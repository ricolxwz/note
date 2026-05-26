---
title: CMake
comments: false
---

## `CMakePresets.json`

`CMakePresets.json`是Cmake提供的一套预设配置机制, 通常写在项目的根目录, 它的作用是把平时命令行里面很长的CMake配置参数保存为一个个名字明确的"预设". 

* `configurePresets`: CMake构建项目通常分为几步, Configure, Build, Test, Install. `configurePresets`对应的是第一步Configure阶段, `cmake --preset debug`(其中`debug`是`configurePresets`中的一个preset), 等价于执行`cmake -S . -B build/debug`. 
* `hidden`: 表示这个preset不会作为一个可以直接使用的选项显示出来, 通常是给其他preset继承使用的. 
* `binaryDir`: 表示CMake生成的各种构件文件会放在哪里, 如`CMakeCache.txt`, `Makefile`, `build.ninja`...
* `installDir`: 安装目录, 执行安装命令后, 最终产物要放在哪里. 他描述的是安装路径这个配置项, 而不是执行安装这个动作.
* `cacheVariables`: 传给CMake Cache的变量集合. 简单说, 它相当于把命令行里的很多`-Dxxx=xxx`写进`CMakePresets.json`里. CMake 配置项目时, 会在构建目录里生成一个文件: `CMakeCache.txt`, 这个文件会保存很多配置项, 例如`CMAKE_CXX_STANDARD=20`, 以后再次运行CMake的时候, 这些值会被记住, 不用每次重新输入. 常见的用途包括, 是否启用测试, 是否启用文档, 是否启用代码分析, 第三方库路径... 有些变量是CMake自带的, 有些变量是项目自己定义的, 如`ENABLE_TEST_MODULE`, 这些自定义变量通常会在`CMakeLists.txt`或`.cmake`文件里被读取. 可以使用`${PROJECT_NAME}`这种方式读取cacheVariables, 在`if`中使用时, 直接写变量的名字, 如`if(ENABLE_TEST_MODULE)`. 
* `architecture`: 用来指定目标构建架构, `value`是具体架构的名称; `strategy`有两种, 一种是`set`, 一种是`external`, `set`意思是让CMake真的把生成器平台设置为`x64`, 相当于`cmake -A 64`, `strategy`意思是想让Visual Studio, VS Code, CI等外部工具识别架构, 但是不希望CMake直接干预. 
* `generator`: 表示使用什么生成器, 例如`Visual Studio 16 2019`, 大致等于命令行里面的`cmake -G "Visual Studio 16 2019"`, 意思是, CMake会生成Visual Studio 2019的工程文件, 比如`.sln`, `.vcxproj`. 
* `toolchainFile`: 