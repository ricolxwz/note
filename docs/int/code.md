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


