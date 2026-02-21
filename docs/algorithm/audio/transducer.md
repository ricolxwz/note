---
title: Transducer
comments: false
---

## CTC的局限性

### 无法使用历史标签信息

假设声学特征序列为$\mathbf{x} = (x_1, ..., x_T)$, 真实标签序列$\mathbf{y} = (y_1, ..., y_U)$, 对齐序列$\mathbf{\hat{y}}=(\hat{y}_1, ..., \hat{y}_T)$. 

CTC的条件独立性体现在: 生成第$t$个标签的时候使用的是前$t$个声学特征$x_1, ..., x_t$(或者在BiLSTM中使用全部声学特征$x_1, ..., x_T$, 但是这样的话就不适用于创建流式识别模型). 但是$\hat{y}_t$不依赖于其他时间步已经输出的标签$\hat{y}_1, ..., \hat{y}_{t-1}$, 这意味着在预测"cat"中的$t$的时候, 模型只能从"ca"的声学特征判断, 无法利用已经输出了c和a这一标签信息来辅助决策. 

$\mathbf{\hat{y}}\in \mathcal{A}_{\text{CTC}}(\mathbf{x}, \mathbf{y})$表示$\mathbf{\hat{y}}$属于所有能映射到真实标签$\mathbf{y}$的有效CTC对齐路径集合. 

\[ P(\mathbf{y}|\mathbf{x}) = \sum_{\hat{\mathbf{y}} \in \mathcal{A}_{\text{CTC}}(\mathbf{x}, \mathbf{y})} \prod_{t=1}^{T} P(\hat{y}_t | x_1, \cdots, x_t) \]

### 存在硬性约束

并且, 由于预测路径$\mathbf{\hat{y}}$长度固定为$T$, CTC存在一个硬性约束: 输出序列的长度$U$必须小于等于输入帧数$T$. 如果语速极快或者语音帧数过少, CTC就会因为格子不够放导致Loss无穷大或者无法对齐. 与此相比, RNN-T允许在同一个时间步(同一个声学特征)上连续循环运行预测网络, 发射多个标签, 直到模型输出空白符才进入下一帧. 这使得RNN-T能够处理标签数多于帧数的极端情况, 并且对语速变化的适应能力更强. 

## RNN-T的创新

RNN-Transducer通过预测网络引入输出历史依赖, 解决了这一局限: 

\[ P(\mathbf{y}|\mathbf{x}) = \sum_{\hat{\mathbf{y}} \in \mathcal{A}_{\text{RNNT}}(\mathbf{x}, \mathbf{y})} \prod_{i=1}^{T+U} P(\hat{y}_i | x_1, \cdots, x_{t_i}, y_0, \ldots, y_{u_{i-1}}) \]

关键差异在于RNN-T的条件项包含了标签历史 \(y_0, \ldots, y_{u_{i-1}}\), 使当前输出能依赖之前的标签序列. 这里的对齐序列$\mathbf{\hat{y}}=(\hat{y}_1, ..., \hat{y}_{T+U})$包含$T$个空白和$U$个标签, 移除空白之后得到$\mathbf{y}$. 用图片表示:

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.cn/8c6465b0c3dcdecfe8a0774d494210ea.webp#only-light){ loading=lazy width='400' }
![](https://img.ricolxwz.cn/8c6465b0c3dcdecfe8a0774d494210ea_inverted.webp#only-dark){ loading=lazy width='400' }
</figure>

可以看到, 编码器负责处理声学特征, 预测网络仅依赖标签历史, 类似语言模型, 联合网络输出经过softmax生成包含空白的概率分布. 

!!! note "RNN-T和CTC在路径的长度定义的本质区别"

    RNN-T和CTC在路径的长度定义和生成机制上有本质区别. CTC的路径长度为$T$, 这是因为CTC强制在每一个时间步$t$输出一个符号(包括空白符或者真实标签). 因此, 如果输入语音有100帧, 那么预测路径的长度严格等于100帧. 而RNN-T的路径长度$=T+U$. RNN-T的路径是在一个$T\times U$的网格(Lattice)中行走的. 路径主要由两种动作组成: 

    1. 向右移动: 消耗1帧的声学特征, 输出空白符, 共$T$次
    2. 向上移动: 不消耗时间(停留在当前帧), 输出一个非空标签, 共$U$次

    因此, 完成整个序列的预测共需要执行$T$次的移帧操作和$U$次发字操作, 路径总长度为$T+U$. 示意图如图所示.

    <figure markdown='1' id='fig'>
    ![](https://img.ricolxwz.cn/c7f58cd5bf6202c6c5ce3324faeb37d4.webp#only-light){ loading=lazy width='300' }
    ![](https://img.ricolxwz.cn/c7f58cd5bf6202c6c5ce3324faeb37d4_inverted.webp#only-dark){ loading=lazy width='300' }
    </figure>
