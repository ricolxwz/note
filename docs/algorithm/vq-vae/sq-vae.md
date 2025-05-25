---
title: SQ-VAE
comments: true
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

!!! note inline "第二段推导"

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

考虑一个观测数据$\mathbf{x} \in \mathbb{R}^D$和一个目标数据分布$p_{\text{data}}(\mathbf{x})$,它对有限的样本进行建模.标准的VAE由一个随机编码器-解码器对组成:一个解码器$p_\theta(\mathbf{x}|\mathbf{z})$和一个近似后验$q_\phi(\mathbf{z}|\mathbf{x})$,其中$\theta$和$\phi$是可训练的参数.假定隐变量$\mathbf{z} \in \mathbb{R}^{d_z}$服从先验分布$p(\mathbf{z})$.数据的生成方式为首先从先验$p(\mathbf{z})$中采样$\mathbf{z}$,然后将$\mathbf{z}$输入到随机解码器$p_\theta(\mathbf{x}|\mathbf{z})$中得到$\mathbf{x}$.每个样本$\mathbf{x}$的负对数证据下界(ELBO)表示为$\mathcal{L}_{\text{VAE}} = \mathbb{E}_{q_\phi(\mathbf{z}|\mathbf{x})}[-\log p_\theta(\mathbf{x}|\mathbf{z})] + D_{KL}(q_\phi(\mathbf{z}|\mathbf{x}) || p(\mathbf{z}))$.为了解析地计算样本$\mathbf{x}$的似然的ELBO,近似后验通常建模为条件高斯分布$q_\phi(\mathbf{z}|\mathbf{x}) = \mathcal{N}(q_\phi(\mathbf{x}), \text{diag}(\sigma_\phi(\mathbf{x})))$,其中有两个映射$g_\phi: \mathbb{R}^D \rightarrow \mathbb{R}^{d_z}$和$\sigma_\phi: \mathbb{R}^D \rightarrow \mathbb{R}^{d_z}$(分别是编码器输出的均值和方差向量).

