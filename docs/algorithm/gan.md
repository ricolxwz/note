---
title: 生成对抗网络
comments: true
---

# GAN[^1]

## 核心思想

GAN的基本思想是, 首先我们有一个"生成器", Generator, 其实就是一个神经网络, 或者是更简单的理解, 他就是一个函数. 输入一组向量, 经由生成器, 产生一组目标矩阵(如果要生成图片, 那么矩阵就是图片的像素集合). 它的目的就是使得自己造样本的能力尽可能强, 强到什么程度呢, 强到判别网络无法判断我是真样本还是假样本. 同时我们还有一个"判别器", 判别器的目的是判别出来一张图片它是来自真实样本集还是假样本集. 假如输入的是真样本, 网络输出就接近1, 输入的是假样本, 网络输出接近0, 那么很完美, 达到了很好判别的目的.

那为什么需要这两个组件呢? GAN在结构上受到了博弈论中的二人[零和博弈](https://zh.wikipedia.org/zh-hans/零和博弈)(即二人的利益之和为0, 一方的所得是另一方的所失)的启发, 系统由一个生成模型(G)和一个判别模型(D)构成. G捕捉真实数据样本的潜在分布, 并生成新的数据样本; D是一个二分类器, 判别输入是真实数据还是生成的样本. 生成器和判别器均可以采用深度神经网络. GAN的优化过程是一个极小极大博弈问题, 优化目标是达到[纳什平衡](https://wiki.mbalib.com/wiki/纳什均衡).

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/e84be7219f469337dba9997250d8fbeb.webp#only-light){ loading=lazy width='500' }
![](https://img.ricolxwz.io/e84be7219f469337dba9997250d8fbeb_inverted.webp#only-dark){ loading=lazy width='500' }
</figure>

首先, 我们有两个关键组件, 生成器(G)和判别器(D), 一开始G-V1生成了一些手写体的图片, 然后丢给D-V1, 同时我们也需要把真实图片也送给D-V1, 然后D-V1根据自己的"经验"(其实就是当前的网络参数)结合真实图片数据, 来判断G-V1生成的图片是否符合要求.

很明显, 第一代的G是无法骗过D的, 那怎么办? 那G-V1就"进化"为G-V2, 以此生成更加高质量的图片来骗过D-V1. 然后为了识别进化后生成更高质量图的图片的G-V2, D-V1也升级为了D-V2... 就这样一直迭代下去, 直到生成网络G-Vn生成的假样本进去了判别网络D-Vn以后, 判别网络给出的结果是一个接近0.5的值, 也就是说明判别不出来了, 这个就是那是平衡了. 这时候回去看生成的图片, 发现它们真的很逼真了.

那么具体它们是怎么互相学习的呢? 首先是D的学习:

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/96f9f3dd69247dea84c045d5217213d5.webp#only-light){ loading=lazy width='500' }
![](https://img.ricolxwz.io/96f9f3dd69247dea84c045d5217213d5_inverted.webp#only-dark){ loading=lazy width='500' }
</figure>

首先, 我们随机初始化生成器G, 并输入一组随机向量, 以此产生一些图片, 并把这些图片标注为0(假图片). 同时把来自真实分布中的图片标注为1(真图片). 两者同时丢到判别器D中, 以此来训练判别器. 实现当输入是真图片的时候, 判别器给出的是接近于1的分数, 而输入假图片的时候, 判别器给出接近于0的低分.

接着是G的学习:

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/d1eca8cec0744fe585304e99a3db549b.webp#only-light){ loading=lazy width='500' }
![](https://img.ricolxwz.io/d1eca8cec0744fe585304e99a3db549b_inverted.webp#only-dark){ loading=lazy width='500' }
</figure>

对于生成网络, 目的是生成尽可能逼真的样本. 所以在训练生成网络的时候, 我们需要联合判别网络才能达到训练的目的. 也就是说, 通过将两者串接起来的方式来产生误差从而得以训练生成网络. 步骤是: 我们通过随机向量(噪声数据)经由生成网络产生一组假数据, 并将这些假数据都标记为1. 然后将这些假数据输入到判别网络里面, 判别器肯定会发现这些标榜为真实数据(标记为1)的输入都是假数据(给出低分), 这样就产生了误差, 在训练这个串接的网络的时候, 一个很重要的操作是不要让判别网络的参数发生变化, 只是把误差一直传, 传到生成网络那块后更新网络的参数. 这样就完成了对生成网络的训练了.

在完成了生成网络的训练之后, 我们又可以产生新的假数据去训练判别网络了. 我们把这个过程称作为单独交替训练. 同时要定义一个迭代次数, 交替迭代到一定次数之后停止即可.

## 数学推导

### 最大似然估计

最大似然估计, 就是利用已知的样本结果信息, 反推最具有可能性(最大概率)导致这些样本结果出现的模型参数值. 样本从某一个客观存在的模型中抽样得来, 然后根据样本来计算该模型的数学参数, 即模型已定, 参数未知.

假设一组含有$m$个样本的数据集$X = \{x^{(1)}, x^{(2)}, x^{(3)}, \ldots, x^{(m)}\}$, 该数据集中的样本是从某个现实的数据生成分布$p_{data}(x)$中独立采样生成的. 这个现实的数据生成分布的具体形式和参数是未知的, 换句话说, 我们完全无法了解这个分布, 只能通过已有的数据来近似理解和建模它.

令$p_{model}(x;\theta)$是一个由参数$\theta$(未知)确定在相同空间上的概率分布, 也就是说, 我们的目的就是找到一个合适的$\theta$使得$p_{model}(x;\theta)$尽可能地去接近$p_{data}(x)$.

我们利用真实分布$p_{data}(x)$中生成出来的数据集$X$去估算总体概率为$L(\theta) = \prod_{i=1}^{m} p_{model}(x^{(i)}; \theta)$. 🤭 又是Diffusion, VAE里面的基操.

然后我们计算出使得$L$最大的这个参数$\theta_{ML}$, 也就是说, 对$\theta$的最大似然估计被定义为:

$$\theta_{ML} = \arg \max_{\theta} p_{model}(X; \theta) = \arg \max_{\theta} \prod_{i=1}^{m} p_{model}(x^{(i)}; \theta)$$

$$p_{model}(X; \theta) \rightarrow f(x^{(1)}, x^{(2)}, x^{(3)}, ..., x^{(m)} | \theta)$$

$$\prod_{i=1}^{m} p_{model}(x^{(i)}; \theta) \rightarrow f(x^{(1)}|\theta) \cdot f(x^{(2)}|\theta) \cdot f(x^{(3)}|\theta) ... f(x^{(m)}|\theta)$$

为什么要让$L$最大? 可以这样想: 我们从真实的分布中取得了这些数据$X=\{x^{(1)}, x^{(2)}, x^{(3)}, \ldots, x^{(m)}\}$, 那为什么会偏偏在真实分布中取得这些数据呢? 是因为取得这些数据的概率更大一些, 而此时我们做的就是人工设计的一个由参数$\theta$控制的分布$p_{model}(x;\theta)$来去拟合真实分布$p_{data}(x)$, 换句话说, 我们通过一组数据$X$去估算第一个参数$\theta$使得这组数据$X$在人工设计的分布中$p_{model}(x;\theta)$被抽样出来的可能性最大, 所以让$L$最大就感觉合乎情理了. 😂 搞懂VAE和Diffusion之后再看这个真的很简单.

多个概率的乘积会因为很多原因不便于计算. 例如, 计算中很可能会出现指数下溢(概率值通常介于0和1之间, 多个概率相乘的结果会越来与小, 计算机用有限的位数来表示浮点数, 所能表示的最小正数有一个下限, 当计算结果小于这个下限的时候, 就会发生下溢, 近似为0). 为了得到一个便于计算的等价优化问题, 我们观察到似然对数不会改变其$\arg \max$, 于是将成绩转换为了便于计算的求和形式(基操):

$$\theta_{ML} = \arg \max_{\theta} \sum_{i=1}^{m} \log p_{model}(x^{(i)}; \theta)$$

但是上述直接使用样本的对数似然总和作为优化目标可能会因为样本的不同而有较大的波动, 尤其是在样本量$m$较小的情况下, 优化可能会受到噪声的影响较大. 为此, 由于重新缩放代价函数的时候$\argmax$不会改变, 可以引入期望对似然函数进行平均化(其实就是一个正则化操作). 随着样本量的增大, 样本的均值会趋近于总体均值, 即经验分布$\hat{p}_{data}(x)$会越来越接近真实分布$p_{data}(x)$. 通过引入期望作为目标, 能够获得以下优点: 平滑优化(期望操作有助于减少由样本的随机性或噪声引起的波动), 减少过拟合(避免了模型过于拟合有限样本的波动, 提升了估计的泛化能力).

### KL散度

一种解释最大似然估计的观点是将其看作是最小化训练集上的经验分布$\hat{p}_{data}$和模型分布$p_{model}(x;\theta)$之间的差异, 两者之间的差异程度可以用KL散度来度量, KL散度的含义是分布保留了多少原始分布的信息.

关于KL散度, 在信息论中[提到](/general/information-theory/what-is-information/#KL散度)过.

KL散度在这里被定义为$D_{KL}(\hat{p}_{data}||p_{model})=E_{x\sim \hat{p}_{data}}[\log \hat{p}_{data}(x)-\log p_{model}(x)]$. 注意到, 这里的公式其实是和在信息论中所写的公式有一点出入, 这是因为期望和加权求和的等价性.

对于离散分布来说, 期望可以表示为随机变量取值的加权平均, 其中权重是对应取值的概率. 即$E_{X \sim p}[f(X)] = \sum_{x} p(x) f(x)$. 在KL散度的计算中, 可以应用上述的思想: $D_{\text{KL}}(P || Q) = E_{x \sim P} \left[ \log \frac{P(x)}{Q(x)} \right] = \sum_{x} P(x) \log \frac{P(x)}{Q(x)}$.

???+ tip "Tip"

    对于连续的分布来说, 也有相似的公式:

    $\mathbb{E}{X \sim p}[f(X)] = \int_x p(x) f(x) \, dx$


左边这一项$E_{x\sim \hat{p}_{data}}[\log \hat{p}_{data}(x)]$仅涉及到数据的原始分布, 和模型是无关的. 这意味着当训练模型最小化KL散度的时候, 我们只需要最小化右边的这个部分, 即$-E_{x\sim \hat{p}_{data}}[\log p_{model}(x)]$.

结合上面对最大似然的解释, 开始推导$\theta_{ML}$:

(注意到, 第4行是把期望展开为前一项然后再减去一个和$\theta_{ML}$无关的项(不会影响到$\theta_{ML}$的取值, 所以可以随便加), 而后面变形为KL散度做准备)

$$\begin{align*}
\theta_{ML} &= \argmax_{\theta} \prod_{i=1}^m p_{\text{model}}(x^{(i)}; \theta) \\
            &= \argmax_{\theta} \log \prod_{i=1}^m p_{\text{model}}(x^{(i)}; \theta)
            = \argmax_{\theta} \sum_{i=1}^m \log p_{\text{model}}(x^{(i)}; \theta) \\
            &\approx \argmax_{\theta} \mathbb{E}_{x \sim \hat{p}_{\text{data}}} [\log p_{\text{model}}(x; \theta)] \\
            &= \argmax_{\theta} \int_x \hat{p}_{\text{data}}(x) \log p_{\text{model}}(x; \theta) \, dx
            - \int_x \hat{p}_{\text{data}}(x) \log \hat{p}_{\text{data}}(x) \, dx \\
            &= \argmax_{\theta} \int_x \hat{p}_{\text{data}}(x) [\log p_{\text{model}}(x; \theta) - \log \hat{p}_{\text{data}}(x)] \, dx \\
            &= \argmax_{\theta} -\int_x \hat{p}_{\text{data}}(x)
            \log \frac{\hat{p}_{\text{data}}(x)}{p_{\text{model}}(x; \theta)} \, dx \\
            &= \arg\min_{\theta} KL(\hat{p}_{\text{data}}(x) \| p_{\text{model}}(x; \theta))
\end{align*}$$

最小化KL散度其实就是最小化分布之间的交叉熵, 任何一个由负对数似然函数组成的损失都是定义在训练集$X$上的经验分布$\hat{p}_{data}$和定义在模型上的概率分布$p_{model}$之间的交叉熵. 例如, 均方误差就是定义在经验分布和高斯模型之间的交叉熵.  最优$\theta$在最大化似然函数和最小化KL散度的时候是相同的.

最小化KL散度==最大似然估计, 基操, VAE, Diffusion都是这样

那么要怎么找到一个比较好的$p_{model}(x;\theta)$呢? 传统的生成模型(例如GMM或者其他统计模型)无法很好地处理复杂的高维数据分布, 而生成对抗网络(GAN)引入了神经网络来建模数据分布, 从而生成更加复杂和逼真的数据, 所以$p_{model}(x;\theta)$在GAN里面是一个神经网络产生的分布(和VAE里面的解码器差不多).

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/2dc8d471d0117149df27695828605bcf.webp#only-light){ loading=lazy width='500' }
![](https://img.ricolxwz.io/2dc8d471d0117149df27695828605bcf_inverted.webp#only-dark){ loading=lazy width='500' }
</figure>

假设$z$是从高斯分布$p_{prior}(z)$中采样而来, 然后通过一个神经网络(也就是G)得到$x$, 这个$x$满足另一个分布$p_{model}(x;\theta)$, 然后我们要找到这个分布的参数$\theta$使得它和真实分布越相近越好, 这里的$p_{model}(x;\theta)$可以写作: $p_G(x) = \int p_{prior}(z) I(G(z) = x) dz$, 这个公式的含义是, 生成的样本$x$是通过输入噪声$z$生成的, 而$z$是一个已知的先验分布$p_{prior}(z)$中采样得到的, 生成$x$的概率是所有可能的$z$贡献的概率总和, $I(G(z)=x)$是指示函数, 当$G(z)$的输出等于$x$的时候, $I(G(z)=x)$的值为$1$, 否则为$0$, 它的作用是筛选出哪些$z$能生成特定的$x$.

难点在于, 在现实中, 如GMM等模型, 由于$G(z)$的复杂性, 基本上很难找到$x$的分布$p_{model}(x;\theta)$, 而GAN的作用就是通过神经网络调整参数$\theta$, 让G产生的分布尽量接近真实分布(😅怎么反复地说).

### JS散度

JS散度(Jensen-Shannon Divergence)衡量了两个概率分布的相似度, 基于KL散度的变体, 解决了KL散度非对称的问题, 也就是说, 在KL散度下, $D_{KL}(\hat{p}_{data}||p_{model})\neq D_{KL}(p_{model}||\hat{p}_{data})$. JS散度是对称的, 其取值在$0$到$1$之间, 定义如下:

$$JSD(P \| Q) = \frac{1}{2} KL\left(P \| \frac{P + Q}{2}\right) + \frac{1}{2} KL\left(Q \| \frac{P + Q}{2}\right)$$

KL散度和JS散度在度量的时候还有一个问题, 如果两个分布离得很远, 完全没有重叠的时候, 那么散度的值是没有意义的. 这在学习算法中是比较致命的, 这就意味着在这一点的梯度为$0$了, 梯度消失了(所以怎么初始化这个$G$很重要).

## 算法推导

首先, 来重申一下重要的参数和名词.

- 生成器, G
    - G是一个函数, 输入是$z$, 输出是$x$
    - 给定一个先验分布$p_{prior}(z)$和一个反映生成器G的分布$p_{G}(x)$, $p_G(x)$对应的就是$p_{model}(x;\theta)$
- 判别器, D
    - D也是一个函数, 输入是$x$, 输出是一个标量
    - 主要是评估$p_G(x)$和$p_{data}(x)$之间到底有多少不同, 也就是他们之间的交叉熵

现给出一条目标公式:

$$V = \mathbb{E}_{x \sim p_{\text{data}}} \left[ \log D(x) \right] + \mathbb{E}_{x \sim p_G} \left[ \log (1 - D(x)) \right]$$

这里的$D(x)$表示的是判别器的输出, 如果$D(x)=1$, 则判别器会认为$x$是完全真实的, 如果$D(x)=0$, 判别器会认为$x$是完全假的. 这个公式的直觉是, 对于真实样本, 希望$D(x)$尽可能接近$1$, 越接近$1$, 损失趋近于$0$(从负方向趋近); 对于生成样本, 希望$D(x)$尽可能接近$0$, 损失趋近于$0$(从负方向趋近), 所以需要最大化$V$.

这条公式衡量的是$p_G(x)$和$p_{data}(x)$之间的不同程度. 对于GAN, 做法是, 给定G, 找到一个D^*^使得$V(G, D)$最大, 即$\max_D V(G, D)$, 直觉上理解为: 生成器固定的时候, 就是通过判别器尽可能地将生成图片和真实图片区别开来, 也就是需要最大化两者之间的交叉熵: $D^*=\argmax_D V(G, D)$

然后, 要是固定D, 使得$\max_D V(G, D)$最小的这个G代表的就是最好的生成器. 所以G的终极目标就是找到G^*^, 找到了G^*^我们就找到了分布$p_G(x)$对应的参数$\theta_G$: $G^*=\arg \min_G\max_D V(G, D)$

上面的步骤给出了我们期望优化的目标, 现在按照步骤对目标进行推导.

### 寻找最好的D^*^

首先是第一步, 给定G, 找到一个最好的D^*^使得$V(G, D)$最大, 即求$\max_D V(G, D)$.

$$\begin{align*}
V &= \mathbb{E}_{x \sim p_{\text{data}}} \left[ \log D(x) \right] + \mathbb{E}_{x \sim p_G} \left[ \log (1 - D(x)) \right] \\
  &= \int_x p_{\text{data}}(x) \log D(x) \, dx + \int_x p_G(x) \log (1 - D(x)) \, dx \\
  &= \int_x \left[ p_{\text{data}}(x) \log D(x) + p_G(x) \log (1 - D(x)) \right] \, dx
\end{align*}$$

对于每一个固定的$x$而言, 我们只要让$p_{\text{data}}(x) \log D(x) + p_G(x) \log (1 - D(x))$最大, 那么积分后的值$V$也是最大的. 由于这个时候, $G$的权重是固定的, 所以$p_G$是固定的, 同时$p_{\text{data}}$以及$x$也是固定的. 唯一的变量是$D(x)$, 我们令$D=D(x)$, 我们有$f(D)=p_{\text{data}}(x) \log D + p_G(x) \log (1 - D)$, 令$f'(D)=0$, 有:

$$
D^*=\frac{p_{\text{data}(x)}}{p_{\text{data}}(x)+p_G(x)}
$$

所以我们就找到了在给定$x$以及$G$的条件下, 最好的$D$要满足的条件.

这个时候, 求$\max_D V(G, D)$就比较容易了, 直接把前面的$D^*$代入进去:

$$
\begin{aligned}
\max_D V(G,D)
&=V(G,D^{*})\\
&=\mathbb{E}_{x\sim p_{\text{data}}}\!\bigl[\log D^{*}(x)\bigr]+\mathbb{E}_{x\sim p_G}\!\bigl[\log\!\bigl(1-D^{*}(x)\bigr)\bigr]\\
&=\mathbb{E}_{x\sim p_{\text{data}}}\!\left[\log\frac{p_{\text{data}}(x)}{p_{\text{data}}(x)+p_G(x)}\right]
  +\mathbb{E}_{x\sim p_G}\!\left[\log\frac{p_G(x)}{p_{\text{data}}(x)+p_G(x)}\right]\\
&=\int_x p_{\text{data}}(x)\log\frac{p_{\text{data}}(x)}{p_{\text{data}}(x)+p_G(x)}\,dx
  +\int_x p_G(x)\log\frac{p_G(x)}{p_{\text{data}}(x)+p_G(x)}\,dx\\
&= \text{中间省略...} \\
&=-2\log2+2\,\mathrm{JSD}\!\bigl(p_{\text{data}}(x)\,\Vert\,p_G(x)\bigr)
\end{aligned}
$$

由于$\mathrm{JSD}(p_{\text{data}}(x)||p_G(x))$的取值范围是从$0$到$\log 2$, 那么$\max_D V(G, D)$的范围是从$0$到$-2\log 2$.

### 寻找最好的G*

这是第二步, 给定$D$, 找到一个$G^*$使得$\max_D V(G, D)$最小, 即求$\min_G \max_D V(G, D)$:

\[
\begin{aligned}
G^{*}&=\arg\min_{G}\,\max_{D}\,V(G,D)\\
     &=\arg\min_{G}\,\max_{D}\Bigl(-2\log 2+2\,\mathrm{JSD}\bigl(p_{\text{data}}(x)\,\|\,p_{G}(x)\bigr)\Bigr)
\end{aligned}
\]

根据上式, 使得最小化$G$需要满足的条件是:

$$
p_{\text{data}(x)}=p_G(x)
$$

直观上我们也知道, 当生成器的分布和真实数据分布一样的时候, 就能让$\max_D V(G, D)$最小. 至于如何让生成器的分布不断拟合真实数据的分布, 在训练的过程中我们可以使用梯度下降来计算:

$$
\theta_G := \theta_G - \eta \frac{\partial\max_{D} V(G,D)}{\partial\theta_G}
$$

## 算法总结

1. 给定一个初始的$G_0$
2. 找到$D^*_0$, 最大化$V(G_0, D)$
3. 使用梯度下降更新$G$的参数$\theta_G := \theta_G - \eta \frac{\partial\max_{D} V(G,D^*_0)}{\partial\theta_G}$, 得到$G_1$
4. 找到$D^*_1$, 最大化$V(G_1, D)$
5. 使用梯度下降更新$G$的参数$\theta_G := \theta_G - \eta \frac{\partial\max_{D} V(G,D^*_1)}{\partial\theta_G}$, 得到$G_2$
6. 循环...

## 实际过程中的算法推导

前面的推导都是基于理论上的推导, 实际上前面的推导是有限制的, 回顾以下在推导的过程中, 其中的函数$V$是:

$$\begin{align*}
V &= \mathbb{E}_{x \sim p_{\text{data}}} \left[ \log D(x) \right] + \mathbb{E}_{x \sim p_G} \left[ \log (1 - D(x)) \right] \\
  &= \int_x p_{\text{data}}(x) \log D(x) \, dx + \int_x p_G(x) \log (1 - D(x)) \, dx \\
  &= \int_x \left[ p_{\text{data}}(x) \log D(x) + p_G(x) \log (1 - D(x)) \right] \, dx
\end{align*}$$

我们当时说的是$p_{\text{data}}(x)$是给定的, 因为真实分布是客观存在的, 不以人的意志为转移, 而因为我们把$G$固定住了, 所以$p_G$也是固定的. 但是现在有一个问题就是, 样本空间是无穷大的, 也就是说我们无法获得它的真实期望. 直接用Monte Carlo抽样估计大法: 从真实分布$p_{\text{data}}$中抽样$\{x^{(1)}, x^{(2)}, ..., x^{(m)}\}$, 从生成器生成的分布$p_G$中抽样$\tilde{x}^{(1)}, \tilde{x}^{(2)}, ..., \tilde{x}^{(m)}$, 那么上面的函数就应该改写为:

\[
\tilde{V}=\frac{1}{m}\sum_{i=1}^{m}\log D\!\bigl(x^{(i)}\bigr)
        +\frac{1}{m}\sum_{i=1}^{m}\log\bigl(1-D(\tilde{x}^{(i)})\bigr)
\]

这就是为啥我们在核心思想中说要训练$D$要$G$先生成几个负样本然后再从真实分布中取几个正样本的原因. 将上面的式子写为一个交叉熵损失:

\[
L=-(\tilde{V}=\frac{1}{m}\sum_{i=1}^{m}\log D\!\bigl(x^{(i)}\bigr)
        +\frac{1}{m}\sum_{i=1}^{m}\log\bigl(1-D(\tilde{x}^{(i)})\bigr))
\]

通过这个交叉熵损失就可以训练$D$.

## 实际过程中的算法总结

1. 初始化一个由$\theta_D$决定的$D$和一个由$\theta_G$决定的$G$
2. 循环迭代训练过程
    1. 训练判别器的过程, 循环$k$次
       1. 从真实分布$p_{\text{data}}(x)$中抽样$m$个正例$\{x^{(1)}, x^{(2)}, ..., x^{(m)}\}$
       2. 从先验分布$p_{\text{prior}}(x)$中抽样$m$个噪声向量$\{z^{(1)}, z^{(2)}, ..., z^{(m)}\}$
       3. 利用生成器$G$从输入噪声向量生成$m$个反例$\tilde{x}^{(1)}, \tilde{x}^{(2)}, ..., \tilde{x}^{(m)}$
       4. 最大化$\tilde{V}=\frac{1}{m}\sum_{i=1}^{m}\log D\!\bigl(x^{(i)}\bigr)+\frac{1}{m}\sum_{i=1}^{m}\log\bigl(1-D(\tilde{x}^{(i)})\bigr)$, 更新$\theta_D:=\theta_D-\eta \nabla \tilde{V}(\theta_D)$
    2. 训练生成器的过程, 循环$1$次
        1. 从先验分布$p_{\text{prior}}$中抽样$m$个噪声向量$\{z^{(1)}, z^{(2)}, ..., z^{(m)}\}$
        2. 最小化$\tilde{V}=\frac{1}{m}\sum_{i=1}^{m}\log D\!\bigl(x^{(i)}\bigr)+\frac{1}{m}\sum_{i=1}^{m}\log\bigl(1-D(G(z^i))\bigr)$, 更新$\theta_G:=\theta_G-\eta \nabla \tilde{V}(\theta_G)$

## 最小化V以训练G的经验操作

在训练生成器的过程中, 实际上我们想要最小化的并不是$E_{x\sim p_G}[\log (1-D(x))]$, 因为如果最小化这个, $\log (1-D(x))$一开始就是一个很接近于$0$的负数, 导致产生的梯度较小, 训练速度较慢, 但是如果改为最小化$E_{x\sim p_G}[-\log (D(x))]$, 一开始是一个很大的整数, 那么产生的梯度就较大, 便于训练.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/6349b54a8fd51a2b2a87dff5e9f80f74.webp#only-light){ loading=lazy width='500' }
![](https://img.ricolxwz.io/6349b54a8fd51a2b2a87dff5e9f80f74_inverted.webp#only-dark){ loading=lazy width='500' }
</figure>

## GAN训练的问题

### 训练不稳定

训练原始GAN是一件非常困难的事情. 难主要体现在训练过程中可能并不收敛, 训练出的生成器根本不能产生有意义的内容等方面. 另一方面, 虽然说我们优化的目标函数是JSD, 它应该能体现出两个分布的距离. 并且这个距离最好一开始比较大, 后来随着训练$G$过程的深入, 这个距离应该慢慢变小才比较好. 但实际上这只是我们理想中的情况.

在实际应用中我们会发现, D的Loss Function非常容易变成$0$, 而且在后面的训练中也已知保持着$0$, 很难发生改变. 这个现象是为什么呢? 其实这个道理很简单. 虽然说JSD能够衡量两个分布之间的距离, 但实际上有两种情况可能会导致JSD永远判定两个分布距离"无穷大" 从而使得Loss Fonction永远是0:

\[
\max_{D}V(G,D)
=-2\log 2
+\underbrace{2\,\mathrm{JSD}\bigl(P_{\text{data}}(x)\,\|\,P_G(x)\bigr)}_{2\log 2}
=0
\o

产生这种现象的情况主要有两种:

1. 判别器$D$太强, 过拟合

    <figure markdown='1' id='fig'>
    ![](https://img.ricolxwz.io/20094716bda5e41ab69ade05c8241c36.webp#only-light){ loading=lazy width='300' }
    ![](https://img.ricolxwz.io/20094716bda5e41ab69ade05c8241c36_inverted.webp#only-dark){ loading=lazy width='300' }
    </figure>

    上图蓝色和橙色分别是两个分布, 我们能发现分布之间确实有一些重叠, 所以按理来说JSD不应该是$\log 2$ . 但由于我们是采样一部分样本(图中的圆点)进行训练, 所以当判别器足够"强"的时候, 就很有可能找到一条分界线强行将两类样本分开, 从而让两类样本之间被认为完全不存在重叠. 我们可以尝试传统的正则化方法(regularization等), 也可以减少模型的参数让它变得弱一些. 但是我们训练的目的就是要找到一个"很强"的判别器, 我们在实际操作中是很难界定到底要将判别器调整到什么水平才能满足我们的需要: 既不会太强, 也不会太弱. 还有一点就是我们之前曾经认为这个判别器应该能够测量JSD, 但它能测量JSD的前提就是它必须非常强, 能够拟合任何数据. 这就跟我们"不想让它太强"的想法有矛盾了, 所以实际操作中用regularization等方法很难做到好的效果.

2. 数据本身的特性

    一般来说, 生成器产生的数据都是一个映射到高维空间的低维流型. 而低维流型之间本身就"不是那么容易"产生重叠的. 如下图所示.

    <figure markdown='1' id='fig'>
    ![](https://img.ricolxwz.io/4f67c7a2945489fb8fa894e748b366f4.webp#only-light){ loading=lazy width='300' }
    ![](https://img.ricolxwz.io/4f67c7a2945489fb8fa894e748b366f4_inverted.webp#only-dark){ loading=lazy width='300' }
    </figure>

    解决的方法有两种, 一种是给数据添加噪声, 让生成器和真实分布的低维流形更容易重叠在一起, 如下图所示.

    <figure markdown='1' id='fig'>
    ![](https://img.ricolxwz.io/a77eed271091ba5d3f1fbf006748ad35.webp#only-light){ loading=lazy width='300' }
    ![](https://img.ricolxwz.io/a77eed271091ba5d3f1fbf006748ad35_inverted.webp#only-dark){ loading=lazy width='300' }
    </figure>

    这个方法的缺点在于, 我们的目标是训练准确的数据(例如高清图等), 加入噪声会影响我们生成数据的质量, 一个简单的做法是让噪声的幅度随着时间缩小, 不过操作起来比较困难.

    除此之外还有另一种方法. 虽然JSD的效果不好, 那干脆就把它换了呗, 哪怕两个分布一直毫无重叠, 都能够提供一个不同的连续的距离的度量, 这是WGAN的工作.

### 模式崩塌

请见[这里](/dicts/mode-collapse/).

训练中可能遇到的另一个问题: 所有的输出都一样! 这个现象被称为Mode Collapse. 这个现象产生的原因可能是由于真实数据在空间中很多地方都有一个较大的概率值, 但是我们的生成模型没有直接学习到真实分布的特性. 为了保证最小化损失, 它会宁可永远输出一样但是肯定正确的输出, 也不愿意尝试其他不同但可能错误的输出. 也就是说, 我们的生成器有时可能无法兼顾数据分布的所有内部模式, 只会保守地挑选出一个肯定正确的模式.

假设我们要学习的真实分布是这个样子:

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/5e013f9a1986d51f076bfb156b66af1d.webp#only-light){ loading=lazy width='300' }
![](https://img.ricolxwz.io/5e013f9a1986d51f076bfb156b66af1d_inverted.webp#only-dark){ loading=lazy width='300' }
</figure>

而我们设想的学习过程应该是这个样子:

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/2b98445d236baf686d2c620cf5d901bb.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/2b98445d236baf686d2c620cf5d901bb_inverted.webp#only-dark){ loading=lazy width='800' }
</figure>

但是实际上却事与愿违:

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/b31e399acd905b22889956cd2460f70c.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/b31e399acd905b22889956cd2460f70c_inverted.webp#only-dark){ loading=lazy width='800' }
</figure>

模型在学习到一个真实分布的模式之后, 并不会继续学习其他模式, 而是尝试立刻将这个模式忘掉, 转而去学习其他模式. 并且在迭代过程中不断在各个模式中跳跃. 但是关于这个情况产生的原因, 并没有太好的定论.

[^1]: 生成对抗网络——原理解释和数学推导—黄钢的部落格|Canary Blog. (不详). 从 https://alberthg.github.io/2018/05/05/introduction-gan/
