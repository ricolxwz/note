---
title: 请求流程
comments: true
---

## 不良林讲解

https://www.youtube.com/watch?v=BAfbkLizFGc&t=77s.

```json
{
  "log": {
    "disabled": false,
    "level": "warn",
    "output": "/var/run/homeproxy/sing-box-c.log",
    "timestamp": true
  },
  "dns": {
    "servers": [
      {
        "tag": "default-dns",
        "address": "223.5.5.5",
        "detour": "direct-out"
      },
      {
        "tag": "system-dns",
        "address": "local",
        "detour": "direct-out"
      },
      {
        "tag": "block-dns",
        "address": "rcode://name_error"
      },
      {
        "tag": "google",
        "address": "https://dns.google/dns-query",
        "address_resolver": "default-dns",
        "address_strategy": "ipv4_only",
        "strategy": "ipv4_only",
        "client_subnet": "1.0.1.0"
      }
    ],
    "rules": [
      {
        "outbound": "any",
        "server": "default-dns"
      },
      {
        "query_type": "HTTPS",
        "server": "block-dns"
      },
      {
        "clash_mode": "direct",
        "server": "default-dns"
      },
      {
        "clash_mode": "global",
        "server": "google"
      },
      {
        "rule_set": "cnsite",
        "server": "default-dns"
      }
    ],
    "strategy": "ipv4_only",
    "disable_cache": false,
    "disable_expire": false,
    "independent_cache": false,
    "final": "google"
  },
  "inbounds": [
    {
      "type": "direct",
      "tag": "dns-in",
      "listen": "::",
      "listen_port": 5333
    },
    {
      "type": "mixed",
      "tag": "mixed-in",
      "listen": "::",
      "listen_port": 5330,
      "sniff": true,
      "sniff_override_destination": false,
      "set_system_proxy": false
    },
    {
      "type": "redirect",
      "tag": "redirect-in",
      "listen": "::",
      "listen_port": 5331,
      "sniff": true,
      "sniff_override_destination": false
    },
    {
      "type": "tproxy",
      "tag": "tproxy-in",
      "listen": "::",
      "listen_port": 5332,
      "network": "udp",
      "sniff": true,
      "sniff_override_destination": false
    }
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct-out"
    },
    {
      "type": "block",
      "tag": "block-out"
    },
    {
      "type": "dns",
      "tag": "dns-out"
    },
    {
      "type": "urltest",
      "tag": "自动选择",
      "outbounds": [
        "香港",
        "日本",
        "美国"
      ]
    },
    {
      "type": "selector",
      "tag": "手动选择",
      "outbounds": [
        "direct-out",
        "block-out",
        "自动选择",
        "香港",
        "日本",
        "美国"
      ],
      "default": "自动选择"
    },
    {
      "type": "selector",
      "tag": "GLOBAL",
      "outbounds": [
        "direct-out",
        "香港",
        "日本",
        "美国"
      ],
      "default": "手动选择"
    },
    {
      "type": "shadowsocks",
      "tag": "香港",
      "server": "abc.com",
      "server_port": 10001,
      "password": "fdc43e321a",
      "method": "aes-128-gcm"
    },
    {
      "type": "shadowsocks",
      "tag": "日本",
      "server": "abc.com",
      "server_port": 10002,
      "password": "fdc43e321a",
      "method": "aes-128-gcm"
    },
    {
      "type": "shadowsocks",
      "tag": "美国",
      "server": "abc.com",
      "server_port": 10003,
      "password": "fdc43e321a",
      "method": "aes-128-gcm"
    }
  ],
  "route": {
    "rules": [
      {
        "inbound": "dns-in",
        "outbound": "dns-out"
      },
      {
        "protocol": "dns",
        "outbound": "dns-out"
      },
      {
        "protocol": "quic",
        "outbound": "block-out"
      },
      {
        "clash_mode": "direct",
        "outbound": "direct-out"
      },
      {
        "clash_mode": "global",
        "outbound": "GLOBAL"
      },
      {
        "rule_set": [
          "cnip",
          "cnsite"
        ],
        "outbound": "direct-out"
      }
    ],
    "rule_set": [
      {
        "type": "remote",
        "tag": "cnip",
        "format": "binary",
        "url": "https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo-lite/geoip/cn.srs",
        "download_detour": "自动选择"
      },
      {
        "type": "remote",
        "tag": "cnsite",
        "format": "binary",
        "url": "https://github.com/MetaCubeX/meta-rules-dat/raw/sing/geo-lite/geosite/cn.srs",
        "download_detour": "自动选择"
      }
    ],
    "auto_detect_interface": true,
    "final": "手动选择"
  },
  "experimental": {
    "cache_file": {
      "enabled": true,
      "path": "/etc/homeproxy/cache.db"
    },
    "clash_api": {
      "external_controller": "192.168.2.1:9090",
      "external_ui": "/etc/homeproxy/ui/",
      "external_ui_download_detour": "自动选择",
      "default_mode": "rule"
    }
  }
}
```

1. 假设需要经过dns请求获取google.com的地址
2. inbound模块: singbox从inbound收到dns请求
3. route模块: 如果请求是从dns-in进来的, 从tag为dns-out的outbound出去
4. outbound模块: dns-out的type是dns, 所以转发给dns模块
5. dns模块: 按照规则选择哪个dns服务器, 发现一个都不符合, 直接选择final dns服务器google
6. dns模块: google这个dns服务器的地址是域名, 新建一个查询dns.google的dns请求
7. dns模块: 发现google这个dns服务器的address_resolver是default-dns
8. dns模块: 该查询dns.google的请求发给default-dns服务器, 114.114.114.114, default-dns的detour是direct-out
9. outbound模块: 该dns.google的查询请求通过direct出站发送给114.114.114.114, 如此我们获取了8.8.8.8
10. dns模块: 由于我们没有为google这个dns服务器设置detour, 所以会使用默认出站
11. route模块: 选择默认出站
12. outbound模块: 默认出站是"手动选择", 跳到"手动选择"出战, 发现默认是"自动选择", 跳到"自动选择"
13. outbound模块: "自动选择"出站要测试延迟, 假设选中了"香港", 跳到"香港"出站
14. outbound模块: "香港"出战, 进行aes加密, 此时, 发现, 服务器的地址是域名, 跳到dns模块
15. dns模块: 该dns请求匹配到了第一个rule, outbound是any
16. dns模块: 交给default-dns解析, 返回"香港"的ip为6.6.6.6
17. outbound模块: 这条经过aes加密的数据会发送到6.6.6.6
18. 服务器: 收到这条数据后, 解密, 将数据转发给8.8.8.8, 将结果返回服务器, 然后返回给电脑浏览器, 假设结果是2.2.2.2
19. inbounds模块: 经过redirect进站, 由于开启了sniff, 获取到了访问的目标域名是google.com(因为请求的地址已经被修改为2.2.2.2了)
20. route模块: 命中final, 走"手动选择"
21. outbound模块: 手动选择, 自动选择 -> 香港节点, 已经获取到了abc.com的ip是6.6.6.6, 所以不用发dns请求, aes加密, 发送给6.6.6.6
22. 服务器: 收到这条数据, 解密, ....
