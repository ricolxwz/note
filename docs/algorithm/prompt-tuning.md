---
title: 提示调优
comments: true
---

# 提示调优[^1]

## 概要

在这项工作中, 作者探索了提示调优, 这是一种简单而又有效的机制, 用于学习软提示来调节冻结的语言模型以执行特定的下游任务. 和GPT-3使用的[离散文本提示](/dicts/discrete-text-prompt)不同, 软提示不是人类可读的自然语言, 它的提示信息是以可训练向量(embedding)的形式存在的, 通过给模型提供带有标签的数据并使用反向传播, 软提示会不断学习和调整自身的向量表示, 以整合更多来自标注样本的信号, 从而更好地适应特定的任务需求. 作者提出的[端到端学习](/dicts/end-to-end-learning)远远优于GPT-3的[小样本学习](/dicts/few-shot-learning). 通过对T5模型在不同规模(参数量)下进行[消融实验](/dicts/ablation)(这里的消融针对于模型的规模), 研究人员发现, 随着模型参数规模增大(超过十亿参数), 提示调优的方法变得越来越具有竞争力, 最终, 当模型足够大的时候, 仅使用提示调优就能取得与对所有模型权重进行微调相当的效果, 换句话说, 在大规模模型上, 提示调优和全量微调之间的性能差距会逐渐缩小, 直到几乎能够持平. 这一发现尤其重要, 因为大型模型的共享和服务成本高, 而能够将一个冻结的模型复用于多个下游任务可以减轻这一负担. 作者的方法可以被视为Li和Liang最近提出的前缀调优(prefix tuning)的简化, 作者提供了一个提示调优和前缀调优以及其他类似方法的比较. 最后, 作者展示了通过软提示对冻结模型进行[条件化](/dicts/conditioning), 提高在领域迁移中的稳健性, 并支持高效的[提示集成](/dicts/prompt-ensembling)(prompt ensembling).

## 背景

### 微调成为主流

随着预训练大型语言模型的成功, 出现了一系列技术来将调试这些通用模型以适应下游任务. ELMo[^2]建议冻结预训练模型并学习其每层的表示在特定任务下的权重. 然而, 自从GPT[^3]和BERT[^4]出现以来, 主流的适应技术已经变成了模型调优(或者称为"微调"), 通常, 这种"微调"是全量的, 即在适应的过程中所有的参数都要被调整.

### 冻结的回归: 提示设计

最近, Brown等人的研究表明, 提示设计(prompt design), 或者说是概要中提到的[离散文本提示](/dicts/discrete-text-prompt), 在通过自然语言文本提示调节冻结的GPT-3模型的行为方面出人意料地有效. 这种方法通常在模型的输入中直接加入自然语言下的任务描述, 示例或者其他指令, 以在无需修改模型的内部参数的情况下影响模型的输出行为. 这种回归到ElMo那种模型冻结的兴趣重燃很具有吸引力, 特别是随着预训练模型的尺寸不断增加, 不需要为每个下游任务都设计一个不同的副本, 而是直接将这个预训练模型直接服务于许多不同的任务.

#### 提示设计的缺陷

然而, 基于提示的调试有几个主要的缺点: 任务描述容易出错需要人工参与; 提示的有效性受到模型的输入能够容纳多少条件文本的限制(因为序列长度是定死的, 条件文本越多, 实际内容越少). 因此, 在下游任务的表现仍然远远落后于微调后的模型, 例如, 使用[提示设计](/dicts/discrete-text-prompt)的GPT-3 175B在SuperGLUE上的few-shot性能为71.8, 而T5-XXL在SuperGLUE上的性能为89.3, 更何况GPT-3的参数数量是T5-XXL的16倍.

##### 自动提示设计

