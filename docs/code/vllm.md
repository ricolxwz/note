---
title: vLLM
comments: false
---

## 安装

```bash
uv venv --python 3.10 --seed
source .venv/bin/activate
pip install https://github.com/vllm-project/vllm/releases/download/v0.4.0/vllm-0.4.0+cu118-cp310-cp310-manylinux1_x86_64.whl --extra-index-url https://download.pytorch.org/whl/cu118

```

## 生成

来自https://github.com/vllm-project/vllm/blob/main/examples/offline_inference/basic/basic.py:

```py
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: Copyright contributors to the vLLM project

from vllm import LLM, SamplingParams

# Sample prompts.
prompts = [
    "Hello, my name is",
    "The president of the United States is",
    "The capital of France is",
    "The future of AI is",
]
# Create a sampling params object.
sampling_params = SamplingParams(temperature=0.8, top_p=0.95)


def main():
    # Create an LLM.
    llm = LLM(model="facebook/opt-125m")
    # Generate texts from the prompts.
    # The output is a list of RequestOutput objects
    # that contain the prompt, generated text, and other information.
    outputs = llm.generate(prompts, sampling_params)
    # Print the outputs.
    print("\nGenerated Outputs:\n" + "-" * 60)
    for output in outputs:
        prompt = output.prompt
        generated_text = output.outputs[0].text
        print(f"Prompt:    {prompt!r}")
        print(f"Output:    {generated_text!r}")
        print("-" * 60)


if __name__ == "__main__":
    main()
```

默认情况下,vLLM 将使用模型创建者推荐的采样参数,并应用 Hugging Face 模型库中的 generation_config.json (如果存在的话).在大多数情况下,如果没有指定 SamplingParams,默认情况下这将为您提供最佳结果. 不过,如果希望使用 vLLM 的默认采样参数,请在创建 LLM 实例时设置 generation_config="vllm".
