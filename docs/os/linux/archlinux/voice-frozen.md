---
title: Archlinux声音卡顿问题
comments: true
---

# 声音卡顿问题

环境为VMWare, 使用的后端是Pipewire, 📢经常出现断断续续1-2分钟之后正常播放的问题. 经发现可能是buffer太小导致的.

## 解决方案

```bash
mkdir -p ~/.config/wireplumber/wireplumber.conf.d/
cd ~/.config/wireplumber/wireplumber.conf.d
vim ~/.config/wireplumber/wireplumber.conf.d/50-alsa-config.conf
```

输入以下内容:

```
monitor.alsa.rules = [
  {
    matches = [
      # This matches the value of the 'node.name' property of the node.
      {
        node.name = "~alsa_output.*"
      }
    ]
    actions = {
      # Apply all the desired node specific settings here.
      update-props = {
        api.alsa.period-size   = 1024 # 建议改为2048
        api.alsa.headroom      = 8192
      }
    }
  }
]
```

## 参考资料

- [https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/Troubleshooting#stuttering-audio-in-virtual-machine](https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/Troubleshooting#stuttering-audio-in-virtual-machine)