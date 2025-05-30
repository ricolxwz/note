---
title: VQRT
comments: true
---

# VQRT (ICLR 2025 ORAL)[^1]

## 摘要

矢量量化变分自编码器(VQ-VAE)旨在将连续输入压缩到离散潜空间,并以最小失真对其进行重构. 它们通过维护一组向量(通常称为码本),并将每个编码器输出量化到码本中最近的向量来运作. 然而,由于矢量量化是不可微的,通向编码器的梯度在直通近似中是绕过矢量量化层而不是直接穿过它. 这种近似可能不理想,因为所有来自矢量量化操作的信息都丢失了. 在这项工作中,作者提出了一种使梯度能够穿过VQ-VAE矢量量化层传播的方法. 作者通过一种旋转和重缩放线性变换,将每个编码器输出平滑地转换为其对应的码本向量,该变换在反向传播期间被视为常数. 因此,当梯度穿过矢量量化层并返回到编码器时,编码器输出与码本向量之间的相对大小和角度被编码到梯度中. 在11种不同的VQ-VAE训练范式中,作者发现这种重构方法改善了重构指标,码本利用率和量化误差.

## 动机

目前对于VQ-VAE中梯度无法传播的标准解决方案是直通估计器STE, 但是这种方法会丢失编码器输出和其对应码本向量之间的相对位置(如角度和幅度)等信息, 见下图.

