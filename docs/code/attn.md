---
title: 注意力计算
comments: true
---

下面的代码节选自`site-packages/transformers/modeling_gpt2.py`.

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
