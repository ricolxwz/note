---
title: WSL2配置容器环境
comments: true
---

## 安装NVIDIA环境

1. 安装nvidia驱动

	在WSL2环境下, 只需要在windows系统上安装NVIDIA驱动, 而不需要在WSL Linux中安装Linux版的驱动. 当你在Windows上安装NVIDIA驱动之后, 驱动会自动将相关组件以运行时库, 如`libcuda.so`的方式映射到WSL2中, 使得WSL2中的应用程序可以利用GPU加速. 所以, 不需要在WSL2中再安装一遍NVIDIA驱动了.

2. 安装nvidia-container-toolkit

	nvidia-container-toolkit的作用是自动将WSL2上的相关运行时库, 如`libcuda.so`映射到容器内, 是容器中无需特别安装驱动就可以调用GPU. 并且, 自动配置GPU环境, 包括设备挂在, 环境变量设置等.

	```bash
	curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
	&& curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
		sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
		sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
	sudo apt-get update
	sudo apt-get install -y nvidia-container-toolkit
	```

	检查nvidia-container-toolkit是否安装成功:

	```bash
	docker run --gpus all -it ubuntu tail -f /dev/null
	nvidia-smi
	``` 

	应该就能在容器内看到当前的GPU了.

### 方法一: 在容器内手动安装全局CUDA, cuDNN

1. 安装cuda-toolkit

	访问https://developer.nvidia.com/cuda-toolkit-archive, 找到自己想要的版本, 在容器内安装

	```bash
	wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin # 获取优先级设置
	mv cuda-ubuntu2404.pin /etc/apt/preferences.d/cuda-repository-pin-600 
	wget https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda-repo-ubuntu2404-12-8-local_12.8.0-570.86.10-1_amd64.deb
	dpkg -i cuda-repo-ubuntu2404-12-8-local_12.8.0-570.86.10-1_amd64.deb
	cp /var/cuda-repo-ubuntu2404-12-8-local/cuda-*-keyring.gpg /usr/share/keyrings/
	apt-get update
	apt-get -y install cuda-toolkit-12-8
	```

	???+ tip "什么是存储库文件"

		设置存储库文件指的是用于配置软件包管理器(例如apt)如何获取和管理软件包的配置文件. 例如, 在ubuntu系统中, `/etc/apt/sources.list`文件和`/etc/apt/sources.list.d`目录下的文件用于指定软件源的地址, 而`/etc/apt/preferences.d`目录下的文件则可以设置软件包的优先级, 也称为pin设置, 以确保在多个来源存在同一软件包时, 系统优先选择特定存储库中的版本.

	别忘记设置环境变量:

	```bash
	echo 'export PATH=/usr/local/cuda-12.8/bin:$PATH' >> ~/.bashrc
	echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
	source ~/.bashrc
	```

	???+ tip "什么是共享库"

		共享库通常存放常用函数和算法, 避免每个程序都静态链接一份相同的代码, 从而节省磁盘空间和内存资源. 在Linux系统中, 共享库一般以.so为后缀, 当程序运行的时候, 动态链接器会根据`LD_LIBRARY_PATH`等环境变量查找并加载所需的共享库. 

	检测cuda-toolkit是否安装成功:

	```bash
	nvcc --version
	```

2. 安装cuDNN

    访问https://developer.nvidia.com/cudnn-archive, 选择自己想要的版本.

    ```bash
    wget https://developer.download.nvidia.com/compute/cudnn/9.7.1/local_installers/cudnn-local-repo-ubuntu2404-9.7.1_1.0-1_amd64.deb
    dpkg -i cudnn-local-repo-ubuntu2404-9.7.1_1.0-1_amd64.deb
    cp /var/cudnn-local-repo-ubuntu2404-9.7.1/cudnn-*-keyring.gpg /usr/share/keyrings/
    apt-get update
    apt-get -y install cudnn
    apt-get -y install cudnn-cuda-12
    ```

    检查cuDNN是否安装成功:

    ```bash
    ldconfig -p | grep libcudnn
    ```

    如果能查到libcudnn相关信息, 说明cuDNN库已经正确安装. 或者还可以通过torch检测是否安装成功:

### 方法二: 使用NVIDIA提供的官方镜像安装全局CUDA, cuDNN

https://hub.docker.com/r/nvidia/cuda, 选择带有cudnn, devel的版本.

### 方法三: 使用PyTorch的预编译版本安装局部CUDA, cuDNN(推荐)

上述方法一, 方法二安装的是系统全局的CUDA支持, PyTorch在安装GPU预编译版本的时候会自动安装它自己的CUDA和cuDNN. 它自己的CUDA和cuDNN和系统的是隔离的, 就是说, 在调用pytorch的时候, 使用的是它自己的CUDA和cuDNN而非系统的. 

```bash
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126
```