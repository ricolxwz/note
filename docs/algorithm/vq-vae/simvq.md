---
title: SimVQ
comments: true
---

# SimVQ[^1]

## 概要

向量量化(VQ)是一种广泛使用的方法, 用于将连续表示转换为离散编码, 这在无监督表示学习和潜在生成模型中已成为基础. 然而, VQ模型常常受到潜在空间中表示坍塌问题的困扰, 这会导致码本利用率低, 并限制了码本在大规模训练中的可扩展性. 现有的旨在缓解表示坍塌的方法通常以牺牲模型容量为代价来降低潜在空间的维度, 这并未完全解决核心问题. 在这项研究中, 他们对VQ模型中的表示坍塌进行了理论分析, 并确定其主要原因是码本的不相交优化, 即只有一小部分码向量通过梯度下降进行更新. 为了解决这个问题, 他们提出了一种名为SimVQ的新方法, 该方法通过基于可学习潜在基的线性变换层来重新参数化码向量. 这种变换优化了码本所张成的整个线性空间, 而不仅仅是更新原始VQ模型中通过最近邻搜索选择的码向量. 尽管普遍认为两个线性矩阵的乘法等同于应用单个线性层, 但他们的方法仅用一个线性层就在解决VQ模型中的坍塌问题上取得了惊人的效果. 他们通过在包括图像和音频数据以及不同模型架构在内的各种模态上进行广泛实验, 验证了SimVQ的有效性. 结果表明, SimVQ不仅有效解决了表示坍塌问题, 而且具有高度的适应性和易于实现的特点, 这表明其在各种机器学习环境中具有广泛的应用前景. 他们的代码可在[https://github.com/youngsheen/SimVQ](https://github.com/youngsheen/SimVQ).获取.

## 动机

基本上和VQGAN-LC那篇的动机是一样的. 想要提高码本的大小, 因为提高码本的大小能够显著提高性能(参见LLaMA3的词表). 但是码本的利用率比较低, 增大码本也不会带来额外的收益. 作者argue这是因为码本是disjoint optimization, 就是只优化了一部分的码字, 但是其他的码字是dead状态, 见下[图1](#fig1)左. 近期, 也有一些工作, 例如FSQ, LFQ和ViTVQGAN, 将潜空间的维度缩小到很小, 但是这样会导致模型的表示能力下降. VQGAN-LC使用CLIP的视觉编码器初始化, 但是限制了模型泛化到其他数据集的能力.

<figure markdown='1' id='fig1'>
![](https://img.ricolxwz.download/8e38bbdfbb3ed43d04a415ee7aaef5d5.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.download/8e38bbdfbb3ed43d04a415ee7aaef5d5_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图1: Vanilla VQ与SimVQ的比较. (a): (左)Vanilla VQ中的分离式优化. 仅更新最近邻的代码向量, 导致大量"dead codes"未被更新. (b): (右)SimVQ中的联合优化. 通过潜在基更新整个代码本, 确保所有代码向量保持激活状态.
</figcaption>
</figure>

[^1]: Zhu, Y., Li, B., Xin, Y., & Xu, L. (2024). Addressing representation collapse in vector quantized models with one linear layer (No. arXiv:2411.02038). arXiv. https://doi.org/10.48550/arXiv.2411.02038
