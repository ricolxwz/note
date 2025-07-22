---
title: 文件
comments: true
icon: material/file-tree
---

## `std::print`

`std::print`是C++23中引入的一个新的输出函数, 定义在`<print>`头文件中. 它旨在提供一种比`iostreams` (`std::cout`)更高效, 更易用且类型安全的替代方案.

主要特点:

1.  性能: `std::print`通常比`std::cout`更快. 它减少了`iostreams`中存在的格式化和虚拟函数调用开销.
2.  易用性: 语法类似于Python的`print()`函数或C\#的`Console.WriteLine`, 使用`{}`作为占位符, 直观简洁.
3.  类型安全: `std::print`使用编译时格式字符串检查 (如果编译器支持). 这意味着格式化错误可以在编译期间被捕获, 而不是在运行时导致未定义行为, 这一点优于`printf`.
4.  Unicode支持: 默认处理UTF-8编码的字符串, 能正确打印各种Unicode字符.
5.  线程安全: `std::print`和`std::println`是线程安全的, 它们的输出不会与其他线程的输出交错.

基本用法:

要使用`std::print`, 你需要包含`<print>`头文件.

  * `std::print()`: 打印格式化的字符串到标准输出 (`stdout`).
  * `std::println()`: 功能与`std::print()`相同, 但会在末尾额外打印一个换行符.

示例:

```cpp
#include <print>
#include <string>
#include <vector>

int main() {
    int x = 42;
    double pi = 3.14159;
    std::string s = "world";

    // 基本用法
    std::println("Hello, C++23!"); // 输出: Hello, C++23! (并换行)

    // 格式化输出
    std::print("The answer is {}. \n", x); // 输出: The answer is 42.
    std::println("Hello, {}. The value of pi is {}. ", s, pi); // 输出: Hello, world. The value of pi is 3.14159.

    // 格式说明符
    std::println("Pi formatted: {:.2f}", pi); // 输出: Pi formatted: 3.14
    std::println("Integer in hex: {:#x}", x); // 输出: Integer in hex: 0x2a

    // 打印到文件流
    // FILE* f = std::fopen("output.txt", "w");
    // if (f) {
    //     std::print(f, "This goes to a file. \n");
    //     std::fclose(f);
    // }

    return 0;
}
```

格式化语法:

`std::print`的格式化功能继承自`std::format`. 占位符`{}`中可以包含格式说明符, 语法如下:

`{[index]:[fill&align][sign][#][0][width][.precision][type]}`

  * `{}`: 默认按顺序格式化参数.
  * `{0}`, `{1}`: 按索引指定参数.
  * `:<` : 左对齐.
  * `:>` : 右对齐.
  * `:^` : 居中对齐.
  * `:_>`: 使用`_`作为填充符并右对齐.
  * `:.2f`: 浮点数精度为2.
  * `:b`: 二进制.
  * `:o`: 八进制.
  * `:x`: 十六进制.
  * `:X`: 大写十六进制.
  * `:#`: 对于整数类型, 添加进制前缀 (如`0b`, `0o`, `0x`).

与`iostream`和`printf`的对比

| 特性 | `std::print` | `std::iostream` (`std::cout`) | `printf` |
| --- | --- | --- | --- |
| 性能 | 通常最快 | 较慢 | 很快, 但可能不如`std::print` |
| 类型安全 | 是 | 是 | 否 |
| 扩展性 | 良好, 可为用户自定义类型重载 | 良好, 可为用户自定义类型重载 | 差, 难以处理用户自定义类型 |
| 语法 | 简洁 (`{}`占位符) | 繁琐 (`<<`操作符) | 紧凑 (`%`占位符), 但易出错 |
| C++标准 | C++23 | C++98 | C |

编译器支持:

`std::print`是C++23的核心特性之一. 你需要一个支持C++23的现代编译器, 并可能需要链接到`{fmt}`库的实现 (具体取决于编译器的实现方式).

  * MSVC: Visual Studio 2022 17.8或更高版本.
  * GCC: GCC 14或更高版本.
  * Clang: Clang 17或更高版本 (可能需要手动链接`-lfmt`).

总而言之, `std::print`提供了一种现代化, 高效且安全的输出方式, 是C++23中推荐使用的标准输出方法.
