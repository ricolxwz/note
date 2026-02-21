---
title: AutoDL使用说明
comments: true
---

## 镜像选择

机器的"最高CUDA"尽量要大, 但是镜像的CUDA尽量要小. 目前选择Miniconda Ubuntu22.04就可以.

## Git服务使用代理

```bash
# 西北设置
git config --global http.proxy https://10.37.1.23:12798
git config --global https.proxy https://10.37.1.23:12798
```

取消设置:

```bash
git config --global --unset http.proxy
git config --global --unset https.proxy
```
