---
title: PyTorch尝试进阶
comments: true
---

## Tensor的创建

1. 从py数组创建: `torch.Tensor([[1, 2], [3, 4]])`
2. 从形状初始化当前内存中的值: `torch.Tensor(2, 3)`
3. 从形状创建全是1的tensor: `torch.ones(2, 2)`
4. 从形状创建对角线是1的tensor: `torch.eye(2, 2)`
5. 从形状创建全是0的tensor: `torch.zeros(2, 2)`
6. 创建一个和b形状相同, 但是全是0的tensor: `torch.zeros_like(b)`
7. 创建一个和b形状相同, 但是全是1的tensor: `torch.ones_like(b)`
8. 从形状创建一个随机的tensor: `torch.rand(2, 2)`
9. 从形状创建一个符合标准正态分布的tensor: `torch.normal(mean=0.0, std=1.0)`
10. 从形状创建一个符合每个数符合各自正态分布的tensor: `torch.normal(mean=0.0, std=torch.rand(5))`第一个数是从均值为0, 方差为`torch.rand(5)`的第一个数字的正态分布中采样得到的, 以此类推... `torch.normal(mean=torch.rand(5), std=torch.rand(5))`第一个数是从均值为上一个`torch.rand(5)`的第一个数字, 方差为下一个`torch.rand(5)`的第一个数字的正态分布中采样得到的, 以此类推...
11. 从形状创建一个符合均匀分布的tensor: `torch.Tensor(2, 2).uniform(-1, 1)`
12. 创建一个有步长的序列: `torch.arange(0, 11, 2)`
13. 创建一个等间隔的序列: `torch.linspace(2, 10, 3)`
14. 创建一个打乱的序列: `torch.randperm(10)`

## Tensor的属性

每一个Tensor有`torch.dtype`, `torch.device`, `torch.layout`三种属性. `torch.device`标识了`torch.Tensor`对象在创建之后所存储的设备名称. `torch.layout`表示`torch.Tensor`内存布局的对象. 常见的内存布局为`torch.strided`, 用于稠密张量, 其数据在内存中按照连续的存储顺序排列; 而对于稀疏张量, 常用的是`torch.sparse_coo`等布局, 这类布局只存储非零元素及其对应的索引, 从而节省内存, 节省计算(0乘以任何数都是0).

```py
dev_0 = torch.device("cuda:0")  # 第一块显卡
a = torch.tensor([1, 2, 3], dtype=torch.float32, device=dev_0)
```

```py
indices = torch.tensor([[0, 1, 1], [2, 0, 2]])  # 定义非零元素的坐标
values = torch.tensor([3, 4, 5], dtype=torch.float32)  # 定义非零元素的值
x = torch.sparse_coo_tensor(indices, values, [2, 4])  # 输入非零元素的坐标, 非零元素的值, 以及tensor的形状
x = x.to_dense()  # 将其转换为一个稠密的张量
```

## Tensor的算术运算

1. 加法

    ```py
    c = a + b
    c = torch.add(a, b)
    c = a.add(b)
    a.add_(b)  # 执行过后, a会自动变成a+b的值, 也就是等价于a=a+b
    ```

2. 减法

    ```py
    c = a - b
    c = torch.sub(a, b)
    c = a.sub(b)
    a.sub_(b)  # 执行过后, a会自动变成a-b的值, 也就是等价于a=a-b
    ```

3. 哈达玛积(element wise)

    ```py
    c = a * b
    c = torch.mul(a, b)
    c = a.mul(b)
    a.mul_(b)  # 执行过后, a会自动变成a*b的值, 也就是等价于a=a*b
    ```

4. 除法运算

    ```py
    c = a / b
    c = torch.div(a, b)
    c = a.div(b)
    a.div_(b)  # 执行过后, a会自动变成a/b的值, 也就是等价于a=a/b
    ```

5. 矩阵运算

    ```py
    c = torch.mm(a, b)
    c = torch.matmul(a, b)
    c = a @ b
    c = a.matmul(b)
    c = a.mm(b)
    ```

    ???+ tip "高维tensor的乘法"

        对于高维的tensor(dim>2), 定义其矩阵乘法仅仅在最后的两个维度上, 要求前面的维度必须保持一直, 就像矩阵的索引一样并且运算操作符只有`torch.matmul()`.

        ```py
        a = torch.ones(1, 2, 3, 4)
        b = torch.ones(1, 2, 4, 3)
        print(a.matmul(b))
        print(torch.matmul(a, b))
        ```

