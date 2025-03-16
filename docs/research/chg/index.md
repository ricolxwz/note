---
title: 对话人脸生成
level: chg
addi: https://share.ricolxwz.io/share/IEek176IiA
---

# 对话人脸生成

## 数据集[^1][^2]

| 数据集               | 年份   | 是否公开 | 交互者                       | 多轮对话 | 风格  | 环境      | 头部动作 | 身体动作 | 其他注释           |
|---------------------|-------|---------|-----------------------------|---------|------|----------|---------|---------|--------------------|
| GRID               | 2006  | ✓       | Speaker                     | ✗       | Lab  | Realistic| ✗       | ✗       | -                  |
| LRW                | 2016  | ✓       | Speaker                     | ✗       | Wild | Realistic| ✗       | ✗       | -                  |
| ObamaSet           | 2017  | ✓       | Speaker                     | ✗       | Wild | Realistic| ✓       | ✓       | -                  |
| VoxCeleb           | 2017  | ✓       | Speaker                     | ✗       | Wild | Realistic| ✓       | ✗       | -                  |
| VoxCeleb2          | 2018  | ✓       | Speaker                     | ✗       | Wild | Realistic| ✓       | ✗       | -                  |
| LRS2-BBC           | 2018  | ✓       | Speaker                     | ✗       | Wild | Realistic| ✓       | ✗       | -                  |
| LRS2-TED           | 2018  | ✓       | Speaker                     | ✗       | Wild | Realistic| ✓       | ✗       | -                  |
| Faceforensics++    | 2019  | ✓       | Speaker                     | ✗       | Wild | Realistic| ✓       | ✗       | -                  |
| MEAD               | 2020  | ✓       | Speaker                     | ✗       | Wild | Realistic| ✓       | ✗       | emotion            |
| Speech2Gesture     | 2019  | ✓       | Presenter                   | ✗       | Wild | Realistic| ✓       | ✓       | -                  |
| Ted Gesture        | 2019  | ✓       | Presenter                   | ✗       | Wild | Realistic| ✓       | ✓       | -                  |
| Gillies et al. | 2008  | ✗       | Speaker, Listener           | ✗       | Lab  | Simulated| ✓       | ✓       | -                  |
| SEMAINE        | 2011  | ✗       | Speaker, Listener           | ✗       | Lab  | Simulated| ✓       | ✗       | custom dimension   |
| Heylen et al.  | 2011  | ✗       | Speaker, Listener           | ✗       | Lab  | Simulated| -       | -       | -                  |
| ALICO          | 2014  | ✗       | Speaker, Listener           | ✗       | Lab  | Realistic| -       | ✓       | feedback signal    |
| [ViCo](/research/chg/vico)               | 2022  | ✓       | Speaker, Listener           | ✗       | Wild | Realistic| ✓       | ✓       | attitude           |
| [ViCo-X](/research/chg/vico-x)             | 2023  | ✓       | Conversational Agent        | ✓       | Lab  | Realistic| -       | -       | dialogue act       |

| Dataset          | Motion | Text | Audio | RGB  | Act. | Emo. | Exp. | Pose | Scn. | Subj. | Dur.  | FPS | Lang. | Repr.       | Env. | Tech.         |
|------------------|:------:|:----:|:-----:|:----:|:----:|:----:|:----:|:----:|:----:|:-----:|:-----:|:---:|:-----:|:-----------:|:----:|:-------------:|
| BIWI         | ✓      | ✓    | -     | -    | -    | -    | L    | -    | -    | 14    | 1.4h  | 25  | EN    | Mesh        | Lab  | 3D            |
| VOCASET      | ✓      | ✓    | ✓     | -    | -    | -    | -    | -    | -    | 12    | 0.5h  | 60  | EN    | Mesh        | Lab  | 3D            |
| MeshTalk     | ✓      | -    | ✓     | -    | -    | -    | -    | -    | -    | 250   | 13h   | 30  | EN    | Mesh        | Lab  | 3D            |
| Multiface    | ✓      | ✓    | ✓     | ✓    | -    | -    | -    | -    | -    | 415   | 30h   | 30  | EN    | Mesh        | Lab  | 3D            |
| MMFace4D     | ✓      | -    | ✓     | -    | L    | -    | -    | -    | -    | 431   | 36h   | 30  | CN    | Mesh        | Lab  | 3D            |
| D3DFACS      | -      | -    | -     | -    | L    | -    | -    | -    | -    | 32    |  -    | 30  |  -    | Mesh        | Lab  | 3D            |
| CoMA         | ✓      | -    | -     | -    | L    | -    | -    | -    | -    | 12    |  -    |  -  |  -    | Mesh        | Lab  | 3D            |
| 4DFAB         | ✓      | -    | -     | -    | L    | -    | -    | -    | -    | 180   |  -    | 60  |  -    | Mesh        | Lab  | 3D            |
| 3D-ETT       | ✓      | -    | -     | -    | L    | -    | -    | -    | -    | 100+  | 6.5h  |  -  | EN    | Blendshape  | Mix  | Mono.         |
| MEAD-3D   | ✓      | -    | ✓     | -    | -    | -    | -    | -    | -    | 60    | 38h   | 30  | EN    | FLAME       | Lab  | Mono.-Gen.    |
| TEAD         | -      | -    | -     | -    | -    | -    | -    | -    | -    |  -    |  -    | 30  | EN    | Blendshape  |  -   |  -            |
| TA-MEAD      | ✓      | ✓    | ✓     | -    | -    | -    | -    | -    | -    |  -    |  -    |  -  | EN    | -           | Lab  |  -            |
| [MMHead](/research/chg/mmhead)           | ✓      | ✓    | ✓     | ✓    | ✓    | ✓    | ✓    | ✓    | ✓    | 2K+   | 49h   | 25  | Mul.  | FLAME       | Mix  | Mono.         |

