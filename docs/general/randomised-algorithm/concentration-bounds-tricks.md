---
title: 随机算法:集中界限
comments: true
---

## 定义

在随机算法中, "集中界限"指的是一系列用于分析随机变量偏离其期望值程度的概率不等式. 它们回答了这样一个核心问题: 给定一个随机变量, 它与其期望值之间的差值有多大, 又出现这种差值的概率是多少?

集中界限常见的形式包括 Chernoff Bound, Hoeffding's Inequality, Markov's Inequality, Chebyshev's Inequality 等. 这些界限在评估算法的随机行为时尤为关键, 因为它们能够帮助我们保证某些事件以高概率发生. 例如, 在随机化算法或大规模数据分析中, 需要确保随机采样结果能够可靠地逼近真实情况, 就可以应用这些集中界限来证明"算法大多数时候都不会太差"或"极端情况出现概率非常低".

## Las Vegas to Monte Carlo

将 Las Vegas 算法转化为 Monte Carlo 算法的关键思路在于: 给原本可能无限期运行的 Las Vegas 算法(确保返回结果即正确)设置一个运行或迭代次数的上限, 一旦超过这个上限则强制停止并作出一个不一定正确的猜测或输出, 这样就换来了对运行时间的明确控制, 但因此在算法结果上引入了一定的错误概率, 从而由'零错误但无最坏情况时间保证'的 Las Vegas 模式转变为'固定时间上限但非零错误概率'的 Monte Carlo 模式.

### Markov Inequality

马尔可夫不等式是概率论中的一个基本工具, 它给出了非负随机变量取较大值的概率的一个上界. 设$X$为非负随机变量, 即$X ≥ 0$, 对于任意$a > 0$, 有$P(X ≥ a) ≤ E[X] / a$. 这个不等式的直观意义是: 如果随机变量$X$的均值较小, 那么它取值超过某个较大阈值$a$的概率也必然较小. 

换句话说, 不可能有超过10%的时间$X$的值会比它的期望大10倍或更多. 如果令$a = 10E[X]$, 那么就有$P(X ≥ 10E[X]) ≤ E[X] / (10E[X]) = 1/10 = 10\%$.

证明: 令$X$为非负随机变量, $a$为正数, 定义指标函数$I\{X\geq a\}$, 当$X\geq a$的时候, $I\{X\geq a\}=1$, 否则为0. 注意到, 对于任意取值, 必有$X\geq a\cdot I\{X\geq a\}$(因为当$X\geq a$的时候, $a\cdot I\{X\geq a\}=a\leq X$; 当$X<a$的时候, $a\cdot I\{X\geq a\}=0\leq X$). 对两边取期望, 我们得到: $E[X]\geq E[a\cdot I\{X\geq a\}]=a\cdot E[I\{X\geq a\}]=a\cdot P(X\geq a)$. 整理得到: $P(X\geq a)\leq E[X]/a$.

???+ note "如何将Las Vegas算法转化为Monte Carlo算法"

    假设我们有一个Las Vegas算法A, 它解决某个问题的期望运行时间至多为$T$. 虽然在平均情况下它只需要$T$时间, 但是Las, Vegas算法在最坏情况下可能会花费非常长的时间. 为了得到一个在最坏情况下有时间上限的算法, 文中提出了一个Monte Carlo算法A', 这个算法的特点是最坏情况下运行时间为$O(T)$, 但是允许一定概率(这里是1%)的失败. 
    
    我们可以将Las Vegas算法A通过某种手段转化为这个Monte Carlo算法A'. 具体做法是, 先运行Las Vegas算法A, 但是只运行最多100步. 如果在100步之内A没有结束, 那就强行中止并输出一个可能错误的结果(或者直接随机猜一个答案), 这样就把Las Vegas算法的期望时间$T$转换为了最坏情况下不超过100T的运行时间, 同时牺牲了一点准确率(因为在被中止的情况下就可能输出错误).

    为什么这样做错误的概率就是$1\%$呢? 这可以用Markov Inequality解释. 设Las Vegas算法A的运行时间为随机变量$X$, $E[X]=T$, 根据Markov Inequality, 有$P(X\geq 100\cdot T)\leq 1/100=1\%$, 说明运行时间大于$100T$的可能性是$1\%$, 我们对这种情况进行截断, 说明超过100步之后的都是不正确的, 没超过100步的都是正确的. 因此, 失败概率为$1\%$.

    换句话说, 如果我们希望把Monte Carlo算法的错误概率降为$\delta$, 那么对应的最坏情况运行时间就会变成$O(T/\delta)$. 为了保证更低错误概率的同时仍能使用这个转化方法, 必须付出运行时间随$1/\delta$增长的代价. 有没有什么方法能够找到更好的结果呢?

