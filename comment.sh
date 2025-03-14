#!/bin/zsh
# 定义目标目录（请根据实际情况修改路径）
target_dir="/Users/wenzexu/ml/docs/research/chg"

# 递归查找所有 .md 文件并处理
find "$target_dir" -type f -name "*.md" | while IFS= read -r file; do
    # 检查文件是否存在
    if [ -f "$file" ]; then
        echo "Processing $file"
        # 获取文件总行数
        line_count=$(wc -l < "$file")
        # 如果文件行数不少于 3 行，则替换第三行内容
        if [ "$line_count" -ge 3 ]; then
            sed -i '' '3s/.*/# level: chg/' "$file"
        else
            echo "File $file has less than 3 lines, skipping"
        fi
    else
        echo "File $file does not exist!"
    fi
done
