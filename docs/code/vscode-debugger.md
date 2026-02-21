---
title: 如何在VSCode中使用调试
comments: true
---

## 工具栏

主要有三种工具:

- 逐过程(Step Over): 当当前行包含一个函数调用过的时候, 逐过程会跳过函数内部的具体执行过程, 直接跳到调用函数的下一行继续调试
- 单步调试(Step Into): 当当前行包含一个函数调用的时候, 单步调试会进入被调用函数的内部, 让你能够逐行看到函数内部的执行流程
- 单步跳出(Step Out): 当你已经进入了一个函数, 单步跳出会快速退出当前函数的逐行调试, 跳到调用函数的下一个逻辑点继续调试
- 继续: 当前断点处暂停后, 选择"继续"会让程序从这个断点处继续按正常流程运行, 直到遇到下一个断点或程序结束, 不会再逐行暂停
- 重启: 在调试过程中随时可以选择"重启", 这会让整个程序的调试流程从头开始, 并重新加载或执行初始状态下的代码. 相当于先停止再重新启动调试会话
- 停止: 终止当前的调试会话, 程序不再继续运行或调试. 使用此操作后, 调试器不再跟踪或执行目标程序

## WATCH

如果想要查看中程序中没有的值, 那么可以使用WATCH这个功能.

## CALL STACK

函数调用栈.

## `launch.json`文件的作用

`launch.json`文件主要用于配置VSCode中的调试选项. 下面是一个示例:

```json
{
    // 使用 IntelliSense 了解相关属性。
    // 悬停以查看现有属性的描述。
    // 欲了解更多信息，请访问: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Python 调试程序: 包含参数的当前文件",
            "type": "debugpy",
            "request": "launch",
            "program": "${file}",
            "console": "integratedTerminal",
            "args": "${command:pickArgs}"
        }
    ]
}
```

* `type`: 表示指定调试的引擎, debuggpy是微软的Python官方调试扩展
* `request`: `launch`表示以"启动一个新进程"的方式来进行调试, 另一个常见的选项是`attach`, 用于附加到已有进程
* `program`: 调试时要运行的Python程序入口, 这里的`${file}`表示的是当前在VSCode活动编辑器里打开的Python文件
* `console`: 指定调试时程序运行输出所在的终端, 这里是VSCode的集成终端. 可以根据需要改成`externalTerminal`在外部终端窗口显示
* `args`: 这里使用了VS Code内置的`${command:pickArgs}`命令, 会在你开始调试的时候让你选择输入或者要传递给程序的命令行参数. 这样就不用在`launch.json`里面写死固定的参数
* `cwd`: 运行的起始目录

在举个例子:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Train VQ",
            "type": "debugpy",
            "request": "launch",
            "program": "${workspaceFolder}/train_vq.py",
            "cwd": "${workspaceFolder}",
            "console": "integratedTerminal",
            "args": [
                "--batch-size", "256",
                "--lr", "2e-4",
                "--total-iter", "300000",
                "--lr-scheduler", "200000",
                "--nb-code", "256",
                "--down-t", "3",
                "--depth", "3",
                "--window-size", "32",
                "--dilation-growth-rate", "3",
                "--out-dir", "output",
                "--dataname", "face_conanglobal",
                "--vq-act", "relu",
                "--quantizer", "ema_reset",
                "--loss-vel", "0.5",
                "--recons-loss", "l1_smooth",
                "--exp-name", "VQVAE_conanglobal"
            ]
        }
    ]
}
```
