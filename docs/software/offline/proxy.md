## 代理

```
export HTTP_PROXY=http://127.0.0.1:65505
export HTTPS_PROXY=http://127.0.0.1:65505
export http_proxy=http://127.0.0.1:65505
export https_proxy=http://127.0.0.1:65505
```

然后在windows上面v2rayN设置tun模式下开启额外端口, 监听10808, 然后通过SSH隧道将服务器上的65505端口转发到本地的10808端口. 
