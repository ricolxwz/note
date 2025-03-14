Get-ChildItem -Path "C:\Users\wenzexu\ml\docs\research\chg" -Recurse -Filter "*.md" | ForEach-Object {
    $lines = Get-Content $_.FullName
    if ($lines.Count -ge 3) {
        $lines[2] = "# level: chg"
        Set-Content $_.FullName $lines
    }
}
