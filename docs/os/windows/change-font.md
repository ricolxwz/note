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

核心要替换的字体包含 (->右侧为Maple Font中的对应字重):

- segoeuil.ttf: Light -> ExtraLight
- seguili.ttf: Light Italic -> ExtraLight Italic
- segoeuisl.ttf: SemiLight -> Light
- seguisli.ttf: SemiLight Italic -> Light Italic
- segoeui.ttf: Regular
- segoeuii.ttf: Italic
- seguisb.ttf: SemiBold
- seguisbi.ttf: SemiBold Italic
- segoeuib.ttf: Bold
- segoeuiz.ttf: Bold Italic
- seguibl.ttf: Black -> ExtraBold
- seguibli.ttf: Black Italic -> ExtraBold Italic
- SegUIVar.ttf: Regular, 根据不同的屏幕分辨率和尺寸调整动态字形
- seguihis.ttf: Regular, 不再使用但是对学者和历史爱好者有研究价值的文字
- msyh.ttc: Regular
- msyhlIt.ttc: Light Italic
- msyhIt.ttc: Italic
- msyhbdIt.ttc: Bold Italic
- msyhl.ttc: Light
- msyhbd.ttc: Bold
- consolas: VSCode某些插件如debuggy会使用这个字体
- WeiFont推荐的其他字体
- segoepr: Regular
- segoeprb: Bold
- segoesc: Regular
- segoescb: Bold

不需要替换的字体包含:

- seguisym.ttf: 系统符号, 系统很多icon用的是这个
- SegoeIcons.ttf: 系统Icon, 系统很多icon用的是这个
- seguiemj.ttf: 系统表情, win+.的表情符号
- segmdl2.ttf: 许多用于应用程序的图标和符号, 改了之后会导致一些图标没了, 如defender的图标

sego类的字体可以通过wefount-给定字体切换, msyh类和其他的一堆字体可以通过wefount-Windows 中文字体切换(选择以上所有字体).

其他备选的要替换的字体有:

- ariel

## 替换

转换好想要的字体后, 重启进入Bios, 启动WePE, 然后将准备好的字体拷贝到Fonts文件夹里. 重启, 就可以了.

## 修改应用字体

就目前来讲, Electron应用可以用asar解包app.asar, 然后修改dist/renderer/assets里面的css文件(可以打开那个文件夹, 然后用全局搜索font-family), 找到body等标签的font-family修改. 注意, 字体可以添加为:

```css
@font-face {
    font-family: "maplefont";
    src: url('./MapleMonoNormalNL-NF-CN-Regular.ttf') format('truetype');
}
```

只要把ttf放到assets文件夹里就行了. 之后在body等标签里面使用font-family: "maplefont";就行了或者使用下面的从cdn导入的方式(注意import要放在第一行). 还有一种应用比如富途牛牛是直接用存储在它文件夹下的字体的, 这种直接使用weifont把它的字体替换掉就行了.

一般Electron应用更新后字体会被覆盖, 需要重新替换字体.

```
asar extract app.asar app
```

```css
/* 放在最前面 */
@import url("https://fontsapi.zeoseven.com/442/main/result.css");
* {
    font-family: "Maple Mono NF CN" !important;
}
```

```
asar pack app app.asar
```

!!! note "tradingview修改字体"

    找到`TradingView.widget`代码或者`tvWidget = new`代码所在地, 然后再属性中加上`custom_font_family: "[电脑本地字体]"`. 例如: `custom_font_family: "Maple Mono Normal NL NF CN"`.

    其实上述方法只能修改刻度上的字体, 其他的比如说标题在windows下用的是`Trebuchet MS`, 在苹果下用的是`-apple-system, BlinkMacSystemFont`, 我们只需要将所有文件中`-apple-system`替换为`"Maple Mono Normal NL NF CN"`即可.

## 其他方法


1. WePE下直接把制作好的字体拖过去
2. 安全模式下使用`xcopy`命令: 进入安全模式方法, 1)按住shift重启; 2)设置, 系统, 恢复, 高级启动重新启动; 3)系统配置, 引导, 安全引导, 选择最小, 应用, 完成操作后, 需要取消勾选安全引导改回来; 4)连续强制关机3次. 进入安全模式后, win+R输, cmd, 然后Ctrl+Shift+Enter, 以管理员身份打开, 执行命令:

    ```bat
    set "SRC=%USERPROFILE%\Downloads\font_replace"

    dir "%SRC%"

    for %F in ("%SRC%\*.*") do if exist "C:\Windows\Fonts\%~nxF" takeown /F "C:\Windows\Fonts\%~nxF" /A
    for %F in ("%SRC%\*.*") do if exist "C:\Windows\Fonts\%~nxF" icacls "C:\Windows\Fonts\%~nxF" /grant *S-1-5-32-544:F
    xcopy "%SRC%\*.*" "C:\Windows\Fonts\" /Y /H /R
    ```

    注意将`font_replace`替换为字体文件夹的名字. 

