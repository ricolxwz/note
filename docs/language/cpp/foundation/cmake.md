---
title: CMake
comments: false
icon: material/wrench
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

## 重要函数

现代 CMake 的核心思想是围绕 **target** 写配置. 一个 target 可以是可执行文件, 静态库, 动态库, 接口库等. 尽量优先使用 `target_xxx` 系列函数, 少用全局的 `include_directories`, `link_libraries`, `add_definitions` 这类老写法.

### `cmake_minimum_required`

声明项目需要的最低 CMake 版本.

```cmake
cmake_minimum_required(VERSION 3.20)
```

它通常是顶层 `CMakeLists.txt` 的第一行. 除了检查版本之外, 它还会影响 CMake policy 的默认行为, 所以不要省略.

### `project`

声明项目名称, 版本, 使用的语言.

```cmake
project(MyProject VERSION 1.0.0 LANGUAGES C CXX)
```

常见变量:

* `PROJECT_NAME`: 当前项目名.
* `PROJECT_VERSION`: 当前项目版本.
* `CMAKE_PROJECT_NAME`: 最顶层项目名.

### `add_executable`

创建一个可执行文件 target.

```cmake
add_executable(app
    src/main.cpp
    src/app.cpp
)
```

这里的 `app` 是 target 名字, 后面很多配置都应该围绕 `app` 来写, 例如编译选项, 头文件目录, 链接库等.

### `add_library`

创建一个库 target.

```cmake
add_library(core STATIC
    src/core.cpp
)

add_library(plugin SHARED
    src/plugin.cpp
)
```

常见类型:

* `STATIC`: 静态库, 例如 `.a`, `.lib`.
* `SHARED`: 动态库, 例如 `.so`, `.dll`, `.dylib`.
* `MODULE`: 插件式动态库, 通常不被其他 target 直接链接.
* `INTERFACE`: 只有使用要求, 没有自己的编译产物. 常用于 header-only library 或统一传播编译选项.

`INTERFACE` 例子:

```cmake
add_library(project_options INTERFACE)
target_compile_features(project_options INTERFACE cxx_std_20)
```

### `target_link_libraries`

给 target 链接库, 也可以传播依赖关系. 这是 CMake 里最重要的函数之一.

```cmake
target_link_libraries(app
    PRIVATE
        core
        fmt::fmt
)
```

基本含义:

* `app` 链接 `core` 和 `fmt::fmt`.
* 如果 `core` 自己还依赖别的库, CMake 会根据依赖关系帮你处理链接顺序.
* `fmt::fmt` 这种带 `::` 的名字通常是 imported target, 来自 `find_package` 或第三方包管理器.

作用域非常重要:

* `PRIVATE`: 只给当前 target 使用. 例如 `app` 链接 `core`, 但不把这个依赖传播给别人.
* `PUBLIC`: 当前 target 使用, 并且使用当前 target 的其他 target 也需要这个依赖.
* `INTERFACE`: 当前 target 自己不用, 但是使用当前 target 的其他 target 需要.

例子:

```cmake
add_library(core src/core.cpp)

target_link_libraries(core
    PUBLIC
        fmt::fmt
    PRIVATE
        Threads::Threads
)

add_executable(app src/main.cpp)
target_link_libraries(app PRIVATE core)
```

这里 `core` 的公开接口里可能包含 `fmt` 类型或头文件, 所以 `fmt::fmt` 用 `PUBLIC`. `Threads::Threads` 只是 `core` 内部实现需要, 所以用 `PRIVATE`.

简单判断:

* 只有 `.cpp` 实现文件需要的依赖, 用 `PRIVATE`.
* 头文件里暴露出去的依赖, 用 `PUBLIC`.
* header-only/interface target 自己不编译, 只传播要求, 用 `INTERFACE`.

### `target_include_directories`

给 target 添加头文件搜索目录.

```cmake
target_include_directories(core
    PUBLIC
        include
    PRIVATE
        src
)
```

含义:

* `include` 是公开头文件目录, 链接 `core` 的 target 也需要知道它.
* `src` 是内部头文件目录, 只有 `core` 自己编译时需要.

安装库时经常会写成:

```cmake
target_include_directories(core
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
)
```

`BUILD_INTERFACE` 表示源码构建时使用的路径, `INSTALL_INTERFACE` 表示安装以后使用的路径.