### Chebyshev's Inequality

Chebyshev不等式描述了一个随机变量在其期望附近波动的概率上线. 具体来说, 假设我们有一个随机变量$X$, 并且知道以下两点信息: $X$的期望$E[X]$, $X$的方差$Var[X]$. 那么对于任意的$t>0$, Chebyshev不等式告诉我们$Pr(|X-E(X)|\geq t)\leq Var[X]/t^2$.

这意味着在没有其他信息的情况下, 我们只要知道期望和方差, 就可以估计$X$偏离其平均值一定距离的概率. 例如, 若想知道$X$偏离平均值超过10个标准差(即$10*\sqrt{Var[X]}$)的概率, 那么根据Chebyshev不等式, 这个概率不会超过$1%$.

证明: 令$Y=(X-E[X])^2$, 这个随机变量显然是非负的($Y\geq 0$), 并且令$a=t^2$. 于是$Pr(|X-E[X]|\geq t)=Pr((X-E[X])^2\geq t^2)=Pr(Y\geq a)$. 根据Markov不等式, 得到$Pr(Y\geq a)\leq E[Y]/a=E[(X-E[X])^2]/t^2=Var[X]/t^2$. 整理得到: $Pr(|X-E(X)|\geq t)\leq Var[X]/t^2$.

???+ note "使用Chebyshev Inequality转化Las Vegas算法"

    假设我们有一个Las Vegas算法A, 它解决某个问题的期望运行时间之多为$T$, 方差为$\sigma^2$. 那么我们可以得到一个Monte Carlo算法A', 最坏运行时间为$O(T)$, 失败概率为$1\%$. 在这里, 我们使用的具体做法是, 先运行Las Vegas算法A, 但是只运行最多$T+10\sigma$步(注意这里和Markov Inequality不一样了, 更少了).

    为什么这样做错误的概率就是$1\%$呢, 这可以用Chebyshev Inequality解释. 设Las Vegas算法A的运行时间为$X$, $E[X]=T$, $Var[X]=\sigma^2$, 根据Chebyshev's Inequality, 有$Pr(|X-T|\geq T+10\sigma)\leq \sigma^2/(T+10\sigma)^2$, 由于$T\geq 0$, 所以$T+10\sigma\geq 10\sigma$, 故有$\frac{\sigma^2}{(10\sigma^2)}=1\%$. 因此, 在运行时间超过$T+10\sigma$的时候就放弃算法并给出任意结果, 其出错概率最多是$1\%$. 更general的说法是, 为了使得出错概率为$\delta$, 最坏情况下的运行时间为$T+O(\sigma/\sqrt{\delta})$.

    那有没有甚至更好的方法呢? 

### Chernoff/Hoeffding Bounds

Chernoff/Hoeffding界告诉我们, 如果一个随机变量可以表示为许多独立的随机变量$X_1, X_2, ..., X_n$之和, 并且每个$X_t$都被限制在$[0, 1]$区间内, 那么我们可以对$X$与期望值$E[X]$的偏差做出指数级的小概率估计. 具体来说, 如果我们关系的是$X$相对于$E[X]$额相对偏差大小$\gamma$($\gamma$在0到1之间), 那么以下结果成立$Pr[|X-E[X]>\gamma E[X]|\leq 2\exp(-\gamma^2E[X]/3)]$(Chernoff bounds); $Pr[|X-E[X]|>\gamma n]\leq 2\exp (-2\gamma^2n)$(Hoeffding bounds).

