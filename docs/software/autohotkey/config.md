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

SetWinDelay(-1)

; Ctrl+Alt+左键拖动→移动
^!LButton::{
    CoordMode("Mouse","Screen")
    MouseGetPos(&mx,&my,&hwnd)
    WinGetPos(&wx,&wy,,, hwnd)
    MouseGetPos(&mx,&my)
    While GetKeyState("LButton","P"){
        MouseGetPos(&nx,&ny)
        WinMove(wx+(nx-mx), wy+(ny-my),,, hwnd)
        Sleep 0
    }
}

; Win+左键拖动→自由缩放
<#LButton::{
    CoordMode("Mouse","Screen")
    MouseGetPos(&sx,&sy,&hwnd)
    WinGetPos(&wx,&wy,&ww,&wh, hwnd)
    MouseGetPos(&sx,&sy)
    While GetKeyState("LButton","P"){
        MouseGetPos(&nx,&ny)
        deltaX := nx - sx
        deltaY := ny - sy
        WinMove(,, ww + deltaX, wh + deltaY, hwnd)
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
