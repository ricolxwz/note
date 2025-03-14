---
title: VAE
comments: true
---

# VAE[^1]

## 基础

### 两个空间

在VAE中, 会出现两个空间. 一个是 ^^像素空间(pixel space)^^, 另一个是 ^^潜空间(latent space)^^. (1) 像素空间是我们所观测到的像素所处的空间, 用$\mathbf{x_{dog}}$来表示一幅狗的图片, 它处于$\mathbb{R}^d$的像素空间中, $\mathbf{x_{dog}}=\{x_{dog_1}, x_{dog_2}, ..., x_{dog_d}\}$, $x_{dog_i}$表示的是图$\mathbf{x_{dog}}$的第$i$个像素. 这个空间很高维, 如图片经常是由上千上百万个像素点组成的. (2) 潜空间是潜向量所处的空间, 这张图片$\mathbf{x_{dog}}$对应一个潜向量$\mathbf{z_{dog}}$, 这个空间维度相对较低, 如$\mathbb{R}^k$, 表示一个潜向量有$k$维.

### 四个分布

(1) $p(\mathbf{Z})$: 这是所有潜向量(即整个潜空间)的分布. (2) $p(\mathbf{Z}|\mathbf{X}=\mathbf{x})$: 这是给定一个任意的图片后其潜向量的分布, 如$p(\mathbf{Z}|\mathbf{X}=\mathbf{x_{dog}})$表示的是给定一张小狗的图片后其对应潜向量的分布. (3) $p(\mathbf{X}|\mathbf{Z}=\mathbf{z})$: 这是给定一个任意的潜向量后其像素向量的分布, 如$p(\mathbf{X}|\mathbf{Z}=\mathbf{z_{dog}})$表示的是给定一个含义为狗的潜向量后其对应像素向量的分布. (4) $p(\mathbf{X})$: 这是所有像素向量(即图像)在像素空间上的分布.

### 四个概率

(1) $p(\mathbf{Z}=\mathbf{z})$: 这个表示的是在未观察到任何图像的前提下的潜向量的概率. 即在潜空间中随机取, 取到$\mathbf{z}$的概率. (2) $p(\mathbf{X}=\mathbf{x})$: 这个表示的是在不依赖具体的潜向量的情况下, 随机在所有可能的图像中, 抽到$\mathbf{x}$的概率. (3) $p(\mathbf{Z}=\mathbf{z}|\mathbf{X}=\mathbf{x})$: 这个表示的是我们已经观察到某个具体的图像$\mathbf{x}$时, 该图像对应潜向量为$\mathbf{z}$的概率. (4) $p(\mathbf{X}=\mathbf{x}|\mathbf{Z}=\mathbf{z})$: 这个表示的是我们已经得知某个潜向量$\mathbf{z}$的情况下, 该潜向量对应图像为$\mathbf{x}$的概率.

### 贝叶斯理论

(1) 先验分布: 如果事件$\mathcal{A}$未发生, 由过往的经验猜测事件$\mathcal{A}$发生的概率分布; (2) 后验分布: 如果事件$\mathcal{A}$已经发生, 求事件$\mathcal{B}$发生的概率分布; (3) 似然函数: 如果事件$\mathcal{B}$已经发生, 求事件$\mathcal{A}$发生的概率分布;

## 动机

<div style="position: relative; padding: 30% 45%;">
<iframe style="position: absolute; width: 100%; height: 100%; left: 0; top: 0;" src="https://www.youtube.com/embed/qJeaCHQ1k2w?si=rpggP8B3fmXl6wFd" frameborder="yes" scrolling="no" allowfullscreen="true"></iframe>
</div>

