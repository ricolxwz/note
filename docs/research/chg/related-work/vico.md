---
title: ViCo
# level: chg
---

# ViCo[^1]

## 摘要

作者提出了一项新的倾听者头部生成基准, 用于在面对面交流中合成听者的响应性反馈(例如点头, 微笑). 作为对说话者头部生成的不可或缺补充, 倾听者头部生成在文献中很少被研究. 自动合成能够主动响应说话者头部的倾听行为, 对数字人,虚拟代理和社交机器人等应用至关重要.

在这项工作中, 作者提出了一个名为 "ViCo" 的全新数据集, 着重于面对面交谈中的倾听者头部生成. ViCo 中包含 92 个身份(67 位说话者和 76 位听者), 提供了 483 个配对的 "说话-倾听" 片段, 其中听者根据其态度(积极,中立,消极)展示三种不同的倾听风格. 不同于传统的语音到手势或说话者头部生成, 倾听者头部生成同时接收来自说话者的音频和视觉信号作为输入, 并以实时方式给出非语言反馈(例如头部动作, 面部表情).

该数据集支持多种应用, 如人际互动, 视频到视频翻译, 跨模态理解与生成. 为了促进进一步研究, 作者还发布了一个可根据不同倾听态度进行生成的倾听者头部生成基线. 代码和 ViCo 数据集请访问: https://project.mhzhou.com/vico.

## 图片

