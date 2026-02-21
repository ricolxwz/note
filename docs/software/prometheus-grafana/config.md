---
title: 配置
comments: false
---

## Compose

```yml
services:
  prometheus: # 9090
    image: prom/prometheus:latest
    container_name: prometheus
    user: "0:0"
    command:
      - --config.file=/etc/prometheus/prometheus.yaml
      - --storage.tsdb.retention.time=7d
      - --storage.tsdb.retention.size=2GB
    ports:
      - 9090:9090
    volumes:
      - /root/prometheus:/etc/prometheus
    restart: unless-stopped
    networks:
      - monitor-net
  grafana: # 3000
    image: grafana/grafana:latest
    container_name: grafana
    user: "0:0"
    ports:
      - 3000:3000
    volumes:
      - /root/grafana:/var/lib/grafana
    restart: unless-stopped
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin
    networks:
      - monitor-net
  watchtower:
    image: containrrr/watchtower:latest
    container_name: watchtower
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: --cleanup --interval 300
networks:
  monitor-net:
```

```sh
alias d="docker compose up -d"
alias dr="docker compose down && docker compose up -d"
alias vi="nvim
```

## Prometheus

### node exporter

```yml
node_exporter:
    image: quay.io/prometheus/node-exporter:latest
    container_name: node_exporter
    command:
      - '--path.rootfs=/host'
    network_mode: host
    pid: host
    restart: unless-stopped
    volumes:
      - '/:/host:ro,rslave'
```

### cadvisor

```yml
cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    restart: unless-stopped
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /sys/fs/cgroup:/sys/fs/cgroup:ro
```

### 配置

```yml
---
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'overleaf'
    static_configs:
      - targets: ['192.168.100.137:9100']
  - job_name: redis
    static_configs:
      - targets:
        - 192.168.100.138:9121
  - job_name: postgres
    static_configs:
      - targets:
        - 192.168.100.138:9187
  - job_name: node
    static_configs:
      - targets:
        - 192.168.100.138:9100
  - job_name: gitlab-workhorse
    static_configs:
      - targets:
        - 192.168.100.138:9229
  - job_name: gitlab-rails
    metrics_path: "/-/metrics"
    scheme: https
    static_configs:
      - targets:
        - 192.168.100.138
  - job_name: gitlab-sidekiq
    static_configs:
      - targets:
        - 192.168.100.138:8082
  - job_name: gitlab_exporter_database
    metrics_path: "/database"
    static_configs:
      - targets:
        - 192.168.100.138:9168
  - job_name: gitlab_exporter_sidekiq
    metrics_path: "/sidekiq"
    static_configs:
      - targets:
        - 192.168.100.138:9168
  - job_name: gitaly
    static_configs:
      - targets:
        - 192.168.100.138:9236
  - job_name: registry
    static_configs:
      - targets:
        - 192.168.100.138:5001
```

## Grafana
