---
title: MDM
# level: chg
---

## Motivation

* Human motion is hard to describe: Human motion spans a vast range of complexity and is difficult to describe precisely, making it challenging for generative models to capture natural and expressive movements. Existing approaches have to limit the learned distribution since they mainly employ audo-encoders or VAEs (the input and latent are one-one mapping and a normal latent distribution) thus they are lack of expressiveness and quality.
* Diffusion models have demonstrated strong generative capabilities in other domains and it has native advantages over diversity mapping. Diffusion models have demonstrated strong generative capabilities in other domains, but they require careful adaptation to handle the unique challenges of human motion—particularly with respect to resource demands and controllability.

## Contribution

* A transformer based diffusion model instead of using U-net as backbone, better fits its temporal and non-spatial nature of motion data.
* Train in a classifier-free manner: In a standard conditional diffusion model, you typically rely on an external classifier or an auxiliary network to provide the conditioning signal. Classifier-free guidance builds part of conditionality into the model itself. During training, the model is partly trained without any conditioning and partly with conditioning. At inference time, we can adjust a "guidance scale" parameter to control how strongly the model uses the conditioning information.
* Adapting diffusion image-inpainting: They set a motion prefix and suffix, and use their model to fill in the gap. Doing so under a textual condition guides MDM to fill the gap with a specific motion that still maintains the semantics of the original input. By performing inpainting in the joints space rather than temporally, they also demonstrate the semantic editing of specific body parts, without changing the others.

## Methodology

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/bfc2420a3bd1db85eed63332ad495415.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/bfc2420a3bd1db85eed63332ad495415_inverted.webp#only-dark){ loading=lazy width='800' }
</figure>

The goal is to synthesize a human motion $x^{1:N}$ of length $N$ given an arbitrary condition $c$. This condition can be any real world signal. e.g. audio, natural language or a discrete class. Also, unconditional motion generation is also possible, they denote as the null condition $c=\emptyset$. The model is fed a motion sequence of noisy motion sequence, in each sampling step, the transformer-encoder predicts the final clean motion sequence. The diffusion process is shown in the right. Given a condition $c$, they sample random noise $X_T$ at the dimensions of the desired motion, then iterate from $T$ to $1$. At each step $t$, MDM predicts the clean sample $\bar{x}^0$, and diffuses it back to $x_{t-1}$.
