---
title: CVQ-VAE
comments: false
---

# CVQ-VAE[^1]

## 概要

向量量化(VQ)正在机器学习领域卷土重来,其在表示学习中的应用日益广泛.然而,优化现有VQ-VAE中的码向量并非易事.一个问题是码本坍塌,即只有一小部分码向量能接收到对其优化有用的梯度,而大多数码向量则会"死亡"且从未被更新或使用.这限制了VQ在需要高容量表示的复杂计算机视觉任务中学习大型码本的有效性.在本文中,作者提出了一种简单的在线码本学习替代方法,即聚类VQ-VAE(CVQ-VAE).作者的方法选择编码后的特征作为锚点来更新"死亡"的码向量,同时通过原始损失函数优化那些"存活"的码向量.该策略使得未使用的码向量在分布上更接近编码后的特征,从而增加了它们被选中和优化的可能性.作者广泛验证了其量化器在各种数据集,任务(例如重建和生成)以及架构(例如VQ-VAE,VQGAN,LDM)上的泛化能力.CVQ-VAE只需几行代码即可轻松集成到现有模型中.

## 动机

码本坍缩问题: 在现有的VQ-VAE中, 许多模型存在码本坍缩问题, 这意味着只有一小部分codevector在训练中接受到有效的梯度并得到更新, 而大部分码字则从未被使用或者更新. 这会限制VQ在学习大型码本时候的有效性, 而大型码本对于复杂计算机视觉任务至关重要.

<figure markdown='1' id='fig1'>
![](https://img.ricolxwz.io/61c9b6c1f2847a0c8a39f0047ca882c1.webp#only-light){ loading=lazy width='400' }
![](https://img.ricolxwz.io/61c9b6c1f2847a0c8a39f0047ca882c1_inverted.webp#only-dark){ loading=lazy width='400' }
<figcaption>图1: 码本使用率与重建误差. 实验设置与VQ-VAE相同, 仅量化器不同. 所有模型均在CIFAR10数据集上进行训练和评估. VQ-VAE存在大量未被使用的"死亡"向量(图中绿点所示). CVQ-VAE通过使用在线采样的特征锚点来更新这些未优化的向量, 从而实现了100%的码本使用率. 与固定初始化方法相比, CVQ-VAE获得了显著更高的码本困惑度以及更好的重建效果. </figcaption>
</figure>

## 方法

<figure markdown='1' id='fig2'>
![](https://img.ricolxwz.io/c5054cef64c70498f8da00aac2d08587.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/c5054cef64c70498f8da00aac2d08587_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图2: CQ-VAE示意图</figcaption>
</figure>

红色的点对应的是编码器的输出, 你会发现有很多红色的点, 每个红点对应的是一次"前向"编码的输出向量, 即batch中的所有样本都要编码, 所以会有很多红点.

[^1]: Zheng, C., & Vedaldi, A. (2023). Online clustered codebook (No. arXiv:2307.15139). arXiv. https://doi.org/10.48550/arXiv.2307.15139
