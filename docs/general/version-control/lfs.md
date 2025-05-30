---
title: 版本控制:LFS
comments: true
---

# Git LFS[^1]

## 介绍

Git是分布式版本控制系统, 这意味着在克隆过程中会将仓库的整个历史记录传输到客户端. 对于包含大文件(尤其是经常被修改的大文件)的项目, 初始克隆需要大量的时间, 因为客户端不会下载每个文件的每个版本. Git LFS是由Atlassian, Github以及其他开源贡献者开发的Git扩展, 它通过延迟地下载大文件的相关版本来减少大文件在仓库中的影响, 具体来说, 大文件是在checkout的时候下载的, 而不是在clone或者fetch过程中下载的(这意味着你在后台定时fetch远端仓库内容到本地的时候, 并不会下载大文件内容, 而是在你checkout到工作区的时候才会去真正下载大文件的内容).

Git LFS会将仓库中的大文件替换为微小的指针文件. 在正常使用期间, 你将永远不会看到这些指针文件, 它们使用Git LFS自动处理的.

1. 当你添加一个LFS文件到暂存区的时候(`git add xxx`), LFS用一个指针替换其内容, 并将文件内容存储在本地LFS的缓存中(本地LFS缓存位于仓库的`.git/lfs/objects`目录中).

    <figure markdown='1' id='$figid'>
    ![](https://img.ricolxwz.download/a45ca0cb2280cf91e367a707c2144fbf.webp#only-light){ loading=lazy width='400' }
    ![](https://img.ricolxwz.download/a45ca0cb2280cf91e367a707c2144fbf_inverted.webp#only-dark){ loading=lazy width='400' }
    </figure>

2. 当你推送新的提交到远程仓库的时候, 新推送的提交引用的所有LFS文件都会从本地LFS缓存传输到绑定到远程仓库的LFS服务器上.

    <figure markdown='1' id='fig'>
    ![](https://img.ricolxwz.download/0f922d9b8285033cc5cbab2fa9488268.webp#only-light){ loading=lazy width='400' }
    ![](https://img.ricolxwz.download/0f922d9b8285033cc5cbab2fa9488268_inverted.webp#only-dark){ loading=lazy width='400' }
    </figure>

3. 当你checkout一个包含LFS指针的提交的时候, 指针文件将替换为本地LFS缓存中的文件, 或者从LFS服务器中下载到本地LFS缓存中, 然后再替换为缓存中的文件.

    <figure markdown='1' id='fig'>
    ![](https://img.ricolxwz.download/7b0183ae420925418631567277bda825.webp#only-light){ loading=lazy width='400' }
    ![](https://img.ricolxwz.download/7b0183ae420925418631567277bda825_inverted.webp#only-dark){ loading=lazy width='400' }
    </figure>

LFS的指针文件是一个文本文件夹, 存储在仓库中, 对应大文件的内容存储在本地LFS缓存里面或者LFS服务器中, 例如, 下面是一个图片LFS文件的指针文件内容:

```
version https://git-lfs.github.com/spec/v1
oid sha256:5b62e134d2478ae0bbded57f6be8f048d8d916cb876f0656a8a6d1363716d999
size 285
```

指针文件很小, 小于1KB, 其格式为key-value格式, 第一行为指针文件规范URL, 第二行为文件的对象id, 即LFS文件的存储对象文件名, 可以在`.git/lfs/objects`目录中找到该文件的存储独享, 第三行为文件的实际大小. 所有LFS指针文件都是这种形式.

Git LFS是无缝的, 在你的工作副本中, 你只会看到实际的文件内容. 这意味着你不需要更改现有的Git工作流就可以使用Git LFS. 你只需要按照常规进行`git checkout`, 编辑文件, `git add`, `git commit`, `git clone`.

## 使用

| 命令             | 拉取 LFS 对象         | 写入指针→大文件      | 更新分支／检出    |
|------------------|----------------------|----------------------|------------------|
| `git lfs fetch`  | ✅                   | ❌                   | ❌               |
| `git lfs pull`   | ✅                   | ✅                   | ❌               |
| `git fetch`      | ❌（仅指针）          | ❌                   | ❌               |
| `git pull`       | ✅（串行 smudge）     | ✅（同上）           | ✅               |
| `git clone`      | ✅（串行 smudge）     | ✅（同上）           | ✅（含 clone）    |
| `git lfs clone`  | ✅                   | ✅                   | ✅（含 clone）    |

- `git lfs fetch`：仅把 LFS 对象下载到本地缓存，不修改工作区任何文件。
- `git lfs pull`：`git lfs fetch` 之后自动 `git lfs checkout`，将指针替换为真实大文件。
- `git fetch`：只更新远程跟踪分支，不触及工作区，也不会自动下载 LFS 对象（只拉指针）。
- `git pull`：`git fetch` + 合并或快进，再 checkout；默认在 checkout 阶段用 smudge 过滤器*串行*下载所需 LFS 对象，可用 `filter.lfs.smudge=0` 关闭。
- `git clone`：相当于 `git init` + `git fetch` + 首次 checkout；若启用 smudge，会像 `git pull` 一样*串行*下载当前分支所需的 LFS 对象
- `git lfs clone`：封装 clone + 并行下载全过程，已被官方标记为 *deprecated*，未来可能移除。

### 初始化

怎么安装就不说了, 一旦安装好了, 运行`git lfs install`来初始化. 只需要运行`git lfs install`一次. 为你的系统初始化之后, 当你克隆包含LFS内容的仓库的时候, Git LFS将自动进行自我引导启动. 但是如果你要新建一个支持Git LFS的仓库, 需要在创建仓库之后运行`git lfs install`.

```bash
# initialize Git
$ mkdir Atlasteroids
$ cd Atlasteroids
$ git init
Initialized empty Git repository in /Users/tpettersen/Atlasteroids/.git/
# initialize Git LFS
$ git lfs install
Updated pre-push hook.
Git LFS initialized.
```

这将在你的仓库中安装一个特殊的pre-push Git hook, 这个hook会在你执行`git push`的时候传输Git LFS文件到服务器上. 当你的仓库初始化了Git LFS之后, 可以通过`git lfs track`来指定要跟踪的文件.

### 克隆现有的Git LFS仓库

安装Git LFS后, 你可以像往常一样使用`git clone`命令来克隆仓库. 在克隆过程的结尾, Git会检出默认的分支, 并且将自动为你下载检出过程所需的所有LFS文件, 例如.

```bash
$ git clone git@bitbucket.org:tpettersen/Atlasteroids.gitCloning into 'Atlasteroids'...
remote: Counting objects: 156, done.
remote: Compressing objects: 100% (154/154), done.
remote: Total 156 (delta 87), reused 0 (delta 0)
Receiving objects: 100% (156/156), 54.04 KiB | 31.00 KiB/s, done.
Resolving deltas: 100% (87/87), done.
Checking connectivity... done.
Downloading Assets/Sprites/projectiles-spritesheet.png (21.14 KB)
Downloading Assets/Sprites/productlogos_cmyk-spritesheet.png (301.96 KB)
Downloading Assets/Sprites/shuttle2.png (1.62 KB)
Downloading Assets/Sprites/space1.png (1.11 MB)
Checking out files: 100% (81/81), done
```

仓库里由4个PNG文件被Git LFS追踪, 执行`git clone`时, 不会下载LFS文件, 在从仓库中检出指针文件的时候, LFS文件才会被一个一个下载下来. 注意, 使用`git clone`的时候, 在checkout的时候, 就会调用LFS的smudge过滤器, 把指针文件自动替换为真实的大文件, 下载和替换都是在checkout阶段进行的.

### 加快克隆速度

如果你正在克隆包含大量 LFS 文件的仓库, 显式使用 git lfs clone 命令可提供更好的性能:

```bash
$ git lfs clone git@bitbucket.org:tpettersen/Atlasteroids.git
Cloning into 'Atlasteroids'...
remote: Counting objects: 156, done.
remote: Compressing objects: 100% (154/154), done.
remote: Total 156 (delta 87), reused 0 (delta 0)
Receiving objects: 100% (156/156), 54.04 KiB | 0 bytes/s, done.
Resolving deltas: 100% (87/87), done.
Checking connectivity... done.
Git LFS: (4 of 4 files) 1.14 MB / 1.15 MB
```

git lfs clone 命令不会一次下载一个 Git LFS 文件, 而是等到检出(checkout)完成后再批量下载所有必需的 Git LFS 文件. 这利用了并行下载的优势, 并显著减少了产生的 HTTP 请求和进程的数量(这对于提高 Windows 的性能尤为重要). 注意, 使用`git lfs clone`的时候, 在checkout的时候, 不会调用LFS 的 smudge 过滤器来替换指针文件, 而是等到checkout完成之后, 一次性将指针文件替换为真实的大文件, 能够并行下载LFS对象, 效率更高.

### 拉取并检出

就像克隆一样, 你可以使用常规的`git pull`命令拉取 Git LFS 仓库. 拉取完成后, 所有需要的 Git LFS 文件都会作为自动检出过程的一部分而被下载.

```bash
$ git pull
Updating 4784e9d..7039f0a
Downloading Assets/Sprites/powerup.png (21.14 KB)
Fast-forward
Assets/Sprites/powerup.png | 3 +
Assets/Sprites/powerup.png.meta | 4133 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
2 files changed, 4136 insertions(+)
create mode 100644 Assets/Sprites/projectiles-spritesheet.png
create mode 100644 Assets/Sprites/projectiles-spritesheet.png.meta
```

不需要显式的命令即可获取 Git LFS 内容. 然而, 如果检出因为意外原因而失败, 你可以通过使用`git lfs pull`命令来下载当前提交的所有丢失的 Git LFS 内容:

```bash
$ git lfs pull
Git LFS: (4 of 4 files) 1.14 MB / 1.15 MB
```

### 加快拉取速度

像 git lfs clone 命令一样, git lfs pull 命令批量下载 Git LFS 文件. 如果你知道自上次拉取以来已经更改了大量文件, 则不妨显式使用 git lfs pull 命令来批量下载 Git LFS 内容, 而禁用在检出期间自动下载 Git LFS. 这可以通过在调用 git pull 命令时使用-c 选项覆盖 Git 配置来完成:

```bash
git -c filter.lfs.smudge= -c filter.lfs.required=false pull && git lfs pull
```

由于输入的内容很多, 你可能希望创建一个简单的Git 别名来为你执行批处理的 Git 和 Git LFS 拉取:

```bash
$ git config --global alias.plfs "\!git -c filter.lfs.smudge= -c filter.lfs.required=false pull && git lfs pull"
$ git plfs
```

当需要下载大量的 Git LFS 文件时, 这将大大提高性能(同样, 尤其是在 Windows 上).
下面是 **按原格式** 调整后的说明，主要修正了 **`git pull` 默认也会触发 smudge 串行下载 LFS 对象** 以及 **`git lfs clone` 已被官方标记为 *deprecated*** 等细节；其它逻辑保持不变。

### 追踪文件

当向仓库中添加新的大文件类型时, 你需要通过使用 git lfs track 命令指定一个模式来告诉 Git LFS 对其进行跟踪:

```bash
$ git lfs track "*.ogg"
Tracking *.ogg
```

请注意, "*.ogg"周围的引号很重要. 省略它们将导致通配符被 shell 扩展, 并将为当前目录中的每个.ogg 文件创建单独的条目:

```bash
# probably not what you want
$ git lfs track *.ogg
Tracking explode.ogg
Tracking music.ogg
Tracking phaser.ogg
```

Git LFS 支持的模式与.gitignore 支持的模式相同, 例如:

```bash
# track all .ogg files in any directory
$ git lfs track "*.ogg"
# track files named music.ogg in any directory
$ git lfs track "music.ogg"
# track all files in the Assets directory and all subdirectories
$ git lfs track "Assets/"
# track all files in the Assets directory but *not* subdirectories
$ git lfs track "Assets/*"
# track all ogg files in Assets/Audio
$ git lfs track "Assets/Audio/*.ogg"
# track all ogg files in any directory named Music
$ git lfs track "/Music/*.ogg"
# track png files containing "xxhdpi" in their name, in any directory
$ git lfs track "*xxhdpi*.png
```

这些模式是相对于你运行 git lfs track 命令的目录的. 为了简单起见, 最好是在仓库根目录运行 git lfs track. 需要注意的是, Git LFS 不支持像.gitignore 那样的负模式(negative patterns).

运行 git lfs track 后, 你会在你的运行命令的仓库中发现名为.gitattributes 的新文件. .gitattributes 是一种 Git 机制, 用于将特殊行为绑定到某些文件模式. Git LFS 自动创建或更新.gitattributes 文件, 以将跟踪的文件模式绑定到 Git LFS 过滤器. 但是, 你需要将对.gitattributes 文件的任何更改自己提交到仓库:

```bash
$ git lfs track "*.ogg"
Tracking *.ogg
$ git add .gitattributes
$ git diff --cached
diff --git a/.gitattributes b/.gitattributes
new file mode 100644
index 0000000..b6dd0bb
--- /dev/null
+++ b/.gitattributes
@@ -0,0 +1 @@
+*.ogg filter=lfs diff=lfs merge=lfs -text
$ git commit -m "Track ogg files with Git LFS"
```

为了便于维护, 通过始终从仓库的根目录运行 git lfs track, 将所有 Git LFS 模式保持在单个.gitattributes 文件中是最简单的. 然而, 你可以通过调用不带参数的 git lfs track 命令来显示 Git LFS 当前正在跟踪的所有模式的列表(以及它们在其中定义的.gitattributes 文件):

```bash
$ git lfs track
Listing tracked paths
*.stl (.gitattributes)
*.png (Assets/Sprites/.gitattributes)
*.ogg (Assets/Audio/.gitattributes)
```

你可以通过从.gitattributes 文件中删除相应的行, 或者通过运行 git lfs untrack 命令来停止使用 Git LFS 跟踪特定模式:

```bash
$ git lfs untrack "*.ogg"
Untracking *.ogg
$ git diff
diff --git a/.gitattributes b/.gitattributes
index b6dd0bb..e69de29 100644
--- a/.gitattributes
+++ b/.gitattributes
@@ -1 +0,0 @@
-*.ogg filter=lfs diff=lfs merge=lfs -text
```

运行 git lfs untrack 命令后, 你自己必须再次提交.gitattributes 文件的更改.

### 提交和推送

你可以按常规方式提交并推送到包含 Git LFS 内容的仓库. 如果你已经提交了被 Git LFS 跟踪的文件的变更, 则当 Git LFS 内容传输到服务器时, 你会从 git push 中看到一些其他输出:

```bash
$ git push
Git LFS: (3 of 3 files) 4.68 MB / 4.68 MB
Counting objects: 8, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (8/8), done.
Writing objects: 100% (8/8), 1.16 KiB | 0 bytes/s, done.
Total 8 (delta 1), reused 0 (delta 0)
To git@bitbucket.org:tpettersen/atlasteroids.git
7039f0a..b3684d3 master -> master
```

如果由于某些原因传输 LFS 文件失败, 推送将被终止, 你可以放心地重试. 与 Git 一样, Git LFS 存储也是内容寻址 的(而不是按文件名寻址): 内容是根据密钥存储的, 该密钥是内容本身的 SHA-256 哈希. 这意味着重新尝试将 Git LFS 文件传输到服务器总是安全的; 你不可能用错误的版本意外覆盖 Git LFS 文件的内容.

### 删除本地Git LFS文件

你可以使用 git lfs prune 命令从本地 Git LFS 缓存中删除文件:

```bash
$ git lfs prune
✔ 4 local objects, 33 retained
Pruning 4 files, (2.1 MB)
✔ Deleted 4 files
```

这将删除所有被认为是旧的本地 Git LFS 文件.  旧文件是以下未被引用的任何文件:

* 当前检出的提交
* 尚未推送(到 origin, 或任何 lfs.pruneremotetocheck 设置的)的提交
* 最近一次提交

你可以配置 prune 偏移量以将 Git LFS 内容保留更长的时间:

```bash
# don't prune commits younger than four weeks (7 + 21)
$ git config lfs.pruneoffsetdays 21
```

与 Git 的内置垃圾收集不同, Git LFS 内容不会自动修剪, 因此, 定期运行 git lfs prune 命令是保持本地仓库大小减小的好主意.

你可以使用 git lfs prune --dry-run 来测试修剪操作将产生什么效果:

```bash
$ git lfs prune --dry-run
✔ 4 local objects, 33 retained
4 files would be pruned (2.1 MB)
```

以及使用 git lfs prune --verbose --dry-run 命令精确查看哪些 Git LFS 对象将被修剪:

```bash
$ git lfs prune --dry-run --verbose
✔ 4 local objects, 33 retained
4 files would be pruned (2.1 MB)
* 4a3a36141cdcbe2a17f7bcf1a161d3394cf435ac386d1bff70bd4dad6cd96c48 (2.0 MB)
* 67ad640e562b99219111ed8941cb56a275ef8d43e67a3dac0027b4acd5de4a3e (6.3 KB)
* 6f506528dbf04a97e84d90cc45840f4a8100389f570b67ac206ba802c5cb798f (1.7 MB)
* a1d7f7cdd6dba7307b2bac2bcfa0973244688361a48d2cebe3f3bc30babcf1ab (615.7 KB)
```

--verbose 模式输出的长十六进制字符串是要修剪的 Git LFS 对象的 SHA-256 哈希(也称为对象 ID 或 OID).  你可以使用"查找路径"中描述的技术或引用 Git LFS 对象的提交来查找有关将被修剪的对象的更多信息.

作为附加的安全检查, 你可以使用--verify-remote 选项在删除之前, 检查远程 Git LFS 存储区是否具有你的 Git LFS 对象的副本:

```bash
$ git lfs prune --verify-remote
✔ 16 local objects, 2 retained, 12 verified with remote
Pruning 14 files, (1.7 MB)
✔ Deleted 14 files
```

这将使修剪过程明显变慢, 但是你可以从服务器上恢复所有修剪的对象, 从而使你高枕无忧.  你可以通过全局配置 lfs.pruneverifyremotealways 属性为系统永久启用--verify-remote 选项:

```bash
$ git config --global lfs.pruneverifyremotealways true
```

### 服务器删除远端Git LFS文件

Git LFS 命令行客户端不支持删除服务器上的文件, 因此如何删除他们取决于你的托管服务提供商.

[^1]: 详解 Git 大文件存储（Git LFS）. (n.d.). 知乎专栏. Retrieved April 18, 2025, from https://zhuanlan.zhihu.com/p/146683392
