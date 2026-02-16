---
title: 代码
comments: false
---

## 回溯

### 子集型回溯

#### [78.子集](https://leetcode.cn/problems/subsets/?envType=study-plan-v2&envId=top-100-liked)

子集型回溯对应的是: **每个元素都可以选或者不选**.

* 枚举选哪个写法:

    枚举子集(答案)的第一个数选谁, 第二个数选谁, 第三个数选谁, 依次类推... `i`表示现在要枚举`nums[i]`到`nums[n-1]`中的一个数, 添加到`path`末尾. 如果选`nums[j]`添加到`path`末尾, 那么下一个要添加到`path`末尾的数, 就要在`nums[j+1]`到`nums[n-1]`中枚举了.

    注意, 不需要在回溯中处理`i==n`的边界情况, 因为此时不会进入循环, 会直接`return`, 所以`if i==n: return`不用写.

    ```py
    class Solution:
        def subsets(self, nums: List[int]) -> List[List[int]]:
            res = []
            path = []
            n = len(nums)

            def dfs(i):
                res.append(path[:])
                for j in range(i, n):
                    path.append(nums[j])
                    dfs(j + 1)
                    path.pop()

            dfs(0)
            return res
    ```

* 选/不选写法:

    对于输入的`nums`, 考虑每个`nums[i]`是选还是不选.

    ```py
    class Solution:
        def subsets(self, nums: List[int]) -> List[List[int]]:
            res = []
            path = []
            n = len(nums)

            def dfs(i):
                if i == n:
                    res.append(path[:])
                    return
                # 不选nums[i]
                dfs(i + 1)
                # 选nums[i]
                path.append(nums[i])
                dfs(i + 1)
                path.pop()

            dfs(0)
            return res
    ```

    每个`i`上都要二叉判断选/不选, 所以总共有`2^n`中选择. 或者说有`2^n`个叶子, 在每个叶子碰到边界要复制路径为`O(n)`. 所以时间复杂度为`O(n*2^n)`.

#### [131.分割回文串](https://leetcode.cn/problems/palindrome-partitioning/?envType=study-plan-v2&envId=top-100-liked)

* 换一个视角, 假设每两个字符之间都有一个逗号, 我们可以选它或者不选它, 这就是一个子集型回溯问题.

    ```py
    class Solution:
        def partition(self, s: str) -> List[List[str]]:
            res = []
            path = []
            n = len(s)
            def dfs(i):
                if i == n:
                    res.append(path[:])
                    return
                for j in range(i, n):
                    t = s[i:j+1]  # i是上一次选中的位置, j是这一次选中的位置, 中间的就是截的字符串
                    if t == t[::-1]:
                        path.append(t)
                        dfs(j+1)
                        path.pop()
            dfs(0)
            return res
    ```

    ```py
    class Solution:
        def partition(self, s: str) -> List[List[str]]:
            res = []
            path = []
            n = len(s)
            def dfs(i, start):
                if i == n:
                    res.append(path[:])
                    return
                if i < n - 1:
                    dfs(i+1, start)
                t = s[start:i+1]  # start用于记录上一次选中的位置
                if t == t[::-1]:
                    path.append(t)
                    dfs(i+1, i+1)  # start赋值为i+1, 作为下一次选中的起点
                    path.pop()
            dfs(0, 0)
            return res
    ```

### 组合型回溯

#### [77.组合](https://leetcode.cn/problems/combinations/description/)

组合型回溯其实是子集型回溯的一种特殊情况. 子集回溯需要所有规模的集合, 组合回溯需要满足某个约束的集合. 子集回溯自然结束, 组合回溯满足条件就停, 可以剪枝.

* 选/不选写法

    ```py
    class Solution:
        def combine(self, n: int, k: int) -> List[List[int]]:
            res = []
            path = []
            def bt(i):
                if len(path) == k:  # 返回满足约束的集合
                    res.append(path[:])
                    return
                if i == n + 1:  # 剪枝
                    return
                bt(i+1)
                path.append(i)
                bt(i+1)
                path.pop()
            bt(1)
            return res
    ```

* 枚举选哪个写法

    ```py
    class Solution:
    def combine(self, n: int, k: int) -> List[List[int]]:
        res = []
        path = []
        def bt(i):
            if len(path) == k:  # 返回满足约束的集合
                res.append(path[:])
                return
            for j in range(i, n-(k-len(path))+2):  # 剪枝
                path.append(j)
                bt(j+1)
                path.pop()
        bt(1)
        return res
    ```

### 排序型回溯

#### [46.全排列](https://leetcode.cn/problems/permutations/?envType=study-plan-v2&envId=top-100-liked)

排序型回溯就不是选/不选了, 是都要选, 但是顺序不同.

```py
class Solution:
    def permute(self, nums: List[int]) -> List[List[int]]:
        res = []
        path = []
        used = [False] * len(nums)

        def dfs(i):
            if i == len(nums):
                res.append(path[:])
                return
            for j in range(len(nums)):
                if used[j] == True:
                    continue
                used[j] = True
                path.append(nums[j])
                dfs(i+1)
                path.pop()
                used[j] = False
        dfs(0)
        return res
```

