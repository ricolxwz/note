---
title: 离散优化
comments: false
---

# Assignment1

## Problem1

由于$A$是可逆的, 因为它的行列式$\det{A}=1-6\neq 0$, 不等于0, 所以是可逆的, 所以$A$是可逆的, 所以对于任何$b$, 我们都能求解出$x = A^{-1}b$, 所以$P_b\neq \emptyset$就等于$A^{-1}b\geq 0$. 这个时候, 我们把$b$看作是一个变量, 那么它满足一系列的线性约束, 所以$Q$是一个多面体.

$A$的逆可以通过高斯-若尔当消元法求出. 具体来说, 在矩阵$A$的右侧放一个同等大小的单位矩阵$I$, 形成$[A|I]$. 然后进行初等行变换: 交换任意两行; 将某一行的元素乘以一个非零常数; 将某一行的倍数加到另一行上; 直到左侧变为$I$, 右侧就是$A$的逆. 求得了逆之后, 然后和$b$这个列向量相乘, 就得到了两个约束条件, 得到了explit linear formulation. 

## Problem2

首先, 我们要弄清楚什么是standard form, minimize $cx$, subject to $Ax = b, x\geq 0$. 我们的目的就是把$Ax=b$这个条件变为$Ax\geq b$, 这其实很简单, 我们把$Ax=b$拆解为$-Ax\geq -b$和$Ax\geq b$, 然后我们就得到了: 

$$
\begin{align*}
\text{minimize} \quad & c \cdot x \\
\text{subject to} \quad & \begin{bmatrix}
A \\
-A \\
I
\end{bmatrix}
x \geq 
\begin{bmatrix}
b \\
-b \\
0
\end{bmatrix}
\end{align*}
$$

从两个角度出发说明我们的reduction是正确的, 首先, $Ax=b$等价于$-Ax\geq -b$和$Ax\geq b$, 说明如果在原始问题中是feasible的解在新问题中同样是feasible的. 其次, 他们的目标函数是一样的. 证毕. 

## Problem3

non-degenerate是防止simplex换基之后仍然停留在原来的顶点, 目标值不变, 陷入循环. 注意, 基矩阵$A_B$的列数一定等于约束条件矩阵$A$的行数, 例如: 

$$
A = \begin{bmatrix}
1 & 1 & 0 \\
0 & 1 & 1
\end{bmatrix}
$$

的基矩阵为:

- $B = \{1, 2\}, A_B = \begin{bmatrix} 1 & 1 \\ 0 & 1 \end{bmatrix}$
- $B = \{1, 3\}, A_B = \begin{bmatrix} 1 & 0 \\ 0 & 1 \end{bmatrix}$
- $B = \{2, 3\}, A_B = \begin{bmatrix} 1 & 0 \\ 1 & 1 \end{bmatrix}$

$B$在这里对应的是索引. 这样, 我们就可以计算$A_B^{-1}b$和$0$的关系.  

a) 第一道题让我们证明如果有两个非退化的basis, 即对应的$B$有$A_B^{-1}b>0$, 那么它有无限的非退化基, 这怎么可能呢? 我们可以举个例子, 例如$A=[1, 1]$, 那么$B=1$和$B=2$对应的$A_B^{-1}$都是$1$, $b=1$, 那么$A_B^{-1}b=1$, 有两个non-degenerate bases, 但是没有无限个. 
b) 很简单, 我们设置$b=0$, 那么$A_B^{-1}=0$, 不是non-degenerate. 
c) 看a)中的例子, 它有两个optimal solutions, 但是没有degenerate basis. 
