---
title: DeepSpeed
comments: false
---

## 依赖

```txt
--extra-index-url https://download.pytorch.org/whl/cu121
torch==2.2.2
torchvision==0.17.2
torchaudio==2.2.2
transformers
datasets
accelerate
deepspeed
```

## ZeRO

在普通的数据并行中, 每张显卡都需要存模型参数+梯度+优化器状态, 这就限制了模型的大小. 所以GPU的利用率比较低. ZeRO的核心思想是能不复制就不复制, 拆开存, 必要的时候再通信. 训练的时候显存大头有三样: 模型参数, 梯度, 优化器状态. ZeRO把它们分成三类, 分别叫ZeRO-1, ZeRO-2, ZeRO-3: 

* ZeRO Stage1: 只拆优化器状态, 因为优化器状态很吃显存, 每个参数要存m和v, 2倍的模型大小. 

    ??? example "例子"

        普通DP:

        ```
        GPU0: params + grads + states
        GPU1: params + grads + states
        GPU2: params + grads + states
        GPU3: params + grads + states
        ```

        ZeRO-1:

        ```
        GPU0: 1/4 optimizer states
        GPU1: 1/4 optimizer states
        GPU2: 1/4 optimizer states
        GPU3: 1/4 optimizer states
        ```

        但: 

        * ✅ 参数仍然复制
        * ✅ 梯度仍然复制

        更新的时候的流程:

        ```
        AllReduce → 得到全局梯度
        ↓
        只把相关梯度发给 GPU0
        ↓
        GPU0 更新参数
        ↓
        广播新参数
        ```

* ZeRO Stage2: 再拆Gradients.

    ??? example "例子"

        现在:
        
        ```
        optimizer states → 分片
        gradients → 分片
        ```

        每张卡只存: 1/N梯度, 有人会问, 为啥? 梯度计算的时候不是一下子计算出所有参数的梯度的嘛? ZeRO-2用了一种比价牛叉的方法, 它用的不是all-reduce, 而是reduce-scatter. 先把每张卡的梯度分成N份, 每份对应一个GPU, 然后每个GPU只保留对应自己的那一份, 其他的丢掉. 为什么其他的可以丢掉? 因为ZeRO-1已经把优化器状态分片了, 每个GPU只更新自己负责的那一部分参数, 只需要对应的梯度就行了.

        假设模型有4个参数, 2个GPU. 反向传播后: 

        GPU0计算出了:

        ```
        g1 g2 g3 g4
        ```

        GPU1也计算出了:

        ```
        g1 g2 g3 g4
        ```

        接下来:

        1. Reduce(求和/平均)

            ```
            GPU0: g1
            GPU1: g1
            ```

            合为:

            ```
            g1_global
            ```

        2. Scatter(分发)

            现在不在复制, 改成:

            ```
            GPU0 保留 → g1 g2
            GPU1 保留 → g3 g4
            ```

            所以, 每卡只有 1/N 梯度. 

        注意, 不是少算梯度, 而是算完立刻扔掉不属于你的那部分. 

        那Optimizer如何更新呢? 比如:

        ```
        GPU0 负责 W1 W2
        ```

        它拥有:

        * ✅ 参数
        * ✅ optimizer state
        * ✅ 全局梯度

        所以它可以:

        ```
        update W1 W2
        ```   

        完全合法, 更新完了之后, 再广播. 

* ZeRO Stage3: 再拆参数. 每张卡只存1/N参数, 1/N梯度, 1/N优化器状态. 

    ??? example "例子"

        现在:

        ```
        optimizer states → 分片
        gradients → 分片
        parameters → 分片
        ```

        当某层要计算:

        ```
        GPU们 → 临时拼出完整权重
        算完
        立刻释放
        ```

        所以显存占用: 

        接近 参数 / GPU数

!!! warning "ZeRO对于通信的要求"

    注意: ZeRO 本质不是"减少计算".  它是在用通信带宽换显存空间. 所以: 

    * NVLink / 高速网络 👉 ZeRO 起飞
    * PCIe 慢网络 👉 可能变慢

## DeepSpeed配置

```json
{
  "train_batch_size": 16,
  "gradient_accumulation_steps": 4,

  "fp16": { "enabled": true },

  "zero_optimization": {
    "stage": 2,
    "overlap_comm": true,
    "contiguous_gradients": true,
    "reduce_scatter": true,
    "allgather_partitions": true
  },

  "gradient_clipping": 1.0,
  "steps_per_print": 50
}
```

