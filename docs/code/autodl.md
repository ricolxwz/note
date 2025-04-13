---
title: AutoDL使用说明
comments: true
---

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
