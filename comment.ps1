# 处理 research/chg/ 目录下的所有 .md 文件
Get-ChildItem -Path "C:\Users\wenzexu\note\docs\research\chg" -Recurse -Filter "*.md" | ForEach-Object {
    $lines = Get-Content $_.FullName
    if ($lines.Count -ge 3) {
        $lines[2] = "# level: chg"
        Set-Content $_.FullName $lines
    }
}

# 处理 mkdocs.yml 文件
$mkdocsFile = "C:\Users\wenzexu\note\mkdocs.yml"
$mkdocsLines = Get-Content $mkdocsFile

$inExcludeDocs = $false
$updatedLines = @()

foreach ($line in $mkdocsLines) {
    # 检测 exclude_docs 块开始
    if ($line -match "^\s*exclude_docs:\s*\|") {
        $inExcludeDocs = $true
        $updatedLines += $line
        continue
    }
    
    if ($inExcludeDocs) {
        # 如果该行没有至少两个空格的缩进，说明已超出 exclude_docs 块
        if ($line -notmatch "^\s{2,}") {
            $inExcludeDocs = $false
        }
    }
    
    # 如果在 exclude_docs 块内且行以注释的斜杠开头，则取消注释
    if ($inExcludeDocs -and $line -match "^\s*#\s*(/.*)") {
        $line = "  " + $matches[1]
    }
    
    $updatedLines += $line
}

# 将修改后的内容写回 mkdocs.yml
Set-Content -Path $mkdocsFile -Value $updatedLines
