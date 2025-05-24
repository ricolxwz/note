---
title: 函数
icon: material/function-variant
---

## 作用域

可以使用花括号来定义域.

## 循环

循环的语法是和C那里一样的.

```cpp
#include <iostream>
#include <array>

int main() {;
    int arr[] = {1, 3, 5};
    for(int i = 0; i < 3; i++) {
        std::cout << arr[i] << std::endl;
    }
    std::array<int, 3> arr2 = {1, 3, 5};
    for (int i = 0; i < arr2.size(); i++) {
        std::cout << arr2[i] << std::endl;
    }
    // 基于range的for循环, 有点像python中的for ... in ...循环
    for (auto element : arr2) {
        std::cout << element << std::endl;
    }
    // while循环
    while(true) { // 手动创建一个死循环
        std::cout << "Hello, World!" << std::endl;
    }
    // do while循环
    do {
        std::cout << "Hello, World!" << std::endl;
    } while (true);
    return 0;
}
```

!!! tip "`auto`"

    `auto`是C++11引入的一个关键字, 用于自动推导变量的类型. 在上面的例子中, `element`的类型会被自动推导为`int`, 这使得代码更加简洁和易读. 在使用`auto`时, 需要注意变量的类型会在编译时确定.

!!! tip "`auto&`"

    上述代码中的`auto`可以写为`auto&`, 这样可以避免拷贝, 直接引用原来的对象. 如果在循环体中修改了`element`, 那么原来的对象也会被修改. 但是如果使用`auto`, 那么`element`是一个拷贝, 修改它不会影响原来的对象.

## 函数

需要注意的是, C++的函数不能定义在其他函数的内部. 主要有这几个考虑点, 我认为其中比较重要的是代码的组织和可读性, 函数本身是一个清晰, 独立的逻辑单元. 当然, 还有其他的一些原因, 比如说闭包, 链接的原因. 还有一点是, 函数必须在使用之前定义. 还有一点是, C++的函数支持重载, 这个在C, Python里面是不行的.

## 地址运算符

`&`可以用来获取变量的地址, 也可以用来获取函数的地址. 这在C++中是很常见的, 特别是在使用指针和引用的时候.

```cpp
#include <iostream>

int main() {
    int x = 42;
    float y = 72;
    char a = 'a';
    signed char b = -1;
    unsigned char c = 255;
    std::cout << &x << std::endl;
    std::cout << &y << std::endl;
    std::cout << (void*)&a << std::endl;
    std::cout << (void*)&b << std::endl;
    std::cout << (void*)&c << std::endl;
    std::cout << (void*)&foo << std::endl;
    return 0;
}
```

!!! tip "为啥要使用`void*`"

    这是因为, 在C++中, 当`a`是一个`char`类型的值的时候, `&a`是一个`char*`类型的值, 但是`std::cout`会对`char*`类型做一个特殊的处理, 当你直接将一个`char*`传递给`std::cout`的时候, 它会认为这个指针指向的是一个以`\0`结尾的C风格字符串, 并尝试从该地址打印字符, 直到为到空字符为止. 所以可能会看到一些不是地址的乱码. 为了打印`a`的地址, 需要将`&a`转化为`void*`类型.

    要注意的是, 函数也使用了`void*`, 如果没有`void*`, 那么函数的地址会返回是`1`, 这是因为`std::ostream`并没有接受函数指针的重载, 但是它有一个接受`bool`的重载, 而在C++里面, 任何指针类型(包括函数指针)都可以隐式转换为`bool`, 所以写`std::cout << &foo;`的时候, 编译器找不到能直接打印函数指针的重载, 只能把`&foo`转为`bool`, 所以打印的是`1`.