???+ note "Chernoff/Hoeffding Bounds告诉我们什么"

    Hoeffding bound告诉我们: 一个随机变量偏离其期望值的概率会随着偏移量的增大而呈现指数级地减小. 换句话说, 如果你要随机变量相对于它的期望值在一定的"加性"范围$\gamma n$之外, 那么这种极端偏移发生的概率非常低, 并且下降速度是指数级的.

    Chernoff bound告诉我们的和Hoeffding差不多, 只不过是随机变量相对于它的期望值在相对于期望值的范围之外, 即$\gamma E[X]$.

证明: 假设我们现在要求解$Pr[X-E[X]>t]$, 设有一个单调递增的函数$f$, 则相当于要求解$Pr[f(X-E[X])>f(t)]$. 假设现在我们定义函数为$f(x)=e^{\lambda x}(\lambda > 0)$, 则相当于要求解$Pr[e^{\lambda(X-E[X])}> e^{\lambda t}]$, 现在, 运用markov inequality, 我们可以得到$Pr[e^{\lambda(X-E[X])}> e^{\lambda t}]\leq \frac{E[e^{\lambda(X-E[X])}]}{e^{\lambda t}}$. 由于假设$X$由相互独立的随机变量$X_i$组成, 且$X=\sum X_i$, 那么$E[X]=\sum E[X_i]$, 因此, $X-E[X]=(X_1-E[X_1])+(X_2-E[X_2])+...+(X_n-E[X_n])$, 带入到上式, 得到$\frac{E[e^{\lambda(X-E[X])}]}{e^{\lambda t}}=\frac{\prod_{i=1}^n E[e^{\lambda (X_i-E[X_i])}]}{e^{\lambda t}}$, 最终, 会得到一个关于$\lambda$的函数, 然后选择最佳的$\lambda$.

???+ note "使用Chernoff bounds转化Las Vegas算法"

    同样的, 假设我们有一个Las Vegas算法A, 它解决某个问题的期望运行时间之多为$T$. 那么我们可以得到一个Monte Carlo算法A', 最坏运行时间为$O(T)$, 失败概率为$\delta$. 在这里, 我们使用的具体做法是, 运行Las Vegas算法A至多$2T$步, 现在, 重复这个过程$k=O(\log (1/\delta))$次. 现在为了使得错误率为$\delta$, 最差的运行时间为$O(T\log (1/\delta))$.

### Union Bonds

Union bond又称Boole不等式, 通常用来估计"多个不利事件中至少有一个发生"的总体概率. 简单来说, union bound可以表述为$P(A_1\cup A_2\cup ... \cup A_n)\leq P(A_1)+P(A_2)+...+P(A_n)$. 即"至少一个事件发生的概率不大于单独事件发生的概率之和". 其中, $A_1$, $A_2$, ..., $A_n$代表多个可能的事件(比如随机算法中不同部分"出错"的事件). 在使用concentration bound的时候, 我们常常先对每个单独的"坏事件"使用Chernoff或者Hoeffding等不等式估计$P(A_i)$, 然后再利用"union bound"把这些事件发生的概率"加"到一起, 得到他们共同发生的概率上界. 如果我们想要知道所有事件$E_1, E_2, ..., E_k$都不发生的概率, 即(non of $E_1, E_2, ..., E_k$), 那么可以通过下述方法估计它的下界$Pr[non\,of\,E_1, E_2, ..., E_k]=1-(Pr[E_1]+Pr[E_2]+...+Pr[E_k])$.

## Monte Carlo to Las Vegas

### Las Vegas和Monte Carlo的区别

