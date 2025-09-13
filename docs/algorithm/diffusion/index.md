---
title: Diffusion
comments: true
---

# Diffusion[^1]

由于李宏毅教授的资料已经讲得非常好, 所以直接参考它的视频.

## 第一集

讲了DDPM有一点匪夷所思的地方, 一个比较high-level的介绍.

<div style="position: relative; padding: 30% 45%;">
<iframe style="position: absolute; width: 100%; height: 100%; left: 0; top: 0;" src="https://www.youtube.com/embed/ifCDXFdeaaM?si=cmtm6KelmnGPuHTZ" frameborder="yes" scrolling="no" allowfullscreen="true"></iframe>
</div>

## 第二集

### 回顾一下VAE

最大似然估计其实和最小KL散度是等价的. 也就是说, 假设我们从真实世界采样了一些照片$X=\{x_1, x_2, ..., x_N\}$, $p_{\text{data}(x_i)}$表示第$i$张图片在真实世界中的分布, $p_{\theta}(x_i)$表示第$i$张图片在VAE的解码器输出结果中的分布. 那么根据最大似然估计, $p_{\theta}(x_i)$应该较大, 也就是说, $\theta^*=\argmax_{\theta}\prod_{i=1}^N p_{\theta}(x_i)$. 只要满足了这个等式, 那么真实世界这些照片的分布就和解码器输出结果中这些照片的分布的KL散度很小.

那么, 我们如何解出$\theta^*=\argmax_{\theta}\prod_{i=1}^N p_{\theta}(x_i)$呢? 其中的一个最关键的点就是求出$p_{\theta}(x_i)$. emmmmm, 首先, $p_{\theta}(x_i)=\int_z p(z)p_{\theta}(x_i|z)dz$, 在这里面, $p(z)$是没有问题的, 一般是从一个很简单的分布中采样, 但是$p_{\theta}(x_i|z)$, ..., 这我们有点束手无策, 怎么办?

1. 第一种方法: $G(z)$是解码器输出的图片, 我们可以假设$G(z)=x_i$的时候, $p_{\theta}(x_i|z)$为$1$, 其余的时候为$0$, 问题是很多时候, $G(z)\neq x_i$, 我们很难采样到$z$使得$G(z)=x_i$, 这不太现实.
2. 第二种方法, $G(z)$是解码器输出的一个高斯分布的均值, 当这个均值越接近$x_i$的时候, $p_{\theta}(x_i|z)$自然就越高, 可以写为$p_{\theta}(x_i|z)\propto \exp(-||G(z)-x_i||_2)$.

现在, 我们已经知道了$p_{\theta}(x_i|z)$和某个东西成正比, $p(z)$也知道了, 我们是不是可以求$p_{\theta}(x_i)=\int_z p(z)p_{\theta}(x_i|z)dz$了呢? 问题是, 这玩意是个积分, 要解决这个问题, 有两种方法:

1. 全局先验蒙特卡洛采样法. 简单来说, 就是从$p(z)$中抽出随机样本$z_1, ..., z_?$, 然后缩小$||G(z)-x_i||_2$, 把这个积分转成平均, 但是这种在全局先验中计算得到的$||G(z)-x_i||_2$往往比较大, 因为很多$G(z_?)$都无法输出和$x_i$相似的均值, 那么, 我们怎么缩小这个采样范围呢? 用后验蒙特卡洛采样法
2. 后验蒙特卡洛采样法. 请见视频19:26. **后验蒙特卡洛采样法相当于把采样位置从全局先验$p(z)$缩到更符合当前样本$x_i$的近似后验$q_{\phi}(z|x_i)$, 极大的缩小采样范围.** 最大化$p_{\theta}(x_i)$, 等价于最大化的是一个证据下届(ELBO): $E_{q_{\phi}(z|x_i)}[\log (\frac{p_{\theta}(x_i, z)}{q_{\phi}(z|x_i)})]=E_{q_{\phi}(z|x_i)}[\log p_{\theta}(x_i|z)]-KL(q_{\phi}(z|x_i)||p(z))$, $z$的分布是确定的, $q_{\phi}(z|x_i)$的分布也是确定的, 所以第二项有解析解. 对于第一项, 由于我们设定了解码器输出一个高斯分布的均值, 所以有$p_{\theta}(x_i|z)\propto \exp(-||G(z)-x||_2)\Rightarrow \log p_{\theta}(x_i|z)\propto -||G(z)-x_i||_2$, 所以要最大化ELBO, 重构误差$||G(z)-x_i||$要尽量小, 而这个时候是从$q_{\phi}(z|x_i)$中蒙特卡洛采样出来的$z$, 而不是从全局先验$p(z)$中采样, 缩小了采样范围, $||G(z)-x_i||_2$较小的几率大大增加.

