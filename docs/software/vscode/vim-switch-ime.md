---
title: Vim模式下自动切换输入法
comments: true
---

1. 安装im-select, 放到合适的位置
2. 在本地机器上和**远程机器**上都要做如下的配置:

    ```
    "vim.autoSwitchInputMethod.enable": true,
    "vim.autoSwitchInputMethod.defaultIM": "com.apple.keylayout.US",
    "vim.autoSwitchInputMethod.obtainIMCmd": "/usr/local/bin/im-select",
    "vim.autoSwitchInputMethod.switchIMCmd": "/usr/local/bin/im-select {im}"
    ```

    注意, 必须在remote ssh下, 也设置一遍, 也就是说要设置两遍.
