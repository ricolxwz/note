---
title: 学习与检测未知概率分布
comments: false
---

## 主题

这节课的主题是学习与检测未知分布, 也就是从一堆数据中学习到一个分布. 我们假设输入数据$x_1, ..., x_n$是从一个未知的分布$\mathbf{p}$中独立同分布抽样得到的, 目前是通过这些数据, 去了解$\mathbf{p}$本身. 我们会对这个未知的分布做一些有限的假设, 唯一的假设是它是定义在一个已知的, 离散的集合$\mathcal{X}$上面, 且空间大小是$k$, 即$|\mathcal{X}|=k$.

## 引入: 加拿大"Lotto 6/49"彩票问题

假设我们有这样的一组数据, 这是加拿大"Lotto 6/49"彩票抽样结果的直方图, $k=49$, 总抽样数为$3665$. 现在想从中学习分布$\mathbf{p}$的信息.

<figure markdown='1' id='fig1'>
![](https://img.ricolxwz.io/b4b63f0808c1d10dd2ca3302da1ddd4c.webp#only-light){ loading=lazy width='600' }
![](https://img.ricolxwz.io/b4b63f0808c1d10dd2ca3302da1ddd4c_inverted.webp#only-dark){ loading=lazy width='600' }
</figure>

那么, 你说的是什么信息呢? Well:

1. 学习分布本身

    比如: 我们能不能估计出整个分布$\mathbf{p}$是什么样子的? 解析式是什么?

2. 学习分布的特征

    比如: 我们能不能计算一些"简单"的参数$f(\mathbf{p})$, 比如均值, 熵, 方差等?

3. 检验分布是否满足某种性质

    比如: 我们能不能判断$\mathbf{p}$是否满足某种特定要求? 例如$\mathbf{p}$是否和从$\{1,…,49\}$中独立均匀抽$6$个数然后取最小值的分布一致? 注意, 我们并不知道是不是抽$6$个取最小, 我们仅仅知道