<figure markdown='1' id='fig1'>
![](https://img.ricolxwz.io/c50d18bd946e9d230b40c90765e2bce8.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/c50d18bd946e9d230b40c90765e2bce8_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图1: 下图展示了三个相关任务以及作者提出的响应式倾听者头部生成.  (a) 语音到手势转换: 生成与给定语音相匹配的合理手势.  (b) 语音到唇部生成: 在说话者头部视频中实现唇部同步.  (c) 说话者头部生成: 在给定说话者身份,语音音频和/或说话者情感的条件下, 合成说话者面部视频.  (d) 作者提出的响应式倾听者头部生成: 根据说话者的视频流来生成倾听者视频.</figcaption>
</figure>

<figure markdown='1' id='fig2'>
![](https://img.ricolxwz.io/7bd8d98cc3461ee909fa7010f90a6e83.webp#only-light){ loading=lazy width='500' }
![](https://img.ricolxwz.io/7bd8d98cc3461ee909fa7010f90a6e83_inverted.webp#only-dark){ loading=lazy width='500' }
<figcaption>图2: 在交谈中, 倾听者的不同态度可能会展现出不同的姿势和表情模式.</figcaption>
</figure>

<figure markdown='1' id='fig3'>
![](https://img.ricolxwz.io/a084caf0c9eb4e31e640c4091fb9219e.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/a084caf0c9eb4e31e640c4091fb9219e_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图3: 在 ViCo 中, 合格的视频片段是根据以下标准进行筛选的: 1) 说话者和听者的行为都清晰可见, 2) 听者能够对对话做出相应的反馈. 此后, 为了构建作者的 ViCo 数据集(见右图), 会进一步裁剪听者-说话者配对的面部区域.</figcaption>
</figure>

<figure markdown='1' id='fig4'>
![](https://img.ricolxwz.io/0486b32f4d9c6af29e50006ea777c727.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/0486b32f4d9c6af29e50006ea777c727_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图4: 作者的响应式倾听者头部生成基线的整体流程. 说话者编码器负责对头部运动,面部表情和音频特征进行编码. 在参考听者图像的融合特征基础上, 听者解码器按照时间顺序接收来自说话者编码器的信号, 并预测头部运动与面部表情特征. 这些特征会与参考听者的身份相关特征相结合, 用于重建 3DMM 系数, 然后输入神经渲染器以生成逼真的倾听者视频.</figcaption>
</figure>

## 结论

在本文中, 作者定义了响应式倾听者头部生成任务, 其目标是基于对说话者面部信号和语音的理解, 为倾听者生成一个响应性视频片段. 同时, 作者还提供了高质量的响应式倾听者数据集 (ViCo) 来解决这一问题. 作者的响应式倾听者生成基线可以合成更符合人类感知的积极倾听者. 他们希望 ViCo 能够推动计算机视觉领域在面对面交流建模方面的发展, 并为更多场景(例如智能辅助,虚拟人等)的应用提供助力.

## 动机

Face-to-face communication是人类日常生活中最常见的交互活动之一, 在这一过程中, 说话人与倾听者通常会轮流扮演不同的角色, 并通过言语和非言语反馈实现信息的有效传递. 已有研究表明, **倾听不仅表现为简单的身体动作或预先设定的动画, 更是高度依赖语境和个体态度的功能性行为**, 其模式可由训练数据中学习到的规律加以推断. 例如, 倾听者在对话中会通过点头,微笑或眼神交流等动作传达理解,兴趣或赞同, 并与说话者的语音节奏或面部表情相协调, 这使得倾听在面对面的沟通中具有不可或缺的作用. 

尽管此前有不少工作聚焦于speaker-centric任务, 例如speech to gesture generation,speech to lip generation以及talking-head synthesis等, **然而这些研究往往只关注说话者的角色, 相对忽视了与其对话的倾听者**. 实际上, 在面对面沟通中, 倾听者的实时反馈对于促进信息交流和提高互动效率尤为关键, 一旦缺少恰当的回应, 交流的顺畅度和有效性都会显著降低. 为解决这一问题, 本研究强调了listening-head generation的重要性, 旨在根据说话者视频及倾听者身份信息生成逼真且具有互动感的倾听者头部动作及表情, 使系统能够自动为不同场景提供自然的人机或人机代理交互. 

为支持listening-head generation任务, 本研究构建了ViCo dataset. 该数据集涵盖了高分辨率拍摄的双人对话场景, 对其中的倾听者表情和动作进行了精细注释, 并划分为积极,中立和消极三种态度. ViCo共包含483段视频, 涵盖76位倾听者和67位说话者, **保证了人物身份与对应对话片段的一致性和丰富度**. 与只关注说话者的MEAD或VoxCeleb2等数据集相比, ViCo更突出了倾听者在互动过程中的多样化反应. 相比于SEMAINE或MAHNOB Laughter等对特殊场景或特定刺激做出的反应, ViCo**注重捕捉真实人际交流中的自然反馈, 因此具有更高的生态有效性与适用价值**. 

在此基础上, 本研究提出了一个listening-head generation baseline方法. 不同于以往针对说话者的独立建模思路, 该方法将倾听行为与说话者视频相结合, 并通过解耦倾听者身份特征来集中学习可推广的交互式运动模式. 具体而言, 该方法将该任务视作video-to-video translation问题, 采用序列到序列的网络结构解码倾听者头部运动和表情, 以捕捉说话者视频中的关键时刻并做出合适的动态响应. 定量评估和用户研究均表明, 该baseline不仅能够自动捕捉对话关键点, 还能生成表情自然,动作清晰的倾听者动画, 展示了在虚拟主播,数字化身,客户服务以及元宇宙等众多交互应用场景中的潜在价值. 

## 创新

1. **提出新的Listener-Centric任务**  

    该工作首次聚焦于face-to-face场景中的listener角色, 引入了Listening-Head Generation的概念, 区别于以往仅关注speaker的研究, 明确强调了生成听者反馈在实际交互中的关键地位.

2. **构建高质量ViCo数据集**  

    研究团队采集并清洗了包含两人对话的高分辨率视频数据, 明确标注了listener的不同态度(positive, neutral, negative). 相较于仅包含单向说话者数据或有限人工交互场景的数据集, ViCo更加真实地体现了人际交流中的动态反应, 并为后续模型学习提供了丰富多样的监听行为样本.

3. **全新序列到序列基线方法**  

    在方法设计上, 研究者将Listening-Head Generation视为video-to-video翻译任务, 采用序列到序列结构逐帧解码listener的头部运动与表情. 该方法能够显式分离listener的身份特征与通用的响应模式, 专注于捕捉并生成与speaker视频相协调的听者动态行为.

4. **突出对实时交互与应用的价值**  

    通过定量评估和用户研究, 该方法能够自动检测并响应speaker视频中的关键时刻, 生成自然,连贯的听者反馈. 在虚拟主播,数字化客服以及元宇宙互动等领域, 该Listening-Head Generation技术有望显著提升交互体验, 使人机或人物之间的交流更加真实生动.

[^1]: Zhou, M., Bai, Y., Zhang, W., Yao, T., Zhao, T., & Mei, T. (2022). Responsive listening head generation: A benchmark dataset and baseline (No. arXiv:2112.13548). arXiv. https://doi.org/10.48550/arXiv.2112.13548
