---
title: CVQ-VAE
comments: true
---

# CVQ-VAE (2023)[^1]

## 概要

向量量化(VQ)正在机器学习领域卷土重来,其在表示学习中的应用日益广泛.然而,优化现有VQ-VAE中的码向量并非易事.一个问题是码本坍塌,即只有一小部分码向量能接收到对其优化有用的梯度,而大多数码向量则会"死亡"且从未被更新或使用.这限制了VQ在需要高容量表示的复杂计算机视觉任务中学习大型码本的有效性.在本文中,作者提出了一种简单的在线码本学习替代方法,即聚类VQ-VAE(CVQ-VAE).作者的方法选择编码后的特征作为锚点来更新"死亡"的码向量,同时通过原始损失函数优化那些"存活"的码向量.该策略使得未使用的码向量在分布上更接近编码后的特征,从而增加了它们被选中和优化的可能性.作者广泛验证了其量化器在各种数据集,任务(例如重建和生成)以及架构(例如VQ-VAE,VQGAN,LDM)上的泛化能力.CVQ-VAE只需几行代码即可轻松集成到现有模型中.

## 动机

码本坍缩问题: 在现有的VQ-VAE中, 许多模型存在码本坍缩问题, 这意味着只有一小部分codevector在训练中接受到有效的梯度并得到更新, 而大部分码字则从未被使用或者更新. 这会限制VQ在学习大型码本时候的有效性, 而大型码本对于复杂计算机视觉任务至关重要. VQ-GAN, ViT-VQGAN, RQ-VAE, MoVQ虽然通过提出额外的损失, 结构等手段缓解了这个问题, 但是他们还是没有解决"死码字"的问题. 虽然HVQ-VAE和Jukebox的工作和他们很想, 但是他们的做法是为每个未优化的码字只分配一个采样的锚点, 或者说依赖于一个临时的, 单一的值进行初始化.

<figure markdown='1' id='fig1'>
![](https://img.ricolxwz.asia/61c9b6c1f2847a0c8a39f0047ca882c1.webp#only-light){ loading=lazy width='400' }
![](https://img.ricolxwz.asia/61c9b6c1f2847a0c8a39f0047ca882c1_inverted.webp#only-dark){ loading=lazy width='400' }
<figcaption>图1: 码本使用率与重建误差. 实验设置与VQ-VAE相同, 仅量化器不同. 所有模型均在CIFAR10数据集上进行训练和评估. VQ-VAE存在大量未被使用的"死亡"向量(图中绿点所示). CVQ-VAE通过使用在线采样的特征锚点来更新这些未优化的向量, 从而实现了100%的码本使用率. 与固定初始化方法相比, CVQ-VAE获得了显著更高的码本困惑度以及更好的重建效果. </figcaption>
</figure>

## 方法

<figure markdown='1' id='fig2'>
![](https://img.ricolxwz.asia/c5054cef64c70498f8da00aac2d08587.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.asia/c5054cef64c70498f8da00aac2d08587_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图2: CQ-VAE示意图</figcaption>
</figure>

CVQ-VAE的灵感来源于经典的动态聚类初始化算法, k-means其核心"动态"在于从0到k这个初始选择过程. 而CVQ-VAE的"动态"在于对于已经存在的簇需要部分更新替换这个持续维护的过程, 它和k-means等传统聚类的方法最大区别就是数据集是动态的, 码本中的聚类不是一尘不变的, 需要动态更新的. 如果只以来某一批mini-batch对码本进行聚类, 那么效果很差, 因为单个mini-batch的数据无法代表整个数据集的真实分布.

在每个mini-batch里面, 他们都会keep track一个索引为k的码字的平均使用率; \(N_k^{(t)} = N_k^{(t-1)}\cdot\gamma + \frac{n_k^{(t)}}{B\,h\,w}\cdot(1-\gamma)\), $B$是这个mini batch中样本的数量, $h\times w$是每个样本的特征的数量. 然后每个mini batch, 他们都会从编码器的输出$\hat{z}$中选择一个大小为$K$的子集, 作为"锚点". 他们并不会用这些锚点直接更新那些使用频率较少的"死码字", 而是用了一种类似EMA的方法, 但不是EMA. 他们对于每个索引为$k$的码字会计算一个衰减值$\alpha_k^{(t)}$: \(\alpha_k^{(t)} = \exp\bigl(-N_k^{(t)}\,K\,\tfrac{10}{1-\gamma} \;-\;\epsilon\bigr)\). 然后, 他们就会更新索引为$k$的码字\(e_k^{(t)} = e_k^{(t-1)}\cdot\bigl(1 - \alpha_k^{(t)}\bigr) + \hat{z}_k^{(t)}\cdot\alpha_k^{(t)}\). 这样, 如果$\alpha_k^{(t)}$很大, 表示$e_k$是一个死码字, 那么新的$e_k^{(t)}$将主要由$\hat{z}^{(t)}_k$决定, 从而被拉向编码器特征的分布区, 如果$\alpha_k^{(t)}$很小, 表示$e_k$是一个活向量, 那么$e_k^{(t)}$将保持其原有的值. 这个方法和EMA的不同点是, 首先, 它的$\alpha$是一个根据索引为$k$的码字在历史上的表现计算的, 而不是像EMA中的$\gamma$是一个固定的值; 其次, **EMA是用于更新活码字的, 不会更新死码字.**

那么, 怎么去选择这个大小为$K$的子集呢? 即怎么选择这些锚点呢? 作者尝试了随机选, 均匀选, 等等方法, 但是发现其实最后在线实验结果和这些方法的关系不大, 但是离线实验结果受这些影响很大. 此外, 他们还推出了一个对比损失, 用于鼓励码本的稀疏分布.

[^1]: Zheng, C., & Vedaldi, A. (2023). Online clustered codebook (No. arXiv:2307.15139). arXiv. https://doi.org/10.48550/arXiv.2307.15139
