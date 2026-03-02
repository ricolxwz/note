## 离线安装npm

去官网下载, 然后安装到`.local/bin`下. 

## 离线安装CC/Codex

```
mkdir -p ./npm-cache
npm pack @openai/codex
npm i -g ./openai-codex-0.106.0.tgz --cache ./npm-cache --no-audit --no-fund
tar czf codex-offline-bundle.tgz openai-codex-0.106.0.tgz npm-cache 
# npm i -g ./anthropic-ai-claude-code-2.1.63.tgz --cache ./npm-cache --no-audit --no-fund
# tar czf offline-bundle.tgz anthropic-ai-claude-code-2.1.63.tgz npm-cache 

tar xzf offline-bundle.tgz
npm i -g ./openai-codex-0.106.0.tgz \
  --cache ./npm-cache \
  --offline --prefer-offline \
  --no-audit --no-fund --progress=false
npm i -g ./anthropic-ai-claude-code-2.1.63.tgz \
    --cache ./npm-cache \
    --offline --prefer-offline \
    --no-audit --no-fund --progress=false
```

## CC设置

```
export ANTHROPIC_BASE_URL="http://localhost:65504"
export ANTHROPIC_AUTH_TOKEN=""
export ANTHROPIC_MODEL="claude-code"
export PATH=$PATH:~/.local/bin/node/bin
```

## Codex设置

```toml
model = "gpt-codex"
model_provider = "openrouter"
web_search = "disabled"

[model_providers.openrouter]
name = "OpenRouter"
base_url = "https://localhost:65504/v1"
env_key = "NEW_API_KEY"

[projects."/home/wenzexu"]
trust_level = "trusted"
```

```
export NEW_API_KEY=""
```

## SSH隧道

```
ssh -NTR 65504:127.0.0.1:65504 zgdx
```

## Caddy反代

```
:65504 {
  reverse_proxy https://api.ricolxwz.download {
    header_up Host api.ricolxwz.download
  }
}
```
