# 处理 research/chg/ 目录下的所有 .md 文件
Get-ChildItem -Path "C:\Users\wenzexu\note\docs\research\chg" -Recurse -Filter "*.md" | ForEach-Object {
    $lines = Get-Content $_.FullName
    if ($lines.Count -ge 3) {
        $lines[2] = "# level: chg"
        Set-Content $_.FullName $lines
    }
}

# 处理 mkdocs.yml 文件
$mkdocsFile = "C:\Users\wenzexu\ml\mkdocs.yml"
$mkdocsLines = Get-Content $mkdocsFile

$inExcludeDocs = $false
$updatedLines = @()

foreach ($line in $mkdocsLines) {
    if ($line -match "^\s*exclude_docs:\s*\|") {
        $inExcludeDocs = $true
        $updatedLines += $line
        continue
    } elseif ($inExcludeDocs -and $line -match "^\s*$") {
        $inExcludeDocs = $false
    }

    if ($inExcludeDocs -and $line -match "^\s*#\s*/") {
        $line = "  " + $line.TrimStart("#").Trim()
    }

    $updatedLines += $line
}

# 将修改后的内容写回 mkdocs.yml
Set-Content -Path $mkdocsFile -Value $updatedLines
