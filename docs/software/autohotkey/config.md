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
; Ctrl+Space→Win+Space
^Space:: {
    Send "#{Space}"
}
```

## 开机自动启动

将脚本放到`%APPDATA%\Romming\Microsoft\Windows\Start Menu\Programs\Startup`这个路径下.
