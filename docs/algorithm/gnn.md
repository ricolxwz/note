---
title: GNN
comments: false
---

## 图的基本组成

图由下列属性构成:

* Vertex Attributes

    例如节点的特征, 邻居节点的数量等.

* Edge Attributes

    例如边的特征, 边的权重, 方向等.

* Global Attributes

    例如整个图的节点数, 最长路径, 连通分量的个数等.

## 图神经网络要干啥

类似于NLP任务中的词嵌入过程, 图神经网络的目标就在于优化其点, 边, 全局的特征表示, 或者说, 我们要得到的是Vertex Embedding, Edge Embedding, Global Embedding. 举个例子, 在NLP中, 我们可能会使用CBOW从当前词的两边的上下文预测中间的词, 然后更新中间的词的词嵌入, GNN也是类似, 用当前节点相邻的节点预测当前节点, 然后更新当前节点的节点嵌入.

## 图的邻接矩阵

计算机是不知道图长啥样的, 一个告诉计算机图的方式就是邻接矩阵. 一般在建模的时候, 会输入点的特征和这个邻接矩阵, 可以表示为GNN(A, X), 其中, A是邻接矩阵, X是点的特征. 其实文本数据也可以表示为图的形式, 邻接矩阵表示的是连接关系.

## 图神经网络的应用

到目前为止, 好像没有见到过哪一个NLP或者CV任务要套用图神经网络的... 这是因为在图像和文本任务中, 输入通常都能被预处理成固定的格式, 因此不需要像图结构那样的邻接矩阵表示节点之间的关系. 具体来说:

* 图像: 一般会将所有的图像resize成同样的固定大小, 比如224\*224, 这样每张图就会变成一个规则的网格数据, 可以直接使用CNN提取特征, 无需关系额外的连接结构
* 文本: 大多数自然语言处理任务会将句子或者文档截断或者填充到固定长度, 然后用词向量或者嵌入层将其转换为固定维度的向量序列. 这个序列依赖位置, 而不是基于图中节点和边的连接关系, 因此同样不需要邻接矩阵

与传统深度学习主要处理规则的欧几里得数据(比如图像的网络结构或文本的序列结构)不同, GNN能够直接在图这种非欧几里得结构上进行建模. 它擅长处理复杂的拓扑关系, 比如社交网络, 知识图谱, 生物分子结构等.

## 邻接矩阵的表示

由于邻接矩阵本身是一个非常大的矩阵, 所以在一般情况下, 是表示为source, target的一个形式, 注意下面的`Adjacency List`:

```
Nodes
[0, 1, 1, 0, 0, 1, 1, 1]

Edges
[2, 1, 1, 1, 3, 1, 1]

Adjacency List
[[1, 0], [2, 0], [4, 3], [6, 2], [7, 3], [7, 4], [7, 5]]

Global
0
```

## 消息传递

在Message Passing Neural Network中, 每个节点会从它的邻居节点收集信息(即"消息"), 然后将这些信息和自身的信息结合, 最终更新得到新的节点表示, 这个过程通常分为以下两步:

1. 消息聚合(Message Aggregation)

    对节点$i$的所有邻居节点$j\in \mathcal{N}_i$进行消息收集, 可以使用各种聚合函数(如Sum, Mean, Max, Min等), 这些聚合函数可以看作是一种"全连接操作", 因为它们会对邻居节点的特征进行线性或者加权变换后再组合, 可以表示为$m_i=G(\{\mathbf{W}_j\cdot x_j; j\in \mathcal{N}_i\})$, 其中$x_j$是邻居节点的输入, $\mathbf{W}_j$是可学习的参数, 而$G()$代表的是聚合函数(如求和或者求均值等等).

2. 节点状态更新(Node Update)

    将聚合得到的邻居信息和节点自身的表示结合, 通过某个非线性变换(如ReLU或者其他激活函数)更新节点表示. 若聚合函数为求和, 可以表示为$h_i=\sigma(W_1\cdot h_i+\sum_{j\in \mathcal{N}_i} \mathbf{W}_j\cdot h_j)$, 这里的$h_i$表示节点$i$当前的隐藏表示, $\sigma()$是非线性激活函数, 而$W_1$和$\mathbf{W}_2$是可学习的权重. 这个更新公式的本质就是"节点自身的特征的线性变换加上邻居特征经过线性变换后再聚合的结果, 然后过一个激活函数得到新的表示.

