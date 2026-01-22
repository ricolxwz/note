---
title: CTC
comments: false
---

## 代入

语音识别的核心逻辑是将音频流切分为若干短窗口并预测字符, 但是这一过程面临着**对齐**的巨大挑战, 即如何准确判定每个字符在语音信号中的位置和长度. 对齐问题的难点在于: 1. 人工标注不可行: 在海量ASR数据中, 手动标注字符的语音位置极度耗时, 不切实际; 2. 规则方法失效: 由于不同人的语速差异很大即使是同一个人的某些音可能差异很大, 并且会有停顿和噪音, 采用固定长度窗口的规则无法在实际场景中生效.

## 核心

在CTC框架下, 目标是建立从输入序列$X=[x_1,x_2,...,x_T]$到输出序列$Y=[y_1,y_2,...,y_U]$的映射. 训练阶段由于帧与字符间缺乏显式对齐, 需计算所有能坍缩为目标$Y$的可行路径概率之和, 即利用条件概率$p(Y|X)$计算Loss来优化ASR模型. 而在推理阶段, 目标则是寻找概率最大的唯一序列$Y^*=\arg\max_Y p(Y|X)$, 通过对每帧预测结果进行去重和删除blank操作(也是坍缩), 从路径分布中提取出最准确的文本结果. 可以训练的是ASR模型, 而CTC是指导训练的方向和准则, 在训练过程中, 只有模型的参数在发生变化, 而CTC的算法准则(即坍缩)是始终固定不变的. 

??? example "简单例子"

    为了能够对CTC有一个较浅的理解, 我们先举个例子: 

    假设$T=2$, 识别目标为"A", 词表为$\{blank, A\}$.

    |时间步|$P(blank)$|$P(A)$|
    |:---|:---|:---|
    |$t=1$|0.3|0.7|
    |$t=2$|0.4|0.6|

    CTC通过"去重"和"删除blank"将路径映射到标签. 在本例中, 长度为2且坍缩结果为"A"的合法路径如下:

    * **Path1**: $(A, A) \rightarrow A$. 概率为$0.7 \times 0.6=0.42$.
    * **Path2**: $(A, blank) \rightarrow A$. 概率为$0.7 \times 0.4=0.28$.
    * **Path3**: $(blank, A) \rightarrow A$. 概率为$0.3 \times 0.6=0.18$.

    所有合法路径概率之和为$P(A|X)=0.42+0.28+0.18=0.88$. 
    $$Loss=-\ln(0.88) \approx 0.128$$

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.cn/ebc913fed238fdde3ff0543c9f9d7734.svg#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.cn/ebc913fed238fdde3ff0543c9f9d7734_inverted.svg#only-dark){ loading=lazy width='800' }
</figure>

## 算法

### 训练: 前向算法

CTC分数$p(Y|X)$本质是所有将输入$X$映射到标签序列$Y$的可行路径概率之和. 由于直接枚举路径不可行, 需通过前向动态规划计算. 为处理对齐中的空白与重复字符, 首先构建扩展序列$Z$: 在原始序列$Y$的首尾及字符间插入空白符$\epsilon$. 例如$Y=[a, b]$, 则$Z=[\epsilon, a, \epsilon, b, \epsilon]$. 若$Y$长度为$U$, 则$Z$长度为$2U+1$. 定义前向变量$\alpha_{s,t}$: 表示在时刻$t$, 路径停在扩展序列$Z$的第$s$个符号$z_s$上的概率总和. 注意: "停在"指当前时刻对齐的符号, 不同于最终"坍缩"后的输出.

时刻$t$的状态$\alpha_{s,t}$仅能由时刻$t-1$的三个位置转移而来:

1. 保持($s$): 当前符号被延续($\alpha_{s, t-1}$).
2. 移步($s-1$): 从前一个符号切换过来($\alpha_{s-1, t-1}$).
3. 跳跃($s-2$): 跨过中间的$\epsilon$直接切换($\alpha_{s-2, t-1}$).

并非所有情况都允许"跳跃". 转移方程如下:

$$
\alpha_{s,t} = p(z_s|X_t) \cdot 
\begin{cases} 
\alpha_{s,t-1} + \alpha_{s-1,t-1} & \text{Case A: 禁止跳跃} \\ 
\alpha_{s,t-1} + \alpha_{s-1,t-1} + \alpha_{s-2,t-1} & \text{Case B: 允许跳跃} 
\end{cases}
$$

判别逻辑:

* Case A (禁止跳跃):

    * $z_s = \epsilon$: 必须按序经过, 无法跳过前一个字符直达$\epsilon$.
    * $z_s = z_{s-2}$: 例如$Z=[\dots, a, \epsilon, a, \dots]$, 若某条路径$\pi = [..., a, a, ...]$, 从第一个$a$直接跳到第二个$a$, 两个$a$在解码时会合并成一个$a$, 导致错误. 必须经过$\epsilon$以分隔重复字符. 例如, 如果ASR模型的其中一条路径是$(h, e, l, l, o)$, 那么由于在两个l之间没有插入blank, 这条规则告诉我们, 这种情况下是不能跳跃的, 所以该路径无效, 像$(h, e, l, \epsilon, l, o)$这样的路径就是有效的. 

    <figure markdown='1' id='fig'>
    ![](https://img.ricolxwz.cn/aba35fc39dabea57bf62a41aa05698b9.webp#only-light){ loading=lazy width='250' }
    ![](https://img.ricolxwz.cn/aba35fc39dabea57bf62a41aa05698b9_inverted.webp#only-dark){ loading=lazy width='250' }
    </figure>

* Case B (允许跳跃):

    $z_s \neq \epsilon$ 且 $z_s \neq z_{s-2}$: 例如$Z=[\dots, a, \epsilon, b, \dots]$, 允许从$a$跨过$\epsilon$直接变至$b$.

    <figure markdown='1' id='fig'>
    ![](https://img.ricolxwz.cn/8544ac6bd34c7280ab6d0e95532b86fa.webp#only-light){ loading=lazy width='220' }
    ![](https://img.ricolxwz.cn/8544ac6bd34c7280ab6d0e95532b86fa_inverted.webp#only-dark){ loading=lazy width='220' }
    </figure>

一条路径在时间$T$结束的时候, 必须走完$Z$中对应$Y$的全部标签(并且重复字符之间要有$\epsilon$), 否则坍缩结果就不可能是$Y$. 设$Z$的长度为$S=2U+1$, 则$z_S$是末尾的$\epsilon$, $z_{S-1}$是$Y$的最后一个字符. 那么在时刻$T$结束的时候, 能够坍缩为$Y$的路径只能有两种结尾: 

1. 停在最后一个字符$z_{S-1}$: 说明最后一个字符在最后一帧被对齐输出, 末尾没有$\epsilon$ 
2. 停在末尾$\epsilon$, 说明最后一个字符已经在更早的某一帧输出完了, 最后若干帧都对齐到$\epsilon$

除此之外, 如果$T$时刻停在$s\leq S-2$, 那么就意味着最后一个标签还没走到, 坍缩输出会缺少尾巴, 不可能等于$Y$. 因此, 终止条件就是把这两类正确完成的路径概率相加: $p(Y\mid X)=\alpha_{S,T}+\alpha_{S-1,T}.$

整个流程如图所示:

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.cn/638027976f9236e046e8befb827acb8d.svg#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.cn/638027976f9236e046e8befb827acb8d_inverted.svg#only-dark){ loading=lazy width='800' }
<figcaption>由于序列开头和结尾的$\epsilon$是可选的, 因此存在两个起始节点和两个终止节点. 总概率是两个终止节点概率之和. </figcaption>
</figure>



### 推理: 束搜索

给定输入$X$, 我们需要输出最可能的路径. 在所有可能的输出$Y$里面, 找一个条件概率$p(Y|X)$最大的, 作为最终的预测$Y^*$. $Y^*=\arg\max_Y p(Y\mid X)$. 序列$Y$的长度会很长, 无法把所有的$Y$都枚举一遍, 需要近似搜索策略. 我们可以使用贪心算法, 在每一步都选择那个概率最大的$a_t$, 不考虑组合的效果概率最大: $A^*=\arg\max_A \prod_{t=1}^{T} p_t(a_t\mid X)$. 

正式由于Greedy算法不考虑组合效果最优, 会面临一些问题, 它只会输出在每一步概率都最大的路径, 最终的概率可能小于多条路径相加的结果. 它得到的不一定是全局最优解. 

??? example "贪婪算法的问题"

    假设 \(T=4\), 每一帧模型给的概率都是: 

    - \(p(b)=0.38\)(最大)
    - \(p(a)=0.37\)
    - \(p(\epsilon)=0.25\)

    **greedy** 每帧都选最大的 b, 于是得到路径 \(A=[b,b,b,b]\), 其概率: 

    \[
    p([b,b,b,b])=0.38^4=0.0209
    \]

    对应输出 \(Y="b"\). 

    但输出 \(Y="a"\) 可以由很多条路径得到, 比如只有一个位置是 a, 其余是 ε: 

    - \([a,\epsilon,\epsilon,\epsilon]\)
    - \([\epsilon,a,\epsilon,\epsilon]\)
    - \([\epsilon,\epsilon,a,\epsilon]\)
    - \([\epsilon,\epsilon,\epsilon,a]\)

    每条概率都是: 

    \[
    0.37\times 0.25^3=0.00578
    \]

    四条加起来: 

    \[
    p(Y="a") \ge 4\times 0.00578 = 0.0231
    \]

    你看: **虽然任何一条"a 的路径"都不如 [b,b,b,b] 大, 但它们加起来反而更大**, 所以真正最可能的输出应是 **"a"**, 而 greedy 会输出 **"b"**. 

一个更好的方法是使用束搜索. 不像Greedy search只能保留一个, 它会保留多个可能的结果. 实际上Greedy search就是候选集长度为1的Beam search, 我们能通过增大候选集的长度, 得到较好的结果, 但是仍然不是全局最优解. 其思想是每次循环我们都从候选集中所有的元素都索索一遍, 然后我们通过排序来维持候选集的长度不变. 

以下是一个普通的束搜索例子:
<figure markdown='1' id='fig'>
![](https://img.ricolxwz.cn/27ac1c2f49f563ec1e3c2f3125379e03.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.cn/27ac1c2f49f563ec1e3c2f3125379e03_inverted.webp#only-dark){ loading=lazy width='800' }
</figure>

但是普通的Beam search无法解决多个路径对应相同$Y$的问题, 不过不需要担心, 我们只需要在每一步计算分数的时候合并所有相同的元素就可以了, 如下图所示.  

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.cn/cc7a82a82952f8f9cf5c4d3bf4188abc.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.cn/cc7a82a82952f8f9cf5c4d3bf4188abc_inverted.webp#only-dark){ loading=lazy width='800' }
</figure>

不过我们需要注意的是, 有时候合并的元素需要重新分开, 比如$a\epsilon$和$aa$虽然都会被合并为$a$, 但是如果下一步遇到$a$的话则$a\epsilon$就会变成$aa$. 
