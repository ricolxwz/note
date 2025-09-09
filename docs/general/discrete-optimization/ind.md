---
title: 离散优化
comments: true
---

* 前置: [https://share.ricolxwz.download/1072aa0fb950aa86d5f3ec80e9de5ed4.pdf](https://share.ricolxwz.download/1072aa0fb950aa86d5f3ec80e9de5ed4.pdf)
* 简介: [https://share.ricolxwz.download/27830fc56ef6efaac58152c7911c844d.pdf](https://share.ricolxwz.download/27830fc56ef6efaac58152c7911c844d.pdf)
* 单纯形法: [https://share.ricolxwz.download/84449b6441d8d0b29fd2ed44eedae412.pdf](https://share.ricolxwz.download/84449b6441d8d0b29fd2ed44eedae412.pdf)
* 线性规划建模: [https://share.ricolxwz.download/0c6b7eb2c9aa86756e22d2ffa99a30fc.pdf](https://share.ricolxwz.download/0c6b7eb2c9aa86756e22d2ffa99a30fc.pdf)
* [整数线性规划](/general/discrete-optimization/ilp)
* [线性规划运用](/general/discrete-optimization/lpa)

强对偶定理: 如果一个线性规划是可行的并且有界, 那么它的对偶问题也是可行的并且有界, 更进一步, 两个问题的最优目标值是相等的. 证明思路是借助单纯形法. 假设原问题有解并且可行, 那么单纯形法一定会找到一个最优的基本可行解x, 设B是x对应的基, 单纯形法的最优性判别条件是所有化简之后的检验数(reduced cost)非负, 这个时候, 我们发现, 当主问题达到最优解的时候, 我们令检验数中的(*)这一部分为y^T, 那么检验数非负的这个约束其实可以被转化为对偶问题的约束, 所以y是一个对偶可行解, 我们计算对偶目标值, 得到原问题和对偶问题的目标函数值是相同的, 由于弱对偶定理, 我们得出这个目标函数同时也是对偶问题的最优解.

互补松弛性: 之前我们学了弱对偶定理和强对偶定理, 那么问题是, 原问题和对偶问题的最优解之间有什么更加细致的关系? 答案就是互补松弛性(complementary slackness). 定理4.3: 若(x, y)分别是原问题和对偶问题的可行解, 那么它们是最优解当且仅当: 对于所有原问题的变量索引j: xj=0或者y^TAj=cj, 也就是说, 变量要么取0, 要么对应的不等式在对偶中紧绑定; 对于所有对偶问题的变量索引i, yi=0或者a^T_ix=bi, 也就是说, 对偶变量要么取0, 要么原问题的约束刚好取到等号. 直观理解是: 在原始问题里面, 如果某个变量xj>0, 那么它在最优解的时候必须"有价值", 即它对应的对偶约束一定是紧的, y^TAj=cj, 否则如果松弛, 就可以改进目标函数; 在对偶问题里面, 如果某个对偶变量yi>0, 那么它对应的原问题约束必须刚好饱和a^T_ix=bi, 否则如果不饱和, 也能改进目标函数. 强对偶性告诉我们, 最优的时候c^Tx=b^Ty, 回看之前的不等式链(4.1), 如果最优解成立, 那么左右边必须相等, 这就迫使每个不等式在分量层面上都取到等号, 就得到上面的这个条件.