### `target_compile_features`

声明 target 需要的 C++ 标准或语言特性.

```cmake
target_compile_features(core PUBLIC cxx_std_20)
```

推荐优先使用它, 而不是全局写:

```cmake
set(CMAKE_CXX_STANDARD 20)
```

因为 `target_compile_features` 是 target 级别的, 依赖传播更清楚. 如果 `core` 的头文件需要 C++20, 那么用 `PUBLIC`; 如果只是 `core` 的 `.cpp` 需要 C++20, 那么用 `PRIVATE`.

### `target_compile_options`

给 target 添加编译选项.

```cmake
target_compile_options(core
    PRIVATE
        -Wall
        -Wextra
        -Wpedantic
)
```

跨编译器时常配合 generator expression:

```cmake
target_compile_options(core
    PRIVATE
        $<$<CXX_COMPILER_ID:GNU,Clang>:-Wall -Wextra -Wpedantic>
        $<$<CXX_COMPILER_ID:MSVC>:/W4>
)
```

### `target_compile_definitions`

给 target 添加宏定义.

```cmake
target_compile_definitions(core
    PRIVATE
        CORE_ENABLE_LOG
    PUBLIC
        CORE_USE_UTF8
)
```

等价于编译命令里的 `-DCORE_ENABLE_LOG`. 不需要自己写 `-D`, CMake 会处理.

### `target_sources`

给已有 target 追加源文件.

```cmake
add_library(core)

target_sources(core
    PRIVATE
        src/core.cpp
        src/parser.cpp
)
```

它适合在比较复杂的项目里分模块追加文件, 也可以配合条件编译:

```cmake
if(WIN32)
    target_sources(core PRIVATE src/platform/windows.cpp)
else()
    target_sources(core PRIVATE src/platform/posix.cpp)
endif()
```

### `find_package`

查找外部依赖包.

```cmake
find_package(fmt CONFIG REQUIRED)

add_executable(app src/main.cpp)
target_link_libraries(app PRIVATE fmt::fmt)
```

常见参数:

* `REQUIRED`: 找不到就直接报错.
* `CONFIG`: 优先使用包自己提供的 `xxxConfig.cmake`, 常见于 vcpkg, Conan, 手动安装的现代 CMake 包.
* `MODULE`: 使用 CMake 自带或项目提供的 `Findxxx.cmake`.

现代写法通常希望 `find_package` 之后得到 imported target, 例如 `fmt::fmt`, `Threads::Threads`, `OpenSSL::SSL`.

### `option`

定义一个开关选项, 会进入 CMake Cache.

```cmake
option(BUILD_TESTING "Build tests" ON)
option(ENABLE_ASAN "Enable AddressSanitizer" OFF)
```

命令行里可以这样改:

```bash
cmake -S . -B build -DBUILD_TESTING=OFF -DENABLE_ASAN=ON
```

在 CMake 里判断:

```cmake
if(BUILD_TESTING)
    add_subdirectory(tests)
endif()
```

### `set`

设置变量.

```cmake
set(MY_SOURCES
    src/a.cpp
    src/b.cpp
)
```

设置 cache 变量:

```cmake
set(ENABLE_FEATURE ON CACHE BOOL "Enable feature")
```

普通变量有作用域, 通常在当前目录和子目录中可见. Cache 变量会写进 `CMakeCache.txt`, 用户可以通过 `-D` 或 CMake GUI 修改.

### `if`

条件判断.

```cmake
if(WIN32)
    target_compile_definitions(core PRIVATE PLATFORM_WINDOWS)
elseif(APPLE)
    target_compile_definitions(core PRIVATE PLATFORM_MACOS)
elseif(UNIX)
    target_compile_definitions(core PRIVATE PLATFORM_LINUX)
endif()
```

常见内置条件:

* `WIN32`: Windows 平台.
* `APPLE`: Apple 平台, 包括 macOS, iOS 等.
* `UNIX`: Unix-like 平台, macOS 也为真.
* `MSVC`: 使用 MSVC 或兼容 MSVC 的编译器前端.

### `add_subdirectory`

把子目录加入构建.

```cmake
add_subdirectory(src)
add_subdirectory(tests)
```

子目录里需要有自己的 `CMakeLists.txt`. 这通常用于拆分大型项目:

```text
project/
  CMakeLists.txt
  src/CMakeLists.txt
  tests/CMakeLists.txt
```