Las Vegas算法与Monte Carlo算法最大的区别在于错误率和运行时间的处理方式. Las Vegas算法在期望运行时间内保证输出一定是正确解(或明确告诉你失败,需要重试),所以它不会犯错,但可能在最坏情况下花很长时间才得到答案. Monte Carlo算法则有固定(通常是多项式级别)的运行时间上界,但允许存在一定概率的错误答案. 

### 转化问题的复杂性

从复杂性角度来看,Las Vegas算法对应的复杂性类通常是ZPP(Zero-error Probabilistic Polynomial time),而Monte Carlo算法则对应BPP,BPP容许一定范围内的随机错误. 要把Las Vegas算法转换为Monte Carlo算法相对简单:只需在运行时间上设置一个上限,如果Las Vegas算法在此时间内没给出结果就强行输出一个随机猜测(这时就容许了错误率),于是就变成了一个Monte Carlo算法. 但反过来,想要把一个会犯错的Monte Carlo算法"自动"变成一个永不犯错, 只在时间上有期望保证的Las Vegas算法,目前并没有已知的普适方法. 在理论上,这相当于要证明BPP是否等于ZPP. 如果BPP = ZPP,那么所有Monte Carlo算法都可以无误转化为Las Vegas算法;可是在现有的复杂性理论中,我们还不知道BPP与ZPP是否相等,因此无法得出通用的转换方法.

### 转化问题的关键点

要把Monte Carlo算法转成Las Vegas算法,核心在于:如果我们能够高效地验证算法输出是否正确(比如存在一个快速的Check程序),那么就可以重复运行Monte Carlo算法,在每次运行结束后用Check程序对结果进行验证. 只有在Check程序通过时才输出,否则就丢弃并重新尝试. 这样一来,只要Monte Carlo算法有非零概率给出正确结果,在期望意义上只需有限次重试就能得到正确答案,因而可以视为Las Vegas算法(零错误,但可能在运行时间上有波动). 不过,此方法要求我们确实能有效验证输出的正确性,并且不能在一开始就输出错误结果(否则就不再是零错误).在实际和理论应用中,不是所有Monte Carlo算法都能满足"结果可高效检验"的条件,因此"有时"可以完成这种转换,而不一定能对所有Monte Carlo算法适用.

### 为什么检测时间可以是常数

事实上, 有这样一个Theorem: 如果有一个Monte Carlo算法A, 它在最坏情况下用时$T$并且出错概率小于1, 而且还附带一个方便的性质--我们能在常数时间$O(1)$内检验它输出的结果是否正确, 那么就可以把它升级为一个Las Vegas算法A', 并且保持它在期望意义上的运行时间仍然是$O(T)$量级. 令$p$表示每次运行算法成功(输出"好"结果)的概率, 那么Las Vegas算法会以概率$p$在某次运行时产出正确的结果, 否则继续重试, 设$N$表示总共要运行几次算法才能第一次得到正确的结果. 为什么$E[N]$是常数复杂度即$O(1)$呢? 

证明: 失败$k$次的概率为$(1-p)^k$, 故有$P(N>k)=(1-p)^k$, 于是, $E[N]=\sum_{k=1}^{\infty}(1-p)^{k-1}=\frac{1}{p}$, 这是一个常数, 和输入的规模无关. 

## Monte Carlo to better Monte Carlo

假设我们有一个Monte Carlo算法A, 它解决的是某个判定(decision)问题, 每次运行需要时间$T$, 且单次运行的错误(失败)概率是$1/3$. 如果我们想把算法的出错概率从$1/3$进一步压低到任意小的$\delta$, 可以做如下的操作: 把算法$A$在同一输入上独立运行$k$次, 把$k$次运行得到的输出(每个输出要么是0要么是1)收集起来, 然后对这$k$个结果做"多数投票", 将投票结果作为最终输出. 

如果单次运行的正确率至少是$2/3$, 那么多数投票正确的概率会显著增高. 利用Chernoff bound可以证明, 当$k$足够大的时候, 多数投票出错的概率会以指数速度衰减, 大致上, 出错概率$\leq e^{-c\cdot k}$, 为了让出错概率降到$\delta$以下, 我们只需令$k=O(\log(1/\delta))$即可.

