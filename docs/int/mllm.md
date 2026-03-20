---
title: MLLM
comments: false
---

## CLIP

1. 什么是CLIP? 它解决了什么问题?

    CLIP是视觉-语言预训练模型, 全称Contrasive Language-Image Pretraining. 它的核心目标不是生成文本, 而是把图像和文本映射到同一个语义空间中, 让匹配的图文更加接近, 不匹配的更远. 它解决的问题是: 如何利用大规模的图文对, 而不是依赖人工分类标签, 来学习更通用的视觉表示.

2. CLIP的模型结构是什么?

    CLIP一般由两个编码器组成: 一个图像编码器, 一个文本编码器. 图像编码器可以是ResNet或者ViT, 文本编码器通常是Transformer. 两边分别把输入编码为向量, 然后投影到同一个embedding space, 最后通过相似度来判断图文是否匹配.

3. CLIP的训练目标是啥?

    CLIP使用对比学习, 训练的时候给定一个batch的图文对. 模型会计算所有图片和所有文本之间的相似度矩阵. 正确配对应该相似度较高, 错误配对应该相似度较低. 损失函数本质上是双向cross-entropy, 对图到文和文到图都做匹配学习.

4. 为什么CLIP可以做zero-shot classification?

    因为CLIP学到的是图像和语言的对应关系, 而不是固定类别分类头. 测试的时候可以把类别名称写成文本提示, 比如"a photo of a cat"和"a photo of a dog", 再和图片向量做相似度比较, 哪个更高就预测哪个类别, 所以不需要为下游任务单独训练分类器.

5. CLIP和普通的图像分类模型有什么区别?

    普通分类模型通常只输出固定类别, 依赖人工标签训练, 泛化到新的类别的时候往往需要微调. CLIP则是学习图像和文本的共享表示, 类别是通过自然语言动态定义的, 所以它更加灵活, 尤其适合zero-shot和跨模态检索任务.

6. CLIP和SimCLR这类纯视觉对比学习有什么区别?

    SimCLR是图像和图像之间做对比学习, 正样本通常来自同一张图像的不同增强视图; CLIP是图像和文本之间做跨模态的对比学习. CLIP的监督信号来自自然语言, 因此语义更加丰富, 也更容易迁移到开放词汇任务.

7. prompt engineering为什么会影响CLIP的效果?

    因为CLIP的文本侧输入的并不是纯类别名, 而是自然语言描述. 不同prompt模板会改变文本向量的位置, 比如"dog"和"a photo of a dog"的表达语义不同. 好的prompt更接近训练时候的语言分布, 所以通常会提升zero-shot分类效果.

8. CLIP的典型应用场景有哪些?

    典型应用包括zero-shot图像分类, 图文检索, 以文搜图, 图像去重, 跨模态搜索, 多模态表示学习. 它也常被当作视觉backbone, 为后续生成式多模态模型提供图像表示.

9. CLIP的主要优点是啥?

    第一, 它减少了对人工标签的依赖, 可以直接使用互联网图文对训练; 第二, 它具备较强的zero-shot泛化能力; 第三, 它学到的是开放式的词汇表示, 而不是封闭类别集合; 第四, 它在图文检索等跨模态任务上非常自然.

10. CLIP的主要缺点或者局限是啥?

    它对prompt比较敏感, 在细粒度分类, 计数, 空间关系, 逻辑推理等任务上往往不够强; 训练数据来自互联网, 可能带来偏见问题; 它更擅长匹配和表征, 而不是复杂推理或生成.

11. CLIP更像生成模型还是表征模型?

    那肯定是更像表征模型. 它的核心是学习图像和文本的联合embedding, 而不是生成文本或者图像. 它的输出是相似度或者向量表示, 因此擅长检索和分类, 而不是典型的生成式视觉语言模型.

12. 如果让你改进CLIP, 你会从哪些方面下手?

    可以从四个方面说: 一是提升数据质量, 减少噪声图文对; 二是设计更强的对比目标或者hard negative mining; 三是引入更强的视觉和文本backbone; 四是和生成式模型结合, 增强推理与细粒度理解能力.

## BLIP

BLIP, Boostrapping Language-Image Pre-training, 它的定义是一个统一的视觉-语言预训练框架, 即能做理解类任务, 也能做生成类任务.