所以GNN的本质就是更新各部分特征, 其中输入是特征, 输出也是特征, 邻接矩阵是不会边的. GNN一般是要做多层的, 虽然当前节点只能看到它的邻居, 但是它的邻居的特征表示也是会改变的, 类比于CNN中, 这个节点, 它的感受野在不断的扩大.

## 输出特征的作用

输出特征能干啥呢? 首先, 将各个点的特征组合, 做一个pooling, 然后可以得到这个图的全局分类. 各个节点也可以分类, 边也是如此. 其实只是利用GNN得到图的结构特征, 最终要做什么还是我们自己决定.

## GCN

GCN(Graph Convolutional Network)是一种处理图结构数据的神经网络模型, 它将卷积操作扩展到图上面(实际上看不出什么卷积(o_ _)ﾉ). 通过聚合节点邻居信息来更新节点表示, 你可以理解为它的卷积核的大小是动态的, 是取决于当前节点周围的邻居的数量的.

### 半监督学习

半监督学习是GCN的一个很大的优势. 和传统方法相比, GCN在图结构数据上可以自然地利用节点之间地关系, 即使只有部分节点带有标签信息, 也能通过网络传递和聚合特征来学习到整体的表示. 换句话说, 对于图数据, 我们可以标记一部分节点, 然后通过GCN的传播机制, 让未标注节点也能间接地学习到有用地特征.

### 基本思想

GCN的基本思想就是平均其邻居的特征(包括自身)后传入神经网络. GCN可以做多层, 每一层输入的都是所有点的特征, 将但钱的特征和网络结构图继续传入下层就可以不断算下去了. 一般较小的图网络不用太多的层数, 这印证了一句话: "你只需要6个人, 就能够了解全世界".

### 特征的计算方法

GCN中, 图被表示为$\mathbf{A}$, 邻接矩阵; $\mathbf{X}$, 每个节点的特征. 特征的计算方法如下:

假设我们有一个包含4个节点的简单无向图, 邻接矩阵 \( \mathbf{A} \) 定义如下:

\[
\mathbf{A} = \begin{bmatrix}
0 & 1 & 0 & 1 \\
1 & 0 & 1 & 0 \\
0 & 1 & 0 & 0 \\
1 & 0 & 0 & 0
\end{bmatrix}.
\]

我们也可以给每个节点一个简单的特征向量(这里为了简单, 用一维特征示意, 实际上可以是多维), 比如:

\[
\mathbf{X} = \begin{bmatrix}
x_1 \\
x_2 \\
x_3 \\
x_4
\end{bmatrix}.
\]

1. 计算 \( \hat{\mathbf{A}} = \mathbf{A} + \mathbf{I} \)

    因为 GCN 常用自环 (self-loop) 的技巧来保留节点自身信息, 我们把单位矩阵 \( \mathbf{I} \) 加到 \( \mathbf{A} \) 上:

    \[
    \mathbf{I} = \begin{bmatrix}
    1 & 0 & 0 & 0 \\
    0 & 1 & 0 & 0 \\
    0 & 0 & 1 & 0 \\
    0 & 0 & 0 & 1
    \end{bmatrix}.
    \]

    因此,

    \[
    \hat{\mathbf{A}}
    = \mathbf{A} + \mathbf{I}
    = \begin{bmatrix}
    0 & 1 & 0 & 1 \\
    1 & 0 & 1 & 0 \\
    0 & 1 & 0 & 0 \\
    1 & 0 & 0 & 0
    \end{bmatrix}
    +
    \begin{bmatrix}
    1 & 0 & 0 & 0 \\
    0 & 1 & 0 & 0 \\
    0 & 0 & 1 & 0 \\
    0 & 0 & 0 & 1
    \end{bmatrix}
    =
    \begin{bmatrix}
    1 & 1 & 0 & 1 \\
    1 & 1 & 1 & 0 \\
    0 & 1 & 1 & 0 \\
    1 & 0 & 0 & 1
    \end{bmatrix}.
    \]

