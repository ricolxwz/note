---
title: 版本控制:LFS
comments: true
---

Git是分布式版本控制系统, 这意味着在克隆过程中会将仓库的整个历史记录传输到客户端. 对于包含大文件(尤其是经常被修改的大文件)的项目, 初始克隆需要大量的时间, 因为客户端不会下载每个文件的每个版本. Git LFS是由Atlassian, Github以及其他开源贡献者开发的Git扩展, 它通过延迟地下载大文件的相关版本来减少大文件在仓库中的影响, 具体来说, 大文件是在checkout的时候下载的, 而不是在clone或者fetch过程中下载的(这意味着你在后台定时fetch远端仓库内容到本地的时候, 并不会下载大文件内容, 而是在你checkout到工作区的时候才会去真正下载大文件的内容).

Git LFS会将仓库中的大文件替换为微小的指针文件. 在正常使用期间, 你将永远不会看到这些指针文件, 它们使用Git LFS自动处理的.

1. 当你添加一个LFS文件到暂存区的时候(`git add xxx`), Git LFS用一个指针替换其内容, 并将文件内容存储在本地Git LFS的缓存中(本地Git LFS缓存位于仓库的`.git/lfs/objects`目录中).

    <figure markdown='1' id='$figid'>
    ![](https://img.ricolxwz.io/a45ca0cb2280cf91e367a707c2144fbf.webp#only-light){ loading=lazy width='400' }
    ![](https://img.ricolxwz.io/a45ca0cb2280cf91e367a707c2144fbf_inverted.webp#only-dark){ loading=lazy width='400' }
    </figure>

2. 当你推送新的提交到服务器的时候, 新推送的提交引用的所有Git LFS文件都会从本地Git LFS缓存传输到绑定到Git仓库的远程Git LFS存储.

    <figure markdown='1' id='fig'>
    ![](https://img.ricolxwz.io/0f922d9b8285033cc5cbab2fa9488268.webp#only-light){ loading=lazy width='400' }
    ![](https://img.ricolxwz.io/0f922d9b8285033cc5cbab2fa9488268_inverted.webp#only-dark){ loading=lazy width='400' }
    </figure>

3. 当你checkout一个包含Git LFS指针的提交的时候, 指针文件将替换为本地Git LFS缓存中的文件, 或者从远端Git LFS存储中下载.
