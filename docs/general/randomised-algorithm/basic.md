---
title: 随机算法:一些基础
comments: false
---

## 算法

### 线性时间内求解中位数

一种基于"Median-of-median"分而治之思想的算法, 可以在线性时间O(n)内找出n个数中的中位数. 如果想要深入了解, 可以参考Erickson的教材第1.8章, 或者Tim Roughgarden的教材(第一卷)第6章. 同时, 这也是一个复习求解递归式(无论是否使用Master Theorem)的好时机.

### 最大流和最小割算法

这里提到本课程假设你已经熟悉最大流(Max-Flow)和最小割(Min-Cut)这类算法(尤其是教材第5章中的内容). 如果需要复习, 可以查看Erickson教材的第10章和第11章. 这里简单介绍一下这最大流和最小割的概念. 最大流是指在一个流网络中, 从源点到汇点所能输送的最大流量, 受到各边容量的限制. 最小割则是将网络中的顶点分为两组(使得源点和汇点分别位于不同的组中), 使得跨越两组边的容量总和最小. 最大流最小割定理表明, 最大流的值等于最小割的容量. 

## 一些离散数学

### Factorial的增长速度

\(n!\)的数量级可以写成\(n^{\Theta(n)}\).  从对数角度看,有\(\log n! = \Theta(n \log n)\).  进一步可以用 Stirling's approximation(斯特林近似)来精确描述: \( n! = (1 + o(1))\sqrt{2 \pi n} \Bigl(\frac{n}{e}\Bigr)^n \). 其中\(o(1)\)表示当\(n \to \infty\)时趋近于 0 的量, 之所以有这一部分, 是因为斯特林近似不仅要给出近似的形式$\sqrt{2 \pi n} \Bigl(\frac{n}{e}\Bigr)^n$, 还要说明这个近似并非精确, 而是有一个相对误差随着$n$增大而变得可以忽略不计.

### Binomial系数\(\binom{2n}{n}\)的渐近行为  

文中提到\(\binom{2n}{n} = \Theta\Bigl(\frac{2^{2n}}{\sqrt{n}}\Bigr)\).  这可以在上个小节的结论上推演. 二项式系数本质上是多个阶乘之比, 而斯特林近似给出了当n足够大时阶乘的近似表达式. 一旦你把这些阶乘替换成斯特林近似形式, 就能在简化后得到二项式系数(如$C(2n,n))$的渐近表达式. 以$C(2n,n)$为例:

$C(2n,n)$的定义为\( \binom{2n}{n} = \frac{(2n)!}{(n!)^2}  \), 将斯特林近似代入(只看主项即可) \( n! \approx \sqrt{2 \pi n}\Bigl(\frac{n}{e}\Bigr)^n  \), 因此\( (2n)! \approx \sqrt{2 \pi (2n)} \Bigl(\frac{2n}{e}\Bigr)^{2n}, \quad n! \approx \sqrt{2 \pi n} \Bigl(\frac{n}{e}\Bigr)^n  \), 代入并简化\( \binom{2n}{n} \approx \frac{\sqrt{2\pi (2n)}\Bigl(\frac{2n}{e}\Bigr)^{2n}}{\Bigl[\sqrt{2\pi n}\Bigl(\frac{n}{e}\Bigr)^n\Bigr]^2} = \frac{\sqrt{4\pi n}\Bigl(\frac{2n}{e}\Bigr)^{2n}}{2\pi n \Bigl(\frac{n}{e}\Bigr)^{2n}}  \), 注意\(\Bigl(\frac{2n}{e}\Bigr)^{2n} / \Bigl(\frac{n}{e}\Bigr)^{2n} = 2^{2n}\), 再将前后系数化简, 得到\( \binom{2n}{n} \approx \frac{2^{2n}}{\sqrt{\pi n}}  \). 得出$C(2n,n)$的渐近规模\( \binom{2n}{n} = \Theta\Bigl(\frac{4^n}{\sqrt{n}}\Bigr)  \)

### Harmonic numbers(调和数)$H_n = \sum_{k=1}^n \frac{1}{k}$的渐进行为

