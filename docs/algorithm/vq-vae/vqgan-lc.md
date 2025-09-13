---
title: VQGAN-LC (2024)
comments: true
---

# VQGAN-LC (2024)[^1]

## 概要

在以VQGAN为代表的图像量化领域, 图像被编码为从预定义大小的码本中提取的离散标记. 近期的研究进展, 特别是在LLAMA 3方面的成果显示, 增大码本能够显著提升模型性能. 然而, VQGAN及其变体, 如VQGAN-FC(因子化编码)和VQGAN-EMA, 在扩展码本规模和提高码本利用率方面仍面临挑战. 例如, VQGAN-FC能学习的码本大小上限为16384, 在ImageNet数据集上的利用率通常不足12%. 在这项工作中, 作者提出了一种名为VQGAN-LC(大码本)的新型图像量化模型, 它将码本规模扩展至100000, 并实现了超过99%的利用率. 与以往优化每个码本条目的方法不同, 作者的方法从一个由预训练视觉编码器提取的100000个特征初始化的码本开始. 其优化重点在于训练一个投影器, 旨在将整个码本与VQGAN-LC中编码器的特征分布对齐. 作者证明了他们提出的模型在图像重建, 图像分类, 使用GPT进行自回归图像生成以及利用基于扩散和流的生成模型进行图像创建等多种任务中, 性能均优于同类模型.

## 动机

扩大码本规模和提高码本利用率. 传统的VQGAN模型在潜空间中常常遇到码本坍缩的问题. 这使得他们难以将码本规模扩大到10000个条目以上. VQGAN的变体, 例如VQGAN-FC和VQGAN-EMA, 虽然在一定程度上有所改进, 但是在扩大码本规模和提高码本利用率方面仍然面临挑战. 近期的研究进展, 特别是收到LLaMA成功的启发, 增大码本规模可以显著提升模型性能.

<figure markdown='1' id='fig1'>
![](http://img.ricolxwz.cn/f4ac1344e5177624c9782f9d1d846f8b.webp#only-light){ loading=lazy width='800' }
![](http://img.ricolxwz.cn/f4ac1344e5177624c9782f9d1d846f8b_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图1: VQGAN的两个增强版本, 即VQGAN-FC(因子化编码)和VQGAN-EMA(指数移动平均), 随着码本规模的扩大, 其码本利用率和性能均出现下降. 相比之下, 作者提出的方法VQGAN-LC(大码本), 能够有效利用极大码本, 持续保持高达99%的利用率并获得了更高的性能. 作者突出了每个模型的最佳重建rFID. (b)三种模型在不同任务上的比较. 在图像生成方面, 作者评估了这三种VQGAN变体在GPT, LDM, DiT和SiT中的应用. </figcaption>
</figure>

## 相关工作

### VQGAN-FC

VQGAN面临着码本利用效率低下的显著挑战. 为解决此问题, 那些作者采用了最初由ViT-VQGAN提出的因子化编码(FC)机制. 作者将集成了FC机制的VQGAN称为VQGAN-FC. VQGAN与VQGAN-FC之间的关键区别有两点: 首先, 增加一个线性层, 将编码器特征$Z \in \mathbb{R}^{h \times w \times D}$投影到低维特征$Z' \in \mathbb{R}^{h \times w \times D'}$, 其中$D' \ll D$; 其次, 码本$\mathcal{B}$由$N$个$D'$维可训练嵌入组成, 并进行随机初始化. 量化损失表述为: $L_Q = \alpha ||\text{sg}(\hat{Z}) - Z'|| + \beta ||\text{sg}(Z') - \hat{Z}||.$

> 纳尼, 这不就增加了个线性层吗? 为啥编码器不直接输出一个高维特征呢?

### VQGAN-EMA

VQGAN的这种变体采用指数移动平均(EMA)策略来优化码本. 具体而言, 设$\hat{B} \subset \mathcal{B}$表示当前训练批次中用于所有令牌图的令牌嵌入集合. 集合$\hat{B}$在每次迭代中通过EMA机制使用相应的编码器特征$Z$进行更新. 因此, 码本不接收任何梯度. 量化损失定义为: $L_Q = \alpha ||\text{sg}(\hat{Z}) - Z||.$

> 就会看见, 其实EMA优化的只是那些活码字.

## 方法

