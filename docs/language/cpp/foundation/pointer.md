---
title: 指针
comments: true
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

!!! note "为啥要使用`void*`"

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

!!! note "如果你不希望引用在函数内被修改"

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

## 陷阱

下面是一些常见的陷阱:

* 不要给空指针赋值, 或者说不要nullptr dereference, 这会导致程序崩溃
* 忘记释放内存, 导致内存泄露, 然后系统爆了, 可以使用`valgrind`或者`-fsanitize`来检测内存泄露
* 悬空指针, 也就是指向已经释放的内存的指针, 例如访问一个在某一个已经释放的栈帧中的局部变量
* 双重释放, 也就是重复释放同一块内存

## 函数指针

函数指针的写法有一点奇怪, 它的类型是`返回值类型(*指针名)(参数类型列表)`.

```cpp
#include <iostream>
#include <functional>

int add(int x, int y) {
    return x + y;
}

int mulnotely(int x, int y) {
    return x * y;
}

int test(int (*func)(int , int), int a, int b) {
    return func(a, b);
}

int test2(std::function<int(int, int)> func, int a, int b) {
    return func(a, b);
}

int main() {
    // 1. 第一种方式
    int (*operation)(int, int); // 这个是函数指针的写法
    operation = add;
    std::cout << "Addition: " << operation(5, 3) << std::endl; // Addition: 8
    operation = mulnotely;
    std::cout << "Mulnotelication: " << operation(5, 3) << std::endl; // Mulnotelication: 15
    std::cout << "Test Addition: " << test(add, 5, 3) << std::endl; // Test Addition: 8
    // 2. 第二种方式
    std::function<int(int, int)> funcptr;
    funcptr = add;
    std::cout << "Test2 Addition: " << test2(funcptr, 5, 3) << std::endl; // Test2 Addition: 8
    return 0;
}
```

## 智能指针

### `std::uniqe_ptr`

`std::unique_ptr`是一个独占所有权的智能指针, 它确保同一时间只有一个指针可以拥有某个对象的所有权. 当`std::unique_ptr`被销毁时, 它会自动释放所管理的内存. 这可以避免内存泄露和悬空指针的问题. 但是需要注意的是, `std::unique_ptr`不能被复制, 只能被移动, 这意味着你不能有两个`std::unique_ptr`指向同一块内存.

```cpp
#include <iostream>
#include <memory>

class UDT {
    public:
        UDT() {
            std::cout << "UDT constructor called" << std::endl;
        }
        ~UDT() {
            std::cout << "UDT destructor called" << std::endl;
        }
};

int main() {
    // std::unique_ptr<UDT> mike = std::unique_ptr<UDT>(new UDT);
    // std::unique_ptr<UDT[]> mike_array = std::unique_ptr<UDT[]>(new UDT[10]);
    std::unique_ptr<UDT> mike = std::make_unique<UDT>();
    std::unique_ptr<UDT[]> mike_array = std::make_unique<UDT[]>(10);
    // std::unique_ptr<UDT> joe = mike; // 直接报错
    std::unique_ptr<UDT> joe = std::move(mike); // 可以使用std::move转移所有权
    return 0;
}
```

#### 自定义`Deleter`

在模板那节中, 我们讲到过`std::unique_ptr`是一个模板类, 其模板包含两个参数: `class T, class Deleter = std::default_delete<T>`, 所以, 我们是可以自定义`Deleter`的. 

```cpp
#include <iostream>
#include <memory>

struct IntDeleter {
    void operator()(int* int_ptr) {
        std::cout << "Deleting int: " << *int_ptr << std::endl;
        delete int_ptr;
    }
};

int main() {
    std::unique_ptr<int, IntDeleter> my_ptr(new int);
    return 0;
}
```

### `std::shared_ptr`

`std::shared_ptr`是一个引用计数的智能指针, 它允许多个指针共享同一块内存, 当最后一个指向该内存的指针被销毁时, 内存才会被释放. 这可以避免内存泄露和悬空指针的问题. 但是需要注意的是, `std::shared_ptr`会增加一些性能开销, 因为它需要维护一个引用计数.

```cpp
#include <iostream>
#include <memory>

class UDT {
    public:
        UDT() {
            std::cout << "UDT constructor called" << std::endl;
        }
        ~UDT() {
            std::cout << "UDT destructor called" << std::endl;
        }
};

int main() {
    std::shared_ptr<UDT> ptr1 = std::make_shared<UDT>();
    {
        std::shared_ptr<UDT> ptr2 = ptr1;
        std::cout << "use count = " << ptr2.use_count() << std::endl; // use count = 2
        // 离开作用域, ptr2被销毁, 但是ptr1仍然存在, 那块内存没有被释放
    }
    std::cout << "use count = " << ptr1.use_count() << std::endl; // use count = 1
    return 0;
}
```