6. 幂运算

    ```py
    c = torch.pow(a, 2)
    c = a.pow(2)
    c = a ** 2
    a.pow_(2)  # 执行过后, a会自动变成a**2的值, 也就是等价于a=a**2
    c = torch.exp(a)
    a.exp_()  # 执行过后, a会自动变成e**a的值, 也就是等价于a=e**a
    ```

7. 开方运算

    ```py
    c = a.sqrt()
    a.sqrt_()  # 执行过后, a会自动变成a.sqrt的值, 也就是等价于a=a.sqrt()
    ```

8. 对数运算

    ```py
    c = torch.log2(a)
    c = torch.log10(a)
    c = torch.log(a)  # 底数为e
    torch.log_(a)  # 执行过后, a会自动变成torch.log(a)的值, 也就是等价于a=torch.log(a)
    ```

## in-place操作

in-place操作, 又叫做原位操作, "就地"操作, 即完成运算后不使用另一个变量来存储. 可以使用在操作符之后加一个下划线实现.

## 广播机制

tensor参数可以自动扩展为相同的大小. 广播机制需要满足两个条件: 每个张量至少有一个维度, 满足右对齐. 什么是右对齐, 例如`torch.rand(2, 1, 1)+torch.rand(3)`, 右边的可以看作是`torch.rand(1, 1, 3)`, 满足右对齐的条件是, 从右到左, 每个维度上要么是相等的, 要么至少有一个`1`, 比如, 最右边是`1`和`3`, 有一个`1`, 中间是`1`和`1`, 有两个`1`, 左边是`2`和`1`, 有一个`1`, 因此是右对齐的. 更多细节可以参考NumPy的广播机制: /language/python/numpy/broadcast/.

```py
a = torch.rand(2, 3)
b = torch.rand(2)
# c = a + b, 会报错, 因为a和b不是右对齐的
```

## Tensor的取整/取余运算

* `.floor()`: 向下取整数
* `.ceil()`: 向上取整数
* `.round()`: 四舍五入 >= 0.5向上取整, < 0.5向下取整
* `.trunc()`: 裁剪, 只取整数部分
* `.frac()`: 只取小数部分
* `%`: 取余

## Tensor的比较运算

???+ note "`out`的含义"

    `out=None`表示该操作不会直接将结果存储到一个指定的输出张良中, 默认情况下, `out=None`意味着`torch.eq`会返回一个新的张量作为结果, 而不会修改原始数据.

* `torch.eq(input, output, out=None)`: 返回的结果是一个tensor, 表示input, output逐元素比较的结果
* `torch.equal(tensor1, tensor2)`: 如果`tensor1`和`tensor2`有相同的size和elements, 则为`true`
* `torch.ge(input, other, out=None)`: input >= other
* `torch.gt(input, other, out=None)`: input > other
* `torch.le(input, other, out=None)`: input =< other
* `torch.lt(input, other, out=None)`: input < other
* `torch.ne(input, other, out=None)`: input != other

```py
a = torch.ones(2, 3)
b = torch.rand(2, 3)
torch.eq(a, b)  # 返回: tensor([[False, False, False], [False, True, False]])
torch.equal(a, b)  # 返回: False
```

```py
a = torch.tensor([1, 4, 4, 3, 5])
torch.sort(a)  # torch.return_types.sort( values=tensor([1, 3, 4, 4, 5]), indices=tensor([0, 3, 1, 2, 4]))
b = torch.tensor([[1, 4, 4, 3, 5], [2, 3, 1, 3, 5]])
torch.sort(b, dim=0, descending=True)  # torch.return_types.sort( values=tensor([[2, 4, 4, 3, 5], [1, 3, 1, 3, 5]]), indices=tensor([[1, 0, 0, 0, 0], [0, 1, 1, 1, 1]]))
```

## Tensor取前k大/前k小/第k小的数值及其索引

* `torch.sort(input, dim=None, descending=False, out=None)`: 对目标`input`进行排序
* `torch.topk(input, k, dim=None, largest=True, sorted=True)`: 沿着指定维度返回最大k个数值及其索引值
* `torch.kthvalue(input, k, dim=None, out=None)`: 沿着指定维度返回第k个最小值及其索引值

