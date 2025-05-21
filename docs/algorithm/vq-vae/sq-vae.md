---
title: SQ-VAE
comments: true
---

# SQ-VAE[^1]

## 摘要

向量量化变分自编码器(VQ-VAE)的一大公认问题是, 学得的离散表示只使用了码本(codebook)全部容量的一小部分, 这种现象也称为码本坍缩(codebook collapse). 作者假设, VQ-VAE的训练方案——其中包含一些精心设计的启发式策略——正是导致该问题的根源. 为此, 本文提出了一种新的训练方案, 通过新颖的随机反量化(stochastic dequantization)和量化(quantization)机制, 将标准VAE扩展为随机量化变分自编码器(SQ-VAE). 在SQ-VAE的训练过程中, 作者观察到量化在初始阶段呈现随机性, 但随着训练进行逐步趋于确定性, 这一现象被称为自退火(self-annealing). 实验结果表明, SQ-VAE在无需常见启发式策略的情况下即能显著提升码本利用率; 此外, 作者还实证证明, 在视觉和语音相关任务中, SQ-VAE均优于VAE和VQ-VAE.

## 动机

这篇文章的动机是为了解决当前向量量化变分自编码器(VQ-VAE)存在的码本坍缩问题及其训练对启发式技巧如梯度直通, SG操作符和超参数精细调优的依赖. VQ-VAE通过将编码后的潜变量量化到可学习码本中的最近邻元素来生成样本, 并在多个任务中展现优越性. 然而, VQ-VAE的训练不完全遵循标准变分贝叶斯框架, 且经常因码本元素未被充分利用而导致重建精度下降. 作者推测确定性量化是导致码本坍缩的原因, 并以此为出发点, 提出了随机量化变分自编码器(SQ-VAE), 该模型结合了随机量化与VAE, 旨在提高码本利用率, 且其训练无需依赖启发式技巧或大量的超参数调优.

!!! note "VQ-VAE和贝叶斯框架"

    VQ-VAE并不在经典的贝叶斯/变分框架下, 它没有先验, 不假设$p(z)$. 并且, VAE的编码器输出的是一个分布, 而VQ-VAE的编码器输出的是一个连续的向量, 潜变量的分布是由码本的使用频率隐式地学到的. 正是因为它不属于经典的贝叶斯框架, 所以我们需要commit损失, 码本损失.


[^1]: Takida, Y., Shibuya, T., Liao, W., Lai, C.-H., Ohmura, J., Uesaka, T., Murata, N., Takahashi, S., Kumakura, T., & Mitsufuji, Y. (2022). SQ-VAE: Variational bayes on discrete representation with self-annealed stochastic quantization (No. arXiv:2205.07547). arXiv. https://doi.org/10.48550/arXiv.2205.07547
