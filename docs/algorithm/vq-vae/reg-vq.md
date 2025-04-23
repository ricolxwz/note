---
title: Reg-VQ
comments: false
addi: https://arxiv.org/pdf/2303.06424
---

# Reg-VQ[^1]

## 摘要

将图像量化为离散表示一直是统一生成模型的基础性问题. 目前的主要方法, 要么通过确定性量化: 选择最佳匹配的token(令牌)来学习离散表示; 要么通过随机量化: 从预测分布中采样来学习离散表示. 然而, 确定性量化存在严重的码本坍缩(codebook collapse)问题, 并且与推断阶段存在不一致; 而随机量化则面临低码本利用率和重构目标受扰动的问题. 本文提出了一种正则化向量量化框架, 通过两个方面的正则化有效缓解上述问题. 其一是先验分布正则化, 用于度量先验token分布与预测token分布之间的差异, 以避免码本坍缩和低码本利用率; 其二是随机掩码正则化, 通过在量化过程中引入随机性, 在推断阶段不一致性和重构目标未受扰动之间取得良好平衡. 此外, 我们设计了一种概率对比损失, 作为经过校准的度量, 进一步缓解重构目标受扰动问题. 大量实验证明, 该正则化量化框架在包括自回归模型和扩散模型在内的多种生成模型上均优于现有的向量量化方法.

## 简介

### 离散化token很重要

随着多模态图像合成和Transformer的流行, 研究界对跨越不同数据模态的统一建模表现出越来越大的兴趣. 为了实现不同数据模态之间的通用数据表示, 离散表示学习发挥了重要作用. 尤其是向量量化模型(如VQ-VAE和VQ-GAN)作为一类有前景的通用图像表示学习方法, 通过将图像离散化为离散token来实现表示学习. 利用这种token化表示, 诸如自回归模型和扩散模型等生成模型可以用于捕捉序列token的依赖, 以进行图像生成, 在此语境下称为token化图像合成.

### 现有确定性/随机量化存在的问题

