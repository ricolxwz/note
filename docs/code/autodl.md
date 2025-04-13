---
title: AutoDL使用说明
comments: true
---

## 镜像选择

CUDA版本尽量不要选的太高, 因为之后克隆时候版本太高会导致无法克隆.

## 系统盘不太够

```bash
rm -rf ~/.cache
ln -s  /root/autodl-tmp  ~/.cache
mv /root/miniconda3 /root/autodl-tmp/miniconda3
ln -s /root/autodl-tmp/miniconda3 /root/miniconda3
```

查看空间:

```bash
apt install ncdu
ncdu
```

## Git服务使用代理

```bash
# 西北设置
git config --global http.proxy http://10.37.1.23:12798
git config --global https.proxy http://10.37.1.23:12798
```

取消设置:

```bash
git config --global --unset http.proxy
git config --global --unset https.proxy
```
