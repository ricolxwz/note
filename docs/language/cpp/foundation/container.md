---
title: 容器
icon: material/inbox-outline
---

## 数组

创建数组很简单:

```cpp
#include <iostream>
#include <numeric>
#include <iterator>

int main() {
    int ids[100];
    ids[0] = 100;
    std::cout << ids[12] << std::endl; // 有可能是一个很奇怪的数字, 因为数组没有初始化
    std::iota(std::begin(ids), std::end(ids), 10);
    std::cout << ids[12] << std::endl; // 12
    return 0;
}

```

上面, 我们用的是内置数组类型, 还可以使用`std::array`, 这是标准库提供的一个模板类, 模板类和Java中的泛型很像, 但是C++的模板类在编译期间, 会生成一个实体的类. Java中的泛型是通过类型擦除实现的, 在编译完成之后生成字节码的阶段, 泛型信息大部分会被擦除掉, 编译器只会在需要的地方自动插入类型转换.

!!! tip "这种模板类的实现放在哪里"

    对于C++模板类来说, 将其实现放在头文件中是标准且常见的做法. 很多现代C++库, 特别是那些大量使用模板的库, 都是以头文件库(Header-only library)的形式发布的. 这意味着你使用这些库的时候, 只需要包含头文件, 而不需要链接任何静态库或者动态库. 这是因为静态库/动态库包含的是已经编译好的, 具体的代码, 很难处理模板这更需要在编译时根据用户需求生成新代码的情况. 实际上, 这些模板库全都是只需要包含头文件就可以用的, 无需额外链接.

```cpp
#include <iostream>
#include <numeric>
#include <iterator>
#include <array>

int main() {
    std::array <int, 100> ids;
    std::iota(std::begin(ids), std::end(ids), 10);
    ids.at(100000) = 9;  // 抛出异常
    return 0;
}
```

!!! tip "`std::begin(ids)`是啥"

    `std::begin`和`std::end`是C++标准库中的函数模板, 用于获取容器的开始和结束迭代器. 迭代器是C++ STL中用于遍历容器的对象, 类似于Python中的迭代器. `std::begin`返回一个指向容器第一个元素的迭代器, 而`std::end`返回一个指向容器最后一个元素之后的位置的迭代器. 这两个函数可以用于任何支持范围的容器, 包括数组, `std::vector`, `std::list`等.

    !!! tip "函数模板"

        函数模板是C++中的一种强大特性, 允许你编写一个函数, 该函数可以接受不同类型的参数. 当你调用这个函数时, 编译器会根据传入的参数类型自动生成相应的函数实例. 这使得代码更加灵活和可重用. 在上面的例子中, `std::begin`和`std::end`都是函数模板, 它们可以接受任何类型的容器作为参数.

    !!! tip "迭代器"

        迭代器是C++ STL中用于遍历容器的对象, 类似于Python中的迭代器. 迭代器提供了一种统一的方式来访问容器中的元素, 无论容器的具体类型是什么. 迭代器可以被视为指向容器元素的指针, 你可以使用它们来读取和修改容器中的元素. 迭代器通常支持递增操作(例如`++it`)和解引用操作(例如`*it`)来访问当前元素.

## 数组offset

我们来讨论一下原生的数组.

```cpp
#include <iostream>

int main() {
    int array[] = {1, 3};
    int* px = array;
    std::cout << array[0] << std::endl;
    std::cout << px << std::endl; // 0x7fffffffdbe0
    std::cout << *px << std::endl; // 1
    px++;
    std::cout << px << std::endl; // 0x7fffffffdbe4
    std::cout << *px << std::endl; // 3
    return 0;
}
```

你会发现, `px`移动了4个字节. 其实也可以通过`*(px+1)`来访问`*px`后的下一个元素. 然后, 如果我们使用`array`来替换`px`, `*(array+1)`, 其实是一模一样的, 所以`*(array+1)`等价于`*(px+1)`等价于`array[1]`.

## 向函数传递数组

当你向某个函数传递数组的时候, 会退化并创建一个指向数组首元素的指针的副本.

```cpp
#include <iostream>

void PrintArray(int arr[], size_t size) {
    arr[0] = 10;
}

int main() {
    int arr[] = {1, 2, 3, 4, 5};
    PrintArray(arr, 5);
    std::cout << arr[0] << std::endl; // 10
    return 0;
}
```

但是如果你传递的是一个`std::array`或者`std::vector`, 则会创建一个完整的对象副本, 这意味着你在函数内部对它的修改不会影响原来的对象.

```cpp
#include <iostream>
#include <array>

void PrintArray(std::array<int, 5> arr) {
    arr[0] = 10;
}

int main() {
    std::array<int, 5> arr = {1, 3, 5, 7, 9};
    PrintArray(arr);
    std::cout << arr[0] << std::endl; // 1
    return 0;
}
```

但是, 如果我传递的是引用, 那么:

```cpp
#include <iostream>
#include <array>

void PrintArray(std::array<int, 5>& arr) {
    arr[0] = 10;
}

int main() {
    std::array<int, 5> arr = {1, 3, 5, 7, 9};
    PrintArray(arr);
    std::cout << arr[0] << std::endl; // 10
    return 0;
}
```

对于`std::vector`也是如此.
