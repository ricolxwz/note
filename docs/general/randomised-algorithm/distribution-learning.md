---
title: 学习与检测未知概率分布
comments: false
---

## 主题

这节课的主题是学习与检测未知分布, 也就是从一堆数据中学习到一个分布. 我们假设输入数据$x_1, ..., x_n$是从一个未知的分布$\mathbf{p}$中独立同分布抽样得到的, 目前是通过这些数据, 去了解$\mathbf{p}$本身. 我们会对这个未知的分布做一些有限的假设, 唯一的假设是它是定义在一个已知的, 离散的集合$\mathcal{X}$上面, 且空间大小是$k$, 即$|\mathcal{X}|=k$.

## 引入: 加拿大"Lotto 6/49"彩票问题

假设我们有这样的一组数据, 这是加拿大"Lotto 6/49"彩票抽样结果的直方图,$k=49$, 总抽样数为$3665$. 现在想从中学习分布$\mathbf{p}$的信息.

<figure markdown='1' id='fig1'>
![](https://img.ricolxwz.download/b4b63f0808c1d10dd2ca3302da1ddd4c.webp#only-light){ loading=lazy width='600' }
![](https://img.ricolxwz.download/b4b63f0808c1d10dd2ca3302da1ddd4c_inverted.webp#only-dark){ loading=lazy width='600' }
</figure>

### 我们的目标

那么, 你说的是什么信息呢? Well:

1. 学习分布本身

    比如: 我们能不能估计出整个分布$\mathbf{p}$是什么样子的? 解析式是什么?

2. 学习分布的特征

    比如: 我们能不能计算一些"简单"的参数$f(\mathbf{p})$, 比如均值, 熵, 方差等?

3. 检验分布是否满足某种性质

    比如: 我们能不能判断$\mathbf{p}$是否满足某种特定要求? 例如$\mathbf{p}$是否和从$\{1,…,49\}$中独立均匀抽$6$个数然后取最小值的分布一致? Again, 我们事先并不知道是这么抽的, 我们只知道抽样的结果.

从信息量的角度来说, 我们可以理解为, 学习分布本身就是需要学习$k$的个值, 学习分布的特征只需要学一个实数, 测一个性质仅仅相当于$1$个比特的信息. 所以, 得到上述信息的难度应该是学习分布本身>学习分布的特征>检验分布是否满足某种性质. 那么, 我们该怎么来设计我们的算法呢? 首先, 来看一些基本的概念.

### 算法的一些概念

1. 复杂度: 度量算法要向分布$p$发出多少独立同分布样本查询$n$
2. 随机性: 这个问题和过去最大的不同就是, 过去输入是确定的, 算法是随机的; 现在输入也是随机的, 算法也是随机的. 所以我们需要考虑两种随机性
3. 参数: 除了空间的大小$k$, 还有失败容忍度$\delta$(算法没有预测为真实分布$\mathbf{p}$的概率), 和距离参数$\epsilon>0$, 其定义取决于我们选择上述三个目标中的哪一个

### 问题的正式定义

基于上面的概念, 问题可以正式定义为: 求最小的$n = n(k, ε, δ)$, 使得在距离参数$ε$且失败概率不超过$δ$的情况下, 算法能完成我们关心的学习, 估计或测试任务. 

### 一些记号

定义在$\mathcal{X}$上的概率分布可以通过其概率质量函数(pmf)来确定, 该函数$\mathbf{p}: \mathcal{X} \rightarrow [0,1]$满足$\sum_{x \in \mathcal{X}} \mathbf{p}(x) = 1$. 相应地, 函数$\mathbf{p}$赋予子集$S \subseteq \mathcal{X}$的概率质量为$\mathbf{p}(S) = \sum_{x \in S} \mathbf{p}(x) = \text{Pr}_{x \sim \mathbf{p}}[x \in S]$. 最后,$\Delta(\mathcal{X})$表示定义在定义域$\mathcal{X}$上的所有概率分布的集合. 

## 概率分布之间的距离

为了定义学习一个概率分布的含义, 或者更进一步, 定义在同一域$\mathcal{X}$上的两个概率分布有多么接近, 我们需要距离的概念. 理想情况下, 这个概念应该是有"意义"的: (1)一个度量会很好(以便在需要时使用三角不等式), (2)一个有界的度量会更好(以便理解诸如0.1这样的值而无需归一化或过多思考), (3)一个具有简单且有意义解释的有界度量会是最好的. 

基于以上因素的考虑, 我们将目光转向总变差距离(也称为统计距离)

### 总变差距离

设$S$是$\mathcal{X}$的一个子集, 两个概率分布$\mathbf{p},\mathbf{q} \in \Delta(\mathcal{X})$之间的总变差距离由下式给出

$$\mathrm{d}_{\mathrm{TV}}(\mathbf{p}, \mathbf{q}) = \sup_{S \subseteq \mathcal{X}} |\mathbf{p}(S) - \mathbf{q}(S)|.$$

给定分布的子集$C \subseteq \Delta(\mathcal{X})$,作者进一步将$\mathbf{p} \in \Delta(\mathcal{X})$到$C$的距离定义为$\mathrm{d}_{\mathrm{TV}}(\mathbf{p}, C) := \inf_{\mathbf{q} \in C} \mathrm{d}_{\mathrm{TV}}(\mathbf{p}, \mathbf{q})$,并且如果$\mathrm{d}_{\mathrm{TV}}(\mathbf{p}, C) > \epsilon$,则称$\mathbf{p}$与$C$之间是$\epsilon$-远的.

人们可以验证$d_{TV}$在$\Delta(\mathcal{X})$上定义了一个度量,并且取值在$[0,1]$中. 此外,总变差距离表现出几个重要的性质,其中最重要的性质之一是其对后处理的免疫性:

#### 后处理免疫性

假设$X$和$Y$是具有分布$\mathbf{p}$和$\mathbf{q}$的独立随机变量, 并设$f$为独立于$X, Y$的(可能随机的)函数. 那么$f(X)$和$f(Y)$的概率分布$\mathbf{p}_f$和$\mathbf{q}_f$满足

$$d_{TV}(\mathbf{p}_f, \mathbf{q}_f) \leq d_{TV}(\mathbf{p}, \mathbf{q}).$$

也就是说, 后处理不能增加总变差距离. 换句话说, 对两个随机变量进行相同的后处理不能使它们在统计上"更远". 有趣的是, 总变差距离在不可区分性方面也有一个非常自然的解释.

#### 不可区分性

不可区分性指的是某些统计推断或者决策无法区分两个不同的分布. 总变差距离可以被视为衡量这种不可区分性的程度. 距离越小, 不可区分性越强. 下面是Pearson-Neyman等人给出的Lemma:

任何(可能是随机的)从单个样本区分$\mathbf{p}$和$\mathbf{q}$的算法其第一类(假阳性)和第二类(假阴性)错误满足 $\text{第一类} + \text{第二类} \ge 1 - d_{TV}(\mathbf{p},\mathbf{q})$. 此外, 该下界可以通过一个检验达到, 该检验当且仅当样本属于Scheffé集$S^* := \{ x : \mathbf{q}(x) > \mathbf{p}(x) \}$时输出$\mathbf{q}$.

对于这个Lemma的证明见课件. 这里说一下可以怎么理解这个Lemma, 假设$\mathbf{p}$和$\mathbf{q}$定义在集合$\mathcal{X}=\{0, 1\}$上, $\mathbf{p}(0)=0.8, \mathbf{p}=0.2; \mathbf{q}(0)=0.3, \mathbf{q}(1)=0.7$, 那么$d_{\text{TV}}(\mathbf{p}, \mathbf{q})=\frac{1}{2}(|0.8-0.3|+|0.2-0.7|)=0.5$. 假设Alice和Bob正在玩一个游戏, 他们两个人都知道$\mathbf{p}, \mathbf{q}$分布的具体解析式. Alice首先投掷一枚均匀硬币, 并且不向Bob展示结果: 如果是正面, 她抽取$x \sim \mathbf{p}$; 如果是反面, 她抽取$x \sim \mathbf{q}$. 然后她将$x$的值展示给Bob, Bob必须猜测硬币投掷的结果是否为正面(也就是判断是从分布$\mathbf{p}$中抽的, 还是从分布$\mathbf{q}$中抽的). 设Bob猜硬币是正面(认为是分布$\mathbf{p}$)但是错误的概率是$\alpha$, 猜硬币是反面(认为是分布$\mathbf{q}$)但是错误的概率是$\beta$, 由于是均匀硬币, 所以是以$1/2$为概率生成硬币的, 那么整体出错的概率可以表为$P_{err}=\frac{1}{2}\alpha+\frac{1}{2}\beta$. 由上述的Lemma可以得到, $\alpha+\beta \geq 1-d_{\text{TV}(\mathbf{p}, \mathbf{q})}$, 所以有$P_{err}\geq \frac{1}{2}-\frac{1}{2}d_{\text{TV}(\mathbf{p}, \mathbf{q})}$, 故胜率$P_{win}=1-P_{err}\leq 1-(\frac{1}{2}-\frac{1}{2}d_{\text{TV}(\mathbf{p}, \mathbf{q})})=\frac{1}{2}+\frac{1}{2}d_{\text{TV}(\mathbf{p}, \mathbf{q})}=0.75$. 这是最高的胜率. 

#### 计算公式

还有一个非常有用的fact: 总变差距离就是$\ell_1$距离的一半. 这叫做Scheffé's Lemma. 对于任意分布$\mathbf{p}, \mathbf{q}$, 总变差距离等于他们在每个取值点上概率差值绝对值之和的一半. 即:

$$
d_{TV}(\mathbf{p},\mathbf{q})=\tfrac12\sum_{x\in\mathcal X}\bigl|\mathbf{p}(x)-\mathbf{q}(x)\bigr|=\tfrac12\|\mathbf{p}-\mathbf{q}\|_1.  
$$

这个fact是一个非常有用的东西. 因为$\ell_p$范数已经被玩烂了, 可以利用常见的不等式进行分析, 例如Hölder不等式, Cauchy-Schwarz不等式, 以及$\ell_p$范数的单调性等, 从而简化证明过程.

## 一枚硬币问题

### 学习分布本身

Well, 前面, 我们假设未知分布定义在离散集合$\mathcal X$上, $|\mathcal X|=k$; 目标是通过$n$个样本了解分布$\mathbf p$本身, 某些参数$f(\mathbf p)$, 或检验$\mathbf p$是否满足某些性质, 同样用距离参数$\epsilon$和失败概率$\delta$来刻画. 

现在, 让我们专注于一个更加简单的问题: 假设未知分布只在${0,1}$上, 也就是一枚可能有偏的硬币, 它的偏置记作$p$; 目标是通过$n$次独立抛硬币来估计$p$, 使得估计误差在$\pm\epsilon$之内, 且以概率至少$1-\delta$正确. 也就是说, 我们要求的是伯努利分布中的$p$. 

那么我们需要抛多少次硬币呢? 是\(n = O\bigl(\tfrac{1}{\varepsilon\delta}\bigr),\; n = O\bigl(\tfrac{1}{\varepsilon^2\delta}\bigr),\; n = O\bigl(\tfrac{1}{\varepsilon^2}\log\tfrac{1}{\delta}\bigr),\; n = O\bigl(\tfrac{1}{\varepsilon}\log\tfrac{1}{\delta}\bigr)\)? 事实上, 如果我们事先知道一些关于硬币偏置$p$的一些额外信息, 例如, 知道$p$不太接近0或者1, 或者落在某个狭窄的区间中, 可以得到比这些更加精细的结果.

> 定理: 假设已知硬币真实偏置满足$0<p<q\leq \frac{1}{2}$, 其中$q$是一个常数上界. 目标是用$n$次独立抛掷把$p$估计到加性误差为$\epsilon$内, 且失败概率不超过$\delta$. 结论样本的数量只需:

> $$n = O(\frac{q}{\epsilon^2}\ln \frac{1}{\delta})$$

> 证明: 首先, 我们有经验均值$\hat{p}=\frac{1}{n}\sum_{i=1}nx_i$, 其中, $x_i$符合$x_i\sim \text{Bern}(p)$. 因为$\text{Var}(x_i)=p(1-p)\leq q(1-q)\leq q$, 所以可以使用Chernoff界来控制$\hat{p}$偏离$p$超过$\epsilon$的概率$\Pr[|\hat{p} - p| \ge \varepsilon] \le 2 \exp(-\frac{n \varepsilon^2}{2q}).$, 令右侧不超过$\delta$, 解得$n = O(\frac{q}{\epsilon^2}\ln \frac{1}{\delta})$.o

并且, 选择$q\in (0, 1/2]$是without loss of generality的. 如果实际情形是$q<p\leq 1$, 即$q\in (1/2, 1)$, 我们只需要把每次抛硬币得的样本$x_i$取反, 定义$x_i'=1-x_i$, 这个时候就有$0\leq p'< 1-q\leq 1/2$. 也就是说, 无论原本偏置$p$在$[0,1/2]$还是$[1/2,1]$区间, 都可以通过"翻转结果"把问题归约到$p<1/2$的情况, 不会改变估计误差要求. 

由此, 会产生一个推论, 既然是对称的, 我们将$q$设置为$1/2$相当于对$p$完全没有额外信息. 得到下面的推论: 

> 推论50.1: 以至少$1-\delta$的概率, 使用$n = O(\frac{1}{\epsilon^2} \log \frac{1}{\delta})$个独立同分布样本, 可以将硬币的偏差估计到$\epsilon$的加性误差内. (此外, 这是最优的.)

### 检验分布满足某种性质

上面说的是我们想要学到某个硬币的偏置$p$. 那么如果我们只想要测试它是不是有偏置的呢? 也就是说, 区分两种cases: (1) 硬币正面朝上的概率为$1/2$; (2) 硬币正面朝上的概率为$1/2+\Omega(\epsilon)$. 我们需要投多少次硬币才能以至少$1-\delta$的概率得到正确的结果呢? 

我们会发现, 测试一枚硬币是否是偏置的困难程度其实和学习它的偏置的困难程度是一样的. 下面是一个定理:

> 定理51: 以至少$1-\delta$的概率测试硬币的偏差是否为$1/2$或至少为$1/2 + \epsilon$, 可以使用$n = O(\frac{1}{\epsilon^2} \log \frac{1}{\delta})$个独立同分布的样本完成. (此外, 这是最优的. )

emmmmm. 这可能有点不尽如人意. 因为在偏差$\frac{\epsilon}{2}$以内, 我们都可以用"学习分布本身"中的那个推论直接求出偏置, 然后来判断是不是一枚有偏置的硬币.  为什么是$\frac{\epsilon}{2}$而不是$\epsilon$, 假设我们的偏置误差是$\epsilon$, 那么我们的估计值$\hat{p}$和真实值$p$之间的误差需要满足$|\hat{p}-p|\leq \epsilon$, 按照上面说的, 有两种case, (1) 如果真实偏差$p=1/2$, 那么我们的估计值$\hat{p}$可能落在$[1/2-\epsilon, 1/2+\epsilon]$这个区间内. (2) 如果真实偏差 $p = 1/2 + \epsilon$ (这是满足情况二的临界点), 那么我们的估计值$\hat{p}$可能落在 $[(1/2 + \epsilon) - \epsilon, (1/2 + \epsilon) + \epsilon]$ 这个区间内, 也就是 $[1/2, 1/2 + 2\epsilon]$. 现在, 比较这两个区间: 对于 $p=1/2$: $\hat{p} \in [1/2 - \epsilon, 1/2 + \epsilon]$; 对于 $p=1/2+\epsilon$: $\hat{p} \in [1/2, 1/2 + 2\epsilon]$. 你会发现这两个区间有很大的重叠部分, 例如, 从$1/2$到$1/2+\epsilon$都是重叠的, 如果估计值$\hat{p}$落在了比如$1/2+\epsilon/2$这个点, 那么就无法判断真实偏差到底是$1/2$还是$1/2+\epsilon$. 得出结论, 只要将根据定理51的$\epsilon$将推论50.1的偏差设置在$\epsilon/2$, 就可以使用推论50.1的"学习分布本身"来替代"检验是不是有偏置". 

那么, 如果我们只想要检测它是否满足某种性质呢? 是不是有某种更好的方法, 我们会发现, 有的, 但是不常有, 当硬币非常偏置的时候非常不偏置的时候, 我们能找到一个更好的方法而不是直接求偏置. 

> 定理: 对于任意$0 < \alpha \le 1/2$和$\epsilon \in (0, 1]$, 检验一枚硬币的偏差至多为$\alpha$或至少为$\alpha(1+\epsilon)$, 以至少$1-\delta$的概率, 可通过$n = O(\frac{1}{\alpha\epsilon^2}\log\frac{1}{\delta})$个独立同分布样本完成.

这里, $\alpha$是偏差的基准阈值. 判定任务是区分$p\le\alpha$与$p\ge\alpha(1+\epsilon)$两种情况. 若$p\le\alpha$则视为不偏, 若$p\ge\alpha(1+\epsilon)$则视为偏置. 完成区分所需样本量为$n=O(1/(\alpha\epsilon^2)\log(1/\delta))$, 成功概率$1-\delta$.

当$\alpha$很小时, 上式的$1/(\alpha\epsilon^2)$比直接把$p$估到加性误差$\pm\frac12\alpha\epsilon$所需的$1/(\alpha^2\epsilon^2)$小一个$\alpha$量级, 因此显著节省样本.

直观做法: 把投掷划分为块, 每块大小$1/(2\alpha)$. 例如$\alpha=0.1$时, 每5次投掷组成一块. 统计每块是否出现至少一次正面, 把该事件当作一次新的伯努利试验. 两种情形下该试验的成功概率相差$\epsilon/2$, 用Chernoff界可知需要$O(1/\epsilon^2)$块即可区分, 总样本量就是$O(1/(\alpha\epsilon^2)\log(1/\delta))$.
