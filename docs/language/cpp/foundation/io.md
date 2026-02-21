---
title: 文件
comments: true
icon: material/file-tree
---

## `std::format`

`std::format`是C++20标准库中引入的一个强大的文本格式化工具. 它旨在提供一个类型安全, 高性能且易于使用的替代方案, 以取代传统的`printf`系列函数和iostreams.

* 类型安全: 编译器可以在编译时检查格式化字符串和参数类型是否匹配, 避免运行时错误.
* 性能更佳: 在许多情况下, `std::format`比iostreams和`sprintf`更快.
* 功能强大: 语法借鉴自Python的`str.format`, 灵活且直观.

要使用`std::format`, 你需要包含`<format>`头文件. 其基本语法非常简单, 使用花括号`{}`作为待格式化值的占位符.

示例:

```cpp
#include <iostream>
#include <format>
#include <string>

int main() {
    std::string name = "Alice";
    int age = 30;

    // 使用 std::format 创建字符串
    std::string message = std::format("User {} is {} years old.", name, age);

    std::cout << message << std::endl;
    // 输出: User Alice is 30 years old.
    return 0;
}
```

如果你需要在最终的输出字符串中包含字面意义上的花括号`{`或`}`, 你可以通过双写花括号`{{`和`}}`来进行转义.

示例:

```cpp
#include <iostream>
#include <format>

int main() {
    std::string text = std::format("In C++, you use {{ and }} to escape braces.");
    std::cout << text << std::endl;
    // 输出: In C++, you use { and } to escape braces.
    return 0;
}
```

`std::format`允许你通过在花括号内指定索引来控制参数的顺序. 这使得参数可以被重复使用或以不同于它们在参数列表中出现的顺序进行格式化. 索引从`0`开始.

示例:

```cpp
#include <iostream>
#include <format>
#include <string>

int main() {
    std::string first = "World";
    std::string second = "Hello";

    // {1} 对应第二个参数 (second), {0} 对应第一个参数 (first)
    std::string message = std::format("{1}, {0}! And {1} again!", first, second);

    std::cout << message << std::endl;
    // 输出: Hello, World! And Hello again!
    return 0;
}
```

格式说明符(Format Specifiers)位于占位符`{}`内部, 用冒号`:`引出, 用于精细控制值的输出格式, 例如对齐, 填充, 精度等. 语法: `{:[[fill]align][sign][#][0][width][.precision][type]}`

简单示例:

```cpp
#include <iostream>
#include <format>

int main() {
    double pi = 3.14159265;

    // :<10 表示左对齐, 总宽度为10
    // :.2f  表示浮点数, 保留两位小数
    std::string s1 = std::format("Value:<{:<10}>", 42);
    std::string s2 = std::format("Pi is roughly {:.2f}.", pi);

    std::cout << s1 << std::endl; // 输出: Value:<42        >
    std::cout << s2 << std::endl; // 输出: Pi is roughly 3.14.
    return 0;
}
```

类型说明符(Type Specifiers)用于指定如何解释和格式化一个值, 尤其对于整数和指针非常有用.

* `b`: 二进制格式
* `o`: 八进制格式
* `d`: 十进制格式 (默认)
* `x` / `X`: 十六进制格式 (小写/大写)
* `p`: 指针地址格式

示例:

```cpp
#include <iostream>
#include <format>

int main() {
    int number = 255;
    int* ptr = &number;

    std::cout << std::format("Decimal: {}", number) << std::endl;       // 输出: Decimal: 255
    std::cout << std::format("Binary: {:b}", number) << std::endl;        // 输出: Binary: 11111111
    std::cout << std::format("Hex: {:x}", number) << std::endl;          // 输出: Hex: ff
    std::cout << std::format("Pointer: {:p}", (void*)ptr) << std::endl; // 输出: Pointer: (一个十六进制地址)
    return 0;
}
```

### 对STL容器的直接支持

C++23标准对`std::format`库进行了一项重要扩展, 使其能够原生支持直接格式化标准模板库 (STL) 中的容器, 例如`std::vector`, `std::list`, 和`std::map`. 这一新特性极大地简化了调试和数据显示的过程, 你不再需要手动遍历容器来打印其内容. 这个功能建立在C++20引入的`std::format`基础之上. 在C++23之前, 尝试将整个容器直接传递给`std::format`会导致编译错误, 因为标准库没有为容器类型提供相应的格式化器(formatter).

C++23之前的做法 (需要手动循环):

```cpp
// 伪代码, 展示了旧方法的思路
for (const auto& item : my_vector) {
    // 逐个打印元素
}
```

有了C++23, 这一切变得异常简单. 你可以直接将容器对象放入`std::format`的参数中. 示例 (C++23):

```cpp
#include <iostream>
#include <format>
#include <vector>

int main() {
    std::vector<int> numbers = {10, 20, 30, 40};

    // 直接格式化整个 vector
    std::string formatted_vector = std::format("The vector contains: {}.", numbers);

    std::cout << formatted_vector << std::endl;
    // 预期的输出: The vector contains: [10, 20, 30, 40].
    return 0;
}
```

这个功能为调试和日志记录提供了巨大的便利.

### 对自己类型的支持

`std::format`是C++20中一个现代化的文本格式化库, 它通过占位符`{}`提供了一种类型安全且高效的方式来构建字符串. 虽然它可以原生处理所有基本类型, 但对于我们自己创建的`struct`或`class` (自定义类型), `std::format`默认并不知道如何处理它们. 要让`std::format`能够打印自定义类型 (例如一个`Point2D`结构体), 你需要为这个类型提供一个`std::formatter`的模板特化 (template specialization). 这本质上是告诉`std::format`库: “嘿, 当你遇到`Point2D`这个类型时, 请使用我定义的这个规则来将它转换成字符串.” 这个特化结构体通常需要实现两个核心函数: `parse`和`format`.

自定义类型示例:

```cpp
struct Point2D {
    double x, y;
};
```

