---
title: RQ-VAE (2022)
comments: false
addi: https://arxiv.org/pdf/2203.01941
---

# RQ-VAE[^1]

## 摘要

针对高分辨率图像的自回归(AR)建模, 向量量化(VQ)通常将图像表示为离散码序列. 较短的序列长度对于AR模型至关重要, 因为这能在建模代码间长程交互时显著降低计算成本. 然而, 作者指出, 在码率–失真权衡(rate-distortion trade-off)意义下, 现有VQ方法难以同时缩短代码序列并保持高保真度图像. 为此, 作者提出了由Residual-Quantized VAE(RQ-VAE)和RQ-Transformer组成的两阶段框架, 以高效生成高分辨率图像. 在固定码本大小的条件下, RQ-VAE能够精确逼近图像特征图, 并将图像表示为离散码的堆叠图. 随后, RQ-Transformer通过预测下一堆栈的代码来学习下一个位置的量化特征向量. 依托RQ-VAE的高精度逼近, 作者可将一张256×256图像压缩为8×8分辨率的特征图, 从而大幅降低RQ-Transformer的计算开销. 实验结果表明, 该框架在无条件与条件图像生成的多个基准上均优于现有AR模型, 并且在生成高质量图像时的采样速度明显快于之前的AR方法.

## 介绍

