---
title: 代码
comments: false
---

## 回溯

### 子集型回溯

子集型回溯对应的是: **每个元素都可以选或者不选**. 

原题: https://leetcode.cn/problems/subsets/?envType=study-plan-v2&envId=top-100-liked

* 选/不选写法: 

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

* 枚举写法: 

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
                dfs(i + 1)
                path.append(nums[i])
                dfs(i + 1)
                path.pop()

            dfs(0)
            return res
    ```

衍生题目: 

* 分割回文串: 换一个视角, 假设每两个字符之间都有一个逗号, 我们可以选它或者不选它, 这就是一个子集型回溯问题. 

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
                    t = s[i:j+1]
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
                t = s[start:i+1]
                if t == t[::-1]:
                    path.append(t)
                    dfs(i+1, i+1)
                    path.pop()
            dfs(0, 0)
            return res
    ```

### 组合型回溯


