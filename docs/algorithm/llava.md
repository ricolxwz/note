---
title: LLaVA
comments: true
---

# LLaVA[^1]

## 摘要

使用机器生成的[指令跟随(instruction-following)数据](/dicts/instruction-following-data)对大语言模型进行指令调优已经被证明能够提升模型在未见任务上的零样本能力. 然而, 这一方面在多模态领域的探索还比较少. 作者首次尝试使用纯语言的GPT-4生成模型生成多模态语言-图像指令跟随数据. 通过这些生成的数据对LLM进行指令调优, 他们提出了LLaVA, Large Language and Vision Assistant. 这是一个端到端训练的大模型, 它将视觉编码器和LLM连接起来, 用于通用视觉和语言理解. 为了促进未来对视觉指令跟随的研究, 他们构建了两个评估基准, 其中包含多种具有挑战性的面向应用的任务. 他们的实验表明, LLaVA展示了令人影响深刻的多模态聊天能力, 有时能在未见图像/指令的条件下表现出多模态版本的GPT-4的行为, 在合成的多模态指令跟随数据集上, LLaVA和多模态版本的GPT-4相比获得了85.1%的相对分数. 在Science QA数据集上进行微调的时候, 与GPT-4的结合达到了92.53%的SOTA准度. 他们已经将基于GPT-4生成的视觉指令调优数据, 他们的模型, 代码开源.

## 简介

### 多模态的优势

人类通过视觉和语言多种渠道和世界互动, 因为每种渠道在表达和交流某些概念的时候具有独特的优势, 从而有助于更好地理解世界. 人工智能的核心愿望之一就是开发一种通用的助手, 它能有效地遵循多模态视觉和语言指令, 和人类的意图保持一致, 能够完成现实世界中各种in the wild的任务.

### 语言增强的视觉模型

为此, 业界开始关注开发语言增强的基础视觉模型. 这些模型在开放世界的视觉理解任务方面具有强大的能力, 如分类, 检测, 分割和图像描述生成, 此外, 这些模型还具有图像生成和编辑的能力. 作者建议参考*Computer Vision in the Wild*阅读列表, 已获取更加全面和最新的参考文献. 

在这一研究方向中, 现有的方法往往为每个任务设计一个独立的模型, 并且任务的具体目标(比如"检测目标", "生成描述")通常是通过模型架构, 训练目标等隐式定义, 而不是直接通过用户的语言指令灵活指定的. 再者, 语言在现有方法中通常仅限于描述图像的内容. 虽然这种方法能够让语言在视觉信号映射到语言语义上发挥了重要作用, 但是导致了模型无法通过自然语言动态响应用户的需求, 它的接口通常是固定的, 交互性和适应性不足.

### 大语言模型

大型语言模型, LLM, 则表明, 语言可以发挥更加广泛的作用: 作为一种通用助手(LLM)的通用接口(语言指令), 用户通过自然语言明确表达任务指令, 模型根据指令动态端到端的完成指定任务. 例如, 最近ChatGPT和GPT-4通过大规模训练和[对齐](/dicts/alignment)技术进一步提升了模型的指令跟随能力, 并且引起了各界对于研发开源LLM的浓厚兴趣, 在他们之中, LLaMA是和GPT-3性能相当的开源LLM. Alpaca, Vicuna, GPT-4-LLM, 利用各种机器生成的高质量指令跟随样本来提高LLM的对齐能力, 和专有的LLM相比, 这些模型的性能令人印象深刻. 重要的是, 这些工作只涉及文本.

### 本文贡献

在本文中, 作者提出了视觉指令调优, 首次尝试将指令调优扩展到语言-图像多模态空间, 为构建通用视觉助手铺平了道路, 他们的模型有以下的贡献:

* 多模态指令跟随数据. 最核心的挑战就是缺乏视觉-语言指令跟随数据. 他们提出了一种数据重构方法和流程, 使用ChatGPT/GPT-4将原本的图文对转换为合理的指令跟随形式
* 大型多模态模型. 他们构建了一个大型多模态模型(LMM), 具体做法是将视觉编码器CLIP和语言解码器Vicuna结合起来, 使用上面GPT-4生成的视觉-语言指令跟随数据进行端到端的微调. 实验结果说明, 使用这些生成的数据进行LLM的指令调优是有效的. 此外, 他们还给出了一些构建通用型视觉[指令跟随代理(agent)](/dicts/instruction-following-agent)的实践建议. 当模型和GPT-4结合后, 在Science QA这个多模态推理数据集上取得了SOTA的结果.
* 多模态指令跟随基准. 他们提出了一个名为LLaVA-Bench的评测基准, 其中包括两个具有挑战性的测试机. 这些测试集提供了多样化的图文对, 指令以及详细的标注, 用来检验模型的多模态指令跟随能力
* 开源. 他们将相关资源全部开源, 包括生成的多模态指令数据, 代码库, 模型权重以及一个可供使用的视觉聊天演示. 这样其他研究者就可以自由使用和改进这些成果

