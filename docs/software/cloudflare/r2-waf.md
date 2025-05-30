---
title: R2对象存储防盗链
comments: true
---

# R2对象存储防盗链

## 只允许特定Referer/IP源访问

(http.host eq "share.ricolxwz.io" and not http.referer contains "ricolxwz.cc") or (http.host eq "rshare.ricolxwz.io" and ip.src ne 52.62.78.98) or (http.host eq "img.ricolxwz.download" and http.referer eq "") => Block

## 站内链接防护

(http.host eq "share.ricolxwz.io") => Managed Challenge

## 图片热链防护

符合下面这些条件的关闭热链防护:

(http.host eq "img.ricolxwz.download" and http.referer contains "ricolxwz.cc") or (http.host eq "img.ricolxwz.download" and http.referer contains "localhost:[port1]") or (http.host eq "img.ricolxwz.download" and http.referer contains "localhost:[port2]") => Disable Hotlink Protection

注意将图片热链防护打开.

## 关闭浏览器完整性检查

(http.host eq "rshare.ricolxwz.io") => Disable Integrity Check

## 缓存

- (http.host eq "img.ricolxwz.download") => Edge TTL: 1 year; Browser TTL: 1 year
- (http.host eq "rshare.ricolxwz.io") or (http.host eq "share.ricolxwz.io") => Edge TTL: Bypass cache; Broser TTL: Bypass Cache