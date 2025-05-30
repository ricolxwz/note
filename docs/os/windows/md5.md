---
title: md5
comments: true
---

# md5

```powershell
function fig {
    param(
        [string]$id,
        [int]$Fuzz1 = 2,
        [int]$Fuzz2 = 2
    )
    $current_dir = Get-Location
    $snip_dir = "C:\Users\wenzexu\Pictures\Screenshots"
    $latest_file = Get-ChildItem -Path $snip_dir | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($latest_file) {
        $md5_hash = (Get-FileHash -Path $latest_file.FullName -Algorithm MD5).Hash.ToLower()
        $extension = $latest_file.Extension.TrimStart(".").ToLower()
        if ($extension -in @("jpg", "jpeg", "png")) {
            $extension = "webp"
            $new_name = "$md5_hash.$extension"
            $new_path = Join-Path $snip_dir $new_name
            magick "$($latest_file.FullName)" -quality 100 -define webp:lossless=true -fuzz "$Fuzz1%" -fill white -opaque white "$new_path"
        }
        else {
            if ($latest_file.Name -ne $extension) {
                $new_name = "$md5_hash.$extension"
            }
            else {
                $new_name = "$md5_hash"
            }
            $new_path = Join-Path $snip_dir $new_name
            Rename-Item -Path $latest_file.FullName -NewName $new_name
        }
        $original_url = "https://img.ricolxwz.download/$new_name"
        $inverted_name = "${md5_hash}_inverted.$extension"
        $inverted_url = "https://img.ricolxwz.download/$inverted_name"
        $inverted_path = Join-Path $snip_dir $inverted_name
        magick "$new_path" -negate `
            -fuzz "$Fuzz2%" -fill "rgb(18,19,23)" -opaque black `
            -fuzz "$Fuzz2%" -fill "rgb(226,228,233)" -opaque white `
            -quality 100 `
            "$inverted_path"
        Write-Output "Processed image: $new_name"
        # $upload_choice = Read-Host "Do you want to perform the upload operation? (Default no, enter y to proceed) [y/N]"
        $upload_choice = "y"
        if ($upload_choice -match '^[Yy]$' -or $upload_choice -eq '') {
            Write-Output "Starting upload operation..."
            try {
                # aws s3 cp "$new_path" "s3://ricolxwz-image/" --profile image
                # aws s3 cp "$inverted_path" "s3://ricolxwz-image/" --profile image
                wrangler r2 object put "ricolxwz-image/$new_name" --file "$new_path" --remote
                wrangler r2 object put "ricolxwz-image/$inverted_name" --file "$inverted_path" --remote
                Write-Output "All upload operations completed."
$figid = "fig$id"
$capid = "图${id}: "
$text = @"
<figure markdown='1' id='$figid'>
![]($($original_url)#only-light){ loading=lazy width='800' }
![]($($inverted_url)#only-dark){ loading=lazy width='800' }
<figcaption>$capid</figcaption>
</figure>
"@
            $text | Set-Clipboard
            Write-Output "The formatted text has been copied to the clipboard. Please paste to save."
            }
            catch {
                Write-Error "An error occurred during upload: $_"
                return
            }
            # $rollback_choice = Read-Host "Do you want to perform rollback operation? (Default no, enter y to proceed) [y/N]"
            $rollback_choice = "n"
            if ($rollback_choice -match '^[Yy]$') {
                Write-Output "Starting rollback operation..."
                function Rollback($file_name) {
                    try {
                        # aws s3 rm "s3://ricolxwz-image/$file_name" --profile image
                        wrangler r2 object delete "ricolxwz-image/$file_name"
                    }
                    catch {
                        Write-Error "An error occurred while rolling back ${file_name}: $_"
                    }
                }
                Rollback $new_name
                Rollback $inverted_name
                Write-Output "Rollback operation completed."
            }
            else {
                Write-Output "Rollback operation not performed."
            }
        }
        else {
            Write-Output "Upload operation not performed."
        }
        Set-Location $current_dir
    }
    else {
        Write-Host "No files found."
    }
}

```
