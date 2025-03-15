---
title: EmoTalkingGaussian
# level: chg
---

# EmoTalkingGaussian[^1]

## 概要

基于3D Gaussian splatting的说话人头合成最近因其能够以实时推理速度渲染高保真图像而受到关注. 然而, 由于其通常只在一段缺乏面部情感多样性的视频上进行训练, 所生成的说话人头在表现广泛情感方面存在困难. 为了解决这一问题, 作者提出了一个对齐嘴唇的情感人脸生成器, 并利用它来训练作者的 EmoTalkingGaussian 模型. 该模型能够根据连续情感值(即 valence 和 arousal)来操控面部情感, 同时保持嘴唇运动与输入音频的同步. 此外, 为了在真实环境音频中实现精确的嘴唇同步, 作者引入了一种自监督学习方法, 利用了文本转语音网络和视觉-音频同步网络. 作者在公开可用的视频上对 EmoTalkingGaussian 进行了实验, 并在图像质量(通过 PSNR,SSIM,LPIPS 测量),情感表达(通过 V-RMSE,A-RMSE,V-SA,A-SA,Emotion Accuracy 测量)以及嘴唇同步(通过 LMD,Sync-E,Sync-C 测量)方面, 均获得了优于现有方法的结果.

## 图片

<figure markdown='1' id="fig1">
![](https://img.ricolxwz.io/1ac2a99c19d6441bffe05cbd84a1676f.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/1ac2a99c19d6441bffe05cbd84a1676f_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图1: 最先进的3D人脸说话合成方法, TalkingGaussian, 基于动作单元来操纵表情; 然而, 它在表达多样化情绪方面的能力有限, 并且在表示情绪源图像中从未见过的情感表情时, 图像质量会变得较差. 作者的方法可以基于动作单元以及valence/arousal来反映多样化的表情和情绪, 并能渲染与输入音频 (/ni/ 和 mute) 保持良好唇形对齐的说话人脸, 如左图所示. 右图展示了作者的方法通过调整valence/arousal来传达连续情绪的能力, 同时保持嘴唇与音频的同步. 说话者正在发音的单词 "nice" 中的 "ce" 部分以红色突出显示.</figcaption>
</figure>

<figure markdown='1' id='fig2'>
![](https://img.ricolxwz.io/273172e6b025d244db4f647da128dbb4.webp#only-light){ loading=lazy width='400' }
![](https://img.ricolxwz.io/273172e6b025d244db4f647da128dbb4_inverted.webp#only-dark){ loading=lazy width='400' }
<figcaption>图2: (a) 显示了源图像, (b) 和 (c) 分别表示由 EmoStyle 与作者的唇形对齐情感人脸生成器所生成的 "happy&surprise" 情绪 (正性为0.8, 唤醒度为0.6) 的图像.</figcaption>
</figure>

<figure markdown='1' id='fig3'>
![](https://img.ricolxwz.io/e68b1ffa6c09fbf8e28d335b32168095.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/e68b1ffa6c09fbf8e28d335b32168095_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图3: EmoTalkingGaussian 的概述: 作者的 EmoTalkingGaussian 由三个分支组成. 首先, inside-mouth 分支根据音频特征 a 来估计 3D 高斯的位置偏移. 其次, face 分支根据音频特征 a 和动作单元 u 来估计位置,缩放因子以及四元数的偏移. 作者的 inside-mouth 分支与 face 分支继承自 TalkingGaussian, 并用虚线矩形表示. 最后, 第三个分支——emotion 分支, 根据情感输入 e (valence/arousal) 来估计位置,缩放因子以及四元数的偏移. 作者先沿着黑色箭头渲染嘴部区域与人脸区域 $\bar{I}$, 然后沿着黄色箭头渲染嘴部区域与情感人脸区域 $\bar{I}^E$. 作者应用 RGB 损失与法线损失, 并结合音频及唇形同步损失, 以提升视觉逼真度与整体对齐度.</figcaption>
</figure>

## 结论

该论文介绍了一种新颖的三维情感说话人头生成框架EmoTalkingGaussian. 该框架能够无缝地利用包含高稀疏度情感表达的新主体视频, 而无需额外的数据采集. 得益于与嘴唇对齐的情感人脸图像生成器,法线贴图损失,同步损失以及精心挑选的语音数据, 该方法能够基于效价和唤醒度进行多样化的情感操控, 并在保证高图像质量的同时使渲染图像中的嘴唇运动与输入音频同步.

???+ note "稀疏情感表达"

    稀疏情感表达指的是在视频数据中, 情感状态或情感特征的出现非常零散, 不连续, 即在大部分帧中情感变化较小或不明显, 而只有少数帧显示出明显的情感特征. 

## 缺陷

根据所表达的情感不同, 合成图像中的口部有时会发生剧烈变化, 导致EmoTalkingGaussian生成的图像在嘴部区域出现伪影. 这表明在图像保真度与情感表达强度之间存在一种取舍.

## 动机

3D Gaussian splatting (3DGS)技术近年来在三维可视化领域中迅速崛起, 成为与NeRF技术并驾齐驱的高效渲染方案, 同时也在说话人头像合成(talking head synthesis)方向展现出卓越的实时渲染能力与画面质量. 随着3DGS的出现, 原本广泛应用的NeRF方法正逐渐被3DGS方法取代, 主要得益于其更快的推理速度和更高的保真度. **然而, 现有的3DGS说话人头像合成模型大多仅能表现基本的面部动作, 如眨眼和眉毛微动等, 对于如快乐,悲伤或生气等连续且多样的情感表达仍显不足**. 人类在交谈时往往会呈现丰富的情感变化, 使得合成模型若无法体现多种情绪便难以打造真正栩栩如生的说话人头像. 同时, 为了获得更逼真的情感效果, 现有工作若需要为新说话人进行训练, 往往依赖额外的数据采集, 这在成本和效率上都存在明显限制.

???+ note "3DGS和NeRF"

    3DGS和NeRF在训练阶段可以被视为一种3D重建过程, 在推理阶段, 可以被视为一种渲染过程. 在传统的3D重建中, 我们通常会得到一个显式的mesh或者点云, 而3DGS和NeRF能够得到对三位场景的隐式或者半隐式表示: 3DGS通过在空间中放置一些列带有权重和属性的高斯核, 来近似三维结构和外观; NeRF则是通过神经网络学习体渲染方程, 在三维坐标和视角方向的输入下, 输出颜色和密度, 然后利用体渲染得到新的视图.

基于以上问题, 本研究提出了EmoTalkingGaussian, 一种将连续情感表达融入3D Gaussian splatting-based说话人头像生成的新方法. 为了能够灵活地控制面部情感, EmoTalkingGaussian采用valence与arousal作为情绪的条件输入, 分别用来表示情绪的正负程度和激昂程度, 范围均为-1至1. **相较于只能捕捉基础表情(如眨眼等)的action units, 使用valence与arousal可在真实感合成中实现更连续,多样的情感呈现, 例如快乐,惊讶以及悲伤等.** 然而, **仅依赖情感风格迁移方法(如EmoStyle)生成的数据来训练EmoTalkingGaussian时, 由于这类方法并不关注语音与嘴型的一致性, 常常导致语音驱动下的说话人模型出现嘴型与音频不同步的现象**. 为解决这一问题, 本研究设计了lip-aligned emotional face generator, 在保持目标图像情感表达的同时尽量保证与语音的唇部对齐, 从而减少口型与语音之间的偏差.

在此基础上, 为了进一步缩小真实图像与生成图像之间的域差异, 本研究引入基于法线贴图的损失函数, **利用法线信息来保证人脸细节的合理性**. 此外, 为增强模型在野外音频中的唇部同步效果, 通过一个text-to-speech network生成了小规模但含有丰富发音多样性的英文语音数据, 并利用SyncNet在自监督框架下加入同步损失, 推动EmoTalkingGaussian在不同音频驱动条件下都能实现更出色的说话人与唇部同步.

???+ note "法线贴图"

    法线是描述表面局部方向的重要信息, 在光照计算中, 光照效果取决于光线方向与表面法线之间的夹角. 有了法线数据, 我们可以准确计算出每个像素的光照强度, 进而模拟出表面的高光、阴影和细微纹理, 即使模型本身的几何结构很简单. 法线贴图正是利用这一原理, 在不增加多边形数量的情况下, 通过调整光照计算中的法线方向, 模拟出凹凸和划痕等细节, 从而显著提升图像的真实感和细腻度.

    贴图 (Texture Mapping) 是将二维图像应用于三维模型表面的技术, 例如在一个立方体上贴上一张木纹图片, 使得立方体看起来像真实的木头表面. 法线贴图 (Normal Map) 是一种特殊的贴图, 它不存储颜色信息, 而是记录每个像素处的法线向量, 用以模拟物体表面的凹凸细节. 举个例子, 假设你有一个平面, 你可以给它贴一张普通纹理贴图显示砖墙的颜色和纹理, 同时再贴一张法线贴图, 让光照计算时模拟出砖墙的凸起和凹陷效果, 从而让平面在视觉上看起来具有真实的凹凸结构, 虽然实际几何形状没有变化.

## 创新

1. 提出了一种基于3D Gaussian splatting的情感化说话人头像生成框架EmoTalkingGaussian, **通过引入valence和arousal两个连续变量实现多样化的情感表情渲染**, 无需为新用户额外采集数据.  
2. 设计了**唇形对齐**的情感人脸生成器, 用于在数据增强过程中同时保留语音与唇形的一致性, 并有效地表达目标的情感强度, 从而克服现有方法中音画不匹配的问题.  
3. 借助基于**normal map的损失函数来缓解真实图像与合成图像之间的域差异**, 在训练过程中提升模型对多样情感表情的泛化能力.  
4. 利用**小规模但具备丰富发音多样性的语音数据集**(由文本转语音网络生成)进行自监督学习, 并引入lip-audio同步损失来强化唇部运动与输入语音的对应关系, 有效提升模型的时序一致性.  

[^1]: Cha, J., Yoon, S., Strizhkova, V., Bremond, F., & Baek, S. (2025). EmoTalkingGaussian: Continuous emotion-conditioned talking head synthesis (No. arXiv:2502.00654; 版 1). arXiv. https://doi.org/10.48550/arXiv.2502.00654
