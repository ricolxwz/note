---
title: 相关工作
level: chg
---

# 相关工作

## 分类结构

由于我们的方法主要有三个侧重点: 一个是能够建模整个对话, 不同于以往研究基于单方面建模; 二是它是基于LLM的, 拥有推理能力, 和目前的特征映射不一样; 三是它是一个多模态模型, 能够对分层次之后的输入产生一个更加全面的理解. 分类结构可以表示为:

* Conversational Head Generation
    * Single Sided Conversation
        * Talking Head Generation
            * Non-LLM Based
                * Audio driven: Wav2Lip
                * Multi-modal driven: 
                * Video driven: Face2Face, FOMM
        * Listening Head Generation
            * Non-LLM Based
                * Text driven
                * Audio driven: PCH
                * Video driven
                * Multi-modal driven: RLHG, L2L, ELP, MFR-NET, SaRLHS, ViCo
            * LLM Based
                * Retrival-base
                    * Text driven: RealTalk
                * Generative-based
                    * Text driven: CLMLtL
                    * Audio driven
                    * Video driven
                    * Multi-modal driven: CustomListener
    * Dyadic Conversation
        * LLM Based
            * Text driven
            * Audio driven
            * Video driven
            * Multi-modal driven: AgentAvatar
        * Non-LLM Based
            * Text driven
            * Audio driven: INFP
            * Video driven
            * Multi-modal driven: ViCo-X, DIM, DialogueNeRF
* Wholistic Motion Generation
    * LLM Based
        * Text driven: 
        * Multi-modal driven: AvatarGPT
    * Non-LLM Based
        * Text driven: MotionCLIP, TEMOS, GDN2HMT, MDM

### 假设

* 输入不考虑reference这种image模态
