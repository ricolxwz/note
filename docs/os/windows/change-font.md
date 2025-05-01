---
title: 切换系统字体
comments: true
---

## 准备

1. 首先, 备份整个fonts文件夹
2. 下载Weifont软件, 在Github上面
3. 准备好要替换的字体
4. 下载WePE, 装到U盘里面

## 核心要替换的字体

核心要替换的字体包含:

- segoeuil.ttf: Light
- seguili.ttf: Light Italic
- segoeuisl.ttf: SemiLight
- seguisli.ttf: SemiLight Italic
- segoeui.ttf: Regular
- segoeuii.ttf: Italic
- seguisb.ttf: SemiBold
- seguisbi.ttf: SemiBold Italic
- segoeuib.ttf: Bold
- segoeuiz.ttf: Bold Italic
- seguibl.ttf: Black
- seguibli.ttf: Black Italic
- SegUIVar.ttf: 根据不同的屏幕分辨率和尺寸调整动态字形
- seguihis.ttf: 不再使用但是对学者和历史爱好者有研究价值的文字
- msyh.ttc: Regular
- msyhhIt.ttc: Italic
- msyhIt.ttc: Light Italic
- msyhbdIt.ttc: Bold Italic
- msyhl.ttc: Light
- msyhbd.ttc: Bold


不需要替换的字体包含:

- seguisym.ttf: 系统符号, 系统很多icon用的是这个
- SegoeIcons.ttf: 系统Icon, 系统很多icon用的是这个
- seguiemj.ttf: 系统表情, win+.的表情符号
- segmdl2.ttf: 许多用于应用程序的图标和符号, 改了之后会导致一些图标没了, 如defender的图标

sego类的字体可以通过wefount-给定字体切换, msyh类和其他的一堆字体可以通过wefount-Windows 中文字体切换(选择以上所有字体).

其他备选的要替换的字体有:

- consolas
- ariel

## 替换

转换好想要的字体后, 重启进入Bios, 启动WePE, 然后将准备好的字体拷贝到Fonts文件夹里. 重启, 就可以了.
