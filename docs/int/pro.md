---
title: 简历
comments: false
---

## Whisper

### 思想

Whisper 的核心思想可以概括为: 统一建模 + 大规模弱监督 + 多任务 token 控制.

* 统一建模: 采用标准 Transformer Encoder-Decoder. 先把语音转成 `log-Mel` 频谱, Encoder 编码声学信息, Decoder 通过自回归生成文本, 并用 cross-attention 对齐音频表示.
* 多任务一套模型: 不为每个任务单独训练模型, 而是通过特殊 token 控制任务行为, 比如 `transcribe`(转写), `translate`(翻译), 语言识别等, 本质是条件生成.
* 数据驱动优先于结构堆料: Whisper 的提升路径不是一味加参数, 而是靠更大规模的数据和更稳的训练策略提升泛化能力.

版本演进的主线:

* v1: 用大规模互联网弱监督语音文本对训练, 拿到强鲁棒性.
* v2: 在参数规模基本不变下, 通过更长训练 + 正则化提升准确率和稳定性: `SpecAugment`在 Mel 频谱上做时间/频率遮挡与时间扰动, 增强噪声与语速变化鲁棒性; `Stochastic Depth`训练时随机跳层, 降低过拟合并稳定深层训练; `BPE Dropout`在分词 merge 时随机跳过部分合并, 让同一句话形成不同子词切分, 提升泛化(注: 发生在训练阶段的文本侧分词, 训练标签文本(转写/翻译结果)要先做 BPE, 变成 token id 给 decoder 学习).
* v3: 进一步把训练数据量拉大, 并把 Mel bins 从 `80` 提到 `128`, 提升频域分辨率和多语言效果.

### 部署

```bash
uv pip install faster-whisper fastapi uvicorn python-multipart
```

`app.py` 示例: 

```python
from faster_whisper import WhisperModel
from fastapi import FastAPI, UploadFile, File
import tempfile

app = FastAPI()

model = WhisperModel(
    "tiny",
    device="cpu",
    compute_type="int8"
)

@app.post("/asr")
async def asr(file: UploadFile = File(...)):
    with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as f:
        f.write(await file.read())
        audio_path = f.name

    segments, info = model.transcribe(audio_path, vad_filter=True)
    text = "".join([seg.text for seg in segments])

    return {
        "language": info.language,
        "duration": info.duration,
        "text": text
    }
```

启动: 

```bash
uvicorn app:app --host 0.0.0.0 --port 8000
```

## 语音文本对齐的最优传输正则化面试

### 多模态融合方法

先记主线: **早-中-高-对-接-图**  
`早`: 早期融合(拼接/加权/门控)  
`中`: 中期融合(跨模态注意力/Transformer)  
`高`: 高阶融合(双线性/张量)  
`对`: 对比对齐(共享嵌入空间)  
`接`: 接口式融合(视觉编码器 + LLM + 桥接模块)  
`图`: 图结构融合(GNN, 场景图, 关系建模)

| 路线 | 核心思路 | 代表关键词 | 主要优点 | 主要局限 |
| --- | --- | --- | --- | --- |
| 早期融合 | 低层直接合并特征 | concat / 加权 / gating | 简单稳, 并行友好 | 细粒度交互弱 |
| 中期融合 | token 级显式交互 | cross-attn / co-attn / 多模态 Transformer | 对齐更细, 表达力强 | 计算量大(O(n^2)) |
| 高阶融合 | 显式建模模态乘性交互 | bilinear / tensor / 低秩分解 | 高阶关系强 | 参数大, 训练难 |
| 对比对齐 | 先学共享语义空间 | CLIP / ALIGN / 双塔 | 可扩展, 零样本强 | 推理与组合能力有限 |
| 接口式融合 | 强编码器 + 轻桥接 + 语言生成 | Q-Former / Adapter / LLM | 成本低, 产品化强 | 幻觉与一致性风险 |
| 图结构融合 | 用图建模对象与关系 | GNN / Scene Graph | 关系推理强 | 构图成本高, 流程复杂 |

### 什么是Optimal Transportation

OT是一种在两个分布之间寻找最小搬运成本匹配方式的方法. 他解决的问题是: 如何把质量从A分布搬到B分布, 使得总成本最小. 给定两个分布: $a=(a_1, ..., a_T)$, $b=(b_1, ..., b_N)$, 给定cost矩阵: $C_{ij}=distance(x_i, y_j)$, OT求: $\min_{\pi}\sum_{i, j}\pi_{ij}C_{ij}$, 其中, $\pi_{ij}$是transport plan. 在speech-text场景里面, 每个frame有质量, 每个token有质量, cost是embedding距离, OT会算出$\pi_{ij}$表示第$i$个frame有多少概率质量对齐到第$j$个token. 

