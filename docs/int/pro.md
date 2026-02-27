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

### SLM generalization gap的本质原因是啥

核心是 speech 与 text 表征分布不一致(modality gap): speech embedding 含大量与语言无关的变化(语速, 停顿, 能量, 说话人等), 模型在 in-domain 时容易学到**"捷径特征"**(spurious cues), 跨数据集这些 cues 失效就崩.  所以不是单纯 dataset bias, 而是__表示层面可被利用的多余自由度 + 训练目标缺少"对齐到 LLM embedding 空间"的直接约束共同导致.__

### unintended variation在embedding space的几何结构是啥

可以理解为: speech embedding 在 LLM embedding space 中出现额外的自由方向, 形成: 离散内容(linguistic)方向 + 连续扰动(paralinguistic)方向叠加; 表现为: 同一 token/词语对应的 speech embeddings 方差大, 簇拉长, 类间边界模糊; 模型可能用这些"容易拟合但不可迁移"的方向来降低 CE loss(捷径), 而不是学到"像文本那样"的语义轨迹. 

### 为什么说CTC supervision是indirect? 

CTC 的 supervision 主要是对齐到 离散 label 序列(字符/子词), 它优化的是"预测 label 的概率", 而不是"speech embeddings 在 LLM 的 embedding metric space 上接近 transcript embeddings". 结果就是: 即使 CTC WER 不错, speech embedding 仍可能不在 LLM 的语义几何里——这就是"监督信号与最终目标(embedding-level alignment)之间有鸿沟". 
