---
title: L2L
level: chg
---

## Motivation

* Need for modeling the non-deterministic(D), multimodal(R) nature of dyadic interactions: Listener responses vary significantly and depend on both the speaker’s speech (audio) and their facial/body motion; aka. chameleon effect.
* Gap in large-scale, in-the-wild datasets: Existing studies often rely on small or lab-recorded interactions. By collecting and analyzing hours of online split-screen interviews, the authors sought to address the scarcity of real-world conversational data for training and evaluating new models.

## Contribution

* Learning a discrete latent space of listener motion using VQ: By extending vector quantization techniques (originally designed for images) to temporal facial motion, the authors enable non-deterministic outputs that remain on the “manifold” of realistic expressions (Section 3.2). This is novel in motion synthesis, as it supports generating multiple plausible listener reactions while avoiding visually implausible drift.
* Cross-modal transformer for combing speaker audio&motion: The method fuses both the speaker’s speech signal and facial motion through cross-attention, rather than simple concatenation (Section 3.3). This approach effectively aligns the two input streams, which is important for capturing the natural timing of gestures and facial cues relative to speech.
* A new large-scale in-the-wild dataset of dyadic interview: The authors collect and release a dataset comprising 72 hours of interviews, filmed in split-screen format to capture both speaker and listener face-on (Section 4). Such large, diverse video data of real conversations is relatively rare and helps train and benchmark models on realistic, fine-grained face-to-face interaction.

## Methodology

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/a77a64ec7aa3abf4c81673e2b8220a88.webp#only-light){ loading=lazy width='500' }
![](https://img.ricolxwz.io/a77a64ec7aa3abf4c81673e2b8220a88_inverted.webp#only-dark){ loading=lazy width='500' }
</figure>

* Speaker's modality fusion: They use cross-modal transformer to fuse the speaker audio and motion input. 
* Noval sequence-encoding VQ-VAE to discretize past listener motion. And the autoregressive predictor outputs a distribution over the $K$ discrete codebook indices, from which they sample a code for the next timestamp, they use this approach to achieve non-deterministic listener interaction.
