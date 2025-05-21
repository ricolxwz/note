---
title: LiteLLM
comments: true
---

LiteLLM是一个将openai api格式请求转换为其他平台api格式的一个proxy服务器.

## 安装

```bash
uv pip install 'litellm[proxy]'
```

## 配置

在shell中写入Azure相关的环境变量.

```bash
export AZURE_API_KEY=""
export AZURE_API_BASE=""
export MASTER_KEY=""
```

新建`config.yaml`:

```yml
general_settings:
  master_key: os.environ/MASTER_KEY
model_list:
  - model_name: text-embedding-3-small
    litellm_params:
      model: azure/ricolxwz-embedding
      api_base: os.environ/AZURE_API_BASE
      api_key: os.environ/AZURE_API_KEY
      api_version: "2023-05-15"
```

启动:

```bash
litellm --config ./config.yaml --host 127.0.0.1 --port 5001
```

然后, 就会默认监听5001端口. 示例调用:

```py
import requests
import json

def test_embedding():
    url = "http://localhost:5001/v1/embeddings"
    headers = {
        "Authorization": "Bearer sk-xxxx",
        "Content-Type": "application/json"
    }
    payload = {
        "model": "text-embedding-3-small",
        "input": "这是一段测试文本"
    }
    resp = requests.post(url, headers=headers, data=json.dumps(payload), timeout=5)
    print("状态码:", resp.status_code)
    print("响应:", resp.json())

if __name__ == "__main__":
    test_embedding()
``