???+ tip "为什么不直接算出真实后验$p(z|x_i)$"

    简单的来说, 我们算不出来, 因为根据贝叶斯公式, 有$p(z|x_i)=\frac{p_{\theta}(x_i|z)p(z)}{\int_z p_{\theta}(x_i|z)p(z)dz}$, 也就是说, 如果我们要求出这个真实后验, 我们首先要知道问题的结果$\int_z p_{\theta}(x_i|z)p(z)dz$, 而我们本身就是在解决这个问题$\int_z p_{\theta}(x_i|z)p(z)dz$...

### 搬到Diffusion上来

**Diffusion去噪的思想和VAE编码器干的事如出一辙, 给我的感觉只不过是在VAE的基础上从一个采样变成了多次迭代采样, 有多层潜变量**, $p_{\theta}(x_{t-1}|x_t)\propto -\exp(||G(x_t)-x_{t-1}||_2)$, $G(x_t)$是去噪预测的$x_{t-1}$的均值, 只不过, 不是从$z$中采样, 而是从上一次的结果中采样. 假设去噪/加噪的过程总共有$T$步, 那么, $p_{\theta}(x_0)=\int_{x_1: x_T}p(x_T)p_{\theta}(x_{T-1}|x_T)...p_{\theta}(x_{t-1}|x_t)...p_{\theta}(x_0|x_1)dx_1:x_T$, 和VAE类似, 我们要最大化是$p_{\theta}(x_0)$, 同样的, 使用ELBO, 要最大化的是$E_{q_(x_1: x_T|x_0)}[\log(\frac{p_{\theta}(x_0: x_T)}{q_(x_1: x_T|x_0)})]$, 有没有感觉和VAE的思路很像...

<div style="position: relative; padding: 30% 45%;">
<iframe style="position: absolute; width: 100%; height: 100%; left: 0; top: 0;" src="https://www.youtube.com/embed/73qwu77ZsTM?si=qykCPsUxkVCKTl_7" frameborder="yes" scrolling="no" allowfullscreen="true"></iframe>
</div>

## 第三集

我们知道, 在VAE里面, $q_{\phi}(z|x_i)$其实就是让编码器输出一个近似真实后验的特定均值和方差的高斯分布, 那Diffusion或者说DDPM里面我们怎么得到$q(x_1: x_T|x_0)$呢?

### 如何加噪

和VAE不同的是, Diffusion的后验分布不需要编码器去预测, 它产生的过程是定死的, 所以没有参数$\phi$. 我们定义$x_t=\sqrt{1-\beta_t}x_{t-1}+\sqrt{\beta_t}\epsilon$, $\epsilon\sim \mathcal{N}(0, \mathcal{I})$, $\{\beta\}$是一些已经确定好的超参数, $q(x_1:x_T|x_0)$可以看作是一条马尔科夫链, $q(x_1: x_T|x_0)=q(x_1|x_0)q(x_2|x_1)...q(x_T|x_{T-1})$.

### 多次加噪简化为单次加噪