OT和contrasive的区别: contrasive拉近正样本, 推远负样本, 是pair-level. OT是全局匹配, 不需要负样本, 是distribution level, 允许many-to-many. 

OT和attention的区别: Attention是先计算相似度$QK^T$, 再按照行softmax, 没有列约束, 不解一个全局优化问题; OT也是基于pairwise相似度矩阵, 但是要求同时满足行列边缘分布. 假设有2个query(q1, q2)和两个key(k1, k2), 如果q1和q2都非常喜欢k1: 

* Attention: q1会给k1很高的权重; q2也会给k1很高的权重, 结果两个query都扎堆k1. 因为attention不限制k1总共能被分配多少
* OT: 如果列边缘规定每个key总容量差不多, q1和q2不能都把质量塞给k1, 系统会全局协调, 把一部分质量分配k2. 

### SLM generalization gap的本质原因是啥

核心是 speech 与 text 表征分布不一致(modality gap): speech embedding 含大量与语言无关的变化(语速, 停顿, 能量, 说话人等), 模型在 in-domain 时容易学到**"捷径特征"**(spurious cues), 跨数据集这些 cues 失效就崩.  所以不是单纯 dataset bias, 而是__表示层面可被利用的多余自由度 + 训练目标缺少"对齐到 LLM embedding 空间"的直接约束共同导致.__

### unintended variation在embedding space的几何结构是啥

可以理解为: speech embedding 在 LLM embedding space 中出现额外的自由方向, 形成: 离散内容(linguistic)方向 + 连续扰动(paralinguistic)方向叠加; 表现为: 同一 token/词语对应的 speech embeddings 方差大, 簇拉长, 类间边界模糊; 模型可能用这些"容易拟合但不可迁移"的方向来降低 CE loss(捷径), 而不是学到"像文本那样"的语义轨迹. 

### 为什么说CTC supervision是indirect? 

CTC 的 supervision 主要是对齐到 离散 label 序列(字符/子词), 它优化的是"预测 label 的概率", 而不是"speech embeddings 在 LLM 的 embedding metric space 上接近 transcript embeddings". 结果就是: 即使 CTC WER 不错, speech embedding 仍可能不在 LLM 的语义几何里——这就是"监督信号与最终目标(embedding-level alignment)之间有鸿沟". 

### 为什么用uniform marginal?

uniform的含义是: 把source与target当作均匀质量分布, 每个speech embdding, 每个unique transcript enbedding都分到等量质量. 优点是简单, 无需额外超参/先验, 不需要token时长或者对齐标注. 减少了对于重复token的先验偏置. 分别对应OT的两个约束: $\sum_{j}\gamma_{ij}=1/n_a, \sum_i \gamma_{ij}=1/n_g$.

### 为什么cost用1 - cosine?

$f_i$是第i个speech embedding, $g_j$是第$j$个unique transcript embedding, cost其实就是OT矩阵里面的一项, 表示第$i$个frame有多少的概率质量对齐到第$j$个token, 这里被定义为$1=\cos(f_i, g_j)$. 为啥使用这个cosine, 是因为consine对scale不敏感, 适合不同模块输出的norm波动, 在高纬度embedding上比L2更加稳健. 在高维embedding上比L2更加稳健.

### $\epsilon$太大/太小会怎样? 

* $\epsilon$很小: transport plan 变得尖锐, 接近 hard assignment, 容易受噪声影响, 训练早期不稳定; 
* $\epsilon$很大: plan 过于平滑, 接近平均分配, alignment 变弱, loss 约束变"软化", 对齐效果下降. 

??? example "例子"

    假设: 

    * 3 个 speech embeddings
    * 2 个 transcript tokens

    === "情况 A: ε 很小(接近 hard assignment)"

        可能 γ 是: 

        |    | g1   | g2   |
        | -- | ---- | ---- |
        | f1 | 0.33 | 0    |
        | f2 | 0.17 | 0.16 |
        | f3 | 0    | 0.33 |

        每列加起来都是 0.5(满足边际)

        但注意: 

        * 每行是尖的(接近 one-hot)
        * 每个 speech frame 基本选一个 token

        这叫 **sharp alignment**

    === "情况 B: ε 很大(平滑)"

        γ 可能变成: 

        |    | g1   | g2   |
        | -- | ---- | ---- |
        | f1 | 0.16 | 0.17 |
        | f2 | 0.16 | 0.17 |
        | f3 | 0.18 | 0.16 |

        仍然: 

        * 每列总和 = 0.5
        * 边际不变

        但现在: 

        > 每个 speech embedding 同时对齐多个 token

        这叫 **模糊对齐**

