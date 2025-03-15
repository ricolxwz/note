---
title: ELP
# level: chg
---

# ELP

## 动机

LHG面临显著挑战: 在缺少音频到口型同步对齐的客观指标下, 观众更容易注意到面部细微表情与头部运动中的不自然之处, 因而对于动作和表情的精细度要求更高. 现有的Responsive Listening Head Generation (RLHG)和Learning2Listen方法在一定程度上实现了对聆听者头部运动的生成, 但依然存在两方面的局限: 

1. 将动作回归经验直接沿用到LHG会弱化其随机性, 并导致较为平滑、缺少丰富变化的面部与头部动作
2. 虽然代码本的设计在一定程度上能够增强动作的多样性, 但单一维度的离散表示空间使情感类型难以得到明确区分, 从而导致生成的情感容易偏向训练集中占主导地位的类型, 并且难以刻画更细腻的情绪差异

此外, 现有方法往往对眼睛周围和口部等局部细节缺少针对性的建模, 无法在多种情绪下生成更逼真的面部动态变化.

## 创新

针对这些难题, 本文提出了Emotional Listener Portrait (ELP)方法, 旨在在动态对话场景中生成更具真实感与情感区分度的聆听者头像视频. 相比以往方法, ELP主要在以下两方面进行了创新. 

1. 通过在更高维度的离散空间中映射聆听者动作, 有效提升了对面部细节和头部姿态的描述能力, 使得聆听者的眨眼、表情变化以及头部运动能够得到更精细的刻画

2. 在离散空间中显式地融入情感先验, 通过对不同情感类型的离散区域进行划分与重排, 能够更准确地生成体现不同情绪的聆听者表情. 通过Adaptive Space Encoder和Mesh-to-Video Renderer这两个核心模块的结合, 系统能够根据说话者的语音及视觉特征生成多情感、多细节的高保真聆听者视频, 提升了与对话内容的互动性与自然度

## 图片

<figure markdown='1'>
![](https://img.ricolxwz.io/0e0b77a418c6f5ffbff401db9f69d060.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/0e0b77a418c6f5ffbff401db9f69d060_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图1: 这是一个关于我们方法在听众动作合成中的展示, 以三元情感值作为示例. 当给定不同情感的说话者(例如 neutral, positive, and negative)时, 我们的方法会在不同的情感潜在空间下生成相应的听众</figcaption>
</figure>

<figure markdown='1'>
![](https://img.ricolxwz.io/086583ec32e00f5458625a2c420f45af.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/086583ec32e00f5458625a2c420f45af_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图2: 这是ELP的整体概述. 他们将静态的听众面部、说话者视频以及对应的说话者语音作为输入. 在Stage I中, Adaptive Space Encoder会将离散化的特征与情感相结合, 映射到听众的动作参数. 接着在Stage II, Mesh-to-Video Renderer会根据获得的参数生成带有情感的听众视频.</figcaption>
</figure>

<figure markdown='1'>
![](https://img.ricolxwz.io/b73304b804f803adb7daf660c515a46c.webp#only-light){ loading=lazy width='400' }
![](https://img.ricolxwz.io/b73304b804f803adb7daf660c515a46c_inverted.webp#only-dark){ loading=lazy width='500' }
<figcaption>图3: Adaptive Space Encoder 的结构与细节. (a) Adaptive Space Encoder 以说话者的语音 MFCC 特征、说话者面部(β(t))和头部运动(p(t))系数作为输入, 并输出聆听者的面部和头部运动. (b) 针对潜在空间 U(N=2 为例)的拆分与重新排列细节, Base Space 通过元素 e 的数值进行加权并拼接(⊕).</figcaption>
</figure>

## 方法

### 自适应空间编码器

作者提出了自适应空间编码器(Adaptive Space Encoder, ASE)来生成情感化的聆听者系数. 具体而言, ASE以$s_sty_{1:T}$作为输入, 作者将$s_sty$视为来自说话者的跨模态特征, 包含聆听者所需的各种信息, 包括情感值, 话语语义以及响应指导. 潜在的语音特征$a(t)$是通过ResNet-50的主干网络和dropout对输入的MFCC特征进行提取得到的.

ASE如图2中部和图3(a)所示, 显示该模型由两个编码器和解码器组成. 作者假设在一个2秒的输入说话者视频片段中, 情感保持不变.
