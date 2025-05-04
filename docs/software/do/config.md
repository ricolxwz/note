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

* 菜单
    * 设置
        * 可用的工具栏: 收藏栏, 菜单选中, 其他都取消, 然后设置为默认工具栏组
    * 窗口
        * 状态栏: 隐藏
    * 搜索图标: 打开Opus搜索, 勾选查找文件名和文件内容
* 选项
    * 文件操作
        * 删除文件
            * 勾选删除到回收站时跳过确认
    * 文件夹
      * 自动读取
        * FTP站点: 选择正常加载
      * 文件夹大小
        * 勾选自动计算文件夹大小, 所有本地和网络驱动器
      * 文件夹格式
        * 使用默认值双击
            * 列
              * 自动调整所有列宽勾选
              * 修改(时间和日期), 勾选排序
    * 文件显示栏
        * 窗口图标: 当前文件夹图标
    * 文件显示列:
        * 选项
            * 勾选在大小列后面显示图形
    * 常用路径
        * 主文件夹: 选择指定文件夹
    * 布局和样式
        * 默认窗口: 取消勾选关闭窗口时自动更新默认窗口
    * DOpus启动
        * 启动
            * 勾选不打开窗口
## 快捷键

1. 按住shift, 拖动: 移动
2. 按住ctrl, 拖动: 复制
3. 按住alt, 拖动: 创建快捷方式
