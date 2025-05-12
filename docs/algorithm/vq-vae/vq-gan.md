---
title: VQ-GAN
comments: true
addi: https://arxiv.org/pdf/2012.09841
---

# VQ-GAN (2021)[^1]

## 摘要

transformer旨在学习序列数据中的长程交互, 在多种任务上持续刷新state-of-the-art表现. 与CNN相比, transformer不含局部优先的[归纳偏置](/algorithm/vit#inductive-bias), 这会使得他们的表达能力更强, 但在处理长序列(如高分辨率图像)时计算开销巨大. 作者展示了如何结合CNN归纳偏置的有效性与transformer的表达力来建模并合成高分辨率图像. 具体而言, 他们(1)使用CNN学习一个上下文丰富的图像成分词汇表(context-rich vocabulary, 即可重用的局部图像"单词"), 并(2)利用transformer高效地对这些成分在高分辨率图像中的组合进行建模. 该方法可以直接用于条件合成任务, 生成过程既可由非空间条件信息(如类别标签)也可由空间条件信息(如分割图)控制. 尤其是, 作者首次实现了基于transformer的百万像素语义引导图像合成, 并在类条件ImageNet数据集上取得自回归模型(autoregressive model, 逐像素递归生成模型)的state-of-the-art性能.

## 简介

<figure markdown='1' id='fig1'>
![](https://img.ricolxwz.io/b851e6b46df520955647ebc8a62eb6a7.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/b851e6b46df520955647ebc8a62eb6a7_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图1: 该方法使transformer能够合成如本例所示的高分辨率图像, 分辨率为1280x460 pixels.</figcaption>
</figure>

Transformer模型正迅速崛起——它们已成为语言任务的事实标准架构, 并且正被广泛应用于音频和视觉等领域. 与当前视觉领域占主导地位的卷积神经网络(CNNs)相比, transformer架构不包含强调局部交互的归纳先验, 因此能够自由学习输入之间的复杂关系. 然而, 这种普适性意味着模型必须显式学习所有关系, 而CNNs能够利用图像内部强局部相关性的先验知识. 由于需要考虑所有成对交互, transformer更高的表达能力伴随着计算量的二次增长. 由此带来的能耗与时间开销, 使得最先进的transformer模型在扩展到数百万像素的高分辨率图像时面临根本性的挑战.

关于transformer倾向于学习卷积结构的观察引出了一个问题: 在每次训练视觉模型时, 是否必须从零开始重新学习关于图像局部结构与规律性的全部知识, 还是可以**在保留transformer灵活性的同时, 高效地编码图像的归纳偏置**? 作者假设, 低层次图像结构可以通过局部连接(即卷积架构)得到良好刻画, 而当语义层级升高时, 这种结构假设便不再有效. 此外, CNN不仅具有显著的局部性偏置, 还因为在所有位置共享权重而呈现对空间不变性的偏置; 当任务需要更整体地理解输入时, 这一特性会使CNN显得低效.

作者的关键洞见在于, 当卷积架构与transformer架构结合使用时, 二者能够共同刻画视觉世界的组合性本质: 他们首先采用卷积方法高效地学习一个包含丰富上下文的视觉部件码本(codebook, 即离散向量词典), 随后学习这些部件在全局范围内的组合模型. 这些组合内部的长程交互需要表达能力强大的transformer架构来建模各组成视觉部件的分布. 此外, **作者引入对抗式(adversarial)训练, 以确保局部部件字典充分捕获感知上重要的局部结构**, 从而减轻transformer在低层统计建模方面的负担. 当transformer能够专注于其独有的优势——长程关系建模——时, 便能够生成如上图所示的高分辨率图像, 这一能力此前一直难以实现. 该方法的框架还允许通过条件信息(例如目标类别或空间布局)来控制生成图像. 实验结果表明, 该方法延续了transformer的优势, 在性能上超越了此前基于卷积架构的同类码本方法的最新水平.

> 给我的感觉是, 利用了一下CNN的先验偏置提取低层次信息, 然后利用Transformer建模更好的高层次交互. 同时用GAN确保CNN提取到了充分的低层次信息, 减少Transformer隐式建模低层次信息的负担. emmmm... 缝合怪

## 方法

本文旨在充分发挥transformer模型卓越的学习能力, 将其引入至百万像素级别的高分辨率图像合成任务. 此前的研究已在64×64像素范围内展示了transformer用于图像生成的可观潜力, 但由于序列长度导致的计算开销呈二次增长, 这些方法无法直接扩展到更高分辨率.

高分辨率图像合成要求模型能够理解图像的整体构图, 既能生成局部逼真的细节, 也能保持全局一致的模式. 因此, 我们不再使用像素来表示图像, 而是将其表示为由codebook中感知丰富的图像成分所组成的组合. 通过如下面第一小节所述学习一套高效编码, 我们能够显著减少这些组合的描述长度, 从而按照下面第二小节中的方法, 使用transformer架构高效地建模图像内部的全局关联. 如下图所示, 该方法在无条件和有条件设置下均能生成逼真且连贯的高分辨率图像.

<figure markdown='1' id='fig2'>
![](https://img.ricolxwz.io/07632a674c37fb011518d820d6c782d5.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/07632a674c37fb011518d820d6c782d5_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图2: 该方法采用卷积学习蕴含上下文信息的视觉部件码本, 随后使用自回归transformer架构对其组合进行建模. 离散码本作为两种架构之间的接口, 基于patch的判别器在保持高感知质量的同时实现强压缩. 此方法将卷积方法的高效性引入基于transformer的高分辨率图像合成. </figcaption>
</figure>

> 感觉和ViT那一套是很像的, 只不过这里是离散的码字, 但是ViT那里是连续的patch向量. 如果说Transformer更喜欢离散token的话, 可能还是这种方式更合transformer的胃口, 和词表中的那些离散文字token差不多.

### 面向Transformer的高效图像成分码本学习

为了将表达能力极强的transformer架构应用于图像合成, 作者需要把一幅图像的组成元素表示成序列形式. 出于复杂度的考虑, 与其直接在像素级别操作, 不如使用一个离散码本(discrete codebook)来存储学习得到的表示. 这样, 任意图像\(x\in\mathbb R^{H\times W\times3}\)都可以用一组空间分布的码本向量\(z_q\in\mathbb R^{h\times w\times n_z}\)表示, 其中\(n_z\)是码字维度. 等价地, 也可以把它写成一串长度为\(h\cdot w\)的索引序列, 每个索引指向学习得到的码本中的一个条目. 为了高效学习这种离散空间码本, 作者直接引入了CNN的归纳偏置, 并结合神经离散表示学习的思想. 具体而言, 先训练一个卷积模型, 由编码器\(E\)和解码器\(G\)组成; 二者共同学习使用来自离散码本\(\mathcal Z=\{z_k\}_{k=1}^K\subset\mathbb R^{n_z}\)的码字来重建图像(见[图2](#fig2)概览).

更精确地说, 给定图像\(x\), 作者用\(\hat x = G(z_q)\)来近似\(x\). 其中\(\hat z = E(x)\in\mathbb R^{h\times w\times n_z}\)是编码结果, 接着对每个空间码\(\hat z_{ij}\in\mathbb R^{n_z}\)执行逐元素量化$q(·)$, 将其映射到与之最接近的码本向量\(z_k\):

\[
z_q = q(\hat z)
      := \bigl(\operatorname*{arg\,min}_{z_k\in\mathcal Z}\lVert \hat z_{ij}-z_k\rVert\bigr)
      \in\mathbb R^{h\times w\times n_z}
\]

于是重建过程满足

\[
\hat x = G(z_q)=G\bigl(q(E(x))\bigr)
\]

因为量化操作不可导, 作者采用直通梯度估计器(straight-through gradient estimator): 在反向传播时直接把解码器的梯度复制给编码器, 从而可以端到端地联合训练模型与码本. 整体损失函数为

\[
\mathcal L_{\text{VQ}}(E,G,\mathcal Z)=
\lVert x-\hat x\rVert^2
+\lVert \operatorname{sg}[E(x)]-z_q\rVert_2^2
+\lVert \operatorname{sg}[z_q]-E(x)\rVert_2^2
\]

其中\(\mathcal L_{\text{rec}}=\lVert x-\hat x\rVert^2\)是重建损失, \(\operatorname{sg}[\cdot]\)表示停止梯度(stop-gradient)操作, 最后一项\(\lVert\operatorname{sg}[z_q]-E(x)\rVert_2^2\)称为承诺损失(commitment loss), 用以鼓励编码器在特征空间中靠近已选中的码字.

> 平平无奇的VQ-VAE操作.

#### 学习一个认知丰富的码本

利用transformer将图像表示为潜在图像成分的分布, 需要在压缩率的极限上探索并学习一个更丰富的码本. 为此, 作者提出了VQ-GAN, 这是原始VQVAE的一个变体, 并结合判别器与感知损失以在较高压缩率下保持良好的感知质量. 与先前仅在浅层量化模型之上叠加像素级或基于transformer的自回归模型的方法形成对比, 该工作更深入地优化了量化过程. 具体而言, 作者将用于\(L_{\text{rec}}\)的\(L_2\)损失替换为感知损失, 并引入基于patch的判别器\(D\)进行对抗训练, 旨在区分真实图像与重建图像:

???+ note "浅层量化模型"

    这里的"浅层"主要体现在: 采样层数少, 压缩倍率低 -> 信息量大, 序列长度长, 给后端Transformer带来很高的计算开销

\[
\mathcal{L}_{\text{GAN}}(\{E,G,Z\},D)=\bigl[\log D(x)+\log\bigl(1-D(\hat{x})\bigr)\bigr]
\]

寻找最优压缩模型\(Q^*=\{E^*,G^*,Z^*\}\)的完整目标函数为

\[
Q^*=\arg\!\min_{E,G,Z}\;\max_D\; \mathbb{E}_{x\sim p(x)}\!\bigl[\mathcal{L}_{\text{VQ}}(E,G,Z)+\lambda\,\mathcal{L}_{\text{GAN}}(\{E,G,Z\},D)\bigr]
\]

其中自适应权重\(\lambda\)按下式计算:

\[
\lambda=\frac{\nabla_{G_L}[\,\mathcal{L}_{\text{rec}}\,]}{\nabla_{G_L}[\,\mathcal{L}_{\text{GAN}}\,]+\delta}
\]

这里, \(L_{\text{rec}}\)为感知重构损失, \(\nabla_{G_L}[\cdot]\)表示其输入关于解码器最后一层\(L\)的梯度, \(\delta=10^{-6}\)用于数值稳定性. 为了在全局范围内聚合上下文信息, 作者在最低分辨率上施加了一个单独的注意力层. 该训练策略在展开潜在码时显著缩短了序列长度, 从而使强大的transformer模型得以应用.

???+ note "对上一段话的理解"

    这里的"自适应权重"是用来平衡$\mathcal{L}_{\text{VQ}}(E,G,Z)$和$\mathcal{L}_{\text{GAN}}(\{E,G,Z\},D)$的, 如果$\nabla _{G_L}[\mathcal{L}_{\text{rec}}]$变大, 那么$\lambda$会变大, 来平衡$\mathcal{L}_{\text{rec}}$对输入的梯度太大产生的影响. 这个所谓的单独的注意力层应该是加在量化器或者编码器后面, 用于在完成下采样之后对全局特征进行一个简单的交互.

### 使用Transformer学习图像成分的组合

#### Transformer设计

当$E$和$G$已训练完毕后, 本文即可利用编码的码本索引来表示图像. 具体而言, 图像$x$的量化编码为\(z_q = q(E(x)) \in \mathbb{R}^{h\times w \times n_z}\), 这与序列\(s \in \{0,\dots,|Z|-1\}^{h\times w}\)等价; 该序列通过将每个码向量替换为其在码本\(Z\)中的索引得到:

\[
s_{ij}=k \text{ such that }(z_q)_{ij}=z_k
\]

将序列$s$的索引映射回相应的码本向量即可恢复\(z_q=(z_{s_{ij}})\), 随后经解码器得到重建图像\(\hat{x}=G(z_q)\).  选定$s$中的某种遍历顺序后, 图像生成问题可表述为自回归的"下一个索引预测": 给定先前索引\(s_{<i}\), Transformer学习预测下一个索引的分布\(p(s_i|s_{<i})\), 从而得到整条序列的似然:

\[
p(s)=\prod_i p(s_i|s_{<i}).
\]

于是可直接最大化数据表示的对数似然:

\[
\mathcal{L}_{\text{Transformer}}
=\mathbb{E}_{x\sim p(x)}\bigl[-\log p(s)\bigr]
\]

> 就是一个比较平常的transformer, 只不过它的tokens是经过量化得到的索引.

#### 条件生成

在许多图像合成任务中, 用户希望通过额外信息来控制生成过程. 记该信息为$c$, 它可以是描述整体类别的单个标签, 亦可是一幅图像本身. 任务即学习在条件$c$下序列的似然:

\[
p(s|c)=\prod_i p(s_i|s_{<i},c)
\]

若条件$c$具有空间结构, 则首先再训练一个VQGAN得到基于索引的表示\(r\in\{0,\dots,|Z_c|-1\}^{h_c\times w_c}\), 对应新的码本\(Z_c\). 由于Transformer的自回归特性, 可将$r$简单地前置于$s$(相当于当作一串历史tokens), 然后仅对\(p(s_i|s_{<i},r)\)项计算负对数似然. 这种"纯解码器"策略同样已成功应用于文本摘要任务.

#### 生成高分辨率图像

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/b4e5eadbaaec484057481f7886a58e4b.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/b4e5eadbaaec484057481f7886a58e4b_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图3: 滑动注意力窗口</figcaption>
</figure>

Transformer的注意力机制对输入序列$s$的长度$h·w$施加了限制. 作者可以通过调整VQGAN的下采样块数量$m$, 将图像尺寸$H\times W$压缩到$h=H/2^m, w=W/2^m$. 然而, 当$m$超过数据集所依赖的临界值时, 作者观察到重构质量会明显下降. 为了在百万像素级别生成图像, 作者必须采用按patch划分的方式, 并在训练期间裁剪图像, 以把序列$s$的长度限制在可接受的最大范围内. 在采样阶段, transformer以滑动窗口(sliding-window)方式工作, 如上图所示. VQGAN确保当数据集的统计特性近似空间平移不变, 或提供空间条件信息(spatial conditioning)时, 可用上下文仍足以精确地建模图像. 在实际应用中, 这一假设并不严格: 即使在无条件合成已对齐数据的场景中被打破, 也只需向生成过程附加图像坐标这一条件即可, 做法与相关研究类似.

> 这就很迷, 你这个工作不就是想要通过减少归纳偏置提高表达力吗? 怎么又搞了个窗口先验. 直接整张图的所有tokens都一起用transformer建模不好吗? 反正编码器已经下采样好几次了, 序列长度应该不至于让Transformer崩了把...

[^1]: Esser, P., Rombach, R., & Ommer, B. (2021). Taming transformers for high-resolution image synthesis (No. arXiv:2012.09841). arXiv. https://doi.org/10.48550/arXiv.2012.09841
