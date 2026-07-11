# Codex 安装

本文记录 Codex CLI 和桌面应用的离线安装方法。这里的“离线”只表示安装时不再下载依赖；登录、调用模型和同步任务仍需要访问 OpenAI 服务。

## 当前版本

以下版本于 2026-07-11 核对：

| 组件 | 稳定版本 | 说明 |
| --- | --- | --- |
| Codex CLI | 0.144.1 | npm `latest` 与 GitHub Release 一致 |
| Node.js | 24.18.0 LTS (Krypton) | 26.5.0 是 Current，不作为本文默认版本 |
| Windows 桌面应用 | 26.707.3748.0 | x64，最低 Windows 10 build 19041 |
| macOS 桌面应用 | 26.707.41301 (build 5103) | arm64；官方支持 macOS 14+、M1+ |

Codex 桌面应用现已并入新的 ChatGPT Desktop，安装后显示为 ChatGPT，应用内仍可进入 Codex。桌面应用与 CLI 使用不同的版本编号。

官方来源：

- [Codex CLI npm 包](https://www.npmjs.com/package/@openai/codex)
- [Codex CLI GitHub Releases](https://github.com/openai/codex/releases)
- [Node.js 下载](https://nodejs.org/en/download)
- [ChatGPT Desktop 下载](https://chatgpt.com/download/)
- [桌面应用迁移说明](https://help.openai.com/en/articles/20001276)

## Windows x64 离线安装

### Node.js

#### 安装版（推荐）

从 Node.js 官网取得最新 LTS 的 x64 MSI，例如：

```text
node-v24.18.0-x64.msi
```

把 MSI 复制到离线电脑后双击安装。重新打开 PowerShell，验证：

```powershell
node --version
npm --version
where.exe node
where.exe npm
Get-Command node,npm
```

PowerShell 中应使用 `where.exe`；`where` 本身是 `Where-Object` 的别名。

#### 便携版

下载并解压：

```text
node-v24.18.0-win-x64.zip
```

例如解压到 `$env:USERPROFILE\Tools\node-v24.18.0-win-x64`，再把“目录”加入用户 `PATH`：

```powershell
$nodeDir = "$env:USERPROFILE\Tools\node-v24.18.0-win-x64"
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$parts = @($userPath -split ';' | Where-Object { $_ })

if ($parts -notcontains $nodeDir) {
    [Environment]::SetEnvironmentVariable(
        'Path',
        (($parts + $nodeDir) -join ';'),
        'User'
    )
}

$env:Path = "$nodeDir;$env:Path"
node --version
```

不要使用 `setx PATH "$env:PATH;..."`：它可能展开并截断现有 `PATH`，而且不会更新当前终端。

### Codex CLI

有两种离线安装方式：npm 包需要 Node.js；GitHub Release 的独立版不需要 Node.js。

#### npm 版

在联网电脑上下载通用启动包和 Windows x64 平台包：

```powershell
$version = '0.144.1'

npm pack "@openai/codex@$version"
npm pack "@openai/codex@$version-win32-x64"
```

应得到：

```text
openai-codex-0.144.1.tgz
openai-codex-0.144.1-win32-x64.tgz
```

把两个文件一起复制到离线电脑，在其所在目录运行：

```powershell
$version = '0.144.1'

npm install -g ".\openai-codex-$version.tgz" `
    --omit=optional `
    --offline `
    --no-audit --no-fund

$platform = (Resolve-Path ".\openai-codex-$version-win32-x64.tgz").Path

npm install -g "@openai/codex-win32-x64@file:$platform" `
    --offline `
    --no-audit --no-fund

codex --version
Get-Command codex
```

预期输出为 `codex-cli 0.144.1`。第一步故意跳过在线 optional dependencies，第二步再从本地文件安装平台二进制包。

#### 独立完整版（推荐）

当前官方安装脚本优先使用完整 package archive。从对应的 GitHub Release 下载：

```text
codex-package-x86_64-pc-windows-msvc.tar.gz
```

包内包含主程序、code-mode host、`rg.exe`、命令运行器和 Windows 沙箱安装器。解压后应保持原目录结构：

```text
bin/
  codex.exe
  codex-code-mode-host.exe
codex-path/
  rg.exe
codex-resources/
  codex-command-runner.exe
  codex-windows-sandbox-setup.exe
codex-package.json
```

把完整包解压到固定目录，例如 `$env:USERPROFILE\Tools\codex-0.144.1`，并把其中的 `bin` 目录加入用户 `PATH`：

```powershell
$codexRoot = "$env:USERPROFILE\Tools\codex-0.144.1"
New-Item -ItemType Directory -Force $codexRoot | Out-Null
tar -xzf .\codex-package-x86_64-pc-windows-msvc.tar.gz -C $codexRoot
$codexBin = "$codexRoot\bin"

$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$parts = @($userPath -split ';' | Where-Object { $_ })

if ($parts -notcontains $codexBin) {
    [Environment]::SetEnvironmentVariable(
        'Path',
        (($parts + $codexBin) -join ';'),
        'User'
    )
}

$env:Path = "$codexBin;$env:Path"
codex --version
```

GitHub Release 仍提供旧式 `codex-x86_64-pc-windows-msvc.exe.zip`。它可以作为兼容备选，但其中的 `codex-x86_64-pc-windows-msvc.exe`、`codex-command-runner.exe` 和 `codex-windows-sandbox-setup.exe` 必须保持在同一目录。`PATH` 中应加入目录，不能加入 exe 文件本身。

### ChatGPT Desktop（含 Codex）

官方 Windows 下载入口对应 Microsoft Store Product ID：

```text
9PLM9XGG6VKS
```

商店页面：<https://apps.microsoft.com/detail/9PLM9XGG6VKS>

微软官方 `winget download` 支持商店脱机分发，但取得脱机许可证通常需要具有相应管理员角色的 Microsoft Entra ID：

```powershell
winget download `
    --source msstore `
    --id 9PLM9XGG6VKS `
    --exact `
    --architecture x64 `
    --platform Windows.Desktop `
    --skip-license `
    --download-directory . `
    --accept-package-agreements `
    --accept-source-agreements
```

普通个人账户无法通过该命令取包时，可以沿用 [Microsoft Store 链接生成器](https://store.rg-adguard.net/)：

1. 请求类型选择 `ProductId`。
2. 输入 `9PLM9XGG6VKS`，Ring 选择 `RP`。
3. 选择 x64 的 `.msix`，不要选择 `.BlockMap` 或 arm64 文件。
4. 下载链接实际指向微软 `delivery.mp.microsoft.com` CDN，但临时链接会过期。

截至 2026-07-11，对应文件为：

```text
OpenAI.Codex_26.707.3748.0_x64__2p2nqsd0c76g0.msix
```

复制到离线电脑后先检查签名：

```powershell
Get-AuthenticodeSignature .\OpenAI.Codex_26.707.3748.0_x64__2p2nqsd0c76g0.msix |
    Format-List Status,StatusMessage,SignerCertificate
```

`Status` 应为 `Valid`，包内 Publisher 应为：

```text
CN=50BDFD77-8903-4850-9FFE-6E8522F64D5B
```

双击 MSIX 安装，或运行：

```powershell
Add-AppxPackage .\OpenAI.Codex_26.707.3748.0_x64__2p2nqsd0c76g0.msix
```

## macOS 离线安装

### Node.js

#### 安装版（推荐）

官方 `.pkg` 是 arm64/x64 通用安装器，不需要下载两份：

```text
node-v24.18.0.pkg
```

复制到离线 Mac 后双击安装，验证：

```bash
node --version
npm --version
which node
which npm
```

#### 便携版

按 `uname -m` 选择：

- Apple Silicon：`node-v24.18.0-darwin-arm64.tar.gz`
- Intel：`node-v24.18.0-darwin-x64.tar.gz`

以 Apple Silicon 为例：

```bash
mkdir -p "$HOME/Tools"
tar -xzf node-v24.18.0-darwin-arm64.tar.gz -C "$HOME/Tools"
echo 'export PATH="$HOME/Tools/node-v24.18.0-darwin-arm64/bin:$PATH"' >> "$HOME/.zshrc"
source "$HOME/.zshrc"
node --version
```

### Codex CLI

#### npm 版

在联网电脑上取得通用启动包及对应架构平台包：

```bash
version='0.144.1'

npm pack "@openai/codex@$version"
npm pack "@openai/codex@$version-darwin-arm64" # Apple Silicon
npm pack "@openai/codex@$version-darwin-x64"   # Intel
```

把通用包和目标架构的平台包一起复制到离线 Mac。在文件所在目录运行：

```bash
version='0.144.1'

npm install -g "./openai-codex-$version.tgz" \
  --omit=optional \
  --offline \
  --no-audit --no-fund

case "$(uname -m)" in
  arm64)
    platform="$(pwd)/openai-codex-$version-darwin-arm64.tgz"
    alias_name='@openai/codex-darwin-arm64'
    ;;
  x86_64)
    platform="$(pwd)/openai-codex-$version-darwin-x64.tgz"
    alias_name='@openai/codex-darwin-x64'
    ;;
  *)
    echo 'Unsupported architecture' >&2
    exit 1
    ;;
esac

npm install -g "$alias_name@file:$platform" \
  --offline \
  --no-audit --no-fund

codex --version
command -v codex
npm prefix -g
```

#### 独立完整版（推荐）

从 GitHub Release 按架构下载：

- Apple Silicon：`codex-package-aarch64-apple-darwin.tar.gz`
- Intel：`codex-package-x86_64-apple-darwin.tar.gz`

完整包包含 `codex`、code-mode host、`rg` 和运行所需资源。以 Apple Silicon 为例，保持包内结构解压到固定目录，再把 `bin` 加入 `PATH`：

```bash
mkdir -p "$HOME/Tools/codex-0.144.1"
tar -xzf codex-package-aarch64-apple-darwin.tar.gz \
  -C "$HOME/Tools/codex-0.144.1"
```

把完整包的 `bin` 加入 `PATH`：

```bash
echo 'export PATH="$HOME/Tools/codex-0.144.1/bin:$PATH"' >> "$HOME/.zshrc"
source "$HOME/.zshrc"
codex --version
```

旧式 `codex-aarch64-apple-darwin.tar.gz` / `codex-x86_64-apple-darwin.tar.gz` 仍可作为兼容备选；这类压缩包只提供主程序。

### ChatGPT Desktop（含 Codex）

从 [官方桌面下载页](https://chatgpt.com/download/) 取得 `ChatGPT.dmg`。当前官方固定入口为：

```text
https://persistent.oaistatic.com/codex-app-prod/ChatGPT.dmg
```

截至 2026-07-11，包内版本是 `26.707.41301`、build `5103`，主程序是 arm64。官方支持范围是 macOS 14 或更高版本、Apple Silicon M1 或更新芯片；包内技术最低版本字段为 macOS 12.0。打开 DMG 后把 ChatGPT 拖入 Applications；Intel Mac 使用 Codex CLI。

## 校验离线包

Node.js 每个版本目录都提供官方 `SHASUMS256.txt`。Codex CLI 的 GitHub Release 也提供每个资产的 SHA-256。建议为最终离线目录再生成一份统一清单：

Windows PowerShell：

```powershell
$root = (Get-Location).Path.TrimEnd('\')
$lines = Get-ChildItem -Recurse -File |
  Where-Object Name -ne 'SHA256SUMS.txt' |
  ForEach-Object {
    $relative = $_.FullName.Substring($root.Length + 1).Replace('\', '/')
    "{0}  {1}" -f (Get-FileHash $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant(), $relative
  }

[IO.File]::WriteAllLines(
    (Join-Path $root 'SHA256SUMS.txt'),
    $lines,
    [Text.UTF8Encoding]::new($false)
)
```

macOS：

```bash
find . -type f ! -name SHA256SUMS.txt -print0 \
  | sort -z \
  | xargs -0 shasum -a 256 > SHA256SUMS.txt
```