## 想法

* MMHead: 使用的是交叉注意力融合机制实现的分层次文本和音频的对齐, 目前尚且无法确认这种对齐的实际表现; 作者认为目前尚无公开可用的专门针对文本驱动3D说话人脸动画的方法, 所以仅仅只讲完整的文本特征加入到现有的基于音频驱动的方法中, 用作基准方法, 这种实验设计可能导致比较基线不够合理, 从而在对比中刻意提升自己的性能表现; 缺乏泛化性; 定性评估只和自己比.
* ViCo-X: 它是通过在广泛的多轮对话中不断求解\(\mathcal{M}^{\mathcal{P}}_{N} = G_m(\mathcal{A}, R, E, \mathcal{M}^{\mathcal{Q}}_N, m^{\mathcal{P}}), \quad \mathcal{V}^{\mathcal{P}}_{N} = G_v(\mathcal{M}_N^{\mathcal{P}}, \mathcal{I}^{\mathcal{P}}, v^{\mathcal{P}})\)实现的角色平滑切换, 一个可能改进的点. 一个比较有新意的点是引入了一个$\mathcal{M}^{\mathcal{L}}$到经典的说话人头生成, 称之为expressive talking head generation, 可能可以提高真实感.
* ViCO: 其中的$e$这个系数是固定不变的, 然而, 在真实的对话中, $e$即听者的情感应该是可变的. 对于不同的渲染引擎, 往往只针对一种人脸进行优化, 是一个可以改进的点.

## 问题定义 {#question-definition}

### LHG[^3]

给定一个输入视频序列$\mathcal{V}^s_t=\{v^s_1,...,v^s_t\}$, 该序列对应时间戳范围$\{1,...,t\}$内的说话者头部, 以及说话者对应的音频信号序列$\mathcal{A}^s_t=\{a_1,...,a_t\}$, 倾听头部生成任务的目标是生成下一时刻的听者头部$v^l_{t+1}$: $v^l_{t+1}=G(\mathcal{V}^s_t,\mathcal{A}^s_t,v^l_1,e)$. 其中$v^l_1$是听者的参考头部, $e$表示听者的态度. 整个生成的听者视频$\mathcal{V}^l_{t+1}$可以表示为$\{v^l_2,...,v^l_{t+1}\}$的串接.

在ViCo这项工作中, 作者提取了输入音频的能量特征, 时域特征以及频域特征, 并使用3DMM系数对面部表情和头部姿态进行建模. 对于音频, 作者提取了Mel-frequency cepstral coefficients(MFCC)特征以及相应的MFCC Delta和Delta-Delta特征. 此外, 能量, 响度和零交叉率(ZCR)等也被嵌入到每段音频\(a_i\)对应的音频特征\(s_i\)中. 从\(\mathcal{A}^s_t\)提取的音频特征可记为\(\mathcal{S}^s_t = \{s_1,\dots,s_t\}\). 作者利用最先进的深度学习3D人脸重建模型对视频进行处理, 以获取3DMM系数. 特别地, 对于每张图像, 可以得到重建系数\(\{\alpha,\beta,\delta,p,\gamma\}\), 分别表示身份, 表情, 纹理, 姿态和光照. 此外, 作者将3D重建系数划分为两部分: \(I = (\alpha,\delta, \gamma)\)表示相对固定且依赖身份的特征, 而\(m = (\beta,p)\)表示相对动态且与身份无关的特征. 从说话者视频中提取的与身份无关特征可表示为\(\mathcal{M}^s_t = \{m^s_1,\dots,m^s_t\}\), 其中\(m^s_i \in \mathbb{R}^{1\times C_v}\)为第\(i\)帧\(v^s_i\)对应的3D重建系数中的表情与姿态特征, 且\(C_v = |\beta| + |p|\).