### 为什么必须去重 transcript embedding? 

因为 transcript 中重复模式会导致 OT 产生多解/歧义: 例如 "banana banana", 两个 token embedding 非常接近, OT 会把大量 speech mass 分散到多个重复目标上, plan 变得不稳定. 用 unique embeddings 相当于把目标变成"词表集合", 让 speech 只需对齐到"出现过的语义原型", 更稳. 

### OT不依赖temporal order, 会不会前半句对应到后半句

在这篇论文里, OT 是在做: 

* source: speech embeddings(语音特征)
* target: unique transcript embeddings(文本特征)

OT 只根据 embedding 相似度 做匹配, 它不会看: 

* 这是第几个 token
* 是不是时间上相邻
* 是否单调递增

但是, 这篇论文的目标不是做严格 ASR alignment. 它的目标是: 减少 modality gap, 让 speech embedding 落在 transcript embedding 的语义空间里. 也就是说, 它不在乎: 这个语音帧是不是对应第 5 个 token, 或第 8 个 token. 它只在乎: 这个语音 embedding 看起来像不像某个正确的文本 token embedding. 

### unique阈值怎么选, 影响是什么?

在做OT对齐的时候, target用的是unique transcript embeddings, 这个unique是通过consine similarity阈值来判断的. 如果阈值很高, 很少embedding会被合并, unique token数量多, OT target更细, transport更严格, 对齐更加精细, 但是可能有更多的噪声, 更加敏感. 阈值低的话, 很多embedding被认为是等价, unique token少, OT target更加粗, 对齐更加宽松, 更加鲁棒, 但是语义可能会被过度合并. 

### $L_{\text{cost}}$和$L_{\text{spr}}$各自优化的是什么?

* L_cost: 让 transport 发生在高相似度对上(speech embedding 靠近 transcript embedding 集合). 让模型产生的optimal transport plan更加好. 
* L_spr: 让每个 speech embedding 的对齐分布更集中(趋向一对一), 减少"平均对齐/糊成一团". 

### 去掉sparsity会怎么样?

transport plan 会更平滑(尤其在 entropy 正则下), 导致: 

* speech embedding 被"同时拉向多个 token 原型", 产生语义模糊; 
* alignment 变成"distribution matching"而不是"token-like anchoring", 对减少 modality gap 不如带 sparsity 明显. (如果alignment只是让speech embedding的**整体分布**接近transcript embedding的分布, 那本质上是一种global distribution-level alignment; token-like anchoring的意思是每个speech token都被锚定到某个具体的transcript embedding).  

### 这篇文章推理/训练的流程是啥?

#### 训练阶段

1. 仅使用CE的监督微调: 

    1. 输入: \( \text{Template}(E_P, F_S) \)
    2. 使用 LLM 进行自回归预测
    3. 计算 Cross-Entropy(CE)loss
    4. 仅更新 Adapter

    特点:

    - 不使用 OT
    - 不使用 Compression
    - 目标: 让 speech embedding 初步适配 LLM embedding 空间

2. 引入OT Reg和Compression

    在 Stage 1 基础上继续训练, 每次迭代包括: 


    1. 前向传播

        计算 speech embedding:  \( F_S = \text{Adapter}(\text{SpeechEncoder}(X_S)) \)

    2. 计算OT对齐

        - Source: speech embedding \( F_S \)
        - Target: 去重后的 transcript embedding \( G_T \)
        - 使用 Sinkhorn 算法求解 entropic OT, 得到最优 transport plan \( \hat{\gamma} \)

    3. 计算OT正则化损失: \( L_{OT} = L_{cost} + \lambda_{spr} L_{spr} \)

        作用: 

        - 拉近 speech embedding 与 transcript embedding
        - 促进稀疏的一对一对齐
        - 减少 modality gap

    4. OT-based Compression: \( K_S = \text{OTCompression}(F_S) \)

        包括: 

        - 合并相邻高相似 embedding
        - 删除与 pad embedding 相似的无信息帧

        目的: 去除冗余, 使 speech 表示更接近 text-like 结构

    5. 计算CE损失: \( L_{CE} = \text{CE}(\hat{Y}, Y) \)
    
    6. 总损失: \( L_{total} = L_{CE} + \lambda_{OT} L_{OT} \)

#### 推理阶段

推理阶段: 

- 没有 transcript
- 不计算 OT plan
- 不计算 OT loss

流程如下: 

1. Speech → Encoder → Adapter → \( F_S \)
2. 应用 OT-based Compression → \( K_S \)
3. 输入 \( \text{Template}(E_P, K_S) \) 到 LLM
4. 自回归生成文本

