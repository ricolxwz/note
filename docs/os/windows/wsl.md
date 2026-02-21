---
title: 怎么使用WSl
comments: true
---

## `.wslconfig`文件

`.wslconfig`文件位于用户目录下的`%UserProfile%\.wslconfig`, 如果不存在需要手动创建, 该文件用于全局配置虚拟机的资源限制, 包括memory, processors, swap等参数.

例如, 如果要配置内存上线, 可以在`.wslconfig`中添加区块:

```ini
[wsl2]
memory=8GB
```
