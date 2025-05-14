---
title: RVQ (2022)
comments: false
addi: https://arxiv.org/pdf/2203.01941
---

# RVQ[^1]

## 摘要

针对高分辨率图像的自回归(AR)建模, 向量量化(VQ)通常将图像表示为离散码序列. 较短的序列长度对于AR模型至关重要, 因为这能在建模代码间长程交互时显著降低计算成本. 然而, 作者指出, 在码率–失真权衡(rate-distortion trade-off)意义下, 现有VQ方法难以同时缩短代码序列并保持高保真度图像. 为此, 作者提出了由Residual-Quantized VAE(RQ-VAE)和RQ-Transformer组成的两阶段框架, 以高效生成高分辨率图像. 在固定码本大小的条件下, RQ-VAE能够精确逼近图像特征图, 并将图像表示为离散码的堆叠图. 随后, RQ-Transformer通过预测下一堆栈的代码来学习下一个位置的量化特征向量. 依托RQ-VAE的高精度逼近, 作者可将一张256×256图像压缩为8×8分辨率的特征图, 从而大幅降低RQ-Transformer的计算开销. 实验结果表明, 该框架在无条件与条件图像生成的多个基准上均优于现有AR模型, 并且在生成高质量图像时的采样速度明显快于之前的AR方法.

## 介绍

