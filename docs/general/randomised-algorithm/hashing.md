---
title: 随机算法:哈希
comments: false
---

## 哈希表

### 第一幕

哈希解决的是内存占用过大的问题, 试想, 一个长度为为$m$的二进制位其全域的大小为$2^m$, 而实际情况下, 根本用不到全域. 例如, 一张位深为8bit, 分辨率为3072*4080的图片, 它的全域大小是$8^{3072\times 4080}$, 而实际上这个全域里面的很多值代表的都是一张没有意义的图片.

哈希表的基本思想是"The universe is a big place, but it's mostly empty". 所以, 如果我们能够map我们的宇宙$\mathcal{X}$到一个小得多的集合$\mathcal{Y}$, 使得任何由$n$个不同元素组成的子集$S\subset \mathcal{X}$都能映射到一个仍然由$n$个不同元素组成的子集$S'\subset \mathcal{Y}$, 我们就处于有利位置. 如下图所示.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/e0ba4b5413a86b2810cc34ec0464fabd.webp#only-light){ loading=lazy width='300' }
![](https://img.ricolxwz.io/e0ba4b5413a86b2810cc34ec0464fabd_inverted.webp#only-dark){ loading=lazy width='300' }
</figure>

但是, 上述的思路真的可行吗? 很可惜, 是不行的. 不管我们怎么选择映射的方法, 我们总能找到一个$n$个元素的集合, 经过映射之后, 小于$n$个元素. 这就是大名鼎鼎的"鸽子洞原理":

设定任意两个集合$\mathcal{X}, \mathcal{Y}$, 且满足$m>m'$. 然后, 对于任意映射$h: \mathcal{X}\rightarrow \mathcal{Y}$, 存在一个子集$\mathcal{S}\subseteq \mathcal{X}$, 它的大小为$\lfloor \frac{m-1}{m'}\rfloor +1 \geq 2$, 该子集中的所有元素都会被映射到$\mathcal{Y}$中的同一个值.

很重要的是, 这个"bad set of elements"是依赖于映射函数$h$的, 这就告诉我们, 如果我们**确定性的**从大宇宙$\mathcal{X}$做一个映射(hashing)到小宇宙$\mathcal{Y}$, 存在最坏情况输入导致会被映射到小宇宙中的同一个值. 但是, 如果这个映射**不是确定的呢?**

### 第二幕

我们需要考虑三种选项:

1. 假设我们要处理的数据是随机分布的.

    我们可以把这些元素视作从集合$\mathcal{X}$中随机抽取, 然后选择用一个确定性的哈希函数, 依然能在平均情况下得到不错的保证. 问题在于, 这种给完全随机的假设其实并不现实, 只能算是一种heuristic, 而不是一个rigorous guarantee, 但是, 有了总比没有好.

2. 假设哈希函数是完全随机的.

    如果哈希函数完全随机, 那么对于每个$x\in \mathcal{X}$的哈希值都可以看作在$\mathcal{Y}$上相互独立, 均匀分布, 这样我们就能用各种随机变量分析方法来估算碰撞概率, 例如, 某个$\mathcal{Y}$的bucket的平均哈希元素数量, 任意bucket的最大哈希元素数量等等.

    但是, 完全随机的哈希函数需要存储大量的信息, 大约需要$m\log_2 m'$位, 比用数组还占空间. 一种可能的解决方法是generate哈希函数on-the-fly. 可以尝试在第一次想要hash $x$的时候生成. 但是问题在于, 之后每次遇到它的时候也要保证给出的值不变. 要做到这点, 就得有个字典记录这个$x$之前分配过什么哈希函数, 同样的, 这是很占空间的. 和我们想要解决的问题背道而驰.

3. 假设哈希函数并不是完全随机的

    我们已经看到了上面确定性的哈希函数和完全随机的哈希函数并不能有效的解决问题. 所以, 我们退而求其次, 希望找一类规模适中(足够小能够节省存储, 但是又足够大保证碰撞概率降低)的哈希函数族$\mathcal{H}, 在初始化的时候随机地从里面选一个哈希函数$h$.

    * 这个集合$\mathcal{H}$不大, 存储函数只需要$\log_2|\mathcal{H}|$位
    * 只要设计得好, 随机选取这个$h$在碰撞表现上看起来就像是真的来自一个完全随机得函数, 足以在期望意义上获得较好得性能.

那么, 我们怎么选取这个哈希函数族$\mathcal{H}$呢?

1. 等下, 这玩意是不是似曾相识? 在derandomization那里也讲过这个东西. 其实, 那里讲的是strongly universal(强泛哈希家族), 它要求对任意一对不同的元素$x\neq x'$, 在随机选择哈希函数$h$后, $h(x)$和$h(x')$在映射到目标集合$\mathcal{Y}$的时候就想两个相互独立, 均匀分布的结果. 这是一种非常强的要求, 构造起来比较复杂(家族的规模比较大).