根据离散token的选择方式, 向量量化模型大致可分为确定性量化和随机量化两类. 具体而言, 典型的确定性方法如VQ-GAN通过Argmin或Argmax直接选择最佳匹配的token; 而随机方法如Gumbel-VQ则根据预测的token分布进行随机采样. 另一方面, 确定性量化存在[码本崩溃](/dicts/codebook-collapse)问题, 即大部分码本嵌入向量无效, 值接近零(如下[图1](#fig1)所示); 此外, 确定性量化与生成建模的推断阶段不一致, 后者通常会随机采样token而非选择最佳匹配的. 与之相对, 随机量化通过[Gumbel-Softmax](/dicts/gumbel-softmax)对token分布进行采样, 能够避免码本崩溃并缓解推断不一致; 然而, 尽管随机量化中的大多数码本嵌入值是有效的, 实际用于量化的仅是一小部分, 导致码本利用率低(如下[图1](#fig1)所示). 另外, 由于随机方法从分布中采样token, 重构图像往往与原始图像不完全对齐, 导致重构目标受到扰动, 重建图像不够真实.

<!-- <figure markdown='1' id='fig1'>
![](https://img.ricolxwz.io/f774a558fda60099392a926954d75ed2.webp#only-light){ loading=lazy width='600' }
![](https://img.ricolxwz.io/f774a558fda60099392a926954d75ed2_inverted.webp#only-dark){ loading=lazy width='600' }
<figcaption>图1: 在CelebA-HQ数据集上的表现, 左侧为VQ-GAN, 右侧为Reg-VQ</figcaption>
</figure> -->

<figure markdown='1' id='fig1'>
![](https://img.ricolxwz.io/1a9e69a42fb317dbd4461ff0feb3efa8.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/1a9e69a42fb317dbd4461ff0feb3efa8_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图1: 在ADE20K数据集上, 第一行为码本可视化, 第二行为码本利用率示意图. VQGAN存在严重的码本坍缩问题, 大多数码本嵌入为无效值. Gumbel-VQ为所有码本嵌入学习到有效值, 然而如利用率示意图所示, 仅有少数嵌入实际用于量化. 相比之下, 本文提出的正则化量化既避免了码本坍缩, 又实现了完整的码本利用. </figcaption>
</figure>

???+ note "VQ训练和推理阶段的不一致"

    在VQ-VAE里, 训练阶段和推断阶段对离散化(quantization)的处理方式不一样, 导致二者不一致:

    1. 训练阶段的确定性量化

        编码器输出连续潜变量\(z_e(x)\), 然后使用最邻近查询(nearest-neighbor)进行硬分配:

        \[
            k^* = \arg\min_j \|\,z_e(x) - e_j\,\|_2
        \]

        也就是说, 不管\(z_e(x)\)的预测分布如何, 始终"硬"地选取距离最近的码本向量\(e_{k^*}\).

    2. 推断阶段的随机采样

        在生成模型(比如在离散潜空间上训练的自回归模型或扩散模型)里, 下一步token \(k\)并不是用\(\arg\min\)硬选, 而是基于模型预测的概率分布\(p(k\mid \text{context})\)随机采样:

        \[
            k\sim p(k\mid\text{context})
        \]

        采样出来的\(k\)可能并不是训练编码器时最常见的那些"最优"索引, 而是来自概率尾部的样本.

    分布不匹配的后果:

    - 训练时解码器只见过硬分配出来的, "最常用"且确定的码向量.
    - 推断时可能要处理那些训练时极少或未曾见过的码向量, 让解码器难以恢复出高质量的图像.

    这种"训练时的确定性"与"推断时的随机性"之间的分布差异, 就称为训练/推断不一致(train–inference mismatch).

### 正则化量化框架

#### 正则化先验分布

在本文中, 提出了一种正则化量化框架, 从两个视角对上述问题进行有效抑制. 具体而言, 为了避免码本坍缩(codebook collapse)以及低码本利用率(即仅少量码本嵌入向量有效或被用于量化), 引入了一种先验分布正则化(prior distribution regularization), 假设token分布的先验为均匀分布. 由于后验token分布可由量化结果近似得到, 因此可以度量先验分布与后验分布之间的差异. 通过在训练过程中最小化该差异, 量化过程被正则化以使用所有码本嵌入向量, 从而防止预测的token分布坍缩到少量码本嵌入.

#### 随机掩码正则化

由于确定性量化在推断阶段存在不一致性, 而随机量化则面临重建目标受到扰动的问题, 作者引入了随机掩码正则化, 以在两者之间取得平衡. 具体来说, 随机掩码正则化会随机地对一定比例的区域应用随机量化, 而对未被掩码的区域则保持确定性量化. 这样在量化过程中引入了不确定性, 缩小了与生成式建模推断阶段中随机选择token(令牌)的差距. 作者还通过深入且全面的实验, 分析了掩码比率的选择对图像重构和生成性能的影响.

#### 弹性图像重建损失

另一方面, 随机采样token会导致随机量化区域的重构目标受到扰动. 这种扰动主要源自"要求利用随机采样token以L1损失完美重构原图"的目标设定. 为避免直接施加严格的L1重构损失, 作者引入了一种对比损失(contrastive loss, 通过在特征空间中"拉近"正样本对并"拉远"负样本对来学习判别表示)实现的弹性图像重建(elastic image reconstruction), 由此显著减轻了重构目标的扰动. 具体而言, 类似PatchNCE, 该对比损失将同一空间位置的patch视为正样本对(positive pairs, 位置一致), 将其他位置的patch视为负样本对(negative pairs). 通过在嵌入空间中拉近正样本对并拉远负样本对, 模型能够在保持内容一致性的同时获得更具弹性的重建效果. 此外, 随机采样token还会在重构目标中引入不同尺度的扰动. 为此, 作者提出了概率对比损失Probabilistic Contrastive Loss(PCL): 该损失根据"随机采样token嵌入"与"最佳匹配token嵌入"之间的差异, 自适应地调整各区域的"拉近力度(即对比损失中的pulling force)", 从而进一步缓解多尺度扰动对重建质量的影响.

### 贡献

本研究的贡献可归纳为三点:

1. 提出正则化量化框架, 通过引入先验分布正则化以防止codebook collapse并提高codebook利用率.
2. 提出随机掩码正则化(stochastic mask regularization), 用以缓解生成建模推断阶段的失配问题.
3. 设计概率对比损失(probabilistic contrastive loss), 达成弹性图像重建, 并在随机量化下针对不同区域自适应地减轻受扰动的重构目标.

## 方法

如[图2](#fig2)所示, 正则化量化框架融合了确定性量化与随机量化, 由编码器$E$, 解码器$G$以及码本$Z=\{z_n\}_{n=1}^{N}\in\mathbb{R}^{N\times d}$组成, 其中$N$表示码本大小,$d$表示嵌入维度. 对于输入图像$X$, 编码器$E$首先生成一组空间token分布$\{x_i\}_{i=1}^{H\times W}$, 其中$x_i\in\mathbb{R}^{N}$,$H\times W$为空间向量大小. 随后, 每个编码向量依据其预测token分布被映射为离散token(即码本嵌入的索引). 与索引对应的码本嵌入随后被输入解码器$G$以重建原图像.

在向量量化框架完成训练后, 图像即可用这些码本索引(离散token)表示. 基于离散token, 生成模型如auto-regressive模型与diffusion模型可用于建模token之间的依赖关系. 在生成推断阶段, 先从模型采样得到一串token用于图像合成; 再将这些token映射回其对应的码本嵌入并输入解码器$G$, 便可直接生成图像.

<figure markdown='1' id='fig2'>
![](https://img.ricolxwz.io/b45caeadd4f3884a90c2aac839984c3c.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/b45caeadd4f3884a90c2aac839984c3c_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图2: 所提出的正则化量化框架流程如下: 在预测token分布上施加随机掩码(紫色区域)以指定随机采样区域. 随后, 编码向量依据选中的码本嵌入表示, 产生用于图像重建的量化向量. 为避免码本坍缩及低码本利用率, 通过计算后验token分布与先验token分布之间的KL散度$D_{\mathrm{KL}}(P\,\|\,Q)$实现正则化.</figcaption>
</figure>

### 正则化先验分布

现有向量量化模型常因码本坍缩或码本利用率低而表现不佳——仅有少量码本嵌入向量有效或被用于量化. 因此, 作者提出在量化过程中引入先验分布正则化. 具体而言, 为量化所用的token设定一个先验分布. 理想情况下, 先验分布应为离散均匀分布

$$
P_{prior}=[1/N,\,1/N,\,\dots,\,1/N], \qquad P_{prior}\in\mathbb{R}^{N},
$$

这意味着所有码本嵌入可被均匀使用, 其信息容量依据最大熵原理得到最大化.

在量化过程中, 尺寸为$H\times W$的图像特征被映射到对应token, 每个特征的预测量化结果可表示为独热向量$\mathbf{p}_i\;(i\in[1,H\times W])$. 因而, 后验token分布可用所有独热向量的平均近似:

$$
P_{post}
=\frac{\sum_{i=1}^{H\times W}\mathbf{p}_i}{H\times W}
=[p_1,p_2,\dots,p_N].
$$

???+ tip "注意$\mathbf{p}_i$和$p_1,...,p_n$的区别"

    $\mathbf{p}_i$表示的是独热向量, $p_1, ..., p_N$表示离散token的概率分布.

???+ example "后验分布"

    $\mathbf{p}_i$是第$i$个空间位置(共$H\times W$个)来说, 编码器会选出码本中的某个离散token. 记码本大小为$N$, 这个选择用一个长度为$N$的one-hot向量$\mathbf{p}_i$表示, 选中的那一个维度为$1$, 其余为$0$. $\sum_{i=1}^{H\times W}\mathbf{p}_i$表示把所有的one-hot向量相加, 相当于把每个token被选中的总次数数出来, 例如若第3个token在全部位置被用了20次, 则求和结果的第3维就是20. $\frac{1}{H\times W}$表示再除以总像素数, 把次数变成频率. 结果就是得到了一个后验token分布$P_{post}$: 每个token在当前图像中出现的比例.

随后, 通过Kullback–Leibler散度衡量先验与后验token分布的差异:

$$
\mathcal{L}_{kl}=KL(P_{post},P_{prior})
=-\sum_{n=1}^{N}p_n\log\frac{1/N}{p_n}\tag{1}
$$

最小化KL散度$\mathcal{L}_{kl}$即可对向量量化进行有效正则化, 进而避免码本坍缩和码本利用率低的问题.

### 随机掩码正则化

[^1]: Zhang, J., Zhan, F., Theobalt, C., & Lu, S. (2023). Regularized vector quantization for tokenized image synthesis (No. arXiv:2303.06424). arXiv. https://doi.org/10.48550/arXiv.2303.06424
