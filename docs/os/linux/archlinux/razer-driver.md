---
title: Archlinux Razer驱动安装
comments: true
---

# 雷蛇驱动安装

```bash
sudo pacman -S openrazer-daemon
sudo gpasswd -a $USER plugdev
yay -S polychromatic
sudo reboot
```