1. 什么是BLIP, 它想解决什么问题?

    BLIP是Salesforce提出的视觉语言预训练框架, 目标是统一支持视觉语言理解任务和生成任务. 作者提出, 之前很多的VLP模型往往只擅长其中一类任务, 而且训练数据通常来自带噪声的网页图文对, 所以BLIP一方面从模型结构上做统一, 另一方面从数据上通过caption bootstraping处理噪声.

2. BLIP的核心创新点是啥?

    可以概括为两点: 第一个是MED, Multimodal Mixture of Encoder-Decoder, 也就是通过共享参数, 把模型切换为不同模式再去做理解或生成. 第二个是Caption Bootstraping, 先用captioner生成合成描述, 再用filter过滤噪声图文对, 从而提升预训练数据质量.

3. MED是啥

    MED是BLIP里面比较核心架构名. 它的意思是同一套视觉语言模型, 可以切换为多种不同的工作方式, 分别去做对齐, 匹配, 生成这三类任务.

    可以将它理解为一套骨架, 三种用法的统一框架, 第一种模式是unimodal encoder, 图像和文本各自编码, 不做跨模态融合, 主要服务于ITC, 也就是图文对比学习; 第二种模式是image-grounded text encoder, 会在文本侧加入cross-attention去看图像特征, 主要服务于ITM, 也就是图文匹配; 第三种模式是image-grounded text decoder, 把文本侧换为casual self-attention, 再结合图像特征做条件生成, 主要服务于LM, 也就是根据图像生成文本. 这样做的好处是, 多个任务之间可以共享表示和参数.

4. 为啥我们不能抛弃ITC, 直接用ITM呢?

    因为ITC负责先把图文"拉到一个对的语义空间里面", ITM再负责更细的配对判别. 可以从三个角度理解:

    1. 计算方式不太一样. ITC是双塔思路, 图像单独编码一次, 文本单独编码一次, 然后计算相似度就行, 这非常适合大规模的检索, 比如100万张图匹配1条文本查询. 但是ITM不是, ITM依赖cross-attention, 是单塔模型, 也就是"这张图和这句话要放在一起交互之后, 模型才能判断配不配". 这意味着每一个图文候选对就要跑一遍融合模型, 如果是1条文本对和100万张图, ITM没法直接这么干, 成本太高.  所以ITC适合召回, ITM适合重排.
    2. 学习粒度不一样: ITC学习的是全局语义空间. 让"猫的图"靠近"cat"的文本, 这一步让模型建立一个整体的跨模态集合结构. 如果一开始用的是ITM, 它的损失是二分类交叉熵损失, 模型看到的只是"这是正样本/这是负样本"的二分类信号, 它当然也能学习到一些匹配关系, 但是未必学出一个好用, 规整, 可检索的embedding space. 所以ITC在塑造表示空间, ITM在做判别边界.
    3. 训练难度和泛化目标不同: ITC会在一个batch里面天然构造很多负样本, 训练信号密, 覆盖广, 能够快速学到粗粒度对齐. ITM更像"最后一公里"的细判别, 擅长学属性, 关系, 局部细节, 但是如果没有前面的粗对齐, ITM一上来就要处理复杂融合, 训练不一定稳, 也不一定高效.

5. 术语

    * ITC: Image-Text Contrasive
    * ITM: Image-Text Matching
    * LM: Language Modeling
    * Image-Grounded Text Encoder
    * Image-Grounded Text Decoder
    * Image Encoder
    * Text Encoder

6. BLIP为什么既能做理解任务又能做生成任务?

    因为它不是只训练一个对比目标, 也不是只训练一个语言生成目标. BLIP在预训练里面联合考虑了图文对齐, 图文匹配和语言生成等目标, 再配合MED的不同工作模式, 所以它既能用于image-text retrieval, VQA这类理解任务, 也能用于image captioning这类生成任务.

7. BLIP里面caption bootstraping是啥? 为什么有功效?

    网页上原始的alt-text常常噪声很大, 和图像并不是严格对应的. BLIP的做法是先训练一个captioner为图片生成更加干净的文本, 再训练一个filter去筛选到不可靠的配对. 这样做的本质是用模型反过来训练清洗数据, 提升监督信号质量, 所以在多个任务上都有收益.

8. BLIP和CLIP的区别是啥?

    CLIP更加偏向图文对齐和表示学习, 核心是对比学习, 擅长zero-shot分类和检索; BLIP则进一步追求理解+生成统一, 除了匹配能力, 还显式支持caption生成, VQA等任务.

