---
title: Conformer
comments: false
---

Conformer是Google在2020年提出的语音识别模型, 基于Transformer改进而来, 主要的改进点在于Transformer在提取长序列依赖的时候更加有效, 而卷积则擅长提取局部特征, 因此将卷积应用于Transfromer的Encoder层, 同事提升模型在长期序列和局部特征上的效果. 实验证明, 该方法确实有效, 在当时的LibriSpeech测试机上取得了SOTA效果. 

## 方案

输入语音特征首先会经过一个卷积下采样层, 用卷积把时间长度变短, 减少后续计算量, 同时提取局部特征. 然后再经过若干个Conformer blocks. 这个block由4个模块组成: 前馈网络, 自注意力, 卷积, 前馈网络. 如下图所示. 

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.cn/a205bc356e40f680189d58a873ecfb9a.webp#only-light){ loading=lazy width='500' }
![](https://img.ricolxwz.cn/a205bc356e40f680189d58a873ecfb9a_inverted.webp#only-dark){ loading=lazy width='500' }
</figure>

### 多头自注意力模块

他们采用了一个来自Transformer-XL的multi-headed self-attention(MSHA), 具体来说他们用的是相对正弦位置编码, 它能让elf-attention模块在边长输入上有更好的表现, 所得到的编码器对语音长度的变化具有更强的鲁棒性. 

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.cn/41997665bec8818bcb728299310d4c55.webp#only-light){ loading=lazy width='500' }
![](https://img.ricolxwz.cn/41997665bec8818bcb728299310d4c55_inverted.webp#only-dark){ loading=lazy width='500' }
</figure>

### 卷积模块

卷积模块先用$1\times 1$卷积把通道扩展并通过GLU做门控筛选, 再用1D depth wise卷积高效提取时间维局部模式, 随后用BatchNorm+Swish稳定并增强非线性表达, 最后使用$1\times 1$卷积投影回到原通道, Dropout正则化, 并和输入做残差相加确保深层训练稳定和信息保留. 

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.cn/534d350be17f968224a790960584889a.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.cn/534d350be17f968224a790960584889a_inverted.webp#only-dark){ loading=lazy width='800' }
</figure>

### 前馈模块

在原始的Transformer模型中, FFN位于MHSA层之后, 由两个线性变换层和夹在中间的非线性激活函数组成, 标准设计包含残差连接和层归一化. 和原始的Transformer不同, 作者选择在输入进入第一层线性层之前就进行层归一化, 使用Swish函数替代了传统的激活函数, 如ReLU, 使用Dropout技术来防止过拟合. 

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.cn/d0a495848edd4c3b420c3b5e16612898.webp#only-light){ loading=lazy width='550' }
![](https://img.ricolxwz.cn/d0a495848edd4c3b420c3b5e16612898_inverted.webp#only-dark){ loading=lazy width='550' }
</figure>

### Conformer模块

Conformer模块包含两个FFN, 其中再夹着一个MHSA模块和一个卷积模块. 文中将原始的FFN层改为两个半步的FFN, 一个在MHSA模块之前, 一个放在最后. 这种设计是Macaron-Net的思想(像一个三明治夹住). 他们的实验显示这种三明治的结构能够极大提高精度. 

$$
\begin{align*}
\tilde{x}_i &= x_i + \frac{1}{2}\mathrm{FFN}(x_i) \\
x'_i &= \tilde{x}_i + \mathrm{MHSA}(\tilde{x}_i) \\
x''_i &= x'_i + \mathrm{Conv}(x'_i) \\
y_i &= \mathrm{Layernorm}\left(x''_i + \frac{1}{2}\mathrm{FFN}(x''_i)\right)
\end{align*}
$$