1. `parse` 函数

    `parse`函数负责解析格式说明符. 格式说明符是你在占位符`{}`中冒号`:`后面的部分 (例如`{:.2f}`).

    * 功能: 检查用户是否提供了特殊的格式选项, 并为后续的`format`函数做好准备.
    * 示例: 我们可以让`parse`函数识别一个`$`符号, 当用户写`std::format("{$}", my_point)`时, 就采用一种不同的格式输出.
    * 返回值: 它必须返回一个指向格式字符串中未解析部分的迭代器 (通常是格式说明符的末尾).

2. `format` 函数

    `format`函数执行实际的格式化工作. 它接收要格式化的值和一个输出上下文, 然后将格式化后的字符串写入该上下文.

    * 功能: 根据`parse`函数解析出的格式选项, 将对象转换为字符串.
    * 核心工具: 通常使用`std::format_to`将最终结果写入输出迭代器.

完整示例: `formatter<Point2D>`: 下面是一个完整的`Point2D`格式化器特化, 它实现了默认格式`(x, y)`和一个由`$`触发的特殊格式`[x, y]`.

```cpp
#include <iostream>
#include <format>

// 要被格式化的自定义类型
struct Point2D {
    double x, y;
};

// 为 Point2D 特化 std::formatter
template <>
struct std::formatter<Point2D> {
private:
    char presentation = 'd'; // 'd' for default, '$' for special

public:
    // 1. parse 函数: 解析格式说明符
    constexpr auto parse(std::format_parse_context& ctx) {
        auto it = ctx.begin(), end = ctx.end();
        if (it != end && (*it == '$' || *it == 'd')) {
            presentation = *it++;
        }

        // 检查格式说明符的末尾是否是 '}'
        if (it != end && *it != '}') {
            throw std::format_error("invalid format");
        }

        return it;
    }

    // 2. format 函数: 执行格式化
    auto format(const Point2D& p, std::format_context& ctx) const {
        if (presentation == '$') {
            return std::format_to(ctx.out(), "[{}, {}]", p.x, p.y);
        }
        return std::format_to(ctx.out(), "({}, {})", p.x, p.y);
    }
};

int main() {
    Point2D point = {1.2, 3.4};

    // 使用默认格式
    std::string s1 = std::format("Default: {}", point);
    std::cout << s1 << std::endl; // 输出: Default: (1.2, 3.4)

    // 使用 '$' 指定的特殊格式
    std::string s2 = std::format("Special: {: $}", point);
    std::cout << s2 << std::endl; // 输出: Special: [1.2, 3.4]
    return 0;
}
```

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

## 流对象

我们可以把流 (Stream) 想象成一条用于数据传输的管道或传送带. 它是一个抽象概念, 代表了程序与某个I/O设备 (如屏幕, 键盘, 文件等) 之间的数据流动通道. 而流对象就是程序中用来管理和操作这条管道的对象. 流对象的最大作用是抽象化. 你的程序不需要关心数据最终是写到屏幕上, 一个文件里, 还是通过网络发送出去. 你只需要学习一套统一的操作方法 (比如使用`<<`插入数据), 然后将数据 "推入" 到相应的流对象中.

* 你想输出到屏幕? 把数据推给`std::cout`对象.
* 你想写入到文件? 把数据推给一个`std::ofstream`对象.
* 你想从键盘读取输入? 从`std::cin`对象中 "拉取" 数据.

无论后端设备是什么, 你使用的编程接口都是一致的. 这极大地简化了I/O编程.

### 流的关键特征

1.  单向性 (Unidirectional): 数据在流中通常只有一个方向.

    * 输出流 (Output Stream): 数据从程序流向外部设备 (例如`std::cout`).
    * 输入流 (Input Stream): 数据从外部设备流向程序 (例如`std::cin`).

2.  顺序性 (Sequential): 数据是按顺序处理的. 你不能跳到流的中间去读取或写入一个字节 (对于某些特定类型的流如文件流, 有些例外, 但基本概念是顺序的). 就像传送带上的物品, 你需要按顺序处理它们.

3.  缓冲 (Buffering): 为了提高效率, 数据通常不会在你发送后立刻被写入到最终设备. 相反, 它们会先被收集在一个叫做缓冲区 (buffer) 的内存区域. 当缓冲区满了, 或者你手动刷新 (flush) 它时 (比如使用`std::endl`), 数据才会被一次性地批量写入. 这减少了与慢速I/O设备频繁交互的次数, 从而提升性能.

### C++中的主要流对象类型

所有这些都定义在`<iostream>`, `<fstream>`, `<sstream>`等头文件中.

| 流对象类型 | 头文件 | 功能 | 示例对象 |
| :--- | :--- | :--- | :--- |
| 控制台流 | `<iostream>` | 用于与标准控制台 (屏幕, 键盘) 交互. | `std::cout`, `std::cin`, `std::cerr` |
| 文件流 | `<fstream>` | 用于读写磁盘上的文件. | `std::ifstream` (输入), `std::ofstream` (输出) |
| 字符串流 | `<sstream>` | 用于在内存中的`std::string`对象上进行I/O操作. | `std::stringstream` |

示例:

```cpp
#include <iostream>  // for std::cout, std::cin
#include <fstream>   // for std::ofstream
#include <sstream>   // for std::stringstream
#include <string>

int main() {
    // 1. 控制台流: 输出到屏幕
    std::cout << "Hello from the console stream!" << std::endl;

    // 2. 文件流: 写入到文件
    std::ofstream my_file("log.txt"); // 创建一个文件流对象并关联到 log.txt
    my_file << "This is a log message."; // 使用相同的 << 操作符
    my_file.close();

    // 3. 字符串流: 在内存中格式化字符串
    std::stringstream ss;
    int major = 3, minor = 1;
    ss << "Version: " << major << "." << minor; // 将数据写入字符串流
    std::string version_string = ss.str(); // 从流中提取出完整的字符串

    std::cout << version_string << std::endl; // 输出: Version: 3.1

    return 0;
}
```