最近有一些研究试图将提示设计的过程自动化, 来解决上述的第一个问题. Shin等人[^6]提出了一种在[离散的词空间](/dicts/discrete-text-prompt)上进行搜索的算法, 这个搜索过程会受到下游任务的训练数据的指导, 也就是说他们会利用任务相关的数据来逐步搜索, 来选择哪些单词更适合当作提示词. 虽然这种技术优于手动提示词设计, 但是对于模型微调还是存在差距.

### 前缀调优

Li和Liang提出的前缀调优在生成任务上展现出了很好的效果[^7]. 它们的主要思路是, 在进行模型微调的时候, 固定住预训练模型中的所有参数, 然后在编码器堆栈(包括输入层)的每一层前面加入一段可训练的前缀向量(prefix activations). 在模型反向传播的过程中, 只有这些前缀向量的参数会被更新, 其余的预训练模型参数保持不变. Hambardzumyan等人在此基础上做了进一步的简化[^8], 他们只在掩码语言模型(MLM)的输入和输出子网络中加入可训练的前缀向量, 将其他部分全部冻结, 同样能在文本分类等判别性任务上取得相当不错的成果.

### 提示调优

???+ warning "深入理解"

    个人想法: 提示调优其实就是提示设计和前缀调优缝合得到的结果. 因为提示设计里面那几个附加的提示$P$的嵌入规则由于嵌入矩阵是被预训练模型定义死的, 所以我们只能被动的手动或者使用非微分搜索找到最合适的token用于提示. 作者应该是想到了前缀调优中在每一层前面加一个可学习的嵌入, 所以想到了能不能把预训练模型的嵌入和提示的嵌入分开, 后者由另外的嵌入矩阵来定义. 相当于**提示设计找的是最优提示的tokens, 提示调优找的是最优提示的embeddings, 两者都魔改了输入序列, 但是前缀调优没有魔改输入序列. 正是因为提示设计难以找到最优提示的token(需要手动或者非微分搜索), 并且前缀调优需要在中间各层添加前缀嵌入(prefix activations)导致性能较低, 才想出了这个缝合怪, 直接通过反向传播找到最优提示的embeddings.**

在这个研究中, 作者提出了提示调优, prompt tuning, 进一步简化语言模型适应的方法. 他们将整个预训练模型冻结, 只允许在下游任务的**输入文本前额外添加$k$个可训练的虚拟token**, 注意, 这$k$个虚拟token/软提示本质上是嵌入向量, 而不是人类能理解的自然字词. 这种软提示通过[端到端训练](/dicts/end-to-end-learning), 能够从完整标注的数据集中提炼信息, 这使得他们的模型能够比使用提示设计的模型要好, 并且缩小了和微调之间的差距(如下图一所示). 同时, 由于对所有下游任务都重用一个预训练模型, 他们也保留了冻结模型在推理阶段的高效率优势(如下图二所示).

???+ note "什么是虚拟token"

    提示调优中的token和提示设计中的token不同, 前者往往可以看作只是一个"占位符", 模型只需要知道这个占位符对应embedding层中的某个嵌入向量就可以了, 不是人类可以理解的自然语言. 提示设计中的token对应的是某个自然语言片段. ^^正是因为上述的原因, 提示调优中的提示又被称为"软提示".^^ 特别注意[token和embedding的区别](/dicts/token-embedding-encoding).

