---
title: TLS
comments: true
---

# 安全

## 双向TLS

### 生成服务端证书

```bash
set -x
# 获取服务器的外部ip
external_ip_v4=$(curl -4 -s ifconfig.me)
external_ip_v6=$(curl -6 -s ifconfig.me)
# 移除现有的所有证书文件
rm /home/wenzexu/man/frp/ssl/*
# 配置OpenSSL
mkdir -p /home/wenzexu/man/frp/ssl
echo "[ ca ]
default_ca = CA_default
[ CA_default ]
x509_extensions = usr_cert
[ req ]
default_bits        = 2048
default_md          = sha256
default_keyfile     = privkey.pem
distinguished_name  = req_distinguished_name
attributes          = req_attributes
x509_extensions     = v3_ca
string_mask         = utf8only
[ req_distinguished_name ]
[ req_attributes ]
[ usr_cert ]
basicConstraints       = CA:FALSE
nsComment              = "OpenSSL Generated Certificate"
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer
[ v3_ca ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints       = CA:true" > /home/wenzexu/man/frp/ssl/my-openssl.cnf

openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -subj "/CN=example.ca.com" -days 5000 -out ca.crt

openssl genrsa -out server.key 2048
openssl req -new -sha256 -key server.key \
    -subj "/C=XX/ST=DEFAULT/L=DEFAULT/O=DEFAULT/CN=server.com" \
    -reqexts SAN \
    -config <(cat my-openssl.cnf <(printf "\n[SAN]\nsubjectAltName=DNS:home.ricolxwz.download")) \
    -out server.csr
openssl x509 -req -days 365 -sha256 \
	-in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
	-extfile <(printf "subjectAltName=DNS:home.ricolxwz.download") \
	-out server.crt
```

### 生成客户端证书

```bash
set -x
# 移除现有的所有证书文件
rm /Users/wenzexu/man/frp/ssl/*
# 配置OpenSSL
mkdir -p /Users/wenzexu/man/frp/ssl
echo "[ ca ]
default_ca = CA_default
[ CA_default ]
x509_extensions = usr_cert
[ req ]
default_bits        = 2048
default_md          = sha256
default_keyfile     = privkey.pem
distinguished_name  = req_distinguished_name
attributes          = req_attributes
x509_extensions     = v3_ca
string_mask         = utf8only
[ req_distinguished_name ]
[ req_attributes ]
[ usr_cert ]
basicConstraints       = CA:FALSE
nsComment              = "OpenSSL Generated Certificate"
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer
[ v3_ca ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints       = CA:true" > /Users/wenzexu/man/frp/ssl/my-openssl.cnf

# 导入刚才生成的ca

openssl genrsa -out client.key 2048
openssl req -new -sha256 -key client.key \
    -subj "/C=XX/ST=DEFAULT/L=DEFAULT/O=DEFAULT/CN=client.com" \
    -reqexts SAN \
    -config <(cat my-openssl.cnf <(printf "\n[SAN]\nsubjectAltName=DNS:localhost,IP:127.0.0.1")) \
    -out client.csr

openssl x509 -req -days 365 -sha256 \
    -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
	-extfile <(printf "subjectAltName=DNS:localhost,IP:127.0.0.1") \
	-out client.crt
```
