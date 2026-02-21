---
title: 一键部署深度学习环境
comments: true
---

```bash
apt install tmux

# tmp dir
echo 'export TMP=/drive/wexu0327' >> ~/.bashrc
source ~/.bashrc

# env
echo 'export PATH="/usr/local/cuda/bin:$TMP/.local/bin:$PATH"' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"' >> ~/.bashrc
echo 'export CUDA_VISIBLE_DEVICES="0"' >> ~/.bashrc
echo 'export MODEL_RESOURCE_DIR=${TMP}/resource/model' >> ~/.bashrc
echo 'export DATASET_RESOURCE_DIR=${TMP}/resource/dataset' >> ~/.bashrc
echo 'export HF_HUB_DOWNLOAD_TIMEOUT=60' >> ~/.bashrc
echo 'export HF_HUB_ETAG_TIMEOUT=60' >> ~/.bashrc
echo 'export PYTHONBREAKPOINT=pdb.set_trace' >> ~/.bashrc
source ~/.bashrc

# alis
echo 'alias ll="ls -al"' >> ~/.bashrc
source ~/.bashrc

# soft links
mkdir ${TMP}/.cache
mkdir ${TMP}/.local 
rm -rf ~/.cache
rm -rf ~/.local
ln -s  ${TMP}/.cache  ~/.cache
ln -s ${TMP}/miniconda3 ~/miniconda3
ln -s ${TMP}/.local ~/.local

# configure tmux
touch ~/.tmux.conf
echo "set -g mouse on" >> ~/.tmux.conf
echo "set -g default-command 'bash -c \"source ~/.bashrc; exec bash\"'" >> ${HOME}/.tmux.conf
tmux source-file ~/.tmux.conf

# install gitlfs
wget -O ~/git-lfs.tar.gz https://github.com/git-lfs/git-lfs/releases/download/v3.6.1/git-lfs-linux-amd64-v3.6.1.tar.gz
cd ~
tar xvzf git-lfs.tar.gz
cd git-lfs-3.6.1
sed -i 's|^prefix="/usr/local"$|prefix="$HOME/.local"|' install.sh
./install.sh
cd ~
rm -rf git-lfs-3.6.1

# install pyenv
curl -fsSL https://pyenv.run | bash
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init - bash)"' >> ~/.bashrc
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(pyenv init - bash)"' >> ~/.bash_profile
source ~/.bashrc
sudo apt update; sudo apt install build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev curl git \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
pyenv install 3.12
pyenv global 3.12

# install miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod u+x Miniconda3-latest-Linux-x86_64.sh
./Miniconda3-latest-Linux-x86_64.sh

# install cuda
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/12.4.0/local_installers/cuda-repo-ubuntu2204-12-4-local_12.4.0-550.54.14-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2204-12-4-local_12.4.0-550.54.14-1_amd64.deb
sudo cp /var/cuda-repo-ubuntu2204-12-4-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda-toolkit-12-4

# switch source
curl https://chsrc.run/posix | bash
chsrc set python
chsrc set ubuntu
chsrc set conda

# configure ssh
mkdir ~/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
```

## 无sudo权限安装tex环境

1. 下载安装包: `wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz`
2. 解压: `tar xvzf install-tl-unx.tar.gz`
3. 安装: `./install-tl`
4. 选择`S`: 设置为full-scheme (everything)
5. 选择`C`: 全选(`+`)
6. 选择`D`: 输入`1`, 然后输入自定义的目录
7. 选择`I`: 开始安装
8. 添加到`PATH`: `export PATH=$PATH:/drive/wexu0327/tex/bin/x86_64-linux`
9. 安装perl: `conda install perl -c conda-forge -y`
9. 添加到`settings.json`:

    ```json
    "latex-workshop.latex.tools": [

        {
            "name": "latexmk",
            "command": "latexmk",
            "args": [
                "-synctex=1",
                "-interaction=nonstopmode",
                "-file-line-error",
                "-pdf",
                "-outdir=%OUTDIR%",
                "%DOC%"
            ],
            "env": {
                "PATH": "/drive/wexu0327/tex/bin/x86_64-linux:/drive/wexu0327/miniconda3/bin/"
            }
        }
    ]
    ```

## 无sudo权限安装homebrew

???+ warning "已知问题"

    如果没有`/home/linuxbrew`, 那么好像没法直接安装二进制预编译包, 装其他软件会很慢.

```bash
mkdir homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew
```

然后添加`/homebrew/bin`到`PATH`. 然后执行`brew shellenv`, 将输出添加到`.bashrc`.

然后你就会发现, 基本上, 能在macos上装的软件都能在无sudo的情况下装,  包括上面那个让人头疼的tex.

## 换源

用https://github.com/RubyMetric/chsrc. 可以替换上面brew的源.

## 干掉一堆vscode/cusor服务端

```
ps -ef | awk '/cursor-|code-/{print $2}' | xargs kill -9
```