* `train_batch_size`: 一次参数更新的时候, 模型实际看过的样本总数. `train_batch_size` = `per_device_train_batch_size` * `gradient_accumulation_steps` * `world_size`. 本质上是micro_batch + gradient accumulation的方法. 
* `overlap_comm`: 开启之后, GPU会一边计算梯度, 一遍把已经算完的梯度发送出去. 
* `contiguous_gradients`: 开启之后, 会把梯度存成连续的内存块, 这样通信效率更高. 防止显存碎片. 
* `reduce_scatter`: 开启之后, reduce-scatter替代all-reduce. 注意, 虽然ZeRO-2的核心是`reduce_scatter`, 但是它并不是必须的, 主要是老旧的集群网络对`reduce_scatter`的兼容性差, 还不如`all-reduce`稳定. 并且, 可以用于调试和排查. 
* `allgather_partitions`: 在 optimizer.step() 之后, 用一次高带宽 AllGather (而非多次broadcast)收集分片参数, 把"各 GPU 更新的参数分片"同步成完整一致的模型. 

## QLoRA训练案例

```py
"""
QLoRA 训练脚本 - 4-bit NF4 量化 + LoRA 微调

CUDA_VISIBLE_DEVICES=0 deepspeed train_qlora.py \
  --model_name_or_path ./pythia-410m \
  --dataset_name ./wikitext-2-raw-v1 \
  --output_dir ./outputs_pythia_qlora \
  --deepspeed ./ds_config.json \
  --per_device_train_batch_size 2 \
  --max_length 512 \
  --num_train_epochs 1 \
  --lora_r 16 \
  --lora_alpha 32 \
  --target_modules "query_key_value,dense,dense_h_to_4h,dense_4h_to_h"
"""

import os
import argparse
import torch
from datasets import load_from_disk
from transformers import (
    AutoTokenizer,
    AutoModelForCausalLM,
    BitsAndBytesConfig,
    DataCollatorForLanguageModeling,
    TrainingArguments,
    Trainer# # 计算时使用的精度
)
from peft import LoraConfig, get_peft_model, TaskType, prepare_model_for_kbit_training

def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--local_rank", type=int, default=-1)
    p.add_argument("--model_name_or_path", type=str, default="gpt2")
    p.add_argument("--dataset_name", type=str, default="wikitext")
    p.add_argument("--dataset_config", type=str, default="wikitext-2-raw-v1")
    p.add_argument("--text_field", type=str, default="text")
    p.add_argument("--output_dir", type=str, default="./outputs_qlora")
    p.add_argument("--deepspeed", type=str, default="./ds_config.json")

    # QLoRA 量化参数
    p.add_argument("--bnb_4bit_quant_type", type=str, default="nf4",
                   help="Quantization type: nf4 or fp4")
    p.add_argument("--bnb_4bit_compute_dtype", type=str, default="float16",
                   help="Compute dtype for quantization: float16, bfloat16, float32")
    p.add_argument("--bnb_4bit_use_double_quant", action="store_true", default=True,
                   help="Use double quantization for further memory reduction")

    # LoRA 参数
    p.add_argument("--lora_r", type=int, default=16, help="LoRA attention dimension (rank)")
    p.add_argument("--lora_alpha", type=int, default=32, help="LoRA alpha parameter for scaling")
    p.add_argument("--lora_dropout", type=float, default=0.05, help="Dropout probability for LoRA layers")
    p.add_argument("--target_modules", type=str, default="query_key_value,dense",
                   help="Comma-separated list of target modules to apply LoRA")
    p.add_argument("--bias", type=str, default="none", choices=["none", "all", "lora_only"],
                   help="Bias training type")

    # 训练参数
    p.add_argument("--max_length", type=int, default=512)
    p.add_argument("--per_device_train_batch_size", type=int, default=1)
    p.add_argument("--per_device_eval_batch_size", type=int, default=1)
    p.add_argument("--learning_rate", type=float, default=2e-4)
    p.add_argument("--num_train_epochs", type=float, default=1)
    p.add_argument("--logging_steps", type=int, default=10)
    p.add_argument("--save_steps", type=int, default=200)
    p.add_argument("--eval_steps", type=int, default=200)
    p.add_argument("--do_eval", action="store_true")
    p.add_argument("--warmup_ratio", type=float, default=0.03)
    p.add_argument("--weight_decay", type=float, default=0.0)
    return p.parse_args()


def main():
    args = parse_args()

    # 1. 配置量化 (4-bit NF4)
    compute_dtype = getattr(torch, args.bnb_4bit_compute_dtype)

    bnb_config = BitsAndBytesConfig(
        load_in_4bit=True,  # 模型以 4-bit 精度加载, 而非默认的 FP16/FP32
        bnb_4bit_quant_type=args.bnb_4bit_quant_type,  # 使用 NF4 (Normal Float 4-bit) 算法, 针对正态分布的权重优化
        bnb_4bit_compute_dtype=compute_dtype,  # 虽然模型是 4-bit 存储, 但计算时升回 float16, 保证训练精度
        bnb_4bit_use_double_quant=args.bnb_4bit_use_double_quant,  # 对量化常数再量化, 可额外节省约 0.5 bit/参数
    )

    print(f"量化配置: 4-bit {args.bnb_4bit_quant_type}, 计算类型: {compute_dtype}")
    print(f"双量化: {'启用' if args.bnb_4bit_use_double_quant else '禁用'}")

    # 2. 加载 tokenizer
    tokenizer = AutoTokenizer.from_pretrained(args.model_name_or_path, use_fast=True)
    if tokenizer.pad_token is None:
        tokenizer.pad_token = tokenizer.eos_token

    # 3. 加载量化模型
    model = AutoModelForCausalLM.from_pretrained(
        args.model_name_or_path,
        quantization_config=bnb_config,
        device_map="auto",
    )

    # 禁用 KV cache 缓存以支持 gradient checkpointing
    model.config.use_cache = False
    # QLoRA 训练前必须做 k-bit 训练准备, 否则可能出现梯度为 None
    model = prepare_model_for_kbit_training(model)

    # 4. 配置 LoRA
    target_modules = args.target_modules.split(",") if args.target_modules else None

    lora_config = LoraConfig(
        r=args.lora_r,
        lora_alpha=args.lora_alpha,
        target_modules=target_modules,
        lora_dropout=args.lora_dropout,
        bias=args.bias,
        task_type=TaskType.CAUSAL_LM,
    )

    # 5. 应用 PEFT/LoRA 到量化模型
    model = get_peft_model(model, lora_config)
    model.print_trainable_parameters()

    # 6. 加载数据集
    raw = load_from_disk(args.dataset_name)

    def tokenize_fn(examples):
        texts = examples[args.text_field]
        return tokenizer(
            texts,
            truncation=True,
            max_length=args.max_length,
            padding=False,
        )

    tokenized = raw.map(
        tokenize_fn,
        batched=True,
        remove_columns=raw["train"].column_names,
        desc="Tokenizing",
    )

    # 过滤空样本
    tokenized = tokenized.filter(lambda x: len(x["input_ids"]) > 0)

    # 7. 数据整理器
    data_collator = DataCollatorForLanguageModeling(tokenizer=tokenizer, mlm=False)

    # 8. 训练参数 (启用 gradient checkpointing)
    train_args = TrainingArguments(
        output_dir=args.output_dir,
        overwrite_output_dir=True,
        per_device_train_batch_size=args.per_device_train_batch_size,
        per_device_eval_batch_size=args.per_device_eval_batch_size,
        learning_rate=args.learning_rate,
        num_train_epochs=args.num_train_epochs,
        warmup_ratio=args.warmup_ratio,
        weight_decay=args.weight_decay,
        logging_steps=args.logging_steps,
        save_steps=args.save_steps,
        save_total_limit=2,
        eval_strategy="steps" if args.do_eval else "no",
        eval_steps=args.eval_steps if args.do_eval else None,
        fp16=True,
        bf16=False,
        deepspeed=args.deepspeed,
        report_to="none",
        dataloader_num_workers=2,
        gradient_checkpointing=True,  # QLoRA 必需: 节省显存
    )

    # 9. 创建 Trainer
    trainer = Trainer(
        model=model,
        args=train_args,
        train_dataset=tokenized["train"],
        eval_dataset=tokenized.get("validation", None) if args.do_eval else None,
        tokenizer=tokenizer,
        data_collator=data_collator,
    )

    # 10. 训练
    trainer.train()

    # 11. 保存模型 (只保存 LoRA 权重)
    trainer.save_model(args.output_dir)
    tokenizer.save_pretrained(args.output_dir)

    print(f"QLoRA 训练完成! 模型已保存到: {args.output_dir}")
    model.print_trainable_parameters()


if __name__ == "__main__":
    main()
```
