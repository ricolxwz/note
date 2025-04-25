---
title: VQ-GAN
comments: false
addi: https://arxiv.org/pdf/2012.09841
---

# VQ-GAN

## 摘要

transformer旨在学习序列数据中的长程交互, 在多种任务上持续刷新state-of-the-art表现. 与CNN相比, transformer不含局部优先的[归纳偏置](/algorithm/vit#inductive-bias), 这会使得他们的表达能力更强, 但在处理长序列(如高分辨率图像)时计算开销巨大. 作者展示了如何结合CNN归纳偏置的有效性与transformer的表达力来建模并合成高分辨率图像. 具体而言, 他们(1)使用CNN学习一个上下文丰富的图像成分词汇表(context-rich vocabulary, 即可重用的局部图像"单词"), 并(2)利用transformer高效地对这些成分在高分辨率图像中的组合进行建模. 该方法可以直接用于条件合成任务, 生成过程既可由非空间条件信息(如类别标签)也可由空间条件信息(如分割图)控制. 尤其是, 作者首次实现了基于transformer的百万像素语义引导图像合成, 并在类条件ImageNet数据集上取得自回归模型(autoregressive model, 逐像素递归生成模型)的state-of-the-art性能.
