---
title: Paraformer
comments: false
---

## 简介

Paraformer是2022年由达摩院提出的一种端到端, 非自回归的语言识别模型, 目标是在尽量不掉太多准确率的前提下, 把传统语音识别里面最慢的"一个字一个字往后生成"这件事情改为"尽量并行地一起生成". 论文报告说, 在AISHELL-1, AISHELL-2和一个2万小时工业数据集上, 做到了和强自回归Transformer一样的效果, 同时推理速度提升10倍以上.

先说说为啥Paraformer会出现, 传统的很多ASR模型, 尤其是自回归的encoder-decoder模型, 解码的时候要先预测第一个字, 然后再拿第一个字去预测第二个字, 再预测第三个字... 也就是说, 后一个字依赖前一个字, 所以天然较慢. Paraformer走的是另一条路, 尽量把整句多个token同时预测出来, 这就是非自回归的核心.

它的整体结构可以分为4个主要部分: Encoder, Predictor, Sampler, Decoder. Encoder先把音频特征编码为更高层次的表示; Predictor负责估计这段语音大概要对应多少个输出token, 并产出和这些token对齐的声学embedding; Sampler在训练的时候加入语义信息, 帮助模型学会字和字之间是有上下文关系的; Decoder再根据这些信息并行输出最终文字.

这里最关键的是Predictor, 可以把它理解为先粗略决定这句话大概有几个字, 以及每个字大概对应哪一段声音. Paraformer不是直接靠CTC先出一个粗结果, 而是用了CIF, Continuous Integrate-and-File. CIF会对encoder的时间帧做一种软对齐, 单调对齐: 不断累积权重, 累积到某个阈值, 就认为这里够形成一个token了, 于是切出一个对应的声学embedding. 这样模型既能预测输出长度, 也能得到比较像"每个字的声学表示"的东西.

只靠并行预测会产生一个问题, 字和字之间的依赖关系会变弱. 比如一句话里面, "今天 天气 很 好"和"今天 天气 很 号", 单个位置看着都像, 但是整句上下文会告诉你"好"更加合理. Paraformer为了解决这个问题, 在训练里面加了一个GLM Sampler, 也就是glancing language model sampler. 它会把一部分目标token的语义信息喂给模型, 让Decoder不只是看声学, 还能学会句子内部的上下文关系.

再往后是Decoder. Paraformer的Decoder和很多传统自回归Decoder不一样, 它是双向的. 而且在推理的时候做的是并行输出, 而不是按照顺序一个字一个字. 论文还特别说明: 训练的时候Sampler会参与, 两次前向帮助模型学习上下文. 但是推理的时候sampler不工作, 模型直接用acoustic embedding和encoder hidden states一次性输出最终结果.

训练目标上, Paraformer不只是普通的交叉熵. 论文提到它同时使用了MAE去约束Predictor学准输出长度, 还使用了MWER, 也就是minimum word error rate训练, 让模型更直接朝"降低词错率/字错率"的目标优化.

## 动机

近年来, 随着端到端语音识别的流行, 基于 Transformer 结构的语音识别系统逐渐成为了主流. 然而, 由于 Transformer 是一种自回归模型, 需要逐个生成目标文字, 计算复杂度随着目标文字数量而呈线性增加, 限制了其在工业生产中的应用.

针对 Transoformer 模型自回归生成文字的低计算效率的缺陷, 学术界提出了非自回归模型来并行地输出目标文字. 根据生成目标文字时的迭代轮数, 非自回归模型分为: 多轮迭代式与单轮非自回归模型.

迭代式非自回归模型, 主要为 Mask-Predict 模式, 训练时, 将输入文字随机掩码, 通过周边信息预测当前文字. 解码时, 采用多轮迭代的方式逐步生成目标文字; 计算复杂度与迭代轮数有关(通常小于目标文字个数), 相比于自回归模型, 计算复杂度有所下降, 但是解码需要多轮迭代的特性, 限制了其在工业生产中的应用. 相比于多轮迭代模型, 单轮非自回归模型有着更加广阔的应用前景, 可以通过单次解码获取全部目标文字, 计算复杂度与目标文字个数无关, 进而极大的提高了解码效率. 然而, 由于条件独立假设, 单轮非自回归模型识别效果与自回归模型有着巨大的差距, 特别是在工业大数据上.

对于单轮非自回归模型, 现有工作往往聚焦于如何更加准确的预测目标文字个数, 如较为典型的 Mask CTC, 采用 CTC 预测输出文字个数, 尽管如此, 考虑到现实应用中, 语速, 口音, 静音以及噪声等因素的影响, 如何准确的预测目标文字个数以及抽取目标文字对应的声学隐变量仍然是一个比较大的挑战.

另外一方面, 我们通过对比自回归模型与单轮非自回归模型在工业大数据上的错误类型, 发现相比于自回归模型, 非自回归模型在预测目标文字个数(插入错误+删除错误)方面差距较小, 但是替换错误显著的增加, 我们认为这是由于单轮非自回归模型中条件独立假设导致的语义信息丢失. 与此同时, 目前非自回归模型主要停留在学术验证阶段, 还没有工业大数据上的相关实验与结论.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.cn/ebfc82a5079c5a314888de1d439e8a7a.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.cn/ebfc82a5079c5a314888de1d439e8a7a_inverted.webp#only-dark){ loading=lazy width='800' }
</figure>

## 设计

为了解决上述问题, 我们设计了一种具有高识别率与计算效率的单轮非自回归模型Paraformer.

针对第一个问题, 我们采用一个预测器(Predictor)来预测文字个数并通过 Continuous integrate-and-fire (CIF) 机制来抽取文字对应的声学隐变量. 针对第二个问题, 受启发于机器翻译领域中的 Glancing language model(GLM), 我们设计了一个基于 GLM 的 Sampler 模块来增强模型对上下文语义的建模. 除此之外, 我们还设计了一种生成负样本策略来引入 MWER区分性训练.

具体模型结构如下图所示, 由 Encoder, Predictor, Sampler, Decoder 与 Loss function 几部分组成. Encoder 与自回归模型保持一致, 可以为 Self-attention, SAN-M 或者 Conformer 结构. Predictor 为2层 DNN 模型, 预测目标文字个数以及抽取目标文字对应的声学向量. Sampler 为无可学习参数模块, 依据输入的声学向量和目标向量, 生产含有语义的特征向量. Decoder 结构与自回归模型类似, 为双向建模(自回归为单向建模). Loss function 部分, 除了交叉熵(CE)与 MWER 区分性优化目标, 还包括了 Predictor 优化目标 MAE.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.cn/8faed8c82860fa20e64c962ec7e2a0b9.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.cn/8faed8c82860fa20e64c962ec7e2a0b9_inverted.webp#only-dark){ loading=lazy width='800' }
</figure>

其核心点主要有:

* Predictor 模块: 基于 CIF 的 Predictor 来预测语音中目标文字个数以及抽取目标文字对应的声学特征向量
* Sampler: 通过采样, 将声学特征向量与目标文字向量变换成含有语义信息的特征向量, 配合双向的 Decoder 来增强模型对于上下文的建模能力
* 基于负样本采样的 MWER 训练准则

### Predictor模块

Predictor 先给每一帧打"贡献分" $\alpha_t$, 这些分数加起来决定有多少个 token; 再用 CIF 把这些分数沿时间累积, 攒够一个阈值就吐出一个 token 的声学表示.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.cn/2eb3f1bdf548a85571a18d451e152129.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.cn/2eb3f1bdf548a85571a18d451e152129_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>阈值$\beta$被设置为$1$</figcaption>
</figure>
