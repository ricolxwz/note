---
title: LFS存储
comments: true
---

## 忘记跟踪某类型文件

1. 如果已经commit

    ```bash
    git track "*.mp4"
    git lfs migrate import
    git push
    ```