总而言之, 流对象是C++中一个强大且灵活的工具, 它将各种复杂的I/O操作统一到了一套简单且类型安全的接口之下.

### 基类

在C++中, 所有的输入/输出 (I/O) 操作都围绕流 (stream) 这个核心概念展开. 你可以把流想象成连接程序和外部设备 (如键盘, 屏幕, 文件) 的数据管道. 为了管理这些管道, C++提供了两个最基础的模板 (基类): `std::istream`和`std::ostream`.

#### `std::ostream`

`std::ostream`是所有输出流的“始祖”. 它定义了一套将数据从程序发送到外部目标的标准接口.

* 核心功能: 负责输出 (写操作).
* 关键操作符: `<<` (插入运算符). 你可以把它理解为将你的数据插入到输出管道中.
* 著名实例: `std::cout`. 它是连接到控制台 (屏幕) 的一个全局`std::ostream`对象.
* 主要派生类:
    * `std::ofstream`: 用于向文件输出.
    * `std::ostringstream`: 用于向内存中的字符串输出.

示例:

```cpp
#include <iostream>
#include <fstream>

int main() {
    // 1. 输出到屏幕 (使用 std::cout)
    std::cout << "Hello, Console!" << std::endl;

    // 2. 输出到文件 (使用 std::ofstream)
    std::ofstream file("data.txt");
    file << "Hello, File!" << std::endl; // 语法完全相同

    return 0;
}
```

##### 成员函数

`std::ostream`作为所有C++输出流的基类, 除了我们最常用的`operator<<`之外, 还提供了一系列成员函数来对输出进行更精细的控制. 这些函数主要分为格式化输出, 非格式化输出, 状态管理和定位四大类.

1. 格式化与非格式化输出

    虽然`operator<<`是最常见的格式化输出方式, 但`ostream`也提供了用于输出单个字符或原始字节的非格式化输出函数.

    1. `put()`

        `put()`函数用于输出单个字符.

        * 签名: `ostream& put(char_type c);`
        * 功能: 将字符`c`写入流中.

        示例:

        ```cpp
        #include <iostream>

        int main() {
            std::cout.put('H');
            std::cout.put('i');
            std::cout.put('!');
            std::cout.put('\n'); // 输出换行符
            // 输出: Hi!
            return 0;
        }
        ```

    2. `write()`

        `write()`函数用于输出一块原始的二进制数据 (一个字符序列).

        * 签名: `ostream& write(const char_type* s, streamsize count);`
        * 功能: 从地址`s`开始, 将`count`个字节的数据不经任何格式化直接写入流中. 这对于写入二进制文件或网络套接字非常有用.

        示例:

        ```cpp
        #include <iostream>
        #include <fstream>

        int main() {
            const char data[] = "Binary Data";
            // 注意: sizeof(data) 包含末尾的 '\0'
            // 我们通常只写入有效字符, 所以是 sizeof(data) - 1
            std::ofstream file("data.bin", std::ios::binary);

            if(file) {
                file.write(data, sizeof(data) - 1);
                file.close();
                std::cout << "Wrote 11 bytes to data.bin" << std::endl;
            }
            return 0;
        }
        ```

2. 状态管理

    流在进行I/O操作时可能会遇到错误. `ostream`提供了一组成员函数来检查和管理流的内部状态.

    1. `good()`, `fail()`, `bad()`, `eof()`

        这些函数用于检查流的特定状态位.

        * `bool good()`: 如果流没有任何错误, 返回`true`.
        * `bool fail()`: 如果发生可恢复的逻辑错误 (如格式化错误) 或更严重的错误, 返回`true`.
        * `bool bad()`: 如果发生不可恢复的读/写错误 (如磁盘损坏), 导致流被破坏, 返回`true`.
        * `bool eof()`: End Of File. 对于输出流意义不大, 主要用于输入流.

        示例:

        ```cpp
        #include <iostream>
        #include <fstream>

        int main() {
            // 假设 non_existent_dir 不存在, 无法创建文件
            std::ofstream file("/non_existent_dir/test.txt");

            if (file.fail()) {
                std::cerr << "Error: Failed to open the file." << std::endl;
            }
            return 0;
        }
        ```

    2. `clear()`

        `clear()`函数用于清除(重置)流的状态标志.

        * 签名: `void clear(iostate state = goodbit);`
        * 功能: 将流的状态重置为你指定的状态, 默认是`goodbit` (即清除所有错误状态). 如果你想继续使用一个发生了`fail`错误的流, 你必须先调用`clear()`.

3. 缓冲管理

    `flush()`函数用于刷新缓冲区.

    * 签名: `ostream& flush();`
    * 功能: 强制将缓冲区中所有待处理的输出立即写入到目标设备. `std::endl`除了换行外, 也隐式调用了`flush()`.

    示例:

    ```cpp
    #include <iostream>
    #include <thread>
    #include <chrono>

    int main() {
        std::cout << "Processing... ";
        // std::cout.flush(); // 如果取消此行注释, "Processing... "会立即显示
                            // 否则它可能和"Done."一起在程序结束时显示

        std::this_thread::sleep_for(std::chrono::seconds(2));

        std::cout << "Done." << std::endl;
        return 0;
    }
    ```

4. 定位函数 (Positioning)

    这些函数主要用于可以在流中任意移动位置的文件流 (`ofstream`), 对于`std::cout`则没有意义.

    1. `seekp()`

        `seekp()` (seek put) 用于在输出流中移动写入指针的位置.

        * 签名:
            * `ostream& seekp(pos_type pos);` (移动到绝对位置)
            * `ostream& seekp(off_type off, ios_base::seekdir dir);` (从某个基准点进行相对偏移)
        * 基准点 (`seekdir`):
            * `ios_base::beg`: 从流的开头
            * `ios_base::cur`: 从当前位置
            * `ios_base::end`: 从流的末尾

    2. `tellp()`

        `tellp()` (tell put) 用于获取当前写入指针的位置.

        * 签名: `pos_type tellp();`

        示例:

        ```cpp
        #include <iostream>
        #include <fstream>

        int main() {
            std::ofstream file("test.txt");
            file << "Hello World";

            std::cout << "Current position: " << file.tellp() << std::endl; // 输出: 11

            file.seekp(6); // 移动到'W'的位置
            file << "There"; // 覆盖 "World"

            file.close(); // 文件最终内容将是 "Hello There"
            return 0;
        }
        ```