<figure markdown='1'>
![](https://img.ricolxwz.asia/0c186e6eed6547498ac06b65886f1654.webp#only-light){ loading=lazy width='400' }
![](https://img.ricolxwz.asia/0c186e6eed6547498ac06b65886f1654_inverted.webp#only-dark){ loading=lazy width='400' }
<figcaption>图一: T5模型的微调性能优异, 但是对每个任务都要一个副本. 作者提出的提示调优的质量和微调模型随着预训练模型参数增长保持一致并保证对于所有的任务都只用一个冻结的模型. 他们的方法远远超过了对GPT-3进行提示设计的效果</figcaption>
</figure>

<figure markdown='1'>
![](https://img.ricolxwz.asia/e9b27a28a8f0281d5d2c098340067bb1.webp#only-light){ loading=lazy width='500' }
![](https://img.ricolxwz.asia/e9b27a28a8f0281d5d2c098340067bb1_inverted.webp#only-dark){ loading=lazy width='500' }
<figcaption>图二: 模型微调需要对每个下游任务都训练一个专门的副本, 并且不同任务的数据必须在不同的批次中进行训练. 相比之下, 提示调优只需要为每个任务存储一个小型的任务相关的提示, 并且不同任务的数据可以混合在同一个批次中, 只需要在前面拼接一个可训练的提示(如图中的A, B, C被分别拼接到a1, a2; b1; c1, c2上). 当使用T2 XXL模型的时候, 每个微调后的模型副本需要110亿个参数, 而作者的提示调优, 假设提示长度为5个虚拟token, 那么每个任务只需要2048个参数, 缩减了5个数量级以上</figcaption>
</figure>

虽然作者的方法和Li和Liang[^7]和Hambardzumyan等人[^8]的方法是同一个时期独立开发出来的, 但是作者却是第一个证明仅使用提示调优(不需要在中间层添加前缀向量或者任务特定的输出层)也足以在性能上和微调模型相竞争的研究. 在后的实验中, 他们进一步证明了预训练语言模型本身的能力是这些方法的成功的重要因素, 正如图一表示的那样, 提示调优的竞争力随着预训练模型规模的扩大而提升.

作者在第4节中对比了其他和提示调优类似的研究或者方法, 说明了自家方法和现有工作之间的区别和联系, 并论述了显式区分任务专用参数和通用参数之间的好处. 在第5节, 作者展示了当把任务定义封装在提示中, 并保持通用参数不变, 模型在面对跨领域数据时, 能够展现出更好的稳健性和适应能力. 在第6节中, 作者提出了"[提示集成](/dicts/prompt-ensembling)", 即为同一个任务学习多个不同的提示, 并将他们集成使用, 并证明了这种该方式比传统的集成学习模型更加高效, 并且能够提高预测质量. 最后在第7节, 作者对所学习到的软提示进行了可解释性分析, 提示都是向量, 不是自然语言.

## 方法论

### 文本到文本范式 {#text-to-text}

T5模型采用"text-to-text", 即文本到文本的范式来代表所有的NLP任务, 也就是说, 不管是分类, 翻译, 摘要或者是其他任务, 都将它们视为一个条件文本生成问题, 输入是文本, 输出还是文本. 在这种框架下, 模型根据输入文本生成目标文本, 而非直接预测某个离散标签或者数值. 传统的分类任务通常被建模为给定输入$X$然后预测标签$y$的概率分布, 即$Pr(y|X)$. 然而, T5并没有把$y$看作是一个简单的类标签, 而是把它当作一段要生成的文本序列$Y$, 这样就将分类任务转变为了一个条件文本生成问题, 即T5要学习$Pr_{\theta}(Y|X)$, 其中$\theta$是模型的参数. 如原本是一个标签"P"或者"N", 现在则会直接生成文本序列, 如输出字符串"Positive"或者"Negative".

### 提示设计的实现

提示是在模型生成$Y$的时候添加额外信息的方法. 通常情况下, 提示是通过在输入$X$前面添加一系列tokens, $p$, 完成的, 以便模型能够最大化输出$Y$的可能性, 即最大化$Pr_{\theta}(Y|[P; X])$, 同时保持预训练模型的参数$\theta$, 不变.

对于使用提示设计(prompt design)调优的GPT-3, prompt通常是输入给模型的一段自然语言文本, 用来引导模型产生期望的输出, 例如, 如果我们想让模型进行翻译, 可以在prompt中写上一些示例或者描述, 让模型知道自己要执行翻译任务, 将这些prompt tokens记作$P=\{p_1, p_2, ..., p_n\}$, 即提示文本被分词后的序列, ^^其中, 每个token都要先转换为向量嵌入(embedding), 才能输入到模型中, 这种转换是由模型的参数$\theta$定义的嵌入表实现的, 而$\theta$是被冻结的.^^ 由于无法调整prompt的嵌入, 我们需要手动或者用非微分搜索找到最适合模型的prompt, 而不是嵌入.

手动搜索比如我们通过靠直觉或者实验, 设计出一段合适的引导文本, 非微分搜索是指通过某些算法自动生成, 筛选大量可能的prompt文本, 然后在验证集或者小规模的数据集上测试效果, 从中选出表现最好的prompt.

### 提示调优的实现

🌟提示调优移除了提示$P$使用和$\theta$相关的嵌入表嵌入的限制, 转而使用自己的专用嵌入表, 这个嵌入表由参数$\theta_p$定义. 提示设计涉及从冻结嵌入表中选择一个固定词汇, 而提示调优可以被认为是使用了一种特殊的token, 即虚拟tokens来表示prompt. 模型会在输入序列中, 在真实输入$X$的前面加上若干个可以学习的虚拟tokens表示prompt, 和$X$拼接在一起作为输入, $X$的嵌入使用的是$\theta$定义的嵌入矩阵, 这个矩阵是被冻结的, 所以产生的嵌入在训练中不会发生改变, 而虚拟token序列即prompt使用的是$\theta_p$定义的嵌入矩阵, 这个矩阵是随着训练发生变化的, 即在训练的过程中, prompt的嵌入会发生改变, $X$的嵌入不会发生改变. 现在, 模型需要最大化的是$Pr_{\theta; \theta_p}(Y|[P; X])$🌟.

<figure markdown='1'>
![](https://img.ricolxwz.asia/ed81b6af774b9d639bb6c2bdfc6f04d6.webp#only-light){ loading=lazy width='500' }
![](https://img.ricolxwz.asia/ed81b6af774b9d639bb6c2bdfc6f04d6_inverted.webp#only-dark){ loading=lazy width='500' }
<figcaption>如图, 左侧的Tunable Soft Prompt是可以随模型训练的, 它们的嵌入是由θp管辖的, 这个参数是可变的; 右侧的Engineered Prompt是无法随模型训练的, 是要手动或者通过繁琐方法搜索的, 因为它们的嵌入规则在训练中是被定义死的(θ是预训练模型的参数, 被冻结)</figcaption>
</figure>

给定一个由$n$个token组成的序列, $\{x_1, x_2, ..., x_n\}$, 第一件要做的事情就是使用预训练模型给的嵌入矩阵(已经被冻结, 参数为$\theta$)对原始输入进行嵌入, 形成一个矩阵$X_e\in \mathbb{R}^{n\times e}$, $e$是嵌入空间的维度. 第二步是使用自己的定义的嵌入矩阵(参数为$\theta_p$)对软提示进行嵌入, 形成一个矩阵$P_e\in \mathbb{R}^{p\times e}$, 其中$p$表示的是提示的长度. 第三步是把这两个嵌入矩阵拼接成一个矩阵$[P_e; X_e]\in \mathbb{R}^{(p+n)\times e}$. 第四步, 这个拼接的矩阵会流经encoder和decoder, 计算出损失. 第五步, 这个损失反向传播, 更新自定义的嵌入矩阵的参数$\theta_p$.

### 设计考量

#### 软提示初始化方法

有多种方法可以初始化提示的表示, 最简单的方法是完全从零开始训练, 使用随机初始化. 更复杂一点的方法是将每个虚拟token初始化为模型词汇表中的某个嵌入向量, 因为软提示在^^概念上^^就像是输入序列前面的一段自然语言文本, 因此使用"类词"的表示作为初始值可能会更合适. 对于分类任务, 还可以使用第三种方式, 把提示初始化为那些能够代表输出类别的词嵌入(类似于[verbalizers](https://blog.csdn.net/qq_27590277/article/details/122356301)), 因为我们希望模型的输出能在这些合法类别中进行选择, 所以把提示初始化为对应目标token的嵌入可以让模型更倾向于生成正确的分类标签.

#### 软提示的长度

作者的另一个设计上的考量是软提示的长度. 他们模型的参数cost是$EP$, $E$是虚拟token的维度, $P$是软提示的长度. 软提示的长度越短, 需要调教的新参数就越少, 所以作者致力于找到一个较短的软提示同时性能上表现良好.

### 片段掩码模型

#### 概念

在T5预训练的过程中, 它采用了一种叫做span corruption(片段掩码)的目标, 和GPT-3这类自回归模型的训练方式不同. 自回归模型(例如GPT-3)通常从左到右依次预测下一个词, 而T5使用了一个encoder-decoder架构, 并且在预训练的时候会对输入文本中的部分片段(spans)进行掩码(mask)处理, 然后让模型根据这些掩码重建被隐藏的内容. 具体来看, 在输入文本中, 被掩码的部分会使用一个唯一的标记符号, 如`<X>`, `<Y>`等替换, 这些标记符号被称为sentinel tokens. T5的目标输出则是由所有被掩盖的内容组成, 并在不同片段之间插入相应的sentinel, 最后会插入一个终止的sentinel. 举个例子, 原文本是`Thanks you for inviting me to your party last week`. 如果掩码了`for inviting`和`last`, 那么输入可能会被构造成`Thank you <X> me to your party <Y> week`, 其中, `<X>`和`<Y>`是sentinel, ^^而目标输出序列就会是`<X> for inviting <Y> last <Z>`, `<Z>`表示的是sentinel终止标记, 注意, 这是用于训练的标签, 不是模型真实的输出.^^

???+ note "span corruption和MLM的区别"

    - 掩盖单位: MLM通常掩盖单个token, span corruption掩盖连续的文本片段(span)
    - 掩盖标记: MLM使用统一的`[MASK]`标记, span corruption使用唯一的sentinel tokens, 如`<X>`, `<Y>`
    - 掩盖比例: MLM通常掩盖15%的token, span corruption可以采用更高的掩盖率, 如40%, 甚至80%
    - 预测目标: MLM预测每个被掩盖的token, span corruption重建整个被覆盖的span
    - 架构适用性: MLM主要用于编码器模型, span corruption适用于编码器-解码器架构

#### 假设存在的问题

虽然Raffel等人发现这种架构和预训练目标比传统的语言模型更有效, 但是作者假设这种策略并不适合生成可以通过提示调整的冻结模型. 具体来说, 一个使用片段掩码专门训练的T5模型, 如T5.1.1, 从未见过真正自然的输入文本(不含有sentinel), 也从未被要求在没有sentinel的情况下生成自然的文本. 刚才我们也看到了, 在T5预训练的过程中, 目标输出序列/标签也会从一个sentinel(例如`<X>`)开始, 如`<X> for inviting <Y> last <Z>`, 这种做法让模型习惯了输出时实现生成sentinel. 如果之后对模型进行微调, 模型很容易学会不再输出这些sentinel, 但是, 如果模型是冻结的, 只通过prompt进行控制, 那就很难以prompt去改变模型对sentinel的输出偏好, 因为无法调整模型本身的参数.

#### 测试问题是否存在

鉴于上述假设, 作者展开了一次实验, 主要分为三种设置:

1. Sentinel: 直接使用现成的, 已经在片段掩码上预训练好的T5模型(如T5.1.1), 并且保持模型完全冻结. 在这个设置中, 他们想看看这样一个从未见过自然文本, 只见过带sentinel的输入和目标的T5, 在执行下游任务的时候, 是否只通过prompt就能被引导输出期望的文本
2. Span Corruption + Sentinel: 仍然使用一个尽在片段掩码上预训练的T5模型, 不同的是, 他们在下游任务的目标文本前面加上一个sentinel, 取模仿T5在预训练时见到的带有sentinel的目标输出序列/标签. 这样可以测试, 如果让下游任务的目标看起来在形式上接近预训练时候的状态, 是否能更好地激活模型的知识, 让模型输出更加准确, 期望的结果
3. LM Adaptation: 在已经完成片段掩码预训练的T5模型上, 继续做少量的自监督训练, 不过这次使用的是语言模型的优化目标, 即给模型一个自然文本前缀, 让它取预测真正自然的后续文本. 也就是说, 这是把T5从"只见过sentinel的非自然训练数据"上, 稍微再额外适配到"自然语言建模"山给, 让它能够更好地再不包含sentinel地场景下进行预测. 重要的是, 这种adaptation只会做一次, 得到一个新的, 已经适配了自然文本输出的冻结模型, 之后, 这个模型就可以重复用在多个下游任务的提示调优上

通过LM adaptation, 作者希望将T5迅速转变为与GPT-3相似的模型, 众所周知, 它们总是能输出逼真的文本, 并且能很好的通过prompt进行小样本学习. 作者指出, 相对于从头训练模型(如GPT-3那样), 在预训练结束后才进行的这一步晚期适配究竟能够取得多大的成功并不明确, 据他们所知, 之前也没有人做过类似的研究, 所以这项实验具有探索性质. 为了检验LM adaptation的效果, 作者尝试了不同的训练步数, 最多高达十万步, 他们希望通过对比不同训练步数下模型在下游任务的表现, 来评估LM adaptation的实际价值.

[^1]: Lester, B., Al-Rfou, R., & Constant, N. (2021). The power of scale for parameter-efficient prompt tuning (No. arXiv:2104.08691). arXiv. https://doi.org/10.48550/arXiv.2104.08691
[^2]: Peters, M. E., Neumann, M., Iyyer, M., Gardner, M., Clark, C., Lee, K., & Zettlemoyer, L. (2018). Deep contextualized word representations (No. arXiv:1802.05365). arXiv. https://doi.org/10.48550/arXiv.1802.05365
[^3]: Radford, A. (2018). Improving language understanding by generative pre-training. https://www.mikecaptain.com/resources/pdf/GPT-1.pdf
[^4]: Devlin, J., Chang, M.-W., Lee, K., & Toutanova, K. (2019). BERT: Pre-training of deep bidirectional transformers for language understanding (No. arXiv:1810.04805). arXiv. https://doi.org/10.48550/arXiv.1810.04805
[^5]: Brown, T. B., Mann, B., Ryder, N., Subbiah, M., Kaplan, J., Dhariwal, P., Neelakantan, A., Shyam, P., Sastry, G., Askell, A., Agarwal, S., Herbert-Voss, A., Krueger, G., Henighan, T., Child, R., Ramesh, A., Ziegler, D. M., Wu, J., Winter, C., … Amodei, D. (2020). Language models are few-shot learners (No. arXiv:2005.14165). arXiv. https://doi.org/10.48550/arXiv.2005.14165
[^6]: Shin, T., Razeghi, Y., IV, R. L. L., Wallace, E., & Singh, S. (2020). AutoPrompt: Eliciting Knowledge from Language Models with Automatically Generated Prompts (No. arXiv:2010.15980). arXiv. https://doi.org/10.48550/arXiv.2010.15980
[^7]: Li, X. L., & Liang, P. (2021). Prefix-tuning: Optimizing continuous prompts for generation (No. arXiv:2101.00190). arXiv. https://doi.org/10.48550/arXiv.2101.00190
[^8]: Hambardzumyan, K., Khachatrian, H., & May, J. (2021). WARP: Word-level adversarial ReProgramming (No. arXiv:2101.00121). arXiv. https://doi.org/10.48550/arXiv.2101.00121
