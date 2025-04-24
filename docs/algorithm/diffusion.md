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

最大似然估计其实和最小KL散度是等价的. 也就是说, 假设我们从真实世界采样了一些照片$X=\{x_1, x_2, ..., x_N\}$, $P_{\text{data}(x_i)}$表示第$i$张图片在真实世界中的分布, $P_{\theta}(x_i)$表示第$i$张图片在VAE的解码器输出结果中的分布. 那么根据最大似然估计, $P_{\theta}(x_i)$应该较大, 也就是说, $\theta^*=\argmax_{\theta}\prod_{i=1}^N P_{\theta}(x_i)$. 只要满足了这个等式, 那么真实世界这些照片的分布就和解码器输出结果中这些照片的分布的KL散度很小.

那么, 我们如何解出$\theta^*=\argmax_{\theta}\prod_{i=1}^N P_{\theta}(x_i)$呢? 其中的一个最关键的点就是求出$P_{\theta}(x_i)$. emmmmm, 首先, $P_{\theta}(x_i)=\int_z P(z)P_{\theta}(x_i|z)dz$, 在这里面, $P(z)$是没有问题的, 一般是从一个很简单的分布中采样, 但是$P_{\theta}(x_i|z)$, ..., 这我们有点束手无策, 怎么办? 第一种方法: $G(z)$是解码器输出的图片, 我们可以假设$G(z)=x_i$的时候, $P_{\theta}(x_i|z)$为$1$, 其余的时候为$0$, 问题是很多时候, $G(z)\neq x_i$, 我们很难采样到$z$使得$G(z)=x_i$, 这不太现实. 第二种方法, $G(z)$是解码器输出的一个高斯分布的均值, 当这个均值越接近$x_i$的时候, $P_{\theta}(x_i|z)$自然就越高, 可以写为$P_{\theta}(x_i|z)\propto \exp(-||G(z)-x||_2)$.

现在, 我们已经知道了$P_{\theta}(x_i|z)$和某个东西成正比, $p(Z)$也知道了, 我们是不是可以求$P_{\theta}(x_i)=\int_z P(z)P_{\theta}(x_i|z)dz$了呢? 问题是, 这玩意是个积分, 我们得穷举所有的$z$. 要解决这个问题, 有两种方法: (1) 蒙特卡洛采样法. 简单来说, 就是从$P(z)$中抽出随机样本, 把这个积分转成平均. (2) ELBO. 用这个, 我们不需要采样$z$. 怎么推导? 请见视频19:26. 我们要最大化的是一个证据下届(ELBO): $E_{q(z|x_i)}[\log (\frac{P(x_1, z)}{q(z|x_i)})]$.

### 搬到Diffusion上来

**Diffusion去噪的思想和VAE编码器干的事如出一辙, 给我的感觉只不过是在VAE的基础上从一个采样变成了多次迭代采样**, $P_{\theta}(x_{t-1}|x_t)\propto -\exp(||G(x_t)-x_{t-1}||_2)$, $G(x_t)$是去噪预测的$x_{t-1}$的均值, 只不过, 不是从$z$中采样, 而是从上一次的结果中采样. 假设去噪/加噪的过程总共有$T$步, 那么, $P_{\theta}(x_0)=\int_{x_1: x_T}P(x_T)P_{\theta}(x_{T-1}|x_T)...P_{\theta}(x_{t-1}|x_t)...P_{\theta}(x_0|x_1)dx_1:x_T$, 和VAE类似, 我们要最大化是$P_{\theta}(x_0)$, 同样的, 使用ELBO, 要最大化的是$E_{q(x_1: x_T|x_0)}[\log(\frac{P(x_0: x_T)}{q(x_1: x_T|x_0)})]$, 有没有感觉和VAE的思路一模一样...

<div style="position: relative; padding: 30% 45%;">
<iframe style="position: absolute; width: 100%; height: 100%; left: 0; top: 0;" src="https://www.youtube.com/embed/73qwu77ZsTM?si=qykCPsUxkVCKTl_7" frameborder="yes" scrolling="no" allowfullscreen="true"></iframe>
</div>

[^1]: Hung-yi Lee (导演). (2023, 四月 16). 【生成式AI】Diffusion Model 原理剖析 [Video recording]. https://www.youtube.com/watch?v=67_M2qP5ssY