#### `std::istream`

`std::istream`是所有输入流的“始祖”. 它定义了一套从数据源读取数据到程序的标准接口.

* 核心功能: 负责输入 (读操作).
* 关键操作符: `>>` (提取运算符). 你可以把它理解为从输入管道中提取数据到你的变量里.
* 著名实例: `std::cin`. 它是连接到键盘的一个全局`std::istream`对象.
* 主要派生类:
    * `std::ifstream`: 用于从文件读取.
    * `std::istringstream`: 用于从字符串读取.

示例:

```cpp
#include <iostream>
#include <string>

int main() {
    int age;
    std::string name;

    std::cout << "Please enter your name: ";
    std::cin >> name; // 从键盘提取一个词到 name

    std::cout << "Please enter your age: ";
    std::cin >> age; // 从键盘提取一个数字到 age

    std::cout << "Hello " << name << ", you are " << age << " years old." << std::endl;
    return 0;
}
```

---

`istream`和`ostream`作为基类的最大优势在于提供了一个统一的编程接口. 你可以编写一个函数, 它接受`std::ostream&`作为参数, 那么这个函数就可以向任何输出目标 (屏幕, 文件, 字符串) 或者说是流对象 写入数据, 无需修改任何代码. 这就是多态的威力.

示例:

```cpp
#include <iostream>
#include <fstream>
#include <sstream>

// 一个可以向任何 ostream 输出的通用函数
void print_data(std::ostream& destination, int data) {
    destination << "Data value is: " << data << std::endl;
}

int main() {
    int my_data = 123;

    print_data(std::cout, my_data); // 输出到屏幕

    std::ofstream file("log.txt");
    print_data(file, my_data);      // 输出到文件

    std::ostringstream oss;
    print_data(oss, my_data);       // 输出到字符串
    std::cout << "String stream contains: " << oss.str();

    return 0;
}
```

---

| 特性 | `std::istream` | `std::ostream` |
| :--- | :--- | :--- |
| 方向 | 输入 (读取) | 输出 (写入) |
| 操作符 | `>>` (提取) | `<<` (插入) |
| 目的 | 将数据从外部源读入程序 | 将数据从程序发送到外部目标 |
| 代表 | `std::cin` | `std::cout` |
| 家族成员| `ifstream`, `istringstream` | `ofstream`, `ostringstream` |

## `std::cout`

`std::cout`是C++中用于将数据输出到标准输出设备 (通常是你的电脑屏幕或终端) 的核心工具. 简单来说, `std::cout`就是C++中负责打印信息到屏幕上的对象. 它存在于`<iostream>`头文件中.  `std::cout`代表 "character output" (字符输出), 它是一个预定义好的流 (stream) 对象. 你可以把 "流" 想象成一条数据传输的管道. 当你把数据发送给`std::cout`时, 这些数据就会顺着这条管道流向标准输出设备. 关键的操作符是 `<<`, 称为插入运算符 (insertion operator). 它的作用就是把你右边的数据 "插入" 到左边的流对象中.

代码示例:

```cpp
#include <iostream> // 必须包含这个头文件
#include <string>

int main() {
    int age = 30;
    std::string name = "Bob";

    // 使用 << 将字符串字面量插入到 std::cout 流中
    std::cout << "Hello, World!";

    // 换行
    std::cout << std::endl;

    // 可以链接多个 << 操作符来输出不同类型的数据
    std::cout << "Name: " << name << ", Age: " << age << std::endl;

    return 0;
}
```

输出:

```
Hello, World!
Name: Bob, Age: 30
```

核心特性:

* 类型安全 (Type-Safe): C++编译器知道每个变量的类型, 所以`std::cout`能够自动为整数, 浮点数, 字符串等不同类型的数据选择正确的输出方式. 这比C语言的`printf`函数更安全, 因为你不需要手动指定`%d`或`%s`这样的格式化符号, 从而避免了类型不匹配的错误.
* 链式调用 (Chaining): `<<`操作符会返回流对象自身的引用, 这就是为什么你可以像`std::cout << a << b << c;`这样把多个输出操作链接在一起的原因.
* 可扩展性 (Extensible): 你可以为你自己的自定义类型 (比如一个`Point`类) 重载`operator<<`, 让`std::cout`知道如何打印你的对象, 这使得代码非常直观.

`std::cout` vs `std::endl`: 你经常会看到`std::endl`和`std::cout`一起使用. `std::endl` (end line) 做两件事:

1.  向输出流中插入一个换行符 (`\n`).
2.  刷新 (flush) 输出缓冲区.

"刷新缓冲区" 意味着强制将内存中等待输出的所有数据立即发送到目标设备. 在大多数情况下, 你只需要换行, 使用换行符`'\n'`会更高效, 因为它不强制刷新.

性能提示:

```cpp
// 更高效, 只换行
std::cout << "This is a line.\n";

// 换行并强制刷新, 可能会有微小的性能开销
std::cout << "This is another line." << std::endl;
```

## `std::cerr`, `std::clog`

这两个都是C++中用于输出错误信息的标准错误流对象, 它们都定义在`<iostream>`头文件中. 它们都与`std::cout`类似, 使用`<<`操作符来输出. 它们的主要区别在于缓冲策略 (buffering strategy).

`std::cerr`是无缓冲的 (unbuffered) 输出流.

