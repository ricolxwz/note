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
