---
title: 随机算法:图算法
comments: false
---

本节主要聚焦于图算法. 现存的确定性算法不够牛掰, 所以尝试用随机算法. 

## Min-Cut算法

### 第一幕

Min-Cut问题就是在途中寻找一个割(两个子集), 使得被切断的便的数量总和最小. 现存的解决这个问题的确定性算法是由Karger提出的, 他们是用最大流做的(Max-Flow). 然而, 这个确定性算法显然不是最优的, 有没有什么比较牛掰的随机算法呢? 是的, 有的. 首先, 需要定义一下什么是Contraction.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/b719f4311866a8f57b05e23867e2ff43.webp#only-light){ loading=lazy width='400' }
![](https://img.ricolxwz.io/b719f4311866a8f57b05e23867e2ff43_inverted.webp#only-dark){ loading=lazy width='400' }
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