为了忽略与身份相关的特征并学习可适用于多种听者身份的通用听者模式, 作者仅使用头部运动和面部表情特征\(m\)来进行响应式倾听头部生成模型的训练, 然后将不同听者身份的身份依赖特征\(I\)应用于可视化和评估. 因此, 作者的听者头部合成任务可表示为: \(m^l_{t+1} = G_m(\mathcal{M}^s_t, \mathcal{S}^s_t, m^l_1, e), \quad v^l_{t+1} = G_v(m^l_{t+1}, I^l, v^l_1)\). 其中\(m^l_{t+1}\)是为听者头部预测的动态特征, 而\(I^l\)表示给定听者的身份依赖特征. 在实际实现中, 作者会使用\(T\)帧的说话者音频和视频来训练响应式倾听头部生成模型.

3D人脸渲染技术\(G_v\)在近期的许多相关工作中都得到了深入研究. 由于人脸渲染模型往往依赖具体身份, 因此可能需要针对每个身份分别训练渲染模型, 以获得更好的性能. 为了突出交互式数字人合成任务的特性并解耦该任务中的关键因素, 作者提出的响应式倾听头部合成模型主要聚焦于与运动相关且身份无关的3D面部系数预测任务\(G_m\), 并使用预训练的渲染模型进行简化可视化.

### ICHG[^4]

假设存在两个对话者$\mathcal{P}$和$\mathcal{Q}$, 给定对话者$\mathcal{Q}$在N轮对话中的输入video序列$V^\mathcal{Q}_N=\{V^\mathcal{Q}_1,V^\mathcal{Q}_2,...,V^\mathcal{Q}_N\}$, 这两个对话者的audio信号序列$\mathcal{A}=\{A_1,A_2,...,A_N\}$, 说话者(真人)的dialog行为或听者(真人)态度$E=\{e_1,e_2,...,e_N\}$, 以及对话者$\mathcal{P}$的角色指示向量$R=\{r_1,r_2,...,r_N\}$(其中$r_i=1$表示说话者, $r_i=0$表示听者). 在这样的设定下, 对话头部生成任务旨在生成$\mathcal{P}$在这$N$轮对话中的可视化表示, 使其能够在同一个范式中既能倾听又能说话: $V^\mathcal{P}_N=G(\mathcal{A},R,E,\mathcal{V}^\mathcal{Q}_N,v^\mathcal{P})$, 其中$v^\mathcal{P}$表示对话者$\mathcal{P}$的初始(身份)图像. 需要注意的是, $\mathcal{V}_i^{\cdot}$表示该对话者对应的视频片段, 可以进一步细分为$\mathcal{V}_i^{\cdot}=\{V^{\cdot}_{i;1},V^{\cdot}_{i;2},...,V^{\cdot}_{i;|A_i|}\}$, 其中$V^{\cdot}_{i;j}$表示其中的一帧图像(表示第$i$轮对话的第$j$帧, 第$i$轮对话的总帧数为$|A_i|$).

(基本和ViCo一样). 在ViCo-X这项工作中, 作者提取了输入音频的能量特征, 时域特征以及频域特征, 并使用3DMM系数来建模面部表情和头部姿态. 对于音频, 作者提取了Mel-frequency cepstral coefficients(MFCC)特征以及相应的MFCC Delta和Delta-Delta特征. 此外, 作者还将能量, 响度和过零率(Zero-Crossing Rate,ZCR)嵌入到音频特征中, 记为$S_i$, 对应每个音频片段$A_i$. 从A中提取的音频特征可表示为$\mathcal{S} = {S_1, S_2, …, S_t}$. 在3D人脸重建领域已经有大量研究. 在这里, 作者利用最先进的基于深度学习的人脸重建模型来获取3DMM系数, 并据此驱动头部运动和表情变化. 具体而言, 对于任意人脸图像, 可以得到重建系数\(\{\alpha,\beta,\delta,p,\gamma\}\), 分别表示身份, 表情, 纹理, 姿态和光照. 此外, 作者将3D重建系数划分为两部分: \(I = (\alpha,\delta, \gamma)\)表示相对固定且依赖身份的特征, 而\(m = (\beta,p)\)表示相对动态且与身份无关的特征. 在完成面部参数化之后, 可以通过$m$调整动作和表情变化, 并通过$\mathcal{I}$修改身份.

