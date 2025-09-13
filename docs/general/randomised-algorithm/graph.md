---
title: 随机算法:图算法
comments: true
---

本节主要聚焦于图算法. 现存的确定性算法不够牛掰, 所以尝试用随机算法.

## Min-Cut算法

### 第一幕

Min-Cut问题就是在途中寻找一个割(两个子集), 使得被切断的便的数量总和最小. 现存的解决这个问题的确定性算法是由Karger提出的, 他们是用最大流做的(Max-Flow). 然而, 这个确定性算法显然不是最优的, 有没有什么比较牛掰的随机算法呢? 是的, 有的. 首先, 需要定义一下什么是Contraction.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.cn/b719f4311866a8f57b05e23867e2ff43.webp#only-light){ loading=lazy width='400' }
![](https://img.ricolxwz.cn/b719f4311866a8f57b05e23867e2ff43_inverted.webp#only-dark){ loading=lazy width='400' }
</figure>

Contraction就是对于新图中的每个顶点u, 可以看作是原图中的一个顶点的子集, 比如上图中最左边(原图)中的顶点子集1和2经过收缩之后变成了新的顶点1,2, 这个新图(最右边)中的顶点1,2对应的是原图中的顶点子集1和2. 同时, 如果在新图中有两个不同的顶点u和v, 那么它们对应的原图顶点子集Su和Sv一定是相互不重叠的, 因为在一次收缩里, 原图中的同一个顶点不会收缩到两个不同的新顶点里. 简而言之, 每个新顶点对应一批原定点合并而成, 不同新顶点的这批原顶点之间不会重叠.

那么, 这个Contraction有什么作用呢? 如果我们不停的执行收缩操作, 那么如果最终得到了两个顶点u, v, 这两个顶点会对应原图中的两批顶点Su和Sv和它们之间的cut, 最重要的是, 这个cut的值就是u和v之间平行边的数量.

下面, 我们就可以给出这个算法:

```pseudo
1: 输入: 多重图 G = (V, E)
2: while |V| > 2 do:
3:     从 E 中均匀随机选取一条边 e
4:     收缩该边, 并令 G ← G/e
5: return 由剩余的两个顶点定义的 cut
```

关键的问题是, 这个算法返回的cut到底是啥? 为啥能解决我们的min-cut问题? 一个直觉是考虑任何一个割(A, B), 如果它想要在这个算法中活到最后, 那么对于A中的一个点和B中的一个点, 它们之间的edge不会被收缩, 如果被收缩, 这个割也就不复存在. 换一种说法, 也就是如果A和B之间的边越多的话, 这个割就越不可能活到最后. 我们要的正好就是A和B之间的割边越少越好, 所以这个算法返回的就是最有可能成为最小割.

假设我们有一个最小割$C$, 那么, 上面这个算法返回它的可能性就是循环的每一步$C$中的任何一条边都没有被收缩. 假设$\xi_i$表示的是第$i$步选中的要收缩的割边不是$C$的. 上述算法返回$C$的概率可以表示为:

\[
    \begin{aligned}
\Pr[\text{C is returned}]
&= \Pr\bigl(\xi_1 \cap \xi_2 \cap \dots \cap \xi_{n-2}\bigr)\\
&= \Pr(\xi_1) \times \Pr\bigl(\xi_2 \mid \xi_1\bigr) \times \dots \times \Pr\bigl(\xi_{n-2} \mid \xi_1 \cap \xi_2 \cap \dots \cap \xi_{n-1}\bigr).
\end{aligned}
\]

基于此, 我们要做的是为以下这个条件概率找到一个比较好的下界:

$$
\Pr\bigl(\xi_{i+1} \mid \xi_1 \cap \xi_2 \cap \dots \cap \xi_{i}\bigr)
$$

在第$i+1$步, $C$中的一条割边被用于收缩的概率是:

$$
\frac{k}{|E_i|}
$$

其中, $k$是$C$中割边的数量, $|E_i|$表示的是这个时候整个$G_i$的边总数. 我们需要求一个这玩意的上界. 这步的时候顶点的数量已经变为$n-i$. 而在多重图Gi中, 每个顶点的度数都不能小于k, 否则就会出现一个度数小于k的顶点u, 这样把图的顶点分成两部分{u}和Vi\{u}的时候, 连接这两个部分的割边数(cut的大小)就会小于k, 这会导致冲突. 所以可以得到:

\[
\lvert E_i \rvert
= \frac{1}{2} \sum_{v \in V_i} \deg(v)
\;\ge\; \frac{1}{2} \lvert V_i \rvert \cdot k
\]

所以就会得到:

\[
\Pr\bigl\{\mathcal{E}_{i+1} \mid \mathcal{E}_1 \cap \mathcal{E}_2 \cap \dots \cap \mathcal{E}_i\bigr\}
= 1 - \frac{k}{\lvert E_i \rvert}
\;\ge\; 1 - \frac{2}{n - i}
\]

那么, 计算最终$C$被返回的概率:

\[
\begin{aligned}
\Pr[\text{C is returned}]
&= \prod_{i=0}^{n-3} \Pr\bigl\{\mathcal{E}_{i+1} \mid \mathcal{E}_1 \cap \dots \cap \mathcal{E}_i\bigr\} \\
&\ge \prod_{i=0}^{n-3} \Bigl(1 - \frac{2}{n - i}\Bigr) \\
&= \prod_{i=0}^{n-3} \frac{n - i - 2}{n - i} \\
&= \prod_{j=3}^{n} \frac{j - 2}{j} \\
&= \frac{1 \cdot 2 \cdot \dots \cdot (n - 2)}{3 \cdot 4 \cdot \dots \cdot n} \\
&= \frac{2}{(n - 1)n}.
\end{aligned}
\]

### 第二幕

一方面, 这个算法跑起来了┗|｀O′|┛ 嗷~~ 但是, 另一方面, 这个算法最后返回$C$的概率很小X﹏X. 但是, 利用我们在前面学到的重复大法, 可以把上面的算法重复多次, 然后选择割边最少:

```pseudo
1: 输入: 多重图 G = (V, E), 整数 T
2: for t = 1 to T do:
3:     使用全新的(独立的)随机位对 G 运行算法 10, 得到割 C_t
4: return 在所有得到的割 C_1, ..., C_T 中选取最小割
```

假设算法单词返回最小割的概率至少是p, 那么单次"失败"(没有返回最小割)的概率至多是1-p. 进行T次独立的重复后仍然全部失败的概率至多是(1-p)^T:

\[
\Pr\bigl[\text{Algorithm 11 fails to return a minimum cut}\bigr]
= (1 - p)^T
\le \left(1 - \frac{2}{n(n-1)}\right)^T
\le e^{-\frac{2T}{n(n-1)}}.
\]

假设delta表示的是我们允许算法失败的最大概率, 那么$T$就是重复大法的重复次数可以表示为:

\[
T = \left\lceil n^2 \ln\bigl(\tfrac{1}{\delta}\bigr) \right\rceil
\]


然后, 我们会发现, 这个算法的时间复杂度是$O(n^4\log (1/\delta))$, 而确定性算法的时间复杂度是$O(n^3)$, 怎么比确定性算法还拉? 太肺雾了.

### 第三幕

有没有来个能打的算法(o_ _)ﾉ? 来了, Karger-Stein算法. 上述算法最大的问题就是: 开始的时候C被kill的几率很小, 但是越到后面被kill的几率越大, 最后一步C被kill的几率甚至来到了2/3. 一个很浅显的解决方案就是只把上面的算法跑到一半, 半路出家, 现在的问题是, 什么时候停? 停了之后干嘛?

我们选择计算停下来的时候, $C$的概率正好是$1/2$. 此时, 已经经过的循环次数为$n-\frac{n}{\sqrt{2}}-1$, 那么剩下的顶点数量为$s=\frac{n}{\sqrt{2}}+1$. 嗯, 我们已经知道了啥时候停, 那么停了之后干嘛呢?

我们已经将顶点的数量以一个常数的倍率减少, 即从$n$降到大概$\frac{n}{\sqrt{2}}$. 由于我们想不到什么好的方法, 所以我们决定进行递归. 但是如果一直一直递归的话, 会出现一个问题, 每次减少到$n/\sqrt{2}$, 那么经过若干次之后, 可能递归之后的vertices不再减少了, 反而变多了, 左边这个公式就是求出减少到什么程度之后再减少, 效果反而会更差, 计算结果表明, $n\leq 6$的时候, 效果会更差, 所以直接使用brute force枚举的方式找到最小割.

目前为止, $1/2$的概率已经远远比$1/n^2$好了, 但是这仍然很小. 这里, 我们又想到了重复大法. 如果每一次递归的时候重复执行算法两次, 那么至少有一个是成功的. 可以写为下列算法:

```pseudo
procedure ModifiedKarger(G = (V, E), s)
    while |V| > s do
        Pick an edge e ∈ E uniformly at random
        Contract it, and let G ← G / e
    return G

procedure KargerStein(G = (V, E))
    if |V| ≤ 6 then
        return a minimum cut    # Brute-force computation
    Set s ← ⌈n / √2 + 1⌉
    # Contraction
    G1 ← ModifiedKarger(G, s)
    G2 ← ModifiedKarger(G, s)
    # Recursion
    C1 ← KargerStein(G1)
    C2 ← KargerStein(G2)
    return the smallest cut among C1, C2
```

`ModifiedKarger`复杂度为$O(n^2)$, 所以整个算法的复杂度可以表示为$T(n)=2T(n/\sqrt{2})+O(n^2)$. 得到的结果为$T(n)=O(n^2\log n)$. 那么它的成功率$p(n)$呢? 从我们对$s$的设置中, 我们已经知道了$G_1$包含最小割的概率至少是$1/2$, 如果这是成立的, 那么$C_1$包含最小割的概率就至少是$p(\frac{n}{\sqrt{2}})$, 所以, $C_1$包含最小割的概率是:

\[
\Pr\bigl[C_{1}\text{ is a minimum cut}\bigr]
\;\ge\;
\tfrac{1}{2}
\;\cdot\;
p\!\Bigl(\tfrac{n}{\sqrt{2}}\Bigr)
\]

同样的, 对于G2, 也有上述公式. 那么在算法的最后一行, 我们返回的是最好的$C_1$或者$C_2$. 算法成功的条件是$C_1$或者$C_2$至少其中有一个是最小割. 那么算法的成功率可以表示为:

\[
p(n)
= 1 - \bigl(1 - \Pr\bigl[C_1 \text{ is a minimum cut}\bigr]\bigr)
     \bigl(1 - \Pr\bigl[C_2 \text{ is a minimum cut}\bigr]\bigr)
\;\ge\;
1 - \Bigl(1 - \tfrac{1}{2}\,p\Bigl(\tfrac{n}{\sqrt{2}}\Bigr)\Bigr)^2
\]

我们的任务就是解出这个不等式. 当然, 我是不会去解的. ヾ(•ω•`)o 最后的结果是:

\[
p(n)
\;\ge\;
\frac{1}{2\log n + 2}
\;=\;
\Omega\!\bigl(\tfrac{1}{\log n}\bigr)
\]

就像第二幕结尾说的那样, 设置允许算法失败的最大概率之后, 我们会得到时间复杂度是$O(n^2\log^2n\log(1/\delta)$, 这比之前的确定性算法快多了!

### 第四幕

现在, 我们已经得到了Karger-Stein算法的时间复杂度和成功率. 然而, 事情变得有些奇怪了起来: 这些节省的时间复杂度到底是从哪里来的? 我们考虑了多少的割呢? 我们有下列的递归关系式:

$$N(n)=2N(n/\sqrt{2})$$

结果是$N(n)=\Theta(n^2)$. 其实和第二幕里面的Best-of-T算法是很像的. 不同点是Best-of-T是完全独立地重复收缩若干次. 而Karger-Stein的思想是初始收缩到一定规模之后分两路继续, 并且会保留前期收缩的效果(不必从头开始重新收缩), 因此同样为了提高成功率, 在大量尝试的同时, 这些尝试并非完全独立, 而是摊销了不少重复工作的成本. 这就解释了为什么Karger-Stein能够在$\Theta(n^2)$的尝试次数里面找到最小割的不错概率, 而且实践中常常概率会更好.

### 第五幕

图中到底存在多少个最小割呢? 一般我们都指导图中至少有一条最小割, 但可能不止一条. 惊喜的是, 从对Karger算法(第二幕)成功概率的分析中就能顺带判断最小割数量的上界. 第二幕算法给出了Karger算法输出特定最小割的下界:

$$\frac{2}{n(n-1)}$$

如果图中有$M$条彼此不同的最小割, 那么输出其中任意一条的概率至少是:

$$\frac{2M}{n(n-1)}$$

由于这个概率肯定小于$1$, 所以就有:

$$M<\binom{n}{2}$$

这个结论其实相当惊人, 因为一个$n$顶点无向图中, 可以有多达$2^{n-1}-1$种不同的切分方式, 但是不是所有的切分都是最小割, 不同的最小割最多只有$\binom{n}{2}$. 这个上界是否能达到呢? 是否是紧的呢? 答案是能, 例如下面这个$n$个顶点构成的环图. 刚好有$\binom{n}{2}$个最小割.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.cn/56248c7a03a55837f18b9b6f0e411607.webp#only-light){ loading=lazy width='300' }
![](https://img.ricolxwz.cn/56248c7a03a55837f18b9b6f0e411607_inverted.webp#only-dark){ loading=lazy width='300' }
</figure>

## MST算法

### 第一幕

生成树是一个图的子图, 包含图中的所有顶点, 且这些顶点之间通过边连接, 形成一棵树, 最小生成树就是在所有可能的树中, 边的权重最小的那棵树称为最小生成树.

据我们所知, 没有一个确定性的算法能够在线性时间内解出一个MST(Minimum Spanning Tree). 幸运的是, 有一个随机算法, 期望的复杂度为线性的, 由Karger, Klein和Tarjaj'j提出.

这里, 我们有一个唯一性假设: 当假设所有边的权值都互不相同的时候, 可以避免因为相同权值而产生的歧义, 使得MST唯一. 虽然这是一个简化的假设, 但是在理论上通常不影响算法的正确定和一般性.

如果能找到一种方法, 在不影响MST的前提下删除"大部分"的边, 就可以在一个规模更小的图上继续求MST, 这样做的好处是可以让后续计算大大简化. 问题就在于怎么才能不kill掉这个MST呢? 这里提到了三个概念:

* 割性质: 给定一个顶点子集$S\subseteq V$, 令$e$是连接$S$内部顶点和$S$外部顶点的最小权值边, 那么这条边一定在MST中.
* 环性质: 给定图中的任意一个环$C$, 如果某条边$e$的权值在这个环中最大, 那么$e$不会出现在MST中
* 重边(Heavy Edge): 给定一个加权图$G=(V, E)$和它的一个子森林$F\subseteq G$, 如果将某条边$e\in E\setminus F$添加到$F$中会形成一个环, 并且$e$在这个环中是"权值最大的那条边", 那么我们称这条边$e$是重边. 如果一条边$e$是相对于森林$F$而言的F-heavy edge, 那么这条边就不可能出现在G的最小生成树中(可以从环性质中得到)

最后的重边的性质, emm, 有点好用, 因为F-heaviness property告诉我们, 只要能有效识别相对于某个森林$F$, 它的重边是哪些, 然后把它们删除, 那么就不会kill掉MST.

实际上, 就有这样一种确定性的算法能够解决上述的这个问题, MSTVerification的确定性算法, 输入为一个带权图$G$和其子森林$F$, 算法可以在$O(m+n)$的时间内输出所有相对于$F$来说是F-Heavy的边.

现在, 假设, 我说是假设我们已经知道整张图$G$的MST$T$, 那么可以靠环性质和上面的算法一次性删除大量不需要的边, 只用$O(m+n)$时间就可以删掉$m-n+1$条边, 现在的问题是我们不知道真正的$T$. 但是, 我们可以知道哪些边不那么重要. 算法来了:

首先, 我们选择稀疏化原图的边: 我们可以从原图$G$中随机地保留一些边, 形成一个"小"很多的子图$G'=(V, E')$, 这个子图的顶点数保持不变, 但是边的数量减少了, 其期望是$p|E|$. 令人惊喜的是, 虽然$G'$只是随机子采样得到, 但是它所产生的最小生成树$F$对于原图的MST判定仍然能够带来一定的帮助. 换言之, 整个算法就是一个迭代式的过程: 1. 先对大图做随机子采样 2. 在子采样得到的相对更小的子图上求MST, 用它判断哪些边是heavy的, 把它们从大图中删掉 3. 再对删完边后的新图继续做随机子采样, 再跑MST, 如此循环.

其次, 我们选择稀疏化原图的顶点, 这里, 我们使用的是Boruvka算法. 下面是Boruvka算法(顶点稀疏化)和随机抽样(边稀疏化)来生成MST的流程, 可以下几个阶段:

1. 用Boruvka算法对顶点做稀疏化

    做$t$步Boruvka, 每一步对每个顶点选取一条最轻的边并收缩, 从而把图的顶点数从$n$降到$n'=n/2^t$. 这一步会得到一个更小的图$G_1$, 只有$n'$个顶点.

    ```pseudo
    procedure BoruvkaStep(G = (V, E), t)
    F ← ∅                                  ▷ F stands for "Forest"
    for 1 ≤ i ≤ t do
        for all v ∈ V do
            Find the lightest edge e ∈ E incident to v:
                e ← argmin{w(v, u) : (v, u) ∈ E}
            Contract it, and let G ← G/e
            F ← F ∪ {e}                    ▷ Add it to F
        for all u, v ∈ V do               ▷ In the new graph
            if u, v are connected by more than one edge then
                only keep one with the smallest weight
    return (G, F)                         ▷ New graph and forest of contracted edges
    ```

2. 对$G_1$进行随机抽样, 即对边做稀疏化

    在$G_1$的边上进行随机抽样, 使其边的数量从$m$降到$m'\simeq p\cdot m$. 得到的新图记作$G_2$, 顶点还是$n'$个, 但是边的数量减少到了$m'$.

3. 在更小的图$G_2$上找MSF

    由于$G_2$比原图更小, 在$G_2$上递归地求它的MSF, 记为$F_2$.

4. 用$F_2$来过滤$G_1$的边, 得到$G_3$

    将$F_2$放回$G_1$中检查哪些边在$G_1$中是$F_2$-heavy, 把这些$F_2$-heavy的边都从$G_1$中删除, 得到更小的图$G_3$. 这一步利用了随机抽样引理保证了可以高效地滤掉大量和MSF无关或者影响很小的边

5. 在$G_3$上再求MSF, 得到$F_3$

    继续递归地对$G_3$找它地MSF, 记为$F_3$, 因为删去了很多地heavy边, $G_3$也比$G_1$小, 故耗时减少.

6. 组合成原图$G$的MST

    最终, 把
