---
title: 注意力计算
comments: true
---

下面的代码节选自`site-packages/transformers/modeling_gpt2.py`的`Attention`类.

* `batch_size`: `B`
* `seq_len`: `T`
* `hidden_dim`: `D`

## 初始化

```py
def __init__(self, nx, n_ctx, config, scale=False):
    super(Attention, self).__init__()
    self.output_attentions = config.output_attentions

    n_state = nx  # in Attention: n_state=768 (nx=n_embd)
    # [switch nx => n_state from Block to Attention to keep identical to TF implem]
    assert n_state % config.n_head == 0
    self.register_buffer("bias", torch.tril(torch.ones(n_ctx, n_ctx)).view(1, 1, n_ctx, n_ctx))
    self.n_head = config.n_head
    self.split_size = n_state
    self.scale = scale

    self.c_attn = Conv1D(n_state * 3, nx)
    self.c_proj = Conv1D(n_state, nx)
    self.attn_dropout = nn.Dropout(config.attn_pdrop)
    self.resid_dropout = nn.Dropout(config.resid_pdrop)
    self.pruned_heads = set()
```

* `nx`: 输入嵌入的维度, 在GPT2中, 这个值是768
* `n_ctx`: 上下文最大长度, 在GPT2中, 这个值是1024
* `config`: 一个配置对象, 里面存放了一些超参数, 如`n_head`, `attn_pdrop`, `redis_pdrop`, `output_attn`等
* `scale`: 决定在注意力计算的时候是否执行`1/sqrt(d_k)`的步骤
* `n_state`: 就是`nx`
* `assert n_state % config.n_head`: 确保`n_state`可以被`n_head`整除, 在多头注意力中会把embedding的维度平分到各个头上
* `self.register_buffer("bias", torch.tril(torch.ones(n_ctx, n_ctx)).view(1, 1, n_ctx, n_ctx))`: 生成一个下三角矩阵, 用于因果掩码. 注册的是一个常量张量, 不会被当作可训练参数
* `self.n_head = config.n_head`: 多头注意力的头数, 在GPT2中, 这个值是12
* `self.split_size = n_state`: 就是`nx`, 可读性, 兼容性
* `self.scale`: 表示后续在`_attn`函数中是否使用`1/sqrt(d_k)`做缩放
* `self.c_attn = Conv1D(n_state * 3, nx)`: 一个Conv1D层, 将输入映射到Q, K, V三个矩阵, 总特征维度是`n_state*3`
* `self.c_proj = Conv1D(n_state, nx)`: 一个Conv1D层, 将注意力计算结果(value)矩阵做一个线性变换
* `self.attn_dropout = nn.Dropout(config.attn_pdrop)`: 用于注意力权重的Dropout
* `self.resid_dropout = nn.Dropout(config.resid_pdrop)`: 用于残差连接的Dropout
* `self.pruned_heads = set()`: 记录剪枝被剪掉的注意力头

## 前向传播

```py
def forward(self, x, layer_past=None, attention_mask=None, head_mask=None):
    x = self.c_attn(x)
    query, key, value = x.split(self.split_size, dim=2)
    query = self.split_heads(query)
    key = self.split_heads(key, k=True)
    value = self.split_heads(value)
    if layer_past is not None:
        past_key, past_value = layer_past[0].transpose(-2, -1), layer_past[1]  # transpose back cf below
        key = torch.cat((past_key, key), dim=-1)
        value = torch.cat((past_value, value), dim=-2)
    present = torch.stack((key.transpose(-2, -1), value))  # transpose to have same shapes for stacking

    attn_outputs = self._attn(query, key, value, attention_mask, head_mask)
    a = attn_outputs[0]

    a = self.merge_heads(a)
    a = self.c_proj(a)
    a = self.resid_dropout(a)

    outputs = [a, present] + attn_outputs[1:]
    return outputs  # a, present, (attentions)
```

## 注意力头生成

```py
def split_heads(self, x, k=False):
    new_x_shape = x.size()[:-1] + (self.n_head, x.size(-1) // self.n_head)
    x = x.view(*new_x_shape)  # in Tensorflow implem: fct split_states
    if k:
        return x.permute(0, 2, 3, 1)  # (batch, head, head_features, seq_length)
    else:
        return x.permute(0, 2, 1, 3)  # (batch, head, seq_length, head_features)
```

* `x`: 一个批次的嵌入, 形状为`(B, T, D)`, 如`(2, 200, 768*3)`
* `k`: 决定如何重新排列维度
* `new_x_shape = x.size()[:-1] + (self.n_head, x.size(-1) // self.n_head)`: 计算新的形状, 原来的形状是`(B, T, D)`, 新的形状是`(B, T, self.n_head, D//self.n_head)`, 例如, 假设`self.n_head=12`, `(2, 200, 768*3)->(2, 200, 64*3)`
* `x = x.view(*new_x_shape)`: 执行形状变换

## 注意力权重矩阵计算

```py
def _attn(self, q, k, v, attention_mask=None, head_mask=None):
    w = torch.matmul(q, k)
    if self.scale:
        w = w / math.sqrt(v.size(-1))
    nd, ns = w.size(-2), w.size(-1)
    b = self.bias[:, :, ns-nd:ns, :ns]
    w = w * b - 1e4 * (1 - b)

    if attention_mask is not None:
        w = w + attention_mask

    w = nn.Softmax(dim=-1)(w)
    w = self.attn_dropout(w)

    if head_mask is not None:
        w = w * head_mask

    outputs = [torch.matmul(w, v)]
    if self.output_attentions:
        outputs.append(w)
    return outputs
```

* `w = torch.matmul(q, k)`: 计算`Q*K^T`, 得到原始的注意力分数矩阵`w`
* `if self.scale: w = w / math.sqrt(v.size(-1))`: 使用`1/sqrt(d_k)`进行缩放, 避免向量维度过大造成的内积值过大
* `nd, ns = w.size(-2), w.size(-1)`: 取得注意力分数矩阵的形状
* `b = self.bias[:, :, ns-nd:ns, :ns]`: 掩码矩阵, 常常是用一个上三角或者下三角矩阵表示
* `w = w * b - 1e4 * (1 - b)`: 把被遮住的注意力分数直接变成一个很大的负值, 这样在softmax的时候, 该位置的分数会被极大值抑制
* `if attention_mask is not None: w = w + attention_mask`: 如果外部额外传入了`attention_mask`, 则把这个mask加到注意力分数里
* `w = nn.Softmax(dim=-1)(w)`: 在最后的一个维度上做softmax, 将注意力分数转为注意力权重
* `self.attn_dropout(w)`: 对注意力权重施加dropout, 减少模型过拟合, 让注意力分布更具有随机性
* `if head_mask is not None: w = w * head_mask`: 如果有`head_mask`, 说明在训练或者推理的时候要屏蔽掉某些注意力头, 会在对应注意力权重上乘以`0`(或其他权重)
* `outputs = [torch.matmul(w, v)]`: 最后用`w`和`v`做矩阵乘法, 得到加权后的value输出
* `if self.output_attentions: outputs.append(w)`: 如果`self.output_attentions`为真, 那么会在`outputs`中把注意力权重`w`一并返回, 方便后续做可视化或其他分析
