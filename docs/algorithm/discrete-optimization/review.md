---
title: 离散优化
comments: false
---

# 题目

## Assignment1

### Problem1

由于$A$是可逆的, 因为它的行列式$\det{A}=1-6\neq 0$, 不等于0, 所以是可逆的, 所以$A$是可逆的, 所以对于任何$b$, 我们都能求解出$x = A^{-1}b$, 所以$P_b\neq \emptyset$就等于$A^{-1}b\geq 0$. 这个时候, 我们把$b$看作是一个变量, 那么它满足一系列的线性约束, 所以$Q$是一个多面体.

$A$的逆可以通过高斯-若尔当消元法求出. 具体来说, 在矩阵$A$的右侧放一个同等大小的单位矩阵$I$, 形成$[A|I]$. 然后进行初等行变换: 交换任意两行; 将某一行的元素乘以一个非零常数; 将某一行的倍数加到另一行上; 直到左侧变为$I$, 右侧就是$A$的逆. 求得了逆之后, 然后和$b$这个列向量相乘, 就得到了两个约束条件, 得到了explit linear formulation. 

### Problem2

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

### Problem3

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

## Assignment2

### Problem1

因为原始问题为minimize所以对偶问题为maximize, $s$这个变量可以消去, 变为$Ax>=b$, 所以对偶问题中变量的符号为$>=$; 由于$x$为free, 所以对偶问题中的约束符号为$=$, $cx$变为$by$, $Ax>=b$变为$A^Ty=c, y>=0$.  

所以, 问题的对偶形式为maximize $by$, subject to $A^Ty=c$, $y\geq 0$. 

强对偶定理的意思是说原始问题(LP)和他的对偶问题(DL)的最优解是相同的. 这里我们用了一个巧妙的方式, 将(LP)中的$x$替换为$-x$, 令$\tilde{x}=-x$. 原始问题变成了maximize $c\tilde{x}$. subject to $\tilde{x}$ free, $A\tilde{x}\leq -b$, 我们将这个定义为(LP'), (LP)和(LP')的最优解是一样的, 因为他们是完全相同的问题. 我们在求(LP')的dual, minimize $-b\tilde{y}$, subject to $\bar{y}\geq 0$, $A^T\tilde{y} = c$, 记为(DP'). 根据强对偶定理, (LP')和(DP')的最优解是一样的, 所以(LP)和(DP')的最优解是一样的. 这个时候, 我们发现(DL)和(DP')其实是同一个问题, 所以(DL)和(DP')的最优解是一样的 , 所以(LP)和(DL)的最优解是一样的, 所以符合强对偶定理. 

## Practice Final Exam

| 原始问题(Minimize) | $\rightarrow$ | 对偶问题(Maximize) |
| :--- | :---: | :--- |
| **目标函数** | | **目标函数** |
| Minimize $c^T x$ | $\rightarrow$ | Maximize $b^T y$ |
| **原始约束($i$)** | | **对偶变量($y_i$)** |
| $\ge b_i$ | $\rightarrow$ | $\ge 0$ |
| $\le b_i$ | $\rightarrow$ | $\le 0$ |
| $= b_i$ | $\rightarrow$ | free(无限制) |
| **原始变量($x_j$)** | | **对偶约束($j$)** |
| $\ge 0$ | $\rightarrow$ | $\le c_j$ |
| $\le 0$ | $\rightarrow$ | $\ge c_j$ |
| free(无限制) | $\rightarrow$ | $= c_j$ |

| 原始问题(Maximize) | $\rightarrow$ | 对偶问题(Minimize) |
| :--- | :---: | :--- |
| **目标函数** | | **目标函数** |
| Maximize $c^T x$ | $\rightarrow$ | Minimize $b^T y$ |
| **原始约束($i$)** | | **对偶变量($y_i$)** |
| $\le b_i$ | $\rightarrow$ | $\ge 0$ |
| $\ge b_i$ | $\rightarrow$ | $\le 0$ |
| $= b_i$ | $\rightarrow$ | free(无限制) |
| **原始变量($x_j$)** | | **对偶约束($j$)** |
| $\ge 0$ | $\rightarrow$ | $\ge c_j$ |
| $\le 0$ | $\rightarrow$ | $\le c_j$ |
| free(无限制) | $\rightarrow$ | $= c_j$ |

!!! tip "free变量怎么办"

    注意, 出现free的话, 我们要使用两个非负的变量去替换掉对应的变量, 如, 我们可以把$x_2$替换为$u$和$v$: $x_2 = u-v$. 将这个带入到原始问题, 变成了: 

    minimize $2x_1-3(u-v)$, subject to $x_1-2u+2v\geq 7$, $2x_1+4u-4v\geq 1$. $x_1\geq 0$, $u\geq 0$, $v\geq 0$.  

    现在我们对这个新的, 有三个变量$x_1, u, v$的问题求对偶. 

    1. $x_1$在第一个约束中的系数是$1$, 在第二个约束中的系数是$2$, 在目标函数中的系数是$2$, 所以有$y_1+2y_2\leq 2$. 
    2. $u$在第一个约束中的系数是$-2$, 在第二个约束中的系数是$4$, 在目标函数中的系数是$-3$, 所以有$-2y_1+4y_2\leq -3$. 
    3. $v$在第一个约束中的系数是$2$, 在第二个约束中的系数是$-4$, 在目标函数中的系数是$3$, 所以有$2y_1-4y_2\leq 3$

    对于约束2和3, 我们发现, 可以推导出$-2y_1+4y_2=-3$. 
    
或者说, 由于$x_2$是free, 所以对应约束的符号是$=$. 

对于目标函数, 应该为maximize $7y_1+y_2$. 对于变量的符号, 由于约束的符号是$\geq$, 所以变量得符号也是$\geq$, $y_1\geq 0$, $y_2\geq 0$. 

### Problem2

题目应该是让我们解决一个最大流问题. $\mathcal{P}$是路径的集合, $P$是一条具体的路径, $x_P$表示的是是否选中这条路径. 我们的目标是在这个大集合$\mathcal{P}$中找到最大数量的没有重叠边的路径. 

我们要最大化的就是路径数量, 所以是$\sum_{P\in \mathcal{P}} x_P$, 由于不能有重叠, 所以对于任何一条边$e$, 不能存在于超过一个的路径中, 有$\sum_{P\in \mathcal{P}: e\in P} x_P\leq 1, \forall e\in E$. 

a) 首先, 我们来推导他的对偶问题, minimize $\sum_{e\in E} y_e$, subject to $y_e\geq 0, \forall e\in E$, $\sum_{e\in P}y_e\geq 1, \forall P\in \mathcal{P}$. 这其实就是最小割问题, 意思是说, 对于从$s$到$t$所有可能的路径, 每一条路径都必须被切断至少一次. $y_e$表示是否切断边$e$. $\sum_{e\in P}y_e\geq 1$表示对于路径$P$, 至少存在一条边$e$把他切断. 目标是最小化所有被切断的边的总数, 即用最小的代价, 使得$s$无法到达$t$.  

