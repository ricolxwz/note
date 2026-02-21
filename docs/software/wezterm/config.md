---
title: 配置
comments: true
---

## 配置文件

```lua
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- 主题
config.color_scheme = "GruvboxDark"
-- 字体
config.font = wezterm.font "Maple Mono Normal NL NF CN"
config.font_size = 12.0
-- 去掉无关的元素
config.enable_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.enable_scroll_bar = false
config.window_decorations = "RESIZE"
-- 透明度
config.window_background_opacity = 0.9
config.macos_window_background_blur = 20
-- 启动大小
config.initial_cols = 100
config.initial_rows = 40

-- 针对windows平台的设置
if wezterm.target_triple:find "windows" then
    config.default_prog = {"powershell.exe"}
    config.default_cwd = wezterm.home_dir
end

config.keys = {}
-- 关闭窗格/标签/窗口快捷键：Ctrl+Shift+W
table.insert(config.keys, {
    key = 'w',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.CloseCurrentPane{confirm=true},
  })
-- 退出应用快捷键：Ctrl+Shift+Q
table.insert(config.keys, {
    key = 'q',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.QuitApplication,
})

return config
```