### `std::weak_ptr`

`std:weak_ptr`主要用于解决共享指针带来的循环引用问题. 当两个或多个对象通过`shared_ptr`相互引用的时候, 它们的引用计数永远不会降为0(即使离开scope, 即使它们已经无法从程序其他地方访问), 从而导致内存泄露. 在循环引用的场景中, 将其中的一个`shared_ptr`替换为`weak_ptr`可以打破循环引用, 使得内存可以被正确释放. `weak_ptr`不会增加引用计数, 它只是一个观察者, 可以安全地检查所指向的对象是否仍然存在.

例如, 现在有一个循环引用的例子.

```cpp
#include <iostream>
#include <memory>
#include <string>

struct Person;
struct Apartment;

struct Person {
    std::string name;
    std::shared_ptr<Apartment> apartment;  // 使用 shared_ptr

    Person(std::string n) : name(n) {
        std::cout << name << " created.\n";
    }
    ~Person() {
        std::cout << name << " destroyed.\n";
    }
};

struct Apartment {
    std::string unit;
    std::shared_ptr<Person> owner; // 使用 shared_ptr

    Apartment(std::string u) : unit(u) {
        std::cout << "Apartment " << unit << " created.\n";
    }
    ~Apartment() {
        std::cout << "Apartment " << unit << " destroyed.\n";
    }
};

int main() {
    std::shared_ptr<Person> john = std::make_shared<Person>("John");
    std::shared_ptr<Apartment> apt101 = std::make_shared<Apartment>("101");

    // 相互引用
    john->apartment = apt101;
    apt101->owner = john;

    std::cout << "Exiting main...\n";
    return 0;
}
```

你会发现, 当离开`main`函数的时候, shared_ptr `apa101`被销毁, shared_ptr `john`也被销毁, 但是你会发现对象内部是相互引用的, 所以这两个对象的引用计数器都是从2变成了1. 不会变成0(`John`对象内部的apartment指向`apt101`, `apt101`对象内部的owner指向`john`), 所以这两个对象都不会被销毁, 导致内存泄露. 下面是一个修正的例子, 使用`weak_ptr`来解决这个问题.

```cpp
#include <iostream>
#include <memory>
#include <string>

struct Person;
struct Apartment;

struct Person {
    std::string name;
    std::shared_ptr<Apartment> apartment;

    Person(std::string n) : name(n) {
        std::cout << name << " created.\n";
    }
    ~Person() {
        std::cout << name << " destroyed.\n";
    }
};

struct Apartment {
    std::string unit;
    std::weak_ptr<Person> owner; // 使用 weak_ptr

    Apartment(std::string u) : unit(u) {
        std::cout << "Apartment " << unit << " created.\n";
    }
    ~Apartment() {
        std::cout << "Apartment " << unit << " destroyed.\n";
    }
};

int main() {
    std::shared_ptr<Person> john = std::make_shared<Person>("John");
    std::shared_ptr<Apartment> apt101 = std::make_shared<Apartment>("101");

    // 相互引用
    john->apartment = apt101;
    apt101->owner = john; // 从 shared_ptr 赋值给 weak_ptr (不增加引用计数)

    std::cout << "Exiting main...\n";
    return 0;
}
```

当离开`main`的时候, `101`对象的引用计数仍然是1. `John`对象的引用计数是0, 因为`apa101->owner`是一个weak_ptr, 析构函数被调用, 显示John被销毁. 当John销毁的时候, 它的成员`apartment`也会被销毁, 因为它是一个shared_ptr, 所以`apt101`的引用计数也会变成0, 最终导致`apt101`也被销毁. 这样就避免了循环引用的问题.

那为什么不直接使用一个普通的指针呢? 因为普通的指针可能会有悬空指针的风险. 在上的这个例子中, 如果我们使用普通指针替代weak_ptr, 那么当`john`被销毁之后, `apt101->owner`就会指向一个已经被销毁的对象, 这会导致悬空指针的问题. 而使用`weak_ptr`可以安全地检查所指向的对象是否仍然存在, 避免了这个问题. 怎么安全的检查呢? 可以调用`lock()`方法, 它会返回一个`shared_ptr`, 如果原来的对象已经被销毁, 那么返回的`shared_ptr`会是空的(nullptr), 或者使用`expired()`方法来检查`weak_ptr`是否指向一个有效的对象, 返回`true`表示指向的对象已经被销毁, 返回`false`表示指向的对象仍然存在.