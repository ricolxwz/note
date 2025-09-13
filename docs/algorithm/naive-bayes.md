---
title: 朴素贝叶斯
comments: true
---

## 贝叶斯理论

给定一个假设Hypothesis, H和证据Evidence, E. 那么在出现了证据E的情况下, H的概率为$P(H|E)=\frac{P(E|H)P(H)}{P(E)}$.

如给出一捆花🌷, 🌹, 🌸的一些特征即证据E, 如颜色, 茎长. 推测假设H是一朵玫瑰🌹的可能性:

- $P(H|E)$: 后验概率, 又叫作条件概率, 是我们知道证据后某一事件的可能性, 如给出颜色, 茎长后, 是玫瑰的概率
- $P(H)$: 先验概率, 是我们知道证据前某一事件的可能性, 如不给出任何颜色, 茎长, 是玫瑰的概率
- $P(E|H)$: 后验概率, 又叫作条件概率, 是我们知道证据后某一事件的可能性, 如玫瑰之后, 是红色, 长茎的概率
- $P(E)$: 先验概率, 是我们知道证据前某一事件的可能性, 如不给出是不是玫瑰, 是红色, 长茎的概率

## 朴素贝叶斯算法 {#nb-algorithm}

朴素贝叶斯算法用于解决分类问题, 依赖的是贝叶斯理论, 在这个基础上还包含了两层假设:

1. 独立性: 在知道所属类的情况下, 所有的属性(特征)两两之间都是独立的, 即假设我们有两个属性A和B, 他们用于预测某个类别C, 如果属性A和属性B是独立的, 那么在给定类别C的情况下, 属性A的取值不会影响属性B的取值. 即$P(A,B|C)=P(A|C)\times P(B|C)$
2. 同等重要: 所有的属性都是同等重要的

从这里, 我们可以看出, 朴素贝叶斯算法之所以被称为"朴素", 或者"天真", 是因为它的假设基本上都是天真的, 不实际的, 但是这些假设能够使算法更加简单, 并且往往能够取得较好的结果.

假设我们有一些天气数据, 从这些数据(证据)中推导出假设"能玩游戏"还是"不能玩游戏":

| outlook  | temp. | humidity | windy | play |
|----------|-------|----------|-------|------|
| sunny    | hot   | high     | false | no   |
| sunny    | hot   | high     | true  | no   |
| overcast | hot   | high     | false | yes  |
| rainy    | mild  | high     | false | yes  |
| rainy    | cool  | normal   | false | yes  |
| rainy    | cool  | normal   | true  | no   |
| overcast | cool  | normal   | true  | yes  |
| sunny    | mild  | high     | false | no   |
| sunny    | cool  | normal   | false | yes  |
| rainy    | mild  | normal   | false | yes  |
| sunny    | mild  | normal   | true  | yes  |
| overcast | mild  | high     | true  | yes  |
| overcast | hot   | normal   | false | yes  |
| rainy    | mild  | high     | true  | no   |

首先, 需要计算在已知特征的情况下, 假设新的一天的天气为sunny, cool, high, true, 分别对应$E_1, E_2, E_3, E_4$, 对于每一个类(假设)都要计算他们的后验概率, 如在这个例子中, 是$P(yes|E)$和$P(no|E)$. 根据贝叶斯理论, $P(yes|E)=\frac{P(E|yes)P(yes)}{P(E)}, P(no|E)=\frac{P(E|no)P(no)}{P(E)}$. 那么, 我们如何计算$P(E|yes)$和$P(E|no)$呢? 这里, 我们就用到了假设1, 即$P(E|yes)=P(E_1|yes)P(E_2|yes)P(E_3|yes)P(E_4|yes)$, $P(E|no)=P(E_1|no)P(E_2|no)P(E_3|no)P(E_4|no)$. 代入上面的式子, 可以得到$P(yes|E)=\frac{P(E_1|yes)P(E_2|yes)P(E_3|yes)P(E_4|yes)P(yes)}{P(E)}, P(no|E)=\frac{P(E_1|no)P(E_2|no)P(E_3|no)P(E_4|no)P(no)}{P(E)}$. 分子的部分可以直接从训练数据中得到, 分母的部分都是$P(E)$, 由于我们只是要比较$P(yes|E)$和$P(no|E)$, 所以没有必要算出分母, 具体的计算过程就不在这里写了, 得到的结果是$P(yes|E)=\frac{0.0053}{P(E)}, P(no|E)=\frac{0.0206}{P(E)}$. 由于$P(no|E)>P(yes|E)$, 所以朴素贝叶斯预测的sunny, cool, high, true的play选项为no.