* 核心特性: 当你把数据发送给`std::cerr`时, 它会立即尝试将信息输出到目标设备 (通常是屏幕), 而不会在内存的缓冲区中等待.
* 适用场景: 用于报告严重的, 需要立即被看到的错误. 比如程序即将崩溃前的最后一条信息. 因为它不使用缓冲, 所以即使程序异常终止, 这条信息也有最大的可能被成功输出.
* 缺点: 因为每次输出都直接与I/O设备交互, 频繁使用时性能会略低于带缓冲的流.

示例:

```cpp
#include <iostream>
#include <stdexcept>

void process_data(int data) {
    if (data < 0) {
        // 立即输出严重错误, 程序可能无法继续
        std::cerr << "Fatal Error: Invalid data received. Value was " << data << "." << std::endl;
        // 通常后面会跟着抛出异常或终止程序
        throw std::runtime_error("Invalid data");
    }
    // ... 正常处理 ...
}
```

---

`std::clog`是有缓冲的 (buffered) 输出流.

* 核心特性: 当你把数据发送给`std::clog`时, 信息会先被存放在一个缓冲区里. 直到缓冲区满了, 或者你手动刷新它 (例如使用`std::endl`), 数据才会被一次性地写入目标设备.
* 适用场景: 用于记录一般的日志信息或非致命性的警告. 这些信息很重要, 但不需要保证在程序崩溃的瞬间还能被看到. 因为它使用了缓冲, 所以在大批量记录日志时性能更好.
* 优点: 性能比`std::cerr`好, 适合记录大量诊断信息.

示例:

```cpp
#include <iostream>

void initialize_subsystem() {
    // 记录一条诊断性的日志信息, 它不紧急
    std::clog << "Log: Initializing graphics subsystem..." << std::endl;
    // ... 执行初始化 ...
    std::clog << "Log: Graphics subsystem ready." << std::endl;
}
```

---

关键区别: stdout 与 stderr. 在大多数操作系统中, `std::cout`输出到"标准输出流 (stdout)", 而`std::cerr`和`std::clog`输出到"标准错误流 (stderr)". 这有什么用呢? 这允许你重定向 (redirect) 程序的输出. 例如, 在命令行中, 你可以:

* 将正常的输出保存到文件, 同时让错误信息仍然显示在屏幕上.
    ```sh
    ./my_program > output.txt
    ```
    (只有`std::cout`的内容会进入`output.txt`, `std::cerr`的内容会显示在终端).
* 分别处理正常输出和错误输出.
    ```sh
    ./my_program 1> output.txt 2> error.log
    ```
    (将stdout写入`output.txt`, 将stderr写入`error.log`).

---

总结对比:

| 特性 | `std::cerr` | `std::clog` | `std::cout` |
| :--- | :--- | :--- | :--- |
| 用途 | 严重的, 紧急的错误 | 普通的日志, 警告 | 常规的程序输出 |
| 缓冲 | 无缓冲 (立即输出) | 有缓冲 (延迟输出) | 有缓冲 (延迟输出) |
| 输出流 | 标准错误 (stderr) | 标准错误 (stderr) | 标准输出 (stdout) |
| 选择时机| 当程序可能崩溃, 必须立即看到信息时 | 记录大量诊断信息或非致命错误时 | 输出程序的正常结果时 |

## `std::cin`

`std::cin`是C++中用于从标准输入设备 (通常是键盘) 读取数据的核心工具. 它的名字是 "character input" 的缩写, 和`std::cout`一样, 它也定义在`<iostream>`头文件中. `std::cin`是`std::istream` (输入流基类) 的一个全局实例对象. `std::cin`通过提取运算符 (extraction operator) `>>` 来工作. 这个操作符的作用是从输入流 (键盘输入) 中"提取"数据, 并将其存入右侧的变量中. `std::cin`能够自动识别变量的类型, 并对输入的数据进行相应的转换.

基本用法:

```cpp
#include <iostream>
#include <string>

int main() {
    int age;
    std::string name;

    // 提示用户输入年龄
    std::cout << "Please enter your age: ";
    std::cin >> age; // 从键盘提取一个整数, 存入 age 变量

    // 提示用户输入名字
    std::cout << "Please enter your first name: ";
    std::cin >> name; // 从键盘提取一个单词, 存入 name 变量

    std::cout << "Hello " << name << ", you are " << age << " years old." << std::endl;

    return 0;
}
```

运行交互示例:

```
Please enter your age: 30
Please enter your first name: Alice
Hello Alice, you are 30 years old.
```

`std::cin` 的重要特性:

* 类型安全: `std::cin`会尝试将输入转换成目标变量的类型. 如果输入"hello"而程序期望一个`int`, 输入会失败, `std::cin`会进入一个错误状态.
* 链式调用: 和`std::cout`一样, 你可以链接多个提取操作来一次性读取多个值.
```cpp
int x, y;
std::cout << "Enter two numbers: ";
std::cin >> x >> y; // 读取两个由空白分隔的数字
```
* 忽略空白: 默认情况下, `>>`操作符会跳过所有的空白符 (空格, Tab, 换行符), 直到找到下一个非空白字符开始读取. 它读取到下一个空白符时便停止. 这就是为什么`std::cin >> name;`只能读取一个单词的原因.

### 读取包含空格的一整行

因为`>>`会以空格为界, 所以不能用它来读取一个完整的句子. 解决方案是使用`std::getline()`函数.

示例:

```cpp
#include <iostream>
#include <string>

int main() {
    std::string full_name;
    std::cout << "Please enter your full name: ";

    // std::ws 会吃掉 cin >> age 后留下的换行符
    // 然后 getline 读取一整行, 直到遇到下一个换行符
    std::getline(std::cin >> std::ws, full_name);

    std::cout << "Your full name is: " << full_name << std::endl;
    return 0;
}
```

### 输入了错误类型的数据

