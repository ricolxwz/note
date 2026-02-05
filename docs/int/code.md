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
        # 判断 base case：坐标 (r, c) 超出网格范围则直接返回
        if not in_area(grid, r, c):
            return
        # 访问上、下、左、右四个相邻格子
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
