---
title: AutoHotKey配置
comments: true
---

## 键位映射

```
if !A_IsAdmin
{
    Run('*RunAs "' A_ScriptFullPath '"')
    ExitApp
}

; 左Alt→左Ctrl
LAlt::LCtrl

; CapsLock→Esc
CapsLock::Esc

; 左Ctrl→左Alt
LCtrl::LAlt

; 右Alt→CapsLock
RAlt::CapsLock

; 右Shift→Win+H
RShift:: {
    Send "#h"
}
```

```
if !A_IsAdmin
{
    Run('*RunAs "' A_ScriptFullPath '"')
    ExitApp
}
#Requires AutoHotkey v2.0+

SetWinDelay(-1)          ; 禁用WinMove自动延时(默认100 ms)
; 如担心占用高，可用 SetWinDelay(0) 给系统一次时间片

; Ctrl+Alt+左键拖动→移动
^!LButton::{
    CoordMode("Mouse","Screen")
    hwnd := WinExist("A")
    WinGetPos(&wx,&wy,,, hwnd)
    MouseGetPos(&mx,&my)
    While GetKeyState("LButton","P"){
        MouseGetPos(&nx,&ny)
        WinMove(wx+(nx-mx), wy+(ny-my),,, hwnd)
        Sleep 0           ; 约 1000 Hz/CPU友好；若仍嫌顿可试 Sleep 0
    }
}

; Shift+左键拖动→自由缩放
+LButton::{
    CoordMode("Mouse","Screen")
    hwnd := WinExist("A")
    WinGetPos(&wx,&wy,&ww,&wh, hwnd) ; 获取窗口的初始位置和大小
    MouseGetPos(&sx,&sy) ; 获取鼠标的初始位置

    While GetKeyState("LButton","P"){
        MouseGetPos(&nx,&ny) ; 获取鼠标当前位置

        ; 计算鼠标的移动量
        deltaX := nx - sx
        deltaY := ny - sy

        ; 根据鼠标移动量调整窗口大小
        ; 可以根据需要调整缩放比例或逻辑
        WinMove(,, ww + deltaX, wh + deltaY, hwnd)

        Sleep 0
    }
}

; Ctrl+Alt+右键拖动→缩放
^!RButton::{
    CoordMode("Mouse","Screen")
    hwnd := WinExist("A")
    MouseGetPos(&sx,&sy)
    WinGetPos(,, &ww,&wh, hwnd)
    While GetKeyState("RButton","P"){
        MouseGetPos(&nx,&ny)
        WinMove(,, ww+(nx-sx), wh+(ny-sy), hwnd)
        Sleep 0
    }
}
```

```
; Ctrl+Space→Win+Space
^Space:: {
    Send "#{Space}"
}
```

## 开机自动启动

将脚本放到`%APPDATA%\Romming\Microsoft\Windows\Start Menu\Programs\Startup`这个路径下.