### `include`

加载另一个 CMake 脚本文件.

```cmake
include(cmake/CompilerWarnings.cmake)
include(GNUInstallDirs)
```

`add_subdirectory` 是加入一个带 `CMakeLists.txt` 的子项目, `include` 是把某个 `.cmake` 文件插进来执行.

### `install`

定义安装规则.

```cmake
install(TARGETS core app
    EXPORT MyProjectTargets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(DIRECTORY include/
    DESTINATION include
)
```

常见产物类型:

* `RUNTIME`: 可执行文件和 Windows `.dll`.
* `LIBRARY`: 动态库, 例如 `.so`, `.dylib`.
* `ARCHIVE`: 静态库, 例如 `.a`, `.lib`.

执行安装:

```bash
cmake --install build
```

### `enable_testing` 和 `add_test`

启用并注册测试.

```cmake
enable_testing()

add_executable(core_tests tests/core_tests.cpp)
target_link_libraries(core_tests PRIVATE core)

add_test(NAME core_tests COMMAND core_tests)
```

运行测试:

```bash
ctest --test-dir build --output-on-failure
```

很多项目会用 CMake 自带变量 `BUILD_TESTING`:

```cmake
include(CTest)

if(BUILD_TESTING)
    add_subdirectory(tests)
endif()
```

`include(CTest)` 会自动提供 `BUILD_TESTING` 这个选项, 默认通常是 `ON`.

### `message`

打印信息, 常用于调试 CMake 配置过程.

```cmake
message(STATUS "Compiler: ${CMAKE_CXX_COMPILER}")
message(WARNING "Feature X is experimental")
message(FATAL_ERROR "Missing required dependency")
```

常见级别:

* `STATUS`: 普通状态信息.
* `WARNING`: 警告, 继续配置.
* `FATAL_ERROR`: 错误, 停止配置.

### `file`

处理文件和路径. 它功能很多, 常见用法包括读取文件, 复制文件, 递归收集文件等.

```cmake
file(GLOB CONFIG_FILES "${CMAKE_CURRENT_SOURCE_DIR}/config/*.json")
file(COPY assets DESTINATION "${CMAKE_CURRENT_BINARY_DIR}")
```

注意: `file(GLOB ...)` 自动收集源文件虽然方便, 但新增 `.cpp` 文件时 CMake 不一定会自动重新配置. 对核心源文件, 更推荐显式写在 `target_sources` 或 `add_library` 里.

### `configure_file`

根据模板生成文件, 常用于生成配置头文件.

```cmake
configure_file(
    config.h.in
    generated/config.h
)
```

`config.h.in`:

```c
#pragma once

#define PROJECT_VERSION "@PROJECT_VERSION@"
#cmakedefine ENABLE_FEATURE
```

生成后可以把输出目录加入头文件路径:

```cmake
target_include_directories(core
    PRIVATE
        "${CMAKE_CURRENT_BINARY_DIR}/generated"
)
```

### `add_custom_command` 和 `add_custom_target`

添加自定义构建步骤.

`add_custom_command` 通常用于生成某个文件:

```cmake
add_custom_command(
    OUTPUT generated/version.cpp
    COMMAND python ${CMAKE_CURRENT_SOURCE_DIR}/scripts/gen_version.py > generated/version.cpp
    DEPENDS scripts/gen_version.py
    COMMENT "Generating version.cpp"
)

target_sources(core PRIVATE generated/version.cpp)
```

`add_custom_target` 通常用于创建一个可以手动执行的目标:

```cmake
add_custom_target(format
    COMMAND clang-format -i ${MY_SOURCES}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
```

### 常见 target 写法模板

```cmake
cmake_minimum_required(VERSION 3.20)

project(MyProject VERSION 1.0.0 LANGUAGES CXX)

find_package(fmt CONFIG REQUIRED)

add_library(core
    src/core.cpp
)

target_include_directories(core
    PUBLIC
        include
)

target_compile_features(core
    PUBLIC
        cxx_std_20
)

target_link_libraries(core
    PUBLIC
        fmt::fmt
)

add_executable(app
    src/main.cpp
)

target_link_libraries(app
    PRIVATE
        core
)
```

这套写法的重点是: **先创建 target, 再把 include, compile features, compile options, definitions, link libraries 都挂到具体 target 上**.
