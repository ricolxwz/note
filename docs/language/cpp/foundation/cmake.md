---
title: CMake
comments: false
---

## `CMakePresets.json`

`CMakePresets.json` 是 CMake 提供的一套预设配置机制, 通常写在项目的根目录. 它的作用是把平时命令行里面很长的 CMake 配置参数保存为一个个名字明确的"预设". 

* `configurePresets`: CMake 构建项目通常分为几步: Configure, Build, Test, Install. `configurePresets` 应的是第一步 Configure 阶段. `cmake --preset debug` 表示使用 `configurePresets` 中名为 `debug` 的 preset 来执行配置. 它不只是简单等价于 `cmake -S . -B build/debug`, 而是会同时应用 preset 里定义的 `binaryDir`, `generator`, `toolchainFile`, `cacheVariables` 等配置. 
    * `hidden`: 表示这个 preset 不会作为一个可以直接使用的选项显示出来, 通常是给其他 preset 继承使用的. 
    * `binaryDir`: 表示 CMake 生成的各种构建文件会放在哪里, 例如 `CMakeCache.txt`, `Makefile`, `build.ninja` 等. 
    * `installDir`: 安装目录. 执行安装命令后, 最终产物会放到这里. 它描述的是安装路径这个配置项, 而不是执行安装这个动作. 
    * `cacheVariables`: 传给 CMake Cache 的变量集合. 简单说, 它相当于把命令行里的很多 `-Dxxx=xxx` 写进 `CMakePresets.json` 里. CMake 配置项目时, 会在构建目录里生成一个文件: `CMakeCache.txt`. 这个文件会保存很多配置项, 例如 `CMAKE_CXX_STANDARD=20`. 以后再次运行 CMake 的时候, 这些值会被记住, 不用每次重新输入. 常见用途包括: 是否启用测试, 是否启用文档, 是否启用代码分析, 第三方库路径等. 有些变量是 CMake 自带的, 有些变量是项目自己定义的, 例如 `ENABLE_TEST_MODULE`. 这些自定义变量通常会在 `CMakeLists.txt` 或 `.cmake` 文件里被读取. 可以使用 `${PROJECT_NAME}` 这种方式读取变量; 在 `if` 中使用时, 可以直接写变量名, 例如 `if(ENABLE_TEST_MODULE)`. 
    * `architecture`: 描述目标架构. 对于 Visual Studio 等生成器, 它可以对应生成器平台, 例如类似命令行里的 `-A x64`. 但如果 `strategy` 是 `external`, 或者使用的是 Makefiles, Ninja 这类生成器, 它更多是给外部工具或 IDE 看的信息, CMake 自己不一定会用它来决定产物架构. 真正的目标架构通常由 toolchain file, compiler target triple 或编译器参数决定. 
    * `generator`: 表示使用什么生成器, 例如 `Visual Studio 16 2019`. 大致等于命令行里的 `cmake -G "Visual Studio 16 2019"`, 意思是 CMake 会生成 Visual Studio 2019 的工程文件, 比如 `.sln`, `.vcxproj`. 
    * `toolchainFile`: 是一个 CMake 脚本, 告诉 CMake 用哪个编译器, 目标平台是什么, 去哪里找库. 它通常用于配置完整的构建工具链, 尤其常见于交叉编译场景. 
    * `toolset`: 告诉生成器使用哪个工具集或工具集选项, 典型用于 Visual Studio. 它和 `toolchainFile` 不是同一个层级: `toolchainFile` 更像是定义一整套构建环境, `toolset` 更像是在生成器支持的范围内选择或微调工具集. `host=x64` 表示运行编译器, 链接器这些构建工具本身的宿主架构是 x64, 不等于产物目标架构是 x64. 当前项目里使用了 `strategy: "external"`, 所以它更偏向给外部工具或 IDE 的提示. 
    * `condition`: 用于按照环境过滤 preset. 当条件为 `false` 时, 该 preset 会被视为不可用, `cmake --list-presets` 通常不会显示它. 例如 `${hostSystemName}` 表示运行 CMake 的机器系统, 如果当前机器不是 Windows, 那么带有 Windows 条件的 preset 就不会作为可用项出现. 
* `buildPresets`: 对应的是build阶段, 也就是configure之后真正执行编译的那一步. 
* `testPresets`: 对应的是test阶段. 
    * `output`: `shortProgress`表示测试运行的时候显示简短进度; `verbosity`表示使用默认详细程度输出. `outputOnFailure`表示只有测试失败的时候才打印该测试的输出, 很常用, 避免成功测试刷屏. 
    * `execution`: `jobs`表示并行跑多少个测试. `stopOnFailure`表示遇到第一个失败测试就停止. 