证明: 设第$i$次运行得到正确答案为1, 得到错误答案为0, 存储在$X_i$中. 由于单次正确率$p\geq 2/3$, 有$E[X_i]=p\geq 2/3$. 总共运行$k$次, 则有$E[X]=\sum_{i=1}^k E[X_i]=kp\geq \frac{2k}{3}$. 在多数投票下, 算法输出正确当且仅当$X>\frac{k}{2}$, 那么算法"投票出错"的事件就是$X\leq \frac{k}{2}$, 我们要估计$Pr(X\leq\frac{k}{2})$有多小. $Pr(X\leq \frac{k}{2})$可以看作一次"随机变量$X$对其期望值$E[X]$的负向偏差"事件, 这可以表示为$Pr(X\leq \frac{k}{2})\leq Pr(|X-E[X]|\geq \frac{k}{6})$. 这里随机变量$X$可以写为$X=\sum_{i=1}^k X_i$, 且$X_i$之间相互独立, 每个$X_i$都在区间$[0, 1]$内(不是0就是1), 我们可以套用Chernoff bounds: $Pr[|X-E[X]>\gamma E[X]|\leq 2\exp(-\gamma^2E[X]/3)]$, 这里$\gamma=\frac{1}{4}$. 进而得到$Pr(X\leq k/2)\leq \exp(-ck)$. 即投票出错的概率$Pr(wrong)\leq e^{-ck}$, 要将错误率压到$\delta$以下, 只需要令$e^{-ck}\leq \delta$, 即$k\geq \frac{1}{c}\ln (\frac{1}{\delta})=O(\log \frac{1}{\delta})$. 

### 中位数的作用

这个问题可以推广到一般的问题. 在决策问题中, 我们只关心哪一方的票最多, 就用"多数投票"来放大成功率. 在一般的数值输出问题里面, 如果我们仍然用"平均值"来合并多次输出, 一旦出现极端异常值或者某些运行给出了很糟糕的结果, 就会将平均值拖得很离谱, 抵消掉其他运行原本比较好的结果. 平均值对极端值过于敏感.

中位数(median trick)则是用中位数来合并多次独立运行的结果. 如果算法每次输出都以大于$1/2$的概率"相当准确", 就意味着在多数(超过一半)的情况下, 输出会集中在"好"的范围里面. 中位数捕捉的正好是"超过一半的那些在正常范围内的输出", 即使有少数运行给出非常糟糕的结果, 它们对中位数的影响也很小. 因此, 相比于"平均值", 中位数对于少量离群值更具有鲁棒性, 从而能像多数投票一样放大单词成功率大于1/2的优势. 

## 找中位数

给定一个未经过排序的数组$A$, 包含$n$个不同的整数, 找到它的中位数. 常规算法是用Quick Selection, 又叫做Median of Medians算法, 这是一个优美的deterministic的递归方法, 复杂度为$O(n)$. 现在, 我们想方法把它转化为随机算法. 该算法可以表示为:

1. Set \(\Delta = 4\sqrt{m}\)
2. Create an array \(B\) containing \(m\) elements of \(A\) chosen independently and uniformly at random (with replacement)
3. Sort \(B\)
4. Let \(\underline{b}\) and \(\overline{b}\) be the \(\bigl(\frac{m}{2} - \Delta\bigr)\)-th and \(\bigl(\frac{m}{2} + \Delta\bigr)\)-th elements of \(B\)
5. Copy every \(x\) of \(A\) with \(\underline{b} \le x \le \overline{b}\) into a new array \(C\)
6. Compute the number \(k\) of elements of \(A\) smaller than \(\underline{b}\)
7. Compute the number \(\ell\) of elements of \(A\) larger than \(\overline{b}\)
8. If \(k > \frac{n}{2}\) **or** \(\ell > \frac{n}{2}\) then  
   &emsp;return **fail**
9. Else if \(\lvert C\rvert > \frac{4n\Delta}{m} + 2\) then  
   &emsp;return **fail**