鉴于身份相关特征($\mathcal{I}$)与对话者运动模式之间的相关性较弱, 本研究仅使用头部运动和面部表情特征$m$进行对话式人头生成模型的训练, 并在可视化和评估阶段再结合不同对话者身份的I. 由此, 所提出的交互式对话人头合成任务可以表述为: \(\mathcal{M}^{\mathcal{P}}_{N} = G_m(\mathcal{A}, R, E, \mathcal{M}^{\mathcal{Q}}_N, m^{\mathcal{P}}), \quad \mathcal{V}^{\mathcal{P}}_{N} = G_v(\mathcal{M}_N^{\mathcal{P}}, \mathcal{I}^{\mathcal{P}}, v^{\mathcal{P}})\). 其中$\mathcal{M}^{\cdot}_i$表示针对第i轮对话者预测得到的动态特征. 在这里,$G_m$将推断$\mathcal{P}$的3DMM系数,而$G_v$则将这些系数渲染为视频. 为了更好地建模$G_m$, 作者将其拆分为与$R$对应的表情化说话人头部建模和响应式倾听人头部建模, 然后将二者结合起来组成完整的对话人头.

首先考虑一个更简单的子问题, 即单轮对话. 目标是基于说话者的音频$A$, 行为$\mathcal{M}^{\mathcal{S}}$以及当前对话行为$e$来生成一个倾听者: $\mathcal{M}^{\mathcal{L}}=G_{m}^{\mathcal{L}}(A, e, \mathcal{M}^{\mathcal{S}}, m^{\mathcal{L}})$. 其中$\mathcal{S}$和$\mathcal{L}$分别表示说话者与倾听者; 或者基于音频$A$, 对话行为或态度$e$以及倾听者的行为$\mathcal{M}^{\mathcal{L}}$来生成说话者: $\mathcal{M}^{\mathcal{S}}=G_{m}^{\mathcal{S}}(A, e, \mathcal{M}^{\mathcal{L}}, m^{\mathcal{S}})$. 对于前一种任务, 作者提出了一个用于响应式倾听人头生成的框架, 旨在弥补倾听者建模的空白. 对于后一种任务, 作者将倾听者行为$\mathcal{M}^L$加入到经典的说话人头生成中, 称之为表情化说话人头生成, 以便说话者能够更好地与倾听者沟通.

为了在多轮(N-round)对话的生成过程中保证对话双方角色的平滑切换,我们在更广泛的对话上下文中继续求解方程\(\mathcal{M}^{\mathcal{P}}_{N} = G_m(\mathcal{A}, R, E, \mathcal{M}^{\mathcal{Q}}_N, m^{\mathcal{P}}), \quad \mathcal{V}^{\mathcal{P}}_{N} = G_v(\mathcal{M}_N^{\mathcal{P}}, \mathcal{I}^{\mathcal{P}}, v^{\mathcal{P}})\),从而对代理($\mathcal{P}$)进行建模.

3D人脸渲染技术$G_v$在许多近期工作中已得到深入研究. 此外, 面部渲染模型通常是身份特定的, 因此可能需要为每个身份分别训练以获得更好的性能. 为了突出对话人头合成任务的特性并解耦关键因素, 所提出的模型主要聚焦于与运动相关且与身份无关的3D面部系数预测任务$G_m$, 同时使用预训练的渲染模型$G_v$来简化可视化过程. 一些视频后期处理方法(例如视频帧插值, 去噪, 超分辨率和图像修复等)也可以用于增强视觉效果.

[^1]: Zhou, M., Bai, Y., Zhang, W., Yao, T., & Zhao, T. (2023). Interactive conversational head generation (No. arXiv:2307.02090). arXiv. https://doi.org/10.48550/arXiv.2307.02090
[^2]: Wu, S., Li, Y., Yan, Y., Duan, H., Liu, Z., & Zhai, G. (2024). MMHead: Towards fine-grained multi-modal 3D facial animation (No. arXiv:2410.07757). arXiv. https://doi.org/10.48550/arXiv.2410.07757
[^3]: Zhou, M., Bai, Y., Zhang, W., Yao, T., Zhao, T., & Mei, T. (2022). Responsive listening head generation: A benchmark dataset and baseline (No. arXiv:2112.13548). arXiv. https://doi.org/10.48550/arXiv.2112.13548
[^4]: Zhou, M., Bai, Y., Zhang, W., Yao, T., & Zhao, T. (2023). Interactive conversational head generation (No. arXiv:2307.02090). arXiv. https://doi.org/10.48550/arXiv.2307.02090