<figure markdown='1' id='fig1'>
![](https://img.ricolxwz.download/a03fa918f5387b0a7e91ff2548aecfdb.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.download/a03fa918f5387b0a7e91ff2548aecfdb_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图1: 直通估计器(STE)如何变换16个码本向量的梯度场的可视化展示, 其中(顶部)函数为$f(x, y) = x^2 + y^2$, (底部)函数为$f(x, y) = \log(1/2x + \tanh(y))$. STE获取码本向量$(qx, qy)$处的梯度, 并将其"复制粘贴"到同一码本区域内的所有其他位置, 从而在梯度场中形成一种"棋盘格"模式. </figcaption>
</figure>

这里, 梯度场被分成了16个区域(4*4), 然后你会看见, 真实的梯度场中每一个Voronoi区域里面的梯度都可能是不同的; 但是对于直通估计器来说, 每个Voronoi区域里面的梯度全都是相同的. 套到VQ-VAE上, 就是L对于q的梯度等于L对于e的梯度, 这说明, e在voronoi块里面的位置不重要, 重要的是e落在了哪个voronoi块. 换句话说, 无论e在所属的区域离q有多近或者多远, 传递给编码器的梯度都是相同的.

有的方法尝试改进STE. 比如, STE用的是一阶泰勒展开来近似Le, 得到结果之后对e求偏导, 结果仍然是q点的梯度. 我们可以改用二阶泰勒展开来近似Le, 比一阶泰勒展开更加精确, 但是我们需要计算一个computational inefficient的Hessian矩阵, 对于拥有大量参数的现代深度学习模型, 计算相对于所有模型参数的Hessian矩阵通常计算量很大, 不切实际. 但是, 如果只计算相对于码本的Hessian矩阵, 由于码本的大小通常远小于模型参数的数量, 所以这是可行的. 更妙的是, 我们实际需要的不是整个Hessian矩阵, 而只是Hessian矩阵和向量(e-q)的乘积. 又比如, 定义两种损失, Lq和Le, 每一趟进行两次前向传播, 一次带有量化, 一次不带有量化. 然后分别计算损失, 记为Lq和Le. 总损失定义为L=Lq+λLe. λ被定义为一个很小的常数, 因为λ很小, 所以λLe这一项对于解码器参数的影响会非常小, 可以确保解码器主要学习如何处理量化后的q. Lq的梯度直接设置为不回传编码器, λLe的梯度可以传回到编码器.

但是, 其实这两种方法的优化方向都是错误的, 编码器接受的是AE的梯度, 而AE是容易过拟合的, 而且泛化性能较差.

## 方法

<figure markdown='1' id='fig2'>
![](https://img.ricolxwz.download/1b58c49b8b7d125f3ac2167be395bebf.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.download/1b58c49b8b7d125f3ac2167be395bebf_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图2: 旋转技巧示意图. 在前向传播过程中, 编码器输出$e$经过旋转和缩放变换为$q_1$. 为简化起见, 图中未显示其他编码器输出的旋转过程. 在反向传播过程中, $q_1$处的梯度移动到$e$, 从而保持$\nabla_{q_1} \mathcal{L}$与$q_1$之间的夹角不变. 这样一来, 同一码本区域内的点会接收到不同的梯度, 具体取决于它们相对于码本向量的角度和大小. 例如, 具有较大角距离的点可能被推入新的码本区域, 从而提高码本的利用率. </figcaption>
</figure>


从几何的角度看, 我们需要把码本向量q的梯度∇qL移动到编码器的输出e上. 并决定在搬运的时候需要保留哪些几何特性. 从本质上来说, 这篇文章提出的rotation trick和STE本质上都是搬运. 但是搬运的方式有些不同: 1. STE的做法是, 直接把∇qL当做∇eL, 保持梯度的方向和大小不变. 2. rotation trick的做法是, 在把梯度从q移动到e的时候, 保持梯度∇qL和q之间的夹角不变(如下图右), 后面会解释为啥不变.

<figure markdown='1' id='fig3'>
![](https://img.ricolxwz.download/fb2b70df9d4a6d9cb2ca1ecee6dd2398.webp#only-light){ loading=lazy width='400' }
![](https://img.ricolxwz.download/fb2b70df9d4a6d9cb2ca1ecee6dd2398_inverted.webp#only-dark){ loading=lazy width='400' }
<figcaption>图3: 展示了$q$处的梯度如何通过STE(中图)和旋转技巧(右图)移动到$e$. STE通过"复制粘贴"梯度来保持其方向, 而旋转技巧则通过移动梯度来保持$q$与$\nabla_q \mathcal{L}$之间的夹角. </figcaption>
</figure>

Rotation Trick被定义为:

$$
\tilde{q} = \underbrace{\left[ \frac{\|q\|}{\|e\|} R \right]}_{\text{constant}} e
$$

关键在于, 尽管旋转R和缩放因子||q||/||e||都依赖于e, 但是在反向传播的时候, 都会加上SG符号, 把它们当做常数来处理. 个人感觉就是把varonoi图里面e和q的空间位置关系用上了, R表示的是e和q的角度差异, ||q||/||e||表示的是长度差异

那么, 为什么要这么做呢? 看图:

<figure markdown='1' id='fig4'>
![](https://img.ricolxwz.download/ee7d977655db45bccb4cff5d6b7b1e1b.webp#only-light){ loading=lazy width='250' }
![](https://img.ricolxwz.download/ee7d977655db45bccb4cff5d6b7b1e1b_inverted.webp#only-dark){ loading=lazy width='250' }
<figcaption>图4: 在STE方法中, 同一区域内各点之间的距离保持不变. 然而, 采用旋转技巧后, 点间的距离则会发生变化. 当$\phi < \pi/2$时, 角距离较大的点会被推远(蓝色表示距离增加); 而当$\phi > \pi/2$时, 点则会被拉向码本向量(绿色表示距离减小). </figcaption>
</figure>

STE的做法: 对于映射到同一码本向量q的所有e, STE会给他们施加完全相同的更新, 不考虑e和q的具体位置关系. 旋转技巧的更新是个性化的. 它会根据e在q的voronoi区域中的具体位置来调整更新的力度和方向. 左图表示一次更新后, e和q之间的距离的变化, 蓝色表示e被推离q, 绿色表示e被拉进q, 白色表示距离没有变化. 你会看见在同一个voronoi区块里面, 如果用STE, 这张图全是白色, 因为STE不会改变e和q的相对位置关系.

旋转技巧的本质是增加簇的内聚力和排斥力. 从右边这张图可以看出, 在保持phi恒定的时候, theta比较大, 即处于边界上的点, rotation trick对于这些点会给予更强的推/拉效果. 在保持theta恒定的时候, phi小是推, phi大是拉. 这是因为: 当phi较小的时候, 如果我们让q沿着当前的方向更强或者更突出, 那么损失会增加, 这说明当前的q对于这个e来说, 可能不是一个好选择; 当phi较大的时候, 则正好相反.

[^1]: Fifty, C., Junkins, R. G., Duan, D., Iyengar, A., Liu, J. W., Amid, E., Thrun, S., & Ré, C. (2025). Restructuring vector quantization with the rotation trick (No. arXiv:2410.06424). arXiv. https://doi.org/10.48550/arXiv.2410.06424
