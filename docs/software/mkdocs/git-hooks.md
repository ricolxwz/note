---
title: Git Hooks
comments: true
---

```bash
#!/bin/bash

config_file="mkdocs.yml"
temp_file=$(mktemp)

# 修改 mkdocs.yml 中的 exclude_docs 配置
awk '
BEGIN {exclude_section=0}
/^exclude_docs:/ {exclude_section=1}
/^[[:space:]]*$/ {exclude_section=0}
{
  if (exclude_section && /^\s*\/.*\/\s*$/ && !/^\s*#/) {
    print "#" $0
  } else {
    print $0
  }
}
' "$config_file" > "$temp_file"

mv "$temp_file" "$config_file"

# 将修改后的 mkdocs.yml 添加到暂存区
git add "$config_file"

# 移除 docs/research/ 目录下所有文件的第三行注释
find docs/research/ -type f | while read -r file; do
  if [ $(wc -l < "$file") -ge 3 ]; then
    sed -i '3s/^\s*#\s*//' "$file"
    # 将修改后的文件添加到暂存区
    git add "$file"
  fi
done
```