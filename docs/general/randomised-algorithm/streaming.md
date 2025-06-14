---
title: 随机算法: 流处理
comments: true
---

由于时间关系, 剩余内容以pdf注解的形式分享, 请下载: [https://huggingface.co/datasets/wenzexu/share/resolve/main/Week%208%20-%20Streaming%20and%20Sketching%20I.pdf?download=true](https://huggingface.co/datasets/wenzexu/share/resolve/main/Week%208%20-%20Streaming%20and%20Sketching%20I.pdf?download=true); [https://huggingface.co/datasets/wenzexu/share/resolve/main/Week%209%20-%20Streaming%20and%20Sketching%20II.pdf?download=true](https://huggingface.co/datasets/wenzexu/share/resolve/main/Week%209%20-%20Streaming%20and%20Sketching%20II.pdf?download=true)

## 符号含义

* $m$: 数据流长度
* $\sigma=<a_1, ..., a_m>$: 数据流
* $X$: 每个数据流中的元素所属的宇宙
* $n$: 宇宙规模
* $s$: 空间复杂度

在严格的内存限制下, 算法无法完整保存整条数据流. 所以我们的首要目标是保证$s=o(\min(m, n))$, 也就是远小于数据流长度和宇宙规模. 再理想化一点, 我们的目标是$s=O(\log m+\log n)$, 如果做不到, 也争取$s=\text{poly}(\log m, \log n)$.

为了达到他的要求, 我们允许使用一种随机近似算法, 近似的程度受一个参数$\epsilon>0$控制, 通常是一个小的任意的常数.

## 多数问题

多数问题的定义如下: 给定数据流$o=<a_1, ..., a_m>$, 判断是否存在某个元素$j$(属于$[1, n]$)在流中出现的次数$f_j\geq m/2$. 其中次数被定义为$f_j=\sum_{i=1}^m 1_{a_i=j}$.

乍一看这个问题, 比较简单, 但是我们手头的内存很小, 无法加载这么大的流, 要在线判断是否存在多数元素并不是一个简单的问题. 经典的Misra-Gries算法在常数时间内能够确定性地解决更加generic的"频率估计"问题, 不仅能够找出$\geq m/2$的元素, 还能给出所有元素出现次数.

### Misra-Gries算法

Misra-Gries算法是一种确定性的算法. 它能够处理一条长度为$m$的数据流$<a_1, a_2, ..., a_m>$, 元素取值的值域为$[n]$. 给定精度参数$\epsilon\in (0, 1]$, 算法一次扫描即可给出所有元素频率的近似值$\hat{f_j}$, 满足$f_j-\epsilon m\leq \hat{f}_j\leq f_j$, $\forall j\in [n]$.

其核心思想是只跟踪足够大的元素, 当计数器数目达到上限, 再出现一个新的元素的时候, 就把所有计数器同时减去$1$, 并删除变成$0$的计数器. 变成$0$的计数器我们不存储.

计数器数量的上限定义为$k=\bigl\lceil\frac{1}{ε}\bigr\rceil=O(\frac{1}{\epsilon})$, 这是为啥呢? 假设我们称真实频率超过$\epsilon m$的元素为重元素, 那么重元素的数量不可能超过$\frac{1}{\epsilon}$个, 否则数据流的长度就不可能是$m(\epsilon m\cdot \frac{1}{\epsilon}=m)$. 所以算法把计数器的上限设置为了$\frac{1}{\epsilon}$, 保证最后得到的计数器一定cover到重元素.

算法的伪代码可以表示为:

```
对流中每个元素 x:
    若 x 已有计数器:          计数器[x]++
    否则若 计数器数目<k-1:     新建计数器[x]=1
    否则:                      对所有计数器计数-- ; 删除计数<=0 的计数器
```

或者一个更加严谨的版本:

```
输入:参数ε∈(0,1]

A←∅               //可用自平衡BST存储(key为元素,value为计数)
k←⌈1/ε⌉

for i←1到m do
    j←a_i         //读取下一个流元素
    if A[j]>0 then            //j已在A中
        A[j]←A[j]+1
    else if A[j]=0且|A|<k-1 then
        A[j]←1
    else if A[j]=0且|A|=k-1 then
        for 每个j'∈A do       //遍历当前所有计数>0的元素
            A[j']←A[j']-1
            if A[j']=0 then
                删除A中的j'
            end if
        end for
    end if
end for

函数Query(j):
    返回A[j]
```

下面我们来论证一下这个算法的复杂度. 数组$A$里面最多只会存$k=O(\frac{1}{\epsilon})$个计数器, 每个计数器需要存两件信息, 元素编号, 取值范围为$[n]$, 占到$\log n$位和当前的计数最大到$m$, 占到$\log m$位. 因此总空间为$s=O(\frac{\log (mn)}{\epsilon})$.

下面我们来论证一下$\hat{f_j}$是否能达到上界$f_j$. 由于$A[j]$只有在元素$j$真正到来的时候才会$++$, 因此最终$\hat{f_j}=A[j]\le f_j$. 下面我们来论证一下$\hat{f_j}$是否能满足下界$f_j-\epsilon m$. 下界的关键在于搞清楚$A[j]$一共被减少了多少次. 注意, 在我们的算法中, 只有当算法执行"全部计数器减一"的时候, $A[j]$才可能被减少, 且这一步发生在计数器的个数已满并且遇到一个新元素的情形. 所以每次触发这一行, 发生了两件事情, 某个元素$j^*$被从$A$中踢了出来, $k$个已有的计数器全部被减一, 其中包含也可能不包含$A[j]$. 假设总共有$T$次这样的削减事件, 被抵消的"+1"的总数是$kT$, 由于流长为$m$, 所以有恰好$m$次$+1$, 所以$kT\leq m$得到$T\leq \frac{m}{k}$. 也就是说, 这种削减事件最多能发生$\frac{m}{k}$次, 如果每一次, unfortunately, 最坏情况下, $j$都被削减了, 那么对于$j$来说, $A[j]$减少的次数就是$\frac{m}{k}$, 由于$k=\bigl\lceil\frac{1}{ε}\bigr\rceil$, 所以可以得到总减少次数$\leq \epsilon m$. 所以$\hat{f_j}\geq f_j-\epsilon m$.

举个例子, 如果$\epsilon=\frac{1}{4}$, 那么这个算法会构造一个集合$S=\{j\in [n]: \hat{f_j}\geq \frac{1}{4}m\}$, 回到我们原始想要解决的问题, 如果$j^*$是多数元素, 则$f_{j^*}\ge \frac{1}{2}m$. 所以说多数元素一定在算法产生的$S$中. 所有这类元素出现的总和必须小于$m$, 所以$S$中的元素的数量一定小于$4$. 在空间开销上来说, 只需要维护$k=\lceil\frac{1}{\epsilon}\rceil$个计数器. 然而, 这个时候$S$中的某些元素的$f$可能$\le \frac{m}{2}$, 我们需要第二遍验证, 这次选择$\epsilon =\frac{1}{2}$, 仅仅只对那$4$个元素做精确计数. 即第一遍产生候选集, 第二遍做精确验证.

## 近似计数问题

近似计数问题, 或者说是Approximate Counting问题关心的是在只允许极少数内存的情况下, 有一个数据流, 在每个时间步$1\leq i\leq m$, 有可能会发生一个事件$a_i=1$或者不发生$a_i=0$, 我们的目标是在这一段时间内对这个事件发生的总次数$d=\sum_{i=1}^m a_i$做一个估计, 把$d$控制在常数因子范围内. 如果要精确计数$d$次事件, 必须存储$O(\log (d+1))$位, 例如$d=10^{12}$的时候就需要大约40bit, 这是非常memory inefficient的.

### Morris Counter算法

算法非常简单, 维护一个非负整数计数器$x$, 初始值为0. 每当读到一个事件$a_i=1$的时候, 不是直接把$x$加一, 而是以概率$2^{-x}$把$x$加一, 换句话说, $x$越大, 后续再增长的门槛就很高. 流处理完毕之后, 输出$\hat{d}=2^{x}-1$. 算法的伪代码可以表示为:

```
1: x ← 0
2: for all 1 ≤ i ≤ m do
3:     Get item a_i ∈ {0,1}
4:     if a_i = 1 then
5:         r_i ← Bern(1/2^x)      ▷ Independent of previous choices.
6:         x ← x + r_i
7: return  d̂ ← 2^x − 1
```

这个算法的空间复杂度: 理论上, 因为数据流中事件总数$d\leq m$, 所以我们的期望$x$所占用的空间 一定不会超过$\log m$. 然而, 在极端情况下, 如果每一次抛硬币都碰巧成功, 那么$x$甚至可能一路涨到$m$, 那就需要$O(\log m)$位来存储, 与设计初衷相悖. 不过可以证明, 这种极端事件的概率随着$m$呈现指数级衰减, 几乎必然地$x$会被束缚在$O(\log m)$以内, 我们只需要为$x$预留$\log \log m$的空间即可, 实现整体的空间复杂度$s=O(\log \log m)$.

#### 空间复杂度证明

下面, 我们就来证明一下这个空间复杂度的结论. 要证明这个结论, 首先我们需要证明一个关键的引理: 上述算法中随机变量$\hat{d}$满足$E[\hat{d}]=d$和$\text{Var}[\hat{d}]=\frac{d(d-1)}{2}$. 下面是它的证明:

##### 证明均值

定义$C_i$为上述算法第$i$步结束的时候, $2^x$的值, 则$C_0=2^0=1$并且$\hat{d}=C_m-1$. 对于任何$1\leq i\leq m$, 我们有:

$$
C_{i+1}=
\begin{cases}
  2\cdot C_i, & \text{if } a_{i+1}=1\text{ and } r_{i+1}=1\\[4pt]
  C_i,       & \text{otherwise}
\end{cases}
$$

我们可以重写为$C_{i+1}=(1+a_{i+1}r_{i+1})C_i$, 由于$r_{i+1}\sim \text{Bern}(1/C_i)$, 所以有:

$$
\mathbb{E}\bigl[C_{i+1}\mid C_i\bigr]
    =(1+a_{i+1}\,\mathbb{E}[r_{i+1}\mid C_i])\cdot C_i
    =\left(1+\frac{a_{i+1}}{C_i}\right)\,C_i
    =C_i+a_{i+1}.
$$

根据Low of Total Expectation, 有:

$$
\mathbb{E}[C_{i+1}]
  =\mathbb{E}\!\bigl[\,\mathbb{E}[C_{i+1}\mid C_i]\,\bigr]
  =\mathbb{E}[C_i]+a_{i+1}.
$$

这是一个数列, 有:

$$
\mathbb{E}[C_m]
  =\mathbb{E}[C_0]+\sum_{i=0}^{m-1}\bigl(\mathbb{E}[C_{i+1}]-\mathbb{E}[C_i]\bigr)
  =1+\sum_{i=0}^{m-1}a_{i+1}
  =1+d
$$

所以, 我们证明了$E[\hat{d}]=d$. 上面的这条式子其实可以generalize为:

$$
\mathbb{E}[C_i]=1+\sum_{j=1}^{i}a_j,\qquad 1\le i\le m.
$$

##### 证明方差

下面, 我们来推导一下它的方差: 首先, 更新规则是$C_{i+1}=(1+a_{i+1}r_{i+1})C_i$, 把式子平方并把$C_i^2$提到外面得到:

\[
\mathbb E[C_{i+1}^2\mid C_i]=\mathbb E\!\Big[(1+a_{i+1}r_{i+1})^2\mid C_i\Big]\;C_i^2.
\]

展开平方项$(1+a_{i+1}r_{i+1})^2=1+2a_{i+1}r_{i+1}+a_{i+1}^2r_{i+1}^2$, 而$\,r_{i+1}^2=r_{i+1}$(因为$r_{i+1}$只有$0/1$). 又有$\mathbb E[r_{i+1}\mid C_i]=1/C_i$, 于是

\[
\mathbb E\!\Big[(1+a_{i+1}r_{i+1})^2\mid C_i\Big]=1+\frac{a_{i+1}(2+a_{i+1})}{C_i}.
\]

将这一结果乘回$C_i^2$便得到

\[
\;\mathbb E[C_{i+1}^2\mid C_i]=C_i^2+a_{i+1}(2+a_{i+1})\,C_i\;
\]

根据Low of Total Expectation, 有:

\[
\begin{aligned}
\mathbb{E}[C_{i+1}^2]
  &= \mathbb{E}\!\bigl[\mathbb{E}[C_{i+1}^2 \mid C_i]\bigr] \\
  &= \mathbb{E}\!\bigl[C_i^2 + a_{i+1}(2+a_{i+1})\mathbb{E}[C_i]\bigr] \\
  &= \mathbb{E}[C_i^2]
     + a_{i+1}(2+a_{i+1})\left(1+\sum_{j=1}^{i} a_j\right) \\
  &= \mathbb{E}[C_i^2]
     + 3a_{i+1}\sum_{j=1}^{i+1} a_j .
\end{aligned}
\]

和计算均值的时候类似, 这是第一个数列, 有:

\[
\begin{aligned}
\mathbb{E}[C_m^2]
&=\mathbb{E}[C_0^2]+3\sum_{i=0}^{m-1}a_{i+1}\sum_{j=1}^{i+1}a_j
      =1+3\sum_{i=1}^{m}\sum_{j=1}^{i}a_i a_j \\[4pt]
&=1+3\cdot\frac12\!\left(
      \left(\sum_{i=1}^{m}a_i\right)^{\!2}
      +\sum_{i=1}^{m}a_i^{2}
   \right) \\[4pt]
&=1+3\cdot\frac12\bigl(d^{2}+d\bigr).
\end{aligned}
\]

由于$E[C_m]^2=(d+1)^2$, 我们可以计算方差了:

\[
\operatorname{Var}[C_m]
  = 1 + 3\cdot\frac12\bigl(d^{2}+d\bigr)
    - (d+1)^{2}
  = \frac{d^{2}-d}{2}\,
\]

#### Median of Means版本

从上述推导中可以看出, 单个Morris计数器的方差是$\Theta(d^2)$, 用切比雪夫不等式很难直接得到"高概率"的精确估计. 解决办法是并行独立运行$k=\Theta(1/\epsilon^2)$个计数器并取平均. 平均会把方差缩小$k$倍, 因此平均值成为一个$1+\epsilon$-近似, 成功概率可以提升到一个固定常数. 接着再使用median-trick, 把上述降低了的方差的算法再独立运行$T=\Theta(\log (1/\delta))$次, 取所有结果的中位数. 中位数对偶然的极端非常鲁棒, 于是最终得到再置信度$1-\delta$下的$(1+\epsilon)$-估计. 下面是一个更加规范的定理:

Medians-of-Means版本的Morris Counter算法: 对于任意$\epsilon, \delta\in (0, 1]$, 它给出流中非零元素个数$d$的估计值$\hat{d}$, 并保证:

$$
Pr[(1-\epsilon)d\leq \hat{d}\leq (1+\epsilon)d]\geq 1-\delta
$$

算法所用空间为:

$$
s=O(\frac{\log \log m}{\epsilon^2}\cdot \log \frac{1}{\delta})
$$

#### 继续优化

上面的算法已经把空间优化到双对数量级, 但是作者认为还继续优化. 做法不再是采用"Median of means"技巧. 而是直接改进计数器本身: 原算法在当前值为$x$的时候, 以概率$1/2^x$将$x$加一, 并把$2^x-1$作为估计; 改进版的算法引入一个可以调节的底数$\alpha>0$, 在$x$处以概率$1/(\alpha(1+\alpha)^x)$增加$x$, 返回$(1+\alpha)^x-1$, 通过精细选择$\alpha$, 可以进一步降低误差和失败的概率, 同样是双对数级空间, 但是界会更紧.

## 不同元素个数估计

Distinct Elements Problem: 给定一条长度可能极大的流, 只用亚线性内存去估计这条流中出现过的不同元素个数$d=\sum_{j\in [n]}1_{f_j>0}$. 在传统的离线场景下, 直接维护哈希集合就可以精确技术, 但是在网络包监控, 搜索日志分析或者物联网传感器等高吞吐情形中, 流速太快, 元素空间$n$太大, 根本无法把所有元素逐个存下来.

### AMS算法

研究者针对这个问题提出了Tidemark(又称为AMS)算法, 该算法能够在仅用对数级别空间的前提下给出$d$的常数因子近似. 这里先引入一个符号$zeros(k)$: 对于任意正整数$k$, $zeros(k)$指的是整数$k$的二进制写法末尾连续$0$的个数. 算法步骤为: (1) 随机选取一个强散列函数$h: [n]\rightarrow [n]$; (2) 维护单个整数变量$z$, 初始值为$0$; (3) 对数据流中的每个元素$a_i$, 计算$t=zeros(h(a_i))$, 如果$t\geq z$, 就更新$z\leftarrow t$; (4) 数据流结束后输出估计值$\hat{d}=\sqrt{2}\cdot 2^{z}$. 伪代码可以表示为:

```
1: Pick h:[n]→[n] from a strongly universal hashing family
2: z ← 0
3: for all 1 ≤ i ≤ m do
4:     Get item a_i ∈ [n]
5:     if zeros(h(a_i)) ≥ z then
6:         z ← zeros(h(a_i))
7: return ˆd ← √2 · 2^z
```

下面解释为什么使用单个变量$z$就能把去重计数器$d$估计在常数因子范围内.

首先, 先对每个整数$r$定义随机变量$Y_r:=\sum_{j\in [n], f_j>0} 1_{zeros(h(j))\geq r}$. 直观地来说, $Y_r$就是那些哈希值尾零不少于$r$位地不同元素个数; 当$Y_r\geq 1$的时候等价于$z\geq r$. 并且, 有\(\mathbb{E}[Y_r]=\sum_{\substack{j\in[n]\\f_j>0}}\Pr[\mathrm{zeros}(h(j))\ge r]=\sum_{\substack{j\in[n]\\f_j>0}}\frac{1}{2^{r}}=\frac{d}{2^{r}}\), 且有\(\operatorname{Var}[Y_r]=\sum_{\substack{j\in[n]\\f_j>0}}\operatorname{Var}\bigl[\mathbf 1_{\mathrm{zeros}(h(j))\ge r}\bigr]\le\sum_{\substack{j\in[n]\\f_j>0}}\frac{1}{2^{r}}=\frac{d}{2^{r}}\).

有了期望与方差, 就可以用基本的不等式来界定\(z\). 对任意\(r\ge0\)使用Markov不等式得\(\Pr[z\ge r]=\Pr[Y_r\ge1]\le\mathbb E[Y_r]=d/2^{r}\). 再对\(Y_{r+1}\)用Chebyshev不等式得\(\Pr[z\le r]=\Pr[Y_{r+1}=0]\le\mathrm{Var}[Y_{r+1}]/\mathbb E[Y_{r+1}]^{2}\le2^{r+1}/d\). 于是只要取\(C:=3\sqrt2\), 就有

\[
\Pr\!\Bigl[\hat d\ge C\cdot d\Bigr]=\Pr\!\Bigl[z\ge\bigl\lceil\log_2(Cd/\sqrt2)\bigr\rceil\Bigr]\le\frac{\sqrt2\,d}{C\,d}=\frac13,
\]

\[
\Pr\!\Bigl[\hat d\le d/C\Bigr]=\Pr\!\Bigl[z\le\bigl\lfloor\log_2(d/(\sqrt2C))\bigr\rfloor\Bigr]\le\frac{2d}{\sqrt2C\,d}=\frac13.
\]

#### Median of Means版本

再搞一个Median-of-Means的版本, 我们可以得到:

经过“中位数技巧”加持的Tidemark (AMS)算法是一种随机化单遍扫描算法: 对任意\(\delta\in(0,1]\)，它能够给出流中不同元素个数\(d\)的估计\(\hat d\)，并且存在某个固定常数\(C>0\)，使得:

\[
\Pr\!\Bigl[\tfrac1C\cdot d\le\hat d\le C\cdot d\Bigr]\ge1-\delta,
\]

同时所用空间复杂度为

\[
s=O\!\bigl(\log n\cdot\log\tfrac1\delta\bigr).
\]
