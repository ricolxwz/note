---
title: CLMLtL
# level: chg
---

## Motivation

* Importance of listener feedback: Nonverbal reactions from listeners play a critical role in dyadic interactions, influcing the flow and clarity of conversations
* LLM excel at understanding and generating text: The authors aim to transfer this language-based knowledge to the gesture generation domain

## Contribution

* Treating discrete atomic gesture elements as language tokens: The authors learn a data-driven dictionary of gesture primitives with a VQ-VQE, then fine-tune the LLM to predict these tokens in an autoregressive fashion. This approach seamlessly leverages powerful language-modeling capabilities to capture nonverbal motion cues.
* Real-time, casual modeling of listener gestures: By interleaving text tokens with motion tokens—and ensuring each gesture is conditioned only on previously seen words—the model produces immediate, temporally aligned responses. This real-time generation is significant because it closely mirrors the natural flow of human dyadic conversation.
* Argue why a text-conditioned model performs well on an inherently multimodal task: They argue that a text transcription of a speaker's utterance carries some temporal signal of when a response is in order. Punctuation, capitalization and temporal breaks in word delivery are hints about sentence structure that embed this rhythmic information. They further demonstrate that lexical semantics is crucial for producing the correct emotional response, especially when the speaker's facial expression does not reflect the emotional affect of their words. 

## Methodology

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/6a35df88593faad95e703a8a181af09f.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/6a35df88593faad95e703a8a181af09f_inverted.webp#only-dark){ loading=lazy width='800' }
</figure>
