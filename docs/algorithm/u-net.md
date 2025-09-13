---
title: U-Net
comments: true
---

# U-Net[^1]

## 摘要

普遍认为, 成功训练深度神经网络需要数以千计的标注样本. 本文提出了一种充分依赖数据增强的新型网络架构与训练策略, 使得有限标注数据也能被高效利用. 该架构包含一条用于捕获上下文的收缩路径, 以及一条对称的扩张路径以实现精准的定位. 我们证明, 这样的网络可以端到端地从极少量图像中训练, 并在ISBI电子显微堆栈神经结构分割挑战赛中超越此前最佳的滑动窗口卷积网络方法. 使用相同的网络在透射光显微图像(相差和DIC)上训练后, 他们在2015年ISBI细胞跟踪挑战赛的相关类别中以巨大优势获得第一. 此外, 网络推理速度很快: 在最新GPU上分割一张512×512的图像耗时不到1秒. 完整实现(基于Caffe)及训练好的网络已发布于[https://lmb.informatik.uni-freiburg.de/people/ronneber/u-net](https://lmb.informatik.uni-freiburg.de/people/ronneber/u-net).

???+ note "滑动窗口卷积"

    滑动窗口卷积是一种早期像素级分割的方法, 具体流程可以总结为: 使用一个滑动窗口从原图中取下一个个的patch, 然后使用同一个CNN进行前向传播, 输出中心像素的类别结果, 然后把所有位置预测拼接回完整分割图. 这种方法有几个问题: 第一是推理速度较慢, 因为必须为整张图中的每个patch都进行单独的前向传播; 第二是上下文不足, patch大小是固定的而且往往比较小, 如果想要看到更大的context就必须增大窗口加深网络; 第三是重复计算, 相邻的patch是高度重叠的, 会导致重复计算大量特征.

## 简介

### 深度卷积网络

过去两年, 深度卷积网络在许多视觉识别任务中均取得了超越先前最佳方法的表现. 例如, 尽管卷积网络(convolutional network)早已提出, 但由于可用训练集规模有限及网络本身较小, 其表现一直受限. Krizhevsky等人的突破在于, 他们在ImageNet数据集(包含100万张训练图像)上, 对一个拥有8层, 数百万参数的大型网络进行了有监督训练. 自那时起, 研究人员又训练了更大更深的网络. 卷积网络的典型应用是分类任务, 即对整幅图像输出单一类别标签.

### 滑动窗口卷积

然而, 在许多视觉任务(尤其是生物医学图像处理)中, 目标输出还应包含定位信息, 即为每个像素分配类别标签. 此外, 在生物医学任务中, 往往难以获得成千上万的训练图像. 因此, Ciresan等人采用滑动窗口(sliding-window)方式训练网络, 为每个待预测像素提供其周围的局部区域(patch)作为输入, 从而预测该像素的类别标签. 首先, 这种网络具备定位能力; 其次, 以patch计的训练样本数量远大于图像数量. 该网络在ISBI2012的电子显微图像分割挑战赛中以巨大优势获胜.

显而易见, Ciresan等人的策略存在两个缺点. 第一, 速度较慢, 因为网络必须对每个patch单独推理, 而且重叠patch带来了大量冗余计算. 第二, 在定位精度与上下文利用之间存在权衡: 较大的patch需经过更多max-pooling层, 导致定位精度下降, 而较小的patch则只能提供有限上下文信息. 较新的方法通过在分类输出中融合多层特征, 使得精准定位与充分利用上下文能够同时实现.

### 全卷积网络

本文基于一种更为优雅的架构——全卷积网络(fully convolutional network, FCN). ^^作者对该架构进行了修改与扩展, 使其在仅需极少量训练图像的情况下即可获得更精确的分割结果^^; 见[图1](#fig1). FCN的核心思想是: 在常规收缩(contracting)网络之后追加若干层, 将池化(pooling)操作替换为上采样(upsampling)操作, 继而逐步提高输出分辨率. 为了实现精确定位, **收缩路径中的高分辨率特征与上采样后的输出进行融合**, 随后的卷积层便可基于这些融合信息学习组装出更为细致的分割结果.

<figure markdown='1' id='fig1'>
![](https://img.ricolxwz.cn/ea7b522b02df0594678669305f245d3e.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.cn/ea7b522b02df0594678669305f245d3e_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图1: U-Net架构(以最低分辨率32×32像素为例). 每个蓝色方块对应一个多通道特征图, 方块顶部标注通道数, 左下角标注x-y尺寸. 白色方块表示复制的特征图. 箭头表示不同操作. </figcaption>
</figure>

### U-Net

FCN架构中的一个重要改进是, 上采样部分他们同样使用大量特征通道, **使网络能够将上下文信息传递到更高分辨率层**. 结果, 扩张路径与收缩路径大体对称, 形成U型结构. 网络不含任何全连接层, 并且仅使用每次卷积的有效区域, 即分割图仅包含在输入图像中拥有完整上下文的像素(这就会导致边界像素无法预测问题, 往下看他们是怎么解决的). 这一策略使网络能够通过overlap-tile策略无缝分割任意大小图像(见[图2](#fig2)). 为预测图像边界区域像素, 缺失上下文通过镜像输入图像进行外推. 该拼接策略对在大尺寸图像上应用网络至关重要, 否则分辨率将受限于GPU内存.

???+ note "仅仅使用每次卷积的有效区域"

    这指不在输入周围补零, 核只能在"合法"区域滑动; 若输入大小为$n$, 卷积核大小为$f$, 步长为$s$, 输出大小变为$\lfloor\frac{n-f}{s}+1\rfloor$, 因此每次卷积都会让特征图在边缘缩小一圈. ​

<figure markdown='1' id='fig2'>
![](https://img.ricolxwz.cn/b052e82e71d0d1895b95edac6078e21e.webp#only-light){ loading=lazy width='400' }
![](https://img.ricolxwz.cn/b052e82e71d0d1895b95edac6078e21e_inverted.webp#only-dark){ loading=lazy width='400' }
<figcaption>图2: 重叠拼块(overlap-tile)策略能够实现对任意大小图像的无缝分割(此处示例为电子显微镜堆栈中的神经结构分割). 在预测黄色区域的分割结果时, 网络需要蓝色区域内的图像数据作为输入; 若输入数据缺失, 则通过镜像扩展(mirroring)进行外推补全. </figcaption>
</figure>

鉴于本研究任务可用的训练数据极为有限, 作者通过**对现有训练图像施加弹性形变(elastic deformations)来进行大量数据增强**. 这种做法使网络能够学习对该类形变的不变性(invariance, 即输出对输入形变不敏感), 而无需在带注释的图像语料库中显式见到这些变换. 在生物医学分割领域尤为关键, 因为形变是组织中最常见的变异形式, 且现实的形变可被高效地模拟. Dosovitskiy等人已在无监督特征学习(unsupervised feature learning)背景下证明了数据增强对于学习不变性的价值.

在许多细胞分割任务中, 另一个难点是将同类别, 相互接触的目标区分开来; 见[图3](#fig3). 为此, 作者提出在损失函数中使用加权损失(weighted loss), 对位于接触细胞之间的背景标签给予较大的权重.

<figure markdown='1' id='fig3'>
![](https://img.ricolxwz.cn/6e8e8b6c2a4e54e1db67f9e204097c47.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.cn/6e8e8b6c2a4e54e1db67f9e204097c47_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图3: 玻片上的HeLa细胞, 使用DIC(differential interference contrast)显微镜成像.  (a) 原始图像.  (b) 与真实分割标签叠加; 不同颜色对应不同HeLa细胞实例.  (c) 生成的分割掩模(白色:前景, 黑色:背景).  (d) 像素级损失权重图, 用于强化网络对边界像素的学习.</figcaption>
</figure>

### 打榜

所得网络可广泛应用于多种生物医学分割任务. 在本文中, 作者展示了其在EM堆栈(电子显微电镜堆栈)神经结构分割中的效果——该任务自ISBI2012启动的持续竞赛——并成功超越了Ciresan等人的网络. 此外, 作者还报告了在ISBI2015细胞跟踪挑战赛中的光学显微图像(cell segmentation in light microscopy)分割结果, 在最具挑战性的两组二维透射光数据集上取得了显著领先优势.

[^1]: Ronneberger, O., Fischer, P., & Brox, T. (2015). U-net: Convolutional networks for biomedical image segmentation (No. arXiv:1505.04597). arXiv. https://doi.org/10.48550/arXiv.1505.04597
