---
title: 配置
comments: true
---

## 转换ssh私钥

1. 下载puttygen: https://www.puttygen.com/download-putty, 注意, 下载的是puttygen.exe
2. 打开软件, 点击菜单Conversations, 选择ed25519或者rsa格式的私钥文件
3. 点击菜单Key, 点击Parameters for sanving key files, PPK file version选择2, 点击OK.
4. 点击save private key, 保存类型为PuTTY Private Key Files, 设置一个文件名, 保存.
5. 进入directory opus, 编辑FTP链接, 选择刚才创建的ppk文件, 就可以了.

## 设置

* 文件显示栏
  * 标题栏
    * 窗口图标: 当前文件夹图标
