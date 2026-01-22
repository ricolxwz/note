---
title: Conformer
comments: false
---

Conformer是Google在2020年提出的语音识别模型, 基于Transformer改进而来, 主要的改进点在于Transformer在提取长序列依赖的时候更加有效, 而卷积则擅长提取局部特征, 因此将卷积应用于Transfromer的Encoder层, 同事提升模型在长期序列和局部特征上的效果. 实验证明, 该方法确实有效, 在当时的LibriSpeech测试机上取得了SOTA效果. 
