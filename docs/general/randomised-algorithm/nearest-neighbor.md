---
title: 随机算法:最近邻问题
comments: true
---

## 最近邻问题

上一周, 我们讨论的是字典问题, 即给定全集$\mathcal{X}$, 和其中的一个子集, 快速判断一个查询元素$x\in \mathcal{X}$是否属于$\mathcal{S}$. 我们可以用Bloom Filter和哈希表的方式解决这个问题.

本周, 我们要解决的是一个类似的问题. 同样有一个子集$\mathcal{S}\subset \mathcal{X}$, 我们不再问$x$是否在$\mathcal{S}$中, 而是要返回和$x$距离最近的点$y\in \mathcal{S}$. 这个就是最近邻问题, 常常比字典问题更难.

解决这个问题可以有很多的应用, 如(1)图像去噪, 给一张含有噪声的图片$x$, 找到最相似的原图$y$并修复; (2)高维聚类: 把点$x$归到离它最近的簇中心; (3)作业查重: 找到和新提交作业最相似的旧作业.

那么, 什么是最近呢? 我们需要定义在$\mathcal{X}$中元素之间的距离是啥. 在这里, 我们假设$\mathcal{X}$是一个度量空间.

???+ tip "度量空间"

    度量空间 = 元素集合 + 满足四公理的距离函数. 它把"远近"的概念从具体坐标系抽象出来, 成为最近邻搜索, 聚类, 分析等众多算法与理论的共同基石.

    设$X$是一个非空集合, $d:X\times X\to\mathbb R_{+}$是一个函数, 若满足以下四条公理, 则称$(X,d)$ 为度量空间:

    | 编号 | 公理 | 解释 |
    |------|------|------|
    | (1) 非负性 | $d(x,y)+$ | 距离永远不为负数 |
    | (2) 恒等分离 | $d(x,y)=0 \iff x=y$ | 只有同一个点之间距离为0 |
    | (3) 对称性 | $d(x,y)=d(y,x)$ | 交换顺序不影响距离 |
    | (4) 三角不等式 | $d(x,z)\le d(x,y)+d(y,z)$ | 直达最短, 不会比"中转"更长 |

那么, 如何定义这个距离函数$d:X\times X\to\mathbb R_{+}$呢? 在机器学习中, 你可能已经见到过一下三种度量方式:

| 序号 | 距离名称 | 适用空间 $\mathcal{X}$ | 数学定义 | 常见别名 |
|------|---------|---------------------------|----------|----------|
| 1 | 曼哈顿距离 $\ell_1$ | $\mathbb R^{d}$ | $\displaystyle \operatorname{dist}(x,y)=\sum_{i=1}^{d}\lvert x_i-y_i\rvert = \lVert x-y\rVert_{1}$ | $\ell_1$ 距离, 出租车(taxicab)距离 |
| 2 | 欧氏距离 $\ell_2$ | $\mathbb R^{d}$ | $\displaystyle \operatorname{dist}(x,y)=\sqrt{\sum_{i=1}^{d}(x_i-y_i)^{2}} = \lVert x-y\rVert_{2}$ | $\ell_2$ 距离 |
| 3 | 汉明距离 | $\{0,1\}^{d}$(二值向量) | $\displaystyle \operatorname{dist}(x,y)=\sum_{i=1}^{d}\mathbf 1_{x_i\neq y_i}$ | 位差计数 |

---

结合上述的前置知识, 现在我们有能力能够定义这个问题了:

给定一个数据集\(S\), 它是一个非常大的度量空间\((\mathcal X,\mathrm{dist})\)的子集; 当出现一个新的元素\(x\in\mathcal X\)时, 如何输出集合\(S\)中与\(x\)距离(\(\mathrm{dist}(x,y)\))最小的元素\(y\)?

