---
title: VQ-VAE-2
comments: false
addi: https://arxiv.org/pdf/1906.00446
---

# VQ-VAE-2[^1]

## 摘要

本文探索了将向量量化变分自编码器(VQ-VAE)模型应用于大规模图像生成的可行性. 为此, 作者扩展并增强了VQ-VAE中的自回归先验(autoregressive prior), 由此在保持高一致性与高逼真度(high-fidelity)的同时生成了更优质的合成样本. 模型仅依赖简单的前馈编码器和解码器网络, 因而在对编码或解码速度要求苛刻的场景中尤具吸引力. 此外, VQ-VAE只需在压缩的潜空间中对自回归模型进行采样, 与在像素空间采样相比——尤其是在处理大尺寸图像时——速度提升达一个数量级. 研究结果表明, 通过多尺度分层架构并在潜码上施加强有力的先验, 该模型在生成样本质量上可与当前在ImageNet等复杂数据集上表现最优的生成对抗网络(Generative Adversarial Networks, GANs)相抗衡, 同时避免了GANs常见的模式崩溃及多样性不足等问题.

## 简介

近年来, 深度生成模型取得了显著进展. 这部分得益于架构创新以及计算能力的提升, 使得在更大规模的数据量和模型规模上进行训练成为可能. 这些模型生成的样本若不仔细辨别, 很难与真实数据区分开来, 它们的应用涵盖超分辨率, 领域编辑, 艺术化操作, 以及文本到语音和音乐生成等场景.

<figure markdown='1' id='fig1'>
![](https://img.ricolxwz.io/0e24e058738aa0c57c799f81e0303bf3.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/0e24e058738aa0c57c799f81e0303bf3_inverted.webp#only-dark){ loading=lazy width='800' }
</figure>

本文将生成模型区分为两大类: 基于似然的模型(包括VAE, 流模型和自动回归模型); 以及隐式生成模型, 如GAN. 不同模型在样本质量, 多样性, 生成速度等方面各有取舍.

???+ note "隐式生成模型和显式生成模型"

    显式生成模型如VAE之所以被称为显式, 是因为它们在模型定义中给出了可计算或者可由

GANs通过极小极大目标函数进行优化, 其中生成器神经网络将随机噪声映射到图像, 判别器通过把生成样本判定为真或假来定义生成器的损失函数. 随着数据量和模型规模的扩大, GANs现已能够生成高质量, 高分辨率图像. 然而, 众所周知, 这些模型的样本并未充分覆盖真实分布的多样性. 此外, 目前尚缺乏在测试集上评估过拟合程度的令人满意的泛化度量, 因而GANs的评估依然具有挑战性. 在模型比较与选择时, 研究者通常依赖图像样本或图像质量的代理指标, 例如InceptionScore(IS, 评估生成图像类别分布的置信度与多样性)和FréchetInceptionDistance(FID, 度量生成分布与真实分布在Inception特征空间中的Fréchet距离).

> 这里说的是IS, FID这些指标只能简介衡量生成图像质量的好坏.


[^1]: Razavi, A., Oord, A. van den, & Vinyals, O. (2019). Generating diverse high-fidelity images with VQ-VAE-2 (No. arXiv:1906.00446). arXiv. https://doi.org/10.48550/arXiv.1906.00446