另一个例子见[图](https://img.ricolxwz.cn/df558f7e1e5c65c1e36402b2b41bfa7e.png).

### 零频问题 {#zero-frequency}

在上述分类问题中, 对于一个属性值(特征值)至少在每一个类别(play=yes, play=no)中都出现过一次. 如果sunny只出现在play=no中, 从未出现在play=yes中, 那么, 就会有$P(yes|E)=\frac{P(E_1|yes)P(E_2|yes)P(E_3|yes)P(E_4|yes)P(yes)}{P(E)}=0$, 因为$P(E_1|yes)=0$. 这意味着任何含有属性值为sunny的天气情况都会被归类到play=no, 完全忽略其他值的影响.

为了解决这个问题, 需要用到拉普拉斯平滑技术: 在计算$P(E_i|yes)$的时候, 用到以下公式, $P(E_i|yes)=(count(E_i)+1)/(count(yes)+m)$, 对于$P(E_i|no)$也是同样的, 其中$m$为该属性$E_i$可能取值的数量, 如对于outlook, 可能的取值有$3$种, 当零频的时候, $count(E_i)$等于$0$.

### 缺失值问题 {#missing-values}

两种情况, 新样本中某些属性缺失, 不要在计算p(E|yes)**和**计算p(E|no)的时候包括那个缺失值的属性, 如没有outlook则不要包含$p(outlook|yes)$和$p(outlook|no)$; 表中的某些属性值缺失, 则不要将缺失值纳入计数, 如在yes下, outlook列中有一个缺失值, 则直接跳过, 不用管.

### 数值属性朴素贝叶斯 {#numeric-nb}

现在, 试想如果温度和湿度是数值的话, 如何对play的结果做出分类呢?

即我们如何计算$P(E_1|yes)$, $P(E_2|yes)$, $P(E_1|no)$, ...? 我们假设数值符合正态分布或者高斯分布, 以正态分布为例, 使用概率函数, 参数为期望$\mu$和标准差, standard deviation $\sigma$: $f(x)=\frac{1}{\sigma\sqrt{2\pi}}e^{-\frac{(x-\mu)^2}{2\sigma^2}}$. 其中期望$\mu=\frac{\sum_{i=1}^n x_i}{n}$, 标准差$\sigma=\sqrt{\frac{\sum_{i=1}^n(x_i-\mu)^2}{n-1}}$.

以属性温度为例, 温度是一个连续的值, 我们可以将某一个温度的概率密度作为乘子. 如$f(temp=66|yes)=\frac{1}{6.2\sqrt{2\pi}}e^{-\frac{(66-73)^2}{2\times 6.2^2}}$, 其中$\mu=73$, 表示气温在分类为yes下的期望(均值), $\sigma=6.2$, 表示气温在分类为yes下的标准差.

其他类似, 有了这些值, 就可以计算$P(yes|E)=\frac{\frac{2}{9}\times 0.034\times 0.0221\times \frac{3}{9}\times\frac{9}{14}}{P(E)}=\frac{0.000036}{P(E)}$, $P(no|E)=\frac{\frac{3}{5}\times 0.0279\times 0.038\times \frac{3}{5}\times\frac{5}{14}}{P(E)}=\frac{0.000137}{P(E)}$, 得到$P(no|E)>P(yes|E)$, 所以预测的分类为play=no.
