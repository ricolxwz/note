---
title: 安装
comments: true
---

# 安装

## 服务端

### SSL证书

请见[这里](/software/frp/tls#生成服务端证书).

### `frps.toml`文件

```toml
bindAddr = "0.0.0.0"
bindPort = 5440
quicBindPort = 5440
auth.token = "<请填入token>"
transport.tls.force = true
transport.tls.certFile = "/etc/frp/ssl/server.crt"
transport.tls.keyFile = "/etc/frp/ssl/server.key"
transport.tls.trustedCaFile = "/etc/frp/ssl/ca.crt"
allowPorts = [
  {start = 60000, end = 65535}
]
```

## 客户端

目前客户端主要用的是Mac Mini.

### 准备

```
docker network create --subnet=172.18.0.0/24 app
```

### SSL证书

请见[这里](/software/frp/tls#生成客户端证书).

### `frpc.toml`文件

```toml
serverAddr = "<请填入地址>"
serverPort = 5440
auth.token = "<请填入token>"
transport.protocol = "quic"
transport.tls.enable = true
transport.tls.certFile = "/etc/frp/ssl/client.crt"
transport.tls.keyFile = "/etc/frp/ssl/client.key"
transport.tls.trustedCaFile = "/etc/frp/ssl/ca.crt"

[[proxies]]
name = "alist"
type = "tcp"
localIP = "alist"
localPort = 5244
remotePort = 60001
```
