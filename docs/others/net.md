---
title: 科学上网
comments: true
---

## Vless+Reality+Vision配置

使用https://github.com/XTLS/RealiTLScanner根据当前的ip搜索目标网站, https://github.com/V2RaySSR/RealityChecker用于检查网站是否符合要求. 不要使用跳转域名, 如tesla.com会跳转到www.tesla.com, 我们要使用的是www.tesla.com. 目标网站必须支持TLS1.3, x25519, h2. 不要使用带有CDN的网站. 

```
./RealiTLScanner-linux-64 -port 443 -thread 100 -timeout 5 -out sites.csv -addr [VPS的IP]
./reality-checker csv sites.csv
```