当`std::cin`读取失败时 (例如, 要求输入数字但用户输入了文字), 它会进入"fail"状态. 在这个状态下, 后续所有的`std::cin`操作都会立即失败. 你需要检测并处理这个错误.

示例: 简单的输入验证

```cpp
#include <iostream>
#include <limits>

int main() {
    int number;
    std::cout << "Enter a number: ";

    // 循环直到用户输入一个有效的数字
    while (!(std::cin >> number)) {
        std::cout << "Invalid input. Please enter a number: ";

        // 1. 清除错误状态
        std::cin.clear();

        // 2. 丢弃缓冲区中错误的输入
        std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
    }

    std::cout << "You entered: " << number << std::endl;
    return 0;
}
```

总而言之, `std::cin`是C++进行交互式命令行程序开发的基础, 理解它的工作方式以及如何处理常见的输入问题至关重要.

## `std::ofstream`

创建并写入文件的最基本方法是创建一个`ofstream`对象, 并使用我们熟悉的`<<` (插入) 运算符.

步骤:

1.  包含`<fstream>`头文件.
2.  创建一个`std::ofstream`对象, 并将文件名作为参数传递给它.
3.  使用`<<`将数据写入文件流.
4.  当`ofstream`对象离开作用域时 (例如函数结束), 文件会自动关闭.

示例:

```cpp
#include <iostream>
#include <fstream> // 必须包含

int main() {
    // 创建一个 ofstream 对象, 这会创建或覆盖 a.txt 文件
    std::ofstream my_file("a.txt");

    // 检查文件是否成功打开
    if (!my_file) {
        std::cerr << "Error: Unable to open file." << std::endl;
        return 1;
    }

    // 使用 << 运算符写入数据
    my_file << "Hello, C++ File I/O." << std::endl;
    my_file << "This is line 2." << std::endl;
    my_file << "The number is " << 123 << "." << std::endl;

    // my_file 在 main 函数结束时自动关闭
    std::cout << "Successfully wrote to a.txt" << std::endl;
    return 0;
}
```

其他文件处理函数: 除了`<<`, `ofstream`还提供了更底层的写入函数.

* `put(char c)`: 写入单个字符.

    ```cpp
    my_file.put('A');
    ```

* `write(const char* s, streamsize count)`: 写入一块原始字符数据 (字节块).

    ```cpp
    const char data[] = "BinaryData";
    my_file.write(data, sizeof(data) - 1); // 写入10个字节
    ```

默认情况下, 写入操作是顺序的. 但你可以移动文件中的写入指针来实现随机位置的写入.

* `seekp(position)`: Seek Put. 移动写入指针到指定位置.
* `tellp()`: Tell Put. 获取当前写入指针的位置.

示例: 覆盖文件中的部分内容.

```cpp
#include <fstream>

int main() {
    std::fstream file("test.txt"); // 使用 fstream 以便读写
    file << "Hello World"; // 初始内容

    // "World" 开始于位置 6
    file.seekp(6); // 移动写入指针到第6个字节 (从0开始)
    file << "There"; // 覆盖 "World"

    // 文件内容现在是 "Hello There"
    file.close();
    return 0;
}
```

如果你不想覆盖文件的现有内容, 而是想在文件末尾添加新内容, 你需要在打开文件时指定追加模式 (`std::ios::app`).

* `app` 代表 append (追加).

示例:

```cpp
#include <fstream>

int main() {
    // 使用追加模式打开文件
    std::ofstream log_file("app.log", std::ios::app);

    log_file << "New log entry." << std::endl;
    // 这行文字会被添加到 app.log 的末尾

    return 0;
}
```

## `std::ifstream`

C++通过`<fstream>`头文件提供了强大的文件I/O功能. `std::ifstream` (Input File Stream) 是专门用于从文件读取数据的类. 它让我们能像读取`std::cin`一样方便地读取文件. 最常见的文件读取任务是逐行读取整个文本文件. 这通常通过一个`while`循环和`std::getline`函数来完成.

步骤:

1.  包含`<fstream>`和`<string>`头文件.
2.  创建一个`std::ifstream`对象, 并将要读取的文件名作为参数.
3.  必须检查文件是否成功打开.
4.  使用`while (std::getline(file_stream, line_buffer))`循环读取每一行.
5.  当`ifstream`对象离开作用域时, 文件会自动关闭.

示例:

```cpp
#include <iostream>
#include <fstream> // 必须包含
#include <string>  // 使用 std::string

int main() {
    // 1. 创建 ifstream 对象并尝试打开文件
    std::ifstream input_file("data.txt");

    // 2. 检查文件是否成功打开
    if (!input_file) {
        std::cerr << "Error: Unable to open file data.txt" << std::endl;
        return 1;
    }

    std::string line;
    std::cout << "File content:" << std::endl;
    // 3. 循环逐行读取
    while (std::getline(input_file, line)) {
        std::cout << line << std::endl;
    }

    // 4. 文件在 input_file 销毁时自动关闭
    return 0;
}
```

当文件中的数据有固定格式时, 你可以使用提取运算符`>>`来直接将数据读入变量. `>>`操作符会自动处理空白符 (空格, 换行等) 并进行类型转换.

示例: 假设文件`coords.txt`内容如下:

```
x: 10.5
y: 20.2
z: 30.8
```

我们可以这样读取:

```cpp
#include <iostream>
#include <fstream>
#include <string>

int main() {
    std::ifstream file("coords.txt");
    if (!file) {
        std::cerr << "Error opening file." << std::endl;
        return 1;
    }

    std::string label;
    double x, y, z;

    // 读取 x, >> 会跳过 ':', 然后读取数字
    file >> label >> x;
    // 读取 y
    file >> label >> y;
    // 读取 z
    file >> label >> z;

    std::cout << "Read coordinates: " << std::endl;
    std::cout << "x = " << x << std::endl;
    std::cout << "y = " << y << std::endl;
    std::cout << "z = " << z << std::endl;

    return 0;
}
```