调和数的定义为\(H_n = \sum_{k=1}^n \frac{1}{k}\). 渐近表现为\(H_n = \ln n + O(1)\). 也就是说,当\(n\)很大时,调和数大约等于\(\ln n\)再加上一个常数.

### \(\sum_{k=1}^n \frac{1}{k^2}\)的渐进行为

事实上,我们知道\(\sum_{k=1}^\infty \frac{1}{k^2} = \frac{\pi^2}{6}\), 因此有界且\(\sum_{k=1}^n \frac{1}{k^2}=O(1)\).

### \(\sum_{k=1}^n \frac{1}{\sqrt{k}}\)的渐进行为

\(\sum_{k=1}^n \frac{1}{\sqrt{k}}=\Theta(\sqrt{n})\).  

### Geometric series(几何级数)  

对于\(r \neq 1\),有\( \sum_{k=0}^n r^k = \frac{r^{n+1} - 1}{r - 1}.\). 当\(|r| < 1\)且考虑无穷和时,有\( \sum_{k=0}^\infty r^k = \frac{1}{1-r}.\). 文中还提到另外一个求和公式:对于\(|r| < 1\),  \( \sum_{k=1}^\infty kr^k = \frac{r}{(1-r)^2}.  \)这是一个更进阶的几何级数求和结果.

### AM-GM inequality(算术-几何平均不等式)  

\( (x_1 x_2 \dots x_n)^{1/n} \leq \frac{x_1 + x_2 + \dots + x_n}{n}\), 当\(x_1, x_2, \dots, x_n \geq 0\)时成立. 这是算法分析和数学推导中也常常需要记住或灵活使用的一个基础不等式. 特别地, 当$n=2$, $a, b\geq 0$的时候, 有$\sqrt{ab}\leq \frac{a+b}{2}$.

## 一些概率

### 概率分布(probability distribution)的定义和性质

给出符号$\pi$, 它是定义在某个集合$X$(即可能的样本空间)上的函数, 它满足几条基本公理, $\pi(\varnothing)=0$, 即对空集的概率为0, $\pi(X)=1$, 即对全集的概率为1. 并且, 如果有可数个两两互不相交的子集$S_1, S_2, S_3, ... \subseteq X$, 那么$\pi\bigl(\bigcup_{k=1}^{\infty} S_k\bigr) = \sum_{k=1}^{\infty} \pi(S_k)
$. 这表达了"可数可加性", 表示不相交的事件的概率之和等于它们并集的概率.

### 事件的加法规则

如果S和T是不相交事件($S \bigcap T = \varnothing$), 则: $π(S \bigcup T) = π(S) + π(T)$; 如果S和T并非互不相交, 则有一般的并集概率公式: $π(S \bigcup T) = π(S) + π(T) - π(S \bigcap T)$.

### 离散情形vs.连续情形

当$X$是可数集(例如$X = \{1,2,...,n\}$或者$X = ℕ$)时, 可以用“概率质量函数(probability mass function, pmf)”来完全刻画随机变量$X$的概率分布, 即\(\pi(i) = \Pr[X = i]\), 并且对任意集合S, \(\pi(S) = \sum_{i \in S} \pi(i)\). 当$X$是连续的(例如$X = ℝ$)时, 则需要用积分(∫)替换求和(∑), 并通过“累积分布函数(cumulative distribution function, cdf)”\(\,F_X(t) = \Pr[X \le t]\)来描述, 一旦知道了cdf, 便可完全决定随机变量X的概率分布.

### 指示随机变量

指示随机变量是指只取${0,1}$这两个值的随机变量. 若有一个事件$A$, 则相应的指示随机变量可以记为$1_A$, 当事件$A$发生时取值$1$, 否则取值$0$. 例如, 如果$X$是一个在$\{1,2,3,4\}$中等概率取值的随机变量, 那么定义$1_{X\text{ even}}$来表示$X$是否为偶数, 如果$X$在${2,4}$中就取值$1$, 否则为$0$.

### 随机变量之间的独立性

若$X,Y$是随机变量, 则独立性的一个常见定义是$\mathbb{P}[X\in S, Y\in T] = \mathbb{P}[X\in S]\cdot \mathbb{P}[Y\in T]$对所有的$S,T$都成立. 这与期望的形式等价, 即$E[f(X)g(Y)] = E[f(X)]E[g(Y)]$对所有满足期望存在的函数$f$和$g$都成立. 从这里也可以推出$E[XY] = E[X]E[Y]$. 