10. Else  
    &emsp;Sort \(C\)  
    &emsp;return the \(\Bigl(\frac{n+1}{2} - k\Bigr)\)-th element of \(C\)

对上述算法进行解释: 我们从第二步开始, 从$A$中独立且均匀地随机选取$m$个元素(允许重复抽取, 即"有放回"的抽样), 把这些元素放到数组$B$; 然后对数组$B$进行排序. 令$b$为排序后$B$里靠近中间但是稍微偏左的位置元素, 即第$(\frac{m}{2}-\Delta)$-th元素; 同样的, 令$\bar{b}$为排序后$B$里靠近中间但是稍微偏右的位置元素, 即第$(\frac{m}{2}+\Delta)$-th元素, 这两个分界大致围住了$B$的中间位置附近(也就是样本中位数附近). 接着, 将在$[b, \bar{b}]$区间内的所有元素复制到新数组$C$, 然后计算$k$和$\ell$, $k$表示数组$A$中比$b$小的元素个数, $\ell$表示数组$A$中比$\bar{b}$大的元素个数. 如果$k>\frac{n}{2}$或者$\ell> \frac{n}{2}$, 说明$b$或者$\bar{b}$太偏, 无法抱住真正的中位数, 直接返回"fail". 接着, 如果筛选出来的子集$C$太大(\(\lvert C\rvert > \frac{4n\Delta}{m} + 2\)), 也返回"fail". 在不"fail"的情况下对$C$排序并返回正确秩的元素. **真正中位数在全局排序中是第$\frac{n+1}{2}$个元素, 我们已经知道前面有$k$个元素比它小, 所以在$C$里面只需要取排序后第$(\frac{n+1}{2}-k)$个元素, 即为原数组$A$的中位数**. 最后, 返回这个元素.

### 复杂度分析

这个复杂度分析的主要来源是:

1. 抽样并对样本$B$进行排序, 用时$O(m\log m)$
2. 对原数组$A$做一次线性扫描(统计小于$b$, 大于$\bar{b}$的元素个数并把区间$[b, \bar{b}]$的元素拷入$C$), 用时$O(n)$
3. 在"好"的情况下对子集$C$进行排序: 由于算法要求$|C|\leq \frac{4n\Delta}{m}+2$, 且$\Delta=4\sqrt{m}$, 在期望情况下可以看作子集大小是$O(\frac{n}{\sqrt{m}})$, 因此排序$C$的时间为$O(\frac{n}{\sqrt{m}}\log(\frac{n}{\sqrt{m}}))$. 

把它们相加, 得到总时间复杂度大致是$O(m\log m)+O(n)+O(\frac{n}{\sqrt{m}}\log(\frac{n}{\sqrt{m}}))$. 我们的目的是通过调整$m$和$n$的相对关系使得总体复杂度中第一项和第三项的贡献小于第二项, 我们选取$m=\sqrt{n}$, 带入之后发现, 第一项为$O(\sqrt{n}\log n)$, 第三项为$O(n^{3/4}\log n)$, 这两项都比$n$小, 所以仍然是第二项占主导地位. 因此, 当$m=\sqrt{n}$时, 总时间复杂度为$O(n)$.

### 错误率上界

那么我们如何得到该算法错误率的上界呢? 这个算法在三种情况下会失败:

1. $E_1$: 有太多元素比$b$小
2. $E_2$: 有太多元素比$\bar{b}$大
3. $E_3$: 子数组$C$太大

我们可以利用上面提到的Union Bounds来计算失败概率的上界. 有$Pr[E_1\cup E_2\cup E_3]\leq Pr[E_1]+Pr[E_2]+Pr[E_3]$. 由于$E_1$和$E_2$是对称的, 所以有$Pr[E_1]+Pr[E_2]+Pr[E_3]=2Pr[E_1]+Pr[E_3]$. 所以现在问题的关键就是如何bounding $Pr[E_1]$和$Pr[E_3]$. 