## 相关工作

### 多模态[指令跟随代理](/dicts/instruction-following-agent)

在计算机视觉领域, 现存的构建指令跟随代理的工作可以大致上分为两类: (i) 端到端训练的模型, 这些模型通常针对特定研究任务进行独立探索, 比如, 在视觉-语言导航(VLN)和Habitat等任务中, 代理需要根据自然语言指令在视觉环境中执行一系列动作以完成目标. 在图像编辑场景中, InstructPix2Pix根据输入图像和文字指令, 直接编辑图像以实现用户的目标; (ii) 通过LangChain/LLMs协调多个模型的系统, 如Visual ChatGPT, X-GPT, MM-REACT, VisProg和ViperGPT. 这些系统用大模型或者LangChain来调用和组合不同的子模型, 从而实现多模态的指令跟随能力. 作者指出, 他们希望在(i)的基础上更进一步, **端到端地**训练一个**多任务的**, 语言-视觉**多模态大模型**. 

### 指令调优

在NLP大家庭中, 为了使得LLM例如GPT-3, T5, PaLM和OPT遵循自然语言指令并完成现实世界中的任务, 研究者探索了各种LLM指令调优的方法, 例如InstructGPT/ChatGPT, FLAN-T5, FLAN-PaLM和OPT-IML. 事实证明, 这种简单的方法可以有效提高LLM的zero-和few-shot泛化能力. 因此, 将这种理念从NLP借鉴到计算机视觉上是很自然的. 更加广泛的来说, 一些和视觉相关的工作包括原本NLP相关的教师-学生蒸馏已经在一些topic例如图像分类领域得到研究. 

由于其强大的零样本任务迁移能力和在上下文学习上的表现, Flamingo可以被视为多模态领域的GPT-3时刻. 其他一些在文本-图像对上训练的LLMs有BLIP-2, FROMAGe, 和KOSMOS-1. PaLM-E是一种用于具身AI场景的模型. 随后, 在开源的LLaMA模型的基础上, OpenFlamingo和LLaMA-Adapter等项目也尝试让LLaMA处理图像输入.

不过, 上述的这些多模态模型虽然在一些方面展现了较好的泛化性能, 但是它们并没有显式地使用视觉-语言指令跟随数据来进行微调, 因此在多模态任务上往往无法像在语言任务上那样取得同等水平的效果. 

作者提到, "视觉指令调优"和"视觉提示调优"的区别是, 欠着的目的是让模型能够更好地理解和执行指令, 提升它在多模态场景下的指令跟随能力; 而后者则主要关注的是如何以更少的参数代价来适应不同的任务.

## 方法论

???+ abstract "30问"

    1. 问题的类型是怎么来的 ---> 人设计的, 完成这些任务所需要的能力基本覆盖了所有我们期望MLM有的能力
    2. 问题是怎么来的 ---> 人设计的问题, 然后用GPT-4改写来扩充为多样化的问题列表
    3. 回答是怎么来的 ---> GPT-4回答的
    4. 标题是怎么来的 ---> 根据图片, 人或者GPT-4, LLaVA之外的模型生成的, 是制作训练集的一部分
    5. 图片是怎么来的 ---> 人搜集的, 制作训练集的时候搜集的
    6. 边框是怎么来的 ---> 根据图片, 人或者GPT-4, LLaVA之外的模型生成的
    7. 图像-文本对是怎么来的 ---> 这就是数据库中的东西, 或者可以说是图像-标题对
    8. LLaVA的输入是什么 ---> X instruct, Xa
    9. GPT-4的输入是什么 ---> Caption + Boxes + 指令
    10. GPT-4的输出是什么 ---> Xa, Xq
    11. LLaVA的输出是什么 ---> Xa
    12. X instruct指的是什么 ---> 见公式2
    13. Xq指的是什么 ---> GPT-4产生的问题 (会送到LLaVA的Vicuna当中, 包含在X instruct当中)
    14. Xv指的是什么 ---> 原始图片 (会送到LLaVA的ViT-L/14当中, 包含在第一个X instruct当中)
    15. Xc指的是什么 ---> 图像的描述, 是Xa的一种 (会送到LLaVA的Vicuna当中, 不包含在X instruct当中), 当回答的是"描述图片"等问题时, Xa=Xc
    16. Xa指的是什么 ---> 问题的答案(会送到LLaVA的Vicuna当中, 不包含在X instruct当中)
    17. xi指的是什么 ---> 目前预测的输出的第i个token
    18. T指的是什么 ---> 多轮对话的总轮数
    19. L指的是什么 ---> 输出的总长度
    20. X instruct, Xa, Xq的右上标指的是什么 ---> 当前多轮对话的轮数
    21. X instruct, Xa的右下标指的是什么 ---> 输出的第几个token
    22. 如何让GPT-4产生这些指令跟随数据, 是要先给GPT做个示范吗 ---> 提示词里面写了一些人工写的示例, 利用的是大模型的in-context learning能力
    23. GPT-4是根据什么产生回答的 ---> 自己🐂🍺
    24. GPT-4是根据什么产生问题的 ---> 提示词里面给了人工写的原始问题做seed, 只是让它扩写
    25. 和简单方法的区别是什么, 为什么是cheap to construct ---> 因为简单方法里面Xa只有一种, 那就是Xa=Xc, 而作者给出的Xa是多种多样问题的回答
    26. 标题和type1, type2, type3答案的联系 ---> caption只是给GPT-4用的, Caption文本+boxes文本是image的等价替换, Xa和标题之间没有很大关系, Xc和标题之间有一点关系, 但是Xc不完全等于标题, Xc是GPT-4生成的, 而标题是作为GPT-4的输入的, 是在数据集中本来就有的东西
    27. 需要设计一些GPT的prompt使得他可以产生指令跟随数据 ---> 那当然了