你不需要总是从头到尾读取文件. 可以直接跳转到文件的特定位置开始读取.

* `seekg(position)`: Seek Get. 移动读取指针到指定位置.
* `read(char* buffer, streamsize count)`: 从当前位置读取`count`个原始字节到`buffer`中.

示例: 从文件特定位置读取几个字符.

```cpp
#include <iostream>
#include <fstream>
#include <string>

int main() {
    // 假设文件 "message.txt" 内容为 "Hello Secret World"
    std::ifstream file("message.txt");
    if (!file) {
        std::cerr << "Error opening file." << std::endl;
        return 1;
    }

    // "Secret" 这个词从第6个字节开始 (从0计数)
    file.seekg(6);

    // 准备一个缓冲区来存放读取的字符
    char buffer[7]; // 6个字符 + 1个用于空终止符 '\0'

    // 从当前位置 (6) 读取6个字节
    file.read(buffer, 6);
    buffer[6] = '\0'; // 手动添加字符串结束符

    std::cout << "The secret word is: " << buffer << std::endl;
    // 输出: The secret word is: Secret

    return 0;
}
```

## 二进制文件读写

### 二进制文件 vs. 文本文件

理解两者的区别至关重要:

  * 文本文件 (Text File):

      * 内容: 人类可读的字符.
      * 存储方式: 数字`123`被存储为三个字符: `'1'`, `'2'`, `'3'`. 每个字符占用一个字节 (在ASCII/UTF-8中).
      * 优点: 便于人类阅读和编辑.
      * 缺点: 对于非文本数据, 存储效率低, 文件体积较大.

  * 二进制文件 (Binary File):

      * 内容: 数据的原始内存字节表示, 人类通常无法直接阅读.
      * 存储方式: 数字`123`作为一个4字节的`int`类型, 被直接写入文件, 保存的是它的二进制形式 (例如`0x0000007B`).
      * 优点: 文件体积小, 读写速度快, 能精确保存复杂的数据结构.
      * 缺点: 不便于人类直接查看.

### 写入二进制文件

写入二进制文件需要以二进制模式打开文件, 并使用`write()`函数.

步骤:

1.  创建一个`std::ofstream`对象, 并在模式中加入`std::ios::binary`.
2.  使用`write()`函数写入数据.
3.  `write()`函数需要一个`const char*`类型的指针. 你需要使用`reinterpret_cast`将你的数据地址转换为字节指针.

示例:

```cpp
#include <iostream>
#include <fstream>

struct Record {
    int id;
    double value;
    char name[10];
};

int main() {
    // 1. 以二进制模式打开文件
    std::ofstream bin_file("data.bin", std::ios::binary);
    if (!bin_file) { return 1; }

    Record rec = {101, 3.14, "Test"};

    // 2. 使用 write() 和 reinterpret_cast 写入数据
    //    参数1: 数据的内存地址, 转为字节指针
    //    参数2: 要写入的字节数
    bin_file.write(reinterpret_cast<const char*>(&rec), sizeof(Record));

    bin_file.close();
    std::cout << "Successfully wrote a Record to data.bin" << std::endl;
    return 0;
}
```

### 读取二进制文件

读取二进制文件与写入过程相对应, 使用`read()`函数.

步骤:

1.  创建一个`std::ifstream`对象, 并以`std::ios::binary`模式打开文件.
2.  创建一个用于接收数据的同类型变量.
3.  使用`read()`函数将文件中的字节读入该变量的内存地址.

示例:

```cpp
#include <iostream>
#include <fstream>

// 使用与写入时相同的结构体
struct Record {
    int id;
    double value;
    char name[10];
};

int main() {
    // 1. 以二进制模式打开文件
    std::ifstream bin_file("data.bin", std::ios::binary);
    if (!bin_file) { return 1; }

    Record rec; // 准备一个空对象来接收数据

    // 2. 使用 read() 和 reinterpret_cast 读取数据
    bin_file.read(reinterpret_cast<char*>(&rec), sizeof(Record));

    bin_file.close();

    // 验证读取的数据
    std::cout << "Read from data.bin:" << std::endl;
    std::cout << "ID: " << rec.id << std::endl;
    std::cout << "Value: " << rec.value << std::endl;
    std::cout << "Name: " << rec.name << std::endl;

    return 0;
}
```

### 先关闭再读取

在同一个程序中, 如果你向一个文件写入数据后, 想要立刻读取它, 必须先关闭文件输出流. 关闭操作会确保所有在内存缓冲区的数据都被完整地写入到磁盘文件中.

```cpp
// 错误示范 ❌
std::ofstream out("file.bin", std::ios::binary);
out.write(...);
// 此处没有 out.close()
std::ifstream in("file.bin", std::ios::binary); // 可能会读到不完整或旧的数据

// 正确示范 ✅
std::ofstream out("file.bin", std::ios::binary);
out.write(...);
out.close(); // 确保写入完成
std::ifstream in("file.bin", std::ios::binary); // 现在可以安全读取
```

## 序列化/反序列化

* 序列化 (Serialization): 将内存中的对象 (如一个`struct`) 转换为一个字节序列 (byte stream) 的过程, 以便可以将其写入文件或通过网络发送.
* 反序列化 (Deserialization): 序列化的逆过程, 即从字节序列中读取数据, 并重新在内存中构建出原始对象.

### 定义示例结构体

我们将使用一个简单的`GameObject`结构体作为示例. 注意: C++编译器可能会为了内存对齐 (memory alignment) 在结构体成员之间或末尾添加填充字节 (padding bytes). 在序列化时, `sizeof()`会自动包含这些填充字节, 确保我们读写的是完整的内存布局.

```cpp
#include <iostream>

struct GameObject {
    int fieldOne;
    short fieldTwo;
    bool active;
    // 编译器可能会在这里添加一个填充字节以确保对齐
};
```

### (可选)重载流输出运算符

为了方便调试和在控制台打印结构体内容, 我们可以为其重载`operator<<`. 这与二进制序列化无关, 但非常实用.

