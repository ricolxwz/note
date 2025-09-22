---
title: FLAN
comments: false
---

## 概要

本文探究了一种提升语言模型零样本学习能力的简单方法. 作者证明了指令微调, 即在通过指令描述的数据集集合上微调语言模型, 能够显著提升其在未见过的任务上的零样本性能. 他们采用一个137B参数的预训练语言模型, 并在超过60个通过自然语言指令模板表述的NLP数据集上对其进行指令微调. 他们将这个经过指令微调的模型命名为FLAN, 并在未见过的任务类型上对其进行评估. FLAN的性能相较于其未经修改的对应模型有显著提升, 并且在他们评估的25个数据集中有20个超过了零样本的175B GPT-3. 在ANLI, RTE, BoolQ, AI2-ARC, OpenbookQA和StoryCloze等任务上, FLAN甚至大幅领先于少样本的GPT-3. 消融实验表明, 微调数据集的数量, 模型规模以及自然语言指令是指令微调成功的关键.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.asia/674af058e82f465121e6d4eb19620cbd.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.asia/674af058e82f465121e6d4eb19620cbd_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图1: FLAN 是一个应用了指令调优的模型. 实验结果表明, 即使在零样本 (zero-shot) 的情况下, FLAN 在自然语言推断, 阅读理解和闭卷问答等未曾训练过的任务上, 其性能也显著优于强大的 GPT-3 模型.</figcaption>
</figure>

## 引言

### GPT在零样本学习上的局限性

像GPT-3这样的大型语言模型(LMs)非常擅长"少样本学习"(few-shot learning), 也就是你给它几个例子, 它就能学会怎么做. 但是, 它们在"零样本学习"(zero-shot learning)上表现要差得多, 也就是在不提供任何范例的情况下直接让它执行任务. 一个可能的原因是, 没有范例的任务指令(prompt)格式与模型预训练时见过的数据格式不太一样, 这让模型难以很好地理解和执行.

### 提出指令微调

本文的目的是提升大型语言模型(LLM)的零样本(zero-shot)学习能力. 作者认为任何自然语言处理(NLP)任务都可以通过一个直接的指令来描述. 例如 "判断情感是积极还是消极" 或 "把'how are you'翻译成中文". 研究人员将超过60个不同的NLP数据集全部转换成这种指令的形式, 然后用这些数据去微调(finetune)一个有1370亿参数的预训练模型. 这个过程被称为"指令微调"(instruction tuning). 经过这种方式微调后诞生的新模型, 被命名为FLAN (Finetuned Language Net).

### 如何评估FLAN零样本性能

他们先把所有任务按类型分组. 当要测试模型在某一类型任务(比如"自然语言推理")上的表现时, 他们会在训练阶段完全不让模型接触任何该类型的任务. 模型只在所有其他类型的任务(比如翻译, 情感分析)上进行微调. 这样就保证了最终的测试是真正的零样本测试, 因为模型对被测试的任务类型是完全陌生的.

### 评估结果

作者的评估表明, FLAN显著提升了137B参数基础模型的零样本性能. 在作者评估的25个数据集中, FLAN的零样本性能在其中20个上超过了175B参数GPT-3的零样本性能, 甚至在ANLI, RTE, BoolQ, AI2-ARC, OpenbookQA和StoryCloze上大幅领先于GPT-3的少样本性能. 在消融实验中, 作者发现增加指令微调中任务簇的数量("任务簇的数量" 指的就是在指令微调(instruction tuning)过程中, 使用了多少种不同类别的任务.)可以提升在未见过任务上的性能, 并且指令微调的益处只有在模型规模足够大时才会显现.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.asia/23ae68234d0b3fe8c3bab4667f19675f.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.asia/23ae68234d0b3fe8c3bab4667f19675f_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图2: 指令调整与预训练-微调和提示的比较</figcaption>
</figure>

## 方法

指令调优 (instruction tuning) 的动机是提升语言模型响应自然语言处理 (NLP) 指令的能力. 核心思想是, 通过有监督学习的方式, 教会语言模型执行指令描述的任务. 模型通过这种训练学会遵循指令, 甚至能完成从未见过的新任务. 为了评估模型在新任务上的表现, 研究者会将数据集按任务类型分组. 评估时, 会保留一个任务组作为测试集, 用所有其余的任务组来对模型进行调优. 这个过程可以检验模型对未知任务的泛化能力.

### 任务&模板

由于从头创建包含许多任务的指令调优数据集会耗费大量资源, 他们将研究界现有的数据集转换为指令格式. 他们聚合了 Tensorflow Datasets 上公开的 62 个文本数据集, 将它们整合成一个单一的混合体, 其中包括语言理解和语言生成任务. 如[图3](#fig3)所示, 每个数据集被归类到 12 个任务集群中的一个, 同一集群内的数据集任务类型相同.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.asia/04ae700bca2871b37fd90a56067db2e6.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.asia/04ae700bca2871b37fd90a56067db2e6_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图3: 本文使用的数据集和任务集群</figcaption>
</figure>
