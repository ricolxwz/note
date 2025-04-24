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

### 搬到Diffusion上来

**Diffusion去噪的思想和VAE编码器干的事如出一辙, 给我的感觉只不过是在VAE的基础上从一个采样变成了多次迭代采样**, $p_{\theta}(x_{t-1}|x_t)\propto -\exp(||G(x_t)-x_{t-1}||_2)$, $G(x_t)$是去噪预测的$x_{t-1}$的均值, 只不过, 不是从$z$中采样, 而是从上一次的结果中采样. 假设去噪/加噪的过程总共有$T$步, 那么, $p_{\theta}(x_0)=\int_{x_1: x_T}p(x_T)p_{\theta}(x_{T-1}|x_T)...p_{\theta}(x_{t-1}|x_t)...p_{\theta}(x_0|x_1)dx_1:x_T$, 和VAE类似, 我们要最大化是$p_{\theta}(x_0)$, 同样的, 使用ELBO, 要最大化的是$E_{q_{\phi}(x_1: x_T|x_0)}[\log(\frac{p_{\theta}(x_0: x_T)}{q_{\phi}(x_1: x_T|x_0)})]$, 有没有感觉和VAE的思路一模一样...

<div style="position: relative; padding: 30% 45%;">
<iframe style="position: absolute; width: 100%; height: 100%; left: 0; top: 0;" src="https://www.youtube.com/embed/73qwu77ZsTM?si=qykCPsUxkVCKTl_7" frameborder="yes" scrolling="no" allowfullscreen="true"></iframe>
</div>

## 第三集

<div style="position: relative; padding: 30% 45%;">
<iframe style="position: absolute; width: 100%; height: 100%; left: 0; top: 0;" src="https://www.youtube.com/embed/m6QchXTx6wA?si=iObkaKbQkNiOfgsV" frameborder="yes" scrolling="no" allowfullscreen="true"></iframe>
</div>

[^1]: Hung-yi Lee (导演). (2023, 四月 16). 【生成式AI】Diffusion Model 原理剖析 [Video recording]. https://www.youtube.com/watch?v=67_M2qP5ssY