```py
a = torch.tensor([[2, 4, 3, 1, 5], [2, 3, 5, 1, 4]])
torch.topk(a, k=1, dim=0)  # torch.return_types.topk( values=tensor([[2, 4, 5, 1, 5]]), indices=tensor([[0, 0, 1, 0, 0]]))
torch.kthvalue(a, k=2, dim=0)  # torch.return_types.kthvalue( values=tensor([2, 4, 5, 1, 5]), indices=tensor([1, 0, 1, 1, 0]))
torch.kthvalue(a, k=2, dim=1)  # torch.return_types.kthvalue( values=tensor([2, 2]), indices=tensor([0, 0]))
```

## Tensor判定是否为finite/inf/nan

* `torch.isfinite(tensor)`: 判断是否有界
* `torch.isinf(tensor)`: 判断是否无界
* `torch.isnan(tensor)`: 判断是否含有nan

会返回一个标记元素是否为finite/inf/nan的mask张量.

```py
a = torch.rand(2, 3)
torch.isfinite(a)  # tensor([[True, True, True], [True, True, True]])
torch.isfinite(a/0)  # tensor([[False, False, False], [False, False, False]])
torch.isinf(a/0)  # tensor([[True, True, True], [True, True, True]])
torch.isnan(a)  # tensor([[False, False, False], [False, False, False]])
```

## Tensor的三角函数

- `torch.abs(input, out=None)`
- `torch.acos(input, out=None)`
- `torch.asin(input, out=None)`
- `torch.atan(input, out=None)`
- `torch.atan2(input, input2, out=None)`
- `torch.cos(input, out=None)`
- `torch.cosh(input, out=None)`
- `torch.sin(input, out=None)`
- `torch.sinh(input, out=None)`
- `torch.tan(input, out=None)`
- `torch.tanh(input, out=None)`

## Tensor中其他的数学函数

- `torch.abs()`
- `torch.erf()`: 计算误差函数, 误差函数是一种特殊的函数, 用于描述正态分布中误差的分布情况
- `torch.erfinv()`: 计算误差函数的反函数
- `torch.sigmoid()`: 计算Sigmoid函数
- `torch.neg()`: 计算输入张量每个元素的相反数
- `torch.reciprocal()`: 计算输入张量每个元素的倒数, 对于零元素, 结果会是无穷大
- `torch.rsqrt()`: 计算输入张量每个元素的平方根的倒数
- `torch.sign()`: 计算输入张量每个元素的符号
- `torch.lerp(start, end, weight)`: 执行线性插值, 根据给定的权重在两个张量之间进行插值
- `torch.addcdiv(tensor1, tensor2, value)`: 将tensor1和tensor2的元素按照元素相除, 然后乘以value加到tensor1上
- `torch.addcmul(tensor1, tensor2, value)`: 将tensor1和tensor2的元素按照元素相乘, 然后乘以value加到tensor1上
- `torch.cumprod()`: 计算输入张量沿着特定维度的累积乘积, 返回一个新的张量, 其中每个位置的值是从开始到该位置的所有元素乘积
- `torch.cumsum()`: 计算输入张量沿着指定维度的累积和, 返回一个新的张量, 其中每个位置的值从开始到该位置的所有元素和

```py
a = torch.rand(2, 3)  # tensor([[0.4863, 0.0496, 0.7216], [0.0850, 0.8989, 0.0389]])
torch.cumsum(a, dim=0)  # tensor([[0.4863, 0.0496, 0.7216], [0.5712, 0.9484, 0.7605]])
torch.cumprod(a, dim-0)  # tensor([[0.4863, 0.0496, 0.7216], [0.0413, 0.0446, 0.0280]])
```

## Tensor中统计学相关的函数

好的，这是从图像中提取的PyTorch函数的Markdown列表：

* `torch.mean()`：返回平均值
* `torch.sum()`：返回总和
* `torch.prod()`：计算所有元素的积
* `torch.max()`：返回最大值
* `torch.min()`：返回最小值
* `torch.argmax()`：返回最大值排序的索引值
* `torch.argmin()`：返回最小值排序的索引值
* `torch.std()`: 返回标准差
* `torch.var()`: 返回方差
* `torch.median()`: 返回中间值
* `torch.mode()`: 返回众数值
* `torch.histc()`: 计算input的直方图
* `torch.bincount()`: 返回每个值的频数, 专门用于统计非负整数张量中各个整数值出现的次数