就像之前一样, 我们会用$n=|\mathcal{S}|$表示子集当前的大小, 然而, 我们不再用$m$表示$\mathcal{X}$的大小, 而是用$\mathbb{R}^d$表示高纬度的空间, $d$是维度.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/2946708885d86aa3869765a15f6332d3.webp#only-light){ loading=lazy width='200' }
![](https://img.ricolxwz.io/2946708885d86aa3869765a15f6332d3_inverted.webp#only-dark){ loading=lazy width='200' }
</figure>

简易起见, 我们设定离线模式, 即假设一次性拿到$\mathcal{S}$的全部$n$个元素, 而这个子集$\mathcal{S}$是不会随着时间改变的, 即不会有新增也不会有和删除. 接着, 需要支持$Query(x)$, 给定查询点$x$, 返回使得$dist(x, y)$最小的$y\in \mathcal{S}$.

主要考虑的复杂度目标有:

* 空间复杂度: 希望数据结构尽量减少空间占用, 理想值为$O(nd)$
* 查询时间: 期望应该次线性于$n$, 对适当的$d$可以接受, 如$Poly(d)\times O(n^{0.99})$被视为可以接受
* 预处理时间: 除了查询时间要做到$O(n)$, 还希望构建索引的预处理时间也可控, 即用$n$个元素建好数据结构的成本不能过高.

典型的参数区间是:

$$1\ll d\ll n\ll 2^d$$

根据这条不等式, 可以帮助我们判断算法的复杂度是否合理:

* 和$n$相关的因子必须是次线性的
* 和$d$相关的因子不能是指数性的

我们进一步假设:

* 任意两点之间的距离$dist(x, y)$可以在$O(d)$时间内算出
* 存储一个$d$维向量需要$O(d)$空间

## 基线方法

这里, 有两个基线方法, 它们可以达到其中的一个要求, 但是不能满足另一个. 没有人能够同时做到多项式级别的空间复杂度和次线性级别的时间复杂度.

## ANN

遇到这类情形,一种本能反应是耸肩放弃; 而往往再过几分钟,另一种自然做法便是改造原问题,看看一个更弱, 但容易得多的"放松版"是否已经够用. 这正是近似最近邻(ApproximateNearestNeighbour)问题的出发点: 我们不再要求找到$S$中与查询点$x\in\mathcal{X}$距离最小的$y^*$,而只需返回某个$y\in S$,使得它离$x$的距离与$y^*$相差不大,也就是"足够好".

给定数据集$S$是一个巨大度量空间$(\mathcal{X},\mathrm{dist})$的子集,当到来新元素$x\in\mathcal{X}$时,希望输出某个$y\in S$,使得$\mathrm{dist}(x,y)$不超过$\min_{y'\in S}\mathrm{dist}(x,y')$的常数倍.

接下来,我们用一个固定常数$C>1$来参数化数据结构,并要求其支持如下查询:

给定$x\in\mathcal{X}$,返回$y\in S$,满足$\mathrm{dist}(x,y)\le C\cdot\min_{y'\in S}\mathrm{dist}(x,y')$. (若取$C=1$,就退化回原始的最近邻问题)

## 方案一: Johnson-Lindenstrauss引理

Johnson-LIndenstrauss引理的核心目标就是在保持欧氏距离近似不变的情况下, 将高维空间$\mathbb{R^d}$中的点随机映射到远低于$d$的$\mathbb{R^k}$中. 为了实现这一目标, 只需要随机构造一个线性映射$\Phi:  \mathbb{R^d}\rightarrow \mathbb{R^k}$, 就能几乎等距地把所有点投影到低维空间.

具体地, 若选择参数$\epsilon\in (0, 1/2), \delta\in (0, 1/2)$, 并令$k=O(\log(1/\delta)/\epsilon^2)$, 则对任意在原始高维空间中地两点$x, y\in \mathbb{R}^d$, 有:

$$||\Phi(x)-\Phi(y)||_2=(1\pm \epsilon)||x-y||_2$$

的概率至少为$1-\delta$. 也就是说, 两点间距离在投影后只被相对误差$\epsilon$放大或者缩小. 举例子: $\delta=0.01, \epsilon=0.01$的时候, 原本位于巨大维度$d$中的数据可以被映射到一个常数维度$k$里面, 仍然保持距离误差$\leq 1\%$.

更令人惊喜的是, $\Phi$的构造方式非常简单, 随机生成一张$k\times d$的矩阵$M$就完事了. 然后$\Phi(x)=Mx$, 无需复杂的优化或者数据依赖预处理, 却在理论上保证了距离近似不变.

???+ note "JK Lemma总结"

    === "Distributional JK Lemma"

        固定任意$\,\varepsilon,\delta\in(0,1/2)\,$, 设

        $$
        k=\Theta\!\Bigl(\frac{\log(1/\delta)}{\varepsilon^{2}}\Bigr).
        $$

        构造随机矩阵$M\in\mathbb{R}^{k\times d}$, 其中每个元素$M_{ij}$独立服从高斯分布$\mathcal{N}(0,1/k)$. 对任意固定向量$u\in\mathbb{R}^{d}$, 有

        $$
        \Pr_{M}\bigl[(1-\varepsilon)\lVert u\rVert_{2}\le\lVert Mu\rVert_{2}\le(1+\varepsilon)\lVert u\rVert_{2}\bigr]\ge1-\delta.
        $$

        1. 生成矩阵$M$的时间复杂度为$\mathcal{O}(kd)$(假设采样$\mathcal{N}(0,1)$的开销为常数).
        2. 对任意$x\in\mathbb{R}^{d}$, 计算投影$Mx$同样只需$\mathcal{O}(kd)$时间.
        3. 这一结果直接推出后面的推论, 亦即通常所称的"JL引理", 我们随后将予以证明.

    === "JL Lemma"

        固定任意$ε∈(0,1/2)$且$n≥2$, 设

        $$
        k=Θ\!\left(\frac{\log n}{ε^{2}}\right).
        $$

        取定理36中定义的随机矩阵$M∈\mathbb{R}^{k×d}$. 则对任意包含$n$个元素的固定集合$T⊆\mathbb{R}^{d}$, 有

        $$
        \Pr_{M}\bigl[∀x,y∈T,(1-ε)\lVert x-y\rVert_{2}≤\lVert Mx-My\rVert_{2}≤(1+ε)\lVert x-y\rVert_{2}\bigr]≥\frac{9}{10}.
        $$

Johnson-Lindenstrauss引理告诉我们仅需容忍元素之间$\binom{n}{2}$个配对欧氏距离的微小失真,就能把原本的$d$维欧氏空间替换为维度仅为$O(\log n)$且更易处理的欧氏空间,而几乎不损失任何信息.

### 在ANN中的应用

- 目标是解决Euclidean空间中的ApproximateNearestNeighbour(ANN)查询.
- "基线算法"在$d$维空间工作, 复杂度对$d$呈指数或至少强依赖.
- 利用Johnson–Lindenstrauss(JL)引理把$S∪\{x\}$随机映射到$k=O(\log n/ε^{2})$维, 从而把所有点对距离保持在$(1±ε)$倍内.
- 接着在低维$\mathbb{R}^{k}$里运行同一基线算法; 由于$k\ll d$, 空间与时间开销显著下降.

#### 运用JL引理

- 空间: 基线算法空间$O(n^{1+α})$中$α$与维度线性相关; 把$d$替换成$k=O(\log n/ε^{2})$得到

    $$α=Θ(\log n/ε^{2}),\quad\text{故空间}=O\!\bigl(n^{1+\,\log n/ε^{2}}\bigr).$$

- 查询时间: 同理得到

    $$O\!\bigl(n^{\log n/ε^{2}}\bigr).$$

- 成功概率: JL投影本身以常数概率成功(可通过重复&放大达到≥$9/10$), 加上基线算法的确定性或高概率正确性, 即得结论.

这还没有完全解决问题(查询时间依然几乎对$n$呈线性依赖), 但已经有所改进.

## 方案二: 局部哈希框架