2. 其实, 另外还有一个家族, 叫做泛哈希加速(unviersal), 只需要对于任意一对不同的元素$x\neq x'$, 它们碰撞(即$h(x)=h(x')$的概率不超过$1/|\mathcal{Y}|$)就行. 也就是说, 不需要完全像两个独立的均匀随机变量, 只要保证碰撞的概率并不比真正的独立随机分配更糟糕就行. 这样家族的规模就可以更小, 构造也更加简单了一些.

    也就是说对于每个$x, x'\in \mathcal{X}, x\neq x'$, 需要满足下列式子:

    $$
    \Pr_{h\sim \mathcal{H}}[h(x)=h(x')]\neq \frac{1}{|\mathcal{Y}|}
    $$

    任何强泛哈希族都是泛哈希族, 但反之不成立.

那么, 如何来构建这个"泛哈希族"呢?

首先, 选取一个合适的素数$p$, 对于给定的整数$a, b$, 定义哈希函数:

$$h_{a,b}(x) = (ax + b \mod p) \mod m', \quad x \in \mathbb{Z}_p$$

注意, $1\leq a<p$并且$0\leq b<p$, 这个哈希家族的大小满足$|\mathcal{H}|\leq 2^{2\log_2 p}$. 证明在Lecture Notes中给出, 这里就不讨论了.

在做算法分析的时候, 我们通产先假设哈希函数是完全随机的(前面提到的第二种option), 按这种假设把所有结论推导完. 然后再回头检查整个推导过程使用的概率工具(例如期望的线性性质, 或者Chebyshev不等式等等), 看看它们是不是只需要有限/配对独立就够了, 如果确实只依赖这些有限独立级别, 那这个分析是成立的; 反之, 如果要用到Chernoff或者Hoeffding之类的需要完全独立的工具, 那么这个分析就不再成立.

### 第三幕

所以什么是哈希表呢? ... 终于, 我们到这一部分了. 一个hash table包含三个要素:

1. 一个哈希函数 \(h\) 把大集合 \(X\) 映射到较小集合 \(Y\) (大小约为 \(m' = O(n)\));
2. 一个数组 \(A\) 的大小就是 \(m'\), 用来存储或表示元素是否在哈希表中;
3. 一种用来处理"碰撞(collisions)"的策略.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/701d75e01fa5dfc5cddbfc5aa2cbbbdb.webp#only-light){ loading=lazy width='300' }
![](https://img.ricolxwz.io/701d75e01fa5dfc5cddbfc5aa2cbbbdb_inverted.webp#only-dark){ loading=lazy width='300' }
</figure>

为什么仍然需要第三步(处理碰撞)? 因为无论哈希函数多么精心设计, 都不可避免会有不同元素映射到同一个数组位置(尤其生日悖论会告诉你, 当有足够多元素时, 碰撞几率大增). 所以除了尽量减少碰撞, 我们还必须有一整套机制来解决或缓解碰撞带来的问题(例如把同一位置上的元素用链表链接起来, 或者使用开放寻址等).

## 处理碰撞

幸运的是, 有很多策略来处理碰撞, 大致上可以分为两类: separate chaning和open addressing.

### 第一幕

Seperate chaining就是当若干元素哈希到相同的bucket的时候, 就在这个bucket后面挂一条链表, 把所有的碰撞到这个桶的元素都保存在这条链表里面. 插入, 查找, 删除操作就直接在对应桶的链表中进行.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/84b854cb4f32231ddfca6804c7c34adb.webp#only-light){ loading=lazy width='300' }
![](https://img.ricolxwz.io/84b854cb4f32231ddfca6804c7c34adb_inverted.webp#only-dark){ loading=lazy width='300' }
</figure>

负载因子, 令$\alpha = \frac{n}{m'}$,. 表示每个桶期望存放多少的元素. 空间复杂度计算: 需要存储哈希函数, 大小为$m'$的数据, 所有链表节点, 总空间大概是$O(\log m+m'+n\log m)$. 时间复杂度计算: 所有的操作都是$O(1+\alpha)$, 因为在期望里, 每个桶的链表长度大约是$\alpha$. 但是若考虑最大负载(最坏的那个桶的链表长度), 可能达到$\Omega (\log n/\log\log n)$个元素, 操作成本较高.

### 第二幕

传统哈希表只有一个哈希函数, 而open addressing这个方法会准备一系列的哈希函数$h_1, h_2, ..., h_{m'}$. 插入元素$x$的时候, 先看$h_1(x)$指向的位置是否空闲, 若已经被占用就继续看$h_2(x)$, 依次下去, 直到找到空位. 查找或者删除也同理.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/d168c8cb0921f26580e5856544943f00.webp#only-light){ loading=lazy width='300' }
![](https://img.ricolxwz.io/d168c8cb0921f26580e5856544943f00_inverted.webp#only-dark){ loading=lazy width='300' }
</figure>

一些插入/查找/删除操作的细节:

* 插入: 从$t=1$开始依次检查数据桶$A[h_t(x)]$, 如果碰到$A[h_t(x)]=x$, 不用管, 如果是空或者tomstone符号(⊥), 就在那里插入并停止
* 查找: 和插入相同
* 删除: 依次查找, 若碰到$A[h_t(x)]=x$, 则将其置为⊥, 表示曾经有过数据, 但是被删除. 如果删除后直接把桶变成空, 那么后续查找的时候, 一旦撞见这个空桶就会错误地认为查不到了, 但是实际可能还需要继续往后查.
