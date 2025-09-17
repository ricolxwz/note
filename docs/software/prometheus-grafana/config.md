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
      - /root/prometheus/config:/etc/prometheus
      - /root/prometheus/data:/prometheus
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

## Grafana
