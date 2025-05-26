---
title: GRFSQ
comments: false
---

# GRFSQ (2024)[^1]

## 概要

作者提出了VQTalker, 这是一种基于矢量量化的多语言说话头生成框架, 旨在解决跨多种语言时唇形同步和自然运动所面临的挑战. 作者的方法基于这样一种语音学原理: 人类语音由有限集合的不同声音单元(音素)和相应的视觉发音(视素)组成, 而这些单元在不同语言之间常常存在共性. 作者引入了一种基于组残差有限标量量化(GRFSQ)的面部运动标记器, 该标记器能够创建面部特征的离散化表示. 这种方法能够全面捕捉面部运动, 同时即使在训练数据有限的情况下, 也能提高对多种语言的泛化能力. 基于这种量化表示, 作者实现了一个从粗到细的运动生成过程, 该过程逐步优化面部动画. 大量实验表明, VQTalker在视频驱动和语音驱动两种场景下均达到了当前最佳性能, 尤其是在多语言环境中. 值得注意的是, 作者的方法在512×512像素的分辨率下实现了高质量结果, 同时保持了约11kbps的较低比特率. 作者的研究为跨语言说话人脸生成开辟了新的可能性.

## 动机

目前常用的音视频数据集, 例如VoxCeleb, HDTF绝大多数是Indo-European语系语言, 导致模型在处理其他语系的时候效果不佳. 现有的很多技术在处理音频输入和面部动作输出的时候, 都将他们视为连续, 平滑变化的值. 这意味着他们可以在一个范围内取无限多个可能的值. 然而, 人类的语音和视觉表达(嘴唇动作)实际上是由有限数量的基本单元构成的. 语音由不同的音素(phonemes)组成, 而嘴唇动作则对应不同的视素(visemes), 这些单元的数量是有限的. 由于连续表示允许无限的变化, 模型需要从这个无限的空间中学习如何映射到有限的, 有意义的动作, 这会增加训练的复杂性, 更重要的是, 这很容易导致过拟合, 模型可能会过度学习训练数据中(主要是Indo-European语系)中那些细微的, 连续的变化, 而当遇到其他语言的时候, 就无法准确地捕捉到唇形和面部表情. 有些工作想要通过更多的训练数据在多语种上具有泛化性, 但是这种做法资源消耗巨大并且对小语种很不友好.

## 贡献

* 为解决单一码本容量有限, 难以高效捕捉复杂面部动作的问题, 作者提出了一种基于 Group Residual Finite Scalar Quantization (GRFSQ) 的多策略量化方案, 结合群组量化, 残差量化和 Finite Scalar Quantization, 既缩小了码本规模又提升了利用率, 能在 512×512 分辨率下以约 11 kbps(仅为连续表示方法 16 kbps 最低码率的 70%)进行运动表示.
* 在此基础上, 作者设计了一个交织式码本生成模式: 同一运动粒度内采用非自回归方式以保持双向注意力并充分利用时间相关性, 不同粒度间则采用自回归策略实现从粗到细的生成流程, 从而在生成速度与动画质量之间取得平衡.

## 方法

<figure markdown='1' id='fig1'>
![](https://img.ricolxwz.io/7cc71a0e5ccd7f49297ab9c3bf93b84b.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/7cc71a0e5ccd7f49297ab9c3bf93b84b_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图1: VQTalker框架包含两个主要组成部分:(1)一个量化的面部运动编解码器, 它通过自监督学习和组残差FSQ(GRFSQ)来学习一种通用的运动表示. (2)一个使用BERT模型的从粗到精的运动生成过程, 该模型接收语音令牌, 并在多个残差层上迭代生成面部运动令牌. 最后, 图像渲染器根据生成的离散码字合成最终的说话头像视频. </figcaption>
</figure>

<figure markdown='1' id='fig2'>
![](https://img.ricolxwz.io/04780f9740de57a0b57bade6e7e02d50.webp#only-light){ loading=lazy width='500' }
![](https://img.ricolxwz.io/04780f9740de57a0b57bade6e7e02d50_inverted.webp#only-dark){ loading=lazy width='500' }
<figcaption>图2: 码本交错模式与混合面部运动生成矩阵. 其中, 行(r1至r4)代表细节程度递增的残差码本. t1至t4则标示了每个残差层的顺序处理步骤, 每个ti步骤都会一次性生成对应的ri. </figcaption>
</figure>

总的来说, 就是一个大杂烩, [图1](#fig1)(左)里面对应的是那个RQ-VAE, Group VQ, FSQ的缝合版本, 右边是一个他们自己设计的自回归生成器. 同一层的所有样本是non-autoregressive生成的, 新的层的样本是autoregressive生成的.

[^1]: Liu, T., Ma, Z., Chen, Q., Chen, F., Fan, S., Chen, X., & Yu, K. (2024). VQTalker: Towards multilingual talking avatars through facial motion tokenization (No. arXiv:2412.09892; Version 1). arXiv. https://doi.org/10.48550/arXiv.2412.09892
