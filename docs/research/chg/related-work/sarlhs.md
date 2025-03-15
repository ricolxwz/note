---
title: SaRLHS
# level: chg
---

# SaRLHS[^1]

## Motivation

Most works rely on acoustic or visual cues alone, missing out the deeper semantic context needed for more accurate.

## Contribution

* Incorporation of semantic information using BERT
* Post-face enhancement process to increase face rendering effects

## Methodology

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/fb1967199121e81ff455da66f966df2f.webp#only-light){ loading=lazy width='600' }
![](https://img.ricolxwz.io/fb1967199121e81ff455da66f966df2f_inverted.webp#only-dark){ loading=lazy width='600' }
</figure>

* They implement a pre-trained BERT to extract semantic representations from text that recognized from the audio
* First use a coarse renderers $𝐺_𝑣$, then they use Rel1ESRGan for fine grained adjustment (post face enhancement)


[^1]: Zhao, W., Xiao, P., Zhang, R., Wang, Y., & Lin, J. (2022). Semantic-aware responsive listener head synthesis. Proceedings of the 30th ACM International Conference on Multimedia, 7065–7069. https://doi.org/10.1145/3503161.3551580