### OT-based compression 为什么可微? 梯度怎么走? 

因为使用的是熵正则OT++Sinkhorn算法, 这个算法的输出(transport plan)是输入(cost matrix)的连续可微函数. 所以梯度能从loss -> $\hat{\gamma}$ -> 相似度矩阵 $C$ -> speech embedding反传. compression的merge/drop实现为软门控/soft mask就同样可微. 

### OT-based compression是如何实现的?

1. Merge Step: 把序列$[f_0, f_1, ..., f_5, ...]$分为$(f_0, f_1), (f_2, f_3), (f_4, f_5), ...$, 然后计算相似度: $\cos(f_{2k}, f_{2k+1})$, 如果similarity > threshold, 那么认为, 这两个embedding的语义是一样的. 如何 merge? 最自然的可微实现方式是$f_{\text{merged}} = \frac{f_{2k} + f_{2k+1}}{2}$. 为什么只merge adjacent pairs? 为了防止过度压缩, 例如hheelllloo, 如果不是merge adjacent pairs, 可能会变为helo, 丢失了太多的重复信息.
2. Drop Step: 因为在unique transcript embedding里面, 我们定义了一个pad token, 表示无信息, 我们可以drop掉那些与pad embedding相似度很高的speech embedding. 具体实现是: 计算$\cos(f_i, g_{\text{pad}})$, 如果 similarity > threshold, 那么这个frame就被认为是无信息的, 可以被drop. 但是, 为了保持可微, 我们不是真的把它丢掉, 而是给它一个soft mask.  

### 用 pad embedding 判断 non-informative 合理吗? 

训练里把 pad 当成"blank/非信息"锚点(augmented transcript 也包含 pad), OTReg 会把 静音/停顿的 speech embedding 拉近 pad embedding, 所以推理时"像 pad 的就 drop"在机制上自洽 ✅. 风险是 pad 在某些 LLM 里可能带点偏置会误删, 但用阈值控制, 删多了 CE 会把它纠回来. 

### 为什么OTReg不在stage1用?

OTReg 依赖"cosine 相似度矩阵"来算 transport plan, 但 Stage 1 的 adapter 输出还没被训练到 LLM embedding 的同一语义空间, 所以此时算出来的 cosine 相似度基本是乱的 → Sinkhorn/OT 会得到噪声 transport plan → 反传的梯度也是错的, 训练容易不稳定/震荡 😵‍💫. 

### CE和OT会conflict嘛?

CE 和 OTReg 目标不完全一样, 局部可能"拉扯", 但整体是互补的. **CE(交叉熵)**管的是最终任务: 让模型输出的 token 序列/转写结果正确(直接决定 WER). OTReg更像是结构化对齐/表示约束: 让 speech 内部表示在分布上更接近对应文本表示(更"像文本那样组织"), 有助于减少 modality gap, 提升泛化. 当 OT 权重大, 可能损伤纯 WER; 当 OT 太小, generalization 改善有限. 你通过 λOT sweep 找到 sweet spot. 

在文章里面, $\lambda_{OT}$设置为$0.3$.  

### 为什么 Base+CTC cross-domain 反而变差? 

CTC 的 classifier 参数大, 容易过拟合. 而且 CTC 对齐的是 label, 不保证 embedding-level 对齐到 LLM; 所以可能学到"CTC 好用的对齐捷径", 但对跨域的 speech variability 仍敏感, 导致泛化下降或收益不稳定. 

### Fig.4 距离下降说明什么? 会不会只是 norm 变小? 

你画的是 speech embeddings 与 transcript embeddings 的 pairwise distance/相似度结构, OTReg 后结构更清晰, 并且非信息段更集中对应到 pad. 同时你用 cosine cost, 本质上对 norm 不敏感, 所以很难用"norm 变小"解释整体结构改善. 

### 为什么 multilingual 下 OTReg 提升更明显? 

跨语言/跨数据集时 speech variability 更大, domain shift 更明显. 
OTReg 提供了"语言无关"的表示约束: 把 speech embedding 拉向 LLM 的 token 语义几何(而不是依赖某数据集的声学风格). 因此越是 shift 大的 setting, 收益越明显. 

### speech 长 >> transcript 长, 会不会违背 monotonic? 

你没有显式追求 monotonic, 对齐目标是"语义集合对齐"而非"严格时间对齐". 
speech 长带来的冗余通过:  

* OT sparsity 让每个 speech embedding 选一个语义原型; 
* OT-based compression merge/drop 去冗余; 从而把多帧映射到更"token-like"的序列/集合. 