```py
a = torch.rand(2, 3)  # tensor([[0.8399, 0.2825, 0.8222], [0.9138, 0.4965, 0.4298]])
torch.mean(a)  # tensor(0.6308)
torch.sum(a)  # tensor(3.7847)
torch.prod(a)  # tensor(0.0380)
torch.mean(a, dim=0)  # tensor([1.7537, 0.7790, 1.2520])
torch.sum(a, dim=0)  # tensor([1.7537, 0.7790, 1.2520])
torch.prod(a, dim=0)  # tensor([0.7675, 0.1403, 0.3534])
torch.mean(a, dim=1)  # tensor([0.6482, 0.6134])
torch.argmax(a, dim=0)  # tensor([1, 1, 0])
torch.argmax(a)  # tensor(3)
torch.std(a)  # tensor(0.2609)
torch.var(a)  # tensor(0.0680)
torch.var(a, dim=1)  # tensor([0.1004, 0.0688])
torch.median(a) # tensor(0.4965)
torch.mode(a)  # torch.return_types.mode( values=tensor([0.2825, 0.4298]), indices=tensor([1, 2]))
b = torch.rand(2, 2) * 10  # tensor([[5.0213, 2.0063], [9.1573, 8.1224]])
torch.histc(b, 6, 0, 0)  # tensor([1., 0., 1., 0., 0., 2.]), 数据被划分为了6个bin, 其中有2个落到了最大bin, 一个落到了最小bin, 1个落到了中间bin
c = torch.randint(0, 10, [10])  # 第一个参数0表示下届, 第二个参数10表示上界, 第三个参数[10]指定输出张量的形状, 即包含10个元素的一维张量, tensor([4, 8, 0, 6, 6, 6, 0, 1, 2, 0])
torch.bincount(c)  # tensor([3, 1, 1, 0, 1, 0, 3, 0, 1]), 可以同济某一类别样本的个数
```

## Tensor的`torch.distributions`

`torch.distribution`包含可参数化的概率分布和采样函数, 方便在深度学习中进行概率计算和采样. 例如, 该模块中实现了Normal, Bernouli, Categorical, Multinomial等概率分类, 每个分布都提供了sample, log_prob, entropy等常用方法. 此外, torch.distributions还支持了分布之间的组合和变换, 这使得构建复杂的概率模型变得更加容易. 此外, 它还提供了`kl_divergence(p, q)`函数, 可用于计算两个分布之间的KL散度.

## Tensor中的随机抽样

定义随机种子: `torch.manual_seed(seed)`.  它用于设置随机数生成器的种子值, 确保随机操作(如随机抽样, 权重初始化等)在每次运行的时候生成相同的随机数序列, 从而使实验结果具有可重复性. 例如, 对tensor进行随机抽样的时候, 如果先调用`torch.manual_seed(seed)`并传入相同的seed值, 则每次抽样得到的结果都是一致的, 这对于调试和验证模型表现非常有用. 可以进一步的定义随机数满足的分布. 比如`torch.normal()`是用于生成符合正态分布(高斯分布)随机数的函数. 其核心思想是根据给定的均值和标准差, 在指定的张量形状上生成元素值服从N(mean, std^2)分布的随机数.

```py
torch.manual_seed(1)
mean = torch.rand(1, 2)
std = torch.rand(1, 2)
torch.normal(mean, std)  # tensor([[0.7825, 0.7358]]), 因为定义了随机种子, 所以这个值应该是不会变的
```

## Tensor中的范数运算

范数(Norm)是数学中用于度量向量或者张量长度(或大小)的一种函数. 给定一个向量或者张量, 范数会映射到一个非负实数, 用来描述该向量或者张量的长度. 例如, 对于一个向量, 常见的向量范数包括: $L^1$范数(曼哈顿距离), $L^2$范数(欧几里得距离), $L^{\infty}$范数(最大范数)...

在PyTorch中, `torch.norm()`和`torch.dist()`都涉及范数的计算, 但是他们的用途有所不同. `torch.norm()`用于计算单个张量的范数. 例如, `torch.norm(x, p=2)`会计算张量`x`的2范数(默认为欧几里得范数), 这个函数用于衡量一个张量的大小或者长度. `torch.dist()`用于计算两个张量之间的距离. 它的实现实际上就是先计算两个张量的差, 再对这个差值计算范数, 即`torch.dist(x, y, p)`等价于`torch.norm(x-y, p)`. 因此, 如果你需要衡量两个张量之间的差异或者距离, 可以直接使用`torch.dist()`.