9. BLIP的优势是啥?

    第一, 它统一了理解和生成, 不像一些旧方法比较偏科; 第二, 它显式处理noisy web data, 而不是被动接受噪声数据; 第三, 论文报告它在retrieval, captioning, VQA上都达到了当时的SOTA, 说明这种统一框架是有效的.

10. BLIP的局限是啥?

    论文主打统一和数据清洗, 但是它仍然属于较早期的vision-language pretraing路线, 和后来的大模型相比, 在复杂多轮对话, 开放式推理, 指令跟随方面能力有限; 虽然它缓解了网页数据噪声, 但是不能彻底解决数据偏差和错配的问题.

## BLIP2

BLIP-2的核心思想是冻结图像编码器, 冻结大预言模型, 只训练一个轻量的桥接模块Q-former, 用两阶段的预训练把视觉信息对齐到语言模型. 论文里强调, 这样可以显著减低训练成本, 同时在多种视觉语言任务上保持很强的效果; 例如论文摘要中给出的例子, BLIP-2在zero-shot VQAv2上超过Flamingo80B 8.7%, 而可训练参数少54倍. 

1. 什么是BLIP-2, 他想解决什么问题?

    BLIP-2是一种视觉语言预训练方法, 目标是更低成本地把现成的强视觉模型和强语言模型组合为多模态模型. 他要解决的问题是: 端到端训练大型视觉语言模型太贵, 而冻结LLM后又很难完成视觉-语言对齐, 所以他引入了Q-former来桥接两种模态. 

2. BLIP-2的整体架构是什么?

    他由三部分组成: 一个冻结的图像编码器, 一个可训练的Q-former, 一个冻结的大预言模型. Q-former负责从视觉编码器输出里提取对预言最有用的视觉信息, 再把这些信息发给LLM. Hugging Face文档把BLIP-2明确描述为vision encoder + Q-former + language model. 

3. 什么是Q-former, 为什么他是核心?

    Q-former是Querying Transformer. 他通过一组可学习的query embeddings, 从冻结图像编码器的特征里面"查询"出固定数量的视觉表示. 论文把它定义为连接frozen image encoder和frozen LLM的可训练模块, 也强调它是一个information bottleneck, 只把最有用的视觉信息传给预言模型. 

4. Q-former的内部结构是啥?

    Q-former由两个共享self-attention的transformer子模块构成, 一个是image transformer, 负责和冻结的视觉特征交互; 另一个是text transformer, 既可以当text encoder, 也可以当text decoder. 这里最容易误解的点是"两个子模块"并不表示两套完全独立参数, 而是他们共同采用了self-attention的主干, 只是在是否接入图像cross-attention, 以及attention-mask怎么设定上不同. 论文还说明, query之间通过self-attention彼此交互, 同时通过cross-attention去读取冻结图像编码器的输出; 这些cross-attention层是每隔一个attention block插入一次的. 
     
    更具体地说, 先把图像送入冻结的 ViT/CLIP 类图像编码器, 得到一串视觉 token; 然后 32 个 query token 进入 Q-Former, 在自注意力里彼此通信, 并通过交叉注意力去"查询"这串视觉 token; 经过多层后, 输出 32 个更紧凑的 query 表征. 若当前任务需要结合文本, 这些 query 还会和文本 token 通过同一套 self-attention 层发生交互; 若进入第二阶段接 LLM, 则这些 query 输出会先经过一个线性层投影到 LLM 的词向量维度, 再作为 soft visual prompts 拼接到 LLM 输入前面. 

5. Q-former的训练是咋样子的

    <figure markdown='1' id='fig'>
    ![](https://img.ricolxwz.cn/a91d65c6298588ae016f475965f8eca4.webp#only-light){ loading=lazy width='800' }
    ![](https://img.ricolxwz.cn/a91d65c6298588ae016f475965f8eca4_inverted.webp#only-dark){ loading=lazy width='800' }
    <figcaption>图: 第一阶段训练. 通过mask控制MED.</figcaption>
    </figure>

    <figure markdown='1' id='fig'>
    ![](https://img.ricolxwz.cn/f7b076d1f587fb270a5da4ff2da305f0.webp#only-light){ loading=lazy width='800' }
    ![](https://img.ricolxwz.cn/f7b076d1f587fb270a5da4ff2da305f0_inverted.webp#only-dark){ loading=lazy width='800' }
    <figcaption>图: 第二阶段训练. </figcaption>
    </figure>
