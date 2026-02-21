---
title: 加密内容
comments: true
---

# 加密内容

## 提交前自动上锁

将下列内容保存为`.git/hooks/pre-commit`:

```bash
#!/bin/bash
files=$(git diff --cached --name-only | xargs grep -l '# level: chg')
for file in $files; do
    sed -i.bak '/# level: chg/s/^[[:space:]]*# *//' "$file"
    git add "$file"
    rm "${file}.bak"
done
```