```py
a = torch.rand(1, 1)
b = torch.rand(1, 1)
torch.dist(a, b, p=1)  # 计算 L^1 距离
torch.dist(a, b, p=2)  # 计算 L^2 距离
```

上面代码中, 由于`a`和`b`是单个数值, 所以不论使用`p=1`或者`p=2`, 其结果都是相同的.

## Tensor中的矩阵分解

下面是一些常见的矩阵分解方法:

* LU分解: 将一个矩阵$\textbf{A}$分解为一个下三角矩阵$\textbf{L}$和一个上三角矩阵$\textbf{U}$的乘积.
* QR分解: 将一个矩阵$\textbf{A}$分解为一个正交矩阵$\textbf{Q}$和一个上三角矩阵$\textbf{R}$的乘积.
* EVD分解: 也称为特征值分解, 将一个可对角化的矩阵$\textbf{A}$分解为$\textbf{A}=\textbf{P}\times \bm{\Lambda}\times \textbf{P}^{-1}$, 其中, $\bm{\Lambda}$是对角矩阵, $\textbf{P}$的列向量为特征向量, 和这个相关的机器学习算法是PCA, PCA请参考[这里](/algorithm/dimensional-reduction). PCA算法的优化目标是降维之后同一维度的方差最大, 不同维度之间的相关性是0.

    特征值分解就是将矩阵分解为由其特征值和特征向量表示的矩阵之积的方法, $\textbf{A} \bm{v}=\lambda \bm{v}$, 其中, $\bm{v}$是特征向量, $\lambda$是特征值.

    ???+ tip "奇异矩阵, 满秩, 行列式和逆矩阵的关系"

        当行列式不等于0的时候, 说明矩阵的行和列之间线性无关, 因此该矩阵是满秩的, 并且存在唯一的逆矩阵, 称为非奇异矩阵; 只当行列式等于0的时候, 矩阵才是奇异矩阵, 此时行和列之间存在一种线性相关性, 导致矩阵没有逆矩阵. 只有满秩的方阵才存在逆矩阵. 对于一个n阶方阵, 若其秩等于n, 则行列式不等于0, 满足存在唯一逆矩阵的条件; 反之, 若矩阵不满秩, 则必有行列式为0, 从而没有逆矩阵.

    ???+ note "PCA的过程复习"

        在PCA算法中, 协方差矩阵用于衡量各个特征之间的相关性, 并为寻找数据中主要变化方向提供依据, 具体过程如下:

        1. 先对数据进行中心化处理, 即每个特征减去其均值
        2. 利用中心化之后的数据计算协方差矩阵, 其中每个元素表示两个特征之间的协方差
        3. 对协方差矩阵进行特征值分解, 得到一组特征值和对应的特征向量, 特征值的大小反映了特征向量方向上的数据方差
        4. 选择具有最大特征值的特征向量, 作为数据的主成分, 从而确定数据中方差最大的方向
        5. 将原始数据投影到这些主成分上, 实现降维和数据重构

* SVD分解: 将任意$m\times n$矩阵$\textbf{A}$分解为$\textbf{A}=\textbf{U}\times \bm{\Sigma}\times \textbf{V}^T$, 其中$\textbf{U}$和$\textbf{V}$分别是正交矩阵, $\bm{\Sigma}$是非负的对角矩阵(奇异值均在对角线), 和这个相关的机器学习算法是LDA.

    LDA的基本思想是利用类别信息, 通过构造类内散度矩阵和类间散度矩阵, 寻找最佳的线性变换, 使得数据投影到低维空间后, 不同类别之间的距离尽可能大, 同一类别内的样本尽可能紧凑. 具体来说, LDA的目标是最大化类间散度和类内散度的比值, 从而得到最优的投影向量. 这种方法在降维的同时保留了判别信息, 有助于提高后续分类器的性能.

???+ note "PCA和LDA的区别图例"

    <figure markdown='1'>
    ![](https://img.ricolxwz.asia/0b2064409573b415daa687b04e429fcf.webp#only-light){ loading=lazy width='800' }
    ![](https://img.ricolxwz.asia/0b2064409573b415daa687b04e429fcf_inverted.webp#only-dark){ loading=lazy width='800' }
    <figcaption></figcaption>
    </figure>
