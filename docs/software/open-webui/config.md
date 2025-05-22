---
title: 配置
comments: true
---

## 请求问题

发现明明只发送了一次请求, 但是计费表上显示三次: 这是因为在open-webui中开启了万恶的生成标题和标签功能. 他会基于回答生成一个标题和标签. 前往管理员配置栏目, 点击界面, 然后本地模型保持为"当前模型", 外部模型更改为计费便宜的模型...

## 请求很大延迟

这是因为`.venv/lib/python3.11/site-packages/open_webui/retrieval/web/utils.py`中`SafeWebBaseLoader`的实现中`_fetch`没有设置timeout的时间. 请求的机理是`ascrape_all`请求`fetch_all`, 由于`SafeWebBaseLoader`是一个`WebBaseLoader`的子类, 所以可以在`langchain-community`中找到`WebBaseLoader`, 其中有`fetch_all`函数, 它调用的是`_fetch_with_rate_limit`函数, 他会先调用`SafeWebBaseLoader`的`_fetch`, 如果有Exception, 返回的是空字符串.

修改`SafeWebBaseLoader`:

```py
async def _fetch(self, url: str) -> str:
    timeout = aiohttp.ClientTimeout(
            total=10,
            sock_connect=5,
            sock_read=5
        )
    async with aiohttp.ClientSession(trust_env=self.trust_env, timeout=timeout) as session:
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
```

```py
async def ascrape_all(self, urls: List[str], parser: Union[str, None] = None) -> List[Any]:
    """Async fetch all urls, then return soups for all results."""
    raw_results = await self.fetch_all(urls)
    filtered = [
        (result, url)
        for result, url in zip(raw_results, urls)
        if not result == ""
    ]
    if not filtered:
        return []
    results_clean, urls_clean = zip(*filtered)
    return self._unpack_fetch_results(list(results_clean), list(urls_clean), parser=parser)
```

## 检索返回条目内容质量不高

这是因为默认的SentenceTransformer默认是在英文下训练的, 所以根本没法索引中文内容. 将嵌入模型替换为中英文训练过的embedding模型: jinaai/jina-embeddings-v2-base-zh.

上面这个还是不太行, 使用BGE-M3, 使用huggingface-cli调用. 这个也不太行... 主要是速度比较慢, 用这个: sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2. 或者用这个: jinaai/jina-embeddings-v3

目前的方法: 使用Azure API平台, 然后在本地部署LiteLLM, 相当于一个proxy服务器, Open WebUI发送的是Openai格式的请求, 经过LiteLLM转换之后变成Azure API格式, Azure上面的embedding模型的速率非常非常高. 关于搜索, 见如何搭建searxng, 记得开启json格式调用. emmm. 好像openai platform上面的速率也没差多少, 都是1000000 TPM, 但是鉴于Openai API是拒付国内信用卡的, 还是老老实实用Azure吧... 块大小设置为8192, 块重叠设置为500, 用于上下文衔接, 嵌入层批处理大小设置为2.

## 开启CUDA支持

embedding等操作都要用到CUDA, 在site-packages下面, env.py文件中注释掉`USE_CUDA`那一行, 直接`USE_CUDA: "true"`, 注意, 要装一下torch. `uv pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 --force-reinstall`, 建议在公司服务器上就不要开了, 不然会被发现在占用内存... 逃.
