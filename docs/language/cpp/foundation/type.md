---
title: 类型
icon: material/format-list-bulleted-type
---

## 数据类型

下面是一张表, 列出了 C++ 中的基本数据类型及其在不同平台上的大小. 请注意, C++ 标准并没有规定这些类型的确切大小, 但它们通常遵循以下规则:

| 类型说明符 | 等效类型 | C++ 标准 (位) | LP32 | ILP32 | LLP64 | LP64 |
|------|---|---|---|---|---|---|
| `signed char` | `signed char` | 至少 8 | 8 | 8 | 8 | 8 |
| `unsigned char` | `unsigned char` | 至少 8 | 8 | 8 | 8 | 8 |
| `short`, `short int`, `signed short`, `signed short int` | `short int` | 至少 16 | 16 | 16 | 16 | 16 |
| `unsigned short`, `unsigned short int` | `unsigned short int` | 至少 16 | 16 | 16 | 16 | 16 |
| `int`, `signed`, `signed int` | `int` | 至少 16 | 16 | 32 | 32 | 32 |
| `unsigned`, `unsigned int` | `unsigned int` | 至少 16 | 16 | 32 | 32 | 32 |
| `long`, `long int`, `signed long`, `signed long int` | `long int` | 至少 32 | 32 | 32 | 32 | 64 |
| `unsigned long`, `unsigned long int` | `unsigned long int` | 至少 32 | 32 | 32 | 32 | 64 |
| `long long`, `long long int`, `signed long long`, `signed long long int` | `long long int` (C++11) | 至少 64 | 64 | 64 | 64 | 64 |
| `unsigned long long`, `unsigned long long int` | `unsigned long long int` (C++11) | 至少 64 | 64 | 64 | 64 | 64 |

!!! example "示例"

    ```cpp
    #include <iostream>
    #include <string>

    int main() {
        int x = 42;
        std::cout << x << std::endl; // 42
        std::cout << sizeof(x) << std::endl; // 4
        long long y = 543254325432;
        std::cout << y << std::endl; // 543254325432
        std::cout << sizeof(y) << std::endl; // 8
        int64_t z = 889789790;
        std::cout << z << std::endl; // 889789790
        std::cout << sizeof(z) << std::endl; // 8
        bool e = true;
        std::cout << e << std::endl; // 1
        std::cout << sizeof(e) << std::endl; // 1
        float f = 3.14f;
        std::cout << f << std::endl; // 3.14
        std::cout << sizeof(f) << std::endl; // 4
        double d = 3.141592653589793f;
        std::cout << d << std::endl; // 3.14159
        std::cout << sizeof(d) << std::endl; // 8
        char c = 'A';
        std::cout << c << std::endl; // A
        std::cout << sizeof(c) << std::endl; // 1
        std::string str = "Hello, World!"; // string不是一种fundamental type
        std::cout << str << std::endl; // Hello, World!
        std::cout << sizeof(str) << std::endl; // 32
        return 0;
    }
    ```

## `const`类型

最简单的用法是将 `const` 关键字放在变量声明的前面, 这会使变量成为只读的.

!!! example "示例"

    ```cpp
    #include <iostream>

    int main() {

        int x = 7;
        std::cout << x << std::endl;
        x = 3;
        std::cout << x << std::endl;

        const float PI = 3.14f;
        std::cout << PI << std::endl;
        // PI = -42; // 不能改变PI
        std::cout << PI << std::endl;

        return 0;
    }
    ```
