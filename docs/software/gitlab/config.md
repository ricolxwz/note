---
title: 配置
comments: true
---

## Docker Compose配置

```yaml
services:
  gitlab:
    container_name: gitlab
    hostname: gitlab
    image: gitlab/gitlab-ce:latest
    restart: unless-stopped
    networks:
      - net
    ports:
      - 8090:8090
      - 8181:8181
      - 2222:22
    environment:
      GITLAB_ROOT_EMAIL: <填写>
      GITLAB_ROOT_PASSWORD: <填写>
      GITLAB_OMNIBUS_CONFIG: |
        external_url "https://git.ricolxwz.download"
        nginx['enable'] = false
        letsencrypt['enable'] = false
        gitlab_workhorse['listen_network'] = "tcp"
        gitlab_workhorse['listen_addr'] = "0.0.0.0:8181"
        gitlab_rails['trusted_proxies'] = [ '192.168.0.0/16' ]
        pages_external_url 'https://pages.ricolxwz.download'
        gitlab_pages['enable'] = true
        gitlab_pages['access_control'] = true
        gitlab_pages['external_http'] = ['0.0.0.0:8090']
        gitlab_pages['listen_proxy'] = nil
        gitlab_pages['inplace_chroot'] = true
        gitlab_pages['gitlab_server'] = 'https://git.ricolxwz.download'
        pages_nginx['enable'] = false
    volumes:
      - /root/gitlab/config:/etc/gitlab
      - /root/gitlab/logs:/var/log/gitlab
      - /root/gitlab/data:/var/opt/gitlab
      - /mnt/hdd/shared:/var/opt/gitlab/gitlab-rails/shared
      - /mnt/hdd/uploads:/var/opt/gitlab/gitlab-rails/uploads
      - /mnt/hdd/backups:/var/opt/gitlab/backups
  gitlab-runner:
    container_name: gitlab-runner
    hostname: gitlab-runner
    image: gitlab/gitlab-runner:latest
    restart: unless-stopped
    depends_on:
      - gitlab
    volumes:
      - /root/gitlab-runner/config:/etc/gitlab-runner
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - net

networks:
  net:
    driver: bridge
```

记得上面的目录的uid和gid修改为git用户的uid和gid. 这里, 我们把容器内的nginx关掉了, 因为我们在外部使用了caddy反代, 然后trusted_proxies设置为局域网段, 或者设置为frpc的ip.

## Caddy反代设置

需要使用`xcaddy`进行编译, 参考: https://caddyserver.com/docs/modules/dns.providers.cloudflare. 然后配置Cloudflare API, 修改caddyfile acme, 然后加上`*.pages.ricolxwz.download`和`pages.ricolxwz.download`. 类似于:

```
{
  email ricol.xwz@outlook.com
  acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
}

git.ricolxwz.download {
	reverse_proxy 127.0.0.1:65502
}

*.pages.ricolxwz.download {
	reverse_proxy localhost:65510
}

pages.ricolxwz.download {
	reverse_proxy localhost:65510
}
```

然后, 如果我们要添加github pages的自定义域名, 我们需要将自定义域名加入到Caddyfile中, 因为自定义域名也需要证书(因为我们的Github pages它只负责http, https是由Caddy来处理的):

```
note.ricolxwz.cc {
    reverse_proxy localhost:65510
}
```

!!! warning "特别注意"

    获取自定义域名证书的时候, 可以移除掉:

    ```
    {
        email ricol.xwz@outlook.com
        acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
    }
    ```

    因为这个域名`ricolxwz.cc`我没有给API的权限, 所以不能通过这种方式验证.

## CDN加速设置

在阿里云回源源站选择gitlab给我的域名, 然后回源Host填写gitlab给我的域名(识别主机要用), 回源SNI填写gitlab给我的域名(TLS解析要用), 回源协议选择https(防止重定向循环).
