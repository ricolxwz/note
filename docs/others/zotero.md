---
title: Zotero配置
comments: true
---

## Better BibLatex

设置不要导出的字段: annotation,abstract,note,file,keywords,pubstate,langid,urldate

## 导出所有的pdf

```powershell
# 1. 定义源文件夹和目标文件夹
$sourcePath = "C:\Users\wenzexu\Downloads\导出的条目"      # 替换为实际源文件夹路径
$targetPath = "C:\Users\wenzexu\Downloads\整理的文件"      # 替换为实际目标文件夹路径

# 2. 如果目标文件夹不存在，则创建它
if (!(Test-Path -Path $targetPath)) {
    New-Item -ItemType Directory -Path $targetPath | Out-Null
}

# 3. 递归搜索源文件夹下的所有 .pdf 文件
Get-ChildItem -Path $sourcePath -Recurse -Include *.pdf | ForEach-Object {

    # 构造移动目标文件的完整路径（文件名保持不变）
    $targetFile = Join-Path $targetPath $_.Name

    # ---------- 可选的重名处理示例 ----------
    # 如果你想要在发生同名文件时重新命名而不是覆盖，可以启用以下逻辑:
    # if (Test-Path $targetFile) {
    #     # 如若发现已存在同名文件，则为文件名添加时间戳后缀
    #     $fileName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
    #     $extension = [System.IO.Path]::GetExtension($_.Name)
    #     $timeStamp = Get-Date -Format "yyyyMMdd-HHmmss"
    #     $newName = $fileName + "_" + $timeStamp + $extension
    #     $targetFile = Join-Path $targetPath $newName
    # }

    # 4. 移动文件到目标文件夹
    Move-Item -Path $_.FullName -Destination $targetFile
}

Write-Host "所有 PDF 文件已移动完成！"
```