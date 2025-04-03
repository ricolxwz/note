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