2. 计算 \( \hat{\mathbf{D}} \)

    \( \hat{\mathbf{D}} \) 是对角矩阵, 其第 \( i \) 个对角元素为第 \( i \) 行在 \( \hat{\mathbf{A}} \) 下的度 (行和). 我们来逐行计算:

    - 第 1 行: \( 1 + 1 + 0 + 1 = 3 \)
    - 第 2 行: \( 1 + 1 + 1 + 0 = 3 \)
    - 第 3 行: \( 0 + 1 + 1 + 0 = 2 \)
    - 第 4 行: \( 1 + 0 + 0 + 1 = 2 \)

    因此度矩阵为:

    \[
    \hat{\mathbf{D}}
    = \begin{bmatrix}
    3 & 0 & 0 & 0 \\
    0 & 3 & 0 & 0 \\
    0 & 0 & 2 & 0 \\
    0 & 0 & 0 & 2
    \end{bmatrix}.
    \]

3. 计算 \( \hat{\mathbf{D}}^{-\frac{1}{2}} \)

    我们把对角元素都开平方的倒数:

    - \( 3^{-\frac{1}{2}} = \frac{1}{\sqrt{3}} \)
    - \( 2^{-\frac{1}{2}} = \frac{1}{\sqrt{2}} \)

    所以,

    \[
    \hat{\mathbf{D}}^{-\frac{1}{2}}
    = \begin{bmatrix}
    \frac{1}{\sqrt{3}} & 0 & 0 & 0 \\
    0 & \frac{1}{\sqrt{3}} & 0 & 0 \\
    0 & 0 & \frac{1}{\sqrt{2}} & 0 \\
    0 & 0 & 0 & \frac{1}{\sqrt{2}}
    \end{bmatrix}.
    \]

4. 构造归一化邻接矩阵 \(\tilde{\mathbf{A}} = \hat{\mathbf{D}}^{-\frac{1}{2}} \, \hat{\mathbf{A}} \, \hat{\mathbf{D}}^{-\frac{1}{2}}\)

    这是两次矩阵乘法, 可以拆为:

    1. 先做 \(\hat{\mathbf{D}}^{-\frac{1}{2}} \hat{\mathbf{A}}\)
    2. 再用结果乘 \(\hat{\mathbf{D}}^{-\frac{1}{2}}\) (从右侧)

    为了清晰, 我们一步到位地写最终结果(如果你想亲手算, 按行 × 列逐项相乘即可). 最终得到:

    \[
    \tilde{\mathbf{A}}
    =
    \begin{bmatrix}
    \frac{1}{3} & \frac{1}{3} & 0 & \frac{1}{\sqrt{6}} \\
    \frac{1}{3} & \frac{1}{3} & \frac{1}{\sqrt{6}} & 0 \\
    0 & \frac{1}{\sqrt{6}} & \tfrac{1}{2} & 0 \\
    \frac{1}{\sqrt{6}} & 0 & 0 & \tfrac{1}{2}
    \end{bmatrix}.
    \]

    > 其中的数值像 \(\frac{1}{\sqrt{6}}\) 就来自 \(\frac{1}{\sqrt{3}} \times \frac{1}{\sqrt{2}}\) 之类的连乘. 你也可以保留在"\(\frac{1}{\sqrt{3} \cdot \sqrt{2}}\)"的形式.

