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

## 多模态融合方法

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
