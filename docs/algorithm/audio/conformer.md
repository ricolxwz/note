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