### GPT辅助视觉指令数据生成

近年来, 社区收集了大量的公开多模态数据, 例如图像-文本对数据集, 比如CC和LAION. 这些数据集包含了图像和相应的文本描述, 广泛应用于多模态学习任务中. 然而, 多模态指令跟随数据相对稀缺. 这是因为创建这类数据的过程非常耗时, 并且当使用人工众包进行收集的时候, 工作流程不够明确, 难以高效执行. 最近GPT模型如ChatGPT/GPT-4在文本注释任务中的成功激发了作者的灵感. 作者提到, 可以利用像ChatGPT和GPT-4这样的语言模型来收集多模态指令跟随数据, 基于现有的图像-文本对数据. 这些语言模型可以自动生成和图像相关的视觉指令跟随数据.

对于一张图片$\mathbf{X}_v$和它对应的描述$\mathbf{X}_c$, 创建一组问题$\mathbf{X}_q$来引导助手描述图片内容是很自然的做法. 作者通过GPT-4来生成这样一组问题, 因此, 将图片-文本对扩展成指令跟随数据的一种简单的方法是`Human: Xq Xv<STOP> Assistant: Xc<STOP>`. 这种扩展方式构建的成本较低, 但是它缺乏指令和回答中的多样性和推理, 他只回答一个单一的图像描述问题`Xc`, 注意, 标题不等于`Xc`, `Xc`是GPT-4生成的, 标题是GPT-4, LLaVA之外的模型生成的, 数据集中本来就有的东西.

为了解决这个问题, 他们使用纯语言的GPT-4或者ChatGPT(只接受文本作为输入)创建包含视觉内容的指令跟随数据. 具体来说, 为了将图像转为视觉特征, 以输入到纯文本GPT中, 他们使用了 ^^两种符号表示^^. (i) 标题, 通常从不同的角度描述视觉场景; (ii) 边框, 通常用于定位场景中的物体, 每个边框表示的是物体的"概念"以及它的空间位置. 

???+ tip "从单一到多样"

    之前的单一做法是:

    ```
    Human : X1instruct <STOP> Assistant: X1c <STOP>
    Human : X2instruct <STOP> Assistant: X2c <STOP>
    ```

    现在的做法是:

    ```
    Human : X1instruct <STOP> Assistant: X1a <STOP>
    Human : X2instruct <STOP> Assistant: X2a <STOP>
    ```

通过这种符号表示的方法, 他们可以将图像编码为LLM可识别的序列. 他们使用的是COCO图像, 生成了 ^^三种类型的指令跟随数据^^. 每种类型的数据, 在表格的底部中有一个示例展示. 对于每种类型, 研究者首先手动设计一些示例, 这些示例是数据收集过程中的唯一的人工注释. 然后, 这些手动设计的示例被用作"上下文学习"的种子示例, 用于query GPT-4模型.

