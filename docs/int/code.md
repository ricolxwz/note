---
title: 代码
comments: false
---

## 回溯

### 子集型回溯

子集型回溯对应的是: **每个元素都可以选或者不选**. [原题](https://leetcode.cn/problems/subsets/?envType=study-plan-v2&envId=top-100-liked)

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

衍生题目: 

* [分割回文串](https://leetcode.cn/problems/palindrome-partitioning/?envType=study-plan-v2&envId=top-100-liked): 换一个视角, 假设每两个字符之间都有一个逗号, 我们可以选它或者不选它, 这就是一个子集型回溯问题. 

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

组合型回溯其实是子集型回溯的一种特殊情况. 子集回溯需要所有规模的集合, 组合回溯需要满足某个约束的集合. 子集回溯自然结束, 组合回溯满足条件就停, 可以剪枝.  [原题](https://leetcode.cn/problems/uUsW3B/solutions/2087261/hui-su-bu-hui-xie-tao-lu-zai-ci-pythonja-6zca/)

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
