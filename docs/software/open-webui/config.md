---
title: 配置
comments: true
---

## 请求问题

发现明明只发送了一次请求, 但是计费表上显示三次: 这是因为在open-webui中开启了万恶的生成标题和标签功能. 他会基于回答生成一个标题和标签. 前往管理员配置栏目, 点击界面, 然后本地模型保持为"当前模型", 外部模型更改为计费便宜的模型...

## 请求很大延迟

这是因为`.venv/lib/python3.11/site-packages/open_webui/retrieval/web/utils.py`中`SafeWebBaseLoader`的实现中`_fetch`没有设置timeout的时间, 还有retry的次数, 所以这是我的实现:

```py
async def _fetch(self, url: str, retries: int = 1, cooldown: int = 2, backoff: float = 1.5) -> str:
    timeout = aiohttp.ClientTimeout(
            total=10,
            sock_connect=5,
            sock_read=5
        )
    async with aiohttp.ClientSession(trust_env=self.trust_env, timeout=timeout) as session:
        for i in range(retries):
            try:
                kwargs: Dict = dict(
                    headers=self.session.headers,
                    cookies=self.session.cookies.get_dict(),
                )
                if not self.session.verify:
                    kwargs["ssl"] = False

                async with session.get(
                    url, **(self.requests_kwargs | kwargs)
                ) as response:
                    if self.raise_for_status:
                        response.raise_for_status()
                    return await response.text()
            except aiohttp.ClientConnectionError as e:
                if i == retries - 1:
                    raise
                else:
                    log.warning(
                        f"Error fetching {url} with attempt "
                        f"{i + 1}/{retries}: {e}. Retrying..."
                    )
                    # await asyncio.sleep(cooldown * backoff**i)
    raise ValueError("retry count exceeded")
```