我们有$x_1=\sqrt{1-\beta_1}x_0+\sqrt{\beta_1}\epsilon_1$, $x_2=\sqrt{1-\beta_2}x_1+\sqrt{\beta_2}\epsilon_2$, $\epsilon_1$, $\epsilon_2$是分别从一个标准正态分布中独立采样的. 我们把$x_1$代入$x_2$的表达式, 得到$x_2=\sqrt{1-\beta_2}\sqrt{1-\beta_1}x_0+\sqrt{1-\beta_2}\sqrt{\beta_1}\epsilon_1+\sqrt{\beta_2}\epsilon_2$, 后面两项可以简化成只采样一次$\epsilon$, 得到$x_2=\sqrt{1-\beta_2}\sqrt{1-\beta_1}x_0+\sqrt{1-(1-\beta_2)(1-\beta_1)}\epsilon$. 所以, 按照这过程, 我们可以写出$x_t=\sqrt{1-\beta_1}...\sqrt{1-\beta_t}x_0+\sqrt{1-(1-\beta_1)...(1-\beta_t)}\epsilon$. 为了简单起见, $\alpha_t=1-\beta_t$, $\bar{\alpha}_t=\alpha_1\alpha_2...\alpha_t$, 上面的式子就可以写为$x_t=\sqrt{\bar{\alpha}_t}x_0+\sqrt{1-\bar{\alpha}_t}\epsilon$. 这就说明, 从$x_t$到$x_0$, 我们其实只要做一次采样就行了, 效果上和多次采样是一样的, 我们可以从原始图片$x_0$一步得到$x_t$

### ELBO

我们要最大化证据下界:

$$
E_{q(x_1: x_T|x_0)}[\log(\frac{p_{\theta}(x_0: x_T)}{q(x_1: x_T|x_0)})]
$$

经过一堆推导之后, 我们发现上面这个式子可以拆解为:

$$
\mathbb{E}_{q(x_1\mid x_0)}\!\left[\log p_{\theta}(x_0\mid x_1)\right]
-\mathrm{KL}\!\left(q(x_T\mid x_0)\,\|\,p(x_T)\right)
-\sum_{t=2}^{T}\mathbb{E}_{q(x_t\mid x_0)}\!\left[
    \mathrm{KL}\!\left(q(x_{t-1}\mid x_t,x_0)\,\|\,p_{\theta}(x_{t-1}\mid x_t)\right)
\right]
$$

我们需要找到一个最佳的$\theta$, 最大化这一坨东西, 其中第二项$\mathrm{KL}\!\left(q(x_T\mid x_0)\,\|\,p(x_T)\right)$是和模型的参数无关的, 不用管. 关键就是第一项和第三项, 它们俩的计算过程比较类似, 所以只讲第三项. $q(x_{t-1}|x_t, x_0)=\frac{q(x_t|x_{t-1})q(x_{t-1}|x_0)}{q(x_t|x_0)}$, 分子分母中的三项根据定义都是已知的, 代入, 硬推之后, 得到$q(x_{t-1}|x_t, x_0)$还是一个高斯分布, 均值为$\frac{\sqrt{\bar{\alpha}_{t-1}}\,\beta_t x_0+\sqrt{\alpha_t}\,(1-\bar{\alpha}_{t-1})\,x_t}{1-\bar{\alpha}_t}$, 方差为$\frac{1-\bar{\alpha}_{t-1}}{1-\bar{\alpha}_t}\,\beta_t I$

### 去噪网络的目标

OK, 现在, 我们要最小化$q(x_{t-1}|x_t, x_0)$和$p_{\theta}(x_{t-1}|x_t)$的KL散度. 注意, $p_{\theta}(x_{t-1}|x_t)$的分布是由去噪网络预测出来的, 在DDPM中, 去噪网络预测分布的方差是人为固定的(当然也有工作是变化的). $q(x_{t-1}|x_t, x_0)$的均值是$\frac{\sqrt{\bar{\alpha}_{t-1}}\,\beta_t x_0+\sqrt{\alpha_t}\,(1-\bar{\alpha}_{t-1})\,x_t}{1-\bar{\alpha}_t}$, 自然而然的, 既然方差是没法动的, **那这个去噪网络的目标就是让它预测的均值尽量靠近$\frac{\sqrt{\bar{\alpha}_{t-1}}\,\beta_t x_0+\sqrt{\alpha_t}\,(1-\bar{\alpha}_{t-1})\,x_t}{1-\bar{\alpha}_t}$以减小KL散度**, 现在, 我们的问题就简化为了下面的这张图:

<figure markdown='1' id='fig'>
![](http://img.ricolxwz.asia/6963b310027e3d66714988e98c36aab5.webp#only-light){ loading=lazy width='800' }
![](http://img.ricolxwz.asia/6963b310027e3d66714988e98c36aab5_inverted.webp#only-dark){ loading=lazy width='800' }
</figure>

进一步的, 由于我们知道$x_t$和$x_0$的关系, $\frac{x_t-\sqrt{1-\bar{\alpha}_t}\,\epsilon}{\sqrt{\bar{\alpha}_t}} = x_{0}$, 我们可以把均值里面的$x_0$替换成$x_t$的形式, 推导, 得到$\frac{\sqrt{\bar{\alpha}_{t-1}}\,\beta_t x_0+\sqrt{\alpha_t}\,(1-\bar{\alpha}_{t-1})\,x_t}{1-\bar{\alpha}_t}=\frac{\sqrt{\bar{\alpha}_{t-1}}\,\beta_t \frac{x_t-\sqrt{1-\bar{\alpha}_t}\,\epsilon}{\sqrt{\bar{\alpha}_t}}+\sqrt{\alpha_t}\,(1-\bar{\alpha}_{t-1})\,x_t}{1-\bar{\alpha}_t}= \frac{1}{\sqrt{\alpha_t}}\left(x_t - \frac{1-\alpha_t}{\sqrt{1-\bar{\alpha}_t}}\epsilon\right)$, 所以, 我们修改一下上面的图:

<figure markdown='1' id='fig'>
![](http://img.ricolxwz.asia/9a617728f8c7014e5a42d2327e029717.webp#only-light){ loading=lazy width='800' }
![](http://img.ricolxwz.asia/9a617728f8c7014e5a42d2327e029717_inverted.webp#only-dark){ loading=lazy width='800' }
</figure>

你会发现, 除了$\epsilon$其余的都是固定的, 所以网络唯一需要预测的部分其实就是$\epsilon$.

<div style="position: relative; padding: 30% 45%;">
<iframe style="position: absolute; width: 100%; height: 100%; left: 0; top: 0;" src="https://www.youtube.com/embed/m6QchXTx6wA?si=4q7X_PR1BYOKdKGM" frameborder="yes" scrolling="no" allowfullscreen="true"></iframe>
</div>

## 第四集

### 为啥要再加一个噪声

DDPM算法:

```
x_T ~ N(0, I)
for t = T, …, 1 do
    if t > 1 then
        z ~ N(0, I)
    else
        z = 0
    end if
    x_{t-1} = (1 / √α_t) * [ x_t − (1 − α_t) / √(1 − 𝛼̄_t) * ε_θ(x_t, t) ] + σ_t · z
end for
return x_0
```

根据DDPM, 其实去噪网络预测的只里面没有直接取平均值$\frac{1}{\sqrt{\alpha_t}}\left(x_t - \frac{1-\alpha_t}{\sqrt{1-\bar{\alpha}_t}}\epsilon\right)$, 而是在这个平均值的基础上额外加了一个噪声. 这是为啥呢? 其实这个和大模型中的思路比较像, 加入这个噪声相当于做beam search, 相当于在产生的分布中采了一次样.

<div style="position: relative; padding: 30% 45%;">
<iframe style="position: absolute; width: 100%; height: 100%; left: 0; top: 0;" src="https://www.youtube.com/embed/67_M2qP5ssY?si=Zz4NlEx02zSuFMxH" frameborder="yes" scrolling="no" allowfullscreen="true"></iframe>
</div>

[^1]: Hung-yi Lee (导演). (2023, 四月 16). 【生成式AI】Diffusion Model 原理剖析 [Video recording]. https://www.youtube.com/watch?v=67_M2qP5ssY
