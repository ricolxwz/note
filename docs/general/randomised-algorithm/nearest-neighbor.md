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
![](https://img.ricolxwz.cn/2946708885d86aa3869765a15f6332d3.webp#only-light){ loading=lazy width='200' }
![](https://img.ricolxwz.cn/2946708885d86aa3869765a15f6332d3_inverted.webp#only-dark){ loading=lazy width='200' }
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

???+ note "JL Lemma总结"

    === "Distributional JL Lemma"

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


### 在ANN中的应用

我们的目标是解决Euclidean空间中的ApproximateNearestNeighbour(ANN)查询. 而"基线算法"在$d$维空间工作, 复杂度对$d$呈指数或至少强依赖. 利用Johnson–Lindenstrauss(JL)引理把$S∪\{x\}$随机映射到$k=O(\log n/ε^{2})$维, 从而把所有点对距离保持在$(1±ε)$倍内. 接着在低维$\mathbb{R}^{k}$里运行同一基线算法; 由于$k\ll d$, 空间与时间开销显著下降.

复杂度分析:

- 空间: 基线算法空间$O(n^{1+α})$中$α$与维度线性相关; 把$d$替换成$k=O(\log n/ε^{2})$得到$α=Θ(\log n/ε^{2}),\quad\text{故空间}=O\!\bigl(n^{1+\,\log n/ε^{2}}\bigr)$
- 查询时间: 同理得到$O\!\bigl(n^{\log n/ε^{2}}\bigr)$
- 成功概率: JL投影本身以常数概率成功(可通过重复&放大达到≥$9/10$), 加上基线算法的确定性或高概率正确性, 即得结论.

这还没有完全解决问题(查询时间依然几乎对$n$呈线性依赖), 但已经有所改进.

Johnson-Lindenstrauss引理告诉我们仅需容忍元素之间$\binom{n}{2}$个配对欧氏距离的微小失真,就能把原本的$d$维欧氏空间替换为维度仅为$O(\log n)$且更易处理的欧氏空间,而几乎不损失任何信息.

## 方案二: 局部敏感哈希(Locality-Sensitive Hashing, LSH)

### 速览

LSH通过概率意义上的"保距"来区分近点与远点:

- 近点(距离≤ r)落到同一桶的概率应高;
- 远点(距离≥ Cr)落到同一桶的概率应低.

这与Johnson-Lindenstrauss引理用随机投影保持距离的思想类似, 只是把线性映射替换成了随机哈希.

### 定义

#### LSH族

给定度量空间$(X,\text{dist})$与参数

\[
0\le q<p\le1,\quad r>0,\quad C>1,
\]

若哈希族$\mathcal{H}=\{h:X\to Y\}$满足

| 场景 | 条件 | 碰撞概率要求 |
|---|---|---|
| 近距离保证 | $\text{dist}(x,x')\le r$ | $\Pr_{h\sim\mathcal{H}}[h(x)=h(x')]\ge p$ |
| 远距离保证 | $\text{dist}(x,x')\ge Cr$ | $\Pr_{h\sim\mathcal{H}}[h(x)=h(x')]\le q$ |

则称$\mathcal{H}$为$(r,C,p,q)$-LSH族.

#### 敏感度参数

进一步定义敏感度参数:

\[
\rho=\frac{\log(1/p)}{\log(1/q)}<1,
\]

$\rho$越大代表近远点的碰撞概率差异越明显, 后续算法效果越好.

### 设计要点

1. 尺度控制: 在选定的尺度$r$下仅需区分"近/远", 不追求对所有距离都精确判别
2. 增大$p$, 减小$q$: 本质是让$\rho$尽量接近1
3. 存在性: 极端例子$h=\text{id}$(恒等映射)显然满足定义但无压缩; 真正有价值的是$\lvert Y\rvert\ll\lvert X\rvert$且$\rho$依旧可观的族

### 在ANN中的应用

#### 问题设置

数据集$\mathcal S\subseteq X$, 固定参数$r>0,C>1$.

#### 查询接口

查询接口$Query_r(x)$:

- 输入: 查询点$x\in X$
- 输出: $\mathcal S$中的某点$y$或$\perp$

#### 正确性要求

| 情形 | 期望行为 |
|---|---|
| 存在真近邻<br>$\exists y^*\in\mathcal{S},\ \text{dist}(x,y^*)\le r$ | 以至少0.99概率返回某个$y\in\mathcal S$, 且$\text{dist}(x,y)\le C r$ |
| 全部远离<br>$\forall y\in\mathcal S,\ \text{dist}(x,y)>Cr$ | 必须返回$\perp$ |
| 模糊区间<br>$\text{dist}(x,y)\in(r,Cr]$ | 返回任意皆视为正确 |

#### 思路

给定一个$(r, C, p, q)$LSH族, 从其中任选$\ell\ge 1$个哈希函数, 定义组合函数(类似于重复大法, and-amplification)$g(x)=(g_1(x), ..., g_{\ell}(x))\in Y^{\ell}$. 那么新族$H^{(\ell)}$仍然是LSH族, 族大小为$|H|^{\ell}$, 敏感度$p$保持不变, 可以表示为$(r, C, p^{\ell}, q^{\ell})$.

根据设计要点, $p$要尽量大, $q$要尽量小, 有了$\ell$这个参数之后, 我们的直觉是, 可以通过增大$\ell$使得误碰撞率$q^{\ell}$变得很小. 但是于此同时, 真近邻碰撞率$p^{\ell}$也会下降. 并且, 由于我们拼接了$\ell$个哈希函数, 桶的数量暴增, 输出域从$\mathcal{Y}$膨胀到$\mathcal{Y}^{\ell}$. 这个时候, 我们会引入第二个参数$k$来补救这个问题. 具体来说:

固定某个距离阈值\(r\)(以及常数\(C>1\))后, 设\(\mathcal{H}\)为一族\((r,C,p,q)\)-LSH哈希. 从\(\mathcal{H}^{(\ell)}\)中独立抽取\(k\)个哈希函数\(g_1,\dots,g_k:X\to Y^{\ell}\). 接着构建\(k\)张采用"分离链表"策略的哈希表\((A_1,h_1),\dots,(A_k,h_k)\), 其中每个\(h_t:Y\to\mathbb{Z}\)都是取自某个合适普通哈希族的互相独立的"标准"哈希函数.

他的API实现为:

* 预处理

    ```py
    for x ∈ S do          ▷ n个元素
        for t = 1..k do
            A_t[h_t(g_t(x))].insert(x)
    ```

* 查询$Query_r(x)$

    ```py
    for t = 1..k do
        L_t ← A_t[h_t(g_t(x))]   ▷ 候选列表
        for y ∈ L_t do
            if dist(x,y) ≤ C·r then
                return y         ▷ 找到近似近邻
    return ⟂                     ▷ 未找到
    ```

两层哈希的动机:

| 层级 | 使用的哈希函数 | 目标作用 | 潜在问题 |
|:---:|:---|:---|:---|
| 第一层 | 局部敏感哈希 \(g_t:X\to Y^{\ell}\) | 让"近点"高概率碰撞; "远点"低概率碰撞, 体现局部敏感性 | 输出键仍位于超大空间\(Y^{\ell}\), 若直接建表需巨量桶, 空间无法承受 |
| 第二层 | 普通哈希 \(h_t:Y\to\mathbb Z\) | 将第一层产生的"LSH键"重新映射到紧凑整数域; 继承普通哈希的低碰撞率+定长表优势, 节省存储 | — |

简言之:

1. 第一层g_t负责"智能分组": 它关注数据几何结构, 保证查询点只会跟"真正可能是近邻"的元素落到同一组.
2. 第二层h_t负责"空间压缩": 它忽略几何, 仅把LSH键再哈希到一个小整数域, 使哈希表的桶数≈数据规模n, 从而保持O(nd)级别的存储. 同时, 整体成功的概率可以总结为$P_{\text{sucess}}=1-(1-p^{\ell})^k$.

#### 总结

我们为ANN设计的数据结构空间复杂度为$O(knd+k\ell d)$, 期望查询复杂度为$O(k\ell T+kndq^{\ell})$, 关于空间复杂度和查询复杂度为啥是这个, 请见讲义中的证明. 我们重点来看一下正确性概率.

如果数据集中不存在真近邻, 那么算法会返回$\perp$. 如果数据集中存在真近邻$y^*$的时候, 对于单张表, $x$和$y^*$撞桶的概率是$p^{\ell}$, 由于$k$张表是独立的, 所以没有任何表碰撞的概率是$(1-p^{\ell})^k$. 取参数使其$\leq 0.01$, 则失败的概率$\leq 10\%$. 用公式可以表示为

\[
\Pr[\forall t\in[k],\,g_t(x)\neq g_t(y^{*})\le(1-p^{\ell})^{k}\le\frac{1}{10}.
\]

那么, 如何给$\ell$和$k$选值呢? 第一步是确定$\ell$, 假阳性的数量是$FP=k\cdot n\cdot q^{\ell}$, 我们想让单张表的原点碰撞率下降到常数级别, 就令$nq^{\ell}\simeq 1$, 得到$\ell=\frac{\log n}{\log(1/q)}$, 这样以来, 时间复杂度$O(k\ell T+kndq^{\ell})$就变为$O(k\ell T+kd)$. 第二步是确定$k$, 由于我们设定的$(1-p^{\ell})^k\leq \frac{1}{10}$, 所以有$k\ge \Theta(n^{\rho})$.

根据上面的$\ell$和$k$的设定, 在$\log n\ll d$的典型高维场景下. baby版ANN的数据结构满足: 空间复杂度为$O(n^{1+\rho}d)$, 查询复杂度为$O(n^{\rho}d)$. 其中, 由于$\rho<1$, 因此查询时间对$n$是次线性, 而空间仅比需要的$nd$多$n^{\rho}$个因子--mildly worse.

#### 反思

这个数据结构只能回答"有没有距离$\leq r$的近邻"这个固定尺度的问题, 一旦查询点和数据集里面的真实最近距离$\neq r$(我们事先不可能知道$r$), 就没法直接用. 一个可能的解决方案是对$r$做倍增搜索.

只要你为每一个半径$r$都构造出这样一个baby版本的ANN, 那么就可以通过倍增搜索的方式将它升级为真正的ANN数据结构. 令$\Delta:=\frac{\text{max}_{x, x'}\text{dist}(x, x')}{\text{min}_{x, x'}\text{dist}(x, x')}$是数据集的纵深或者称为aspect ratio. 在$[\text{min} \text{dist}, \text{max} \text{dist}]$这一指数范围内, 对$r$按照$1, 2, 4, 8$做几何增长, 最多$\log \Delta\leq \log n$次. 因为尝试次数$\leq \log n$, 故空间$\times \log n$, 查询时间也是如此, 相当于付出了一个$\log n$的额外成本.