3. 使用"字体替换工具 by 随风飘扬"替换: https://www.fishlee.net/soft/SysFontReplacer/
4. 使用noMeiryoUI替换: https://github.com/Tatsu-syo/noMeiryoUI
5. 使用pendandmoves替换: 使用的script:

    ```powsershell
    #Requires -RunAsAdministrator

    $BaseDir = "C:\Users\610184\Downloads\pendmoves"
    $ReplaceDir = "$BaseDir\replace"
    $SystemFontDir = "C:\Windows\Fonts"

    $TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $WorkDir = "C:\FontSwap\$TimeStamp"
    $BackupDir = "$WorkDir\backup"
    $StagingDir = "$WorkDir\staging"

    $MoveFile = "$BaseDir\movefile64.exe"
    $PendMoves = "$BaseDir\pendmoves64.exe"

    if (!(Test-Path $MoveFile)) {
        $MoveFile = "$BaseDir\movefile.exe"
    }

    if (!(Test-Path $PendMoves)) {
        $PendMoves = "$BaseDir\pendmoves.exe"
    }

    if (!(Test-Path $MoveFile)) {
        Write-Error "movefile64.exe/movefile.exe not found."
        exit 1
    }

    New-Item -ItemType Directory -Force $BackupDir | Out-Null
    New-Item -ItemType Directory -Force $StagingDir | Out-Null

    function Add-FontReplaceTask {
        param(
            [string]$FontName
        )

        $ReplaceFont = Join-Path $ReplaceDir $FontName
        $SystemFont = Join-Path $SystemFontDir $FontName
        $BackupFont = Join-Path $BackupDir $FontName
        $StagingFont = Join-Path $StagingDir $FontName

        Write-Host ""
        Write-Host "===== $FontName ====="

        if (!(Test-Path $ReplaceFont)) {
            Write-Host "SKIP: replace font not found: $ReplaceFont"
            return
        }

        if (!(Test-Path $SystemFont)) {
            Write-Host "SKIP: system font not found: $SystemFont"
            return
        }

        Copy-Item -Force $ReplaceFont $StagingFont

        Write-Host "Add backup task:"
        Write-Host "$SystemFont -> $BackupFont"
        & $MoveFile -accepteula $SystemFont $BackupFont

        Write-Host "Add replace task:"
        Write-Host "$StagingFont -> $SystemFont"
        & $MoveFile -accepteula $StagingFont $SystemFont
    }

    Add-FontReplaceTask "consola.ttf"
    Add-FontReplaceTask "consolab.ttf"
    Add-FontReplaceTask "consolai.ttf"
    Add-FontReplaceTask "consolaz.ttf"

    Add-FontReplaceTask "msyh.ttc"
    Add-FontReplaceTask "msyhbd.ttc"
    Add-FontReplaceTask "msyhbdIt.ttc"
    Add-FontReplaceTask "msyhIt.ttc"
    Add-FontReplaceTask "msyhl.ttc"
    Add-FontReplaceTask "msyhlIt.ttc"
    Add-FontReplaceTask "msyhmd.ttc"
    Add-FontReplaceTask "msyhmdit.ttc"
    Add-FontReplaceTask "msyhsb.ttc"
    Add-FontReplaceTask "msyhsbit.ttc"
    Add-FontReplaceTask "msyhxb.ttc"
    Add-FontReplaceTask "msyhxbit.ttc"
    Add-FontReplaceTask "msyhxl.ttc"
    Add-FontReplaceTask "msyhxlit.ttc"

    Add-FontReplaceTask "segoepr.ttf"
    Add-FontReplaceTask "segoeprb.ttf"
    Add-FontReplaceTask "segoesc.ttf"
    Add-FontReplaceTask "segoescb.ttf"
    Add-FontReplaceTask "segoeui.ttf"
    Add-FontReplaceTask "segoeuib.ttf"
    Add-FontReplaceTask "segoeuii.ttf"
    Add-FontReplaceTask "segoeuil.ttf"
    Add-FontReplaceTask "segoeuisl.ttf"
    Add-FontReplaceTask "segoeuiz.ttf"

    Add-FontReplaceTask "seguibl.ttf"
    Add-FontReplaceTask "seguibli.ttf"
    Add-FontReplaceTask "seguihis.ttf"
    Add-FontReplaceTask "seguili.ttf"
    Add-FontReplaceTask "seguisb.ttf"
    Add-FontReplaceTask "seguisbi.ttf"
    Add-FontReplaceTask "seguisli.ttf"
    Add-FontReplaceTask "SegUIVar.ttf"

    Write-Host ""
    Write-Host "========================================"
    Write-Host "All pending font replace tasks submitted."
    Write-Host "Backup dir:"
    Write-Host $BackupDir
    Write-Host "Staging dir:"
    Write-Host $StagingDir
    Write-Host "========================================"

    if (Test-Path $PendMoves) {
        Write-Host ""
        Write-Host "Current pending move tasks:"
        & $PendMoves
    } else {
        Write-Host "pendmoves not found, skip checking pending tasks."
    }

    Write-Host ""
    Write-Host "After confirming pending tasks, reboot with:"
    Write-Host "shutdown /r /t 0"
    ```
