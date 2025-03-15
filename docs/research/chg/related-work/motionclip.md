---
title: MotionCLIP
# level: chg
---

## Motivation

* Motion capture datasets fail to provide sufficiently rich and descriptive textual annotations: They point out that existing motion capture datasets, despite their growing size, still fail to provide sufficiently rich and descriptive textual annotations for fully capturing the semantics of human motion. So, neural models trained using labeled motion data do not generalize well to the full richness of the human motion manifold.

* The importance of connecting human motion with rich linguistic understanding: They emphasize the importance of connecting human motion with rich linguistic understanding, in order to enable intuitive, high-level control . They observe that large-scale vision–language models (like CLIP) contain extensive semantic and cultural knowledge, which could be leveraged to address the sparse and imperfect nature of standard motion datasets.

## Contribution

* Propose MotionCLIP, a 3D human motion autoencoder that aligns the motion latent space with CLIP. They introduce a dual-alignment strategy (text-alignment using CLIP's text encoder and self-supervised image-alignment through rendered frames) that infuses CLIP’s visual-textual semantics into the motion domain. They exclusively claim that their latent space demonstrates unprecedented compositionality of independent actions, semantic interpolation between actions, even natural and linear latent-space based editing. And never-before-seen capabilities.(独立动作组合起来; 动作之间插值; 潜在空间编辑).

## Methodology

* Dual alignment strategy: they do so using (i) a Text Loss, connecting motion representations to the CLIP embedding of their text labels, and (ii) an Image Loss, connecting motion representations to CLIP embedding of rendered images that depict the motion visually.