<figure markdown='1' id='fig1'>
![](https://img.ricolxwz.io/25e4f8ab2eccb9ff9a3b7157b7f2f74c.webp#only-light){ loading=lazy width='600' }
![](https://img.ricolxwz.io/25e4f8ab2eccb9ff9a3b7157b7f2f74c_inverted.webp#only-dark){ loading=lazy width='600' }
<figcaption>图1: 256×256图像条件生成示例. 第一行图像根据ImageNet类别进行生成. 第二行图像基于文本条件生成, 分别为"A cheeseburger in front of a mountain range covered with snow."与"a cherry blossom tree on the blue ocean"; 这些文本条件在训练阶段未出现.</figcaption>
</figure>

向量量化(VQ)已成为自回归(AR)模型生成高分辨率图像的基础技术. 具体而言, 先对图像的特征图(feature map)进行VQ量化, 并按光栅扫描(raster scan)等顺序重新排列, 将图像表示为一系列离散编码. 量化完成后, 训练AR模型按序逐步预测这些编码. 换言之, AR模型能够在不逐像素预测的情况下生成高分辨率图像.

作者提出, 在图像AR建模中缩短离散码序列长度至关重要. 较短的码序列能显著降低AR模型的计算开销, 因为模型在预测下一个码时需要利用前序位置的码. 然而, 现有研究受制于码率–失真(rate-distortion)折衷, 难以进一步缩短图像的序列长度. 具体而言, 若要在保持重建图像质量的同时降低量化特征图分辨率, VQ-VAE必须使用规模呈指数级增长的码本(codebook). 过大的码本不仅增加模型参数量, 还会引发码本坍缩(codebook collapse)问题, 从而导致VQ-VAE训练过程不稳定.

本文提出残差量化VAE(RQ-VAE), 采用残差量化(RQ)对特征图进行精确逼近并降低其空间分辨率. 不同于扩大码本规模的方法, **RQ在固定码本大小的前提下, 以由粗到细的递归方式量化特征图**. 经过$D$次残差量化后, 特征图被表示为由$D$个离散编码堆叠而成的映射. 由于RQ能够组合出$|C|^D$个向量(其中$|C|$为码本大小), RQ-VAE无需庞大码本即可精确逼近特征图, 同时保留编码图像的信息. 得益于这种高精度逼近, RQ-VAE能够将量化特征图的空间分辨率进一步降低, 优于先前研究. 例如, 在256×256图像的AR建模中, RQ-VAE仅需8×8分辨率的特征图.

> 作者的写作手法...emmm,, 不敢恭维. 他只用了一张特征图, 非要说成是"stacked map", 这谁还能看得懂... 还有图1也是如此, **自始至终, 使用的都是同一张特征图**, 不然的话你的空间复杂度优势是哪里来的...

此外, 作者提出RQ-Transformer用于预测RQ-VAE提取的编码. 在RQ-Transformer的输入端, RQ-VAE量化后的特征图被转换为一序列特征向量, 随后RQ-Transformer预测接下来$D$个编码, 以估计下一位置的特征向量. 得益于RQ-VAE降低的特征图分辨率, RQ-Transformer显著减少了计算开销, 并能够轻松学习输入之间的长程依赖. 作者还针对RQ-Transformer提出两项训练技术: soft labeling(软标签)和stochastic sampling(随机采样), 通过缓解自回归模型训练中的exposure bias(曝光偏置)进一步提升性能. 因此, 如[图1](#fig1)所示, 该模型能够生成高质量图像.

主要贡献总结如下:

1. 作者提出残差量化变分自编码器(RQ-VAE), 该方法将图像表示为离散编码的堆叠映射, 同时生成高保真重建图像.
2. 作者提出RQ-Transformer及其两项训练策略——软标签(soft labeling)与随机采样(stochastic sampling), 用于精准预测RQ-VAE的编码并缓解exposure bias(训练阶段与推断阶段分布不一致的问题).
3. 实验结果表明, 相比现有自回归模型, 所提出方法在生成图像质量, 计算成本及采样速度方面均取得显著提升.

## 方法

本文提出包含RQ-VAE与RQ-Transformer的两阶段框架, 用于图像的AR建模(见[图2](#fig2)). RQ-VAE利用码本将图像表示为$D$个离散编码的堆叠映射. 随后, RQ-Transformer以自回归方式预测下一空间位置的$D$个编码. 此外, 作者阐述了RQ-Transformer在AR模型训练中如何缓解曝光偏置(exposure bias)的问题.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/18c69acd3a64e43d09ada8199b5cd210.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/18c69acd3a64e43d09ada8199b5cd210_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图2: 本文提出的两阶段图像生成框架概述如下: 框架由RQ-VAE和RQ-Transformer组成. 在第一阶段, RQ-VAE利用残差量化器将图像表示为$D=4$个离散编码的堆叠. 当该编码堆叠映射被reshape后, RQ-Transformer预测下一空间位置的$D$个编码.</figcaption>
</figure>

### 残差量化VAE

在本节中, 作者首先介绍向量量化(VQ)及VQVAE的数学表述; 随后提出RQ-VAE, 该方法在不扩增码本规模的前提下能够精确逼近特征图, 并阐释RQ-VAE如何将图像表示为离散编码堆叠而成的映射.

#### VQ-VAE简介

设码本$C$为有限集合$\{(k, e(k))\}_{k\in[K]}$, 其中$k$表示离散码, $e(k)\in\mathbb{R}^{n_z}$为其对应的码嵌入, $K$为码本规模, $n_z$为嵌入维度. 给定向量$z\in\mathbb{R}^{n_z}$, 向量量化(记作$Q(z; C)$)返回与$z$最接近的码, 其定义如下:

$$
Q(z; C)=\arg\min_{k\in[K]} \lVert z-e(k)\rVert_2^2
$$

在VQ-VAE将图像编码为离散码图之后, VQ-VAE会利用该编码码图重建原始图像. 设$E$和$G$分别为VQ-VAE的编码器与解码器. 给定输入图像$X\in\mathbb{R}^{H_o\times W_o\times3}$, VQ-VAE首先提取特征图$Z=E(X)\in\mathbb{R}^{H\times W\times n_z}$. 其中$(H, W)=(H_o/f, W_o/f)$表示$Z$的空间分辨率, $f$为下采样因子. 接着, 对$Z$中每一位置的特征向量施加向量量化, VQ-VAE得到码图$M\in[K]^{H\times W}$以及其量化特征图$\hat{Z}\in\mathbb{R}^{H\times W\times n_z}$, 具体为

$$
M_{hw}=Q(Z_{hw};C), \qquad\hat{Z}_{hw}=e(M_{hw})
$$

$Z_{hw}\in\mathbb{R}^{n_z}$是位置$(h,w)$处的特征向量, $M_{hw}$为其编码. 最后, 输入被重建为$\hat{X}=G(\hat{Z})$.

作者指出, 降低$\hat{Z}$的空间分辨率$(H, W)$对于AR模型至关重要, 因为AR模型的计算成本随$HW$增加. 然而, 由于VQ-VAE对图像执行有损压缩, 在减少$(H, W)$并同时保留$X$信息之间存在权衡. 具体而言, 当码本规模为$K$时, VQ-VAE使用$HW\log_2 K$位将图像表示为编码. 根据率-失真理论, 可达到的最优重建误差取决于比特数. 因此, 若要将$(H, W)$进一步减半至$(H/2, W/2)$且仍保持重建质量, VQ-VAE需要大小为$K^4$的码本. 然而, 过大的码本会导致VQ-VAE训练不稳定并出现codebook collapse问题, 因而效率低下.

> 本质上, 他们的工作就是缩小了网格大小, 并间接通过residuald的方式增加了码本的数量.

[^1]: Lee,  D., Kim, C., Kim, S., Cho, M., & Han, W.-S. (2022). Autoregressive image generation using residual quantization (No. arXiv:2203.01941). arXiv. https://doi.org/10.48550/arXiv.2203.01941
