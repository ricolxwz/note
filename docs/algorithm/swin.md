---
title: Swin
comments: true
---

# Swin[^1]

## 概要

该研究展现了一种新的视觉Transformer, 叫做Swin-T. 它是一种能够胜任计算机视觉的一般性[骨干网络](/dicts/backbone). 将Transformer从语言领域应用到视觉领域面临着诸多的挑战, 这些挑战源于两者之间的差异. 例如[视觉实体在尺度上的差异](/dicts/large-variation-in-scale-visual-entities/), 图像的高像素分辨率. 为了解决这些差异产生的问题, 作者提出了一种**层次化**的Transformer, 使用**移位窗口**计算表示. 这个移位窗口的方案通过**将自我注意力限制在不重叠的局部窗口中, 同时允许不同窗口间的连接**, 从而提高效率. 这种层次化的结构具有在不同尺度上建模的灵活性, 并且其计算复杂度和图像的大小呈线性关系. 这些特性使得Swin-T能够兼容广泛的视觉任务, 包括图像分类, 在ImageNet-1K上达到87.3%的top-1精度; 密集预测任务, 如目标检测, 在COCO测试集上, 58.7的框平均精度和51.1的掩码平均精度; 语义分割, 在ADE20K上达到53.5mIoU. 它的性能已经超过了之前的SOTA, 在[COCO](/dicts/coco)上, Box AP +2.7, Mask AP +2.6. 在[ADE20K](/dicts/ade20k)上, +3.2 mIoU, 展现了基于Transformer的模型作为视觉主干网络的潜力. 这种**层次化**的设计和**移位窗口**的方法被证明对于所有的MLP架构都是有益的. 代码可以在[https://github.com/microsoft/Swin-Transformer](https://github.com/microsoft/Swin-Transformer)找到.

## 背景

### CV领域的骨干网络

计算机视觉领域的建模长期以来一直由卷积神经网络主导. 从AlexNet及其在ImageNet图像分类挑战赛上的革命性表现开始, CNN架构通过更大的规模, 更广泛的连接和更加复杂的卷积形式变得越来越强大. CNNs作为各种视觉任务的主干网络, 它们的架构的进步带来了性能的提升, 从而显著促进了整个领域的发展.

### NLP领域的骨干网络

在另一个赛道上, 自然语言处理中网络架构的演变则走了一条不同的道路, 如今盛行的架构是Transformer. Transformer模型专为序列建模和[转导任务](/dicts/inductive-transductive-learning)而设计, 其显著的特点在于利用注意力机制来模拟数据中的长程连接关系. 其在语言领域的巨大成功促使研究人员探究其在计算机视觉领域的应用, 最近在特定的任务上, 例如图像分类和联合视觉-语言建模上, 取得了令人鼓舞的成果.

### 图像和文本模态的差异

在这个研究中, 他们旨在找到扩展Transformer的功能, 使其成为一种通用的计算机视觉领域的[骨干网络](/dicts/backbone), 正如它在NLP领域和CNN在视觉领域那样. 作者观察到, 将其在语言领域的出色表现转移到视觉领域面临的重大挑战, 可以用两种模态之间的差异来解释. 其中的一个差异是[尺度](/dicts/large-variation-in-scale-visual-entities/), 于作为语言Transformer处理基本单元的词元不同, 视觉元素的尺度差异很大, 这个问题在目标检测任务中受到了极大关注. 现在的基于Transformer的模型, 所有的token都是固定尺度的, 这对于在视觉领域的应用是不合适的. 另外一个差异是图像中像素的分辨率远远高于文本段落中的文字. 许多视觉任务, 如语义分割, 需要像素级密集预测, 如果图像的分辨率一大, 对于Transformer模型来说是难以处理的, 假设我们对于整张图片的所有像素运用全局注意力, 其复杂度$O(B\cdot N^2\cdot D)$和图像的大小是呈现二次方关系的.

### Swin-T的提出

#### 层次化架构 {#hierarchical-structure}

为了解决这些问题, 作者提出了一种Transformer[通用主干网络](/dicts/backbone), 叫做Swin-T. **它会构建分层特征图, 并且其计算复杂度和图像的大小呈现线性关系. 它通过从小patches开始, 并在更深的Transformer层中(更深的stage)逐渐合并相邻补丁, 构建层次表示(如下图所示)**. 利用这些分层特征图, Swin-T模型可以方便地利用高级稠密预测技术, 例如特征金字塔网络(FPN)或者U-Net. 他们将图像划分为非重叠的窗口(红色框), 并在窗口内局部计算自注意力, 且每个窗口中patch的数量固定, 因此复杂度是图像大小的线性函数(见下方复杂度计算).

<figure markdown='1'>
<!-- ![](https://img.ricolxwz.asia/77e84ae173ab3e1ff94dd4d5a678ac96.webp#only-light){ loading=lazy width='400' }
![](https://img.ricolxwz.asia/77e84ae173ab3e1ff94dd4d5a678ac96_inverted.webp#only-dark){ loading=lazy width='400' } -->
![](https://img.ricolxwz.asia/c78aa09e2a4a017c112084c2eca559a8.webp#only-light){ loading=lazy width='600' }
![](https://img.ricolxwz.asia/c78aa09e2a4a017c112084c2eca559a8_inverted.webp#only-dark){ loading=lazy width='600' }
<figcaption>(a) Swin-T通过在深层合并patches构造层次的特征图, 由于只在窗口内部有注意力, 窗口内patch的数量是固定的, 所以复杂度和图像大小线性相关. (b) ViT只能产生一个低分辨率的特征图, 而且其复杂度和图像大小的平方成正比</figcaption>
</figure>

???+ warning "层次化结构是指不同stage之间的结构具有层次化"

    🌟请注意, 这种patches合并, 窗口变大, 特征图分辨率减半的行为只会发生在不同的stage之间, 不会发生在同一个stage内部, 每个stage内部的窗口大小是不会变的, 每个stage内部会有多个transformer块, 这些transformer块的区别是窗口的位置会交替变化([移位窗口](#shifted-window)). 上图表示的是不同的stage之间的区别, 而不是同一个stage内部的区别.(看下面那张完整的Swin-T架构图).🌟

???+ note "Swin和ViT复杂度简单计算"

    假设图像的大小为$H\times W$, 大小的单位都是像素.

    - ViT: 假设图像在每一层都会被分为$N$个patches. 每一层都要在这些固定的patches之间计算注意力, 所以每一层的复杂度都为$O(N^2\cdot D)$, $D$是每个patch的嵌入维度. 假设patches的大小为$Q\times Q$, 那么$N=\frac{H\times W}{Q^2}$, 代入到公式里面, 就是$O(\frac{(H\times W)^2\cdot D}{Q^4})$. 这表明, ViT的时间复杂度和图像分辨率$H\times W$的平方成正比
    - Swin: 假设第$i$个stage每个窗口的大小为$M_i\times M_i$, 其窗口的数量为$\frac{H\times W}{M_i^2}$, 每个窗口内, 会被划分为固定数量的patches, 假设为$P$, 那么在每个窗口内的自注意力复杂度为$O(P^2\cdot C_i)$, $C_i$是这些patches在第$i$个stage的嵌入维度, 所以第$i$个stage的复杂度是$O(\frac{H\times W\times P^2\times C_i}{M_i^2})$, 由于在最底部的stage$M_i\gg P$, 且随着$i$的变大, $P$是不变的, $M_i$是2倍扩大的, 所以$\frac{P^2}{M_i^2}$是单调递减的, 所以复杂度可以简化为$O(H\cdot W\cdot C_i)$. 这表明, Swin的时间复杂度和图像分辨率$H\times W$成正比

这些优点使得Swin-T成为各种视觉任务的通用主干网络, 这和之前的基于Transformer架构的[ViT](/algorithm/vit)形成对比, 后者所有的patch嵌入都只有单一尺度的特征, 无法有效学习到不同尺度的信息, ^^且只会产生单一分辨率的特征图^^, 所以有二次方的复杂度, ^^而Swin-T随着网络的加深, 其特征图的分辨率会逐渐降低, 而通道数逐渐增加^^.

#### 移位窗口 {#shifted-window}

Swin-T中的另一个比较重要的设计就是移位窗口, Shifted Window. 这种移位窗口发生在同一个stage的不同transformer块之间, 使得不同block的窗口之间产生了连接/重叠/交叉, 让原本独立的窗口之间产生了联系, 使得模型能够学习到更大范围的信息, 提升了在不同窗口之间的理解能力. 如下图所示.

<figure markdown='1'>
![](https://img.ricolxwz.asia/c1b8074569e7a51ce2c3008dd1caf2dc.webp#only-light){ loading=lazy width='500' }
![](https://img.ricolxwz.asia/c1b8074569e7a51ce2c3008dd1caf2dc_inverted.webp#only-dark){ loading=lazy width='500' }
<figcaption>移位窗口. 在左边, 使用的是一种常规的分割策略. 在右边, 是将前一个block的窗口进行移动.</figcaption>
</figure>

这个策略同样在真实世界降低延迟方面也很有效, 所有在同一个窗口内不同的patch的$Q$向量共享的都是同一个键集合, 而不是像传统的滑动窗口(sliding window)方法那样不同的patch的$Q$向量使用的是不同的键集合, 这样可以极大降低延迟和内存占用. 作者的实验显示在消耗的算力差不多的情况下移位窗口策略的延迟相比滑动窗口显著降低. 这种移位窗口的approach被证明对所有的MLP架构是有益的.

<figure markdown='1'>
![](https://img.ricolxwz.asia/8b85d471089af1b92eb97119e1bc71ea.webp#only-light){ loading=lazy width='500' }
![](https://img.ricolxwz.asia/8b85d471089af1b92eb97119e1bc71ea_inverted.webp#only-dark){ loading=lazy width='500' }
<figcaption>传统滑动窗口计算某一个patch对其他patches注意力的时候, 必须要用到它的周围一圈的patches组成的键集合; 但是移位窗口计算某一个patch对其他patches注意力的时候, 只用同一个窗口下的patches组成的键集合. 如b2, b3, b4, b5, b6, b7计算注意力的时候用到的都是同一个键集合. 但是b2, b3计算注意力的时候用到的不是同一个键集合</figcaption>
</figure>

???+ note "理解共用一个键集合"

    参考: https://github.com/microsoft/Swin-Transformer/issues/118#issuecomment-993124909

    > In traditional sliding window method. Different querys, q and q', will have different neighboring windows, which indicates different key sets. The computation is unfriendly to memory access and the real speed is thus not good.
    >
    > In non-overlapping window method used in Swin-T. Different queries within a same red window, for example, q and q', will share a same key set.

### 评估

作者所提出的Swin-T在图像分类, 目标检测和予以分割等识别任务上取得了强大的性能. 它在性能上超越了ViT/DeiT, ResNe(X)t模型, 并且在延迟上所差无几. 它在[COCO](/dicts/coco)上的成绩为58.7 box AP, 51.1 mask AP, 超越了之前的SOTA, +2.7 box AP, +2.6 mask AP. 在[ADE20K](/dicts/ade20k)语义分割上, 在验证集上达到了53.5 mIoU, 较之前的SOTA增加了3.2 mIoU. 它也在ImageNet-1K图像分类的top-1的准度上达到了87.3%.

---

作者深信, 一个在计算机视觉领域和自然语言处理领域统一的架构会对两个领域都有极大的帮助, 因为它能促进视觉和文本信号的联合建模, 并且来自这两个领域的建模只是可以更加深入地共享. 他们相信通过Swin-T在各种视觉任务上的出色表现, 能够让社区更加深入地推动这种信念, 并鼓舞视觉和语言信号的统一建模.

## 相关工作

### CNN和变体

CNN是计算机视觉领域标准的网络模型. 虽然CNN已经存在了几十年, 但是直到AlexNet的出现, CNN才真正兴起并成为主流. 此后, 更深更有效的卷积神经网络架构被提出, 进一步推动了计算机视觉领域的深度学习浪潮, 例如VGG, GoogLeNet, ResNet, DenseNet, HRNet和EfficientNet. 除了这些架构上的改进, 还开展了许多工作来改进各个卷积层, 例如深度卷积和可变形卷积. 虽然CNN及其变体仍然是计算机视觉领域的主要骨干网络, 但是类似Transformer的架构在视觉和语言统一建模方面有巨大潜力. 作者的工作在一些基础视觉识别任务上取得了强劲的性能, 他们希望这些工作能推动建模方式的转变.

### 替代部分或所有空间卷积层

受到自然语言处理领域的自注意力层和Transformer架构的启发, 一些工作将自注意力层用于替代流行的ResNet中的部分或者全部空间卷积层. 在这些工作中, 自注意力机制在每个像素的局部窗口中计算[^4](这就是所谓的滑动窗口, sliding window), 以加快优化过程, 并且它们在精度/FLOPs权衡方面优于对应的ResNet架构. 正如前面所说的, 由于一个patch使用的是周围patches组成的键集合, 所以对于每一个patch, 它们对应的键集合都是不一样的, 所以它们昂贵的内存访问导致实际延迟比卷积神经网络大得很多, 请参考[这里](#shifted-window). 作者建议的是使用移位窗口, 而不是滑动窗口, 这可以在通用硬件上实现更加高效地执行.

### 增强标准CNN

另一条赛道是使用自注意力层或者Transformer增强标准的CNN架构. 自注意力层可以通过编码远距离依赖或者[异质交互](/dicts/heterogeneous-interactions)来补充主干网络或者头部网络. 最近, Transformer的编码器-解码器设计已经被用于目标检测和实例分割任务. 作者的工作探索了将Transformer用于基本视觉特征提取, 和这些工作互补.

### 基于Transformer的视觉骨干

和作者的工作最接近的是[ViT](/algorithm/vit)及其后续研究. 这项开创性的工作直接将Transformer架构用于非重叠的中等尺寸的图像patches进行图像分类. 和CNNs相比, 它在图像分类方面实现了令人印象深刻的**速度-准度的权衡**. ViT需要大规模的训练数据集(如JFT-300M)才能达到和卷积网络类似的表现, DeiT[^5]引入了多种训练策略, 使得ViT也能使用较小的ImageNet-1K数据集达到较高的性能.

ViT在图像分类上的结果令人鼓舞, 但是其架构不适合用作密集视觉任务的通用骨干网络, 并且由于它的特征图分辨率较低, 且复杂度和图像大小的平方成正比的特性, 在输入分辨率过高的情况下也不太合适. 有一些工作将ViT模型应用于目标检测或者语义分割等密集视觉任务, 通过直接[上采样](/dicts/sampling/#upsampling)(通过插值将低分辨率的特征图提高到高分辨率)或者反卷积(在标准卷积中, 可以将高分辨率特征图映射到一个低分辨率的输出, 在反卷积中, 可以将低分辨率特征图反向映射回高分辨率空间)[^6][^7], 但是性能相对较低. 和作者的工作同时进行的还有修改ViT架构以实现更好图像分类的工作. 实验表明, 作者的Swin-T架构在图像分类任务中实现了这些方法中最佳的速度-准确率权衡, 尽管作者的工作侧重于通用性能而不是特定的分类任务. 另一项同时进行的工作[^8]研究了类似的思路, 在Transformer上构建多分辨率的特征图, 但是它的复杂度还是和图像大小的二次方成正比, 而作者的方法是线性的, 并且是在局部操作, 这已经被证明对于建模视觉信号的高相关性是有益的. 作者的方法既高效又有效, 在COCO目标检测和ADE20K语义分割方面都达到了SOTA.

## 方法论

### 整体架构

<figure markdown='1'>
![](https://img.ricolxwz.asia/84eb2b84b063a9220fd7325a70b10e4c.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.asia/84eb2b84b063a9220fd7325a70b10e4c_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>(a) Swin-T的架构. (b) 两个连续的Swin-T块, 其中, W-MSA和SW-MSA分别是常规和移位窗口下的多头注意力模块</figcaption>
</figure>

#### patch嵌入

上图展示了Swin-T的整体架构. 首先通过类似ViT的patch分割模块将输入的RGB图像分割为不重叠的patches. 每个patch都会被视为一个token, 其特征向量是通过将该小块中所有像素的RGB值按照顺序连接起来形成的(类似于NLP领域将词汇转换为one-hot向量的操作). 在作者的实现中, 他们用的patch大小是$4\times 4$, 所以每一个小patch的特征向量的维度是$4\times 4\times 3=48$, 得到的输出大小为$\frac{H}{4}\times \frac{W}{4}\times 48$. 在此之后, 会有一层线性嵌入层, 将其线性投影到一个任意的维度上, 记为$C$(类似于NLP领域将one-hot向量进行嵌入的操作), 得到的patch的数量为$\frac{H}{4}\times \frac{W}{4}$, 输出大小为$\frac{H}{4}\times \frac{W}{4}\times C$, 特征图分辨率为$\frac{H}{4}\times \frac{W}{4}$. 随后, 这些patches会进行经过修改的自注意力计算(2*Swin-T块). 上述操作就是stage1.

???+ example "RGB值顺序连接"

    假设我们有一个2*2像素的小patch, 每个像素的RGB值如下:

    | 像素位置 | R   | G   | B   |
    |----------|-----|-----|-----|
    | (1,1)    | 10  | 20  | 30  |
    | (1,2)    | 40  | 50  | 60  |
    | (2,1)    | 70  | 80  | 90  |
    | (2,2)    | 100 | 110 | 120 |

    假设按照从左到右, 从上到下的顺序排列, 即(1,1) → (1,2) → (2,1) → (2,2). 将每个像素的RGB值按照顺序连接, 得到特征向量: [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120].

#### patch合并

为了产生层次化的表示, 随着stage的变化, 会通过patch合并层(patch merging layer)以减少embedding的数量, 增大patch的分辨率. 第一个patch合并层将相邻的$2\times 2$(共$4$个)patches进行合并, ^^注意, 是对这$4$个patches在**通道**方向上进行合并(如何合并见下图, 将每个窗口相同位置的像素取出), 也就是说, 会得到一个$4C$维向量, 然后再通过一个线性层(通常会将$4C$维度投影到新的维度, 例如$2C$)得到patch合并层的最终输出,^^ 这个向量表示的是像素大小是$8\times 8$, 所以这样的patch数量为$\frac{H}{8}\times \frac{W}{8}$, 输出大小为$\frac{H}{8}\times \frac{W}{8}\times 2C$, 特征图分辨率为$\frac{H}{8}\times \frac{W}{8}$, 然后, 这些patches会通过Swin-T块, 上述操作就是stage2.

<figure markdown='1'>
![](https://img.ricolxwz.asia/af0ec1985beaa09580776e5974f032e3.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.asia/af0ec1985beaa09580776e5974f032e3_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption></figcaption>
</figure>

---

stage3和stage4进行的是和stage2类似的操作, 特征图的分辨率分别是$\frac{H}{16}\times \frac{W}{16}$和$\frac{H}{32}\times \frac{W}{32}$. 这些stage之间会产生一种层次关系, 就像VGG和ResNet那样. 因此, 他们所提出的架构可以方便地替换掉各种视觉任务中现有地骨干网络.

#### Swin-T块

Swin-T块将标准Transformer中的MSA模块替换为基于移位窗口的MSA模块, 然后后接一个中间包含GELU的2层MLP. 在每个MSA模块和MLP之前都有一个LN层. 并且在每个模块后都有残差连接.

### 基于移位窗口的自注意力

标准Transformer架构及其用于图像分类的变种都基于全局自注意力机制, 即计算每个embedding和其他所有embedding之间的注意力. 全局自注意力计算导致复杂度和token的数量成二次关系, 这使得其不适合许多需要大量密集的token用于预测或者表示高分辨率图片的问题.

#### W-MSA模块

为了高效建模, 作者提出在局部窗口内计算注意力. 这些窗口通过以非重叠的方式均匀划分图像产生. 假设每个窗口包含$M\times M$的patches. 那么对于一张具有$h\times w$个patch的图像, 全局MSA模块和基于窗口的W-MSA模块的复杂度为:

$$\begin{aligned}
\Omega(\text{MSA})   &= 4hwC^2 + 2(hw)^2C, \\
\Omega(\text{W-MSA}) &= 4hwC^2 + 2M^2hwC.
\end{aligned}$$

前者对于patch数量$hw$的二次方成正比, 后者当$M$固定的时候是线性的. 当$hw$非常大的时候, 全局自注意力对于硬件来说代价高昂, 而基于窗口的自注意力计算明显更具有可缩放性.

#### SW-MSA模块

上述W-MSA缺乏窗口之间的注意力, 这限制了模型的建模能力. 为了在保持非重叠窗口的高效计算的同时引入跨窗口连接, 作者提出了一种移位窗口的方法, 基于这种方法的注意力机制又叫做SW-MSA. ^^W-MSA和SW-MSA在同一个stage内交替使用.^^

<figure markdown='1'>
![](https://img.ricolxwz.asia/c1b8074569e7a51ce2c3008dd1caf2dc.webp#only-light){ loading=lazy width='400' }
![](https://img.ricolxwz.asia/c1b8074569e7a51ce2c3008dd1caf2dc_inverted.webp#only-dark){ loading=lazy width='400' }
<figcaption>移位窗口. 在左边, 使用的是一种常规的分割策略. 在右边, 是将前一个block的窗口进行移动.</figcaption>
</figure>

如上图所示. W-MSA会将$8\times 8$的特征图划分为$2\times 2$个$4\times 4$($M=4$)的窗口. SW-MSA会将上一层的窗口移动$(\lfloor \frac{M}{2}\rfloor, \lfloor \frac{M}{2}\rfloor)$, 即先向右移动$\lfloor \frac{M}{2}\rfloor$, 然后向下移动$\lfloor \frac{M}{2}\rfloor$.

可以用下列公式描述这两个相邻的Swin-T块的行为.

$$\begin{aligned}
\hat{\mathbf{z}}^{l} &= \text{W-MSA} \left( \text{LN} \left( \mathbf{z}^{l-1} \right) \right) + \mathbf{z}^{l-1}, \\
\mathbf{z}^{l} &= \text{MLP} \left( \text{LN} \left( \hat{\mathbf{z}}^{l} \right) \right) + \hat{\mathbf{z}}^{l}, \\
\hat{\mathbf{z}}^{l+1} &= \text{SW-MSA} \left( \text{LN} \left( \mathbf{z}^{l} \right) \right) + \mathbf{z}^{l}, \\
\mathbf{z}^{l+1} &= \text{MLP} \left( \text{LN} \left( \hat{\mathbf{z}}^{l+1} \right) \right) + \hat{\mathbf{z}}^{l+1},
\end{aligned}$$

注意, 上述的公式中后面的加法表示的是残差连接, 自注意力层和MLP前面都有LN. $\hat{\mathbf{z}}^l$表示的是第$l$块(S)W-MSA模块和MLP模块的输出. 这种移位窗口的方法引入非重叠窗口之间的连接, 这个方法被证明在图像分类, 目标检测和语义分割中是有效的.

##### 循环移位

在使用移位窗口时会遇到的一个问题是, **它会导致窗口的数量增加, 从$\left \lceil \frac{h}{M} \right \rceil \times \left \lceil \frac{w}{M} \right \rceil$增加到$\left( \left \lceil \frac{h}{M} \right \rceil + 1 \right) \times \left( \left \lceil \frac{w}{M} \right \rceil + 1 \right)$, 并且某些窗口的大小会小于$M\times M$**, 如上图中窗口的数量从4个增加到9个, 4个角和4个边出现了小于$4\times 4$的窗口.

一种朴素的方法是将较小的窗口填充到$M\times M$的大小, 然后在计算注意力的时候屏蔽填充的值. 当在W-MSA分割的时候产生的窗口数量较小的时候, 例如, 4个窗口, 就会产生9个窗口, 每个窗口的大小要不是$M\times M$, 要不会被填充到$M\times M$, 所以增加的复杂度约为$\frac{9}{4}=2.25$倍, 这通常是不可接受的, 增加的太多了...

作者提出了一种更加高效的方法: 循环移位, cyclic-shifting. 如图.

<figure markdown='1'>
![](https://img.ricolxwz.asia/dfcac15ee3737b3ab5f5929822dac872.webp#only-light){ loading=lazy width='600' }
![](https://img.ricolxwz.asia/dfcac15ee3737b3ab5f5929822dac872_inverted.webp#only-dark){ loading=lazy width='600' }
</figure>

通过循环移位, 得到的窗口数量和原始窗口数量是一样的, 都是4个, 但是, 可以从上图看到, 左下, 右下, 右上的窗口是由几个在特征图内非相邻的子窗口组成的. 为了解决这个问题, 他们采用了掩码来使自注意力计算限制在各个子窗口内.

<figure markdown='1'>
![](https://img.ricolxwz.asia/ea61d3a1880b70d06eb6a5824b00e023.webp#only-light){ loading=lazy width='500' }
![](https://img.ricolxwz.asia/ea61d3a1880b70d06eb6a5824b00e023_inverted.webp#only-dark){ loading=lazy width='500' }
<figcaption></figcaption>
</figure>

如图, 4是一个独立的窗口, 5和3会被合并为一个窗口, 7和1会被合并为一个窗口, 8, 6, 2, 0会被合并为一个窗口, 所以总共共有4个窗口, 这样就保证了复杂度不增加. 5和3在原图上是不相邻的区域, 不应该有注意力, 所以要计算区域3注意力的时候, 就在3和5组成的窗口上运用掩码, 排除掉5的区域, 这样就只会在3内部计算注意力. 最后要再通过反循环移位移回去, 以保持窗口的相对位置不变.

### 相对位置偏置

相对位置偏置是用来增强注意力机制的一种方法, 它在计算注意力的时候考虑了token之间的相对位置关系, 相对位置信息是计算注意力的时候加入的, 作为一个偏置项(bias). 该偏置$B\in \mathbb{R}^{M^2\times M^2}$, 其中的每一个元素的含义是当前token和其他token之间的相对距离(可以是负数), 修改后的注意力计算公式为:

$$\text{Attention}(Q, K, V) = \text{SoftMax}(QK^T / \sqrt{d} + B)V$$

$Q, K, V\in \mathbb{R}^{M^2\times d}$是query, key, value矩阵, d是query, key的维度, $M^2$是一个窗口中patches的数量. 由于每个轴(水平和垂直)上patches的相对位置位于$[-M+1, M-1]$的范围内, 它们构建了一个较小的偏置矩阵$\hat{B} ∈ \mathbb{R}^{(2M−1)×(2M−1)}$, 其中元素的值是从$B$中取的.

作者观察到使用相对位置偏置的模型在性能上显著优于那些没有使用这种偏置的模型, 或者仅使用绝对位置嵌入的模型. ^^由于另外的研究[^10]发现, 将绝对位置嵌入直接加到输入中会导致性能略微下降, 因此作者决定在Swin-T中不使用绝对位置嵌入.^^

和ViT[类似](/algorithm/vit/#fine-tuning), 在微调的时候, 可以通过双三次插值法调整预训练得到的相对位置偏置, 使其适应不同窗口大小的任务.

### 架构变体

作者构建的base模型是Swin-B, 即基础版, 该模型的大小和计算复杂度和ViT-B, DeiT-B相似. 他们也提供了不同规模的模型版本, 用户可以根据具体的计算资源和需求选择最合适的模型, 如资源有限的设备可以选择Swin-T, Swin-S, 需要高性能的应用可以选择Swin-L. Swin-T的复杂度和ResNet-50, DeiT-S类似, Swin-S的复杂度和ResNet-101类似.

在作者的实现中, 窗口大小被设置为$7\times 7$. 每个自注意力头的查询向量维度$d=32$. MLP中的扩展比例系数$\alpha=4$, 就是说, 隐藏层的维度是输入维度的$4$倍, 这个和Transformer论文是一样的.

Swin-T, Swin-S, Swin-B, Swin-L的具体超参数为:

- Swin-T: C = 96, layer numbers = {2, 2, 6, 2}
- Swin-S: C = 96, layer numbers = {2, 2, 18, 2}
- Swin-B: C = 128, layer numbers = {2, 2, 18, 2}
- Swin-L: C = 192, layer numbers = {2, 2, 18, 2}

其中, C是第一个stage的patches的维度.

[^1]: Liu,., Lin, Y., Cao, Y., Hu, H., Wei, Y., Zhang, Z., Lin, S., & Guo, B. (2021). Swin-T: Hierarchical vision transformer using shifted windows (No. arXiv:2103.14030). arXiv. https://doi.org/10.48550/arXiv.2103.14030
[^2]: 木盏. (2021, 十月 18). Swin-T全方位解读【ICCV2021马尔奖】. Csdn. https://blog.csdn.net/leviopku/article/details/120826980
[^3]: 最容易理解的Swin-T模型(通俗易懂版)—海_纳百川—博客园. (不详). 从 https://www.cnblogs.com/chentiao/p/18379629
[^4]: Hu, H., Zhang, Z., Xie, Z., & Lin, S. (2019). Local relation networks for image recognition (No. arXiv:1904.11491). arXiv. https://doi.org/10.48550/arXiv.1904.11491
[^5]: Touvron, H., Cord, M., Douze, M., Massa, F., Sablayrolles, A., & Jégou, H. (2021). Training data-efficient image transformers & distillation through attention (No. arXiv:2012.12877). arXiv. https://doi.org/10.48550/arXiv.2012.12877
[^6]: Beal, J., Kim, E., Tzeng, E., Park, D. H., Zhai, A., & Kislyuk, D. (2020). Toward transformer-based object detection (No. arXiv:2012.09958). arXiv. https://doi.org/10.48550/arXiv.2012.09958
[^7]: Zheng, S., Lu, J., Zhao, H., Zhu, X., Luo, Z., Wang, Y., Fu, Y., Feng, J., Xiang, T., Torr, P. H. S., & Zhang, L. (2021). Rethinking semantic segmentation from a sequence-to-sequence perspective with transformers (No. arXiv:2012.15840). arXiv. https://doi.org/10.48550/arXiv.2012.15840
[^8]: Wang, W., Xie, E., Li, X., Fan, D.-P., Song, K., Liang, D., Lu, T., Luo, P., & Shao, L. (2021). Pyramid vision transformer: A versatile backbone for dense prediction without convolutions (No. arXiv:2102.12122). arXiv. https://doi.org/10.48550/arXiv.2102.12122
[^9]: Swin transformer—贝壳里的星海—博客园. (不详). 从 https://www.cnblogs.com/tian777/p/17935080.html
[^10]: Dosovitskiy, A., Beyer, L., Kolesnikov, A., Weissenborn, D., Zhai, X., Unterthiner, T., Dehghani, M., Minderer, M., Heigold, G., Gelly, S., Uszkoreit, J., & Houlsby, N. (2021). An image is worth 16x16 words: Transformers for image recognition at scale (No. arXiv:2010.11929). arXiv. https://doi.org/10.48550/arXiv.2010.11929
