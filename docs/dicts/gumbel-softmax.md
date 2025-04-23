## 动机

类别分布\(\boldsymbol\pi\)需采样one-hot, 但\(\arg\max\)不可微. Gumbel-Softmax用可微近似解决梯度回传, 思想类似reparameterization trick.

## Gumbel-Max采样

\[
y=\arg\max_i\bigl(\log\pi_i+g_i\bigr),\;g_i\sim\text{Gumbel}(0,1)
\]

结果与\(\text{Cat}(\boldsymbol\pi)\)同分布, 但依旧不可微.

## 温度化连续近似

\[
\tilde y_i=\frac{\exp\!\bigl((\log\pi_i+g_i)/\tau\bigr)}{\sum_j\exp\!\bigl((\log\pi_j+g_j)/\tau\bigr)}
\]

\(\tau\to0\)趋近one-hot, \(\tau\to\infty\)趋近均匀; 退火训练先大后小兼顾稳定与离散化.

## 直通(ST)版

- 前向: 先算\(\tilde{\mathbf y}\), 再\(\mathbf y=\text{one\_hot}(\arg\max\tilde{\mathbf y})\)得到真正离散token.
- 反向: 梯度仅借\(\tilde{\mathbf y}\)传递, 可微且高效.

## 训练-推断一致性

前向已含Gumbel噪声→随机采样, 与推断阶段按\(p(k\mid\text{context})\)抽样同分布; 避开"无噪声硬argmax"引起的失配与码本坍缩.
