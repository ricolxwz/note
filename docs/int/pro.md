---
title: 简历
comments: false
---

## Whisper

### 思想

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
    "large-v3",
    device="cuda",          # 无GPU可改为 cpu
    compute_type="float16"  # CPU可改为 int8
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
