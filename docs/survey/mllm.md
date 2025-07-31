---
title: 多模态大模型
comments: true
---

# 多模态大模型[^1]

## 摘要

近年来, 以GPT-4V为代表的多模态大预言模型(MLLM)成为新兴研究热点, 其通过强大语言模型作为大脑来执行多模态任务. MLM展现出惊人的涌现能力-如图像故事创作和无需OCR的数学推理, 这在传统多模态方法中极为罕见, 昭示着通向通用人工智能的潜在路径. 为此, 学术界和工业界竞相研发可以与GPT-4V媲美甚至超越的MLLM模型, 以前所未有的速度突破研究边界.

在这篇论文中, 作者旨在追踪并总结MLLMs的最新进展. 首先, 作者给出了MLLM的基本形式, 并阐明了其相关概念, 包括模型架构、训练策略与数据, 以及评估方式. 接着, 作者介绍了如何将MLLMs扩展到更细的粒度、更丰富的模态、更多的语言和应用场景. 作者还讨论了多模态幻觉及其扩展技术, 包括多模态ICL(M-ICL)、多模态CoT(M-CoT)和LLM辅助视觉推理(LAVR). 最后, 作者讨论了当前面临的挑战并指出了值得关注的研究方向. 鉴于MLLM时代才刚刚开始, 作者将持续更新这份综述, 并希望它能激发更多研究. 有关最新论文的GitHub链接可在此找到: https://github.com/BradyFU/Awesome-Multimodal-Large-Language-Models.

## 介绍

近些年, LLMs取得了显著的进展. 通过扩大数据规模和模型规模, 这些LLMs展现了非凡的涌现能力, 其中典型包括指令跟随(1)[^2][^3], In Context Learning(ICL)(2)[^4], 以及Chain of Thought(CoT)(3)[^5]. 虽然LLMs在大多数自然语言处理任务上展现了令人惊讶的零/小样本推理性能, 但由于它们只能理解离散文本, 因此在视觉方面本质上是“盲”的. 与之相对, 大规模视觉模型(LVMs)虽然能够清晰地“看见”[^6][^7][^8][^9], 但通常在推理方面表现不足.
{.annotate}

1. LLM中的“指令跟随”(Instruction Following)指的是大型语言模型在面对用户指令或问题时,能够根据上下文与用户需求进行理解和处理,并给出相应回答或执行特定任务的能力.这种能力通常依靠在训练阶段通过大量示例和反馈来对模型进行微调,使其在解析并响应指令时更符合人类意图.常见方法包括使用监督微调(Supervised Fine-Tuning)和人类反馈强化学习(RLHF, Reinforcement Learning from Human Feedback)等技术,从而让模型学会理解人类语言、尊重对话上下文以及调整回答的风格或内容,以实现更准确、更自然的交流体验.
2. “In context learning”指的是在推理阶段,模型不需要进行额外的参数更新或训练,而是通过给定的上下文(例如提示语+示例)来学习并完成新任务.也就是说,模型能够从输入的上下文信息中快速“领会”任务的要求与内容,从而在不改变内部参数的情况下,完成相应的推断或回答. 相比之下,“指令跟随”(Instruction Following)更侧重于模型对明确指令的理解与执行.通过在训练或微调阶段让模型大量接触各种指令和人类反馈,模型学会如何遵循特定的指令格式或意图,并给出相应的回答或行动.
3. “Chain of thought”指的是大型语言模型在推理或回答问题时,会在内部形成一系列逻辑推断或思维步骤,从而帮助模型更好地理解问题和生成结果.这种“思维链”过程类似于人在解决复杂问题时会先进行多步思考,再得出结论.通过在训练和推理过程中显式或隐式地利用这些中间推断步骤,模型能够在面对复杂任务时给出更准确和具有解释性的回答.

基于这种互补性, LLM和LVM相互靠拢, 引出了多模态大型语言模型(MLLM)这一新领域. 从形式上来看, 它指的是具备接收、推理以及输出多模态信息能力的基于LLM的模型. 在MLLM出现之前, 已经有大量研究致力于多模态领域, 并可将相关工作分为判别式[^10][^11][^12]和生成式[^13][^14][^15]两种范式. CLIP[^10]作为前者的代表, 将视觉和文本信息投射到统一的表示空间, 为下游多模态任务搭建了桥梁. 相比之下, OFA[^13]是后者的代表, 通过序列到序列的方式统一多模态任务. 根据序列操作, MLLM可被归类为后者, 但与传统模型相比, 它体现了两个显著特征: (1) MLLM基于具有数十亿参数的LLM, 这在以往模型中并不存在. (2) MLLM使用新的训练范式来释放其全部潜力, 例如使用多模态指令微调[^16][^17], 以鼓励模型遵循新的指令. 凭借这两个特征, MLLM展现了新的能力, 例如基于图像编写网站代码[^18], 理解表情包的深层含义[^19], 以及无需OCR的数学推理[^20].

自从GPT-4[^22]发布以来, 它所展示的令人惊叹的多模态示例引发了对MLLMs的研究热潮. 学术界和工业界的共同努力加速了这一领域的发展. MLLMs的早期研究主要关注基于文本提示与图像[^17][^21]/视频[^23][^24]/音频[^25]的文本内容生成. 后续工作进一步拓展了模型的能力或使用场景, 包括: (1) 更精细的粒度支持. 通过方框[^26]或单击某个对象[^27]来实现对用户提示的更精细控制. (2) 对输入和输出模态的增强支持[^28][^29], 如图像、视频、音频以及点云. 除了输入以外, 像NExT-GPT[^30]这样的项目还进一步支持以不同模态进行输出. (3) 语言支持的改进. 有研究尝试在训练语料相对有限的情况下, 将MLLMs的成功经验推广到其他语言(例如中文)[^31][^32]. (4) 向更多领域和使用场景拓展. 一些研究将MLLMs的强大能力应用于医学图像理解[^33][^34][^35]和文档解析[^36][^37][^38]等领域. 此外, 多模态智能体也被开发用于辅助真实世界中的交互, 例如具身智能体[^39][^40]和GUI智能体[^41][^42][^43]. 下图中展示了MLLMs的发展时间线.

