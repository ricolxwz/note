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
x
### [45.跳跃游戏 II](https://leetcode.cn/problems/jump-game-ii/description/?envType=study-plan-v2&envId=top-100-liked)

这道题比55更进一步, 需要求出到达最后一个元素的最小跳跃次数.
