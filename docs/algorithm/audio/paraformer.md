---
title: Paraformer
comments: false
---

Paraformer是一种快速准确的非自回归语音识别模型, 用于解决传统自回归模型推理速度慢的问题. 传统Transformer模型采用自回归解码器逐个生成token, 计算效率较低. 传统Transformer模型采用自回归解码器逐个生成token, 计算效率低. 现有单步NAR方法虽然能够并行生成, 但是因为假设输出token独立而性能较差, 尤其是在大规模语料上. 单步NAR面临两大挑战, 准确预测输出token数量并提取隐变量; 增强token间依赖建模. Paraformer采用三项技术: _连续集成-触发预测器(CIF)_, _扫视语言模型(GLM)采样器_, _最小词错率(MWER)训练_. 在测试集上面, 达到和SOTA自回归Transformer相当的性能的同时, 推理速度提升超过10倍.
