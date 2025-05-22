---
title: SQ-VAE
comments: false
---

# SQ-VAE[^1]

## 摘要

向量量化变分自编码器(VQ-VAE)的一大公认问题是, 学得的离散表示只使用了码本(codebook)全部容量的一小部分, 这种现象也称为码本坍缩(codebook collapse). 作者假设, VQ-VAE的训练方案——其中包含一些精心设计的启发式策略——正是导致该问题的根源. 为此, 本文提出了一种新的训练方案, 通过新颖的随机反量化(stochastic dequantization)和量化(quantization)机制, 将标准VAE扩展为随机量化变分自编码器(SQ-VAE). 在SQ-VAE的训练过程中, 作者观察到量化在初始阶段呈现随机性, 但随着训练进行逐步趋于确定性, 这一现象被称为自退火(self-annealing). 实验结果表明, SQ-VAE在无需常见启发式策略的情况下即能显著提升码本利用率; 此外, 作者还实证证明, 在视觉和语音相关任务中, SQ-VAE均优于VAE和VQ-VAE.

## 动机

* 码本崩溃 (Codebook Collapse): 在向量量化变分自编码器 (VQ-VAE) 中, 学习到的离散表示仅使用码本全部容量的一小部分. 这意味着大多数码本元素未被使用, 导致重构精度下降
* 依赖启发式方法: VQ-VAE 的训练不遵循标准的变分贝叶斯框架, 而是依赖于一些精心设计的启发式方法, 例如停止梯度算子和梯度的直接估计. 这些方法通常需要繁琐的超参数调整, 并且缺乏理论上的优雅性.
* 确定性量化问题: 作者怀疑确定性量化是码本崩溃的根源. 在初始化不佳的情况下, 一些码本元素可能永远不会被选中.
* 现有随机量化方案的局限性: 先前文献中的随机量化方案在其分类后验中没有涉及可训练的参数, 或者需要预定义的超参数调度进行退火, 如果控制不当会导致训练问题. 也就是说, 已有的随机量化方法要不不够灵活(量化过程的随机性无法学习), 要么难以调整(退火过程需要手动进行设计, 且容易出错).

## 贡献

* 提出SQ-VAE: 提出了一种名为随机量化变分自编码器(SQ-VAE)的新模型. 它是一种配备了随机量化和可训练后延分类分布的变分自编码器, 可以在普通的变分贝叶斯框架内得到解释, 并可以作为传统VQ-VAE的直接替代品
* 自退火机制: 在 SQ-VAE 中, 量化过程的随机性退火可以带来更大的码本利用率.  论文为这种"自退火"现象提供了理论见解和经验验证.
* 改进码本利用率, 减少对启发式方法的依赖: SQ-VAE 能够改进码本的利用率, 并且其训练不需要像传统 VQ-VAE 那样依赖于停止梯度, 码本重置或指数移动平均 (EMA) 更新等启发式技术, 也无需详尽的超参数调整.
* 设计了两种 SQ-VAE 实例: 设计了高斯 SQ-VAE (适用于一般情况) 和 von Mises-Fisher (vMF) SQ-VAE (专门针对分类数据分布).

## 相关工作

这里回顾一下VAE和VQ-VAE.

### VAE

考虑一个观测数据$\mathbf{x} \in \mathbb{R}^D$和一个目标数据分布$p_{\text{data}}(\mathbf{x})$,它对有限的样本进行建模.标准的VAE由一个随机编码器-解码器对组成:一个解码器$p_\theta(\mathbf{x}|\mathbf{z})$和一个近似后验$q_\phi(\mathbf{z}|\mathbf{x})$,其中$\theta$和$\phi$是可训练的参数.假定隐变量$\mathbf{z} \in \mathbb{R}^{d_z}$服从先验分布$p(\mathbf{z})$.数据的生成方式为首先从先验$p(\mathbf{z})$中采样$\mathbf{z}$,然后将$\mathbf{z}$输入到随机解码器$p_\theta(\mathbf{x}|\mathbf{z})$中得到$\mathbf{x}$.每个样本$\mathbf{x}$的负对数证据下界(ELBO)表示为$\mathcal{L}_{\text{VAE}} = \mathbb{E}_{q_\phi(\mathbf{z}|\mathbf{x})}[-\log p_\theta(\mathbf{x}|\mathbf{z})] + D_{KL}(q_\phi(\mathbf{z}|\mathbf{x}) || p(\mathbf{z}))$.为了解析地计算样本$\mathbf{x}$的似然的ELBO,近似后验通常建模为条件高斯分布$q_\phi(\mathbf{z}|\mathbf{x}) = \mathcal{N}(q_\phi(\mathbf{x}), \text{diag}(\sigma_\phi(\mathbf{x})))$,其中有两个映射$g_\phi: \mathbb{R}^D \rightarrow \mathbb{R}^{d_z}$和$\sigma_\phi: \mathbb{R}^D \rightarrow \mathbb{R}^{d_z}$(分别是编码器输出的均值和方差向量).

