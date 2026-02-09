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

* `train_batch_size`：一次参数更新的时候, 模型实际看过的样本总数. `train_batch_size` = `per_device_train_batch_size` * `gradient_accumulation_steps` * `world_size`. 本质上是micro_batch + gradient accumulation的方法. 

### ZeRO
