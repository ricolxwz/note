---
title: 随机算法:哈希
comments: false
---

哈希解决的是内存占用过大的问题, 试想, 一个长度为为$m$的二进制位其全域的大小为$2^m$, 而实际情况下, 根本用不到全域. 例如, 一张位深为8bit, 分辨率为3072*4080的图片, 它的全域大小是$8^{3072\times 4080}$, 而实际上这个全域里面的很多值代表的都是一张没有意义的图片.

哈希表的基本思想是"The universe is a big place, but it's mostly empty". 所以, 如果我们能够map我们的宇宙$\mathcal{X}$到一个小得多的集合$\mathcal{Y}$, 使得任何由$n$个不同元素组成的子集$S\subset \mathcal{X}$都能映射到一个仍然由$n$个不同元素组成的子集$S'\subset \mathcal{Y}$, 我们就处于有利位置. 如下图所示.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.io/e0ba4b5413a86b2810cc34ec0464fabd.webp#only-light){ loading=lazy width='300' }
![](https://img.ricolxwz.io/e0ba4b5413a86b2810cc34ec0464fabd_inverted.webp#only-dark){ loading=lazy width='300' }
</figure>

但是, 上述的思路真的可行吗? 很可惜, 是不行的. 不管我们怎么选择映射的方法, 我们总能找到一个$n$个元素的集合, 经过映射之后, 小于$n$个元素. 这就是大名鼎鼎的"鸽子洞原理":
