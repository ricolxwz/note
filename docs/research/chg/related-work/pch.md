---
title: PCH
level: chg
---

# PCH[^1]

## 任务

1. LHG

* Input: Speaker (Audio), Listener (Reference Image)
* Output: Listener (Video)

2. THG

* Input: Speaker (Audio), Speaker (Reference Image)
* Output: Speaker (Video)

## 动机

* Realistic digital humans generation needs a large number of videos of the same speaker, but we have less digital information given a speaker reference
* Background distortions and image border artifacts during rendering

## 贡献

* Enhancement on PIRender: use an image boundary inpainting trick and a foreground-background fusion module
* Apply several neural network training techniques to improve audio-to-head training on limited data

## 方法

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/79798d68d5583691d77540e1210ef390.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/79798d68d5583691d77540e1210ef390_inverted.webp#only-dark){ loading=lazy width='800' }
</figure>

Givn a audio signal sequence, a sequential driver approximates the 3DMM parameters for every video frame. Then a pre-trained PIRender renders the final video based on these parameters and reference frame. This can prevent the model from error accumulation, it's quite similar to resnet.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/4b90e6faccc1a5fd7a315ea92eaaa4af.webp#only-light){ loading=lazy width='300' }
![](https://img.ricolxwz.io/4b90e6faccc1a5fd7a315ea92eaaa4af_inverted.webp#only-dark){ loading=lazy width='300' }
</figure>

Architecture of the sequential driver model. For each frame, they approximate the residual relative to the initial parameters of the first frame (reference image).

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/ad3f7dca29e01a12031c1adf83ebac0b.webp#only-light){ loading=lazy width='400' }
![](https://img.ricolxwz.io/ad3f7dca29e01a12031c1adf83ebac0b_inverted.webp#only-dark){ loading=lazy width='400' }
</figure>

Every each pixel position in each frame, they belong to either foreground or background. To avoid the distortions between foreground and background, they calculate a median segmentation result, each pixel of which is the median of the results of the previous five frames. After segmentation, they paste the background area from reference image to improve reality.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/4047dd6cc66e92cbe4975151769bf630.webp#only-light){ loading=lazy width='300' }
![](https://img.ricolxwz.io/4047dd6cc66e92cbe4975151769bf630_inverted.webp#only-dark){ loading=lazy width='300' }
</figure>

The human hair and upper body should follow with the movement of the head. In this case, we need to inpaint some texture around the edges fo the image. They solve by setting the padding mode to "border" in `grid_sample` function of pytorch. 

[^1]: Huang, A., Huang, Z., & Zhou, S. (2022). Perceptual conversational head generation with regularized driver and enhanced renderer. 7050–7054. https://doi.org/10.1145/3503161.3551577
