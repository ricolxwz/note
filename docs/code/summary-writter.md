---
title: SummaryWritter
comments: true
---

在 PyTorch 中, `SummaryWriter` 是 `torch.utils.tensorboard` 模块提供的一个类, 主要用于在训练过程中记录和可视化数据, 以便在 TensorBoard 中进行展示. 通过 `SummaryWriter`, 您可以将训练过程中的各种信息(如损失值, 准确率, 模型参数分布, 图像等)记录到指定的日志目录中, 然后使用 TensorBoard 对这些信息进行可视化分析.

主要功能包括:

- 记录标量数据: 使用 `add_scalar()` 方法记录训练过程中的标量值, 如损失和准确率.
- 记录多组标量数据: 使用 `add_scalars()` 方法同时记录多组相关的标量数据, 便于对比分析.
- 记录模型结构: 使用 `add_graph()` 方法将模型的计算图添加到日志中, 方便查看模型的结构.
- 记录图像数据: 使用 `add_image()` 或 `add_images()` 方法记录单张或多张图像数据, 便于观察输入数据或模型生成的图像.
- 记录直方图: 使用 `add_histogram()` 方法记录模型参数或其他张量的分布情况, 帮助分析参数变化.

使用示例:

```python
from torch.utils.tensorboard import SummaryWriter

# 创建 SummaryWriter 对象, 指定日志存储目录
writer = SummaryWriter(log_dir='logs')

# 记录标量数据
for epoch in range(10):
    loss = 0.1 * epoch  # 示例损失值
    writer.add_scalar('Loss/train', loss, epoch)

# 关闭 writer
writer.close()
```

上述代码将在 `logs` 目录下生成日志文件, 可通过 TensorBoard 加载并可视化这些数据. 通过 `SummaryWriter`, 您可以方便地在训练过程中记录和可视化各种信息, 帮助分析和调试模型.