如果目标数据分布是连续的, 则随机解码器可以用一个映射$f_\theta: \mathbb{R}^{d_z} \rightarrow \mathbb{R}^D$建模为高斯分布: $p_\theta(\mathbf{x}|\mathbf{z}) = \mathcal{N}(f_\theta(\mathbf{z}), \sigma^2 \mathbf{I})$. 这会将ELBO中的第一项简化为均方误差(MSE). 相反, 如果数据分布是离散的并且有$C_{\text{all}}$个类别, 则$\mathbf{x}$的第$d$个元素$x_d$的随机解码器可以用一个映射$f_{\theta, d}^c: \mathbb{R}^{d_z} \rightarrow \mathbb{R} (c \in [C_{\text{all}}])$建模为分类分布: $p_\theta(x_d = c|\mathbf{z}) = \text{softmax}_c(\{f_{\theta, d}^{c'}(\mathbf{z})\}_{c'=1}^{C_{\text{all}}})$. 其中softmax操作在$c'$上进行. 在这种情况下, ELBO中的第一项变为交叉熵(CE)损失.

### VQ-VAE

与变分自编码器(VAE)不同, 向量量化变分自编码器(VQ-VAE)包含一个确定的编码器-解码器路径和一个可训练的码本$\mathbf{B}$. 该码本是一个集合, 包含$K$个$d_b$维向量$\{\mathbf{b}_k\}_{k=1}^K$. 一个$d_z$维离散潜在变量与码本相关联(这里讲的应该是对于一张图片, 我们需要用$d_z$个离散的潜向量来表示它), 可以被解释为$\mathbf{B}^{d_z} \subset \mathbb{R}^{d_b \times d_z}$的$d_z$个笛卡尔积. 作者将潜在变量表示为$\mathbf{Z}_q \in \mathbf{B}^{d_z}$, 它的第$i$个列向量为$\mathbf{z}_{q,i} \in \mathbf{B}$. 从输入$x$到$\mathbf{Z}_q$的确定性编码过程包括一个映射$\mathbf{\hat{Z}}_q = g_\phi(x)$, 其中$g_\phi: \mathbb{R}^D \rightarrow \mathbb{R}^{d_b \times d_z}$, 以及将$\mathbf{\hat{Z}}_q$量化到$\mathbf{B}^{d_z}$上的量化过程. 量化过程被建模为一个确定的分类后验分布, 其中$\hat{\mathbf{z}}_{q,i}$总是映射到其最近邻$\mathbf{z}_{q,i}$, 即$\mathbf{z}_{q,i} = \arg \min_{\mathbf{b}_k} \|\mathbf{\hat{z}}_{q,i} - \mathbf{b}_k\|_2$. VQ-VAE的目标函数为: $\mathcal{L}_{VQ} = - \log p_\theta(x|\mathbf{Z}_q) + \|sg[g_\phi(x)] - \mathbf{Z}_q\|_2^2 + \beta \|g_\phi(x) - sg[\mathbf{Z}_q]\|_2^2$. 其中$sg[\cdot]$表示停止梯度算子, 且$\beta$设置为$0.1$. 为了提高性能和收敛速度, 指数移动平均(EMA)更新通常只应用于与码本更新相对应的第二项.

---

请注意, VAE和VQ-VAE的目标函数都可以解释为重建误差和潜在正则化惩罚之和.

## 方法

本节中,作者提出了SQ-VAE及其两个子种类:高斯SQ-VAE和vMF SQ-VAE.该框架桥接了VAE和VQ-VAE的训练方案,减轻了VQ-VAE对启发式技术的依赖,并降低了超参数调优的难度.此外,它融入了可训练的类别后验分布的自退火过程,该分布在训练过程中逐渐逼近VQ-VAE的确定性量化.此外,作者还提供了关于自退火机制益处的理论和实证支持.

### 概括

SQ-VAE的框架如[图1](#fig1)所示. 与VQ-VAE类似, SQ-VAE也具有一个可训练的码本$\mathbf{B} := \{\mathbf{b}_k\}_{k=1}^K$. 作为一个生成模型, SQ-VAE的目标是学习一个生成过程$\mathbf{x} \sim p_\theta(\mathbf{x}|\mathbf{Z}_q)$, 其中$\mathbf{Z}_q \sim P(\mathbf{Z}_q)$, 以生成属于数据分布$p_{data}(\mathbf{x})$的样本, 其中$P(\mathbf{Z}_q)$表示离散潜在空间$\mathbf{B}^d$的先验分布. 在主要的训练阶段, 与VQ-VAE中一样, 先验$P(\mathbf{Z}_q)$被假定为独立同均匀分布, 即$P(\mathbf{Z}_{q,i} = \mathbf{b}_k) = 1/K$, 对于$k \in [K]$. 在主要的训练阶段之后, 将进行第二次训练以学习$P(\mathbf{Z}_q)$. 由于精确评估$p_\theta(\mathbf{Z}_q|\mathbf{x})$是难以处理的, 因此使用近似后验$q_\phi(\mathbf{Z}_q|\mathbf{x})$来代替.

!!! tip "为什么要进行第二阶段的学习?"

    因为在初始训练的时候, 先验$P(\mathbf{Z}_q)$通常被假设为一个简单的均匀分布, 这便于模型训练. 但是在数据编码到离散的$\mathbf{Z}_q$之后, 其真实均匀分布往往不是均匀的. 因此, 在主要训练阶段之后, 需要第二阶段来专门学习一个更接近真实数据特征的$P(\mathbf{Z}_q)$, 这样做可以: 提升生成样本的质量, 并且能够更好的捕捉数据结构, 通常使用PixelCNN, Transformer等自回归模型学习这个先验.

<figure markdown='1' id='fig1'>
![](https://img.ricolxwz.io/2fe77603b62d7297ef74d2a10d58c8ad.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/2fe77603b62d7297ef74d2a10d58c8ad_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图1: SQ-VAE的编码和生成过程. 从$\mathbf{x}$到$\mathbf{Z}_q$的编码路径包括(E1)确定性编码, (E2)随机解量化和(E3)量化过程. 对于生成, 在(G1)中, 我们首先从先验$p(\mathbf{Z}_q)$中采样$\mathbf{Z}_q \in \mathbf{B}^{d_z}$. 然后, 在(G2)中, 我们将$\mathbf{Z}_q$输入到随机解码器中以生成数据样本. </figcaption>
</figure>

> 下面这一段比较重要.

在此设定下,尽管作者可以依照VQ-VAE中的方法建立生成过程,但由于$Z_q$的离散特性,构建从$x$到$Z_q$的编码过程并非易事. 因此,作者引入了两个辅助变量以简化说明:$Z$和$\hat{Z}_q$. $Z$是由$Z_q$通过反量化过程$p_φ(Z|Z_q)$转换得到的连续变量,其中$φ$表示其参数. 此外,作者可以根据贝叶斯定理$\hat{P}_φ(Z_q|Z) \propto p_φ(Z|Z_q)P(Z_q)$推导出$p_φ(Z|Z_q)$的逆过程,即随机量化过程$\hat{P}_φ(Z_q|Z)$. 另一方面,$\hat{Z}_q$定义为$\hat{Z}_q = g_φ(x)$,它是确定性编码器$g_φ : \mathbb{R}^D \rightarrow \mathbb{R}^{d \times d_z}$在给定样本$x$时的输出. 理想情况下,$\hat{Z}_q$应接近$Z_q$. 类似地,$\hat{Z}_q$的反量化过程可以写为$\hat{Z}|\hat{Z}_q \sim p_φ(Z|\hat{Z}_q)$. ^^如[图1](#fig1)所示,叠加过程$p_φ(Z|\hat{Z}_q)$和$\hat{P}_φ(Z_q|Z)$连接了$\hat{Z}_q$和$Z_q$,从而建立了从$x$到$Z_q$的随机编码过程$Q_ω(Z_q|x) := E_{q_ω(Z|x)}[\hat{P}_φ(Z_q|Z)]$,其中$ω := \{φ, ϕ\}$且$q_ω(Z|x) := p_φ(Z|g_ϕ(x))$.^^ (下方带有颜色的箭头路径)

!!! note "贝叶斯公式推导"

    根据贝叶斯定理 $P(A|B) = \frac{P(B|A)P(A)}{P(B)}$, 我们可以推导 $\hat{P}_φ(Z_q|Z)$. 在此情景下, 令 $A = Z_q$ 且 $B = Z$. 将这些代入贝叶斯定理, 我们得到 $\hat{P}_φ(Z_q|Z) = \frac{p_φ(Z|Z_q)P(Z_q)}{P(Z)}$. 由于 $P(Z)$ (即 $Z$ 的边际概率) 在给定 $Z$ 的条件下不依赖于我们所考虑的特定 $Z_q$ 值, 它在此处充当归一化常数, 确保 $\hat{P}_φ(Z_q|Z)$ 对所有 $Z_q$ 的总和为1. 因此, 我们可以将等式简化为正比关系: $\hat{P}_φ(Z_q|Z) \propto p_φ(Z|Z_q)P(Z_q)$.

然后, 我们就能推导SQ-VAE的ELBO:

$$
\begin{aligned}
\log p_{\theta}(\mathbf{x}) \ge -\mathcal{L}_{\text{SQ}}(\mathbf{x}; \theta, \omega, \mathbf{B}) & := \mathbb{E}_{q_{\omega}(\mathbf{Z}|\mathbf{x})\hat{P}_{\varphi}(\mathbf{Z}_q|\mathbf{Z})} \left[ \log \frac{p_{\theta}(\mathbf{x}|\mathbf{Z}_q)p_{\varphi}(\mathbf{Z}|\mathbf{Z}_q)P(\mathbf{Z}_q)}{q_{\omega}(\mathbf{Z}|\mathbf{x})\hat{P}_{\varphi}(\mathbf{Z}_q|\mathbf{Z})} \right] \\
& = \mathbb{E}_{q_{\omega}(\mathbf{Z}|\mathbf{x})\hat{P}_{\varphi}(\mathbf{Z}_q|\mathbf{Z})} \left[ \log \frac{p_{\theta}(\mathbf{x}|\mathbf{Z}_q)p_{\varphi}(\mathbf{Z}|\mathbf{Z}_q)}{q_{\omega}(\mathbf{Z}|\mathbf{x})} \right] \\
& \quad + \mathbb{E}_{q_{\omega}(\mathbf{Z}|\mathbf{x})} H(\hat{P}_{\varphi}(\mathbf{Z}_q|\mathbf{Z})) + \text{const.} \tag{5}
\end{aligned}
$$

!!! tip "推导这个ELBO"

    首先, 我们来回顾一下最原始的ELBO定义, 对于一个包含隐变量(设为$\textbf{z}$)的生成模型$p(\textbf{x}, \textbf{z})$和一个近似后验分布$q(\textbf{z}|\textbf{x})$, ELBO定义为: $L=E_{q(\textbf{z}|\textbf{x})}[\log \frac{p(\textbf{x}, \textbf{z})}{q(\textbf{z}|\textbf{x})}]$, 我们来最大化这个下界来近似最大化$\log p(x)$. 在SQ-VAE中, 近似后验分布为$q_w(\textbf{Z}|\textbf{x})\hat{P}_{\varphi}(\textbf{Z}_q|\textbf{Z})$, 首先将$\textbf{x}$映射到$\textbf{Z}$的分布, 然后$\textbf{Z}$通过一个概率量化得到$\textbf{Z}_q$的分布. SQ-VAE的ELBO的形式是这样子的: $L_{ELBO} = \mathbb{E}_{q_w(\textbf{Z}|\textbf{x})\hat{P}_{\varphi}(\textbf{Z}_q|\textbf{Z})} \left[ \log \frac{p_{\theta}(\mathbf{x, Z, Z_q})}{q_w(\textbf{Z}|\textbf{x})\hat{P}_{\varphi}(\textbf{Z}_q|\textbf{Z})} \right]$. 你会发现, 和上面的这个式子就差在分子部分, 这个联合分布可以写为$p(\textbf{x},\textbf{Z},\textbf{Z}_q)=p(\textbf{x}\mid \textbf{Z},\textbf{Z}_q)\,p(\textbf{Z}\mid \textbf{Z}_q)\,P(\textbf{Z}_q)$, 由于给定量化码本$\textbf{Z}_q$之后, 重构只依赖$\textbf{Z}_q$, 即$p(\textbf{x}\mid \textbf{Z},\textbf{Z}_q)=p(\textbf{x}\mid \textbf{Z}_q)$, 所以分子为$p_{\theta}(\mathbf{x}|\mathbf{Z}_q)p_{\varphi}(\mathbf{Z}|\mathbf{Z}_q)P(\mathbf{Z}_q)$. 后面的推导见上面的公式.

其中$H(P)$表示$P$的熵. 在上式中,由于假设$P(Z_q)$服从均匀分布,因此其值为一常数项,故被省略(变成了上面的const). 为简洁起见,作者此后省略$\mathcal{L}_{\text{SQ}}$的参数. 最终,主要训练通过最小化$\mathbb{E}_{p_{\text{data}}(\mathbf{x})}\mathcal{L}_{\text{SQ}}(\mathbf{x})$来进行. 在此过程中,编码器, 解码器和码本都同时进行优化. 这样,码本优化不再需要诸如停止梯度, 指数移动平均(EMA)以及码本重置等启发式技术. 上式中第一项的期望涉及类别分布$\hat{P}_{\varphi}(Z_q|Z)$,该分布可以通过Gumbel-softmax松弛近似,以便在传统VAE的反向传播中使用重参数化技巧.

!!! note "为什么SQ-VAE可以使用ELBO优化"

    在标准的VAE中, 计算ELBO第一项$-\mathbb{E}_{q_{\phi}(\mathbf{z}|\textbf{x})}\log p_{\theta}(\textbf{x}|\textbf{z})$需要使用抽样$\textbf{z}$近似. 我们假设的是$q_{\phi}(\textbf{z}|\textbf{x})$服从高斯分布, 为了保证梯度能够传递到编码器上, 我们设计了重参数化技巧, 这样, 我们是能得到一个$\mathbb{E}_{q_{\phi}(\textbf{z}|\textbf{x})}$的解析表示的. 但是VQ-VAE是一种确定性的量化过程, 这会导致我们无法给出$\mathbb{E}_{q_{\phi}(\textbf{z}|\textbf{x})}$的解析表示, 也就无法计算第一项产生的梯度, 所以它使用了一些启发式的方法, 例如直通估计器和辅助损失项.

    这样就产生了一个问题, 我为什么不直接用Gumbel-Softmax这种随机量化的技巧对$\mathbf{\hat{Z}}_q$进行松弛呢? 我是否也能使用ELBO进行优化呢? 即把流程简化为$\mathbf{\hat{Z}}_q=g_{\phi}(\mathbf{x})\rightarrow \mathbf{Z}_q \sim \mathbf{Gumbel-Softmax}(\mathbf{\hat{Z}_q})$. 答案是不可以的. Generally, 使用SQ-VAE可以使得ELBO的每一项都写成能计算的形式, 但是用更直接的方法没法把每一项都写为能计算的形式, 如果省略了中间的$\mathbf{Z}$, 那么, 最终得到的$q(\mathbf{Z}_q|\mathbf{x})$将会是一个形式特别复杂的分布, "Concrete分布", 这个分布是很难写出闭式解的, 或者说ELBO的第二项KL散度项无解析式, 只能使用Monte-Carlo估计, 方差大, 梯度不稳定, 难以优化(注意, 重构项即第一项都是用Monte-Carlo估计的, 区别在第二项上). 但是SQ-VAE里面, 每一项都能写出闭式解, 所以可以用ELBO优化. 还有一点就是, 如果我们不使用这个中间变量$\mathbf{Z}$, 是无法对量化过程的随机性进行控制的, 就没有自退火机制一说.


### 高斯SQ-VAE

作者设计高斯SQ-VAE的假设是去量化过程遵循高斯分布. 基于此假设, 去量化过程被建模为$p_{\varphi}(\mathbf{z}_i | \mathbf{Z}_q) = \mathcal{N}(\mathbf{z}_{q,i}, \mathbf{\Sigma}_{\varphi})$, 其中$\mathbf{\Sigma}_{\varphi}$是可训练的. 根据贝叶斯定理, 他们可以通过上式的逆过程, 即随机量化过程来恢复$\mathbf{Z}_q$, 表示为

$$\hat{P}_{\varphi}(\mathbf{z}_{q,i} = \mathbf{b}_k | \mathbf{Z}) = \text{softmax}_k \left( \left\{ -\frac{(\mathbf{b}_j - \mathbf{z}_i)^\top \mathbf{\Sigma}_{\varphi}^{-1} (\mathbf{b}_j - \mathbf{z}_i)}{2} \right\}_{j=1}^K \right) \tag{7}$$

其中, 上式中$\mathbf{b}_k$的未归一化对数概率对应于$\mathbf{z}_i$与方差$\mathbf{\Sigma}_{\varphi}$之间的马氏距离. 他们进一步考虑了$\mathbf{\Sigma}_{\varphi}$的几种参数化方法, 并总结了它们以及相应的未归一化负对数概率. 他们检验了这些方法的有效性. 高斯SQ-VAE的解码和编码设置描述如下.

#### 解码和编码

解码过程采用了常见的高斯设置, 即 $p_{\theta}(\mathbf{x}|\mathbf{Z}_q) = \mathcal{N}(f_{\theta}(\mathbf{Z}_q), \sigma^2\mathbf{I})$, 其中 $\sigma^2 \in \mathbb{R}_+$ 且 $\theta$ 是可训练参数. 编码遵循[图1](#fig1)所示的过程, 且应用于 $\hat{\mathbf{Z}}_q$ 的去量化过程为 $p_{\varphi}(\mathbf{z}_i|\hat{\mathbf{Z}}_q) = \mathcal{N}(\hat{\mathbf{z}}_{q,i}, \mathbf{\Sigma}_{\varphi})$.

#### 目标函数

将上述编码和解码过程代入公式(5)可得到:

$$\mathcal{L}_{\mathcal{N}\text{-}SQ} = \mathbb{E}_{q_{\omega}(\mathbf{z}|\mathbf{x})\hat{P}_{\varphi}(\mathbf{z}_q|\mathbf{z})}\left[\frac{1}{2\sigma^2}\|\mathbf{x} - f_{\theta}(\mathbf{Z})\|^2_2 + \mathcal{R}_{\varphi}^{\mathcal{N}}(\mathbf{Z}, \mathbf{Z}_q)\right] - \mathbb{E}_{q_{\omega}(\mathbf{z}|\mathbf{x})}H(\hat{P}_{\varphi}(\mathbf{z}_q|\mathbf{Z})) + \frac{D}{2}\log \sigma^2 + \text{const.} \tag{8}
$$

其中$\mathcal{R}_{\varphi}^{\mathcal{N}}(\mathbf{Z}, \mathbf{Z}_q)$表示[表1](#tab1)中的正则化目标, 具体取决于$\Sigma_{\varphi}$的参数化形式.

<figure markdown='1' id='tab1'>
![](https://img.ricolxwz.io/f639f22a061bd19f43631bb641b6752e.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/f639f22a061bd19f43631bb641b6752e_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>表1: 高斯SQ-VAE中方差$\Sigma_{\varphi}$的不同参数化方法. </figcaption>
</figure>

### 自退火量化

在提出下一个SQ-VAE实例之前, 作者希望证明可训练参数在(反)量化过程中的有效性. 在本小节中, 为简单起见, 作者采用参数化$\Sigma_{\varphi} = \sigma_{\varphi}^2 \mathbf{I}$ ([表1](#tab1)中的类型I).

根据公式(7), $\Sigma_{\varphi}$控制了训练过程中量化的随机程度. 作者首先考虑两种极端情况, $\sigma^2 \to \infty$和$\sigma^2 \to 0$, 并给出以下命题, 其证明见附录. 注意, 这里的$\sigma^2$是解码器方差, 它控制的是重建数据和解码器输出的随机性程度, 而$\sigma_{\varphi}^2$是随机反量化过程的方差, 它控制的是$\mathbf{Z}$和$\mathbf{Z}_q$之间的随机性程度.

**命题1.** 假设$p_{\text{data}}(\mathbf{x})$具有有限支撑集, 而$g_{\phi}$和$\{b_k\}_{k=1}^K$是有界的. 设$\omega^* = \{\phi^*, \varphi^*\}$是在固定$\theta$, $\sigma^2$和$\{b_k\}_{k=1}^K$的条件下, $\mathbb{E}_{p_{\text{data}}(\mathbf{x})} D_{\text{KL}}(Q_{\omega}(\mathbf{Z}_q|\mathbf{x}) \parallel P_{\theta}(\mathbf{Z}_q|\mathbf{x}))$的最小化器. 如果$\sigma^2 \to 0$, 那么$\sigma_{\varphi^*}^2 \to 0$.

!!! tip "这个命题的意思"

    这个命题的意思就是, 这两个方差之间存在一种关联: 如果模型学习到非常精确的重建(即$\sigma^2$)趋近于0, 那么为了达到这个目标, 最优的策略是也学习到非常精确, 接近确定性的量化(即$\sigma_{\varphi}^2$也趋近于0). 这也是自退火现象背后的原理之一, 随着训练的进行, 如果重建误差降低, 量化过程的随机性也会随着降低.

当$\sigma^2 \to \infty$时, 公式(8)中的第一项减小. 当$\sigma^2_\phi \to \infty$时, 该项达到最小值, 此时$P_\phi(z_{q,i} = b_k|Z)$趋近于均匀分布. 另一方面, 根据命题1, 当$\sigma^2 \to 0$时, 会导致$\sigma^2_\phi \to 0$. 这意味着$P_\phi(z_{q,i} = b_k|Z)$收敛到克罗内克$\delta$函数$\delta_{k,\hat{k}}$, 其中$\hat{k} = \arg\min_k \|z_i - b_k\|_2$. 这种确定性量化正是VQ-VAE的后验类别分布. 根据以上两种情况, 如果在训练过程中$\sigma^2$逐渐减小, 那么量化过程的随机性也会逐渐降低, 并趋近于确定性量化. 作者将此过程称为*自退火*.

为验证训练过程中是否发生*自退火*, 他们在MNIST上进行了一项实验. 他们训练了高斯SQ-VAE, 其中$\Sigma_\phi = \sigma^2_\phi \mathbf{I}$. 作为比较对象, 他们还训练了将$\sigma^2_\phi$固定为指定值$\sigma^2_q$的模型. 实验设置的细节可在附录中找到. 结果总结在[图2](#fig2)中.

<figure markdown='1' id='fig2'>
![](https://img.ricolxwz.io/6961403a3c2be096625f2c8d793ca3c4.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/6961403a3c2be096625f2c8d793ca3c4_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图2: 本节中与$\sigma^2_\phi$相关的动态变化的实证研究. (a)方差参数$\sigma^2_\phi$(蓝色)随$\sigma^2$(红色)减小, 其中$\sigma^2_0$和$\sigma^2_{\phi,0}$是它们的初始值. (b)量化过程相对于迭代次数的平均熵, 通过蒙特卡洛估计获得. (c)测试集上可训练$\sigma^2_\phi$和不同$\sigma^2_q$值对应的均方误差(MSE). </figcaption>
</figure>

在[图2](#fig2)(a)中, 随着训练轮数的增加, $\sigma^2_\phi$与$\sigma^2$一同减小, 这与命题1和作者的预期一致. 如[图2](#fig2)(b)所示, 当$\sigma^2_\phi$可训练时, 平均熵随着训练的进行而降低. 这两个结果表明*自退火*在实际情况中会发生. 另一方面, [图2](#fig2)(b)显示, 当$\sigma^2_q$固定时, 平均熵保持相对恒定. 此外, 如[图2](#fig2)(c)所示, 均方误差(MSE)受所选$\sigma^2_q$的影响很大. 尽管固定$\sigma^2_q$存在一个最优值, 但由蓝线表示的可训练$\sigma^2_\phi$在所有情况中均获得了最低的均方误差. 因此, 作者证明了随机量化和*自退火*共同产生了一个码本, 该码本能够有效地覆盖潜在空间中更大的支撑集, 特别是在训练阶段的初期. 这有助于提高重建精度.

### vMF SQ-VAE

将SQ-VAE适用于分类数据分布的一种直观方法是, 将解码器输出建模为分类分布(原文公式3). 考虑一个典型的分类场景: 解码器的最后一层是一个线性层, 其后跟着一个softmax层. 解码器可以表示为线性层$w_{last,c} \in \mathbb{R}^F$和其余部分$\tilde{f}_{ \theta^-,d}^{rest}: \mathbb{B}^{dz} \to \mathbb{R}^F$的组合. 它变为$f^c_{\theta,d}(Z_q) = w^T_{last,c} \tilde{f}^{rest}_{\theta^-,d}(Z_q)$, 其中$\theta^-$表示除$w_{last,c}$之外的可训练参数.

该模型基于分解的ELBO表示为

$$\mathcal{L}_{\text{CE-SQ}}^{\text{naive}} = \mathbb{E}_{q_\omega(\mathbf{z}|\mathbf{x})\hat{P}_\varphi(\mathbf{Z}_q|\mathbf{z})} \left[ -\sum_{d=1}^D \log(P_\theta(x_d = c|\mathbf{Z}_q)) + \mathcal{R}_\varphi^N(\mathbf{Z}, \mathbf{Z}_q) \right] - \mathbb{E}_{q_\omega(\mathbf{z}|\mathbf{x})} H(\hat{P}_\varphi(\mathbf{Z}_q|\mathbf{z})) + \text{const.} \tag{9a}$$

其中$P_\theta(x_d = c|\mathbf{Z}_q) = \text{softmax}_c \left( \{\mathbf{w}_{\text{last},c'}^{\text{T}} \tilde{f}_{\theta^-,d}^{\text{rest}}(\mathbf{Z}_q)\}_{c'=1}^C \right) \tag{9b}$.

> 可以参考VAE解码器输出为分类分布, 差不多也是这个意思, 可以看作是一个交叉熵损失.

然而, 他们发现这种朴素分类(NC)SQ-VAE的性能通常不尽如人意. 通过观察(8)和(9a)之间的差异, 可以找到一个可能的原因. 在(9a)中, 由于用分类分布替代了高斯分布, 像$\sigma^2$这样的可训练参数在目标函数中已不复存在. 这意味着该模型无法从自退火效应中受益.

为了利用自退火的优势, 他们引入vMF分布来改进模型, 如[图3](#fig3)所示, 并将其称为vMF SQ-VAE. 考虑一个嵌入在$F$维空间中的超球面$S^{F-1}$. 令$w_c$表示第$c$个数据类别在$S^{F-1}$表面上的投影向量. 接下来, 他们将数据$x_d$在超球面上的投影表示为$v_d \in \{w_c\}_{c=1}^{C_{all}}$. 如果$x_d$属于类别$c$, 即$x_d = c$, 则$v_d = w_c$, 反之亦然.

<figure markdown='1' id='fig3'>
![](https://img.ricolxwz.io/d7448ea350c6854f92123230a8eec305.webp#only-light){ loading=lazy width='500' }
![](https://img.ricolxwz.io/d7448ea350c6854f92123230a8eec305_inverted.webp#only-dark){ loading=lazy width='500' }
<figcaption>图3: vMF解码器</figcaption>
</figure>

#### 解码

第一步是使用解码器$\tilde{f}_{\theta,d}: \mathbb{B}^{dz} \to S^{F-1}$将$Z_q$解码为$V := \{v_d\}_{d=1}^D$. 然后, 通过使用

$$P_\theta(v_d = w_c|\mathbf{Z}_q) = \text{softmax}_c \left( \{\kappa \mathbf{w}_{c'}^{\text{T}} \tilde{f}_{\theta,d}(\mathbf{Z}_q)\}_{c'=1}^{C_{\text{all}}} \right) \tag{10}$$

来确定$v_d = w_c$的概率, 其中$\kappa \in \mathbb{R}_+$是一个可训练的标量. 这类似于(9b)中的分类解码器, 不同之处在于对$S^{F-1}$的归一化和缩放因子$\kappa$. 因此, 他们可以将解码后的$Z_q$的分类概率表示为

$$p_\theta(v_d|\mathbf{Z}_q) \propto \exp(\kappa v_d^{\text{T}} \tilde{f}_{\theta,d}(\mathbf{Z}_q)) \tag{11}$$

通过将(11)关于$v_d$在$S^{F-1}$上进行归一化, 他们得到$p_\theta(v_d|\mathbf{Z}_q) = \text{vMF}(\tilde{f}_{\theta,d}(\mathbf{Z}_q), \kappa)$, 其中$\tilde{f}_{\theta,d}(\mathbf{Z}_q)$和$\kappa$分别对应于vMF分布的平均方向和集中度参数.

#### 编码

相应地, 他们使用vMF分布对编码器的随机去量化过程进行建模:

$$p_\varphi(\mathbf{z}_i|\mathbf{Z}_q) = \text{vMF}(\mathbf{z}_{q,i}, \kappa_\varphi) \tag{12}$$

其中$\kappa_\varphi$是可训练的集中度参数. 与第3.2节中的高斯SQ-VAE类似, 使用贝叶斯定理恢复离散的$Z_q$, 表示为

$$\hat{P}_\varphi(z_{q,i} = b_k|\mathbf{Z}) = \text{softmax}_k (\{ \kappa_\varphi b_j^{\text{T}} z_i \}_{j=1}^K) \tag{13}$$

其中(13)中$b_k$的未归一化对数概率对应于$b_k$和$z_i$之间经$\kappa_\varphi$缩放的余弦相似度.

#### 优化目标

目标函数 将编码和解码过程代入(5)可得

$$\mathcal{L}_{\text{vMF-SQ}} = \mathbb{E}_{q_\omega(\mathbf{z}|\mathbf{x})\hat{P}_\varphi(\mathbf{Z}_q|\mathbf{z})} \left[ -\kappa \sum_{d=1}^D \mathbf{v}_d^{\text{T}} \tilde{f}_{\theta,d}(\mathbf{Z}_q) + \mathcal{R}_\varphi^{\text{vMF}}(\mathbf{Z}, \mathbf{Z}_q) \right] - \mathbb{E}_{q_\omega(\mathbf{z}|\mathbf{v})} H(\hat{P}_\varphi(\mathbf{Z}_q|\mathbf{z})) - \log C_F(\kappa) + \text{const.}$$

其中$\mathcal{R}_\varphi^{\text{vMF}}(\mathbf{x}, \mathbf{Z}_q)$是由$\mathcal{R}_\varphi^{\text{vMF}}(\mathbf{Z}, \mathbf{Z}_q) = \sum_{i=1}^{d_z} \kappa_{\varphi,i}(1 - \mathbf{z}_{q,i}^{\text{T}} \mathbf{z}_i)$定义的正则化目标(详见附录B.2). 此处, $C_F(\kappa)$表示vMF分布的归一化常数(详见附录A).

> 总的来说, 这篇文章理论的知识点很多, 值得细细品味.

[^1]: Takida, Y., Shibuya, T., Liao, W., Lai, C.-H., Ohmura, J., Uesaka, T., Murata, N., Takahashi, S., Kumakura, T., & Mitsufuji, Y. (2022). SQ-VAE: Variational bayes on discrete representation with self-annealed stochastic quantization (No. arXiv:2205.07547). arXiv. https://doi.org/10.48550/arXiv.2205.07547