b) 由于该对偶问题的约束条件很多, 所以属于大规模优化问题, 具有指数级别的约束, 所以我们可以使用约束延迟生成算法. 先求出一个解, 然后使用separation oracle快速验证这个解是否正确, 如不正确, 找出反例. 那么这个问题其实就是课上讲的全局最小割问题, 我们要找到最小的隔边, 使得$s$无法到达$t$, 那么解决全局最小割问题, 我们常用的是Dijkstra算法. 首先, 我们会验证解$x$的非负性. 然后, 我们使用Dijkstra算法找到$s$到$t$的最小$\sum y_e$, 如果最小路径大于等于1, 说明是可行的; 如果最小路径小于1, 说明是不可行的. 这里的Dijkstra找出的其实不是路径长度, 而是一种路径是否被切掉的总的概率. 

### Problem4

我们先来看一下什么是submodular, 其实就是边际递减效应, 对于$A\subset B$, $f(A+x)-f(A)>f(B+x)-f(B)$. 

这道题考察的是次模性在复合函数下的性质保持问题. 简单来说, 如果对次模函数取对数, 那么它还是次模的吗? 如果对次模函数取指数, 那么它函数次模的吗? 

a) 我们通过边际效应递减来证明, 我们要证明对于$A\subseteq B$, 有$g(A\cup \{x\})-g(A)\geq g(B\cup \{x\})-g(B)$. 写出表达式, $g(S\cup \{x\})-g(S) = \log(f(S\cup \{x\}))-\log(f(S)) = \log(\frac{f(S\cup \{x\})}{f(S)})$, 我们令$f(S\cup \{x\}) = f(S) + \Delta$, 代入, 有$\log(1+\frac{\Delta}{f(S)})$. 那么, 我们实际上要比较的是$\frac{\Delta}{f(S)}$ , 也就是比较$\frac{\Delta_A}{f(A)}$和$\frac{\Delta_B}{f(B)}$. 由于$f$是递增的, 所以$f(B)\geq f(A)$, 因为$f$是次模的, 所以$\Delta_A\geq \Delta_B$, 所以$\frac{\Delta_B}{f(B)}$更小, 所以有$g(A\cup \{x\})-g(A)\geq g(B\cup \{x\})-g(B)$, 所以g满足边际效应递减, 所以g是次模函数. 

b) 其实很简单, 随便举一个反例就行了. 例如, 设$f(S) = |S|$, $|S|$是集合元素的个数, 构造集合$A=\{1\}$, $B = \{1, 2\}$, 所以$f(A) = 1$, $f(B) = 2$, $g(A) = 2, g(B) = 4$. 现在新加入一个元素, $f(A\cup x) = 2, f(B\cup x) = 3$, $g(A\cup x) = 4, g(B\cup x) = 9$. $f(A\cup x) - f(A) = 1, f(B\cup x)-f(B) = 1$, 符合次模性, 但是$g(A\cup x)- g(A) = 2<g(B\cup x) - g(B) = 5$, 所以不符合次模性. 