`i`: 当前要填的是排列的第`i`个位置(递归深度), `j`: 遍历`nums[0..n-1]`的下标, 尝试把还没用过的`nums[j]`放到当前位置. 如果`i==n`, 那么在回溯的时候, 会把路径上的`j`都置为`False`.

## 二分查找

### [35.搜索插入位置](https://leetcode.cn/problems/search-insert-position/?envType=study-plan-v2&envId=top-100-liked)

下面是闭区间写法. 为什么不找到`target`就立刻返回, 是因为这种写法的适用范围比较窄, 为什么返回第一个等于`target`的数的下表更好呢? 因为这可以解决更加复杂的题目, 比如给你一个有序数组, 让你计算有多少个数字小于`target`.

```py
class Solution:
    def searchInsert(self, nums: List[int], target: int) -> int:
        left, right = 0, len(nums) - 1
        while left <= right:
            mid = left + (right - left) // 2
            if nums[mid] < target:
                left = mid + 1
            else:
                right = mid - 1
        return left
```

如果`target`存在, 则`left`停在第一个`target`的位置; 如果不存在, 则`left`停在第一个大于`target`的位置(有可能越界, 这是需要处理的)

### [74.搜索二维矩阵](https://leetcode.cn/problems/search-a-2d-matrix/description/?envType=study-plan-v2&envId=top-100-liked)

这道题里面的二维矩阵展平了之后其实就是一个一维数组, 所以可以使用一维数组的思维来解决这道题.

```py
class Solution:
    def searchMatrix(self, matrix: List[List[int]], target: int) -> bool:
        m, n = len(matrix), len(matrix[0])
        left, right = 0, m * n - 1
        while left <= right:
            mid = left + (right - left) // 2
            if matrix[mid // n][mid % n] < target:
                left = mid + 1
            else:
                right = mid - 1
        if left == m * n or matrix[left // n][left % n] != target:
            return False
        else:
            return True
```

`if left == m * n or matrix[left // n][left % n] != target:`这一行表示无法找到`target`, 三种情况, 所有元素都大于`target`, 对应`left == m * n`; 所有元素都小于`target`或者在序列中找不到, 对应`matrix[left // n][left % n] != target`.

### [34.在排序数组中查找元素的第一个和最后一个位置](https://leetcode.cn/problems/find-first-and-last-position-of-element-in-sorted-array/description/?envType=study-plan-v2&envId=top-100-liked)

因为我们之前的模板找到的是`target`的第一个位置(如果存在), 所以我们如果找到的话可以直接`while`一下, 判断结束的位置.

```py
class Solution:
    def searchRange(self, nums: List[int], target: int) -> List[int]:
        left, right = 0, len(nums) - 1
        while left <= right:
            mid = left + (right - left) // 2
            if nums[mid] < target:
                left = mid + 1
            else:
                right = mid - 1
        if left == len(nums) or nums[left] != target:
            return [-1, -1]
        else:
            start = left
            while left < len(nums) and nums[left] == target:
                left += 1
            return [start, left-1]
```

### [33.搜索旋转排序数组](https://leetcode.cn/problems/search-in-rotated-sorted-array/description/?envType=study-plan-v2&envId=top-100-liked)

旋转数组本来是整体递增的, 只是某个位置断开之后拼到了后面, 对于任意区间, 总有一边是有序的. 此时有序部分使用二分法查找. 无序部分再一分为二, 其中一个一定有序, 另一个可能有序, 可能无序, 如此循环.

```py
class Solution:
    def search(self, nums: List[int], target: int) -> int:
        left, right = 0, len(nums) - 1
        while left <= right:
            mid = left + (right - left) // 2
            if nums[mid] == target:
                return mid
            if nums[left] <= nums[mid]:  # [left, mid]有序
                if target < nums[left]:  # 说明发生旋转
                    left = mid + 1
                elif target < nums[mid]:  # 常规情况
                    right = mid - 1
                else:
                    left = mid + 1  # 常规情况
            else:  # [mid, right]有序
                if target > nums[right]:  # 说明发生旋转
                    right = mid - 1
                elif target > nums[mid]:  # 常规情况
                    left = mid + 1
                else:
                    right = mid - 1  # 常规情况
        return -1
```

### [153.寻找旋转排序数组中的最小值](https://leetcode.cn/problems/find-minimum-in-rotated-sorted-array/?envType=study-plan-v2&envId=top-100-liked)

```py
class Solution:
    def findMin(self, nums: List[int]) -> int:
        left, right = 0, len(nums) - 1
        while left < right:
            mid = left + (right - left) // 2
            if nums[mid] > nums[right]:
                left = mid + 1
            else:
                right = mid
        return nums[left]
```

## 栈

### [20.有效的括号](https://leetcode.cn/problems/valid-parentheses/description/?envType=study-plan-v2&envId=top-100-liked)

这道题是经典的栈题目, 三种情况:

1. 字符串遍历完成后, 栈里面还有元素: 左括号多余
2. 遇到右括号, 取出栈顶元素发现不配对: 左右括号不配对
3. 遇到右括号, 发现栈空: 右括号多余

```py
class Solution:
    def isValid(self, s: str) -> bool:
        stack = []
        for c in s:
            if c in ["(", "[", "{"]:
                stack.append(c)
            else:
                if len(stack) == 0:
                    return False
                t = stack.pop()
                if c == ")" and t != "(" or c == "]" and t != "[" or c == "}" and t != "{":
                    return False
        if len(stack) != 0:
            return False
        return True
```