5. 与特征矩阵 \(\mathbf{X}\) 相乘, 得到聚合后的特征

    现在我们来做 \(\tilde{\mathbf{A}} \mathbf{X}\). 由于 \(\mathbf{X}\) 是 \(4 \times 1\) 的列向量:

    \[
    \tilde{\mathbf{A}}
    =
    \begin{bmatrix}
    \frac{1}{3} & \frac{1}{3} & 0 & \frac{1}{\sqrt{6}} \\
    \frac{1}{3} & \frac{1}{3} & \frac{1}{\sqrt{6}} & 0 \\
    0 & \frac{1}{\sqrt{6}} & \tfrac{1}{2} & 0 \\
    \frac{1}{\sqrt{6}} & 0 & 0 & \tfrac{1}{2}
    \end{bmatrix},
    \quad
    \mathbf{X}
    = \begin{bmatrix}
    x_1 \\
    x_2 \\
    x_3 \\
    x_4
    \end{bmatrix}.
    \]

    进行矩阵乘法(4×4 乘以 4×1), 最终得到一个 4×1 的向量:

    \[
    \tilde{\mathbf{A}} \mathbf{X}
    =
    \begin{bmatrix}
    \dfrac{x_1}{3} + \dfrac{x_2}{3} + 0 \cdot x_3 + \dfrac{x_4}{\sqrt{6}} \\[6pt]
    \dfrac{x_1}{3} + \dfrac{x_2}{3} + \dfrac{x_3}{\sqrt{6}} + 0 \cdot x_4 \\[6pt]
    0 \cdot x_1 + \dfrac{x_2}{\sqrt{6}} + \dfrac{x_3}{2} + 0 \cdot x_4 \\[6pt]
    \dfrac{x_1}{\sqrt{6}} + 0 \cdot x_2 + 0 \cdot x_3 + \dfrac{x_4}{2}
    \end{bmatrix}.
    \]

    具体展开为:

    1. 第 1 行 (节点 1): \(\tfrac{x_1}{3} + \tfrac{x_2}{3} + \tfrac{x_4}{\sqrt{6}}\)
    2. 第 2 行 (节点 2): \(\tfrac{x_1}{3} + \tfrac{x_2}{3} + \tfrac{x_3}{\sqrt{6}}\)
    3. 第 3 行 (节点 3): \(\tfrac{x_2}{\sqrt{6}} + \tfrac{x_3}{2}\)
    4. 第 4 行 (节点 4): \(\tfrac{x_1}{\sqrt{6}} + \tfrac{x_4}{2}\)

    这就是一次"邻域特征聚合"(包含自环). 你可以看到, 每个节点的新特征都来自于它周围(含自身)节点特征的加权和.

