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
    volumes:
      - /root/gitlab/config:/etc/gitlab
      - /root/gitlab/logs:/var/log/gitlab
      - /root/gitlab/data:/var/opt/gitlab
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

这里, 我们把容器内的nginx关掉了, 因为我们在外部使用了caddy反代, 然后trusted_proxies设置为局域网段, 或者设置为frpc的ip.

## Caddy反代设置

需要使用`xcaddy`进行编译, 参考: https://caddyserver.com/docs/modules/dns.providers.cloudflare. 然后配置Cloudflare API, 修改caddyfile acme, 然后加上`*.pages.ricolxwz.download`和`pages.ricolxwz.download`.
