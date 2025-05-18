---
title: 搭建
comments: true
---

```
cd ~
mkdir searxng
cd searxng
git clone https://github.com/searxng/searxng searxng-src
uv venv --python=3.11
source .venv/bin/activate
cd searxng-src
uv pip install setuptools wheel pyyaml
uv pip install -r requirements.txt
pip install --no-build-isolation -e .
mkdir -p ~/.config/searxng
cp ~/searxng/searxng-src/utils/templates/etc/searxng/settings.yml ~/.config/searxng/settings.yml
```

对于`settings.yml`, 需要修改的点有:

* 使用`openssl rand -hex 32`生成随机字符串. 编辑settings.yml文件, 替换掉`ultrasecretkey`为刚才生成的随机字符串.
* `search.safe_search:0`: 关闭安全过滤
* `server.limiter`: 关闭这玩意, 需要redis, root权限
* `server.image_proxy`: 关闭这玩意
* `redis.url`: 设置为空
* `server.port`: 设置为服务端口

```
echo "export SEARXNG_SETTINGS_PATH=~/.config/searxng/settings.yml" >> ~/.bashrc
source ~/.bashrc
cd ~/searxng/searxng-src
python searx/webapp.py
```