<figure markdown='1'>
![](https://img.ricolxwz.asia/1a83353a9331c33630be6673f9b4356e.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.asia/1a83353a9331c33630be6673f9b4356e_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>代表性MLLMs的时间线.</figcaption>
</figure>

鉴于该领域的快速发展以及其所展现的可观成果, 作者撰写了这份综述, 旨在帮助研究者了解MLLMs的基本概念、主要方法和当前进展. 需要注意, 他们主要聚焦于视觉和语言模态, 但也包括涉及其他模态(如视频和音频)的相关工作. 具体而言, 他们概括并总结了MLLMs最重要的方面, 同时建立了一个实时更新的GitHub页面. 据作者所知, 这是关于MLLM的第一篇综述.

以下是该综述的内容结构: 该综述首先对MLLMs的核心方面进行了全面回顾, 包括主流架构; 完整的训练策略与数据; 性能评估的常见做法. 随后, 作者们深入探讨了MLLMs中的一些重要议题, 每个议题都聚焦于一个主要问题: 哪些方面可以进一步改进或拓展? 如何缓解多模态幻觉问题? 接下来, 该综述介绍了三个关键技术, 分别适用于特定的应用场景: MICL是一种在推理阶段常用的有效技术, 可提升小样本情境下的表现. 另一项重要技术是M-CoT, 通常应用于复杂推理任务. 之后, 作者们阐述了一个基于LLM构建系统的整体思路, 用于解决复合推理任务或应对常见用户需求. 最后, 该综述以总结和未来研究方向作结.

## 架构

一个典型的MLLM可以被抽象为三个模块, 分别是预训练的模态编码器、预训练的LLM以及连接它们的模态接口. 如果将其与人类做类比, 那么图像/音频等模态编码器就像人的眼睛/耳朵, 负责接收并预处理光学/声学信号, 而LLM则如同人类大脑, 用于理解并推理这些处理过的信号. 在此过程中, 模态接口用于对齐不同的模态. 一些MLLM还包含生成器, 用于输出除文本以外的其他模态. 下图中展示了该架构示意图. 在本节中, 作者将依次介绍每个模块.

<figure markdown='1'>
![](https://img.ricolxwz.asia/d76d54f68aefa45dc820ae980b6944c6.webp#only-light){ loading=lazy width='400' }
![](https://img.ricolxwz.asia/d76d54f68aefa45dc820ae980b6944c6_inverted.webp#only-dark){ loading=lazy width='400' }
<figcaption>典型的MLLM架构. 它包含一个编码器、一个连接器以及一个LLM. 除此之外, 可以在LLM上附加一个可选的生成器, 用于生成除文本之外的更多模态. 编码器负责接收图像、音频或视频并输出特征, 这些特征再通过连接器进行处理, 使LLM能够更好地理解. 通常而言, 连接器可以分为三种类型: 基于投影的连接器、基于查询的连接器以及基于融合的连接器. 前两种类型采用基于token的融合方式, 将特征处理为token, 与文本token一起输入; 而最后一种类型则允许在LLM内部进行基于特征层面的融合.</figcaption>
</figure>

### 模态编码器

编码器用于将图像或音频等原始信息压缩为更紧凑的表示. 而不是从零开始训练, 一种常见做法是使用已经对齐其他模态的预训练编码器. 例如, CLIP[^10]在大规模图文数据上进行预训练, 从而使其视觉编码器在语义上与文本对齐. 因此, 使用此类预先对齐的编码器, 通过对齐式预训练与LLM对齐会更为容易.

下表中总结了常用的图像编码器. 除了原版的CLIP图像编码器[^10]之外, 一些研究也在探索其他变体. 例如, MiniGPT-4[^18]采用了EVA-CLIP[^44][^45](ViT-G/14)编码器, 并在改进的训练技巧下进行训练. 相比之下, Osprey[^27]使用了基于卷积的ConvNext-L编码器[^46], 以利用更高的分辨率和多级特征. 也有一些研究探索无编码器架构. 例如, Fuyu-8b[^47]在输入LLM之前直接投影图像块, 使得模型能够自然地支持灵活的图像分辨率输入.

| 变体 (Variants)                        | 预训练语料 (Pretraining Corpus)       | 分辨率 (Resolution) | 样本数量 (B) (Samples) | 参数规模 (M) (Parameter Size) |
| -------------------------------------- | ------------------------------------- | ------------------- | ---------------------- | ----------------------------- |
| OpenCLIP-ConvNext-L              | LAION-2B                              | 320                 | 29                     | 197.4                        |
| CLIP-ViT-L/14                     | OpenAI's WIT                          | 224/336             | 13                     | 304.0                        |
| EVA-CLIP-ViT-G/14                 | LAION-2B, COYO-700M                   | 224                 | 11                     | 1000.0                       |
| OpenCLIP-ViT-G/14                 | LAION-2B                              | 224                 | 34                     | 1012.7                       |
| OpenCLIP-ViT-bigG/14              | LAION-2B                              | 224                 | 34                     | 1844.9                       |

在选择编码器时, 通常会考虑分辨率、参数规模和预训练语料等因素. 值得注意的是, 许多工作通过实验证明, 使用更高的分辨率可以显著提升性能[^32][^48][^49][^50]. 将输入分辨率提升的方法可分为直接放大和切分图像两类. 直接放大方式将更高分辨率的图像输入编码器, 往往需要进一步调整编码器[^32]或替换为能处理更高分辨率的预训练编码器[^48]. 类似地, CogAgent[^42]使用了双编码器机制, 分别处理高分辨率和低分辨率图像, 并通过交叉注意力将高分辨率特征注入低分辨率分支. 切分图像的方法则将高分辨率图像切分成若干块并复用低分辨率编码器. 例如, Monkey[^49]和SPHINX[^51]将大图像分成多个小块, 并将这些子图像与下采样的高分辨率图像一同输入图像编码器, 使子图像捕捉局部特征, 而低分辨率图像保留全局特征. 相比之下, 一些实证研究发现, 与输入分辨率相比, 参数规模和训练数据构成的重要性较低[^50].

类似的编码器也可用于其他模态. 例如, Pengi[^25]使用CLAP[^52]模型作为音频编码器, 而ImageBind-LLM[^28]使用ImageBind编码器[^53], 可以对图像、文本、音频、深度、热成像以及惯性测量单元(zoteIMU)数据进行编码. 借助这一强大的编码器, ImageBind-LLM能够针对多种模态的输入做出响应.

### 预训练LLM

与从零开始训练LLM相比, 使用预训练模型更加高效且更具实用性. 经过在海量网络语料上的预训练, LLM已经融入了丰富的世界知识, 并展现出强大的泛化和推理能力. 作者在下表中总结了常用且公开可用的LLM. 值得注意的是, 大部分LLM属于因果解码器类型, 继承自GPT-3[^4]. 其中, Flan-T5[^54]系列是较早被使用的LLM, 应用于BLIP-2[^55]和InstructBLIP[^56]等工作. LLaMA[^2]系列和Vicuna[^57]家族是代表性的开源LLM, 在学术界备受关注. 由于它们主要在英文语料上进行预训练, 多语言支持(例如中文)能力有限. 相比之下, Qwen[^58]是一种支持中英文的双语LLM.

| 模型                 | 发布时间     | 预训练数据规模  | 参数规模(B)        | 语言支持           | 架构                           |
| -------------------- | ------------ | --------------- | ------------------ | ------------------ | ------------------------------ |
| Flan-T5-XL/XXL | 2022年10月   | -               | 3 / 11            | 英语, 法语, 德语    | 编码-解码器 (Encoder-Decoder)  |
| LLaMA           | 2023年2月    | 1.4T tokens     | 7 / 13 / 33 / 65   | 英语               | 因果解码器 (Causal Decoder)    |
| Vicuna          | 2023年3月    | 1.4T tokens     | 7 / 13 / 33        | 英语               | 因果解码器 (Causal Decoder)    |
| LLaMA-2        | 2023年7月    | 2T tokens       | 7 / 13 / 70        | 英语               | 因果解码器 (Causal Decoder)    |
| Qwen           | 2023年9月    | 3T tokens       | 1.8 / 7 / 14 / 72  | 英语, 中文         | 因果解码器 (Causal Decoder)    |

需要指出的是, 扩大LLM的参数规模也会带来额外收益, 类似于提升输入分辨率所带来的增益. 有研究[^48][^59]表明, 将LLM从7B扩展到13B, 可以在多个基准上带来全面的性能提升. 此外, 当使用34B规模的LLM时, 即使仅在英文多模态数据上进行训练, 模型也能展现零样本的中文能力. 另有工作[^60]同样发现, 当将LLM从13B扩展到35B或65B/70B后, 在为多模态大模型所设计的基准上也能实现持续的性能提升.  同时, 也有研究使用更小的LLM来便于在移动设备上部署. 例如, MobileVLM系列[^61][^62]通过缩小版LLaMA (称为MobileLLaMA 1.4B/2.7B), 实现在移动端处理器上的高效推理.

近年来, 将专家混合(MoE)架构应用于LLM的探索也日益受到关注[^63][^64][^65]. 相较于稠密模型, 稀疏结构通过选择性激活部分参数, 能在不增加计算开销的情况下扩展总参数规模. 在实证研究中, MM1[^50]和MoE-LLaVA[^66]发现, 几乎在所有基准上, MoE实现都优于对应的稠密模型.

### 模态接口

由于LLMs只能感知文本, 因此在自然语言与其他模态之间搭建桥梁是必要的. 然而, 以端到端的方式训练一个大型多模态模型代价高昂. 一个更可行的方法是在预训练的视觉编码器与LLM之间引入一个可学习的连接器. 另一种方式则是借助专家模型将图像转换为语言, 然后再将这些语言输入LLM.

#### 可学习接口

它负责弥合不同模态之间的差距. 具体而言, 该模块会将信息投影到LLM能够高效理解的空间. 根据多模态信息融合方式的不同, 大致可以分为token级融合与特征级融合两类.

在token级融合中, 编码器输出的特征会被转换成若干token, 并在送入LLMs之前与文本token拼接. 一种常见且可行的方案是使用一组可学习的查询token来以基于查询的方式抽取信息[^67], 该方法首先在BLIP-2[^55]中实现, 随后被许多工作所继承[^24][^56][^68]. 这类Q-Former风格的方法会将视觉token压缩成少量表示向量. 相比之下, 有些方法则直接使用基于MLP的接口来弥合模态鸿沟[^17][^35][^69][^70]. 例如, LLaVA系列采用一个或两个线性MLP来投影视觉token[^17][^48], 并将特征维度与词嵌入对齐. 需要注意的是, MM1[^50]在连接器的设计选择上进行了消融实验, 发现对于token级融合, 模态适配器的具体类型远不如视觉token数量和输入分辨率重要. 尽管如此, 也有研究[^71]比较了token和特征级融合在VQA基准上的性能, 实验证明token级融合变体表现更好. 对于这一性能差距, 作者们认为交叉注意力模型可能需要更复杂的超参数搜索过程才能获得可比的性能.

另一种思路是特征级融合, 即在文本特征和视觉特征之间插入额外模块, 实现更深入的交互和融合. 例如, Flamingo[^72]在LLM的冻结Transformer层之间插入了额外的交叉注意力层, 从而在语言特征中注入外部的视觉线索. 类似地, CogVLM[^73]在每一层Transformer中嵌入了一个视觉专家模块, 使视觉特征与语言特征能够双向互动和融合. 为了获得更好的性能, 引入模块的QKV权重矩阵会从预训练的LLM初始化. 同样, LLaMA-Adapter[^74]在Transformer层中引入了可学习的提示, 先用视觉知识对这些提示进行嵌入, 然后与文本特征拼接作为前缀. 就参数规模而言, 可学习接口与编码器和LLM相比通常只占很小的一部分. 以Qwen-VL[^32]为例, 其Q-Former的参数量约为0.08B, 占比不到总参数的1%, 而编码器和LLM分别约占19.8%(1.9B)和80.2%(7.7B).

#### 专家模型

除了可学习的接口, 使用专家模型(例如图像描述模型)也是弥合模态差距的一种可行方法[^75][^76][^77][^78]. 其基本思路是无须训练, 直接将多模态输入转换为语言. 如此一来, LLM就可以通过转换后的语言来理解多模态信息. 例如, VideoChat-Text[^23]利用预训练的视觉模型来提取诸如动作等视觉信息, 并使用语音识别模型丰富描述. 虽然使用专家模型十分直接, 但可能不如可学习接口灵活. 将外部模态转换为文本会导致信息损失, 比如将视频转换成文本描述会扭曲其时空关系[^23].

## 训练策略和数据

一个完整的 MLLM 在训练过程中会经历三个阶段, 即预训练, 指令调优, 和对齐调优. 每个阶段都需要不同类型的数据, 并实现不同的目标. 在本节中, 作者讨论了训练目标, 以及每个训练阶段的数据收集与特点.

### 预训练

#### 训练细节

作为第一个训练阶段, 预训练主要旨在对齐不同模态并学习多模态世界知识. 预训练阶段通常需要大规模的文本配对数据, 例如说明文字数据. 通常, 这些文本对会以自然语言句子的形式描述图像/音频/视频. 在这里, 研究人员考虑了一种常见情景, 即训练MLLMs将视觉与文本对齐. 如下列代码所示, 给定一张图像, 模型在标准交叉熵损失的指导下自回归地预测该图像的描述文本.

```
Input: <image>
Response: {caption}
```

预训练的一种常见方法是将预训练的模块(例如视觉编码器和LLM)保持冻结状态, 并训练一个可学习的接口[^17][^33][^70]. 其核心思想是在不丢失预训练知识的前提下对齐不同模态. 一些方法[^32][^79][^80]也会解冻更多模块(例如视觉编码器)以提供更多可训练参数用于对齐. 需要注意的是, 训练方案与数据质量密切相关. 对于简短且噪声较多的描述文本数据, 可以采用较低的分辨率(例如224)来加快训练过程, 而对于更长且更干净的数据, 最好使用更高的分辨率(例如448或更高)来减轻幻觉现象. 此外, ShareGPT4V[^81]发现, 在预训练阶段使用高质量的描述文本数据, 解锁视觉编码器有助于实现更好的对齐.

#### 数据

预训练数据主要有两个用途: (1) 对齐不同模态, (2) 提供世界知识. 按照粒度划分, 预训练语料可分为粗粒度和细粒度数据, 作者将依次进行介绍. 作者在下表中总结了常用的预训练数据集.

**粗粒度图文(Coarse-grained Image-Text)**

| 数据集(Dataset)        | 样本量(Samples) | 日期(Date)  |
| ---------------------- | -------------- | ----------- |
| CC-3M            | 3.3M           | 2018        |
| CC-12M            | 12.4M          | 2020        |
| SBU Captions      | 1M             | 2011        |
| LAION-5B          | 5.9B           | Mar-2022    |
| LAION-2B          | 2.3B           | Mar-2022    |
| LAION-COCO        | 600M           | Sep-2022    |
| COYO-700M          | 747M           | Aug-2022    |

**细粒度图文(Fine-grained Image-Text)**

| 数据集(Dataset)        | 样本量(Samples) | 日期(Date)  |
| ---------------------- | -------------- | ----------- |
| ShareGPT4V-PT     | 1.2M           | Nov-2023    |
| LVIS-Instruct4V    | 111K           | Nov-2023    |
| ALLaVA            | 709K           | Feb-2024    |

**视频-文本(Video-Text)**

| 数据集(Dataset)        | 样本量(Samples) | 日期(Date)  |
| ---------------------- | -------------- | ----------- |
| MSR-VTT          | 200K           | 2016        |

**音频-文本(Audio-Text)**

| 数据集(Dataset)        | 样本量(Samples) | 日期(Date)  |
| ---------------------- | -------------- | ----------- |
| WavCaps           | 24K            | Mar-2023    |

粗粒度的图文描述数据通常具有以下典型特征: (1) 数据量大, 因为样本通常来自互联网. (2) 由于网络抓取的特性, 文本一般较短且噪声较多, 因为它们通常源自网页图像的alt-text. 这些数据可以通过自动化工具进行清洗和过滤, 例如使用CLIP模型[^10]过滤相似度低于预设阈值的图文对. 接下来, 作者将介绍一些具有代表性的粗粒度数据集.

**CC**[^82]. CC-3M是一个包含330万图文对的网络规模图文描述数据集, 其中原始描述源自与图像关联的alt-text. 研究者设计了一个复杂的管线来清洗数据: (1) 对于图像, 会过滤掉不适宜的内容或纵横比. (2) 对于文本, 使用NLP工具获取文本注释, 并根据设计的启发式规则过滤样本. (3) 对于图文对, 利用分类器为图像分配标签. 如果文本注释与图像标签不重叠, 则丢弃对应的样本. CC-12M[^83]是CC-3M的后续工作, 包含1240万图文对. 相比之前的工作, CC-12M放宽并简化了数据收集的流程, 因此收集到更多数据.

**SBU Captions**[^84]. 这是一个包含100万图文对的带描述照片数据集, 图像和描述都来自Flickr. 具体来说, 首先通过在Flickr网站上使用大量查询词获取初始图像集合, 图像所附的描述即作为图文描述. 然后, 为了确保描述与图像相关, 保留的图像需满足以下要求: (1) 图像描述的长度足够, 由实际观察决定. (2) 图像描述中至少包含预定义词表中的2个词以及一个表示空间关系的介词(例如"on", "under").

**LAION**. 这一系列是大规模网络数据集, 图像通过互联网爬取, 并将alt-text作为图文描述. 为了过滤图文对, 会执行以下步骤: (1) 丢弃文本过短或图像尺寸过小或过大的样本. (2) 基于URL进行图像去重. (3) 为图像和文本提取CLIP向量嵌入, 并利用这些嵌入丢弃可能包含非法内容以及嵌入余弦相似度较低的图文对. 以下是几个典型变体的简要概述:

* LAION-5B[^85]: 这是一个研究用途的数据集, 包含58.5亿图文对, 数据集是多语言的, 其中包含20亿张英文子集.
* LAION-COCO[^86]: 包含从LAION-5B英文子集中提取的6亿张图像. 这些图文描述是合成的, 通过BLIP[^87]生成各种图像描述, 并使用CLIP[^10]选择最适合该图像的描述.

**COYO-700M**[^88]. 该数据集包含7.47亿图文对, 提取自CommonCrawl. 在数据过滤方面, 作者设计了以下策略: (1) 对于图像, 会过滤掉尺寸、内容、格式或纵横比不合适的图像, 并根据pHash值去除与公共数据集(如ImageNet和MS-COCO)重叠的图像. (2) 对于文本, 只保留长度合适、具有名词形式和恰当词汇的英文文本. 会去除句子前后的空格, 并将连续空格替换为单个空格. 此外, 会丢弃出现超过10次的文本(例如"image for"). (3) 对于图文对, 基于(image pHash, text)元组去除重复样本.

最近, 越来越多的工作[^81][^89][^90]探索通过提示强大的多模态大语言模型(例如GPT-4V)来生成高质量的细粒度数据. 相比粗粒度数据, 这些数据通常包含更长且更准确的图像描述, 因此能够在图像与文本模态之间实现更精细的对齐. 然而, 由于这种方法通常需要调用商用多模态大语言模型, 成本更高, 且数据规模相对较小. 值得注意的是, ShareGPT4V通过先使用GPT-4V[^81]生成的10万条数据来训练一个描述生成器, 然后利用该预训练好的描述生成器将数据规模扩展到120万条, 在成本和数据量之间取得了平衡.

[^1]: Yin, S., Fu, C., Zhao, S., Li, K., Sun, X., Xu, T., & Chen, E. (2024). A survey on multimodal large language models. National Science Review, 11(12), nwae403. https://doi.org/10.1093/nsr/nwae403
[^2]: Touvron, H., Lavril, T., Izacard, G., Martinet, X., Lachaux, M.-A., Lacroix, T., Rozière, B., Goyal, N., Hambro, E., Azhar, F., Rodriguez, A., Joulin, A., Grave, E., & Lample, G. (2023). LLaMA: Open and efficient foundation language models (No. arXiv:2302.13971). arXiv. https://doi.org/10.48550/arXiv.2302.13971
[^3]: Peng, B., Li, C., He, P., Galley, M., & Gao, J. (2023). Instruction tuning with GPT-4 (No. arXiv:2304.03277). arXiv. https://doi.org/10.48550/arXiv.2304.03277
[^4]: Brown, T. B., Mann, B., Ryder, N., Subbiah, M., Kaplan, J., Dhariwal, P., Neelakantan, A., Shyam, P., Sastry, G., Askell, A., Agarwal, S., Herbert-Voss, A., Krueger, G., Henighan, T., Child, R., Ramesh, A., Ziegler, D. M., Wu, J., Winter, C., … Amodei, D. (2020). Language models are few-shot learners (No. arXiv:2005.14165). arXiv. https://doi.org/10.48550/arXiv.2005.14165
[^5]: Wei, J., Wang, X., Schuurmans, D., Bosma, M., Ichter, B., Xia, F., Chi, E., Le, Q., & Zhou, D. (2023). Chain-of-thought prompting elicits reasoning in large language models (No. arXiv:2201.11903). arXiv. https://doi.org/10.48550/arXiv.2201.11903
[^6]: Kirillov, A., Mintun, E., Ravi, N., Mao, H., Rolland, C., Gustafson, L., Xiao, T., Whitehead, S., Berg, A. C., Lo, W.-Y., Dollár, P., & Girshick, R. (2023). Segment anything (No. arXiv:2304.02643). arXiv. https://doi.org/10.48550/arXiv.2304.02643
[^7]: Shen, Y., Fu, C., Chen, P., Zhang, M., Li, K., Sun, X., Wu, Y., Lin, S., & Ji, R. (2023). Aligning and prompting everything all at once for universal visual perception (No. arXiv:2312.02153). arXiv. https://doi.org/10.48550/arXiv.2312.02153
[^8]: Zhang, H., Li, F., Liu, S., Zhang, L., Su, H., Zhu, J., Ni, L. M., & Shum, H.-Y. (2022). DINO: DETR with improved DeNoising anchor boxes for end-to-end object detection (No. arXiv:2203.03605). arXiv. https://doi.org/10.48550/arXiv.2203.03605
[^9]: Oquab, M., Darcet, T., Moutakanni, T., Vo, H., Szafraniec, M., Khalidov, V., Fernandez, P., Haziza, D., Massa, F., El-Nouby, A., Assran, M., Ballas, N., Galuba, W., Howes, R., Huang, P.-Y., Li, S.-W., Misra, I., Rabbat, M., Sharma, V., … Bojanowski, P. (2024). DINOv2: Learning robust visual features without supervision (No. arXiv:2304.07193). arXiv. https://doi.org/10.48550/arXiv.2304.07193
[^10]: Radford, A., Kim, J. W., Hallacy, C., Ramesh, A., Goh, G., Agarwal, S., Sastry, G., Askell, A., Mishkin, P., Clark, J., Krueger, G., & Sutskever, I. (2021). Learning transferable visual models from natural language supervision (No. arXiv:2103.00020). arXiv. https://doi.org/10.48550/arXiv.2103.00020
[^11]: Li, J., Selvaraju, R., Gotmare, A., Joty, S., Xiong, C., & Hoi, S. C. H. (2021). Align before fuse: Vision and language representation learning with momentum distillation. Advances in Neural Information Processing Systems, 34, 9694–9705. https://proceedings.neurips.cc/paper_files/paper/2021/hash/505259756244493872b7709a8a01b536-Abstract.html
[^12]: Chen, Y.-C., Li, L., Yu, L., Kholy, A. E., Ahmed, F., Gan, Z., Cheng, Y., & Liu, J. (2020). UNITER: UNiversal image-TExt representation learning (No. arXiv:1909.11740). arXiv. https://doi.org/10.48550/arXiv.1909.11740
[^13]: Wang, P., Yang, A., Men, R., Lin, J., Bai, S., Li, Z., Ma, J., Zhou, C., Zhou, J., & Yang, H. (2022). OFA: Unifying architectures, tasks, and modalities through a simple sequence-to-sequence learning framework (No. arXiv:2202.03052). arXiv. https://doi.org/10.48550/arXiv.2202.03052
[^14]: Cho, J., Lei, J., Tan, H., & Bansal, M. (2021). Unifying vision-and-language tasks via text generation (No. arXiv:2102.02779). arXiv. https://doi.org/10.48550/arXiv.2102.02779
[^15]: Wang, Z., Yu, J., Yu, A. W., Dai, Z., Tsvetkov, Y., & Cao, Y. (2022). SimVLM: Simple visual language model pretraining with weak supervision (No. arXiv:2108.10904). arXiv. https://doi.org/10.48550/arXiv.2108.10904
[^16]: Wei, J., Bosma, M., Zhao, V. Y., Guu, K., Yu, A. W., Lester, B., Du, N., Dai, A. M., & Le, Q. V. (2022). Finetuned language models are zero-shot learners (No. arXiv:2109.01652). arXiv. https://doi.org/10.48550/arXiv.2109.01652
[^17]: Liu, H., Li, C., Wu, Q., & Lee, Y. J. (2023). Visual instruction tuning (No. arXiv:2304.08485). arXiv. https://doi.org/10.48550/arXiv.2304.08485
[^18]: Zhu, D., Chen, J., Shen, X., Li, X., & Elhoseiny, M. (2023). MiniGPT-4: Enhancing vision-language understanding with advanced large language models (No. arXiv:2304.10592). arXiv. https://doi.org/10.48550/arXiv.2304.10592
[^19]: Yang, Z., Li, L., Wang, J., Lin, K., Azarnasab, E., Ahmed, F., Liu, Z., Liu, C., Zeng, M., & Wang, L. (2023). MM-REACT: Prompting ChatGPT for multimodal reasoning and action (No. arXiv:2303.11381). arXiv. https://doi.org/10.48550/arXiv.2303.11381
[^20]: Driess, D., Xia, F., Sajjadi, M. S. M., Lynch, C., Chowdhery, A., Ichter, B., Wahid, A., Tompson, J., Vuong, Q., Yu, T., Huang, W., Chebotar, Y., Sermanet, P., Duckworth, D., Levine, S., Vanhoucke, V., Hausman, K., Toussaint, M., Greff, K., … Florence, P. (2023). PaLM-E: An embodied multimodal language model (No. arXiv:2303.03378). arXiv. https://doi.org/10.48550/arXiv.2303.03378
[^21]: Awadalla, A., Gao, I., Gardner, J., Hessel, J., Hanafy, Y., Zhu, W., Marathe, K., Bitton, Y., Gadre, S., Sagawa, S., Jitsev, J., Kornblith, S., Koh, P. W., Ilharco, G., Wortsman, M., & Schmidt, L. (2023). OpenFlamingo: An open-source framework for training large autoregressive vision-language models (No. arXiv:2308.01390). arXiv. https://doi.org/10.48550/arXiv.2308.01390
[^22]: OpenAI, Achiam, J., Adler, S., Agarwal, S., Ahmad, L., Akkaya, I., Aleman, F. L., Almeida, D., Altenschmidt, J., Altman, S., Anadkat, S., Avila, R., Babuschkin, I., Balaji, S., Balcom, V., Baltescu, P., Bao, H., Bavarian, M., Belgum, J., … Zoph, B. (2024). GPT-4 technical report (No. arXiv:2303.08774). arXiv. https://doi.org/10.48550/arXiv.2303.08774
[^23]: Li, K., He, Y., Wang, Y., Li, Y., Wang, W., Luo, P., Wang, Y., Wang, L., & Qiao, Y. (2024). VideoChat: Chat-Centric Video Understanding (No. arXiv:2305.06355). arXiv. https://doi.org/10.48550/arXiv.2305.06355
[^24]: Zhang, H., Li, X., & Bing, L. (2023). Video-LLaMA: An Instruction-tuned Audio-Visual Language Model for Video Understanding (No. arXiv:2306.02858). arXiv. https://doi.org/10.48550/arXiv.2306.02858
[^25]: Deshmukh, S., Elizalde, B., Singh, R., & Wang, H. (2024). Pengi: An audio language model for audio tasks (No. arXiv:2305.11834). arXiv. https://doi.org/10.48550/arXiv.2305.11834
[^26]: Chen, K., Zhang, Z., Zeng, W., Zhang, R., Zhu, F., & Zhao, R. (2023). Shikra: Unleashing multimodal LLM’s referential dialogue magic (No. arXiv:2306.15195). arXiv. https://doi.org/10.48550/arXiv.2306.15195
[^27]: Yuan, Y., Li, W., Liu, J., Tang, D., Luo, X., Qin, C., Zhang, L., & Zhu, J. (2024). Osprey: Pixel understanding with visual instruction tuning (No. arXiv:2312.10032). arXiv. https://doi.org/10.48550/arXiv.2312.10032
[^28]: Han, J., Zhang, R., Shao, W., Gao, P., Xu, P., Xiao, H., Zhang, K., Liu, C., Wen, S., Guo, Z., Lu, X., Ren, S., Wen, Y., Chen, X., Yue, X., Li, H., & Qiao, Y. (2023). ImageBind-LLM: Multi-modality instruction tuning (No. arXiv:2309.03905). arXiv. https://doi.org/10.48550/arXiv.2309.03905
[^29]: Moon, S., Madotto, A., Lin, Z., Nagarajan, T., Smith, M., Jain, S., Yeh, C.-F., Murugesan, P., Heidari, P., Liu, Y., Srinet, K., Damavandi, B., & Kumar, A. (2023). AnyMAL: An efficient and scalable any-modality augmented language model (No. arXiv:2309.16058). arXiv. https://doi.org/10.48550/arXiv.2309.16058
[^30]: Wu, S., Fei, H., Qu, L., Ji, W., & Chua, T.-S. (2024). NExT-GPT: Any-to-Any Multimodal LLM (No. arXiv:2309.05519). arXiv. https://doi.org/10.48550/arXiv.2309.05519
[^31]: Hu, J., Yao, Y., Wang, C., Wang, S., Pan, Y., Chen, Q., Yu, T., Wu, H., Zhao, Y., Zhang, H., Han, X., Lin, Y., Xue, J., Li, D., Liu, Z., & Sun, M. (2024). Large Multilingual Models Pivot Zero-Shot Multimodal Learning across Languages (No. arXiv:2308.12038). arXiv. https://doi.org/10.48550/arXiv.2308.12038
[^32]: Bai, J., Bai, S., Yang, S., Wang, S., Tan, S., Wang, P., Lin, J., Zhou, C., & Zhou, J. (2023). Qwen-VL: A versatile vision-language model for understanding, localization, text reading, and beyond (No. arXiv:2308.12966). arXiv. https://doi.org/10.48550/arXiv.2308.12966
[^33]: Li, C., Wong, C., Zhang, S., Usuyama, N., Liu, H., Yang, J., Naumann, T., Poon, H., & Gao, J. (2023). LLaVA-med: Training a large language-and-vision assistant for biomedicine in one day (No. arXiv:2306.00890). arXiv. https://doi.org/10.48550/arXiv.2306.00890
[^34]: Moor, M., Huang, Q., Wu, S., Yasunaga, M., Zakka, C., Dalmia, Y., Reis, E. P., Rajpurkar, P., & Leskovec, J. (2023). Med-Flamingo: A Multimodal Medical Few-shot Learner (No. arXiv:2307.15189). arXiv. https://doi.org/10.48550/arXiv.2307.15189
[^35]: Zhang, X., Wu, C., Zhao, Z., Lin, W., Zhang, Y., Wang, Y., & Xie, W. (2024). PMC-VQA: Visual instruction tuning for medical visual question answering (No. arXiv:2305.10415). arXiv. https://doi.org/10.48550/arXiv.2305.10415
[^36]: Ye, J., Hu, A., Xu, H., Ye, Q., Yan, M., Dan, Y., Zhao, C., Xu, G., Li, C., Tian, J., Qi, Q., Zhang, J., & Huang, F. (2023). mPLUG-DocOwl: Modularized multimodal large language model for document understanding (No. arXiv:2307.02499). arXiv. https://doi.org/10.48550/arXiv.2307.02499
[^37]: Liu, Y., Yang, B., Liu, Q., Li, Z., Ma, Z., Zhang, S., & Bai, X. (2024). TextMonkey: An OCR-free large multimodal model for understanding document (No. arXiv:2403.04473). arXiv. https://doi.org/10.48550/arXiv.2403.04473
[^38]: Hu, A., Shi, Y., Xu, H., Ye, J., Ye, Q., Yan, M., Li, C., Qian, Q., Zhang, J., & Huang, F. (2024). mPLUG-PaperOwl: Scientific Diagram Analysis with the Multimodal Large Language Model (No. arXiv:2311.18248). arXiv. https://doi.org/10.48550/arXiv.2311.18248
[^39]: Huang, J., Yong, S., Ma, X., Linghu, X., Li, P., Wang, Y., Li, Q., Zhu, S.-C., Jia, B., & Huang, S. (2024). An embodied generalist agent in 3D world (No. arXiv:2311.12871). arXiv. https://doi.org/10.48550/arXiv.2311.12871
[^40]: Peng, Z., Wang, W., Dong, L., Hao, Y., Huang, S., Ma, S., & Wei, F. (2023). Kosmos-2: Grounding multimodal large language models to the world (No. arXiv:2306.14824). arXiv. https://doi.org/10.48550/arXiv.2306.14824
[^41]: Zhang, C., Yang, Z., Liu, J., Han, Y., Chen, X., Huang, Z., Fu, B., & Yu, G. (2023). AppAgent: Multimodal agents as smartphone users (No. arXiv:2312.13771). arXiv. https://doi.org/10.48550/arXiv.2312.13771
[^42]: Hong, W., Wang, W., Lv, Q., Xu, J., Yu, W., Ji, J., Wang, Y., Wang, Z., Zhang, Y., Li, J., Xu, B., Dong, Y., Ding, M., & Tang, J. (2024). CogAgent: A visual language model for GUI agents (No. arXiv:2312.08914). arXiv. https://doi.org/10.48550/arXiv.2312.08914
[^43]: Wang, J., Xu, H., Ye, J., Yan, M., Shen, W., Zhang, J., Huang, F., & Sang, J. (2024). Mobile-agent: Autonomous multi-modal mobile device agent with visual perception (No. arXiv:2401.16158). arXiv. https://doi.org/10.48550/arXiv.2401.16158
[^44]: Sun, Q., Fang, Y., Wu, L., Wang, X., & Cao, Y. (2023). EVA-CLIP: Improved training techniques for CLIP at scale (No. arXiv:2303.15389). arXiv. https://doi.org/10.48550/arXiv.2303.15389
[^45]: Fang, Y., Wang, W., Xie, B., Sun, Q., Wu, L., Wang, X., Huang, T., Wang, X., & Cao, Y. (2022). EVA: Exploring the limits of masked visual representation learning at scale (No. arXiv:2211.07636). arXiv. https://doi.org/10.48550/arXiv.2211.07636
[^46]: Cherti, M., Beaumont, R., Wightman, R., Wortsman, M., Ilharco, G., Gordon, C., Schuhmann, C., Schmidt, L., & Jitsev, J. (2023). Reproducible scaling laws for contrastive language-image learning. 2023 IEEE/CVF Conference on Computer Vision and Pattern Recognition (CVPR), 2818–2829. https://doi.org/10.1109/CVPR52729.2023.00276
[^47]: Fuyu-8B: A multimodal architecture for AI agents. (不详). 从 https://www.adept.ai/blog/fuyu-8b/
[^48]: Liu, H., Li, C., Li, Y., & Lee, Y. J. (2024). Improved baselines with visual instruction tuning (No. arXiv:2310.03744). arXiv. https://doi.org/10.48550/arXiv.2310.03744
[^49]: Li, Z., Yang, B., Liu, Q., Ma, Z., Zhang, S., Yang, J., Sun, Y., Liu, Y., & Bai, X. (2024). Monkey: Image resolution and text label are important things for large multi-modal models (No. arXiv:2311.06607). arXiv. https://doi.org/10.48550/arXiv.2311.06607
[^50]: McKinzie, B., Gan, Z., Fauconnier, J.-P., Dodge, S., Zhang, B., Dufter, P., Shah, D., Du, X., Peng, F., Weers, F., Belyi, A., Zhang, H., Singh, K., Kang, D., Jain, A., Hè, H., Schwarzer, M., Gunter, T., Kong, X., … Yang, Y. (2024). MM1: Methods, analysis & insights from multimodal LLM pre-training (No. arXiv:2403.09611). arXiv. https://doi.org/10.48550/arXiv.2403.09611
[^51]: Lin, Z., Liu, C., Zhang, R., Gao, P., Qiu, L., Xiao, H., Qiu, H., Lin, C., Shao, W., Chen, K., Han, J., Huang, S., Zhang, Y., He, X., Li, H., & Qiao, Y. (2023). SPHINX: The joint mixing of weights, tasks, and visual embeddings for multi-modal large language models (No. arXiv:2311.07575). arXiv. https://doi.org/10.48550/arXiv.2311.07575
[^52]: Elizalde, B., Deshmukh, S., Ismail, M. A., & Wang, H. (2022). CLAP: Learning audio concepts from natural language supervision (No. arXiv:2206.04769). arXiv. https://doi.org/10.48550/arXiv.2206.04769
[^53]: Girdhar, R., El-Nouby, A., Liu, Z., Singh, M., Alwala, K. V., Joulin, A., & Misra, I. (2023). ImageBind: One embedding space to bind them all (No. arXiv:2305.05665). arXiv. https://doi.org/10.48550/arXiv.2305.05665
[^54]: Chung, H. W., Hou, L., Longpre, S., Zoph, B., Tay, Y., Fedus, W., Li, Y., Wang, X., Dehghani, M., Brahma, S., Webson, A., Gu, S. S., Dai, Z., Suzgun, M., Chen, X., Chowdhery, A., Castro-Ros, A., Pellat, M., Robinson, K., … Wei, J. (2022). Scaling instruction-finetuned language models (No. arXiv:2210.11416). arXiv. https://doi.org/10.48550/arXiv.2210.11416
[^55]: Li, J., Li, D., Savarese, S., & Hoi, S. (2023). BLIP-2: Bootstrapping language-image pre-training with frozen image encoders and large language models (No. arXiv:2301.12597). arXiv. https://doi.org/10.48550/arXiv.2301.12597
[^56]: Dai, W., Li, J., Li, D., Tiong, A. M. H., Zhao, J., Wang, W., Li, B., Fung, P., & Hoi, S. (2023). InstructBLIP: Towards general-purpose vision-language models with instruction tuning (No. arXiv:2305.06500). arXiv. https://doi.org/10.48550/arXiv.2305.06500
[^57]: Vicuna: An open-source chatbot impressing GPT-4 with 90%* ChatGPT quality | LMSYS org. (不详). 从 https://lmsys.org/blog/2023-03-30-vicuna
[^58]: Bai, J., Bai, S., Chu, Y., Cui, Z., Dang, K., Deng, X., Fan, Y., Ge, W., Han, Y., Huang, F., Hui, B., Ji, L., Li, M., Lin, J., Lin, R., Liu, D., Liu, G., Lu, C., Lu, K., … Zhu, T. (2023). Qwen technical report (No. arXiv:2309.16609). arXiv. https://doi.org/10.48550/arXiv.2309.16609
[^59]: Lee, H. L., Chunyuan Li, Yuheng Li, Bo Li, Yuanhan Zhang, Sheng Shen, Yong Jae. (2024, 一月 30). LLaVA-NeXT: Improved reasoning, OCR, and world knowledge. LLaVA. https://llava-vl.github.io/blog/2024-01-30-llava-next/
[^60]: Lu, Y., Li, C., Liu, H., Yang, J., Gao, J., & Shen, Y. (2023). An empirical study of scaling instruct-tuned large multimodal models (No. arXiv:2309.09958). arXiv. https://doi.org/10.48550/arXiv.2309.09958
[^61]: Chu, X., Qiao, L., Lin, X., Xu, S., Yang, Y., Hu, Y., Wei, F., Zhang, X., Zhang, B., Wei, X., & Shen, C. (2023). MobileVLM: A fast, strong and open vision language assistant for mobile devices (No. arXiv:2312.16886). arXiv. https://doi.org/10.48550/arXiv.2312.16886
[^62]: Chu, X., Qiao, L., Zhang, X., Xu, S., Wei, F., Yang, Y., Sun, X., Hu, Y., Lin, X., Zhang, B., & Shen, C. (2024). MobileVLM V2: Faster and stronger baseline for vision language model (No. arXiv:2402.03766). arXiv. https://doi.org/10.48550/arXiv.2402.03766
[^63]: Shen, S., Hou, L., Zhou, Y., Du, N., Longpre, S., Wei, J., Chung, H. W., Zoph, B., Fedus, W., Chen, X., Vu, T., Wu, Y., Chen, W., Webson, A., Li, Y., Zhao, V., Yu, H., Keutzer, K., Darrell, T., & Zhou, D. (2023). Mixture-of-experts meets instruction tuning:a winning combination for large language models (No. arXiv:2305.14705). arXiv. https://doi.org/10.48550/arXiv.2305.14705
[^64]: Jiang, A. Q., Sablayrolles, A., Roux, A., Mensch, A., Savary, B., Bamford, C., Chaplot, D. S., Casas, D. de las, Hanna, E. B., Bressand, F., Lengyel, G., Bour, G., Lample, G., Lavaud, L. R., Saulnier, L., Lachaux, M.-A., Stock, P., Subramanian, S., Yang, S., … Sayed, W. E. (2024). Mixtral of experts (No. arXiv:2401.04088). arXiv. https://doi.org/10.48550/arXiv.2401.04088
[^65]: Fedus, W., Zoph, B., & Shazeer, N. (2022). Switch transformers: Scaling to trillion parameter models with simple and efficient sparsity (No. arXiv:2101.03961). arXiv. https://doi.org/10.48550/arXiv.2101.03961
[^66]: Lin, B., Tang, Z., Ye, Y., Huang, J., Zhang, J., Pang, Y., Jin, P., Ning, M., Luo, J., & Yuan, L. (2024). MoE-LLaVA: Mixture of experts for large vision-language models (No. arXiv:2401.15947). arXiv. https://doi.org/10.48550/arXiv.2401.15947
[^67]: Carion, N., Massa, F., Synnaeve, G., Usunier, N., Kirillov, A., & Zagoruyko, S. (2020). End-to-end object detection with transformers (No. arXiv:2005.12872). arXiv. https://doi.org/10.48550/arXiv.2005.12872
[^68]: Chen, F., Han, M., Zhao, H., Zhang, Q., Shi, J., Xu, S., & Xu, B. (2023). X-LLM: Bootstrapping advanced large language models by treating multi-modalities as foreign languages (No. arXiv:2305.04160). arXiv. https://doi.org/10.48550/arXiv.2305.04160
[^69]: Su, Y., Lan, T., Li, H., Xu, J., Wang, Y., & Cai, D. (2023). PandaGPT: One model to instruction-follow them all (No. arXiv:2305.16355). arXiv. https://doi.org/10.48550/arXiv.2305.16355
[^70]: Pi, R., Gao, J., Diao, S., Pan, R., Dong, H., Zhang, J., Yao, L., Han, J., Xu, H., Kong, L., & Zhang, T. (2023). DetGPT: Detect what you need via reasoning (No. arXiv:2305.14167). arXiv. https://doi.org/10.48550/arXiv.2305.14167
[^71]: Zeng, Y., Zhang, H., Zheng, J., Xia, J., Wei, G., Wei, Y., Zhang, Y., & Kong, T. (2023). What matters in training a GPT4-style language model with multimodal inputs? (No. arXiv:2307.02469). arXiv. https://doi.org/10.48550/arXiv.2307.02469
[^72]: Alayrac, J.-B., Donahue, J., Luc, P., Miech, A., Barr, I., Hasson, Y., Lenc, K., Mensch, A., Millican, K., Reynolds, M., Ring, R., Rutherford, E., Cabi, S., Han, T., Gong, Z., Samangooei, S., Monteiro, M., Menick, J., Borgeaud, S., … Simonyan, K. (2022). Flamingo: A visual language model for few-shot learning (No. arXiv:2204.14198). arXiv. https://doi.org/10.48550/arXiv.2204.14198
[^73]: Wang, W., Lv, Q., Yu, W., Hong, W., Qi, J., Wang, Y., Ji, J., Yang, Z., Zhao, L., Song, X., Xu, J., Xu, B., Li, J., Dong, Y., Ding, M., & Tang, J. (2024). CogVLM: Visual expert for pretrained language models (No. arXiv:2311.03079). arXiv. https://doi.org/10.48550/arXiv.2311.03079
[^74]: Zhang, R., Han, J., Liu, C., Gao, P., Zhou, A., Hu, X., Yan, S., Lu, P., Li, H., & Qiao, Y. (2024). LLaMA-adapter: Efficient fine-tuning of language models with zero-init attention (No. arXiv:2303.16199). arXiv. https://doi.org/10.48550/arXiv.2303.16199
[^75]: Yin, S., Fu, C., Zhao, S., Xu, T., Wang, H., Sui, D., Shen, Y., Li, K., Sun, X., & Chen, E. (2024). Woodpecker: Hallucination correction for multimodal large language models. Science China Information Sciences, 67(12), 220105. https://doi.org/10.1007/s11432-024-4251-x
[^76]: Guo, J., Li, J., Li, D., Tiong, A. M. H., Li, B., Tao, D., & Hoi, S. C. H. (2023). From images to textual prompts: Zero-shot VQA with frozen large language models (No. arXiv:2212.10846). arXiv. https://doi.org/10.48550/arXiv.2212.10846
[^77]: Wang, T., Zhang, J., Fei, J., Zheng, H., Tang, Y., Li, Z., Gao, M., & Zhao, S. (2023). Caption anything: Interactive image description with diverse multimodal controls (No. arXiv:2305.02677). arXiv. https://doi.org/10.48550/arXiv.2305.02677
[^78]: Zhu, D., Chen, J., Haydarov, K., Shen, X., Zhang, W., & Elhoseiny, M. (2023). ChatGPT asks, BLIP-2 answers: Automatic questioning towards enriched visual descriptions (No. arXiv:2303.06594). arXiv. https://doi.org/10.48550/arXiv.2303.06594
[^79]: Ye, Q., Xu, H., Xu, G., Ye, J., Yan, M., Zhou, Y., Wang, J., Hu, A., Shi, P., Shi, Y., Li, C., Xu, Y., Chen, H., Tian, J., Qian, Q., Zhang, J., Huang, F., & Zhou, J. (2024). mPLUG-owl: Modularization empowers large language models with multimodality (No. arXiv:2304.14178). arXiv. https://doi.org/10.48550/arXiv.2304.14178
[^80]: Wang, W., Chen, Z., Chen, X., Wu, J., Zhu, X., Zeng, G., Luo, P., Lu, T., Zhou, J., Qiao, Y., & Dai, J. (2023). VisionLLM: Large language model is also an open-ended decoder for vision-centric tasks (No. arXiv:2305.11175). arXiv. https://doi.org/10.48550/arXiv.2305.11175
[^81]: Chen, L., Li, J., Dong, X., Zhang, P., He, C., Wang, J., Zhao, F., & Lin, D. (2023). ShareGPT4V: Improving large multi-modal models with better captions (No. arXiv:2311.12793). arXiv. https://doi.org/10.48550/arXiv.2311.12793
[^82]: Sharma, P., Ding, N., Goodman, S., & Soricut, R. (2018). Conceptual captions: A cleaned, hypernymed, image alt-text dataset for automatic image captioning. 收入 I. Gurevych & Y. Miyao (编), Proceedings of the 56th Annual Meeting of the Association for Computational Linguistics (Volume 1: Long Papers) (页 2556–2565). Association for Computational Linguistics. https://doi.org/10.18653/v1/P18-1238
[^83]: Changpinyo, S., Sharma, P., Ding, N., & Soricut, R. (2021). Conceptual 12M: Pushing web-scale image-text pre-training to recognize long-tail visual concepts (No. arXiv:2102.08981). arXiv. https://doi.org/10.48550/arXiv.2102.08981
[^84]: Ordonez, V., Kulkarni, G., & Berg, T. (2011). Im2Text: Describing images using 1 million captioned photographs. Advances in Neural Information Processing Systems, 24. https://papers.nips.cc/paper_files/paper/2011/hash/5dd9db5e033da9c6fb5ba83c7a7ebea9-Abstract.html
[^85]: Schuhmann, C., Beaumont, R., Vencu, R., Gordon, C., Wightman, R., Cherti, M., Coombes, T., Katta, A., Mullis, C., Wortsman, M., Schramowski, P., Kundurthy, S., Crowson, K., Schmidt, L., Kaczmarczyk, R., & Jitsev, J. (2022). LAION-5B: An open large-scale dataset for training next generation image-text models (No. arXiv:2210.08402). arXiv. https://doi.org/10.48550/arXiv.2210.08402
[^86]: Laion coco: 600M synthetic captions from Laion2B-en | LAION. (不详). 从 https://laion.ai/blog/laion-coco/
[^87]: Li, J., Li, D., Xiong, C., & Hoi, S. (2022). BLIP: Bootstrapping language-image pre-training for unified vision-language understanding and generation (No. arXiv:2201.12086). arXiv. https://doi.org/10.48550/arXiv.2201.12086
[^88]: kakaobrain/coyo-dataset: COYO-700M: large-scale image-text pair dataset. (不详). 从 https://github.com/kakaobrain/coyo-dataset
[^89]: Wang, J., Meng, L., Weng, Z., He, B., Wu, Z., & Jiang, Y.-G. (2023). To see is to believe: Prompting GPT-4V for better visual instruction tuning (No. arXiv:2311.07574). arXiv. https://doi.org/10.48550/arXiv.2311.07574
[^90]: Chen, G. H., Chen, S., Zhang, R., Chen, J., Wu, X., Zhang, Z., Chen, Z., Li, J., Wan, X., & Wang, B. (2024). ALLaVA: Harnessing GPT4V-synthesized data for lite vision-language models (No. arXiv:2402.11684). arXiv. https://doi.org/10.48550/arXiv.2402.11684
