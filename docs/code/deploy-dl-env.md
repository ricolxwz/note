---
title: 一键部署深度学习环境
comments: true
---

```bash
apt install tmux

# tmp dir
export TMP=${TMP} >> ~/.bashrc
export TMP=/drive/wexu0327 >> ~/.bashrc

# env
echo 'export PATH="/usr/local/cuda/bin:$TMP/.local/bin:$PATH"' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"' >> ~/.bashrc
echo 'export CUDA_VISIBLE_DEVICES="0"' >> ~/.bashrc
echo 'export MODEL_RESOURCE_DIR=${TMP}/resource/model' >> ~/.bashrc
echo 'export DATASET_RESOURCE_DIR=${TMP}/resource/dataset' >> ~/.bashrc
echo 'export HF_HUB_DOWNLOAD_TIMEOUT=60' >> ~/.bashrc
echo 'export HF_HUB_ETAG_TIMEOUT=60' >> ~/.bashrc
echo 'export PYTHONBREAKPOINT=pdb.set_trace' >> ~/.bashrc

# alis
echo 'alias ll="ls -al"' >> ~/.bashrc

# soft links
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

## 安装tex环境

```bash
conda install -c conda-forge \
  texlive-core \
  latexmk perl
```
