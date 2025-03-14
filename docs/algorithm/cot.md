---
title: 思维链
comments: false
---

# 思维链[^1]

## 摘要

作者探讨了如何通过生成思路链——一系列中间推理步骤——来显著提升大型语言模型执行复杂推理的能力. 特别地, 他们展示了在足够大的语言模型中, 这类推理能力如何通过一种称为chain-of-thought prompting的简单方法自然地涌现, 即在提示中提供少量思路链示例作为范例. 对三个大型语言模型的实验结果表明, chain-of-thought prompting在多种算术、常识及符号推理任务中都能提升性能. 这一实证结果相当显著. 例如, 仅给PaLM 540B提供八个思路链示例, 就能在GSM8K数学文字题基准上达到业界领先的准确率, 甚至超越了带有验证器的微调GPT-3.

## 图片

<figure markdown='1' id="fig1" >
![](https://img.ricolxwz.io/2986560185d5a5cdebcac29943792540.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/2986560185d5a5cdebcac29943792540_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图1: Chain-of-thought prompting使大型语言模型能够应对复杂的算术、常识和符号推理任务. Chain-of-thought推理过程高亮表示.</figcaption>
</figure>

<figure markdown='1' id="fig2">
![](https://img.ricolxwz.io/503b24ba5229a9f966e81510f730d8c0.webp#only-light){ loading=lazy width='280' }
![](https://img.ricolxwz.io/503b24ba5229a9f966e81510f730d8c0_inverted.webp#only-dark){ loading=lazy width='280' }
<figcaption>图2: PaLM 540B通过chain-of-thought提示在GSM8K数学文字题基准上实现了新的业界领先表现. 微调的GPT-3以及之前的最佳结果均来自Cobbe et al. (2021).</figcaption>
</figure>

<figure markdown='1' id="fig3">
![](https://img.ricolxwz.io/ce7273b9848fb8663e07072fb1cb79ae.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.io/ce7273b9848fb8663e07072fb1cb79ae_inverted.webp#only-dark){ loading=lazy width='800' }
<figcaption>图3: 给出了算术、常识和符号推理基准中的〈input, chain of thought, output〉三元组示例. 思路链部分得到突出显示.</figcaption>
</figure>

<figure markdown='1' id="fig4">
![](https://img.ricolxwz.io/daf6e73d41924db528df3d876e445f96.webp#only-light){ loading=lazy width='300' }
![](https://img.ricolxwz.io/daf6e73d41924db528df3d876e445f96_inverted.webp#only-dark){ loading=lazy width='300' }
<figcaption>图4: Chain-of-thought prompting使大型语言模型能够解决具有挑战性的数学问题. 值得注意的是, chain-of-thought推理是一种随着模型规模增长而涌现的能力. 之前在GSM8K, SVAMP和MAWPS上的最佳结果来自相关研究(...).</figcaption>
</figure>

<figure markdown='1' id="fig5">
![](https://img.ricolxwz.io/156240c30edc6dd14066bf6e84744304.webp#only-light){ loading=lazy width='250' }
![](https://img.ricolxwz.io/156240c30edc6dd14066bf6e84744304_inverted.webp#only-dark){ loading=lazy width='250' }
<figcaption>图5: 对LaMDA 137B和PaLM 540B在不同提示变体下的消融研究.</figcaption>
</figure>

<figure markdown='1' id="fig6">
![](https://img.ricolxwz.io/b49b467e758d8dd89ce04771c0e33813.webp#only-light){ loading=lazy width='280' }
![](https://img.ricolxwz.io/b49b467e758d8dd89ce04771c0e33813_inverted.webp#only-dark){ loading=lazy width='280' }
<figcaption>图6: Chain-of-thought prompting在不同提示示例之间存在差异(这是预料之中的), 但对于各种标注者以及不同示例来说, 都优于标准提示.</figcaption>
</figure>

<figure markdown='1' id="fig7">
![](https://img.ricolxwz.io/ef4f264d02dc166168771e704d1a74d4.webp#only-light){ loading=lazy width='600' }
![](https://img.ricolxwz.io/ef4f264d02dc166168771e704d1a74d4_inverted.webp#only-dark){ loading=lazy width='600' }
<figcaption>图7: Chain-of-thought prompting也提升了语言模型的常识推理能力. 此处展示的语言模型是PaLM. 之前最优的结果来自CSQA (Talmor et al., 2019)和StrategyQA (Geva et al., 2021)(仅限单模型, 截至2022年5月5日).</figcaption>
</figure>

<figure markdown='1' id="fig8">
![](https://img.ricolxwz.io/7f41db6924748cf4838b058e692cca55.webp#only-light){ loading=lazy width='280' }
![](https://img.ricolxwz.io/7f41db6924748cf4838b058e692cca55_inverted.webp#only-dark){ loading=lazy width='280' }
<figcaption>图8: 使用chain-of-thought prompting有助于在两项符号推理任务中对更长序列进行泛化.</figcaption>
</figure>

## 动机

近年来, 语言模型领域涌现了多种突破性工作, 如ELMo、BERT和GPT-3等, 并通过不断扩大模型规模来提升在语言理解与生成上的整体性能. 然而, 单纯依靠规模增大并不足以在算术推理、常识推理以及符号推理等更具挑战性的任务上取得理想效果. 基于此, 研究者们开始思考如何在无需大规模精细标注的前提下, 充分挖掘大型语言模型的推理潜能. 这一问题的研究动机源于现有方法的局限性: 传统的rationale-augmented training和微调方法虽然可以让模型显式生成推理过程, 但标注高质量的推理步骤通常需要大量的人力成本; 而以少量示例为基础的few-shot prompting方法虽然能够在某些简单任务上表现良好, 但在需要复杂推理能力的场景中效果并不显著, 且随着模型规模增长也没有获得显而易见的提升.

## 创新点

针对以上不足, 相应工作提出了一种名为Chain-of-Thought Prompting的新方法, 通过在提示示例中包含〈输入、推理过程、输出〉三元组的形式, 引导语言模型在生成最终答案之前输出更为详细的中间推理步骤. 这种做法兼具可解释性与高效性的优点, 在保留few-shot prompting无需大量训练数据和多次模型微调优势的同时, 使得模型能够有效地学习并复用推理模式. 实验表明, 在GSM8K等基准数据集上, 结合Chain-of-Thought Prompting的PaLM 540B模型在算术推理、常识推理以及符号推理任务中均取得了突破性进展, 并显著领先于传统的标准提示方法. 这一成果不仅说明了大型语言模型在内在推理能力上的巨大潜力, 也为后续在更多复杂场景中有效利用语言模型提供了新的思路和启示.

[^1]: Wei, J., Wang, X., Schuurmans, D., Bosma, M., Ichter, B., Xia, F., Chi, E., Le, Q., & Zhou, D. (2023). Chain-of-thought prompting elicits reasoning in large language models (No. arXiv:2201.11903). arXiv. https://doi.org/10.48550/arXiv.2201.11903