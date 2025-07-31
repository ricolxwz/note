---
title: PQ-VAE (2019)
comments: true
---

# PQ-VAE (2019)[^1]

!!! info "还有一篇也叫PQ-VAE"

    还有一篇题目叫做"PQ-VAE: Learning Hierarchical Discrete Representations  with Progressive Quantization"也是PQ-VAE, 和RQ-VAE比较像. 这篇是Product Quantization, 那篇是Progressive Quantization.

## 摘要

VQ-VAE通过将向量量化和自编码器相结合, 提供了一种用于学习离散表示的模型. 本文研究了将VQ-VAE用于下游任务(例如图像检索)的表征学习. 首先, 在信息论框架下描述VQ-VAE. 作者指出, 学习到的表示上的正则化项由训练前嵌入码本的规模决定, 并影响模型的泛化能力. 因此, 我们引入一个超参数来平衡向量量化器的强度和重建误差. 通过调节该超参数, 嵌入式瓶颈量化器被用作正则化器, 迫使编码器的输出共享受限的编码空间, 从而使学得的潜在特征能够保持数据空间的相似性关系. 此外, 我们还给出了寻找最优超参数的搜索范围. 最后, 我们将乘积量化引入到VQ-VAE的瓶颈阶段, 提出了一个端到端的用于图像检索任务的无监督学习模型. 乘积量化器能够生成大规模的码本, 且可通过存储任意子码字对之间距离的查找表实现快速检索. 所学码本在检索任务中达到了最先进的性能.

!!! note "解释几个概念"

    * 图像检索: 根据图像内容(如物体, 场景, 纹理等)从大规模数据库中快速查找并返回相似图像的任务. 通常通过提取图像的特征表示(如颜色, 形状, 深度特征等), 计算特征之间的相似度来实现.
    * 表征学习: Representation learning. 这是机器学习中通过模型自动学习数据的有意义表示(即特征)的过程. 这些表示应能捕捉数据的关键特性, 并适用于下游任务(如分类, 检索). 例如, CNN通过多层非线性变换将图像映射为低维向量, 即一种表征学习.
    * 嵌入码本: 就是码本
    * 正则化项: 正则化项是损失函数中用于对模型表示空间施加约束, 防止过拟合的惩罚项.
    * 嵌入码本的规模: 嵌入码本的规模指码本中嵌入向量的数量(即码本大小). 例如, 若码本包含K个d维向量, 则规模为K. 码本规模直接影响模型的表达能力: 规模过小可能导致信息损失, 规模过大会增加过拟合风险. 原文指出, 码本规模决定了正则化强度, 进而影响泛化能力.
    * 超参数: 在损失函数中引入一个超参数, 用来控制"量化损失"和"重建误差"之间的权重比例
    * "迫使编码器输出共享受限的编码空间": 通过增大这个超参数, 就会加强正则化的作用, 编码器被迫更紧地"对齐"到离散码本的原型上, 使得相似的输入更可能映射到相同或相近的码字, 从而在低维离散空间里保留数据的相似性结构.
    * "嵌入式瓶颈量化器": 就是量化器. why so many fancy words? 这不就是量化器吗... 为啥要强调插在自编码器的"瓶颈位置", 这不是非常明显吗...

## 动机

* **传统VAE的后验坍塌缺陷**: 经典变分自编码器(VAE)在训练时, 解码器容易过度"强大"而忽略潜在空间表示, 导致潜在编码无法有效捕获数据特征. 这种现象严重制约了模型在图像检索等任务中对数据本质特征的提取能力.
* **无约束表示学习的相似性保持困境**: 现有方法缺乏对潜在空间的显式约束机制, 导致学习到的特征难以保持输入数据之间的相似性关系. 这对依赖特征相似性比较的下游任务(如图像检索)造成根本性限制.
* **大规模检索场景的量化效率瓶颈**: 传统向量量化方法需要存储大规模码本, 导致内存消耗随码本尺寸呈线性增长. 例如, 百万级码本需要GB级存储空间, 这在实际应用中面临硬件资源与计算效率的双重挑战.

## 相关工作

很多工作都是想让模型更好的处理和学习离散的数据表示(一方面, 可以减轻后续自回归建模的压力; 另一方面, 现代的LLM, Transformer架构只能接受离散的值作为输入). 大多数这类的工作的改进都发生在"瓶颈"部分, 就是数据被压缩或者编码的地方, 例如标量量化(finite quantization), 参考FSQ和向量量化VQ-VAE. 由于离散数据通常很难直接计算梯度(因为又一个argmax), 有工作引入了Gumbel-Softmax, 它可以把离散的问题变得可微, 类似于VAE中的reparametrization trick. 有研究使用EM算法来训练VQ-VAE, 来提高效果. 为了提高解码速度, 有工作提出了在VQ-VAE中使用乘积量化的概念, 或者叫做"decomposed VQ-VAE".

## 方法

由于它的写作手法过于奇葩, 直接看乘积量化的实现. PQ-VAE包含一个encoder, decoder, 和一个瓶颈乘积量化器. 编码器学到的是一个deterministic的映射, 输出的是一个潜向量$z_e(\mathbf{x})\in \mathbb{R}^D$. 这个潜向量会被喂到乘积量化器中. 这个乘积量化器包含$M$个子量化器, 每个自量化器负责的维度大小是$D/M$. 每个VQ_m都会将子潜空间分成$K$个簇. 这些子簇被由子码本表示$C^{(m)}=\{e_1^{(m)}, ..., e_K^{(m)}\}, m=1, ..., M$. 每一个子潜向量都会通过NN被量化成$K$个码字中的一个:

