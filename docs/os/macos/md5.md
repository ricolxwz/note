---
title: md5图片
comments: true
---

# md5图片

```shell
function fig() {
    local id="$1"
    local Fuzz1="${2:-2}"
    local Fuzz2="${3:-2}"

    local current_dir="$(pwd)"
    local snip_dir="$HOME/snip"

    # 获取最新文件（按修改时间倒序排序）
    local latest_file="$(ls -t "$snip_dir" 2>/dev/null | head -n 1)"
    if [[ -n "$latest_file" ]]; then
        local latest_file_path="$snip_dir/$latest_file"
        # 计算 MD5 值，并转换为小写
        local md5_hash="$(md5 -q "$latest_file_path" | tr '[:upper:]' '[:lower:]')"

        # 获取文件扩展名并转换为小写
        local filename="$(basename "$latest_file_path")"
        local extension="${filename##*.}"
        extension="$(echo "$extension" | tr '[:upper:]' '[:lower:]')"

        # 如果扩展名是 jpg, jpeg 或 png，则转换为 webp 格式
        if [[ "$extension" == "jpg" || "$extension" == "jpeg" || "$extension" == "png" ]]; then
            extension="webp"
            local new_name="${md5_hash}.${extension}"
            local new_path="$snip_dir/$new_name"
            magick "$latest_file_path" -quality 100 -define webp:lossless=true -fuzz "${Fuzz1}%" -fill white -opaque white "$new_path"
        else
            # 如果文件名与扩展名不同，则添加扩展名，否则仅使用 MD5 作为新文件名
            if [[ "$filename" != "$extension" ]]; then
                local new_name="${md5_hash}.${extension}"
            else
                local new_name="${md5_hash}"
            fi
            local new_path="$snip_dir/$new_name"
            mv "$latest_file_path" "$new_path"
        fi

        local original_url="https://img.ricolxwz.asia/${new_name}"
        local inverted_name="${md5_hash}_inverted.${extension}"
        local inverted_url="https://img.ricolxwz.asia/${inverted_name}"
        local inverted_path="$snip_dir/$inverted_name"

        # 创建反色图像
        magick "$new_path" -negate \
            -fuzz "${Fuzz2}%" -fill "rgb(18,19,23)" -opaque black \
            -fuzz "${Fuzz2}%" -fill "rgb(226,228,233)" -opaque white \
            -quality 100 \
            "$inverted_path"

        echo "Processed image: $new_name"

        # 自动选择上传操作（可修改为通过 read 获取用户输入）
        local upload_choice="y"
        if [[ "$upload_choice" =~ ^[Yy]$ || -z "$upload_choice" ]]; then
            echo "Starting upload operation..."
            # 上传操作：调用 wrangler 工具上传到 R2 对象存储
            # wrangler r2 object put "ricolxwz-image/$new_name" --file "$new_path"
            # wrangler r2 object put "ricolxwz-image/$inverted_name" --file "$inverted_path"
            ossutil cp "$new_path" "oss://ricolxwz-pic/$new_name"
            ossutil cp "$inverted_path" "oss://ricolxwz-pic/$inverted_name"
            echo "All upload operations completed."

            local figid="fig${id}"
            local capid="图${id}: "
            local text="<figure markdown='1' id='${figid}'>
![](${original_url}#only-light){ loading=lazy width='800' }
![](${inverted_url}#only-dark){ loading=lazy width='800' }
<figcaption>${capid}</figcaption>
</figure>"
            # 复制格式化文本到剪贴板（macOS 使用 pbcopy）
            echo "$text" | pbcopy
            echo "The formatted text has been copied to the clipboard. Please paste to save."

            # 回滚操作默认不执行，可修改为通过 read 获取用户输入
            local rollback_choice="n"
            if [[ "$rollback_choice" =~ ^[Yy]$ ]]; then
                echo "Starting rollback operation..."
                function Rollback() {
                    local file_name="$1"
                    # wrangler r2 object delete "ricolxwz-image/${file_name}"
                    ossutil rm "oss://ricolxwz-image/$file_name"
                }
                Rollback "$new_name"
                Rollback "$inverted_name"
                echo "Rollback operation completed."
            else
                echo "Rollback operation not performed."
            fi
        else
            echo "Upload operation not performed."
        fi

        cd "$current_dir"
    else
        echo "No files found."
    fi
}
```