### [155.最小栈](https://leetcode.cn/problems/min-stack/?envType=study-plan-v2&envId=top-100-liked)

这道题需要一个辅助栈.

* 当一个元素要入栈的时候, 我们取当前辅助栈顶存储的最小值, 和当前元素比较得到最小值, 将这个最小值插入到辅助栈中.
* 当一个元素要出栈的时候, 我们把辅助栈的栈顶元素也一样弹出.

在任意一个时刻, 栈内元素的最小值就是存储在辅助栈的栈顶元素中.

```py
class MinStack:

    def __init__(self):
        self.stack = []
        self.min_stack = [float('inf')]

    def push(self, val: int) -> None:
        self.stack.append(val)
        if self.min_stack[-1] > val:
            self.min_stack.append(val)
        else:
            self.min_stack.append(self.min_stack[-1])

    def pop(self) -> None:
        self.stack.pop()
        self.min_stack.pop()

    def top(self) -> int:
        return self.stack[-1]

    def getMin(self) -> int:
        return self.min_stack[-1]
```

### [394.字符串解码](https://leetcode.cn/problems/decode-string/?envType=study-plan-v2&envId=top-100-liked)

这道题的复杂点在于, `s`有多种类型:

* 基础: 不含括号, 没有数字, 此时, 只包含字母, 例如`s = abc`.
* 嵌套: 结构为数字+左括号+括号中的字符串+右括号, 例如`s = 2[abc]`, `s = 2[3[ab]]`
* 组合: 多个`k[str]`并在一起, 例如`s=2[ab]3[xy]`

用栈模拟递归:

```py
class Solution:
    def decodeString(self, s: str) -> str:
        stack = []
        res = ''
        k = 0
        for c in s:
            if c.isalpha():
                res += c
            elif c.isdigit():
                k = k * 10 + int(c)
            elif c == '[':
                stack.append((res, k))
                res = ''  # 当开始[的时候, 我们需要清空res来存放此次递归的结果, 之前的结果已经被压入到stack中.
                k = 0
            else:
                pre_res, pre_k = stack.pop()
                res = pre_res + res * pre_k
        return res
```

### [739.每日温度](https://leetcode.cn/problems/daily-temperatures/?envType=study-plan-v2&envId=top-100-liked)

这道题的解法是单调栈. 维护一个从栈底到栈顶温度递减的单调栈, 当遇到比栈顶温度更高的温度的时候, 就找到了栈顶元素的答案. 弹出栈顶, 计算天数差, 直到栈为空或者栈顶温度>=当前温度. 将当前索引压入栈中.

```py
class Solution:
    def dailyTemperatures(self, temperatures: List[int]) -> List[int]:
        res = [0] * len(temperatures)
        stack = []
        for i, t in enumerate(temperatures):
            while stack and t > temperatures[stack[-1]]:
                j = stack.pop()
                res[j] = i - j
            stack.append(i)
        return res
```

## 贪心算法

贪心算法的核心思想是每一步都做出当前看起来最优的选择, 期望通过局部最优达到全局最优.

### [121.买卖股票的最佳时机](https://leetcode.cn/problems/best-time-to-buy-and-sell-stock/?envType=study-plan-v2&envId=top-100-liked)

买入日期必须在卖出日期的前面, 从`prices[0]`到`prices[i-1]`, 我们维护一个最小值`minprice`, 对于每一个`prices[i]`, 我们都计算卖出获利值`prices[i] - minprice`, 如果该值优于现有的最优值, 那么确定在这里卖出.

```py
class Solution:
    def maxProfit(self, prices: List[int]) -> int:
        res = 0
        min_price = prices[0]
        for i in range(len(prices)):
            res = max(res, prices[i] - min_price)
            min_price = min(min_price, prices[i])
        return res
```

### [55.跳跃游戏](https://leetcode.cn/problems/jump-game/?envType=study-plan-v2&envId=top-100-liked)

这道题的关键不是跳几步, 而是跳多远. 维护变量`max_reach`, 记录当前能达到的最远位置, 然后, **最关键的是, 我们只遍历可达范围内的位置`i<=max_reach`.** 随后, 更新当前可达的最远距离`max_reach = max(max_reach, i + nums[i])`, 如果`max_reach >= 数组末尾`, 返回true.

```py
class Solution:
    def canJump(self, nums: List[int]) -> bool:
        max_reach = 0
        i = 0
        while i <= max_reach:
            max_reach = max(max_reach, i + nums[i])
            if max_reach >= len(nums) - 1:
                return True
            i += 1
        return False
```

### [45.跳跃游戏 II](https://leetcode.cn/problems/jump-game-ii/description/?envType=study-plan-v2&envId=top-100-liked)

这道题比55更进一步, 需要求出到达最后一个元素的最小跳跃次数. 其核心思想是, 在当前的跳跃范围内(`i < border`), 选择让下一跳到达更远的位置, 不需要真的跳到`border`.

