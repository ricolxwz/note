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
        # 如果当前行非空且不匹配以可选 "#" 后跟斜杠开头的模式，则认为已超出 exclude_docs 块
        if ($line.Trim() -ne "" -and $line -notmatch "^\s*(#\s*)?\/") {
            $inExcludeDocs = $false
        }
    }
    
    # 如果在 exclude_docs 块内且行以注释的斜杠开头，则取消注释并添加两个空格缩进
    if ($inExcludeDocs -and $line -match "^\s*#\s*(/.*)") {
        $line = "  " + $matches[1]
    }
    
    $updatedLines += $line
}

# 将修改后的内容写回 mkdocs.yml
Set-Content -Path $mkdocsFile -Value $updatedLines