对于$n$个随机变量$X_1, X_2, \ldots, X_n$, 若它们两两之间都符合这样的性质, 则称为两两独立, 若对任何划分事件的集合都符合联合概率可因式分解, 则称为相互独立. 即\( \Pr[X_1 \in S, X_2 \in S_2, \dots, X_n \in S_n] = \prod_{k=1}^{n} \Pr[X_k \in S_k] \quad \forall S_1, \dots, S_n.  \), 则他们之间相互独立. 或者和下面这个期望的形式是等价的: \( \mathbb{E} \left[ \prod_{k=1}^{n} f_k(X_k) \right] = \prod_{k=1}^{n} \mathbb{E} [ f_k(X_k) ].  \), 同样的, $f_1, ..., f_n$需要满足期望存在.

### 贝叶斯公式

贝叶斯公式表明对于事件$A$和$B$, 在给定概率分布的情况下, 有$\mathbb{P}[A \mid B] = \dfrac{\mathbb{P}[A \cap B]}{\mathbb{P}[B]}$. 这个结果可以用来计算如$\mathbb{P}[X\text{ prime}\mid X\text{ even}]$等条件概率. 

### 条件期望

条件期望则表明在事件$A$下, 对随机变量$X$的期望可写为$E[X\mid A] = \sum_{x\in X} x \cdot \mathbb{P}[X=x\mid A]=\frac{E[X1_A]}{\mathbb{P}[A]}$(离散情形下), 而在连续情形则要用积分替换求和, 并相应调整分母. 全期望定理(即分解定理)则是把一个随机变量的期望用若干条件期望的形式拆开, 以简化或分步骤计算所需的期望值.

进一步地, 可以将条件期望从条件于事件扩展到条件于随机变量. 给定两个随机变量$X$和$Y$. 可以写出$\mathbb{E}[X\mid Y]$, 它所代表地是"在知道$Y$之后, $X$还剩下的随机性所做的平均". 这个条件期望满足几个重要的性质.

第一个重要的性质是"全期望定理"(Law of Total Expectation), 即$\mathbb{E}[\mathbb{E}[X\mid Y]]=\mathbb{E}{X}$. 它表示"分布做期望"和"一次性做期望"会得到相同的结果. 其中$\mathbb{E}[\mathbb{E}[X\mid Y]]$表示的是先计算在给定$Y$条件下$X$的条件期望$E[X|Y]$, 然后对$Y$的所有可能取值再求一次期望. 

第二个性质和独立性有关, 如果$X$和$Y$独立, 那么知道$Y$并不能改变$X$的分布, 因此$\mathbb{E}[X\mid Y]=\mathbb{E}[X]$. 另一个极端情况是$X$是$Y$的确定性函数, 例如$X=f(Y)$ , 那么在知道$Y$之后, $X$便不再有额外的随机性, 因而$\mathbb{E}[f(Y)\mid Y]=f(Y)$'.

### 一些分布

|分布名称|参数|定义域|概率质量函数|期望|方差|
|---|---|---|---|---|---|
|几何分布$(\text{Geom}(p))$|$p\in(0,1]$|$\mathbb{N}=\{1,2,\dots\}$|$\pi(k)=p(1-p)^{k-1}$|$1/p$|$(1-p)/p^2$|
|泊松分布$(\text{Poi}(\lambda))$|$\lambda\ge0$|$\mathbb{N}\cup\{0\}=\{0,1,2,\dots\}$|$\pi(k)=e^{-\lambda}\frac{\lambda^k}{k!}$|$\lambda$|$\lambda$|
|伯努利分布$(\text{Bern}(p))$|$p\in[0,1]$|$\{0,1\}$|$\pi(0)=1-p,\ \pi(1)=p$|$p$|$p(1-p)$|
|二项分布$(\text{Bin}(n,p))$|$n\ge1,\ p\in[0,1]$|$\{0,1,\dots,n\}$|$\pi(k)=\binom{n}{k}p^k(1-p)^{n-k}$|$np$|$np(1-p)$|