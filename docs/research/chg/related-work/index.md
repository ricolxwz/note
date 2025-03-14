---
title: 相关工作
level: chg
---

# 相关工作

## 分类结构

由于我们的方法主要有三个侧重点: 一个是能够建模整个对话, 不同于以往研究基于单方面建模; 二是它是基于LLM的, 拥有推理能力, 和目前的特征映射不一样; 三是它是一个多模态模型, 能够对分层次之后的输入产生一个更加全面的理解. 分类结构可以表示为:

* Single Sided
    * THG
        * Non-LLM Based
            * Audio conditioned: MakeItTalk, VASA-1, EMO, V-Express, Diffusion Heads
            * Multi-modal conditioned: Wav2Lip, PC-AVS, EchoMimic, AniTalker
    * LHG
        * Non-LLM Based
            * Text conditioned
            * Audio conditioned: PCH
            * Video conditioned
            * Multi-modal conditioned: RLHG, L2L, ELP, MFR-NET
        * LLM Based
            * Retrival-base
                * Text conditioned: RealTalk
            * Generative-based
                * Text conditioned: CLMLtL
                * Audio conditioned
                * Video conditioned
                * Multi-modal conditioned: CustomListener
* Dyadic
    * LLM Based
        * Text conditioned
        * Audio conditioned
        * Video conditioned
        * Multi-modal conditioned
    * Non-LLM Based
        * Text conditioned
        * Audio conditioned
        * Video conditioned
        * Multi-modal conditioned

### 假设

* 输入不考虑reference这种image模态