<figure markdown='1' id='fig2'>
![](http://img.ricolxwz.cn/6c7fd98fd887a227d8898d46f5de2880.webp#only-light){ loading=lazy width='800' }
![](http://img.ricolxwz.cn/6c7fd98fd887a227d8898d46f5de2880_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图2: (a) VQGAN 的编码器-量化器-解码器结构, 其中码本与量化器相连.  (b) VQGAN 和 VQGAN-FC 中采用的码本优化策略.  (c) VQGAN-EMA 中使用的码本更新机制.  (d) 他们的 VQGAN-LC 中实现的码本初始化和量化过程. </figcaption>
</figure>

在这些 VQGAN 的增强版本中, 码本是随机初始化的. 在每次迭代期间, 只有与当前训练批次相关的码本条目的一小部分子集被优化. 结果是, 频繁优化的条目与编码器生成的特征图分布更加一致, 而较少优化的条目则仍然未被充分利用. 因此, 在训练和推理阶段, 码本的很大一部分仍然未被使用. [图3](#fig3)显示了训练周期内的码本利用率, 并可视化了训练完成后每个码本条目的使用频率.

<figure markdown='1' id='fig3'>
![](http://img.ricolxwz.cn/ee676e5ef54d7dad88a97155d45decac.webp#only-light){ loading=lazy width='800' }
![](http://img.ricolxwz.cn/ee676e5ef54d7dad88a97155d45decac_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图3: (左) 训练周期内的码本利用率. 如果一个码本条目在一个周期内至少被使用一次, 则认为该条目被利用.  (右) 所有周期内每个码本条目的平均使用频率, 其中每个像素代表一个条目. 所有模型均采用大小为 100K 的码本, 并在 ImageNet 上使用分辨率为 256 × 256 的图像. </figcaption>
</figure>

### 总览

作者提出了VQGAN-LC(大码本), 该方法支持将码本扩展至高达100,000的规模, 同时实现了高达99%的惊人利用率. 如[图2](#fig2)(d)所示, 他们的方法与VQGAN-FC和VQGAN-EMA的不同之处在于其量化器的设计. 他们保留了一个**静态**码本, 并训练一个投影器将整个码本映射到潜空间, 从而对齐编码器生成的特征图的分布. 这种方法使得他们能够有效地扩展码本大小而无需修改编码器和解码器, 实现了极高的利用率, 并在各种任务上取得了优越的性能. 值得注意的是, 增加码本大小几乎不会带来额外的计算成本.

> 其实就是用了一个投影层, 把CLIP等先验知识运用到了他们的模型中. 有点感觉像是蒸馏的感觉... 但是没有回答为什么可以有效地扩展码本大小无需修改编码器和解码器的问题.

### 码本初始化

为初始化静态码本, 作者首先利用预训练视觉编码器(如基于ViT(视觉Transformer)骨干网络的CLIP(ContrastiveLanguage-ImagePretraining))从目标数据集(如ImageNet数据集)的M张图像中提取图像块级特征. 该提取产生特征集合$F=\{F_m^{(i,j)}\in R^D\}_{i=1, j=1, m=1}^{\bar{h}, \bar{w}, M}$, 其中$F^{(i,j)}_m$表示第$m$张图像中位置$(i,j)$处的$D$维图像块级特征,$(\bar{h},\bar{w})$指示$F$的空间维度. 随后, 作者对$F$应用K-means聚类(一种常用的无监督划分算法), 生成$N$个簇中心(默认值$N=100,000$). 这些簇中心构成集合$C={c_n\in R^D}_{n=1}^N$, 其中$c_n$为第$n$个簇中心. 最后, 作者使用$C$来初始化静态码本$B$.

### 量化

VQGAN, VQGAN-FC和VQGAN-EMA直接优化码本, 与它们不同, 他们的方法通过训练一个投影器$P(\cdot)$ (实现为简单的线性层), 来将静态码本$B$与他们VQGAN-LC的编码器$E(\cdot)$所生成的特征分布进行对齐. 令$B' = P(B) = \{b'_n \in R^{D'}\}_{n=1}^N$表示投影后的码本. 对于给定的输入图像$X$, 量化器将特征图$Z = E(X) \in R^{h \times w \times D'}$转换为标记图$\hat{Z}$. 该量化过程可以表示为$\hat{Z} := \underset{b'_n \in B'}{\operatorname{argmin}} ||Z^{(i,j)} - b'_n||$.

### 损失函数

作者采用了与VQ-GAN中相同的损失函数. 然而, 关键的区别在于作者的码本$\mathcal{B}$保持冻结, 而新引入的投影仪$P(\cdot)$则进行优化.

[^1]: Zhu, L., Wei, F., Lu, Y., & Chen, D. (2024). Scaling the codebook size of VQGAN to 100,000 with a utilization rate of 99% (No. arXiv:2406.11837). arXiv. https://doi.org/10.48550/arXiv.2406.11837
