---
title: 光栅化
# level: chg
---

# 光栅化[^1]

光栅化(rasterization)是计算机图形学中最常见, 最基础的渲染技术之一, 其核心目的是将场景中的几何图元(比如三角形, 多边形等)转换为离散的像素数据. 其他的渲染技术还包括光线追踪等.

## 基本单元

光栅化的基本单元是三角形, 采用三角形作为基本单元的原因是三角形是最基本的多边形, 三角形具有平面性, 三角形可以明确定义内部和外部, 我们可以通过向量叉积来计算, 任意多边形可以拆分为N个三角形. 

## 采样绘制

2D屏幕是一个离散的像素阵列, 空间中的三角形则是一个连续的函数. 采样绘制的本质是对一个函数进行离散化, 具体的做法是: 遍历像素阵列, 判断每个像素阵列是是否位于三角形的投影区域内, 如果是, 进行绘制像素, 否则, 不绘制. 如下图所示为采样绘制的伪代码和示意图. 注意, 像素本身是一个矩形区域, 因此判断像素是否在三角形内部时, 采用的是像素点的中心作为参照.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/ab15966da2bca4a2f2d0fa4382ae383d.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/ab15966da2bca4a2f2d0fa4382ae383d_inverted.webp#only-dark){ loading=lazy width='800' }
</figure>

在绘制三角形的时候, 一般不会对屏幕的像素点进行扫描, 而是仅仅对三角形的bounding box区域内的像素进行扫描和绘制, 从而有效降低算法复杂度. 对于一些窄三角形, 甚至可以进一步优化算法, 如下图右侧所示.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/ec5d3f266299772e2a1664d45c99f2e5.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/ec5d3f266299772e2a1664d45c99f2e5_inverted.webp#only-dark){ loading=lazy width='800' }
</figure>

## 核心问题

