---
title: AutoDL使用说明
comments: true
---

## 镜像选择

机器的"最高CUDA"尽量要大, 但是镜像的CUDA尽量要小. 目前选择Miniconda Ubuntu22.04就可以.

## Tmux设置

```bash
echo "set -g mouse on" >> ${HOME}/.tmux.conf
echo "set -g default-command 'bash -c \"source ~/.bashrc; exec bash\"'" >> ${HOME}/.tmux.conf
tmux source-file ${HOME}/.tmux.conf
```

## 环境变量配置

```bash
TMP=/root/autodl-tmp

echo "export PATH="/usr/local/cuda/bin:${TMP}/.local/bin:\$PATH"" >> ${HOME}/.bashrc
echo "export LD_LIBRARY_PATH="/usr/local/cuda/lib64:\$LD_LIBRARY_PATH"" >> ${HOME}/.bashrc
echo "export CUDA_VISIBLE_DEVICES='0'" >> ${HOME}/.bashrc

echo "alias hfu='huggingface-cli upload --repo-type model --include'" >> ${HOME}/.bashrc
echo "alias hfd='huggingface-cli download --repo-type model --local-dir . --include'" >> ${HOME}/.bashrc
echo "alias hfu*='huggingface-cli upload --repo-type dataset --include'" >> ${HOME}/.bashrc
echo "alias hfd*='huggingface-cli download --repo-type dataset --local-dir . --include'" >> ${HOME}/.bashrc

echo "source /etc/network_turbo" >> ${HOME}/.bashrc

echo "export MODEL_RESOURCE_DIR=${TMP}/resource/model" >> ${HOME}/.bashrc
echo "export DATASET_RESOURCE_DIR=${TMP}/resource/dataset" >> ${HOME}/.bashrc

echo "alias mm='micromamba'" >> ${HOME}/.bashrc

source ${HOME}/.bashrc
```

## 配置micromamba

```bash
TMP=/root/autodl-tmp
mm shell init -s bash -r ${TMP}/micromamba
source ${HOME}/.bashrc
mm config append channels conda-forge
mm config set channel_priority strict
```

## 系统盘不太够

```bash
rm -rf ~/.cache
mkdir /root/autodl-tmp/.cache
ln -s  /root/autodl-tmp/.cache  ~/.cache
mv /root/miniconda3 /root/autodl-tmp/miniconda3
ln -s /root/autodl-tmp/miniconda3 /root/miniconda3
ln -s /root/autodl-tmp /root/tmp
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