6. 乘以可学习权重 \(\mathbf{W}\) 并加激活

    通常在 GCN 的一层中, 还会加一个可学习的线性变换 \(\mathbf{W}\). 如果你的输入是 1 维特征, 而想输出 \(d'\) 维特征(比如 2 维), 那 \(\mathbf{W}\) 尺寸是 \((1 \times d')\). 整体公式为:

    \[
    \mathbf{H}
    = \sigma \Bigl( \tilde{\mathbf{A}} \, \mathbf{X} \, \mathbf{W} \Bigr),
    \]

    其中 \(\sigma(\cdot)\) 常见是 ReLU 或其它非线性函数.

    - 首先, \(\tilde{\mathbf{A}} \mathbf{X}\) 得到一个 \(4 \times 1\) 的向量(如上所示).
    - 将其乘以 \(\mathbf{W}\) (例如 \(1\times d'\)) 后, 结果变为 \(4\times d'\) 的矩阵.
    - 最后通过 \(\sigma\) 做非线性变换, 得到新的节点特征表征 \(\mathbf{H}\) (尺寸同 \(4\times d'\)).

    > 如果初始特征是多维(比如 \(4\times d\)), 只要把上面的计算思路扩展到 \(\tilde{\mathbf{A}} (4\times4)\) × \(\mathbf{X} (4\times d)\) × \(\mathbf{W} (d\times d')\), 就能得到 \(4\times d'\) 的结果, 原理不变, 只是向量变成矩阵运算.

若将上面的公式展开到单个节点$i$的级别, 就能写成下列形式:

\[
h_i^{(l+1)}
= \sigma\Biggl(
  \underbrace{\frac{1}{\sqrt{\hat{D}_{ii}\,\hat{D}_{ii}}} \,W^{(l)}\,h_i^{(l)}}_{\text{自身特征}}
  \;+\;
  \underbrace{\sum_{j \in \mathcal{N}_i} \frac{1}{\sqrt{\hat{D}_{ii}\,\hat{D}_{jj}}} \,W^{(l)}\,h_j^{(l)}}_{\text{邻居特征}}
\Biggr),
\]

其中:

- \(h_i^{(l)}\) 是第 \(l\) 层时节点 \(i\) 的特征向量(也可以写成 \(\bigl(H^{(l)}\bigr)_{i,:}\)).
- \(\frac{1}{\sqrt{\hat{D}_{ii}\,\hat{D}_{jj}}}\) 来自对称归一化 \(\hat{D}^{-\tfrac12}\hat{A}\hat{D}^{-\tfrac12}\) 中的系数;
- "自身特征"其实就是把节点 \(i\) 自己也当做"邻居", 对应 \(\hat{A}_{ii}=1\).

这样就看得更直观: 第 \(i\) 个节点将自己的特征 \(h_i^{(l)}\) 与所有邻居 \(j\) 的特征 \(h_j^{(l)}\) 按照度数进行归一化加权, 然后过一层线性变换 \(W^{(l)}\), 再经过 \(\sigma\) 激活, 得到新的特征 \(h_i^{(l+1)}\).

???+ note "为什么要对自身进行缩放"

    在GCN中, 对自身节点进行缩放的目的是为了平衡节点度数的差异, 保持对称性, 确保数值稳定性. GCN的临界矩阵添加了自环($\hat{\mathbf{A}}=\mathbf{A}+\mathbf{I}$), 这会改变节点的度数($\hat{d_i}=d_i+1$), 归一化需要反应新的度数对所有连接(包括自环)的影响. 如果仅对邻居归一化而忽略自身, 会导致: 自身特征的权重未被调整, 破坏对称性; 高度数节点的自身特征在多层传播中持续放大, 造成数值不稳定. 换句话说, 高度数节点会梯度爆炸, 低度数节点会梯度消失. 归一化归的就是度数.

???+ note "为什么要左乘还要右乘$\mathbf{D}^{-1/2}$"

    这是为了保持对称归一化, 统一调整源节点和目标节点的度数对权重的影响.

    左乘的数学含义是对源节点进行缩放:


    * 高度数源节点(\(\hat{d}_i\) 大): 该行所有元素被缩小(例如除以 \(\sqrt{\hat{d}_i}\)), 避免该节点发出的边权重过大.
    * 低度数源节点(\(\hat{d}_i\) 小): 该行所有元素被放大(例如除以 \(\sqrt{\hat{d}_i}\)), 增强其发出的边权重.

    右乘的数学含义是对目标节点进行缩放:

    * 高度数目标节点(\(\hat{d}_j\) 大): 该列所有元素被缩小(例如除以 \(\sqrt{\hat{d}_j}\)), 避免该节点接收的边权重过大.
    * 低度数目标节点(\(\hat{d}_j\) 小): 该列所有元素被放大(例如除以 \(\sqrt{\hat{d}_j}\)), 增强其接收的边权重.

    这样:

    * 高度数节点到低度数节点: 权重被抑制(例如 \(\frac{1}{\sqrt{4 \cdot 1}} = 0.5\));
    * 低度数节点到高度数节点: 权重也被抑制(同上例, 对称性保证权重一致);
    * 低度数节点之间: 权重被放大(例如 \(\frac{1}{\sqrt{1 \cdot 1}} = 1\)).

    ???+ example "富二代例子"

        现在, 小绿是一个富二代, 他的朋友非常多, 度很高, 但是小红只认识小绿一个人, 他的度非常小. 现在的任务是根据这些节点的特征向量判断他是否是富二代. 由于小红只和小绿有连接, 所以他的特征会很大程度上受到小绿的影响, 导致小红也被判断为富二代, 然而事实是他两只是小时候在贫民窟认识的. 那么如何减少这种影响呢, 这就是右乘发挥作用的时候了, 这条关系对小绿其实不那么重要, 但是对小红很重要, 所以可以通过右乘$\frac{1}{\sqrt{\text{小绿的度}}}$来实现降低重要性的效果.

???+ tip "两层公式"

    如果有两层, 上面的公式就变为: $\mathbf{H}=\text{softmax}(\hat{\mathbf{A}}\sigma(\hat{\mathbf{A}}\mathbf{X}\mathbf{W}^{(0)})\mathbf{W}^{(1)})$.

### 层数

理论上来说肯定越大越好, 但是实际的图种可能不需要这么多, 回想一下我们的例子, 在社交网络中, 只需要6个人你就可以认识全世界, 所以一般GCN的层数不会特别多. 并且在实验中, 可以发现两三层比较合适, 多了反而差了.

### PyG使用

PyG是一个GNN的Python库. 一个示例的代码:

```py
# %%
import torch
import networkx as nx
import matplotlib.pyplot as plt

# %%
def visualize_graph(G, color=None):
    plt.figure(figsize=(7, 7))
    plt.xticks([])
    plt.yticks([])
    nx.draw_networkx(G, pos=nx.spring_layout(G, seed=42), with_labels=False, node_color=color, cmap="Set2")
    plt.show()

def visualize_embedding(h, color, epoch=None, loss=None):
    plt.figure(figsize=(7, 7))
    plt.xticks([])
    plt.yticks([])
    h = h.detach().cpu().numpy()
    plt.scatter(h[:, 0], h[:, 1], c=color, s=140, cmap="Set2")
    if epoch is not None and loss is not None:
        plt.xlabel(f"Epoch: {epoch}, Loss: {loss:.4f}", fontsize=16)
    plt.show()

# %%
from torch_geometric.datasets import KarateClub  # 使用一个示例的数据集
dataset = KarateClub()
print(f"Dataset: {dataset}:")
print("==========================")
print(f"Number of graphs: {len(dataset)}")
print(f"Number of features: {dataset.num_features}")
print(f"Number of classes: {dataset.num_classes}")
print(f"Number of nodes: {dataset[0].num_nodes}")
print(f"Number of edges: {dataset[0].num_edges}")

# %%
data = dataset[0]
print(data)

# %%
print(data["train_mask"])  # 这个是一个布尔掩码, 表示哪些节点用于有监督训练

# %%
edge_index = data["edge_index"]
print(edge_index.t())  # 这个是一个边索引, 表示图的连接关系

# %%
from torch_geometric.utils import to_networkx
G = to_networkx(data, to_undirected=True)
visualize_graph(G, color=data.y)

# %%
from torch.nn import Linear
from torch_geometric.nn import GCNConv
class GCN(torch.nn.Module):
    def __init__(self):
        super().__init__()
        torch.manual_seed(42)
        self.conv1 = GCNConv(dataset.num_features, 4)
        self.conv2 = GCNConv(4, 4)
        self.conv3 = GCNConv(4, 2)
        self.classifier = Linear(2, dataset.num_classes)

    def forward(self, x, edge_index):
        h = self.conv1(x, edge_index)
        h = h.tanh()
        h = self.conv2(h, edge_index)
        h = h.tanh()
        h = self.conv3(h, edge_index)
        h = h.tanh()
        out = self.classifier(h)
        return out, h
model = GCN()
print(model)

# %%
# 可视化一下还没训练模型的时候, 它的输出
model = GCN()
_, h = model(data.x, data.edge_index)
print(f"Embedding shape: {list(h.shape)}")
visualize_embedding(h, color=data.y)

# %%
import time
model = GCN()
criterion = torch.nn.CrossEntropyLoss()
optimizer = torch.optim.Adam(model.parameters(), lr=0.01)
def train(data):
    optimizer.zero_grad()
    out, h = model(data.x, data.edge_index)
    loss = criterion(out[data.train_mask], data.y[data.train_mask])  # 半监督训练
    loss.backward()
    optimizer.step()
    return loss, h
for epoch in range(401):
    loss, h = train(data)
    if epoch % 10 == 0:
        print(f"Epoch: {epoch}, Loss: {loss.item():.4f}")
        visualize_embedding(h, color=data.y, epoch=epoch, loss=loss.item())
        time.sleep(0.3)
```

这是一开始随机初始化后, `h`在空间中的分布(还未进行训练):

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/4130ba9c496734f38415c1f0f6a3ec51.webp#only-light){ loading=lazy width='400' }
![](https://img.ricolxwz.io/4130ba9c496734f38415c1f0f6a3ec51_inverted.webp#only-dark){ loading=lazy width='400' }
</figure>

这是400个epoch之后, `h`在空间中的分布:

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/9f811a555cb71fab0c3e50084f55ced9.webp#only-light){ loading=lazy width='400' }
![](https://img.ricolxwz.io/9f811a555cb71fab0c3e50084f55ced9_inverted.webp#only-dark){ loading=lazy width='400' }
</figure>

## GAT

Graph Attention Netowrk(GAT)是一种面向图结构数据的神经网络模型, 其核心思想是通过自注意力机制(Self-Attention)来动态调整节点之间的信息交互权重. 简单来说, 在图结构中的每个节点会从它的邻居节点接受信息, 但是不同的邻居对于该节点的重要性不一定相同. GAT引入注意力机制, 根据节点和邻居之间的相关度自动学习到合适的注意力权重, 从而使得模型更准确地捕捉到不同邻居对节点的影响程度.

### 和GCN的区别

GAT和GCN的主要区别在于邻居节点的信息聚合方式:

1. GCN采用固定的邻居权重

    在GCN中, 节点会从邻居节点接受信息, 但是所有的邻居节点的贡献通常按照预先计算好的权重(如对称归一化拉普拉斯矩阵)统一处理. 这个权重是由源点的度和目标节点的度决定的.

2. GAT采用可学习的注意力机制

    GAT通过自注意力机制来计算节点和邻居之间的相对重要性, 每个邻居的权重是科学系的, 从而能够适应不同图结构和节点的特征分布, 提高模型的灵活性和表达能力. GAT并不依赖源点和目标节点的度, 它的权重是由一个注意力得分决定的. 在原始的GAT论文中还使用了多头注意力机制, 即对同一组邻居节点进行多次注意力计算, 然后将这些结果进行拼接或者求平均, 这样做可以在一定程度上稳定训练并增强模型的表达能力.

### 计算过程

在GAT中, attention的计算过程一般可以分成以下的几个步骤:

1. 线性变换

    首先, 对每个节点的特征向量进行一次线性变换. 假设某个节点的原始特征为$h_i$, 则可以通过一个可学习的参数矩阵$\mathbf{W}$得到新的特征表示:

    $$
    h_i'=\mathbf{W}h_i
    $$

2. 计算注意力分数

    对于目标节点$i$及其邻居节点$j$, 原始GAT的做法是将它们的特征拼接或者其他的方式组合, 然后通过一个可学习的向量$a$和激活函数(例如LeakyReLU)来得到两者之间的注意力分数$e_{ij}$(计算自注意力分数的方式层出不穷, 这是最开始的那个哥们计算注意力的方法):

    $$
    e_{ij}=\text{LeakyReLU}(a^T[h_i'||h_j'])
    $$

    其中, $||$表示向量拼接, $a^T[h_i'||h_j']$表示向量$a$和向量$[h_i'||h_j']$的内积, 结果是一个标量.

3. 归一化

    在目标节点$i$的所有的邻居节点中, 使用Softmax函数对注意力分数进行归一化, 得到最终的注意力权重$a_{ij}$:

    $$
    a_{ij}=\frac{\exp(e_{ij})}{\sum_{k\in N(i)} \exp(e_{ik})}
    $$

    其中, $N(i)$表示节点$i$的邻居集合.

4. 消息聚合

    最终, 对邻居节点信息进行加权求和, 即将邻居节点特征按照注意力权重$a_ij$来加权:

    $$
    h_i''=\sum_{j\in N(i)}a_{ij}h_j'
    $$

    其中, $h_i''$是节点$i$在该GAT层的输出表示

5. 多头注意力

    在实际应用中, 通常会使用多头注意力机制来增强表达能力并稳定训练. 即对于同一组节点, 进行多次平行的注意力计算, 然后将所有头的结果进行拼接或者求平均.

其实上述操作就是对邻接矩阵$\hat{\mathbf{A}}$进行了一个加权的操作, 原本这个矩阵里面的元素要不是1就是0, 现在有介于0和1之间的值(归一化自注意力权重).

## TGN

Temporal Graph Networks(TGN)是一种针对动态图的深度学习框架, 它利用记忆模块来存储节点的历史信息, 并通过消磁传递机制来更新这些记忆. 举个简单的例子, 社交网络, 今天还是朋友, 明天就不是朋友了, 边没了; 明天甚至直接删号了, 这个节点都不见了. 所以说, 图在这种情况下是动态变化的, 就需要用到TGN来处理了, 这叫做dynamic graph, 节点和边可能会随着时间消失/新增. 还有另一类static graph只是节点的特征值随着时间在改变, 这一类也和时间有关系.

### 基本思路

原始的TGN本质上是对GCN上做一个LSTM的套用. 以一个static的图为例