```py
class Solution:
    def jump(self, nums: List[int]) -> int:
        max_reach = 0
        border = 0
        steps = 0
        i = 0
        while i < len(nums) - 1:
            max_reach = max(max_reach, i + nums[i])
            if i == border:
                border = max_reach
                steps += 1
            i += 1
        return steps
```

### [763.划分字母区间](https://leetcode.cn/problems/partition-labels/?envType=study-plan-v2&envId=top-100-liked)

## 堆

### [215.数组中的第K个最大元素](https://leetcode.cn/problems/kth-largest-element-in-an-array/?envType=study-plan-v2&envId=top-100-liked)

这道题题目里面说了要求时间复杂度为`O(n)`, 但是官方题解里面用的是堆算法. 那我们就先来看一下Python的堆是怎么写的, Python的堆用的是`heapq`库, 堆顶元素是列表中的最小元素. 使用`heapq.heappush(heap, val)`将元素压入堆中, 使用`heapq.heappop(heap)`将堆顶元素弹出. 使用`heapq.heapify(heap)`将列表转换为堆. 这道题的思路就是当`heap`的大小大于`k`的时候, 弹出堆顶元素, 最后剩下的就是第`k`个最大元素.

```py
class Solution:
    def findKthLargest(self, nums: List[int], k: int) -> int:
        import heapq
        heap = []
        for num in nums:
            heapq.heappush(heap, num)
            if len(heap) > k:
                heapq.heappop(heap)
        return heap[0]
```

### [347.前K个高频元素](https://leetcode.cn/problems/top-k-frequent-elements/?envType=study-plan-v2&envId=top-100-liked)

这道题需要使用哈希表来统计每个元素出现的次数, 然后使用堆来找出前`k`个高频元素. 和215类似, 当`heap`的大小大于`k`的时候, 弹出堆顶元素. 最后剩余的就是前`k`个高频元素. 要注意, 这里我们存储的是`(val, key)`, 而不是`(key, val)`, 因为我们要按照频率排序, 而频率是第一个元素.

```py
class Solution:
    def topKFrequent(self, nums: List[int], k: int) -> List[int]:
        import heapq
        ht = dict()
        for num in nums:
            ht[num] = ht.get(num, 0) + 1
        heap = []
        for key, val in ht.items():
            heapq.heappush(heap, (val, key))
            if len(heap) > k:
                heapq.heappop(heap)
        res = []
        for item in heap:
            res.append(item[1])
        return res
```

### [295.数据流的中位数](https://leetcode.cn/problems/find-median-from-data-stream/?envType=study-plan-v2&envId=top-100-liked)

这道题用到的技术是 _对顶堆_. 用一个大顶堆+一个小顶堆, 将数据分为较小的一半和较大的一半.

* 大顶堆: 存较小的一半, 堆顶是这一半里面的最大值
* 小顶堆: 存较大的一半, 堆顶是这一半里面的最小值

约定两堆大小不能超过1, 这样中位数就是:

* 总数为奇数: 元素多的那堆为堆顶
* 总数为偶数: 两堆堆顶的平均值

要点:

* `addNum(num)`: 根据`num`和当前堆顶的关系, 决定放进哪一个堆, 必要时将一个堆的堆顶移动到另一个堆, 保持大小平衡
* `findMedian()`: 只读两个堆顶并做简单运算, 时间复杂度`O(1)`

```py
import heapq
class MedianFinder:

    def __init__(self):
        self.min_heap = []
        self.max_heap = []

    def addNum(self, num: int) -> None:
        if not self.min_heap or num >= self.min_heap[0]:
            heapq.heappush(self.min_heap, num)
        else:
            heapq.heappush(self.max_heap, -num)
        if len(self.min_heap) - len(self.max_heap) > 1:
            e = heapq.heappop(self.min_heap)
            heapq.heappush(self.max_heap, -e)
        elif len(self.max_heap) - len(self.min_heap) > 1:
            e = -heapq.heappop(self.max_heap)
            heapq.heappush(self.min_heap, e)

    def findMedian(self) -> float:
        if len(self.min_heap) > len(self.max_heap):
            return self.min_heap[0]
        elif len(self.min_heap) < len(self.max_heap):
            return -self.max_heap[0]
        else:
            return (self.min_heap[0] - self.max_heap[0]) / 2
```

## 图论

### [200.岛屿数量](https://leetcode.cn/problems/number-of-islands/?envType=study-plan-v2&envId=top-100-liked)

这道题考察的是图的DFS遍历. 网格问题是由`m*n`个小方格组成的一个网格, 每个小方格与其上下左右四个方格认为是相邻的, 要在这样的网格上进行某种搜索. 岛屿问题是一种典型的网格问题, 每个格子中的数字可能是0或者1, 我们把数字为0的格子看为是海洋格子, 数字为1的格子看为是陆地格子. 这样相邻的陆地格子就连接成一个岛屿. 在这样的设定下, 就出现了各种岛屿问题的变种, 包括数量, 面积, 周长等, 基本都可以用DFS解决.

对于网格上的DFS, 我们可以参考二叉树的DFS:

