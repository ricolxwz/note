---
title: Git Hooks
comments: true
---

```bash
#!/bin/bash

config_file="mkdocs.yml"
temp_file=$(mktemp)

awk '
BEGIN {exclude_section=0}
/^exclude_docs:/ {exclude_section=1}
/^$/ {exclude_section=0}
{
  if (exclude_section && /^\s*\/.*\//) {
    print "#" $0
  } else {
    print $0
  }
}
' "$config_file" > "$temp_file"

mv "$temp_file" "$config_file"
```