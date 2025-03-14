---
title: virtual-host-style
comments: true
---

# Virtual Host 风格

1. 定义容器的环境变量`MINIO_DOMAIN`为minio服务的主域名
2. 在DNS服务商添加一条DNS记录, 如`<bucket-name>.s3.example.com`, 指向minio服务的ip
3. 在nginx proxy manager里面添加一个虚拟主机`<bucket-name>.s3.example.com`, 指向minio容器的9000端口