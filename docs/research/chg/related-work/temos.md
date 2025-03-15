---
title: TEMOS
level: chg
---

## Motivation

* Much of the previous work has focused on generating motions conditioned on a single action label, not a sentence. And most current work generate only one output motion per text input, however, it's a non-deterministic problem: for example, with the input "A man walks in a circle", the size and the orientation of the circle are not specified, thus lead to multiple ways of performing the actions.
* Most prior work employs AR models, which can suffer from drift over time and eventually produce static poses. 

## Contribution

* A novel cross-modal variational model using transformers for joint encoding of text and motion in a shared latent space
* Diverse and natural motions: The model generates multiple plausible motions per input by sampling from a distribution, addressing ambiguities in textual descriptions and exploring natural variations.

## Methodology

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/32852b9bc917cf00d05e8d9de43337c6.webp#only-light){ loading=lazy width='500' }
![](https://img.ricolxwz.io/32852b9bc917cf00d05e8d9de43337c6_inverted.webp#only-dark){ loading=lazy width='500' }
</figure>

During training, they encode both the motion and text through their respective transformer encoders, together with modal-specific learnable distribution tokens. The encoder outputs corresponding to these tokens provide Gaussian distribution parameters on which the KL losses are applied and a latent vector $z$ is sampled. Reconstruction losses on the motion decoder outputs further provide super-vision for both motion and text branches. Word embedding consists of a variational encoder that takes input from a pre-trained and frozen DistilBERT model. 

At test time, they only use the right branch, which gores from an input test to a diverse set of motions through the random sampling of the latent vector $z^T$ on the cross-modal space. The output motion duration is determined by the number of positional encodings $F$.