* 对话. 他们设计了一段对话, 对话内容是助手和一个就这张照片提问的人之间的对话. 回答者的语气就像助手看到图片并回答问题一样. 就图片的视觉内容提出一系列问题, 包括物体类型, 物体数量, 物体动作, 物体位置, 物体之间的相对位置等. 只有明确答案的问题才会被考虑
* 详细描述. 为了对图片进行丰富而全面的描述, 他们创建了一个问题列表. 对于每张图片, 他们都会从列表中随机抽取一个问题, 要求GPT-4生成详细描述
* 复杂推理. 上述的两种类型的问题主要集中在视觉内容本身. 再次基础上, 他们进一步制作了深度推理问题, 答案通常需要按照严密的逻辑逐步推理

<figure markdown='1'>
![](https://img.ricolxwz.io/4fe9d333253f301574047f72d9992da8.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/4fe9d333253f301574047f72d9992da8_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>指令跟随数据的一个例子. 最上面的标题/边框是GPT-4的prompt中的一部分. 最下面的问题/回答和图片是LLaVA的prompt中的一部分</figcaption>
</figure>

<figure markdown='1'>
![](https://img.ricolxwz.io/55e367bc05d73ed1bc1a1c60ffc2a9d5.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/55e367bc05d73ed1bc1a1c60ffc2a9d5_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>GPT-4的输入</figcaption>
</figure>

### 视觉指令调优

#### 架构

主要目标是有效利用现有的预训练的LLM和视觉模型的功能. 网格架构如下图所示. 他们选择的是Vicuna作为以$\phi$作为参数的LLM $f_{\phi}(\cdot)$, 因为Vicuna在公开的checkpoints中具有最佳的指令跟踪能力.

<figure markdown='1'>
![](https://img.ricolxwz.io/20310f3fdd5c88bb694fe2d8a6956fcf.webp#only-light){ loading=lazy width='500' }
![](https://img.ricolxwz.io/20310f3fdd5c88bb694fe2d8a6956fcf_inverted.webp#only-dark){ loading=lazy width='500' }
<figcaption>LLaVA网络架构</figcaption>
</figure>

对于输入图像$\mathbf{X}_v$, 他们考虑使用预训练好的CLIP视觉编码器ViT-L/14, 他能提供视觉特征$\mathbf{Z}_v=g(\mathbf{X}_v)$. 他们在实验中考虑在使用CLIP视觉编码器的最后一个Transformer层之前和之后的特征, 来进行分析或实验. 他们考虑用简单的线性层将图像特征链接到word的嵌入空间. 具体来说, 他们使用可训练的投影矩阵$\mathbf{W}$将$\mathbf{Z}_v$转换为语言嵌token$\mathbf{H}_v$, 其维度应该和语言模型中的单词嵌入空间的维度相同: $\mathbf{H}_v=\mathbf{W}\cdot \mathbf{Z}_v$, 其中, $\mathbf{Z}_v=g(\mathbf{X}_v)$. 

这样, 我们就得到了视觉tokens序列$\mathbf{H}_v$. 注意, 他们的简单投影方案是轻量级的, 这使得我们能够快速迭代以数据为中心的实验. 他们还考虑使用更加复杂的方案来链接图像和语言特征, 例如Flamingo中的门控交叉注意和BLIP-2中的Q-former. 他们将在今后的工作中探索更加有效, 更加复杂的LLaVA架构设计.

#### 训练

对于每张图$\mathbf{X}_v$, 他们会使用GPT-4生成多轮对话数据$(\mathbf{X}_q^1, \mathbf{X}_a^1,..., \mathbf{X}_q^T, \mathbf{X}_a^T)$, $T$是对话的轮数. 第$t$轮对话的$\mathbf{X}^t_{\text{instruct}}$可以被表示为:

$$\mathbf{X}_\text{instruct}^t = 
\begin{cases} 
\text{Randomly choose } [\mathbf{X}_q^1, \mathbf{X}_v] \text{ or } [\mathbf{X}_v, \mathbf{X}_q^1], & \text{the first turn } t = 1 \\ 
\mathbf{X}_q^t, & \text{the remaining turns } t > 1
\end{cases}$$

这就形成了如下面这个例子所示的形式. 他们利用自回归训练目标对预测的token计算损失. 具体来说, 对于长度为$L$的序列, 他们通过以下方法计算目标答案$\mathbf{X}_a$的概率. 

$$p(\mathbf{X}_a \mid \mathbf{X}_v, \mathbf{X}_{\text{instruct}}) = \prod_{i=1}^L p_{\mathbf{\theta}}(x_i \mid \mathbf{X}_v, \mathbf{X}_{\text{instruct}, <i}, \mathbf{X}_{a, <i})$$

???+ example "LLaVA训练模拟"

    完整的输入是`an image here<STOP>Human:图像里有几个人<STOP>Assistant:有七个人<STOP>`, 要预测的是`有七个人`, 预测`有`字的casual mask让LLM能看到`an image here<STOP>Human:图像里有几个人<STOP>Assistant:`, 预测`七`字的casual mask让LLM能看到`an image here<STOP>Human:图像里有几个人<STOP>Assistant:有`.

    输入的是一个完整的输入, 是通过casual mask实现这种自回归的功能的, $L$就是这个完整的输入的长度. 多轮对话是当做一个整体输入的, 如下所示.

    ```
    Xsystem-message<STOP>Human:X1instruct<STOP>Assistant:X1a<STOP>Human:X2instruct<STOP> Assistant:X2a<STOP>
    ```

    都是连成一个串输入进去的.

<figure markdown='1'>
![](https://img.ricolxwz.io/50f5a8dd0bd9e1fb341480878a7643fe.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/50f5a8dd0bd9e1fb341480878a7643fe_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>用于训练模型的序列. 注意上图中的序列都是串行的, 都是并行的, 是因为表示清晰所以并排列出; 这里只举例说明了两个对话回合, 在实际操作中, 回合的数量会根据指令跟随数据的不同而变化. 在他们的实现中, 按照Vicuna-v0设置了一个系统信息$\mathbf{X}_{\text{system}}$并设置STOP=###. 该模型经过训练, 用于预测assistant的答案$\mathbf{X}_a$和停止的位置, 所以只有颜色不同的哪些序列/tokens会被用于在自回归模型中计算损失</figcaption>
</figure>

其中, $\theta$是可训练参数, $\mathbf{X}_{\text{instruct}, <i}$和$\mathbf{X}_{a, <i}$分别是当前预测标记$x_i$之前所有回合中的$\mathbf{X}_{\text{instruct}}$和$\mathbf{X}_a$. 关于预测token的说明, 请见上图. 对于上面公式中的条件, 作者明确添加了$\mathbf{X}_v$, 以强调图像对于所有答案都是有基础的, 同时他们省略了$\mathbf{X}_{\text{system-message}}$和之前所有的`<STOP>`, 以提高可读性. 对于LLaVA模型训练, 他们考虑采用两阶段的指令调优程序.

##### 特征对齐

为了在concept coverage和训练效率之间取得平衡, 他们从CC3M中筛选了59.5万条图文配对的样本, 并将这些原本只包含图片和文本标题的数据对使用GPT-4转换成带有指令和回答的形式. ^^每个样本被视为一个单回合对话^^, 其中$\mathbf{X}_{\text{instruct}}$是输入, 对于一张图片$\mathbf{X}_v$, 会从问题集里面随机采样一个问题$\mathbf{X}_q$, $\mathbf{X}_a$是问题的回答. ^^在训练的过程中, 他们会保持视觉编码器和LLM的权重冻结, 只会去优化那个视觉投影层,^^ 根据上述公式, 也就是参数$\mathbf{\theta}=\mathbf{W}$. 这样一来, 图像特征的$\mathbf{H}_v$就会和预训练LLM的文字嵌入对齐. 这个过程可以理解为为冻结的LLM训练一个兼容的视觉tokenizer.

##### 端到端调优

在第二阶段, 他们始终将视觉编码器的权重冻结, 然后 ^^继续更新线性投影层^^, 并且, ^^也要更新LLM^^. 即, 现在$\mathbf{\theta}=\{\mathbf{W}, \mathbf{\phi}\}$. 他们考虑了两个使用场景:

1. 多模态聊天机器人: 使用158k条语言-图片指令数据进行微调, 以构建一个多模态聊天机器人. 在三种问题类型中, 对话是多轮的, 这三种问题会均一采样
2. Science QA: 他们在ScienceQA基准测试上研究了他们的方法, 这是第一个大规模的多模态科学问答数据集, 其中每个问题都有详细的解释和答案解析. 在这个数据集中, 每个问题会提供一个上下文, 该上下文可能是自然语言形式或者是图片. 模型需要在理解上下文的基础上, 用自然语言输出推理过程, 并在多个选项中做出选择. 对于训练阶段, 他们将数据组织成一个单回合对话的形式, 具体来说, 问题和上下文会被拼接为$\mathbf{X}_{\text{instruct}}$, 而推理过程和最终答案会被拼接为$\mathbf{X}_a$, 通过这种方式, 模型能够在多模态的场景下进行科学问答, 并给出可解释的推理和准确的答案.

[^1]: Liu, H., Li, C., Wu, Q., & Lee, Y. J. (2023). Visual instruction tuning (No. arXiv:2304.08485). arXiv. https://doi.org/10.48550/arXiv.2304.08485