---
title: GDN3HMT
level: chg
---

## Motivation

* The input text is too short, it may have a wide range of forms and the motions generated from text are expected to possess variable lengths
* Most work is deterministic sequence-to-sequence generation: there are usually multiple ways for a character to behave following the same textual description

## Contributions

* 2 stage pipeline to generate motion from text: Consisting of text2length sampling and text2motion generation. text2length estimates the distribution function of visual motion length grounded on the input text. The role of text2motion is to generate distinct 3D motions from the input text and the sampled motion length. 
* ⚠️ Introduce motion snippet code: Each snippet code focuses on a smaller piece of the motion (for example, "raising the arm" or "bending the knees"). Instead of encoding an entire multi-second motion as a single high-dimensional vector, the motion is segmented into more manageable chunks.
* A large-scale human motion datasets, each motion sequence paired with three textual descriptions.

## Methodology

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/cd2b95c9fea966ec0cac115629c4ffff.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/cd2b95c9fea966ec0cac115629c4ffff_inverted.webp#only-dark){ loading=lazy width='800' }
</figure>