我们观察上述这种简单的采样绘制方式, 可以发现一个很明显的问题-锯齿(Jaggies). 这个问题根本上是采样导致的, 对于这种现象我们称之为走样(Aliasing). 走样会带来很多奇怪的现象, 比如: 锯齿, 摩尔纹(Moire Patterns), 车轮效应等, 如下图所示.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/7d73aba7f0676b24521d5b1e62795077.webp#only-light){ loading=lazy width='600' }
![](https://img.ricolxwz.io/7d73aba7f0676b24521d5b1e62795077_inverted.webp#only-dark){ loading=lazy width='600' }
</figure>

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/b6eeb119f34e387dc9932c0c61ba4a4c.webp#only-light){ loading=lazy width='600' }
![](https://img.ricolxwz.io/b6eeb119f34e387dc9932c0c61ba4a4c_inverted.webp#only-dark){ loading=lazy width='600' }
</figure>

## 解决方法

计算机图形学中解决走样问题的常用方法是: 先模糊, 后采样. 模糊, 从字面意思上讲就是将图片虚化, 从数学上理解就是滤波. 下图所示为直接采样和先模糊, 后采样的流程对比图.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/ca1dff550c1705bf3825ecafb14637cc.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/ca1dff550c1705bf3825ecafb14637cc_inverted.webp#only-dark){ loading=lazy width='800' }
</figure>

在具体实践中, 通过这种方式能够有效解决光栅化中的锯齿问题, 如下所示为反走样前后的效果对比图.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/291c7b03b1cad587705e1d633b9b24c6.webp#only-light){ loading=lazy width='600' }
![](https://img.ricolxwz.io/291c7b03b1cad587705e1d633b9b24c6_inverted.webp#only-dark){ loading=lazy width='600' }
</figure>

这里, 我们可能会产生疑问: 出现走样的根本原因是什么, 为什么先模糊(滤波)后采样能够实现反走样? 要明白这些内容, 我们必须介绍一下采样理论.

## 采样理论

采样理论是信号系统中非常重要的一个理论, 它在数字信号处理, 数字通信, 图像处理等众多领域都有广泛的应用. 在实际应用中, 我们通过一定的采样率把连续信号转换为离散信号, 然后再对离散信号进行处理. 处理完后, 我们又可以通过一定的重构方法把离散信号转换回连续信号, 以便再实际系统中使用.

那么如何表示任意一种信号呢? 法国数学家傅里叶认为, 任何周期函数(信号)都可以使用正弦函数和余弦函数构成的无穷级数来表示, 如下图所示.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/6abdbc921e7eedb4a82173894b3bf911.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/6abdbc921e7eedb4a82173894b3bf911_inverted.webp#only-dark){ loading=lazy width='800' }
</figure>

对于上图的信号, 使用傅里叶级数展开的表示如下所示. 其中, 这里的$t$表示时间, $A$表示振幅, $w$表示角频率

$$
f(x) = \frac{2A \cos(tw)}{\pi}
- \frac{2A \cos(3tw)}{3\pi}
+ \frac{2A \cos(5tw)}{5\pi}
- \frac{2A \cos(7tw)}{7\pi}
+ \cdots
$$

对于傅里叶级数, 我们可以对信号的时域(以时间为横坐标)和频域(以频率为横坐标)进行相互转换: 时域转换为频域, 采用傅里叶变换(Fourier Transform); 频域转换成时域, 采用逆傅里叶变换(Inverse Fourier Transform). 

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/2cd06046bbaa7532f48d894c5bd78c1f.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/2cd06046bbaa7532f48d894c5bd78c1f_inverted.webp#only-dark){ loading=lazy width='800' }
</figure>

## 走样原理

了解了信号的时域和频域后, 我们再来介绍走样的原理. 理想情况下, 对一个连续信号进行采样后得到的离散信号, 应该能够近似重构原始信号. 然而, 当采样频率低于原始信号的频率的时候, 就会很容易出现走样的问题. 换句话说, 就是采样得到的离散信号无法近似重构原始信号.

如下图所示, 我们列举了几种信号, 信号频率依次从高到低, 我们使用相同的频率对这些信号进行采样. 很显然, 我们对低频信号进行采样的时候, 由于采样频率大于信号频率, 得到的离散信号可以近似重构原始信号; 但是, 我们对高频信号采样的时候, 由于采样率小于信号频率, 得到的离散信号无法近似重构原始信号.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/46d377567d685b8f9a4756b84591998d.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/46d377567d685b8f9a4756b84591998d_inverted.webp#only-dark){ loading=lazy width='800' }
</figure>

因此, 走样的根本原因就是采样频率小于信号频率.

## 滤波

由于滤波在反走样中起到了重要作用, 因此我们简单介绍一下图像处理中的滤波. 如下图所示, 通过傅里叶变换将左侧的像素空间(空间域)变为右侧的频谱(频域), 注意, 傅里叶变换并不局限于时域和频域之间的转换. 对于二维的信号, 其频谱表示如下: 高频部分代表细节, 边缘, 噪声; 低频占据大多数能量, 代表图像中大量的平滑区域(亮度或者色彩变化缓慢), 频率分布具有中心对称性.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/a3bc76e0394b442c2badded683814c1d.webp#only-light){ loading=lazy width='600' }
![](https://img.ricolxwz.io/a3bc76e0394b442c2badded683814c1d_inverted.webp#only-dark){ loading=lazy width='600' }
</figure>

下面来介绍几种常见的滤波:

1. 高通滤波

    高通滤波(High-pass filter), 保留高频信号. 在图像中, 轮廓的变换会发生剧烈的变化, 属于高频信号. 经过高通滤波后, 图像只会保留一些轮廓信息, 如下图所示.

    <figure markdown='1' id='fig'>
    ![](https://img.ricolxwz.io/66c27da352cb253295b2a5ef65d1a71a.webp#only-light){ loading=lazy width='600' }
    ![](https://img.ricolxwz.io/66c27da352cb253295b2a5ef65d1a71a_inverted.webp#only-dark){ loading=lazy width='600' }
    </figure>

2. 低通滤波

    低通滤波(Low-pass filter), 保留低频信号. 在图像中, 颜色变化平缓的区域属于低频信号. 经过低通滤波后, 图像会抹去轮廓信息. 模糊处理是基于低通滤波实现的.

    <figure markdown='1' id='fig'>
    ![](https://img.ricolxwz.io/3d05c8e959d55c506b0bd73eb557b0fb.webp#only-light){ loading=lazy width='600' }
    ![](https://img.ricolxwz.io/3d05c8e959d55c506b0bd73eb557b0fb_inverted.webp#only-dark){ loading=lazy width='600' }
    </figure>

3. 带通滤波

    带通滤波(Band-pass filter), 顾名思义, 只保留一部分频率范围内的信号. 对图像滤波后的效果取决于带通滤波所选择的频率范围. 下图所示, 为两种不同频率范围的带通滤波.

    <figure markdown='1' id='fig'>
    ![](https://img.ricolxwz.io/2a715d76eb6a7ea7f2b848fa56099eeb.webp#only-light){ loading=lazy width='600' }
    ![](https://img.ricolxwz.io/2a715d76eb6a7ea7f2b848fa56099eeb_inverted.webp#only-dark){ loading=lazy width='600' }
    </figure>

    <figure markdown='1' id='fig'>
    ![](https://img.ricolxwz.io/a812974af82c2c7417a3ef0a2960aa81.webp#only-light){ loading=lazy width='600' }
    ![](https://img.ricolxwz.io/a812974af82c2c7417a3ef0a2960aa81_inverted.webp#only-dark){ loading=lazy width='600' }
    </figure>

## 卷积

那么如何实现滤波呢? 卷积(Convolution)就是实现滤波的主要数学工具和底层原理. 滤波器的基本原理是响应函数和输入信号进行卷积运算, 因此滤波器可以被称为卷积核. 如下图所示, 是对图像进行滤波(卷积)的过程, 实现模糊处理. 基于傅里叶变换, 我们可以实现时域(空间域)和频域之间的相互转换. 时域(空间域)上对两个信号进行卷积, 等同于频域上对两个信号的频率进行乘积.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/31fd93ad168d6d03cc0609a6bc872d32.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/31fd93ad168d6d03cc0609a6bc872d32_inverted.webp#only-dark){ loading=lazy width='800' }
</figure>

## 反走样原理

在走样原理中, 我们提到了走样的根本原因是采样频率小于信号频率. 在不提高采样频率的前提下, 通过先滤波, 后采样的方式可以实现反走样, 这里的底层逻辑是什么呢? 简单的理解就是, 滤波(低通滤波, 即模糊处理)会过滤掉信号中大于采样频率的信号分量. 滤波后, 剩余的信号分量的频率满足采样频率>=信号频率的条件, 因此实现了反走样. 实现反走样的方法主要就是围绕两个角度来实现: 1) 提高采样频率, 如超采样技术, 多重采样抗锯齿, 超分辨率; 2) 过滤高频信号, 如先模糊后采样.

## 遮挡和可见

上述内容介绍了光栅化的一个三角形的场景, 以及其会遇到的问题 -- 走样. 下面, 我们来介绍光栅化多个三角形会遇到的问题 -- 遮挡和可见问题. 在3D空间中, 三角形之间存在前后遮挡的关系, 那么三角形绘制的先后顺序应该是怎么样的呢?

## 画家算法

对此, 我们先介绍一个经常被用到的算法: 画家算法. 画家算法, 顾名思义, 按照画家绘画时的先后顺序来执行, 远的物体先绘制, 近的物体后绘制, 如下图所示.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/7288070afe2f763e8c5185c28d3c3e5f.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/7288070afe2f763e8c5185c28d3c3e5f_inverted.webp#only-dark){ loading=lazy width='800' }
</figure>

虽然画家算法适用于绝大多数场景, 但是在某些场景下它仍然无法解决可见性问题. 如下图所示, 三个相互嵌套的三角形, 使用画家算法则无法对三角形进行排序, 因此无法准确实现光栅化.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/b1f51afd467cd5156d8661f517d4e915.webp#only-light){ loading=lazy width='600' }
![](https://img.ricolxwz.io/b1f51afd467cd5156d8661f517d4e915_inverted.webp#only-dark){ loading=lazy width='600' }
</figure>

## 深度缓冲算法

那么上述问题如何解决呢? 于是出现了深度缓冲算法(Z-buffer Algorithm), 其基本原理是:

光栅化采用两个缓冲区: 原有的帧缓冲区(Frame Buffer)存储每个像素颜色值; 附加的深度缓冲区(Z-Buffer)存储每个像素的深度值, 并且是每个像素当前的最小深度值. 如下图所示, 使用深度缓冲算法光栅化两个三角形的示意图. 当光栅化红色三角形的时候, 我们遍历红色三角形的每个像素的深度值, 并和当前深度值进行比较. 由于当前深度值均为无穷大, 所以红色三角形的每个像素都能绘制. 当光栅化蓝色三角形的时候, 同样会遍历蓝色三角形每个像素的深度值, 并和当前深度值比较, 深度值大于当前深度值, 则不绘制; 否则, 绘制并更新当前的最小深度值.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/ed354658bc2be181f3903268dee33bc9.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/ed354658bc2be181f3903268dee33bc9_inverted.webp#only-dark){ loading=lazy width='800' }
</figure>

注意, 这里的深度值比较取决于坐标轴是如何建立的. 

[^1]: Chuquan B. (2024, 三月 30). 计算机图形学基础（4）——光栅化. 楚权的世界. http://chuquan.me/2024/03/30/foundation-of-computer-graphic-04/index.html