如果目标数据分布是连续的, 则随机解码器可以用一个映射$f_\theta: \mathbb{R}^{d_z} \rightarrow \mathbb{R}^D$建模为高斯分布: $p_\theta(\mathbf{x}|\mathbf{z}) = \mathcal{N}(f_\theta(\mathbf{z}), \sigma^2 \mathbf{I})$. 这会将ELBO中的第一项简化为均方误差(MSE). 相反, 如果数据分布是离散的并且有$C_{\text{all}}$个类别, 则$\mathbf{x}$的第$d$个元素$x_d$的随机解码器可以用一个映射$f_{\theta, d}^c: \mathbb{R}^{d_z} \rightarrow \mathbb{R} (c \in [C_{\text{all}}])$建模为分类分布: $p_\theta(x_d = c|\mathbf{z}) = \text{softmax}_c(\{f_{\theta, d}^{c'}(\mathbf{z})\}_{c'=1}^{C_{\text{all}}})$. 其中softmax操作在$c'$上进行. 在这种情况下, ELBO中的第一项变为交叉熵(CE)损失.

!!! note "第二段推导"

    === "连续数据"

        当解码器是高斯分布 $p_\theta(\mathbf{x}|\mathbf{z}) = \mathcal{N}(f_\theta(\mathbf{z}), \sigma^2 \mathbf{I})$ 时, 其对数似然为:
        $\log p_\theta(\mathbf{x}|\mathbf{z}) = \log \left( \frac{1}{(2\pi\sigma^2)^{D/2}} \exp\left(-\frac{1}{2\sigma^2} ||\mathbf{x} - f_\theta(\mathbf{z})||^2\right) \right)$
        $= -\frac{D}{2} \log(2\pi\sigma^2) - \frac{1}{2\sigma^2} ||\mathbf{x} - f_\theta(\mathbf{z})||^2$
        其中 $D$ 是数据 $\mathbf{x}$ 的维度, $f_\theta(\mathbf{z})$ 是解码器网络输出的均值.

        因此, 重建损失为: $-\mathbb{E}_{q_\phi(\mathbf{z}|\mathbf{x})}[\log p_\theta(\mathbf{x}|\mathbf{z})] = \mathbb{E}_{q_\phi(\mathbf{z}|\mathbf{x})}\left[\frac{D}{2} \log(2\pi\sigma^2) + \frac{1}{2\sigma^2} ||\mathbf{x} - f_\theta(\mathbf{z})||^2\right]$如果 $\sigma^2$ 是常数, 这可以写成: $= \frac{D}{2} \log(2\pi\sigma^2) + \frac{1}{2\sigma^2} \mathbb{E}_{q_\phi(\mathbf{z}|\mathbf{x})}[||\mathbf{x} - f_\theta(\mathbf{z})||^2]$
        最小化此损失等价于最小化期望均方误差 $\mathbb{E}_{q_\phi(\mathbf{z}|\mathbf{x})}[||\mathbf{x} - f_\theta(\mathbf{z})||^2]$ (或其等比例项). 在实际操作中, 这个期望通常通过从 $q_\phi(\mathbf{z}|\mathbf{x})$ 中采样 $\mathbf{z}$ 来近似(例如, 使用重参数化技巧时, 对每个 $\mathbf{x}$ 取一个 $\mathbf{z}$ 样本).

    === "离散数据"

        对于分类解码器 $p_\theta(x_d = c|\mathbf{z}) = \text{softmax}_c(\{f_{\theta, d}^{c'}(\mathbf{z})\}_{c'=1}^{C_{\text{all}}})$, 我们有:
        $-\log p_\theta(\mathbf{x}|\mathbf{z}) = - \sum_{d=1}^D \sum_{c=1}^{C_{\text{all}}} y_{d,c} \log P_{d,c}(\mathbf{z})$
        其中 $P_{d,c}(\mathbf{z}) = p_\theta(x_d = c|\mathbf{z})$.
        因此, 重建损失为:
        $-\mathbb{E}_{q_\phi(\mathbf{z}|\mathbf{x})}[\log p_\theta(\mathbf{x}|\mathbf{z})] = -\mathbb{E}_{q_\phi(\mathbf{z}|\mathbf{x})}\left[\sum_{d=1}^D \sum_{c=1}^{C_{\text{all}}} y_{d,c} \log P_{d,c}(\mathbf{z})\right]$
        $= \mathbb{E}_{q_\phi(\mathbf{z}|\mathbf{x})}\left[-\sum_{d=1}^D \sum_{c=1}^{C_{\text{all}}} y_{d,c} \log P_{d,c}(\mathbf{z})\right]$
        这就是期望交叉熵损失. 同样, 在实践中, 这个期望通过从 $q_\phi(\mathbf{z}|\mathbf{x})$ 中采样 $\mathbf{z}$ 来近似.

[^1]: Takida, Y., Shibuya, T., Liao, W., Lai, C.-H., Ohmura, J., Uesaka, T., Murata, N., Takahashi, S., Kumakura, T., & Mitsufuji, Y. (2022). SQ-VAE: Variational bayes on discrete representation with self-annealed stochastic quantization (No. arXiv:2205.07547). arXiv. https://doi.org/10.48550/arXiv.2205.07547
