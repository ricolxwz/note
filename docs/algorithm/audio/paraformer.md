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