```cpp
// 重载 <<, 使 cout << a; 成为可能
std::ostream& operator<<(std::ostream& stream, const GameObject& obj) {
    stream << "GameObject:" << std::endl;
    stream << "  fieldOne: " << obj.fieldOne << std::endl;
    stream << "  fieldTwo: " << obj.fieldTwo << std::endl;
    stream << "  active: " << (obj.active ? "true" : "false") << std::endl;
    return stream;
}
```

### 序列化(写入文件)

序列化函数的目标是接收一个`GameObject`对象, 并将其内存中的内容作为原始字节写入到一个输出流 (`std::ostream`) 中.

步骤:

1.  定义一个`serialize`函数, 接收`GameObject`的引用和`std::ostream`的引用.
2.  使用流的`write()`方法.
3.  使用`reinterpret_cast`将`GameObject`对象的地址 (`&obj`) 转换为`const char*`, 这是`write()`方法要求的字节指针类型.
4.  写入的字节数由`sizeof(GameObject)`确定.

示例:

```cpp
#include <fstream>

void serialize(const GameObject& obj, std::ostream& stream) {
    stream.write(reinterpret_cast<const char*>(&obj), sizeof(GameObject));
}

// 如何使用:
// std::ofstream file("gameobject.bin", std::ios::binary);
// GameObject player = {100, 50, true};
// serialize(player, file);
```

### 反序列化(读取文件)

反序列化函数的目标是从输入流 (`std::istream`) 中读取足够多的字节, 并用这些字节来填充一个新的`GameObject`对象的内存.

步骤:

1.  定义一个`deserialize`函数, 接收`std::istream`的引用.
2.  创建一个`GameObject`对象用于存放结果.
3.  使用流的`read()`方法.
4.  使用`reinterpret_cast`将结果对象的地址 (`&result`) 转换为`char*`.
5.  读取的字节数同样由`sizeof(GameObject)`确定.
6.  返回创建的对象.

示例:

```cpp
#include <fstream>

GameObject deserialize(std::istream& stream) {
    GameObject result;
    stream.read(reinterpret_cast<char*>(&result), sizeof(GameObject));
    return result;
}

// 如何使用:
// std::ifstream file("gameobject.bin", std::ios::binary);
// GameObject loaded_player = deserialize(file);
// std::cout << loaded_player; // 使用重载的 << 打印
```

## `std::sstream`

`<sstream>`是C++标准库中的一个非常有用的头文件. 它提供了一种将字符串当作流 (stream) 来处理的能力. 简单来说, 它让你可以在内存中对一个`std::string`对象进行格式化的输入和输出, 就像你使用`std::cin`和`std::cout`来处理键盘和屏幕一样. 你可以把字符串流想象成一个在内存中的 "虚拟文件". 你可以向它 "打印" (写入) 数据, 也可以从它那里 "扫描" (读取) 数据. 所有的操作都发生在内存里, 速度非常快, 不涉及任何磁盘I/O.

`<sstream>`提供了三个主要的类, 它们是`fstream`家族在内存中的对应版本:

1.  `std::stringstream`:

      * 功能: 功能最全, 既可以读, 也可以写.
      * 继承自: `std::iostream`.
      * 用途: 最常用的字符串流, 适用于需要先构建字符串然后再解析它的复杂场景.

2.  `std::ostringstream`:

      * 功能: Output String Stream. 只用于输出 (写).
      * 继承自: `std::ostream`.
      * 用途: 当你只需要将各种类型的数据格式化拼接到一个字符串中时, 这是最高效的选择.

3.  `std::istringstream`:

      * 功能: Input String Stream. 只用于输入 (读).
      * 继承自: `std::istream`.
      * 用途: 当你需要从一个已有的字符串中按特定格式解析出数据时 (比如按空格分割), 这是最高效的选择.

应用场景:

1. 类型转换 (Type Conversion)

    这是`stringstream`最经典的应用之一: 在各种类型和`std::string`之间进行转换.

    示例: 数字转字符串

    ```cpp
    #include <iostream>
    #include <sstream>
    #include <string>

    int main() {
        std::ostringstream oss;
        int year = 2025;
        double version = 2.0;

        // 像 cout 一样将数据写入流
        oss << "Version: " << version << ", Year: " << year;

        // 使用 .str() 方法获取流中的完整字符串
        std::string result = oss.str();

        std::cout << result << std::endl; // 输出: Version: 2.0, Year: 2025
        return 0;
    }
    ```

    示例: 字符串转数字

    ```cpp
    #include <iostream>
    #include <sstream>
    #include <string>

    int main() {
        std::string data = "123 45.6";
        std::istringstream iss(data); // 用字符串初始化输入流

        int my_int;
        double my_double;

        // 像 cin 一样从流中读取数据
        iss >> my_int >> my_double;

        std::cout << "Read int: " << my_int << std::endl;
        std::cout << "Read double: " << my_double << std::endl;
        return 0;
    }
    ```

2. 解析复杂字符串 (String Parsing)

    当你想按特定分隔符 (默认为空格) 分割字符串时, `istringstream`非常方便.

    示例: 按空格分割句子

    ```cpp
    #include <iostream>
    #include <sstream>
    #include <string>

    int main() {
        std::string sentence = "this is a sample sentence";
        std::istringstream iss(sentence);
        std::string word;

        std::cout << "Words:" << std::endl;
        // >> 操作符会自动按空格分割
        while (iss >> word) {
            std::cout << word << std::endl;
        }
        return 0;
    }
    ```

3. 内存中的格式化 (In-Memory Formatting)

    在你需要构建一个复杂的字符串 (比如一条SQL查询语句或一个JSON对象), 但又不希望每次都进行昂贵的字符串拼接操作时, `ostringstream`是绝佳的选择. 它一次性在缓冲区中完成所有格式化, 最后再生成一个完整的字符串, 效率很高.