在普通的AE中, 我们在潜空间中随机选一个潜向量, 再通过decoder生成的像素向量所代表的图片往往是没有意义的噪声, 这是因为普通AE的encoder只将输入的图片映射到了潜空间中的一个潜向量上, 所以潜空间中只有一些特定的潜向量能够重构回原图, 这会导致潜空间的"支离破碎", 其他的潜向量经过解码器后只会得到没有意义的噪声, 如潜向量1能重构图1, 潜向量2能重构图2, 但是在潜向量1和潜向量2之间的潜向量3经过decoder会得到一张没有意义的图片. 

<figure markdown='1'>
![](https://img.ricolxwz.io/092c19c9031472a566c9cd3122dba8fd.webp#only-light){ loading=lazy width='700' }
![](https://img.ricolxwz.io/092c19c9031472a566c9cd3122dba8fd_inverted.webp#only-dark){ loading=lazy width='700' }
<figcaption></figcaption>
</figure>

在VAE中的潜空间中, 大部分区域的潜向量都能重构回看起来合理的样本. 这是因为VAE的encoder会将输入的图片映射到潜空间中的一个分布上, 这个分布内的潜向量都能构建出一张和原图类似的图片, 在这些潜向量中, 某些潜向量构建出原图的概率更高, 某些潜向量构建出原图的概率较低. 假设图片1被映射到的潜空间中潜向量2...潜向量8...潜向量12这个区域内, 图片2被映射到潜空间中潜向量10...潜向量14...潜向量18的区域内, 那么如果我们从潜空间中取潜向量11, 经过decoder之后大概率得到的是图片1和图片2的融合品, 如图片1是猫, 图片2是狗, 那么出来的图片可能是带有狗鼻子的猫. 换句话说, 现在, 在这个潜空间中随机去一个点, 经过decoder都能得到一个有意义的图. 这让VAE不仅仅能够重建图片, 还能够创造新的图片, 这说明, VAE具有极其强大的泛化性能.

<figure markdown='1'>
![](https://img.ricolxwz.io/7e539da4e2d8feb1d3e1f5c973b8ad2c.webp#only-light){ loading=lazy width='300' }
![](https://img.ricolxwz.io/7e539da4e2d8feb1d3e1f5c973b8ad2c_inverted.webp#only-dark){ loading=lazy width='300' }
<figcaption></figcaption>
</figure>

<div style="position: relative; padding: 30% 45%;">
<iframe style="position: absolute; width: 100%; height: 100%; left: 0; top: 0;" src="https://www.youtube.com/embed/sV2FOdGqlX0?si=eFHyoV8bza-c6Cjj" frameborder="yes" scrolling="no" allowfullscreen="true"></iframe>
</div>

VAE在训练的时候, 往往会让这些由encoder生成的潜向量的分布往先验分布靠, 于此同时, 也不能让它们靠得太紧. (1) 为什么要往先验分布靠? 这是一个正则化的过程. 举个例子, 如果图片1被映射到潜向量2...潜向量8...潜向量12, 图片2被映射到潜向量20...潜向量24...潜向量28, 那么如果我们取潜向量15, 经过decoder生成的是无意义的图片, 这种叫做潜空间的"真空区", 这个真空区内的潜向量经过decoder之后生成的是噪声, 所以要尽量减少这种分布之间的真空区; (2) 为什么不能靠得太紧? 举个例子, 如果图片1被映射到潜向量2...潜向量8...潜向量12, 图片2被映射到潜向量3...潜向量9...潜向量13, 那么我们甚至无法找到一个合理的潜向量去重构图1或者图2. 这就是为什么VAE的损失函数里面第一部分是重构损失, 第二部分是encoder生成的潜向量分布和先验分布的KL散度.

<figure markdown='1'>
![](https://img.ricolxwz.io/843639a0a1b9f9e3e24c5a78e731bf43.webp#only-light){ loading=lazy width='600' }
![](https://img.ricolxwz.io/843639a0a1b9f9e3e24c5a78e731bf43_inverted.webp#only-dark){ loading=lazy width='600' }
<figcaption></figcaption>
</figure>

## 方法论

<div style="position: relative; padding: 30% 45%;">
<iframe style="position: absolute; width: 100%; height: 100%; left: 0; top: 0;" src="//player.bilibili.com/player.html?isOutside=true&bvid=BV1ix4y1x7MR&high_quality=1&autoplay=false&muted=false&as_wide=1" frameborder="yes" scrolling="no" allowfullscreen="true"></iframe>
</div>

### 贝叶斯公式

要得到输入图像在潜空间的分布, 等价于计算$p(\mathbf{Z}|\mathbf{X}=\mathbf{x})$, 我们想到的第一个方法是贝叶斯公式, 在很多的贝叶斯模型中, 我们想知道后验分布$p(\mathbf{Z}|\mathbf{X}=\mathbf{x})$, 使用公式可以写作:

$$p(\mathbf{Z} |\mathbf{X}=\mathbf{x}) = \frac{p(\mathbf{Z}, \mathbf{X}=\mathbf{x})}{p(\mathbf{X}=\mathbf{x})}$$

其中, $p(\mathbf{X})$可以用全概率公式计算:

$$p(\mathbf{X}=\mathbf{x})=\int _{\mathbf{z}}p(\mathbf{X}=\mathbf{x}|\mathbf{Z}=\mathbf{z})p(\mathbf{Z}=\mathbf{z})d\mathbf{z}$$ 

然而, 当$\mathbf{Z}$的维度较高的时候, 这个积分几乎无法求解, 用数值方法计算也会非常困难或者代价高昂. 正因为如此, 我们无法得到结果$p(\mathbf{X}=\mathbf{x})$然后代入到贝叶斯公式来得到$p(\mathbf{Z}|\mathbf{X}=\mathbf{x})$. 所以在实际中, 我们会借助近似方法, 如变分推断, MCMC等来绕过求解该积分的难题.

### 变分推断

变分推断的基本思想是把难以求解的$p(\mathbf{Z}|\mathbf{X}=\mathbf{x})$转化为一个可优化的问题, 具体来说, 变分推断会定义一个包含可调节参数的分布$q_{\phi}(\mathbf{Z}|\mathbf{X}=\mathbf{x})$, 称为"变分分布", 它的$\phi$是可学习的. 

在VAE中, 是通过encoder的神经网络来拟合这个分布, 我们的先验分布$p(\mathbf{Z})$是标准正态分布, 我们要让encoder生成的分布尽量贴近这个标准正态分布, 即只要让KL散度$KL(q_{\phi}(\mathbf{Z}|\mathbf{X}=\mathbf{x})\;\|\;p(\mathbf{Z}))$变小, 不管是黑猫白猫, 只要能够使它变小, 都是好的分布. 这里, 我们选择让encoder拟合一个均值为$\mathbf{\mu}_{\phi}, \mathbf{\sigma}^2_{\phi}\cdot \mathbf{I}$的正态分布, 即$q_{\phi}(\mathbf{Z}|\mathbf{X}=\mathbf{x})\sim \mathcal{N}(\mathbf{\mu}_{\phi}, \mathbf{\sigma}^2_{\phi}\cdot \mathbf{I})$. 

通过优化$\phi$来让$q_{\phi}(\mathbf{Z}|\mathbf{X}=\mathbf{x})$尽可能地逼近真实的后验分布$p(\mathbf{Z}|\mathbf{X}=\mathbf{x})$. 第一个感觉是可以使用KL散度来衡量两个分布之间的差距, 目标是最小化: 

$$KL\left(q_\phi(\mathbf{Z}|\mathbf{X} = \mathbf{x}) \;\|\; p(\mathbf{Z}|\mathbf{X} = \mathbf{x})\right)$$

然而, 直接最小化这个KL散度往往是不可行的, 因为它需要我们知道真实的后验分布$p(\mathbf{Z}|\mathbf{X}=\mathbf{x})$, 而后者本身就是未知的. 为了解决这个问题, 变分推断会通过最大化"证据下界"(Evidence Lower BOund, ELBO)的方式来等价地最小化上述的KL散度.  

### 证据下界

ELBO(Evidence Lower BOund)定义为:

$$\mathcal{L}(\phi) = \mathbb{E}_{q_\phi(\mathbf{Z}|\mathbf{X}=\mathbf{x})} \left[ \log p(\mathbf{Z}, \mathbf{X}=\mathbf{x}) - \log q_\phi(\mathbf{Z}|\mathbf{X}=\mathbf{x}) \right]$$

最大化该ELBO, 等价于最小化KL散度$KL\left(q_\phi(\mathbf{Z}|\mathbf{X} = \mathbf{x}) \;\|\; p(\mathbf{Z}|\mathbf{X} = \mathbf{x})\right)$. 以下是推导.

KL散度的定义为:

$$
\begin{aligned}
&KL\Bigl(q_\phi(\mathbf{Z}\mid \mathbf{X} = \mathbf{x}) \,\Big\|\, p(\mathbf{Z}\mid \mathbf{X} = \mathbf{x})\Bigr) \\[6pt]
&\quad= \int_{\mathbf{z}} q_\phi(\mathbf{Z}=\mathbf{z}\mid \mathbf{X} = \mathbf{x})\,
\log\!\Bigl(\frac{q_\phi(\mathbf{Z}=\mathbf{z}\mid \mathbf{X} = \mathbf{x})}{p(\mathbf{Z}=\mathbf{z}\mid \mathbf{X} = \mathbf{x})}\Bigr)
\,\mathrm{d}\mathbf{z} \\[6pt]
&\quad= \mathbb{E}_{q_\phi(\mathbf{Z}\mid \mathbf{X}=\mathbf{x})}\!\Bigl[
\log \frac{q_\phi(\mathbf{Z}\mid \mathbf{X} = \mathbf{x})}{p(\mathbf{Z}\mid \mathbf{X} = \mathbf{x})}
\Bigr]
\end{aligned}
$$


后验分布$p(\mathbf{Z}|\mathbf{X}=\mathbf{x})$根据贝叶斯公式可以写为:

$$p(\mathbf{Z} |\mathbf{X}=\mathbf{x}) = \frac{p(\mathbf{Z}, \mathbf{X}=\mathbf{x})}{p(\mathbf{X}=\mathbf{x})}$$

将它代入KL散度的分母即可得到:

$$
\begin{aligned}
&KL\bigl(q_\phi(\mathbf{Z}\mid \mathbf{X} = \mathbf{x}) \,\|\, p(\mathbf{Z}\mid \mathbf{X} = \mathbf{x})\bigr)
= \mathbb{E}_{q_\phi(\mathbf{Z}\mid \mathbf{X} = \mathbf{x})}\!\Bigl[\log \frac{q_\phi(\mathbf{Z}\mid \mathbf{X} = \mathbf{x})}{\dfrac{p(\mathbf{Z}, \mathbf{X} = \mathbf{x})}{p(\mathbf{X} = \mathbf{x})}}\Bigr] \\[4pt]
&= \mathbb{E}_{q_\phi(\mathbf{Z}\mid \mathbf{X} = \mathbf{x})}\!\Bigl[\log \frac{q_\phi(\mathbf{Z}\mid \mathbf{X} = \mathbf{x})\,p(\mathbf{X} = \mathbf{x})}{p(\mathbf{Z}, \mathbf{X} = \mathbf{x})}\Bigr] \\[4pt]
&= \mathbb{E}_{q_\phi(\mathbf{Z}\mid \mathbf{X} = \mathbf{x})}\!\Bigl[\log q_\phi(\mathbf{Z}\mid \mathbf{X} = \mathbf{x})\Bigr]
- \mathbb{E}_{q_\phi(\mathbf{Z}\mid \mathbf{X} = \mathbf{x})}\!\Bigl[\log p(\mathbf{Z}, \mathbf{X} = \mathbf{x})\Bigr]
+ \log p(\mathbf{X} = \mathbf{x}) \\[4pt]
&= \mathbb{E}_{q_\phi(\mathbf{Z}\mid \mathbf{X} = \mathbf{x})}\!\Bigl[\log q_\phi(\mathbf{Z}\mid \mathbf{X} = \mathbf{x}) - \log p(\mathbf{Z}, \mathbf{X} = \mathbf{x})\Bigr]
+ \log p(\mathbf{X} = \mathbf{x}) \\[4pt]
&= -\,\mathcal{L}(\phi)\;+\;\log p(\mathbf{X} = \mathbf{x})
\end{aligned}
$$

能直接将$\log p(\mathbf{X}=\mathbf{x})$提出的原因是, 在计算:

$$\mathbb{E}_{q_\phi(\mathbf{Z}|\mathbf{X}=\mathbf{x})} \left[ \log p(\mathbf{X} = \mathbf{x}) \right]$$

的时候, 因为$\log p(\mathbf{X}=\mathbf{x})$并不依赖于$\mathbf{Z}$, 它在积分运算中可以被视为一个常数$c$, 即: 

$$\mathbb{E}_{q_\phi(\mathbf{Z}|\mathbf{X}=\mathbf{x})} \left[ c \right] 
= \int_{\mathbf{z}} c \, q_\phi(\mathbf{Z}=\mathbf{z}|\mathbf{X}=\mathbf{x}) \, d\mathbf{z} 
= c \int_{\mathbf{z}} q_\phi(\mathbf{Z}=\mathbf{z}|\mathbf{X}=\mathbf{x}) \, d\mathbf{z} 
= c \cdot 1 = c.
$$

对KL散度的表达式进行简单的变换后, 就可以得到:

$$
\log p(\mathbf{X} = \mathbf{x}) = \mathcal{L}(\phi) + KL\bigl(q_\phi(\mathbf{Z}\mid \mathbf{X} = \mathbf{x}) \,\|\, p(\mathbf{Z}\mid \mathbf{X} = \mathbf{x})\bigr)
$$

其中, $\mathcal{L}(\phi)$就是ELBO. 由于$\log p(\mathbf{X}=\mathbf{x})$和$\phi$是无关的, 它只是一个关于图片$\mathbf{x}$的常数, 请见四个概率中的概率二. 所以最大化$\mathcal{L}(\phi)$(ELBO)会让$KL\bigl(q_\phi(\mathbf{Z}\mid \mathbf{X} = \mathbf{x}) \,\|\, p(\mathbf{Z}\mid \mathbf{X} = \mathbf{x})\bigr)$的值变小, 即最小化KL散度, 反过来, 最小化KL散度, 也就等价于让$\mathcal{L}(\phi)$变大. 即:

$$
\max_\phi \mathcal{L}(\phi) \;\iff\; \min_\phi KL\bigl(q_\phi \,\|\, p\bigr).
$$

如下图所示, 框的大小表示$\log p(\mathbf{X}=\mathbf{x})$, 不变, ELBO越大, KL散度越小.

<figure markdown='1'>
![](https://img.ricolxwz.io/edd0237538287148b1827fc06b54a318.webp#only-light){ loading=lazy width='180' }
![](https://img.ricolxwz.io/edd0237538287148b1827fc06b54a318_inverted.webp#only-dark){ loading=lazy width='180' }
<figcaption></figcaption>
</figure>

ELBO的形式如下:

$$\mathcal{L}(\phi) = \mathbb{E}_{q_\phi(\mathbf{Z}|\mathbf{X}=\mathbf{x})} \left[ \log p(\mathbf{Z}, \mathbf{X}=\mathbf{x}) - \log q_\phi(\mathbf{Z} | \mathbf{X}=\mathbf{x}) \right]$$

### 损失函数

仔细观察一下第一项, 其实我们可以再使用一次贝叶斯公式:

$$\log p(\mathbf{Z}, \mathbf{X}=\mathbf{x})=\log p_{\theta}(\mathbf{X}=\mathbf{x}|\mathbf{Z})+\log p(\mathbf{Z})$$

于是, 我们就得到了:

$$
\begin{aligned}
\mathcal{L}(\phi, \theta) &= \mathbb{E}_{q_\phi(\mathbf{Z}|\mathbf{X}=\mathbf{x})} \left[ \log p_{\theta}(\mathbf{X}=\mathbf{x}|\mathbf{Z})+\log p(\mathbf{Z}) - \log q_\phi(\mathbf{Z} | \mathbf{X}=\mathbf{x}) \right] \\
&= \mathbb{E}_{q_\phi(\mathbf{Z}|\mathbf{X}=\mathbf{x})} \left[ \log p_{\theta}(\mathbf{X}=\mathbf{x}|\mathbf{Z})\right]+\mathbb{E}_{q_\phi(\mathbf{Z}|\mathbf{X}=\mathbf{x})} \left[\log p(\mathbf{Z})\right] - \mathbb{E}_{q_\phi(\mathbf{Z}|\mathbf{X}=\mathbf{x})} \left[\log q_\phi(\mathbf{Z} | \mathbf{X}=\mathbf{x}) \right] \\
&= \mathbb{E}_{q_\phi(\mathbf{Z}|\mathbf{X}=\mathbf{x})} \left[ \log p_{\theta}(\mathbf{X}=\mathbf{x}|\mathbf{Z})\right]+\mathbb{E}_{q_\phi(\mathbf{Z}|\mathbf{X}=\mathbf{x})} \left[\log p(\mathbf{Z}) - \log q_\phi(\mathbf{Z} | \mathbf{X}=\mathbf{x}) \right]
\end{aligned}
$$

我们注意到, $\mathbb{E}_{q_\phi(\mathbf{Z}|\mathbf{X}=\mathbf{x})} \left[\log p(\mathbf{Z}) - \log q_\phi(\mathbf{Z} | \mathbf{X}=\mathbf{x}) \right]$其实就是一个KL散度的相反数: $-KL(q_{\phi}(\mathbf{Z}|\mathbf{X}=\mathbf{x})\;\|\;p(\mathbf{Z}))$, 所以, ELBO可以被重写为:

$$\mathcal{L}(\phi, \theta)=\mathbb{E}_{q_\phi(\mathbf{Z}|\mathbf{X}=\mathbf{x})} \left[ \log p_{\theta}(\mathbf{X}=\mathbf{x}|\mathbf{Z})\right]-KL(q_{\phi}(\mathbf{Z}|\mathbf{X}=\mathbf{x})\;\|\;p(\mathbf{Z}))$$

VAE的损失函数被定义为这个结果的相反数, 即$-\mathcal{L}(\phi, \theta)$, 最小化损失函数, 就是最小化$KL\left(q_\phi(\mathbf{Z}|\mathbf{X} = \mathbf{x}) \;\|\; p(\mathbf{Z}|\mathbf{X} = \mathbf{x})\right)$.

$$\mathcal{Loss}=KL(q_{\phi}(\mathbf{Z}|\mathbf{X}=\mathbf{x})\;\|\;p(\mathbf{Z}))-\mathbb{E}_{q_\phi(\mathbf{Z}|\mathbf{X}=\mathbf{x})} \left[ \log p_{\theta}(\mathbf{X}=\mathbf{x}|\mathbf{Z})\right]$$

$\mathcal{Loss}$中的第一项表示的是先验匹配KL散度, 表示的让某张图片潜向量的分布尽量往标准正态分布靠近, 防止潜空间中的真空化, 或者说是正则化. 这一项的计算公式为$\frac{1}{2}(\mathbf{\mu}_{\phi}+\mathbf{\sigma}_{\phi}^2-\log \mathbf{\sigma}_{\phi}^2-\mathbf{1})$, 这个公式的推导就不放在这里了.

$\mathcal{Loss}$中的第二项表示的是重建损失. 也就是说, 给定了一个图片$\mathbf{x}$, 重新构建出它的概率, 可以使用一个MSE损失表示$||\mathbf{x}-\mathbf{\hat{x}}||^2$, 防止不同图片潜向量的分布靠得太近, 这是一个L2项.

### 重参数化技巧

既然我们现在有了一个损失函数, 那么我们怎么进行反向传播, 以更新参数$\theta$和$\phi$呢? 我们注意到, 如果我们对encoder生成的隐向量分布直接进行采样, 这个采样的操作就是不可微的, 所以无法把梯度传回到encoder. 为什么不可微呢?

从数学上看, 如果一个操作可微, 意味着它可以被视为某个关于参数, 这里是$\phi$的连续函数, 并且能通过链式法则对其进行微分, 当我们从$q_{\phi}(\mathbf{Z}|\mathbf{X}=\mathbf{x})$里面采样的时候, 这个采样的结果不是通过一个确定的函数$f(\phi)$得到的, 即结果和$\phi$不存在一个可微函数的关系, 所以没法反向传播.

因此, 我们将采用重参数化trick, 从一个标准正态分布$\mathbf{\epsilon}\sim\mathcal{N}(\mathbf{0}, \mathbf{I})$采样, 然后通过$\mathbf{z}=\mathbf{\mu}_{\phi}+\sigma_{\phi}\odot\mathbf{\epsilon}$将其映射到encoder产生的潜向量分布上. 使得采样结果$\mathbf{z}$对$\mathbf{\mu}_{\phi}$和$\mathbf{\sigma}_{\phi}$成为一个确定而且可微的函数, 从而绕过了直接采样不可微的问题.

## 架构

<figure markdown='1'>
![](https://img.ricolxwz.io/d0c1e3e28dfb9f11ceb867b0764bfbb6.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/d0c1e3e28dfb9f11ceb867b0764bfbb6_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption></figcaption>
</figure>

VAE本质上是一个生成模型. 它的目标是使用encoder构造一个足够正则化的潜空间, 使得能够从中取样并生成图片. 在训练阶段, 构建的损失函数中包含KL Loss用于正则化潜空间, L2项用于减小重建误差. 从一个标准正态分布中采样, 然后通过重参数化技术映射到潜向量的分布中, 使误差可以反向传播. encoder通过最大化ELBO(其实就是损失函数经过变形)得到一个近似的后验分布. 

在生成阶段, 然而, 是没有encoder的. 也就是说, 我们是在标准正态分布中随机采样, 然后经过decoder生成一张图片, 我们无法控制生成某一张特定的图片, 如想要它生成猫或者是狗是做不到的, 它只能保证你采样之后生成的图片大概率是有意义的. 若或许你已经知道了某个动物的潜向量, 那么在附近取一个潜向量, 经过decoder大概率还是那个动物. 如果你想要不带encoder的VAE生成特定的图片, 可以使用CVAE, Conditional VAE.

VAE中的神经网络由于我们对于先验分布$p(\mathbf{Z})$的假设(即它符合标准正态分布)自动拉向标准正态分布, 这是通过KL散度实现的, 通过把所有的后验分布都尽量拉向标准正态分布使得最后的边际分布近似为标准正态分布.

[^1]: Kingma, D. P., & Welling, M. (2022). Auto-encoding variational bayes (No. arXiv:1312.6114). arXiv. https://doi.org/10.48550/arXiv.1312.6114
[^2]: Rocca, J. (2021, 三月 21). Understanding variational autoencoders (VAEs). Medium. https://towardsdatascience.com/understanding-variational-autoencoders-vaes-f70510919f73
[^3]: 马东什么. (2023, 十月 19). Vae和重参数化技巧 [知乎专栏文章]. 深度学习. https://zhuanlan.zhihu.com/p/570269617