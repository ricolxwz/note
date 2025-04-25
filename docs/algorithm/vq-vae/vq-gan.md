---
title: VQ-GAN
comments: false
addi: https://arxiv.org/pdf/2012.09841
---

# VQ-GAN

## 摘要

transformer旨在学习序列数据中的长程交互, 在多种任务上持续刷新state-of-the-art表现. 与CNN相比, transformer不含局部优先的[归纳偏置](/algorithm/vit#inductive-bias), 这会使得他们的表达能力更强, 但在处理长序列(如高分辨率图像)时计算开销巨大. 作者展示了如何结合CNN归纳偏置的有效性与transformer的表达力来建模并合成高分辨率图像. 具体而言, 他们(1)使用CNN学习一个上下文丰富的图像成分词汇表(context-rich vocabulary, 即可重用的局部图像"单词"), 并(2)利用transformer高效地对这些成分在高分辨率图像中的组合进行建模. 该方法可以直接用于条件合成任务, 生成过程既可由非空间条件信息(如类别标签)也可由空间条件信息(如分割图)控制. 尤其是, 作者首次实现了基于transformer的百万像素语义引导图像合成, 并在类条件ImageNet数据集上取得自回归模型(autoregressive model, 逐像素递归生成模型)的state-of-the-art性能.

## 简介

<figure markdown='1' id='fig1'>
![](https://img.ricolxwz.io/b851e6b46df520955647ebc8a62eb6a7.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/b851e6b46df520955647ebc8a62eb6a7_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图1: 该方法使transformer能够合成如本例所示的高分辨率图像, 分辨率为1280x460 pixels.</figcaption>
</figure>

Transformer模型正迅速崛起——它们已成为语言任务的事实标准架构, 并且正被广泛应用于音频和视觉等领域. 与当前视觉领域占主导地位的卷积神经网络(CNNs)相比, transformer架构不包含强调局部交互的归纳先验, 因此能够自由学习输入之间的复杂关系. 然而, 这种普适性意味着模型必须显式学习所有关系, 而CNNs能够利用图像内部强局部相关性的先验知识. 由于需要考虑所有成对交互, transformer更高的表达能力伴随着计算量的二次增长. 由此带来的能耗与时间开销, 使得最先进的transformer模型在扩展到数百万像素的高分辨率图像时面临根本性的挑战.

关于transformer倾向于学习卷积结构的观察引出了一个问题: 在每次训练视觉模型时, 是否必须从零开始重新学习关于图像局部结构与规律性的全部知识, 还是可以**在保留transformer灵活性的同时, 高效地编码图像的归纳偏置**? 作者假设, 低层次图像结构可以通过局部连接(即卷积架构)得到良好刻画, 而当语义层级升高时, 这种结构假设便不再有效. 此外, CNN不仅具有显著的局部性偏置, 还因为在所有位置共享权重而呈现对空间不变性的偏置; 当任务需要更整体地理解输入时, 这一特性会使CNN显得低效.

作者的关键洞见在于, 当卷积架构与transformer架构结合使用时, 二者能够共同刻画视觉世界的组合性本质: 他们首先采用卷积方法高效地学习一个包含丰富上下文的视觉部件码本(codebook, 即离散向量词典), 随后学习这些部件在全局范围内的组合模型. 这些组合内部的长程交互需要表达能力强大的transformer架构来建模各组成视觉部件的分布. 此外, **作者引入对抗式(adversarial)训练, 以确保局部部件字典充分捕获感知上重要的局部结构**, 从而减轻transformer在低层统计建模方面的负担. 当transformer能够专注于其独有的优势——长程关系建模——时, 便能够生成如上图所示的高分辨率图像, 这一能力此前一直难以实现. 该方法的框架还允许通过条件信息(例如目标类别或空间布局)来控制生成图像. 实验结果表明, 该方法延续了transformer的优势, 在性能上超越了此前基于卷积架构的同类码本方法的最新水平.

> 给我的感觉是, 利用了一下CNN的先验偏置提取低层次信息, 然后利用Transformer建模更好的高层次交互. 同时用GAN确保CNN提取到了充分的低层次信息, 减少Transformer隐式建模低层次信息的负担. emmmm... 缝合怪

## 方法

本文旨在充分发挥transformer模型卓越的学习能力, 将其引入至百万像素级别的高分辨率图像合成任务. 此前的研究已在64×64像素范围内展示了transformer用于图像生成的可观潜力, 但由于序列长度导致的计算开销呈二次增长, 这些方法无法直接扩展到更高分辨率.

高分辨率图像合成要求模型能够理解图像的整体构图, 既能生成局部逼真的细节, 也能保持全局一致的模式. 因此, 我们不再使用像素来表示图像, 而是将其表示为由codebook中感知丰富的图像成分所组成的组合. 通过如下面第一小节所述学习一套高效编码, 我们能够显著减少这些组合的描述长度, 从而按照下面第二小节中的方法, 使用transformer架构高效地建模图像内部的全局关联. 如下图所示, 该方法在无条件和有条件设置下均能生成逼真且连贯的高分辨率图像.

<figure markdown='1' id='fig2'>
![](https://img.ricolxwz.io/07632a674c37fb011518d820d6c782d5.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/07632a674c37fb011518d820d6c782d5_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图2: 该方法采用卷积学习蕴含上下文信息的视觉部件码本, 随后使用自回归transformer架构对其组合进行建模. 离散码本作为两种架构之间的接口, 基于patch的判别器在保持高感知质量的同时实现强压缩. 此方法将卷积方法的高效性引入基于transformer的高分辨率图像合成. </figcaption>
</figure>

> 感觉和ViT那一套是很像的, 只不过这里是离散的码字, 但是ViT那里是连续的patch向量. 如果说Transformer更喜欢离散token的话, 可能还是这种方式更合transformer的胃口, 和词表中的那些离散文字token差不多.