$$
z_q^{(m)}(\mathbf{x}) = e_k^{(m)},\quad k = \arg\min_i \bigl\lVert z_e^{(m)}(\mathbf{x}) - e_i^{(m)}\bigr\rVert_2
$$

这$M$个子量化器的输出$z_q^{(m)}$会被拼接为一个完整的码字$z_q(\mathbf{x})=[z_q^{(1)}(\mathbf{x}), z_q^{(2)}(\mathbf{x}), ..., z_q^{(M)}(\mathbf{x})]$, 然后传递给解码器重构出给定图像$\mathbf{x}$. 如下图所示, 这是一个完整的流程.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.asia/3bc91d5463a78e0f7087a678cfe68a14.webp#only-light){ loading=lazy width='400' }
![](https://img.ricolxwz.asia/3bc91d5463a78e0f7087a678cfe68a14_inverted.webp#only-dark){ loading=lazy width='400' }
<figcaption>图1: PQ-VAE示意图</figcaption>
</figure>

他们调整了VQ-VAE的损失函数:

$$
\begin{aligned}
L = & -\log g\bigl(x\mid z_q(x)\bigr) \\
& +\lambda\Biggl(
\sum_{m=1}^M\beta\bigl\lVert z_e^{(m)}(x)-\operatorname{sg}\bigl(e^{(m)}\bigr)\bigr\rVert_2^2
+\sum_{m=1}^M\bigl\lVert\operatorname{sg}\bigl(z_e^{(m)}(x)\bigr)-e^{(m)}\bigr\rVert_2^2
\Biggr)
\end{aligned}
$$

其中,$\lambda$是他们在前面介绍的所谓的正则化调控因子, 其实就是想在rich representation和less bit之间做一个trade off.

这$M$个子量化器是同时且独立进行训练的. 在一次训练迭代中, 首先把所有经过编码器得到的潜向量根据NN分配到各自对应的簇中; 然后, 对于每个簇, 计算被分配到该簇的所有潜向量的平均值, 最后把这个平均向量作为该簇的码本向量. 对于第$m$个子量化器的第$i$个码字, 更新规则是:

$$
\begin{aligned}
& n_i := \sum_{j=1}^B \mathbb{1}(z_j = i)\\
& e_i := \frac{1}{n_i}\sum_{j=1}^B \mathbb{1}(z_j = i)\,z(x_j)
\end{aligned}
$$

---

然后, 我们在来看看, 查询是咋样的.

对于每张图像, 编码器首先会提取出$N$个连续的隐向量, 然后将每个隐向量分成$M$个子向量, 分别通过$M$个子码本(product codebook)进行量化. 记第$m$个子码本对第$n$个隐向量量化后得到的索引为$z_n^{(m)} \;=\;\arg\min_{i\in[K]}\bigl\|\mathbf e_e^{(m)}(x)-\mathbf e_i^{(m)}\bigr\|_2$, 则第$m$个子码本产生的索引向量为$\mathbf z^{(m)}=[\,z_1^{(m)},z_2^{(m)},\dots,z_N^{(m)}]$, 整个离散编码拼接后就是$\mathbf z=[\mathbf z^{(1)},\mathbf z^{(2)},\dots,\mathbf z^{(M)}] =[\,z_1^{(1)},\dots,z_N^{(1)},\dots,z_1^{(M)},\dots,z_N^{(M)}\,]$. 共包含$M\times N$个码字索引. 这样就把一张图像压缩成长度为$R=N\,M\log_2K$的离散码.

查询是在量化空间中进行的. 数据库图像和查询图像都被送入训练好的编码器和学习到的乘积码本. 我们使用乘积量化器对查询和数据库图像进行离散编码, 用于查询和存储. 在数据库中, 我们存储$M$个查找表(LT), 每个表包含$K\times K$个条目. 每个LT存储其子码本中任意两个子码字之间的距离. 图像编码用作表的索引. 查询时, 查询$\mathbf{q}$和数据库$\mathbf{x}$之间的距离通过如下公式计算:

$$d(\mathbf{q}, \mathbf{x}) = LT_1 \left(z_q^{(1)}, z_x^{(1)}\right) + \cdots + LT_M \left(z_q^{(M)}, z_x^{(M)}\right)$$

其中, $z_q$是查询图像的编码, $z$是数据库图像的编码. 可以达成快速检索, 因为不需要任何额外的距离计算步骤. 查询过程如下图所示.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.asia/f4425a6a7bd16bfeb87bf60df46d304a.webp#only-light){ loading=lazy width='400' }
![](https://img.ricolxwz.asia/f4425a6a7bd16bfeb87bf60df46d304a_inverted.webp#only-dark){ loading=lazy width='400' }
<figcaption>图2: 查询过程</figcaption>
</figure>


[^1]: Wu, H., & Flierl, M. (2019). Learning product codebooks using vector quantized autoencoders for image retrieval (No. arXiv:1807.04629). arXiv. https://doi.org/10.48550/arXiv.1807.04629
