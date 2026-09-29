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

    ```powershell
    #Requires -RunAsAdministrator

    $BaseDir = "C:\Users\610184\Downloads\pendmoves"
    $ReplaceDir = Join-Path $BaseDir "replace"
    $SystemFontDir = "C:\Windows\Fonts"

    $TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $WorkDir = "C:\FontSwap\$TimeStamp"
    $BackupDir = Join-Path $WorkDir "backup"
    $StagingDir = Join-Path $WorkDir "staging"

    $MoveFile = Join-Path $BaseDir "movefile64.exe"
    $PendMoves = Join-Path $BaseDir "pendmoves64.exe"

    if (!(Test-Path -LiteralPath $MoveFile -PathType Leaf)) {
        $MoveFile = Join-Path $BaseDir "movefile.exe"
    }

    if (!(Test-Path -LiteralPath $PendMoves -PathType Leaf)) {
        $PendMoves = Join-Path $BaseDir "pendmoves.exe"
    }

    if (!(Test-Path -LiteralPath $MoveFile -PathType Leaf)) {
        throw "movefile64.exe/movefile.exe not found."
    }

    if (!(Test-Path -LiteralPath $ReplaceDir -PathType Container)) {
        throw "Replace directory not found: $ReplaceDir"
    }

    # Windows字体文件的常见扩展名
    $FontExtensions = @(".ttf", ".ttc", ".otf", ".otc", ".fon", ".fnt")
    $Fonts = @(Get-ChildItem -LiteralPath $ReplaceDir -File |
        Where-Object { $FontExtensions -contains $_.Extension.ToLowerInvariant() })

    if ($Fonts.Count -eq 0) {
        throw "No font files found in: $ReplaceDir"
    }

    New-Item -ItemType Directory -Force -Path $BackupDir, $StagingDir | Out-Null

    $Submitted = 0
    $Skipped = 0
    $Failed = 0

    foreach ($Font in $Fonts) {
        $FontName = $Font.Name
        $SystemFont = Join-Path $SystemFontDir $FontName
        $BackupFont = Join-Path $BackupDir $FontName
        $StagingFont = Join-Path $StagingDir $FontName

        Write-Host ""
        Write-Host "===== $FontName ====="

        if (!(Test-Path -LiteralPath $SystemFont -PathType Leaf)) {
            Write-Host "SKIP: system font not found: $SystemFont"
            $Skipped++
            continue
        }

        try {
            Copy-Item -LiteralPath $Font.FullName -Destination $StagingFont -ErrorAction Stop
        } catch {
            Write-Warning "Failed to stage $FontName`: $_"
            $Failed++
            continue
        }

        Write-Host "Add backup task: $SystemFont -> $BackupFont"
        & $MoveFile -accepteula $SystemFont $BackupFont
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Backup task failed for $FontName; replace task skipped."
            $Failed++
            continue
        }

        Write-Host "Add replace task: $StagingFont -> $SystemFont"
        & $MoveFile -accepteula $StagingFont $SystemFont
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Replace task failed for $FontName. Check pending tasks before rebooting."
            $Failed++
            continue
        }

        $Submitted++
    }

    Write-Host ""
    Write-Host "========================================"
    Write-Host "Submitted: $Submitted; Skipped: $Skipped; Failed: $Failed"
    Write-Host "Backup dir: $BackupDir"
    Write-Host "Staging dir: $StagingDir"
    Write-Host "========================================"

    if (Test-Path -LiteralPath $PendMoves -PathType Leaf) {
        Write-Host ""
        Write-Host "Current pending move tasks:"
        & $PendMoves
    } else {
        Write-Host "pendmoves not found; pending tasks could not be displayed."
    }

    Write-Host ""
    Write-Host "After checking pending tasks, reboot with:"
    Write-Host "shutdown /r /t 0"
    ```

    GPT-6 Astra写个一个小脚本: 不依赖pendmoves.exe, 直接调用MoveFileExW API.

    ```powershell
    #Requires -RunAsAdministrator
    <#
    Run in 64-bit Windows PowerShell 5.1 (powershell.exe), as administrator.
    Schedule: .\FontSwap-Safe.ps1
    Verify after restart: .\FontSwap-Safe.ps1 -Mode Verify -RunDir 'C:\FontSwap\RUN'
    
    No automatic restart, deletion of original fonts, taking ownership, or editing
    existing pending tasks. Backups are copied and verified before ANY scheduling.
    Each font uses ONE MoveFileExW request with flags 0x5 (delayed replacement).
    This is not a transaction across fonts; partial scheduling is reported.
    Font headers are checked, not family names, glyph coverage or visual suitability.
    Backups preserve file bytes; target DACL is saved and applied to staged files.
    Original owner/SACL and Windows servicing metadata are NOT cloned.
    #>
    [CmdletBinding()]
    param(
        [ValidateSet('Schedule', 'Verify')]
        [string]$Mode = 'Schedule',
        [string]$BaseDir = 'C:\Users\610184\Downloads\pendmoves',
        [string]$RunDir
    )
    
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'
    if ($PSVersionTable.PSEdition -ne 'Desktop' -or -not [Environment]::Is64BitProcess) {
        throw 'Use 64-bit Windows PowerShell 5.1 (powershell.exe), as administrator.'
    }
    $SystemFontDir = Join-Path $env:windir 'Fonts'
    $FontPrefix = $SystemFontDir.TrimEnd('\') + '\'
    
    function Get-Sha256([string]$Path) {
        (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
    }
    
    function Convert-PendingPath([string]$Path) {
        $p = $Path.TrimStart('!')
        if ($p.StartsWith('\??\')) { $p = $p.Substring(4) }
        if ($p.StartsWith('\\?\')) { $p = $p.Substring(4) }
        return $p
    }
    
    function Get-PendingFontTasks {
        $key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey(
            'SYSTEM\CurrentControlSet\Control\Session Manager')
        if ($null -eq $key) { throw 'Cannot read Session Manager registry key.' }
        try {
            foreach ($valueName in @('PendingFileRenameOperations', 'PendingFileRenameOperations2')) {
                $raw = $key.GetValue($valueName)
                if ($null -eq $raw) { continue }
                if ($raw -isnot [string[]] -or ($raw.Count % 2) -ne 0) {
                    throw "Unexpected pending queue format: $valueName. Inspect it manually."
                }
                for ($i = 0; $i -lt $raw.Count; $i += 2) {
                    $src = Convert-PendingPath $raw[$i]
                    $dst = Convert-PendingPath $raw[$i + 1]
                    if ($src.StartsWith($FontPrefix, [StringComparison]::OrdinalIgnoreCase) -or
                        $dst.StartsWith($FontPrefix, [StringComparison]::OrdinalIgnoreCase)) {
                        [pscustomobject]@{ Queue = $valueName; Source = $src; Target = $dst }
                    }
                }
            }
        } finally { $key.Dispose() }
    }
    
    function Assert-NoPendingFonts {
        $pending = @(Get-PendingFontTasks)
        if ($pending.Count -gt 0) {
            $pending | Format-List | Out-Host
            throw 'Existing font tasks found. Nothing new was scheduled. Inspect old tasks first; do not blindly reboot if an old task only moves a font away.'
        }
    }
    
    function Assert-RegularLocalPath([string]$Path) {
        $item = Get-Item -LiteralPath $Path -Force
        while ($null -ne $item) {
            if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
                throw "Reparse points are not supported: $($item.FullName)"
            }
            if ($item -is [IO.FileInfo]) { $item = $item.Directory }
            else { $item = $item.Parent }
        }
    }
    
    function Assert-FontHeader([string]$Path) {
        $stream = [IO.File]::OpenRead($Path)
        try {
            $bytes = New-Object byte[] 4
            if ($stream.Length -lt 12 -or $stream.Read($bytes, 0, 4) -ne 4) {
                throw "Font is too short: $Path"
            }
            $sig = [BitConverter]::ToString($bytes)
            $ext = [IO.Path]::GetExtension($Path).ToLowerInvariant()
            $allowed = @('00-01-00-00', '4F-54-54-4F', '74-72-75-65', '74-79-70-31')
            if ($ext -in @('.ttc', '.otc')) { $allowed = @('74-74-63-66') }
            if ($sig -notin $allowed) { throw "Unexpected font header: $Path ($sig)" }
        } finally { $stream.Dispose() }
    }
    
    function Save-Manifest {
        $temp = $script:ManifestPath + '.tmp'
        $script:Manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $temp -Encoding UTF8
        Move-Item -LiteralPath $temp -Destination $script:ManifestPath -Force
    }
    
    if ($Mode -eq 'Verify') {
        if ([string]::IsNullOrWhiteSpace($RunDir)) { throw 'Verify requires -RunDir.' }
        $manifest = Get-Content -LiteralPath (Join-Path $RunDir 'manifest.json') -Raw | ConvertFrom-Json
        $pending = @(Get-PendingFontTasks)
        $bad = 0
        $report = foreach ($entry in $manifest.Fonts) {
            $exists = Test-Path -LiteralPath $entry.Target -PathType Leaf
            $actual = if ($exists) { Get-Sha256 $entry.Target } else { '' }
            $backupOK = (Test-Path -LiteralPath $entry.Backup -PathType Leaf) -and
                ((Get-Sha256 $entry.Backup) -eq $entry.OriginalHash)
            $hasPending = @($pending | Where-Object {
                $_.Source -eq $entry.Target -or $_.Target -eq $entry.Target
            }).Count -gt 0
            $result = if ($hasPending) { 'PENDING' }
                elseif (-not $exists) { 'MISSING' }
                elseif ($actual -eq $entry.NewHash) { 'MATCH' }
                elseif ($actual -eq $entry.OriginalHash) { 'ORIGINAL' }
                else { 'DIFFERENT' }
            if ($result -ne 'MATCH' -or -not $backupOK) { $bad++ }
            [pscustomobject]@{ Font = $entry.Name; Result = $result; BackupOK = $backupOK }
        }
        $report | Format-Table -AutoSize | Out-Host
        if ($bad -gt 0) { throw 'Verification incomplete or failed. Keep backups and inspect the results.' }
        Write-Host 'All target hashes match the replacements; all backups match the originals.' -ForegroundColor Green
        Write-Host 'Also check font rendering in your applications. Hash verification does not validate appearance.'
        return
    }
    
    if ($RunDir) { throw '-RunDir is only used with -Mode Verify.' }
    $mutex = New-Object Threading.Mutex($false, 'Global\FontSwapSafeScheduleV1')
    $locked = $false
    $submitted = 0
    try {
        try { $locked = $mutex.WaitOne(0) }
        catch [Threading.AbandonedMutexException] { $locked = $true }
        if (-not $locked) { throw 'Another FontSwap-Safe instance is running.' }
        Assert-NoPendingFonts
        $replaceDir = Join-Path $BaseDir 'replace'
        if (-not (Test-Path -LiteralPath $replaceDir -PathType Container)) {
            throw "Replace directory not found: $replaceDir"
        }
        $allFiles = @(Get-ChildItem -LiteralPath $replaceDir -File)
        if (@($allFiles | Where-Object { $_.Extension.ToLowerInvariant() -in @('.fon', '.fnt') }).Count) {
            throw 'Legacy .fon/.fnt fonts are not supported by this version. Remove them from replace.'
        }
        $fonts = @($allFiles | Where-Object {
            $_.Extension.ToLowerInvariant() -in @('.ttf', '.ttc', '.otf', '.otc')
        } | Sort-Object Name)
        if (-not $fonts.Count) { throw "No supported fonts found in $replaceDir" }
    
        # Validate all targets BEFORE preparing or scheduling any replacement.
        foreach ($font in $fonts) {
            $target = Join-Path $SystemFontDir $font.Name
            if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
                throw "System font not found: $target. This script replaces existing files only."
            }
            Assert-RegularLocalPath $target
            Assert-RegularLocalPath $font.FullName
            Assert-FontHeader $font.FullName
            $attributes = (Get-Item -LiteralPath $target -Force).Attributes
            if (($attributes -band [IO.FileAttributes]::ReadOnly) -ne 0) {
                throw "Read-only target: $target. Attributes will not be changed automatically."
            }
        }
    
        $workRoot = Join-Path ([IO.Path]::GetPathRoot($env:windir)) 'FontSwap'
        New-Item -ItemType Directory -Path $workRoot -Force | Out-Null
        Assert-RegularLocalPath $workRoot
        $runName = (Get-Date -Format 'yyyy-MM-dd_HH-mm-ss-fff') + '_' + [guid]::NewGuid().ToString('N').Substring(0, 8)
        $RunDir = Join-Path $workRoot $runName
        New-Item -ItemType Directory -Path $RunDir | Out-Null
        # Protect manifests/backups/staging from modification by ordinary users.
        $dirAcl = New-Object Security.AccessControl.DirectorySecurity
        $dirAcl.SetSecurityDescriptorSddlForm('O:BAG:BAD:P(A;OICI;FA;;;SY)(A;OICI;FA;;;BA)')
        Set-Acl -LiteralPath $RunDir -AclObject $dirAcl
        $backupDir = Join-Path $RunDir 'backup'
        $stagingDir = Join-Path $RunDir 'staging'
        New-Item -ItemType Directory -Path $backupDir, $stagingDir | Out-Null
        $script:ManifestPath = Join-Path $RunDir 'manifest.json'
        $entries = @()
    
        foreach ($font in $fonts) {
            $target = Join-Path $SystemFontDir $font.Name
            $backup = Join-Path $backupDir $font.Name
            $staged = Join-Path $stagingDir $font.Name
            $oldHash = Get-Sha256 $target
            $newHash = Get-Sha256 $font.FullName
            Copy-Item -LiteralPath $target -Destination $backup
            Copy-Item -LiteralPath $font.FullName -Destination $staged
            if ((Get-Sha256 $backup) -ne $oldHash -or (Get-Sha256 $target) -ne $oldHash) {
                throw "Backup hash mismatch: $($font.Name)"
            }
            if ((Get-Sha256 $staged) -ne $newHash) { throw "Staging hash mismatch: $($font.Name)" }
            [IO.File]::SetAttributes($staged, [IO.FileAttributes]::Normal)
            $originalAcl = Get-Acl -LiteralPath $target
            $dacl = $originalAcl.GetSecurityDescriptorSddlForm([Security.AccessControl.AccessControlSections]::Access)
            $fileAcl = New-Object Security.AccessControl.FileSecurity
            $fileAcl.SetSecurityDescriptorSddlForm($dacl, [Security.AccessControl.AccessControlSections]::Access)
            $fileAcl.SetAccessRuleProtection($true, $true)
            Set-Acl -LiteralPath $staged -AclObject $fileAcl
            # Ensure the staged file remains readable after setting its access rules.
            if ((Get-Sha256 $staged) -ne $newHash) { throw 'Staged font became unreadable or changed.' }
            $entries += [pscustomobject]@{
                Name = $font.Name; Target = $target; Backup = $backup; Staged = $staged
                OriginalHash = $oldHash; NewHash = $newHash; OriginalDacl = $dacl
                Status = 'Prepared'; Error = $null
            }
            Write-Host "Backed up and verified: $($font.Name)"
        }
        $script:Manifest = [pscustomobject]@{
            Version = 1; Created = (Get-Date).ToString('o'); RunDir = $RunDir; Fonts = $entries
        }
        Save-Manifest
    
        if (-not ('FontSwapSafe.Native' -as [type])) {
            Add-Type -TypeDefinition @'
    using System;
    using System.Runtime.InteropServices;
    namespace FontSwapSafe {
        public static class Native {
            [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true, ExactSpelling = true)]
            [return: MarshalAs(UnmanagedType.Bool)]
            public static extern bool MoveFileExW(string source, string destination, uint flags);
        }
    }
    '@
        }
        Assert-NoPendingFonts
        # Recheck the entire batch before its first queue operation.
        foreach ($entry in $entries) {
            if ((Get-Sha256 $entry.Target) -ne $entry.OriginalHash -or
                (Get-Sha256 $entry.Backup) -ne $entry.OriginalHash -or
                (Get-Sha256 $entry.Staged) -ne $entry.NewHash) {
                throw "File changed during preparation: $($entry.Name)"
            }
        }
        foreach ($entry in $entries) {
            # Persist intent BEFORE the native call, so an interrupted run is visible.
            $entry.Status = 'Submitting'
            Save-Manifest
            $ok = [FontSwapSafe.Native]::MoveFileExW($entry.Staged, $entry.Target, 5)
            if (-not $ok) {
                $code = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
                $entry.Status = 'SubmitFailed'
                $entry.Error = "Win32 error $code"
                Save-Manifest
                throw "Could not schedule $($entry.Name): Win32 error $code"
            }
            $submitted++
            $entry.Status = 'Scheduled'
            Save-Manifest
            Write-Host "Scheduled replacement: $($entry.Name)"
        }
        Write-Host "`nScheduled: $submitted. This is NOT proof of boot-time success."
        Write-Host "Backups and manifest: $RunDir"
        Get-PendingFontTasks | Format-List | Out-Host
        Write-Host 'Keep this run directory intact until after verification.'
        Write-Host 'When ready, restart Windows manually: shutdown /r /t 0'
        Write-Host "After restart: .\FontSwap-Safe.ps1 -Mode Verify -RunDir '$RunDir'"
    } catch {
        Write-Warning "Stopped. Successfully submitted in this run: $submitted."
        Write-Warning 'Previously submitted tasks remain queued; this script does not clear or roll back the system queue.'
        if ($RunDir) { Write-Warning "Keep this directory: $RunDir" }
        throw
    } finally {
        if ($locked) { $mutex.ReleaseMutex() }
        $mutex.Dispose()
    }
    ```