1. 首先, 网格结构中的格子有多少相邻节点可以类比于二叉树的子节点数量, 在网格中, 每个格子有4个相邻的格子. 对于格子`(i, j)`, 其上下左右的格子分别是`(i-1, j)`, `(i+1, j)`, `(i, j-1)`, `(i, j+1)`. 换句话说, 网络结构是四叉树.

    <figure markdown='1' id='fig'>
    ![](https://img.ricolxwz.cn/d058b0f5bd2ea79445b1689a4bb88dd1.webp#only-light){ loading=lazy width='600' }
    ![](https://img.ricolxwz.cn/d058b0f5bd2ea79445b1689a4bb88dd1_inverted.webp#only-dark){ loading=lazy width='600' }
    </figure>

2. 其次, DFS的Base case应该是网格中不需要继续递归, `grid[r][c]`会出现异常的格子, 也就是那些超出网格范围的格子.

    <figure markdown='1' id='fig'>
    ![](https://img.ricolxwz.cn/10aee5d759bfb2b5fecd485d28e8cb6d.webp#only-light){ loading=lazy width='600' }
    ![](https://img.ricolxwz.cn/10aee5d759bfb2b5fecd485d28e8cb6d_inverted.webp#only-dark){ loading=lazy width='600' }
    </figure>

    这一点和二叉树中是一样的, 都是"先污染, 后治理", 甭管当前是在哪个格子, 先往四个方向走一步再说, 如果发现走出了网格范围再赶紧返回.

    这样, 我们有了网格DFS的框架:

    ```py
    def dfs(grid: list[list[int]], r: int, c: int) -> None:
        # 判断 base case: 坐标 (r, c) 超出网格范围则直接返回
        if not in_area(grid, r, c):
            return
        # 访问上, 下, 左, 右四个相邻格子
        dfs(grid, r - 1, c)
        dfs(grid, r + 1, c)
        dfs(grid, r, c - 1)
        dfs(grid, r, c + 1)


    def in_area(grid: list[list[int]], r: int, c: int) -> bool:
        """判断坐标 (r, c) 是否在网格内"""
        return 0 <= r < len(grid) and 0 <= c < len(grid[0])
    ```

3. 网格结构的DFS和二叉树DFS最大的不同之处在于, 遍历中可能遇到遍历过的节点. 这个时候, DFS可能会不停的兜圈子, 永远停不下来, 如图所示.

    <figure markdown='1' id='fig'>
    ![](https://img.ricolxwz.cn/2a5682635bda405caaf0e888e2a76244.gif#only-light){ loading=lazy width='600' }
    ![](https://img.ricolxwz.cn/2a5682635bda405caaf0e888e2a76244_inverted.gif#only-dark){ loading=lazy width='600' }
    </figure>

    如何避免这样的重复遍历呢? 答案是标记已经遍历过的格子. 以岛屿问题为例, 我们需要在所有值为1的格子上做DFS遍历, 每走过一个陆地格子, 我们就把格子的值改为2, 这样我们遇到2的时候, 就知道这是遍历过的格子了, 需要终止递归, 直接返回. 每个格子可能取三个值: 0表示海洋格子, 1表示陆地格子, 2表示已遍历过的陆地格子.

    我们在框架代码中加入避免重复遍历的语句:

    ```py
    def dfs(grid: list[list[int]], r: int, c: int) -> None:
        if not in_area(grid, r, c):
            return
        if grid[r][c] != 1:
            return
        grid[r][c] = 2
        dfs(grid, r - 1, c)
        dfs(grid, r + 1, c)
        dfs(grid, r, c - 1)
        dfs(grid, r, c + 1)
    ```

    <figure markdown='1' id='fig'>
    ![](https://img.ricolxwz.cn/d2bbbca5f382c18b662915c3353dc561.gif#only-light){ loading=lazy width='600' }
    ![](https://img.ricolxwz.cn/d2bbbca5f382c18b662915c3353dc561_inverted.gif#only-dark){ loading=lazy width='600' }
    </figure>

所以, 本题的代码为:

```py
class Solution:
    def numIslands(self, grid: List[List[str]]) -> int:
        def dfs(r, c):
            if r < 0 or r >= len(grid) or c < 0 or c >= len(grid[0]):
                return
            if grid[r][c] != '1':
                return
            grid[r][c] = '2'
            dfs(r-1, c)
            dfs(r+1, c)
            dfs(r, c-1)
            dfs(r, c+1)

        res = 0
        for i in range(len(grid)):
            for j in range(len(grid[0])):
                if grid[i][j] == '1':
                    dfs(i, j)
                    res += 1
        return res
```

### [994.腐烂的橘子](https://leetcode.cn/problems/rotting-oranges/?envType=study-plan-v2&envId=top-100-liked)

不同于上一道题考察DFS, 这道题考察的是BFS.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.cn/ddf4f9777e1782890f72f265f729000d.gif#only-light){ loading=lazy width='500' }
![](https://img.ricolxwz.cn/ddf4f9777e1782890f72f265f729000d_inverted.gif#only-dark){ loading=lazy width='500' }
</figure>

BFS其实就是层序遍历, 从某个节点出发, BFS首先遍历距离为1的节点, 然后是距离为2, 3, 4的节点.  这道题要返回直到单元格中没有新鲜橘子为止必须经过的最小分钟数, 翻译一下, 实际上就是求腐烂橘子到所有新鲜橘子的最短路径.

BFS的代码框架在二叉树中就见过, 需要使用队列(注意, 这里需要`m`未被访问过是因为图和二叉树不一样, 图的节点可能会被多次访问):

```py
while queue 非空:
    node = queue.pop()
    for node 的所有相邻节点 m:
        if m 未被访问过:
            queue.push(m)
```

但是在这种框架下, 当你从队列中取出一个节点的时候, 如果你不做额外处理, 你无法从队列本身一眼看出这个节点到底是属于"距离起点1步"还是"距离起点2步"的. 所以, 我们需要稍微修改一下框架, 一次性处理完每一层的所有节点.

```py
depth = 0
while queue 非空:
    depth += 1
    n = queue 中的元素个数
    循环 n 次:
        node = queue.pop()
        for node 的所有相邻节点 m:
            if m 未被访问过:
                queue.push(m)
```

有了计算最短路径的层序BFS框架, 这道题就很简单了:

1. 一开始, 我们找出所有腐烂的橘子, 将它们放入队列, 作为第0层的节点
2. 然后进行BFS遍历, 每个节点的相邻节点可能是上, 下, 左, 右四个方向的节点, 注意判断节点位于网格边界的特殊情况
3. 由于可能存在未被污染的橘子, 我们需要记录新鲜橘子的数量, 在BFS中, 每遍历一个橘子(污染了一个橘子), 就将新鲜橘子的数量-1, 如果BFS结束之后这个数量仍然没有归0, 说明存在无法被污染的橘子.

本题的代码为:

```py
from collections import deque
class Solution:
    def orangesRotting(self, grid: List[List[int]]) -> int:
        M = len(grid)
        N = len(grid[0])
        queue = deque()
        count = 0

        # 统计新鲜橘子的数量, 并将腐烂的橘子加入到队列
        for r in range(M):
            for c in range(N):
                if grid[r][c] == 1:  # 新鲜橘子
                    count += 1
                elif grid[r][c] == 2:  # 腐烂橘子
                    queue.append((r, c))

        round = 0   # 层数, 或者分钟数
        while count > 0 and len(queue) > 0:  # count需要大于0, 是因为如果全部都是腐烂的橘子, 那么会进入循环导致round + 1, 实际上round需要为0
            round += 1
            n = len(queue)
            for i in range(n):  # 这一层的全部都放进来
                r, c = queue.popleft()
                if r - 1 >= 0 and grid[r-1][c] == 1:
                    grid[r-1][c] = 2
                    count -= 1
                    queue.append((r-1, c))
                if r + 1 < M and grid[r+1][c] == 1:
                    grid[r+1][c] = 2
                    count -= 1
                    queue.append((r+1, c))
                if c - 1 >= 0 and grid[r][c-1] == 1:
                    grid[r][c-1] = 2
                    count -= 1
                    queue.append((r, c-1))
                if c + 1 < N and grid[r][c+1] == 1:
                    grid[r][c+1] = 2
                    count -= 1
                    queue.append((r, c+1))

        if count > 0:
            return -1
        else:
            return round
```

### [207.课程表](https://leetcode.cn/problems/course-schedule/description/?envType=study-plan-v2&envId=top-100-liked)

这道题的本质是判断图中是否存在环. 我们选择使用BFS来检测是否存在环, 所使用的算法叫做Kahn算法, 它是一种经典的拓扑排序算法. 算法的核心思想是"拆除依赖". 其本质是剥洋葱式的循环:

1. 找头: 找到此时没有前置依赖(入度=0)的节点
2. 移除: 把节点从图中拿掉
3. 解锁: 该节点消失之后, 原本指向它的节点, 依赖数-1
4. 重复: 检查谁变成了新的入度=0的节点, 继续下一轮

如果最后图里面还有节点, 但是没有入度=0的, 说明图中存在环.

```py
class Solution:
    def canFinish(self, numCourses: int, prerequisites: List[List[int]]) -> bool:
        indeg = [0] * numCourses  # 用于统计每一个节点的入度
        g = [[] for _ in range(numCourses)]  # 用于记录每个节点的相邻节点

        for a, b in prerequisites:  # b -> a
            g[b].append(a)
            indeg[a] += 1

        from collections import deque
        q = deque(i for i in range(numCourses) if indeg[i] == 0)  # 最开始先把所有入度已经是0的节点放进来
        cnt = 0
        while q:
            u = q.popleft()
            cnt += 1
            for v in g[u]:
                indeg[v] -= 1
                if indeg[v] == 0:
                    q.append(v)

        return cnt == numCourses
```

## 动态规划

动态规划是一种算法设计方法, 用于解决具有重叠子问题特性和最优子结构的问题. 他有两种实现方式, 自顶向下和自底向上.

* 重叠子问题: 问题可以分解为多个子问题, 这些子问题会被重复计算
* 最优子结构: 问题的最优解能由子问题的最优解组合得到
* 自顶向下: 从原始问题出发, 递归求解并缓存结果
* 自底向上: 从最小子问题开始, 逐步构建到原问题

动态规划的关键是找到状态定义和状态转移方程.

=== "自底向上"

    自底向上的实现方式是递推. 从最小子问题开始, 逐步推导到原问题. 使用循环迭代, 没有递归. 用数组存储所有子问题的结果. 其执行过程可以总结为:

    1. 初始化数组, 设置边界条件
    2. 按顺序计算每个子问题
    3. 根据状态转移方程填充表格
    4. 返回原问题的结果

    以斐波那契数列为例:

    ```py
    def fib(n):
        if n <= 1:
            return n
        dp = [0] * (n + 1)
        dp[1] = 1
        for i in range(2, n + 1):
            dp[i] = dp[i - 1] + dp[i - 2]
        return dp[n]
    ```

=== "自顶向下"

    自顶向下是动态规划的另一种实现方式. 从原问题出发, 递归分解为子问题, 首次计算时缓存结果, 避免重复计算, 本质是递归+缓存. 其执行过程可以总结为:

    1. 检查缓存: 如果子问题已经计算过, 直接返回结果
    2. 否则递归计算
    3. 将结果存入缓存
    4. 返回结果

    以斐波那契数列为例:

    ```py
    def fib(n, memo={}):
        if n in memo:  # 检查缓存
            return memo[n]
        if n <= 1:
            return n

        # 递归计算并缓存
        memo[n] = fib(n-1, memo) + fib(n-2, memo)
        return memo[n]
    ```

    为什么要用到缓存, 是因为可能会重复计算相同的子问题, 缓存是为了避免重复. 普通递归(没有缓存)计算`fib(5)`的过程:

    ```
                     fib(5)
                    /      \
                fib(4)      fib(3)
                /    \      /    \
            fib(3) fib(2) fib(2) fib(1)
            /   \   /  \   /  \
        fib(2) fib(1) ...
    ```

    注意:fib(3) 计算了 2次,fib(2) 计算了 3次! 有缓存的工作原理:

    ```
    memo = {}  # 缓存字典

    fib(5) → 计算 fib(4) 和 fib(3)
    fib(4) → 计算 fib(3) 和 fib(2)
        fib(3) → 计算完,存入 memo[3] = 2
        fib(2) → 计算完,存入 memo[2] = 1
    返回 fib(4) = 3,存入 memo[4]

    fib(3) → 直接从 memo[3] 取值 = 2 ✅ (不用重算!)

    返回 fib(5) = 5
    ```

### 线性动态规划

线性DP的关注点是解决问题的前i个元素组成的子问题, 状态主要沿序列线性推进, 当前值通常直接依赖于前一个或者前几个位置的最优值. 走到第`i`步, 只在乎结果, 不在乎处于什么姿态.

#### [70.爬楼梯](https://leetcode.cn/problems/climbing-stairs/description/?envType=study-plan-v2&envId=top-100-liked)

`dp[i]`的状态只能从`i-1`迈一步或者从`i-2`迈两步转移过来. 因此, `dp[i] = dp[i-1] + dp[i-2]`.

```py
class Solution:
    def climbStairs(self, n: int) -> int:
        if n <= 2:
            return n
        dp = [0] * (n+1)
        dp[1] = 1
        dp[2] = 2
        for i in range(3, n+1):
            dp[i] = dp[i-1] + dp[i-2]
        return dp[n]
```

#### [118.杨辉三角](https://leetcode.cn/problems/pascals-triangle/?envType=study-plan-v2&envId=top-100-liked)

```py
class Solution:
    def generate(self, numRows: int) -> List[List[int]]:
        res = []
        for i in range(numRows):
            lel = [1] * (i+1)
            if i >= 2:
                for j in range(1, i):
                    lel[j] = res[i-1][j-1] + res[i-1][j]
            res.append(lel)
        return res
```

#### [279.完全平方数](https://leetcode.cn/problems/perfect-squares/?envType=study-plan-v2&envId=top-100-liked)

完全平方数是一类典型的背包问题. `dp[i]`表示组成数字`i`的完全平方数的最少数量. `dp[i]`的状态转移方程是: `dp[i] = min(dp[i], dp[i - j*j] + 1)`, 其中`j*j`是小于等于`i`的完全平方数.

假设你现在已经在第`i=12`层, 那么到这个状态, 有这么几种可能, 最后一步迈的是`1^2`, 那么之前在11, 最后一步迈的是`2^2`, 那么之前在8, 最后一步迈的是`3^2`, 那么之前在3. 所以可以表示为`dp[12] = min(dp[11]+1, dp[8]+1, dp[3]+1)`.

```py
class Solution:
    def numSquares(self, n: int) -> int:
        dp = [float('inf')] * (n+1)
        dp[0] = 0
        for i in range(1, n+1):
            j = 1
            while j * j <= n:
                dp[i] = min(dp[i], dp[i-j*j]+1)
                j += 1
        return dp[n]
```

#### [322.零钱兑换](https://leetcode.cn/problems/coin-change/?envType=study-plan-v2&envId=top-100-liked)

这道题也是典型的背包问题. `dp[i]`表示组成金额`i`的最少硬币数量. `dp[i]`的状态转移方程是: `dp[i] = min(dp[i], dp[i - coin] + 1)`, 其中`coin`是小于等于`i`的硬币面额.

```py
class Solution:
    def coinChange(self, coins: List[int], amount: int) -> int:
        dp = [float('inf')] * (amount + 1)
        dp[0] = 0
        sorted_coins = sorted(coins)
        for i in range(1, amount + 1):
            j = 0
            while j < len(sorted_coins) and i - sorted_coins[j] >= 0:
                dp[i] = min(dp[i], dp[i-sorted_coins[j]]+1)
                j += 1
        return dp[amount] if dp[amount] != float('inf') else -1
```

#### [139.单词拆分](https://leetcode.cn/problems/word-break/?envType=study-plan-v2&envId=top-100-liked)

定义 `dp[i]` 表示字符串前 `i` 个字符 (`s[0:i]`) 能否用字典中的单词拆分. 状态转移: 遍历所有可能的断点 `j < i`, 如果 `dp[j]` 为真且 `s[j:i]` 在字典中, 则 `dp[i]` 为真.

```py
class Solution:
    def wordBreak(self, s: str, wordDict: List[str]) -> bool:
        dp = [False] * (len(s) + 1)
        wordSet = set(wordDict)
        dp[0] = True
        for i in range(1, len(s) + 1):
            for j in range(i):
                if dp[j] and s[j:i] in wordSet:
                    dp[i] = True
                    break
        return dp[len(s)]
```

#### [300.最长递增子序列](https://leetcode.cn/problems/longest-increasing-subsequence/?envType=study-plan-v2&envId=top-100-liked)

`dp[i]`表示以`nums[i]`结尾的LIS的长度. 对于所有的`i`, 枚举所有`j<i`, 如果`nums[j] < nums[i]`, 说明可以接在后面, 那么`dp[i] = max(dp[i], dp[j] + 1)`.

```py
class Solution:
    def lengthOfLIS(self, nums: List[int]) -> int:
        n = len(nums)
        if n == 0:
            return 0
        dp = [1] * n
        for i in range(n):
            for j in range(i):
                if nums[j] < nums[i]:
                    dp[i] = max(dp[i], dp[j] + 1)
        return max(dp)
```

#### [152.乘积最大子数组](https://leetcode.cn/problems/maximum-product-subarray/?envType=study-plan-v2&envId=top-100-liked)


这道题也是线性DP, 但是有点阴险, 因为负数可能会让最大变为最小, 最小变为最大. `max_dp[i]`表示的是以`nums[i]`结尾的, 非空的, 连续子数组的最大乘积, 这一道题和上一道题的不同点是, 他要求子数组必须是连续的, 所以, `max_dp[i]`只能从`max_dp[i-1]`或者`min_dp[i-1]`转移过来. 而不能从`max_dp[j]`或者`min_dp[j]`转移过来, 其中`j < i-1`.

```py
class Solution:
    def maxProduct(self, nums: List[int]) -> int:
        n = len(nums)
        max_dp = [0] * n
        min_dp = [0] * n
        max_dp[0] = min_dp[0] = nums[0]
        result = nums[0]

        for i in range(1, n):
            if nums[i] >= 0:
                max_dp[i] = max(nums[i], max_dp[i-1]*nums[i])
                min_dp[i] = min(nums[i], min_dp[i-1]*nums[i])
            else:
                max_dp[i] = max(nums[i], min_dp[i-1]*nums[i])
                min_dp[i] = min(nums[i], max_dp[i-1]*nums[i])
            result = max(result, max_dp[i])
        return result
```

### 状态机动态规划

状态机DP的关注点是在第`i`步的时候, 处于某种特定内部状态下的最优解. 状态序列在推进的同时, 还在有限个内部状态之间跳转. `dp[i][当前状态]`依赖于`dp[i-1][来源状态]`. 走到第`i`步, 必须明确当前处于什么姿态.

#### [198.打家劫舍](https://leetcode.cn/problems/house-robber/description/?envType=study-plan-v2&envId=top-100-liked)

`dp[i][0]`表示第`i`个房子没偷的最大收益, `dp[i][1]`表示第`i`个房子偷了的最大收益. 如果第`i`个房子没偷, 那么第`i-1`个房子偷或者不偷都行, `dp[i][0] = max(dp[i-1][0], dp[i-1][1])`. 如果第`i`个房子偷了, 那么第`i-1`个房子就不能偷了, `dp[i][1] = dp[i-1][0] + nums[i]`.

```py
class Solution:
    def rob(self, nums: List[int]) -> int:
        if not nums:
            return 0
        n = len(nums)

        dp = [[0] * 2 for _ in range(n)]
        dp[0][0] = 0  # 第一家不偷, 收益为 0
        dp[0][1] = nums[0]  # 第一家偷了, 收益为 nums[0]

        for i in range(1, n):
            # 状态机
            dp[i][0] = max(dp[i-1][0], dp[i-1][1])
            dp[i][1] = dp[i-1][0] + nums[i]

        return max(dp[n-1][0], dp[n-1][1])  # 最后一家有可能偷了也有可能没有偷
```

### 区间动态规划

## 二叉树

### 遍历

#### 迭代写法

对于先序遍历和后续遍历, 是一种写法:

```py
def preorder(root):
    if not root:
        return
    stack = [root]
    while stack:
        node = stack.pop()
        print(node.val)
        if node.right:
            stack.append(node.right)
        if node.left:
            stack.append(node.left)
```

对于中序遍历, 是另一种写法:

```py
def inorder(root):
    stack = []
    cur = root
    while cur or stack:
        while cur:
            stack.append(cur)
            cur = cur.left
        cur = stack.pop()
        print(cur.val)
        cur = cur.right
```
