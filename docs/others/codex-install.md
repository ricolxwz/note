# Codex安装

## Windows

### 离线安装

#### nodejs

1. 使用安装版

    去node.js官网下载.msi文件, 例如node-v24.18.0-x64.msi. 然后将.msi复制到离线Windows电脑, 双击安装就可以了. 安装完重新打开Powershell, 检查`node -v`, `npm -v`, `where node`, `where npm`就可以了. 

2. 使用便携版

    也可以使用便携版, 下载.zip包, 例如node-v24.18.0-win-x64.zip. 然后把这个目录加到环境变量`setx PATH "$env:PATH;$env:USERPROFILE\node-v24.18.0-win-x64"`, 然后打开Powershell验证. 

#### Codex CLI

1. 需要nodejs

    在一台有网的电脑上:

    ```powershell
    $version = "0.142.5"

    npm pack "@openai/codex@$version"
    npm pack "@openai/codex@$version-win32-x64"
    ```

    离线机器:

    ```powershell
    $version = "0.142.5"

    npm install -g ".\openai-codex-$version.tgz" `
    --omit=optional `
    --offline `
    --no-audit --no-fund

    $platform = (Resolve-Path ".\openai-codex-$version-win32-x64.tgz").Path

    npm install -g "@openai/codex-win32-x64@file:$platform" `
    --offline `
    --no-audit --no-fund

    codex --version
    ```

2. 不需要nodejs

    去Codex的Github Release页面下载: `codex-x86_64-pc-windows-msvc.exe.zip`, 然后将`codex-x86_64-pc-windows-msvc.exe`命名为`codex.exe`, 加入系统PATH:

    ```powershell
    setx PATH "$env:PATH;$env:USERPROFILE\codex-x86_64-pc-windows-msvc.exe"
    ```

#### Codex桌面

打开Codex在Windows App Store的页面, 现在是https://apps.microsoft.com/detail/9plm9xgg6vks?hl=zh-CN&gl=CN, 可以看到有一串Product ID: 9plm9xgg6vks. 

去[这里](https://store.rg-adguard.net/). 左侧下拉框选择Product ID, 然后输入Product ID: 9plm9xgg6vks. 右侧选择默认, 查询. 选择对应平台的msix文件, 如`OpenAI.Codex_26.623.13972.0_x64__2p2nqsd0c76g0.msix`, 然后右键复制链接地址, 在URL栏粘贴, 他会开始下载: `OpenAI.Codex_26.623.13972.0_x64__2p2nqsd0c76g0.Msix`. 双击下载文件, 点击安装就可以了.

## MacOS

### 离线安装

#### nodejs

1. 使用安装版

    在一台能联网的电脑上去nodejs官网下载macOS安装包, 注意选择对应的平台. 如node-v24.18.0.pkg文件, 然后把.pkg复制到离线电脑, 双击安装即可, 可以通过`node -v`, `npm -v`, `which node`, `which npm`验证. 

2. 使用便携版

    在一台能联网的电脑上去nodejs官网下载便携版.tar.gz文件, 注意选择对应的平台. 然后在离线电脑解压: 

    ```shell
    tar -xzf node-v24.18.0-darwin-arm64.tar.gz
    ```

    然后放入PATH:

    ```shell
    echo 'export PATH="$HOME/node-v24.18.0-darwin-arm64/bin:$PATH"' >> ~/.zshrc
    source ~/.zshrc
    ````

#### Codex CLI

1. 需要nodejs

    在一台有网的电脑上, 根据Mac架构下载对应npm包:

    ```shell
    version="0.142.5"

    npm pack "@openai/codex@$version"

    # Apple Silicon: M1/M2/M3/M4
    npm pack "@openai/codex@$version-darwin-arm64"

    # Intel Mac
    npm pack "@openai/codex@$version-darwin-x64"
    ```

    把生成的tgz文件复制到离线电脑:

    ```shell
    version="0.142.5"

    npm install -g "./openai-codex-$version.tgz" \
    --omit=optional \
    --offline \
    --no-audit --no-fund

    # Apple Silicon
    platform="$(pwd)/openai-codex-$version-darwin-arm64.tgz"

    npm install -g "@openai/codex-darwin-arm64@file:$platform" \
    --offline \
    --no-audit --no-fund
    ```

    产物在`node_modules`的`.bin`下.

2. 不需要nodejs

    去codex的Github发布界面下载对应macOS压缩包, 如codex-aarch64-apple-darwin.tar.gz. 复制到离线macOS然后解压:

    ```
    tar -xzf codex-aarch64-apple-darwin.tar.gz
    ```

    把解压出来的可执行文件改名为codex, 然后放到PATH里面的目录, 比如

    ```
    mkdir -p "$HOME/.local/bin"
    mv codex-aarch64-apple-darwin "$HOME/.local/bin/codex"
    chmod +x "$HOME/.local/bin/codex"
    ```

    如果`.local/bin`还没加入PATH:

    ```
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
    source ~/.zshrc
    ```

#### Codex桌面

从官网下载, 直接安装dmg文件. 