---
title: 指针
icon: material/laser-pointer
---

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

## 使用引用传参

这是C++和C一个重要区别.

```cpp
#include <iostream>

void PassByValue(int arg) {
    arg = 9999;
}

void PassByReference(int& arg) {
    arg = 9999;
}

int main() {
    int x = 10;
    PassByValue(x);
    std::cout << x << std::endl;
    PassByReference(x);
    std::cout << x << std::endl;
    return 0;
}
```

注意, 原生数组传递进函数的时候传递的是首元素的指针(或者说退化为首元素的指针了), 但是如果你用的是`std::array`或者`std::vector`, 你传递的是一个对象. 所以说, 一个复制指针, 一个复制对象. 复制指针说明可以在函数内部修改原来的数组, 但是复制对象说明函数内部修改的只是一个拷贝, 不会影响原来的对象.

!!! tip "如果你不希望引用在函数内被修改"

    可以使用`const`修饰符来声明一个常量引用, 这样就可以在函数内部读取引用的值, 但是不能修改它.

    ```cpp
    #include <iostream>
    void PrintValue(const int& arg) {
        std::cout << arg << std::endl;
    }
    int main() {
        int x = 10;
        PrintValue(x); // 输出10
        // x = 20; // 如果你想修改x, 需要在函数外部修改
        return 0;
    }
    ```

## 指针

和C里面差不多.

```cpp
#include <iostream>

void foo() {}

int main() {
    int x = 7;
    int* y = &x;
    void* z = (void*)&foo;
    std::cout << y << std::endl; // 0x7fffffffdbe4
    std::cout << z << std::endl; // 0x5555555551e9
    *y = 9999;
    std::cout << x << std::endl; // 9999
    return 0;
}
```

## 内存分配

### `new/delete`

可以使用`new`和`delete`来分配堆的内存, 注意不是栈, 栈的内存是由编译器自动管理的, 一般放的是局部变量, 函数参数, 返回地址, 函数调用信息等, 当一个函数调用的时候, 栈会自动分配一块存储空间, 叫做栈帧, 当函数执行完毕的时候, 这块内存空间会被自动释放. 栈的大部分内存空间是在编译的时候就基本确定的, 当编译器分析你的代码的时候, 它能够预估出每个函数调用所需要的栈空间大小. 基于这些信息, 编译器会为每个函数预留一个固定大小的栈帧. 需要注意的是, 虽然每个栈帧的大小在编译的时候基本确定, 但是栈的总大小通常是在程序启动的时候由操作系统决定的(可以通过编译选项调整), 如果程序使用的栈空间超过了这个限制, 就会发生stack overflow错误. 相对来讲, 堆的内存是在程序运行的时候根据需要进行分配的, 而不是在编译的时候预先确定的. 以将其想象为一块巨大的, 共享的内存池, 程序可以在需要的时候向这个池子申请一块特定大小的内存来存储数据, 例如对象, 数组等. 程序员需要手动显式地分配和释放, 如果忘记释放, 就导致内存泄露. 其次, 它是全局可以访问的, 它的分配速度比较慢, 可以动态调整堆的大小. 由于内存块的分配和释放是随机的, 可能会在已分配的内存块之间留下一些小的, 不连续的区域, 这就是内存碎片.

```cpp
#include <iostream>

int main() {
    int numberOFStudnets = 0;
    std::cout << "Enter the number of students: ";
    std::cin >> numberOFStudnets;
    int studentids[numberOFStudnets];
    for (int i = 0; i < numberOFStudnets; i++) {
        studentids[i] = i;
    }
    return 0;
}
```

上面的这个程序, 如果输入的学生数量很大, 如1000000, 那么栈就会溢出, 因为栈的大小是有限制的. 但是如果你使用`new`来分配内存, 就不会有这个问题.

```cpp
#include <iostream>

int main() {
    int numberOFStudnets = 0;
    std::cout << "Enter the number of students: ";
    std::cin >> numberOFStudnets;
    int* studentids = new int[numberOFStudnets];
    for (int i = 0; i < numberOFStudnets; i++) {
        studentids[i] = i;
    }
    delete[] studentids; // 因为是数组, 要用[]
    return 0;
}
```
