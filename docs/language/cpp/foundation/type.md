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

!!! tip "可以使用`<type_traits>`来判断类型是否为`const`"

    `std::is_const<T>::value`可以用来判断类型`T`是否为`const`. 例如:

    ```cpp
    #include <iostream>
    #include <type_traits>

    int main() {
        std::cout << std::boolalpha; // 后续输出的布尔值将以true/false形式显示
        std::cout << std::is_const<int>::value << std::endl; // false
        std::cout << std::is_const<const int>::value << std::endl; // true
        return 0;
    }
    ```

## `sizeof`运算符

注意, `sizeof`运算符返回的是那个类型的大小, 不是里面放的所有东西的大小.

```cpp
#include <iostream>
#include <vector>

int main() {
    int x = 7;
    int *px = &x;
    int array[] = {1, 3, 5, 7, 9};
    int* dynamicallyAllocatedArray = new int[100];
    std::vector<int> v;
    v.push_back(1);
    v.push_back(1);
    v.push_back(1);
    v.push_back(1);
    std::cout << "x                          :" << sizeof(x) << std::endl;  // 4
    std::cout << "px                         :" << sizeof(px) << std::endl; // 8
    std::cout << "array                      :" << sizeof(array) << std::endl; // 20
    std::cout << "dynamicallyAllocatedArray  :" << sizeof(dynamicallyAllocatedArray) << std::endl; // 8, 这里是8, 而不是400
    std::cout << "v                          :" << sizeof(v) << std::endl; // 24, 这里是24, 而不是16
    return 0;
}
```

## 左值右值

这一节比较重要. 左值是一个有确定内存地址的东西. 右值是一个临时的没有内存地址的东西. 例如

* `a`: 是左值
* `b`: 是左值
* `a + b`: 是右值, 因为没法获取到地址
* `array[10+a]`: 是左值
* `10 + a`: 是右值

### 左值引用

* 符号: `&`
* 作用: 这是 C++ 传统的引用, 它是已存在对象的一个别名 (alias). 你通过引用修改对象, 就像直接修改原对象一样.
* 绑定: 通常只能绑定到左值.
* 例外: `const` 左值引用 (`const T&`) 可以绑定到右值.
* 目的: 主要是为了避免拷贝 (尤其是在函数传参和返回值时) 以及允许函数修改其参数.

例子:
```cpp
int x = 10;
int& ref_l = x;

// int& ref_bad = 10; // 错误: 不能绑定到右值 10
const int& ref_const = 10; // 正确: const左值引用可以绑定到右值
```

### 右值引用

* 符号: `&&`
* 作用: 这是 C++11 引入的新特性, 专门用于绑定到右值 (临时对象).
* 绑定: 只能绑定到右值.
* 目的: 主要用于实现移动语义 (Move Semantics, 所有权转移) 和完美转发 (Perfect Forwarding). 移动语义允许我们"窃取" 临时对象的资源 (比如动态分配的内存), 避免不必要的深拷贝, 从而极大地提高性能.

例子:
```cpp
int&& ref_r = 10;
ref_r = 20;
std::cout << ref_r << std::endl; // 20

std::string s = "world";
// std::string&& ref_s = s; // 错误: 不能绑定到左值 s
std::string&& ref_s = std::move(s);  // 注意, 这种写法其实没有移动
std::cout << ref_s << std::endl; // "world"
std::cout << s << std::endl; // "world"
std::string s_move = std::move(s);  // 这种写法有移动
std::cout << s << std::endl; // ""

std::string s1 = "wenzexu";
std::string s2 = "a really long str";
std::string&& s3 = s1 + s2; // 注意, 这种写法其实没有移动
std::cout << s3 << std::endl; // "wenzexua really long str"
std::string s4 = std::move(s1);  // 这种写法有移动
std::cout << s1 << std::endl; // ""
```

!!! tip "生命周期延长"

    当你将一个右值引用绑定到一个临时对象时, 这个临时对象的生命周期会被延长到右值引用的作用域结束, `const T&`的右值引用也会延长临时对象的生命周期. 例如:

    ```cpp
    std::string&& ref = std::string("Hello");
    const std::string& ref_const = std::string("World");
    std::cout << ref << std::endl; // 输出 "Hello"
    std::cout << ref_const << std::endl; // 输出 "World"
    ```

!!! warning "`std::string s_move = std::move(s)`和`std::string&& ref_s = std::move(s)`的区别"

    `std::string s_move = std::move(s);` 是通过移动构造函数创建新对象并转移资源, 而 `std::string&& ref_s = std::move(s);` 仅创建一个绑定到原对象的右值引用, 不发生移动.

    `std::string s_move = std::move(s);`的实现: `std::move(s)`是一个强制类型转换, 实际上可以写为`(std::string&&)s`, 它将左值转换为一个右值引用. 等式左边的代码`std::string s_move`会调用构造函数, 由于等式的右边是一个右值引用, 编译器会选择调用`str::string`的移动构造函数. 移动构造函数的核心是资源窃取. 也就是说, 右值引用在这里只是作为一种类型标记, 触发C++的重载机制, 从而让编译器选择移动构造函数, 而不是拷贝构造函数. 为什么它会选择移动构造函数呢, 因为移动构造函数的函数签名里面接受的是一个右值引用, 而复制构造函数里面接受的是一个左值引用. 移动构造函数里面做了什么事情呢? 它会将`s_move`的内部指针指向`s`的资源, 然后将`s`的指针置空, 这样就完成了资源转移而不是复制.

    而`std::string&& ref_s = std::move(s);`这句代码不会执行移动, 没有触发任何构造函数. 等式右边的这个`std::move(s)`的类型是`std::string&&`, 但是鉴于它是一个表达式, 所以它是右值, 或者更加具体化的说, 它是一个xvalue, 将亡值, 仍然属于右值的范畴, 所以可以赋值给等号的左边.

#### `std::move`

实际上, 我们在写C++代码的时候, 可能会包含很多的复制, 例如:

```cpp
std::string s1 = "long string........";
std::string s2 = s1; // 触发复制构造函数
void func(std::string s3) { /* ... */ }
func(s1); // 也是复制
```

但是, 我们想要的是转交`s1`的所有权, 因为我们用不到`s1`了. 这个时候就要用到`std::move`了. `std::move`是一个函数模板, 它的作用是将一个左值转换为右值引用, 这样就可以触发移动构造函数而不是复制构造函数, 为什么呢? 因为移动构造函数的参数是右值引用, 而复制构造函数的参数是左值引用, 根据重构策略, 应该调用移动构造函数. 移动构造函数里面做了什么事情呢? 它会将`s_move`的内部指针指向`s`的资源, 然后将`s`的指针置空, 这样就完成了资源转移而不是复制.

```cpp
std::string myString = "copy construct me";
std::string newValue;
std::cout << "myString: " << myString << std::endl; // "copy construct me"
std::cout << "newValue: " << newValue << std::endl; // ""
newValue = std::move(myString); // 等价于newValue = (std::string&&)myString;
std::cout << "myString: " << myString << std::endl; // ""
std::cout << "newValue: " << newValue << std::endl; // "copy construct me"
```