<figure markdown='1' id='fig1'>
![](https://img.ricolxwz.io/25e4f8ab2eccb9ff9a3b7157b7f2f74c.webp#only-light){ loading=lazy width='600' }
![](https://img.ricolxwz.io/25e4f8ab2eccb9ff9a3b7157b7f2f74c_inverted.webp#only-dark){ loading=lazy width='600' }
<figcaption>图1: 256×256图像条件生成示例. 第一行图像根据ImageNet类别进行生成. 第二行图像基于文本条件生成, 分别为"A cheeseburger in front of a mountain range covered with snow."与"a cherry blossom tree on the blue ocean"; 这些文本条件在训练阶段未出现.</figcaption>
</figure>

向量量化(VQ)已成为自回归(AR)模型生成高分辨率图像的基础技术. 具体而言, 先对图像的特征图(feature map)进行VQ量化, 并按光栅扫描(raster scan)等顺序重新排列, 将图像表示为一系列离散编码. 量化完成后, 训练AR模型按序逐步预测这些编码. 换言之, AR模型能够在不逐像素预测的情况下生成高分辨率图像.

作者提出, 在图像AR建模中缩短离散码序列长度至关重要. 较短的码序列能显著降低AR模型的计算开销, 因为模型在预测下一个码时需要利用前序位置的码. 然而, 现有研究受制于码率–失真(rate-distortion)折衷, 难以进一步缩短图像的序列长度. 具体而言, 若要在保持重建图像质量的同时降低量化特征图分辨率, VQ-VAE必须使用规模呈指数级增长的码本(codebook). 过大的码本不仅增加模型参数量, 还会引发码本坍缩(codebook collapse)问题, 从而导致VQ-VAE训练过程不稳定.

本文提出残差量化VAE(RQ-VAE), 采用残差量化(RQ)对特征图进行精确逼近并降低其空间分辨率. 不同于扩大码本规模的方法, **RQ在固定码本大小的前提下, 以由粗到细的递归方式量化特征图**. 经过$D$次残差量化后, 特征图被表示为由$D$个离散编码堆叠而成的映射. 由于RQ能够组合出$|C|^D$个向量(其中$|C|$为码本大小), RQ-VAE无需庞大码本即可精确逼近特征图, 同时保留编码图像的信息. 得益于这种高精度逼近, RQ-VAE能够将量化特征图的空间分辨率进一步降低, 优于先前研究. 例如, 在256×256图像的AR建模中, RQ-VAE仅需8×8分辨率的特征图.

> 量化为$D$个特征图, 但是码本用的都是同一个码本$C$.

此外, 作者提出RQ-Transformer用于预测RQ-VAE提取的编码. 在RQ-Transformer的输入端, RQ-VAE量化后的特征图被转换为一序列特征向量, 随后RQ-Transformer预测接下来$D$个编码, 以估计下一位置的特征向量. 得益于RQ-VAE降低的特征图分辨率, RQ-Transformer显著减少了计算开销, 并能够轻松学习输入之间的长程依赖. 作者还针对RQ-Transformer提出两项训练技术: soft labeling(软标签)和stochastic sampling(随机采样), 通过缓解自回归模型训练中的exposure bias(曝光偏置)进一步提升性能. 因此, 如[图1](#fig1)所示, 该模型能够生成高质量图像.

主要贡献总结如下:

1. 作者提出残差量化变分自编码器(RQ-VAE), 该方法将图像表示为离散编码的堆叠映射, 同时生成高保真重建图像.
2. 作者提出RQ-Transformer及其两项训练策略——软标签(soft labeling)与随机采样(stochastic sampling), 用于精准预测RQ-VAE的编码并缓解exposure bias(训练阶段与推断阶段分布不一致的问题).
3. 实验结果表明, 相比现有自回归模型, 所提出方法在生成图像质量, 计算成本及采样速度方面均取得显著提升.

## 方法

本文提出包含RQ-VAE与RQ-Transformer的两阶段框架, 用于图像的AR建模(见[图2](#fig2)). RQ-VAE利用码本将图像表示为$D$个离散编码的堆叠映射. 随后, RQ-Transformer以自回归方式预测下一空间位置的$D$个编码. 此外, 作者阐述了RQ-Transformer在AR模型训练中如何缓解曝光偏置(exposure bias)的问题.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/18c69acd3a64e43d09ada8199b5cd210.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/18c69acd3a64e43d09ada8199b5cd210_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图2: 本文提出的两阶段图像生成框架概述如下: 框架由RQ-VAE和RQ-Transformer组成. 在第一阶段, RQ-VAE利用残差量化器将图像表示为$D=4$个离散编码的堆叠. 当该编码堆叠映射被reshape后, RQ-Transformer预测下一空间位置的$D$个编码.</figcaption>
</figure>

### 残差量化VAE

在本节中, 作者首先介绍向量量化(VQ)及VQVAE的数学表述; 随后提出RQ-VAE, 该方法在不扩增码本规模的前提下能够精确逼近特征图, 并阐释RQ-VAE如何将图像表示为离散编码堆叠而成的映射.

#### VQ-VAE简介

设码本$C$为有限集合$\{(k, e(k))\}_{k\in[K]}$, 其中$k$表示离散码, $e(k)\in\mathbb{R}^{n_z}$为其对应的码嵌入, $K$为码本规模, $n_z$为嵌入维度. 给定向量$z\in\mathbb{R}^{n_z}$, 向量量化(记作$Q(z; C)$)返回与$z$最接近的码, 其定义如下:

$$
Q(z; C)=\arg\min_{k\in[K]} \lVert z-e(k)\rVert_2^2
$$

在VQ-VAE将图像编码为离散码图之后, VQ-VAE会利用该编码码图重建原始图像. 设$E$和$G$分别为VQ-VAE的编码器与解码器. 给定输入图像$X\in\mathbb{R}^{H_o\times W_o\times3}$, VQ-VAE首先提取特征图$Z=E(X)\in\mathbb{R}^{H\times W\times n_z}$. 其中$(H, W)=(H_o/f, W_o/f)$表示$Z$的空间分辨率, $f$为下采样因子. 接着, 对$Z$中每一位置的特征向量施加向量量化, VQ-VAE得到码图$M\in[K]^{H\times W}$以及其量化特征图$\hat{Z}\in\mathbb{R}^{H\times W\times n_z}$, 具体为

$$
M_{hw}=Q(Z_{hw};C), \qquad\hat{Z}_{hw}=e(M_{hw})
$$

$Z_{hw}\in\mathbb{R}^{n_z}$是位置$(h,w)$处的特征向量, $M_{hw}$为其编码. 最后, 输入被重建为$\hat{X}=G(\hat{Z})$.

作者指出, 降低$\hat{Z}$的空间分辨率$(H, W)$对于AR模型至关重要, 因为AR模型的计算成本随$HW$增加. 然而, 由于VQ-VAE对图像执行有损压缩, 在减少$(H, W)$并同时保留$X$信息之间存在权衡. 具体而言, 当码本规模为$K$时, VQ-VAE使用$HW\log_2 K$位将图像表示为编码. 根据率-失真理论, 可达到的最优重建误差取决于比特数. 因此, 若要将$(H, W)$进一步减半至$(H/2, W/2)$且仍保持重建质量, VQ-VAE需要大小为$K^4$的码本. 然而, 过大的码本会导致VQ-VAE训练不稳定并出现codebook collapse问题, 因而效率低下.

#### 残差量化

他们没有增加码本的大小, 而是采用残差量化(RQ)对向量$z$进行离散化. 给定量化深度$D$, RQ将$z$表示为有序的$D$个编码. 令$C$是大小为$|C|=K$的码本(codebook), $k_d$表示深度$d$时$z$的编码(code):

$$
RQ(z;C,D)=(k_{1},\dots,k_{D})\in [K]^{D}
$$

 从$0$阶残差$r_0=z$开始, 残差量化(RQ)递归地计算$k_d$, 并将编码$k_d$映射为码向量$e(k_d)$(code embedding), 随后计算下一阶残差$r_d$:

$$
k_d = Q(r_{d-1};C), \quad
r_d = r_{d-1} - e(k_d),
$$

对于$d=1,\ldots,D$. 此外, 定义$\hat{z}^{(d)}=\sum_{i=1}^d e(k_i)$为前$d$个码向量的部分和, 而$\hat{z}:=\hat{z}^{(D)}$则为$z$的量化向量(quantized vector).

RQ的递归量化以由粗到细的方式逼近向量z. 需要注意的是, $\hat{z}^{(1)}$是码本(codebook)中与$z$距离最近的码嵌入(code embedding) $e(k_1)$. 随后其余码被依次选取, 以在每一层深度上减少量化误差(quantization error). 因此, 截至深度$d$的部分和(partial sum) $\hat{z}^{(d)}$随着$d$的增大提供更精细的近似.

**尽管作者可以为每个深度$d$分别构建码本$C_d$, 但在所有量化深度均使用同一个共享码本$C$.** 共享码本为RQ逼近向量$z$带来两大优势. 首先, 若分别使用码本, 需要进行大量超参数搜索以确定每个深度的码本大小$|C_d|$, 而共享码本只需决定总码本大小$K$. 其次, 共享码本使所有码嵌入在每个量化深度都可用, 因而任一码可以在任意深度被复用以最大化其效用.

> 我认为这句话是整篇文章的核心.

需要指出的是, 在码本大小相同的情况下, RQ比VQ能更精确地逼近向量. VQ将整个向量空间$\mathbb{R}^{n\_z}$划分为$K$个簇(cluster), 而深度为$D$的RQ最多可将该空间划分为$K^D$个簇. 换言之, 深度为$D$的RQ的划分能力(partition capacity)等同于拥有$K^D$个码的VQ. 因此, 通过增大$D$, RQ可取代需指数级扩张码本的VQ.

#### RQ-VAE

在[图2](#fig2)中, 作者提出了RQ-VAE以精确量化图像的特征图(feature map). RQ-VAE同样采用VQ-VAE的encoder-decoder架构, 但将VQ模块替换为前文的RQ模块. 具体而言, 深度为$D$的RQ-VAE将特征图$Z$表示为代码堆叠图$M \in \{1,\ldots,K\}^{H \times W \times D}$, 并提取$\hat{Z}^{(d)} \in \mathbb{R}^{H \times W \times n_z}$, 其中$\hat{Z}^{(d)}$是深度$d$($d \in \{1,\ldots,D\}$)下的量化特征图, 满足

$$
\begin{aligned}
&\mathbf{M}_{hw} = \mathcal{RQ}(E(\mathbf{X})_{hw}; \mathcal{C}, D),\\
&\hat{\mathbf{Z}}^{(d)}_{hw} = \sum_{d'=1}^{d} \mathbf{e}(\mathbf{M}_{hw d'}). \tag{5}
\end{aligned}
$$

为简洁起见, 深度为$D$的量化特征图$\hat{Z}^{(D)}$亦记作$\hat{Z}$. 最终, 解码器$G$根据$\hat{Z}$重建输入图像, 记为$\hat{X} = G(\hat{Z})$.

本文提出的RQ-VAE可以使自回归(autoregressive, AR)模型在较低的计算成本下有效生成高分辨率图像. 在固定下采样因子$f$的情况下, 由于RQ-VAE能够在给定码本大小下精确逼近特征图, 因而其重建结果比VQ-VAE更为逼真. 需要注意的是, 重建图像的保真度对于生成图像的最高质量至关重要. 此外, 得益于其更精确的逼近能力, RQ-VAE在保持重建质量的同时相比VQ-VAE允许更大的$f$和更小的$(H, W)$. 因此, RQ-VAE使AR模型能够降低计算成本, 提高图像生成速度, 并更好地学习码之间的长程交互.

##### 训练

为了训练RQ-VAE的编码器E与解码器G, 作者针对损失:

$$
\mathcal{L}= \mathcal{L}_{\text{recon}} + β\mathcal{L}_{\text{commit}},\quad β>0
$$

采用梯度下降法. 其中, 重构损失$\mathcal{L}_{\text{recon}}$与承诺损失$\mathcal{L}_{\text{commit}}$定义为

$$
\mathcal{L}_{\text{recon}} = \lVert \mathbf{X}-\hat{\mathbf{X}}\rVert_2^2
$$

$$
\mathcal{L}_{\text{commit}} = \sum_{d=1}^{D}\Bigl\lVert \mathbf{Z}-\text{sg}\!\bigl[\hat{\mathbf{Z}}^{(d)}\bigr]\Bigr\rVert_2^2
$$

其中sg\[·]表示断梯度(stop-gradient)运算符, RQ模块的反向传播采用直通估计器(straight-through estimator). 需要注意的是, $\mathcal{L}_{\text{commit}}$为各层$d$量化误差之和, 而非单一项$\lVert \mathbf{Z}-\text{sg}[\hat{\mathbf{Z}}]\rVert_2^2$. 该损失旨在使$\hat{\mathbf{Z}}^{(d)}$随着$d$的增加逐步减少$\mathbf{Z}$的量化误差. 因此, RQ-VAE以粗到细(coarse-to-fine)的方式逼近特征图, 并保持训练稳定. 码本$C$通过聚类特征的指数移动平均(exponential moving average, EMA)进行更新.

#### 对抗训练

RQ-VAE同样采用对抗学习进行训练, 以提升重建图像的感知质量. 按照前人研究的描述, 模型联合使用基于patch的对抗损失与感知损失. 相关实现细节收录于补充材料.

> 类似于VQ-GAN.

### RQ-Transformer

在本节中, 作者提出了图2中的RQ-Transformer, 用于自回归地预测RQ-VAE的code stack. 首先, 作者对RQVAE提取的离散码进行自回归AR建模, 随后介绍RQ-Transformer如何高效学习离散码的堆叠映射. 最后, 作者提出了针对RQ-Transformer的训练技巧, 以在AR模型训练过程中避免exposure bias(训练与推断阶段不一致的问题).

#### 深度为$D$的离散码AR建模

在RQ-VAE提取得到码图$M∈[K]^{H×W×D}$之后, 栅格扫描(raster scan)顺序会将$M$的空间索引重新排列为二维码数组$S∈[K]^{T×D}$, 其中$T=HW$. 具体而言, 第$t$行$S_t$由$D$个码组成:

$$
S_t=(S_{t1},\cdots,S_{tD})∈[K]^D,\quad t∈[T].
$$

将$S$视为图像的离散潜变量, AR模型学习的分布$p(S)$可自回归地分解为

$$
p(S)=\prod_{t=1}^{T}\prod_{d=1}^{D}p\bigl(S_{td}\mid S_{<t,d},S_{t,<d}\bigr).
$$

#### RQ-Transformer架构

一种朴素做法是按照栅格扫描顺序将$S$展开为长度为$TD$的序列, 并输入传统transformer. 然而, 该方法既未利用RQ-VAE对$T$长度的压缩, 也未降低计算开销. 因此, 作者提出RQ-Transformer, 以高效学习深度为$D$的RQ-VAE离散码. 如[图2](#fig2)所示, RQ-Transformer由spatial transformer与depth transformer两部分组成.

##### 空间Transformer

Spatial transformer由若干masked self-attention块堆叠而成, 用于提取汇总前序位置信息的上下文向量. 在其输入端, 作者复用了学习到的RQ-VAE码本. 具体地, 定义spatial transformer的输入$u_t$为

$$
u_t=\mathrm{PE}_T(t)+\sum_{d=1}^{D}e(S_{t-1,d}),\quad t>1
$$

其中$\mathrm{PE}_T(t)$是针对栅格扫描(raster-scan,即按行逐像素扫描)顺序下空间位置$t$的位置信嵌入(positional embedding). 需要注意,第二项与式5中的图像量化特征向量(quantized feature vector)相同. 对于序列的首个位置,将$u_1$设为可学习嵌入(learnable embedding),用作序列起始标记. 序列$(u_t)_{t=1}^T$经空间transformer(spatial transformer)处理后,上下文向量$h_t$编码了$S_{<t}$的全部信息,具体为

$$h_t = \mathrm{SpatialTransformer}(u_1,\cdots,u_t)$$

##### 深度Transformer

给定上下文向量$h_t$, 深度Transformer在位置$t$以自回归方式预测$D$个码元$(S_{t1},\cdots,S_{tD})$. 在位置$t$, 深度$d$处, 它的输入$v_{td}$定义为至多深度$d-1$的码元嵌入之和, 因而有$v_{td}=PE_D(d)+\sum_{d'=1}^{d-1}e(S_{td'})\quad (d>1)$.

其中$PE_D(d)$是针对深度$d$的位置信息嵌入, 在所有位置$t$共享. 由于位置信息已编码于$u_t$, $v_{td}$中不再使用$PE_T(t)$. 当$d=1$时, 取$v_{t1}=PE_D(1)+h_t$. 需注意, 上式中的第二项对应式(5)中深度$d-1$处的量化特征向量$\hat{Z}_{hw}^{(d-1)}$. 因此, 深度Transformer在已有至$d-1$阶估计的基础上预测下一个码元, 以获得对$\hat{Z}_t$更精细的估计. 最终, 深度Transformer给出的条件分布$p_{td}(k)=p(S_{td}=k|S_{<t,d},S_{t,<d})$为

$$p_{td}=DepthTransformer(v_{t1},\cdots,v_{td})$$

RQ-Transformer通过最小化$L_{AR}$进行训练, 该损失为负对数似然(NLL):

$$\mathcal{L}_{AR}=\mathbb{E}_{S}\mathbb{E}_{t,d}\bigl[-\log p(S_{td}|S_{<t,d},S_{t,<d})\bigr]$$

!!! example "RQ-Transformer推理示例"

    1. Compute u2
    2. Input u1 and u2 into the Spatial Transformer to get h2
    3. Form v2,1 by adding the first depth positional embedding PED(1) and h2, then use Depth Transformer layer 1 to predict S2,1
    4. Form v2,2 by adding PED(2) and the embedding of S2,1, then use Depth Transformer layer 2 to predict S2,2
    5. Form v2,3 by adding PED(3) and the embeddings of S2,1 and S2,2, then use Depth Transformer layer 3 to predict S2,3
    6. Form v2,4 by adding PED(4) and the embeddings of S2,1, S2,2 and S2,3, then use Depth Transformer layer 4 to predict S2,4
    7. After all four depth codes at position 2 are predicted, compute u3 as PET(3) plus the sum of embeddings S2,1 through S2,4, then move to position 3 and repeat until every spatial position is generated

#### 软标签和随机采样

暴露偏置(exposure bias)被认为会因为训练阶段与推理阶段预测差异导致的误差累积而降低AR模型(autoregressive model)的性能. 对于RQ-Transformer来说, 当深度$D$增加时, 预测误差也会累积, 因为随着$d$变大, 对特征向量进行更精细估计变得更加困难.

!!! tip "暴露偏置"

    暴露偏置是序列生成模型在训练-推断两种不同模式下输入分布不一致导致的系统性误差: 训练时候模型总是看到真实数据的上一时刻词(Teacher Forcing策略), 而推断时候只能接受自己刚才预测的词. 当早期预测出错以后, 错误会被反复喂给模型并迅速放大, 造成雪崩式质量下降.

因此, 本文提出利用soft labeling(软标签, 即用概率分布而非one-hot硬标签)以及从RQ-VAE随机抽样码向量(stochastic sampling)来缓解暴露偏置. Scheduled sampling(计划抽样)虽可减少该差异, 但对大规模AR模型并不适用, 因为它要求在每一步训练中进行多次推理, 从而显著提高训练成本. 相反, 本文利用RQ-VAE中码嵌入(code embedding)的几何关系. 设向量$z∈ℝ^{n_z}$, 在$[K]$上定义条件分类分布$Q_τ(k|z)$, 其中$τ>0$为temperature(温度参数):

!!! tip "计划抽样"

    计划抽样通过在训练过程中按预设概率逐步用模型自身预测替换TeacherForcing的真值输入, 让模型提前适应推断场景, 以低成本缓解暴露偏置. 如果采用teacher forcing, 可以一次性并行计算所有实践部的一次前向传播. 而计划抽样需要在每个时间步先用模型生成预测, 再决定下一步的输入, 天然串行, 所以说, 在每一步训练中需要多次进行推理, 训练成本显著提高.

!!! tip "几何关系"

    几何关系在这里指的是向量空间中各个嵌入向量之间的空间结构特征, 包括它们的距离, 方向, 角度, 邻近性等等. 这里他们将距离信息转化为条件分类概率. 相近的code赋予更高的概率.

$$Q_τ(k|z) ∝ \exp(−‖z−e(k)‖₂² / τ),  k ∈ [K]$$

该分布根据$z$与各码嵌入$e(k)$的欧氏距离为每个码$k$分配概率, 温度$τ$控制分布的平滑程度; $τ$越小, 分布越尖锐, 越倾向于选择距离最近的码.

##### 软标签

基于码嵌入之间的距离, 作者使用软标签来改进RQ-Transformer的训练, 通过对RQ-VAE中各码间几何关系进行显式监督实现. 对于位置$t$和深度$d$, 设$Z_t$为图像的特征向量, $r_{t,d-1}$为深度$d-1$处的残差向量. 随后, NLL损失将one-hot标签$Q_0(·|r_{t,d-1})$(即仅对单一码赋予概率$1$的离散标签)作为$S_{td}$的监督信号. 与one-hot标签不同, 作者采用经过平滑处理的概率分布$Q_τ(·|r_{t,d-1})$(soft label)作为监督.

> 这里的意思应该是监督信号本身也换成了一个"软标签"的概率分布, 同时模型输出的也是一个概率分布, 两者通过NLL来对齐.

##### 随机采样

在上述soft labeling(软标签)的基础上, 作者提出对RQ-VAE生成的code map(码图)进行stochastic sampling(随机采样), 以减小training与inference阶段的discrepancy(差异). 与RQ的deterministic code selection(确定性码选择)不同, 作者通过从$Q_τ(·|r_{t,d−1})$中采样来确定码$S_{td}$. 需要指出的是, 当$τ→0$时, 该随机采样退化为SQ的原始码选择. 随机采样使得对于给定图像的feature map, 可以获得不同组合的codes $S$.

[^1]: Lee,  D., Kim, C., Kim, S., Cho, M., & Han, W.-S. (2022). Autoregressive image generation using residual quantization (No. arXiv:2203.01941). arXiv. https://doi.org/10.48550/arXiv.2203.01941
