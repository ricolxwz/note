---
title: 思维链
comments: false
---

# 思维链

## 摘要

推理是人类智能不可或缺的基本认知过程, 在人工智能领域引起了广泛的关注. 值得注意的是, 最近的研究表明, 思维链能够显著增强LLM的推理能力, 这引起了学术界和产业界的广泛关注. 该综述系统的调查了相关研究, 并通过细致的分类总结了先进的方法, 提供了新颖的视角. 此外, 他们还深入研究了当前的前沿领域, 并划分了挑战和未来的方向. 此外, 他们还参与了开放性问题的讨论, 他们希望这篇综述能够成为初学者的入门读物... 促进未来的研究, 资源已经在他们的[网站](https://github.com/zchuz/CoT-Reasoning-Survey)上发布.

## 简介

在人类的认知领域中, 推理作为关键枢纽, 对于理解世界和形成决策至关重要. 随着预训练规模的不断发展, 大型语言模型(LLMs)在众多下游任务中展现出越来越强的能力. 最近, 研究者发现LLMs能够通过上下文学习展现逐步推理的能力, 这一现象被称为链式思维(CoT)推理. 普遍观察到, CoT提示显著增强了LLMs的推理能力, 尤其是在复杂任务中.

<figure markdown='1' id='fig1'>
![](https://img.ricolxwz.io/c7433be139acdeee35014c49ef83b158.webp#only-light){ loading=lazy width='500' }
![](https://img.ricolxwz.io/c7433be139acdeee35014c49ef83b158_inverted.webp#only-dark){ loading=lazy width='500' }
<figcaption>图1: 模型在链式思维提示的指导下逐步解决复杂问题</figcaption>
</figure>

[图1](#fig1)展示了一个链式思维推理的例子. 与直接给出答案不同, 链式思维推理提供了一个逐步推理的过程. 具体来说, 它将复杂的问题分解为可管理的步骤(思路), 简化了整体推理过程, 并在各个推理步骤之间建立连续(链条)以确保没有忽略任何重要条件. 此外, 链式思维推理提供了一个可以观察的推理过程, 使得用户可以理解模型的决策轨迹, 并提高最终答案的可信度和可解释性.

得益于CoT Prompting的卓越表现, 他收到了学术界和工业界的广泛关注, 演变成了prompt engineering领域中的一个独特的研究分支. 此外, 它已经成为AI autonomous agents领域中的一个关键组成部分. 然而, 这些研究仍然缺乏系统性的综述和分析. 为了弥补这一空白, 作者提出本研究以对CoT推理进行全面而详尽的分析. 具体来说, 本文深入探讨了链式思维推理的更广泛范畴, 他们称之为generalized chain-of-thought (XoT). XoT推理的核心理念是通过逐步推理的方法, 逐渐揭开复杂问题的层层面纱.

他们的贡献总结如下: (1) Comprehensive Survey: 这是第一个专门针对XoT推理的全面综述; (2) Meticulous taxonomy: 他们引入了一个精细的分类法; (3) Frontier and Future: 他们讨论了新的前沿, 概述了其挑战, 并为未来研究提供了启示; (4) Resources: 他们公开提供这些资源, 以便促进社区研究的发展.

综述的组织: 他们首先介绍背景和预备知识; 接着从不同的视角呈现基准测试和先进方法; 此外, 他们还讨论了前沿研究, 并概述了挑战和未来方向; 最后, 他们进一步讨论了开放性问题.

## 背景和预备知识

### 背景

在过去的几年中, 随着预训练规模的不断扩大, 语言模型展现出众多新能力, 例如上下文学习和链式思路推理. 伴随着这一驱使, 预训练后提示逐渐取代了预训练后微调, 成为自然语言处理领域的新范式.

### 预备知识

在本节中, 他们将介绍标注提示和链式思维推理的预备知识. 他们定义了以下的符号: 问题$\mathcal{Q}$, 提示词$\mathcal{T}$, 概率语言模型$p_{LM}$和预测$\mathcal{A}$. 

首先, 他们考虑少样本标准提示场景, 其中提示$\mathcal{T}_{SP}$包含指令$I$和少样本示例(若干问答对). 模型将问题和提示作为输入, 并产生答案预测$\mathcal{A}$作为输出, 如下列公式所示:

$$
\begin{aligned}
&\mathcal{T}_{SP} = \{I, (x_1, y_1), \dots, (x_n, y_n)\}\\
&p(\mathcal{A} \mid \mathcal{T}, \mathcal{Q}) = \prod_{i=1}^{|\mathcal{A}|} p_{LM}(a_i \mid \mathcal{T}, \mathcal{Q}, a_{<i})
\end{aligned}
$$

接下来, 他们考虑在保持少样本情况下使用思维链提示. 提示词$\mathcal{T}_{CoT}$包含指令, 问题, 答案以及推理过程$e_i$. 在链式思维推理中, 模型不再直接生成答案, 而是先逐步的推理轨迹$\mathcal{R}$, 然后再给出答案$\mathcal{A}$, 如下列公式所示:

\[
\begin{aligned}
\mathcal{T}_{\text{CoT}} &= \{I, (x_1, e_1, y_1), \dots, (x_n, e_n, y_n)\}, \\[6pt]
p(\mathcal{A}, \mathcal{R} \mid \mathcal{T}, \mathcal{Q}) &= p(\mathcal{A} \mid \mathcal{T}, \mathcal{Q}, \mathcal{R}) \cdot p(\mathcal{R} \mid \mathcal{T}, \mathcal{Q}), \\[6pt]
p(\mathcal{R} \mid \mathcal{T}, \mathcal{Q}) &= \prod_{i=1}^{|\mathcal{R}|} p_{\text{LM}}\bigl(r_i \mid \mathcal{T}, \mathcal{Q}, r_{<i}\bigr), \\[6pt]
p(\mathcal{A} \mid \mathcal{T}, \mathcal{Q}, \mathcal{R}) &= \prod_{j=1}^{|\mathcal{A}|} p_{\text{LM}}\bigl(a_j \mid \mathcal{T}, \mathcal{Q}, \mathcal{R}, a_{<j}\bigr).
\end{aligned}
\]

### CoT推理的优势

作为一种新的推理范式, 链式思维推理具有多种优势. (1) Boosted Reasoning. 链式思维推理将复杂问题分解为可管理的步骤, 并在这些步骤之间建立联系, 从而促进推理; (2) Offering Interpretability. 链式思维推理提供可观察的推理轨迹, 使得用户可以理解模型的决策, 使推理过程透明且可信; (3) Advance Collaboration. 细粒度的推理轨迹有助于用户和系统之间的交互, 使得能够改变模型的执行轨迹, 从而促进由LLMs驱动的自主代理的发展.

## 基准

在本节中, 他们将简要概述评估推理能力的各项基准, 包括数学推理, 常识推理, 符号推理, 逻辑推理以及多模态推理. 基准概述如表所示(表太大了, 没放下).

* 数学推理: 数学推理构成了人类智力的基础. 在解决问题, 决策和理解世界方面发挥着关键作用. 它通常用来被评估LLMs的一般推理能力
* 常识推理: 常识推理对于日常生活中的交流以及对世界的感知至关重要,它评估了语言模型对世界的理解能力
* 符号推理: 符号推理将语义进行重构, 并作为检验语言模型在模拟原子操作能力方面的试验平台
* 逻辑推理: 逻辑推理至关重要, 因为它是理性思考, 文件问题解决和可解释决策的基石
* 多模态推理: 多模态推理将文本思维和来自自然世界的感官体验, 如视觉场景和听觉声音无缝整合, 从而创造出更加丰富, 更加全面的信息理解

???+ example "符号推理"

    假设有两个前提:

    1. 所有人都会死亡
    2. 苏格拉斯是人

    我们可以将这些前提符号化, 令$P(x)$表示$x$是人, $Q(x)$表示$x$会死亡. 那么, 第一个前提可以表示为: $\forall x\,(P(x) \rightarrow Q(x))$; 第二个前提可以写为: $P(\text{Socrates})$根据逻辑推理规则, 我们可以得出: $Q(\text{Socrates})$, 即苏格拉底会死亡.

## 模型

本节讨论了来自三个视角的先进XoT方法: prompt construction, topological variations和enhancement methods.