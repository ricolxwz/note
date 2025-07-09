---
title: 容器
comments: true
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

!!! note "这种模板类的实现放在哪里"

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

!!! note "`std::begin(ids)`是啥"

    `std::begin`和`std::end`是C++标准库中的函数模板, 用于获取容器的开始和结束迭代器. 迭代器是C++ `STL`中用于遍历容器的对象, 类似于Python中的迭代器. `std::begin`返回一个指向容器第一个元素的迭代器, 而`std::end`返回一个指向容器最后一个元素之后的位置的迭代器. 这两个函数可以用于任何支持范围的容器, 包括数组, `std::vector`, `std::list`等.

    !!! note "函数模板"

        函数模板是C++中的一种强大特性, 允许你编写一个函数, 该函数可以接受不同类型的参数. 当你调用这个函数时, 编译器会根据传入的参数类型自动生成相应的函数实例. 这使得代码更加灵活和可重用. 在上面的例子中, `std::begin`和`std::end`都是函数模板, 它们可以接受任何类型的容器作为参数.

    !!! note "迭代器"

        迭代器是C++ `STL`中用于遍历容器的对象, 类似于Python中的迭代器. 迭代器提供了一种统一的方式来访问容器中的元素, 无论容器的具体类型是什么. 迭代器可以被视为指向容器元素的指针, 你可以使用它们来读取和修改容器中的元素. 迭代器通常支持递增操作(例如`++it`)和解引用操作(例如`*it`)来访问当前元素.

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

## `std::string`的用法

在C语言中, 没有专门的字符串类型, 字符串是通过`char`类型的数组来表示的, 并且约定以空字符`\0`作为字符串的结束标志.

```c
char greeting[6] = {'H', 'e', 'l', 'l', 'o', '\0'}; // 明确包含空字符
char message[] = "World"; // 编译器会自动计算大小并添加 '\0'
```

但是, C语言字符串存在明显缺点:

* 手动内存管理: 程序员需要手动确保数组足够大, 以容纳所有字符和终止符. 容易发生缓冲区溢出.
* 不直观的操作: 拼接, 复制, 比较等操作需要调用特定的函数, 而不是像基本数据类型那样使用运算符.
* 安全性: 缺乏边界检查, 容易导致程序崩溃或安全漏洞.
* 长度: 需要遍历到`\0`才能确定字符串长度 (除了`strlen`函数).

C++作为一门更高级的语言, 旨在提供更安全, 更高效, 更直观的变成方式, C风格字符串的缺点促使C++设计者寻求一种更好的字符串解决方案. 为了解决C风格字符串的局限性, C++标准库引入了`std::string`类. `std::string`是一个类, 它封装了`char`数组和相关操作逻辑, 它提供了一个面向对象的接口, 来管理和操作可变长度的字符串. 它的优点包括:

* 自动内存管理: `std::string`会自动处理底层字符输出的内存分配, 扩展和释放, 你不需要担心缓冲区大小或者内存泄露.
* 面向对象的操作:
  * 直观的运算符重载: 可以使用`+`进行拼接`==`, `!=`, `<`, `>`进行比较, `=`进行赋值
  * 丰富的成员函数: 提供了`append`, `insert`, `replace`, `find`, `substr`等方法, 使得字符串操作更加直观和易用.
* 安全性: 内部实现通常会进行边界检查, 减少了变成错误和安全漏洞
* 效率优化: 现代`std::string`实现通常包括小字符串优化(Small String Optimization, SSO), 允许短字符串直接存储在对象内部, 减少了内存分配的开销.
* 与C风格字符串的兼容性: 提供`c_str()`方法, 返回一个以`\0`结尾的`const char*`指针, 方便与C风格的API交互.

### `size()`

`size()`返回字符中实际存储的字符数量, 不包括末尾的空字符`\0`. 等价于`s.length()`, 这两个函数在功能上是完全等价的, 它告诉你字符串有多少长.

```cpp
std::string s = "Hello";
s.size(); // 返回5
```

### `capacity()`

`capacity()`返回的是当前为其内部字符数据分配的内存空间总大小(以字符为单位), 这包括了实际存储的字符, 以及为了将来可能得增长而预留的空间, 通常也包括了末尾的空字符`\0`预留的空间, 返回值类型为`size_t`. `capacity()`总是大于或者等于`size()`, 当`size()`超过`capacity()`的时候, `std::string`会重新分配一块更大的内存区域来容纳新的字符, 并且通常会释放旧的内存, 这个过程称为重新分配, 重新分配是一个相对耗时的工作. `capacity()`可能会比`size()`大很多, 这是为了避免频繁的内存重新分配, 当字符串增长的时候, `std::string`通常会以指数级增长其容量以减少分配的次数. 对于短字符串, `capacity`可能返回一个固定的小值, 因为数据直接存储在`std::string`对象内部的预留缓冲区中.

```cpp
std::string s = "Hello";
std::cout << "初始 size: " << s.size() << std::endl;     // 5
std::cout << "初始 capacity: " << s.capacity() << std::endl; // 可能为 15 22 或其他更大的值 (取决于SSO和实现)

s += " World and more characters to trigger reallocate";
std::cout << "增长后 size: " << s.size() << std::endl; // 字符串变长
std::cout << "增长后 capacity: " << s.capacity() << std::endl; // 可能会显著增大
```

输出:

```bash
初始 size: 5
初始 capacity: 15
增长后 size: 53
增长后 capacity: 53
```

可以使用`shink_to_fit()`方法来将`capacity`缩减到与`size`相同的大小, 这会释放未使用的内存, 但通常不建议频繁使用, 因为这会导致性能下降.

```cpp
#include <iostream>
#include <string>

int main() {
    // 1. 初始字符串
    std::string s = "短字符串";
    std::cout << "--- 初始状态 ---" << std::endl;
    std::cout << "字符串: \"" << s << "\"" << std::endl;
    std::cout << "size(): " << s.size() << std::endl;
    std::cout << "capacity(): " << s.capacity() << std::endl; // 对于短字符串, 可能因SSO而返回固定小值

    std::cout << std::endl;

    // 2. 增长字符串, 触发重新分配
    // 注意: 这里我们故意添加足够多的字符, 确保触发一次或多次重新分配
    s += "这是一个较长的字符串, 用于测试std::string的容量增长机制.";
    std::cout << "--- 字符串增长后 ---" << std::endl;
    std::cout << "字符串: \"" << s << "\"" << std::endl;
    std::cout << "size(): " << s.size() << std::endl;
    std::cout << "capacity(): " << s.capacity() << std::endl; // capacity应该显著增大, 且 >= size()

    std::cout << std::endl;

    // 3. 减少字符串长度
    // 此时 size 减小了, 但 capacity 通常不会立即减小
    s.resize(20); // 将字符串截断为20个字符
    std::cout << "--- 字符串截断后 ---" << std::endl;
    std::cout << "字符串: \"" << s << "\"" << std::endl;
    std::cout << "size(): " << s.size() << std::endl;
    std::cout << "capacity(): " << s.capacity() << std::endl; // capacity很可能保持不变

    std::cout << std::endl;

    // 4. 使用 shrink_to_fit() 释放未使用的容量
    // 尝试将 capacity 缩减到 size 的大小
    s.shrink_to_fit();
    std::cout << "--- 调用 shrink_to_fit() 后 ---" << std::endl;
    std::cout << "字符串: \"" << s << "\"" << std::endl;
    std::cout << "size(): " << s.size() << std::endl;
    std::cout << "capacity(): " << s.capacity() << std::endl; // capacity 应该接近或等于 size() (可能加上1用于\0)

    return 0;
}
```

输出:

```bash
--- 初始状态 ---
字符串: "短字符串"
size(): 12
capacity(): 15

--- 字符串增长后 ---
字符串: "短字符串这是一个较长的字符串, 用于测试std::string的容量增长机制."
size(): 89
capacity(): 89

--- 字符串截断后 ---
字符串: "短字符串这是�"
size(): 20
capacity(): 89

--- 调用 shrink_to_fit() 后 ---
字符串: "短字符串这是�"
size(): 20
capacity(): 20
```

### `append()`

`append()`是`std::string`类的成员函数, 用于向字符串默认添加新内容. 常用的方式有:

1. 追加字符串/子串:
   ```cpp
   std::string s = "Hello";
   s.append(" World");       // 结果: "Hello World"
   s.append("abcde", 3);     // 追加前3字符: "abc" → "Helloabc"
   ```

2. 追加另一字符串的部分:
   ```cpp
   std::string t = "12345";
   s.append(t, 1, 3);       // 从t[1]开始取3字符: "234" → "Hello234"
   ```

3. 追加多个相同字符:
   ```cpp
   s.append(4, '!');        // 添加4个'!' → "Hello!!!!"
   ```

4. 等效操作:
   可直接用 `+=` 运算符:
   ```cpp
   s += " World";           // 效果等同于 append()
   ```

### `find()`

`find()`方法用于在字符串中查找子字符串或字符, 返回找到的第一个位置的索引, 如果没有找到则返回`std::string::npos`, 这是一个特殊的常量, 表示未找到, 它的值等于`size_t(-1)`, 即无符号整形的最大值, 所以在if语句里面不能直接使用`find()`的返回值进行判断, 需要使用`std::string::npos`进行比较.

```cpp
#include <iostream>
#include <string>

int main() {
    std::string s("wenzexu");
    std::cout << s.find("a") << std::endl;
    if (s.find("a") == std::string::npos) {
        std::cout << "没有找到" << std::endl;
    } else {
        std::cout << "找到了" << std::endl;
    }
    return 0;
}
```

输出:

```
18446744073709551615
没有找到
```

### `c_str()`

有时, 在我们的程序中可能包含C代码, 某些C语言的函数接受的字符串类型是`const char*`, 这是C风格的字符串, 而`std::string`是一个对象, 其内部含有一个字符串数组. 所以, 怎么才能提取内部的那个字符串数组呢? 可以使用`c_str`方法.

```cpp
#include <iostream>
#include <cstring>
#include <string>

extern "C" {
    void c_func(const char* c_str) {
        printf("c_func called with '%s'\n", c_str);
    }
}

int main() {
    std::string s("Emplary"):
    const char* p = s.c_str();
    c_func(s.c_str());
    return 0;
}
```

输出:

```bash
c_func called with 'Emplary'
```

### `data()`

`data()`返回指向字符串内部数据(C风格字符数组)的指针.

`data()` 和 `c_str()` 的主要区别在于:

1.  返回类型和空终止符保证:
    *   `c_str()` 始终保证返回一个以空字符 (`\0`) 结尾的C风格字符串 (`const char*`). 这是一个严格的C++标准规定, 因为它主要是为了与C语言API兼容.
    *   `data()` 在 C++11 和 C++14 中, 返回的指针不保证指向的字符数组是以空字符结尾的. 在这些版本中, 如果你需要空终止, 你仍然必须使用 `c_str()`.
    *   从 C++17 开始, `data()` 也保证返回一个以空字符结尾的字符串 (`const char*`). 这意味着从C++17开始, 对于只读访问, `data()` 和 `c_str()` 的行为实际上是一致的.

2.  可变性(非`const`版本):
    *   `c_str()` 只有 `const` 版本, 意味着你不能通过它返回的指针修改字符串内容.
    *   `data()` 在 C++11 引入了一个非 `const` 版本 (`char* data()`), 允许你通过返回的指针直接修改字符串的底层缓冲区. 但是, 使用这个非 `const` 版本操作时需要非常小心, 因为你可能会破坏字符串的内部状态(例如, 改变长度而不通知 `std::string` 对象).

### 遍历

我们可以使用`for`循环进行遍历:

```cpp
#include <string>
#include <iostream>

int main() {
    std::string s("wenzexu");
    for (auto element:s) {
        std::cout << element << std::endl;
    }
    return 0;
}
```

输出:

```bash
w
e
n
z
e
x
u
```

## `std::string_view`的用法

来看下面这段代码:

```cpp
#include <iostream>
#include <string>

void print_string(const std::string& param) {
    std::cout << param << std::endl;
}

int main() {
    std::string s = "this is some really long string...";
    print_string(s);
    return 0;
}
```

Ok, 我们是使用引用传递避免了`s`的拷贝. 那么如果这样呢?

```cpp
#include <iostream>
#include <string>
#include <string_view>

void print_string(const std::string& param) {
    std::cout << param << std::endl;
}

int main() {
    const char* s = "this is some really long string...";
    print_string(s);
    print_string("hello");
    return 0;
}
```

Well, 由于传递的不是`std::string`类型, 这样是会产生拷贝的. 这个时候我们就可以使用`std::string_view`来彻底避免拷贝:

```cpp
#include <iostream>
#include <string>

void print_string(std::string_view param) {
    std::cout << param << std::endl;
}

int main() {
    const char* s = "this is some really long string...";
    print_string(s);
    print_string("hello");
    return 0;
}
```

注意, 这里的拷贝是指底层字符数据的拷贝, 而不是指针和长度的拷贝, 后者的拷贝还是会发生的, 你可以将`string_view`想象为一个中介, 它其实是一个类, 成员变量为指向数组的指针和数组的长度, 并且提供了几个构造函数, 调用的时候编译器会根据实参类型选择对应构造, 如果是`const char*`或者字面量, 调用其中的一个构造; 如果是`std::string`, 则调用另一个构造, 所有的操作都是指针和长度的复制, 不进行任何字符拷贝, 因此无论是`const char*`, 字符串字面量, 还是`std::string`, 传给`string_view`都能实现零拷贝访问.

!!! warning "`std::string_view`的生命周期"

    尽管std::string_view非常高效, 但在使用时必须注意一个关键点: 生命周期. std::string_view本身不拥有它所指向的字符串数据. 它仅仅是一个 "视图". 如果原始的字符串被销毁, 那么string_view就会变成一个悬空指针 (dangling pointer), 对其进行任何访问都将导致未定义行为 (Undefined Behavior).

    ```cpp
    #include <string>
    #include <string_view>

    // 错误! 返回的string_view指向一个已经销毁的局部string对象
    std::string_view get_a_view() {
        std::string s = "this is a local string";
        return std::string_view(s);
    } // s在这里被销毁, view立即失效

    int main() {
        std::string_view sv = get_a_view();
        // 此时sv已经悬空, 下面的打印是未定义行为
        // std::cout << sv << std::endl;  // CRASH!
        return 0;
    }
    ```

## `std::array`的用法

`std::array`是C++11引入的容器, 用于封装一个固定大小的数组. 它在行为上像一个`STL`容器, 但其性能和内存布局与C风格的静态数组完全相同. 在现代C++编程中, 推荐使用`std::array`替代C风格数组, 主要原因在于`std::array`提供了更高的安全性和便利性, 同时没有性能损失.

* 类型安全和大小信息: `std::array`是一个类型, 其大小是类型信息的一部分. 这意味着`std::array`对象始终知道自己的大小. 而C风格数组在传递给函数时会退化 (decay) 为一个指针, 丢失了大小信息, 迫使程序员手动传递大小参数.
    * C风格数组:
        ```cpp
        void process_array(int arr[], size_t size); // 必须额外传递大小
        ```
    * std::array:
        ```cpp
        template<size_t N>
        void process_array(const std::array<int, N>& arr); // 大小是类型的一部分, 无需额外参数
        ```

* 更安全: `std::array`提供了成员函数`at()`, 它会进行边界检查. 如果访问越界, `at()`会抛出一个`std::out_of_range`异常. 而C风格数组的越界访问是未定义行为 (undefined behavior), 这是导致程序崩溃和安全漏洞的常见原因.

* `STL`容器接口: `std::array`提供了与其它`STL`容器 (如`std::vector`) 一致的接口, 例如:
    * `begin()`, `end()`: 用于迭代器和`range-based for loops`.
    * `size()`, `empty()`: 获取大小和判断是否为空.
    * `front()`, `back()`: 访问第一个和最后一个元素.
    这使得`std::array`可以无缝地与STL算法 (如`std::sort`, `std::for_each`) 集成.

* 支持赋值: `std::array`对象可以被直接拷贝和赋值. C风格数组不支持这些操作, 必须手动使用循环或`memcpy`进行复制.
    ```cpp
    std::array<int, 3> a1 = {1, 2, 3};
    std::array<int, 3> a2;
    a2 = a1; // ✅ 合法且直观

    int c1[] = {1, 2, 3};
    int c2[3];
    // c2 = c1; // ❌ 编译错误
    ```

`std::array`是一个零成本抽象 (zero-cost abstraction). 这意味着它的抽象层 (如成员函数) 不会带来任何运行时开销. 经过编译器优化后, 使用`std::array`的代码与使用C风格数组的代码在性能上没有区别.

!!! tip "零成本抽象"

    零成本抽象 (Zero-cost Abstraction) 是C++的一个核心设计理念. 它的意思是, 你可以使用更高层次, 更安全, 更易于理解的编程构造 (即"抽象", 例如一个类或模板函数), 而不会在最终的程序中引入任何运行时开销 (即"零成本"). 换句话说, 经过编译器优化后, 使用这些抽象所生成的机器码与你手动编写的, 更底层的等效代码在性能上完全相同, 甚至可能更优. "成本" 主要指运行时的CPU周期和内存占用.

    实现零成本的关键在于编译时 (compile-time). C++编译器通过强大的优化能力将这些高级抽象"看透"并将其消除, 而不是在运行时去处理它们. 主要依赖的技术包括:

    * 模板 (Templates): 编译器会为模板参数的每一种具体类型生成专门的代码 (这个过程叫模板实例化). 这使得代码可以被高度定制和优化.
    * 内联 (Inlining): 编译器将函数调用直接替换为函数体本身, 从而消除了函数调用的开销 (如压栈, 跳转). 对于那些小的, 用于抽象的函数 (例如`std::array::size`或`std::unique_ptr::get`) 尤其有效.
    * 常量表达式 (`constexpr`): 允许某些计算在编译期就完成, 结果直接作为常量嵌入到代码中.

综上, `std::array`在保留C风格数组的性能和内存优势 (栈分配) 的同时, 提供了现代C++所要求的类型安全, 易用性和强大的功能集成. 因此, 在所有需要使用固定大小数组的场景中, `std::array`都是更好的选择.

!!! note "`std::array`的存储位置"

    1. 若std::array声明为局部变量:
        * 元数据: 栈
        * 内部数组: 栈
    2. 若std::array声明为全局变量:
        * 元数据: 静态区
        * 内部数组: 静态区
    3. 若std::array通过new创建
        * 元数据: 堆
        * 内部数组: 堆

### `at()`

`at()`是C++标准库中许多容器 (例如`std::vector`, `std::string`, `std::array`, `std::map`) 都拥有的一个成员函数. 它的核心作用是: 提供有边界检查的元素访问. 当你使用`container.at(i)`来访问容器中位置`i`的元素时:

1.  如果索引`i`在有效范围内: 它会返回该位置元素的引用, 功能与`operator[]` (即方括号`[]`) 完全相同.
2.  如果索引`i`越界: 它会抛出一个`std::out_of_range`类型的异常.


* `at()` (更安全):
    ```cpp
    std::vector<int> v = {10, 20};
    try {
        int x = v.at(5); // 索引5越界, 抛出异常
    } catch (const std::out_of_range& e) {
        // 程序可以在这里捕获异常并处理错误, 而不是崩溃
        // e.what() 会返回错误描述
    }
    ```

* `operator[]` (更快):
    ```cpp
    std::vector<int> v = {10, 20};
    int y = v[5]; // 索引5越界. 这里是未定义行为 (Undefined Behavior).
                  // 程序可能会立即崩溃, 也可能读取到垃圾值, 导致后续逻辑出错.
    ```

### `fill()`


```cpp
#include <array>

int main() {
    std::array<int, 5> arr; // 创建一个包含5个整数的数组

    arr.fill(100); // 将数组的所有元素设置为100

    // 此刻, arr 的内容是 {100, 100, 100, 100, 100}
}
```

这是一个快速填满整个`std::array`的便捷方法.

### `sort()`

`std::sort`是C++标准库中一个非常强大的排序算法, 位于`<algorithm>`头文件中.  它的主要作用是对一个序列 (或容器的一部分) 进行排序.

基本用法 (升序排序): 默认情况下, `std::sort`按升序 (从小到大) 排序.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

int main() {
    std::vector<int> v = {5, 2, 8, 1, 9};

    std::sort(v.begin(), v.end()); // 对整个vector进行升序排序

    // 此刻, v 的内容是 {1, 2, 5, 8, 9}
}
```

降序排序: 如果你想降序 (从大到小) 排序, 可以提供一个额外的比较对象.

```cpp
#include <vector>
#include <algorithm>
#include <functional> // 需要包含此头文件

int main() {
    std::vector<int> v = {5, 2, 8, 1, 9};

    std::sort(v.begin(), v.end(), std::greater<>()); // 降序排序

    // 此刻, v 的内容是 {9, 8, 5, 2, 1}
}
```

自定义排序规则 (使用Lambda表达式): 对于复杂类型或者特殊的排序逻辑, 你可以提供一个自定义的比较函数, 通常用Lambda表达式实现, 非常方便.

```cpp
#include <vector>
#include <algorithm>
#include <cmath>

int main() {
    std::vector<int> v = {-8, 5, -2, 1, -9};

    // 如果a的绝对值小于b的绝对值, 则a排在前面
    std::sort(v.begin(), v.end(), [](int a, int b) {
        return std::abs(a) < std::abs(b);
    });

    // 此刻, v 的内容是 {1, -2, 5, -8, -9}
}
```
`std::sort`内部实现通常是快速排序 (Introsort), 性能非常高效.
返回的
!!! tip "`end()`和`begin()`"


    `begin()`和`end()`这两个函数返回的是一个迭代器.  什么是迭代器? 迭代器就是一个指针. 对于一个`T*`类型的指针, 执行`++`的行为就是将地址移动`sizeof(T)`个字节. 对于`std::array`和`std::vector`这类内存连续的数据结构, 它们的`begin()`和`end()`函数可以直接返回一个指针.

     但是, 对于`std::list`(链表)或`std::map`(树)这样内存不连续的数据结构, 它们必须返回一个自定义的迭代器类. 其实就是一个自定义的指针类, 这个类通过重载 (overload) `operator++`, `operator--`等运算符, 从而实现符合其自身复杂结构的遍历逻辑.

    !!! tip "为何`end()`也要返回一个迭代器"

        比较的对象类型必须相同, 这是最根本的原因.  在 `for` 循环中, 核心的判断语句是 `it != container.end()`.

        * 我们已经知道, 对于红黑树, `begin()` 返回的 `it` 必须是一个自定义的迭代器类对象, 因为只有这个类才懂得如何在树的节点间进行复杂的前进 (`++`) 操作.
        * C++语言规定, `!=` 操作符两边的对象类型必须是相同的 (或者可以相互转换).
        * 因此, 如果 `it` 是一个自定义的迭代器类的对象, 那么 `container.end()` 也必须返回一个相同类型的迭代器类的对象, 否则它们之间根本无法进行比较, 代码将无法编译.  你不能拿一个"自定义迭代器对象"去和一个"原始的节点指针"作比较, C++不知道该如何处理这两种完全不同的类型.

    我们将在迭代器那部分详细讲到.

## `std::span`的用法

`std::span`和`std::string_view`非常类似. 它是C++20引入的一个新特性, 用于表示一个连续内存区域的视图. 它可以看作是一个轻量级的容器, 但不拥有数据的所有权. `std::span`可以用于任何类型的数组, 包括C风格数组, `std::array`, `std::vector`等. 但是它和`std::string_view`有一个显著的区别, 就是`std::string_view`不可以修改底层数据, 但是`std::span`可以是可变视图, 也可以是只读视图, 取决于你如何声明它. 它的核心特性有:

* 非拥有性: `std::span`不负责其指向的内存的生命周期. 它只是一个观察者. 这意味着当原始数据被销毁后, `std::span`会变为悬空(dangling), 使用它将导致未定义行为.
* 轻量级: 一个`std::span`对象通常只包含一个指针和一个大小成员, 其大小与传递一个指针和size_t到函数中几乎没有区别, 因此开销极低.
* 灵活性与统一性: 这是`std::span`最强大的地方. 它可以从多种数据源创建, 例如C风格数组, `std::vector`, `std::array`等. 这使得我们可以编写一个接受`std::span`作为参数的函数, 而这个函数可以处理任何类型的连续数据容器, 无需为每种容器编写重载版本.
* 安全性: `std::span`提供了类似容器的接口, 例如`size()`, `front()`, `back()`以及范围for循环的支持. 它还提供了`operator[]`用于访问元素, 但与原始指针不同, 许多标准库实现会在调试模式下对访问进行边界检查, 有助于减少越界错误.

```cpp
#include <iostream>
#include <span>      // 引入<span>头文件
#include <vector>
#include <array>

// 该函数接受一个整型span, 它可以引用任何连续的整数序列
void print_data(std::span<const int> data)
{
    for (int n : data) {
        std::cout << n << ' ';
    }
    std::cout << '\n';
}

int main()
{
    // 1. 从C风格数组创建span
    int c_array[] = {1, 2, 3, 4, 5};
    std::cout << "From C-style array: ";
    print_data(c_array);

    // 2. 从std::vector创建span
    std::vector<int> vec = {6, 7, 8, 9};
    std::cout << "From std::vector: ";
    print_data(vec);

    // 3. 从std::array创建span
    std::array<int, 3> arr = {10, 11, 12};
    std::cout << "From std::array: ";
    print_data(arr);

    // 4. 从数组的一部分 (切片) 创建span
    //    创建一个从c_array的第二个元素开始, 长度为3的span
    std::span<const int> slice(c_array + 1, 3);
    std::cout << "From a slice of C-style array: ";
    print_data(slice); // 将打印 2 3 4

    return 0;
}
```

输出:

```bash
From C-style array: 1 2 3 4 5
From std::vector: 6 7 8 9
From std::array: 10 11 12
From a slice of C-style array: 2 3 4
```

为什么要使用`std::span`? 其实和使用`std::string_view`的原因类似, 在`std::span`出现之前, 我们通常通过传递指针和大小来向函数传递数组数据:

```cpp
// 旧的方式
void process_data(int* data, size_t size);
```

这种方式有几个缺点:

* 容易出错: 很容易传递错误的size, 导致缓冲区溢出或数据处理不完整.
* 接口不统一: 如果有`std::vector`, 你需要调用`vec.data()`和`vec.size()`来传递参数.

`std::span`解决了这些问题, 它将数据指针和大小封装成一个对象, 提供了更安全, 更现代, 更通用的接口来处理连续数据视图. 它是向函数传递连续序列数据的首选方式.

### 动态&静态`std::span`

`std::span`的第二个模板参数`Extent`是一个编译时常量, 用于指定`span`所引用的序列的长度. 它有两种形式:

1.  `std::dynamic_extent` (默认值):

    * 表示`span`的长度在运行时确定.
    * 这是最常见的用法, 因为它可以引用任何长度的连续序列.
    * `std::span<int>`等价于`std::span<int, std::dynamic_extent>`.

2.  一个非负整数值:

    * 表示`span`的长度在编译时就是固定的.
    * 如果尝试从一个大小不匹配的序列创建这样一个`span`, 代码将无法编译. 这提供了一层编译时安全检查.
    * 这种`span`的体积可能更小, 因为编译器已经知道了其长度, 无需再用一个成员变量来存储它.

```cpp
#include <iostream>
#include <span>
#include <vector>

// 此函数只能接受一个包含3个整数的span
void print_fixed_size_span(std::span<const int, 3> data)
{
    std::cout << "Fixed-size span (extent=3): ";
    for (int n : data) {
        std::cout << n << ' ';
    }
    std::cout << '\n';
}

// 此函数可以接受任意长度的span
void print_dynamic_size_span(std::span<const int> data) // extent is std::dynamic_extent
{
    std::cout << "Dynamic-size span (extent=" << data.size() << "): ";
    for (int n : data) {
        std::cout << n << ' ';
    }
    std::cout << '\n';
}


int main()
{
    int c_array[] = {1, 2, 3};
    std::vector<int> vec = {4, 5, 6, 7};

    // --- 固定Extent的用法 ---
    // 正确: c_array的大小正好是3
    print_fixed_size_span(c_array);

    // 错误: vec的大小是4, 不是3. 下面这行代码会导致编译失败.
    // print_fixed_size_span(vec);

    // --- 动态Extent的用法 ---
    print_dynamic_size_span(c_array); // OK
    print_dynamic_size_span(vec);     // OK

    return 0;
}
```

输出:

```bash
Fixed-size span (extent=3): 1 2 3
Dynamic-size span (extent=3): 1 2 3
Dynamic-size span (extent=4): 4 5 6 7
```

## `std::vector`

上面我们说到, `std::array`的存储位置取决于其定义, 那么`std::vector`呢? 它的情况和`std::array`有稍许不同:

1. 若std::vector声明为局部变量:
    * 元数据: 栈
    * 内部数组: 堆
2. 若std::vector声明为全局变量:
    * 元数据: 静态区
    * 内部数组: 堆
3. 若std::vector通过new创建
    * 元数据: 堆
    * 内部数组: 堆

它的核心特性包括:

* 动态大小: 可以在运行的时候动态增长或者缩小, 无需手动管理内存
* 内存连续: 元素在内存中是连续的, 这点和`std::array`是一样的, 这使得通过下标随机访问非常快, 并且能和C风格数组无缝互操作
* 高效尾部操作: 在末尾添加`push_back()`或删除`pop_back()`元素是非常高效的, 因为它们通常只涉及到指针的移动
* 低效中间操作: 在中间插入或删除元素会导致大量元素的移动, 这可能会很慢, 因为需要移动大量数据

常用的操作:

2. 添加元素
- `v.push_back(10);` 尾部插入
- `v.insert(v.begin()+2, 20);` 指定位置插入

3. 访问元素
- `v[0]` 下标访问(不检查边界)
- `v.at(0)` 边界检查访问
- `v.front()/v.back()` 首尾元素

4. 删除元素
- `v.pop_back();` 删除尾部
- `v.erase(v.begin()+1);` 删除指定位置
- `v.clear();` 清空所有元素

5. 容量操作
- `v.size()` 当前元素数量
- `v.empty()` 判断是否为空
- `v.capacity()` 当前分配容量
- `v.reserve(100)` 预分配空间

7. 修改
- `v.assign(5, 10);` 重置为5个10
- `std::sort(v.begin(), v.end());` 排序

8. 内存管理
- `v.shrink_to_fit();` 释放多余容量
- `std::vector<int>().swap(v);` 清空并释放内存

### `erase()`

`earse()`用于移除容器中的元素. 它和python中的移除元素的函数不太一样, 它一般接受的是迭代器.

```cpp
std::vector<int> v = {10, 20, 30, 40};
auto it = v.erase(v.begin() + 1);
```

或者给定元素的范围:

```cpp
std::vector<int> v = {10, 20, 30, 40, 50};
auto it = v.erase(v.begin() + 1, v.begin() + 3);
```

!!! warning "循环删除"

    在循环删除的场景中, 要特别注意`erase`的正确使用方法. 例如, 下面的代码:

    ```cpp
    #include <iostream>
    #include <vector>
    int main() {
        std::vector<int> myVector{1, 2, 3};
        myVector.push_back(4);
        for (int i = 0; i < myVector.size(); i++) {
            std::cout << "---" << std::endl;
            std::cout << "myVector.size: " << myVector.size() << std::endl;
            myVector.erase(myVector.begin());
            std::cout << myVector[i] << std::endl;
        }
        return 0;
    }
    ```

    输出是这样子的:

    ```bash
    ---
    myVector.size: 4
    2
    ---
    myVector.size: 3
    4
    ```

    如果你使用的是range循环的话:

    ```cpp
    #include <iostream>
    #include <vector>
    int main() {
        std::vector<int> myVector{1, 2, 3};
        myVector.push_back(4);
        for (auto elem : myVector) {
            myVector.erase(myVector.begin());
            std::cout << elem << std::endl;
        }
        return 0;
    }
    ```

    输出:

    ```bash
    1
    3
    4
    4
    ```

    在range循环中, 程序首先会从`myVector`中取出第一个元素的值`1`, 将其拷贝作为一个副本赋值给`elem`, 然后, `myVector.erase`修改的是`myVector`, 删除了其中的`1`, 但是由于`elem`是一个副本, 所以第一次输出的还是`1`. range循环的底层是由迭代器实现的, 循环结束后, 迭代器要进行++, 由于此时的`myVector`是`{2, 3, 4}`, 所以移动了`3`上面, 将`3`拷贝作为一个副本赋值给`elem`, 第二次循环结束后, 迭代器继续++, 此时的`myVector`是`{3, 4}`, 迭代器指向的是一块未知的内存, 在上面这种情况下, 由于这块内存原先是`4`, 所以大概率没有经过修改, 所以输出还是4; 第4次循环, `myVector`是`{4}`, 同样的, 迭代器指向的也是位置的内存, 但是由于原先是`4`, 所以输出还是4.

    如果上面我是按照引用赋值给`elem`的, 那么会输出:

    ```bash
    2
    4
    4
    4
    ```

    这是因为, 第一次循环, `elem`是`1`的一个引用, 当你删掉`1`之后, `elem`变为引用的是`2`, `myVector`变为`{2, 3, 4}`; 第二次循环, `elem`是`3`的一个引用, 当你删掉`2`之后, `elem`变为引用的是`4`, `myVector`变为`{3, 4}`; 第三次循环, `elem`此时引用的已经是未知的内存区域, 同样的, 由于原先是`4`, 所以大概率输出还是`4`, `myVector`变为`{4}`; 第四次循环, `elem`引用的还是未知的内存区域, 由于原先是`4`, 所以输出还是`4`.    

!!! note "避免拷贝"

    看下面这段代码:

    ```cpp
    std::vector<long> myVector2;
    for (size_t i = 0; i < 1000000; i++) {
        myVector2.push_back(i);
    }
    ```

    这里可能会发生多次拷贝, 也就是多次扩容. 解决的方法是使用`reserve()`方法: 

    ```cpp
    std::vector<long> myVector2;
    myVector2.reserve(1000000); // 预分配空间, 避免多次拷贝
    for (size_t i = 0; i < 1000000; i++) {
        myVector2.push_back(i);
    }
    ```

## `std::list`的用法

std::list是一个C++标准库中的容器类模板, 用来存储元素的双向链表实现. 双向链表每个元素都包含指向前一个和后一个元素的指针. 非连续存储元素在内存中不是连续存放的. 快速插入和删除在列表的任意位置插入或者删除元素都非常高效, 时间复杂度是$O(1)$. 不支持随机访问, 不能像数组那样通过索引直接访问元素, 例如`myList[0]`是不允许的, 访问元素需要遍历链表. 它还提供了双向的迭代器, 可以前向或者后向遍历列表. 可以在运行的时候动态的调整大小. `std::list`特别适合需要频繁在列表中间进行插入和删除操作的场景, 如果需要频繁随机访问或者内存空间使用效率极高, 那么`std::vector`或者`std::deque`可能更加适合. 

### 移动指针

1. 基础移动

    * `++it`: 移动到下一个元素
    * `--it`: 移动到上一个元素

    ```cpp
    #include <list>
    #include <iostream>

    int main() {
        std::list<int> lst = {1, 2, 3, 4, 5};
        auto it = lst.begin();
        ++it;
        std::cout << *it << std::endl;
        --it;
        std::cout << *it << std::endl;
        return 0;
    }
    ```

2. 使用`std::next`和`std::prev`

    * `std::next(it, n)`: 从`it`向前移动`n`步, 默认`n=1`
    * `std::prev(it, n)`: 从`it`向前移动`n`步, 默认`n=1`

    ```cpp
    #include <list>
    #include <iostream>
    #include <iterator> // 需包含此头文件

    int main() {
        std::list<int> lst = {1, 2, 3, 4, 5};
        auto it = lst.begin(); // 指向 1

        // 向前移动 2 步到 3
        auto it_next = std::next(it, 2);
        std::cout << *it_next << std::endl; // 输出 3

        // 向后移动 1 步到 2
        auto it_prev = std::prev(it_next, 1);
        std::cout << *it_prev << std::endl; // 输出 2

        return 0;
    }
    ```

3. 使用`std::advance`

    `std::advance(it, n)`: 将`it`移动`n`步, `n`可正可负.

    ```cpp
    #include <list>
    #include <iostream>
    #include <iterator>

    int main() {
        std::list<int> lst = {1, 2, 3, 4, 5};
        auto it = lst.begin(); // 指向 1

        // 向前移动 3 步到 4
        std::advance(it, 3);
        std::cout << *it << std::endl; // 输出 4

        // 向后移动 2 步到 2
        std::advance(it, -2);
        std::cout << *it << std::endl; // 输出 2

        return 0;
    }
    ```

### 其他常用函数

1. `l1.sort()`: 默认升序排列
2. `l1.sort(std::greater<int>())`: 降序排列
3. `l1.reverse()`: 反转
4. `l1.merge(l2)`: 将两个已经排序的链表合并在一起
5. `l1.splice(it, l2)`: 在`it`位置插入`l2`的所有元素

## `std::forward_list`的用法

`std::forward_list`是C++标准库中引入的一个单链表容器, 定义在`<forward_list>`头文件中. 它提供高效的插入和删除操作, 但是只支持单向遍历. 每个节点存储数据和一个指向下一个节点的指针, 只能从头节点开始访问, 每个节点能节省一个指针空间. 

1. 构造与赋值

    ```cpp
    std::forward_list<int> list1;             // 空链表
    std::forward_list<int> list2(3, 100);     // 3个元素,每个值100
    std::forward_list<int> list3 = {1, 2, 3}; // 初始化列表
    auto list4 = list3;                       // 拷贝构造
    ```

2. 元素访问

    `front()`:访问首元素(链表为空时行为未定义)

    ```cpp
    int first = list2.front(); // 100
    ```

3. 迭代器操作

    - `before_begin()`:返回首元素前一个位置的迭代器(用于插入)
    - `begin() / end()`:返回首元素和尾后迭代器

    ```cpp
    auto it_pre = list3.before_begin(); // 指向头节点(哨兵位)
    auto it = list3.begin();            // 指向第一个元素
    ```

4. 插入操作

    - `insert_after(pos, value)`:在 `pos` 后插入元素
    - `push_front(value)`:在链表头部插入元素

    ```cpp
    list3.insert_after(list3.before_begin(), 0); // 头插:{0, 1, 2, 3}
    list3.push_front(-1);                        // 头插:{-1, 0, 1, 2, 3}
    ```

5. 删除操作

    - `erase_after(pos)`:删除 `pos` 后的元素
    - `pop_front()`:删除首元素
    - `remove(val)`:删除所有等于 `val` 的元素
    - `remove_if(pred)`:删除满足谓词的元素

    ```cpp
    list3.erase_after(list3.begin()); // 删除第二个元素:{-1, 1, 2, 3}
    list3.pop_front();                // 删除首元素:{1, 2, 3}
    list3.remove(2);                  // 删除所有2:{1, 3}
    ```

6. 容量操作

    `empty()`:检查链表是否为空

    ```cpp
    if (!list3.empty()) { /* 非空 */ }
    ```

7. 链表操作

    - `splice_after(pos, other)`:将 `other` 链表内容插入到 `pos` 后
    - `reverse()`:反转链表
    - `sort()`:排序(可自定义比较函数)
    - `merge(other)`:合并两个有序链表
    - `unique()`:删除连续重复元素

    ```cpp
    std::forward_list<int> other = {4, 5};
    list3.splice_after(list3.begin(), other); // 在第二个位置后插入:{1, 4, 5, 3}
    list3.sort();                            // 排序:{1, 3, 4, 5}
    list3.unique();                          // 删除连续重复(已排序可去重)
    ```

8. 特殊操作

    - `resize(n)`:调整链表大小
    - `clear()`:清空链表

    ```cpp
    list3.resize(2); // 保留前2个元素:{1, 3}
    list3.clear();   // 清空链表
    ```

## `std::deque`的用法

`std::deque`(双端队列)是 C++ 标准模板库(STL)中的动态数组容器,支持在头部和尾部高效插入/删除元素(时间复杂度 O(1)).与 `std::vector` 相比,它在头部操作更高效;与 `std::list` 相比,它支持随机访问.以下是核心用法和示例:

1. 头文件与声明

    ```cpp
    #include <deque>
    std::deque<T> dq; // 声明元素类型为 T 的 deque
    ```

2. 初始化

    ```cpp
    std::deque<int> dq1;                     // 空 deque
    std::deque<int> dq2(5, 10);              // 5 个元素,每个值为 10
    std::deque<int> dq3 = {1, 2, 3, 4};      // 初始化列表
    std::deque<int> dq4(dq3.begin(), dq3.end()); // 迭代器范围
    ```

3. 添加元素

    ```cpp
    dq.push_back(10);   // 在尾部插入 10
    dq.push_front(5);   // 在头部插入 5
    dq.insert(dq.begin() + 2, 30); // 在索引2位置插入30
    ```

4. 删除元素

    ```cpp
    dq.pop_back();      // 删除尾部元素
    dq.pop_front();     // 删除头部元素
    dq.erase(dq.begin() + 1); // 删除索引1处的元素
    dq.clear();         // 清空所有元素
    ```

5. 访问元素

    ```cpp
    int first = dq.front();     // 首元素
    int last = dq.back();       // 末元素
    int elem = dq[2];           // 索引2处的元素(无边界检查)
    int safe_elem = dq.at(2);   // 带边界检查(越界抛异常)
    ```

6. 大小与容量

    ```cpp
    bool isEmpty = dq.empty();  
    size_t size = dq.size();    
    dq.resize(10);              // 调整大小为10
    ```

7. 迭代器遍历

    ```cpp
    // 顺序遍历
    for (auto it = dq.begin(); it != dq.end(); ++it) {
        std::cout << *it << " ";
    }

    // 逆序遍历
    for (auto it = dq.rbegin(); it != dq.rend(); ++it) {
        std::cout << *it << " ";
    }

    // 范围for循环 (C++11)
    for (int val : dq) {
        std::cout << val << " ";
    }
    ```

⚡ 性能特点

| 操作                 | 时间复杂度 |
|----------------------|------------|
| 头部/尾部插入删除    | O(1)       |
| 随机访问 `dq[i]`     | O(1)       |
| 中间插入/删除        | O(n)       |

## `std::set`的用法

`std::set`是STL中的关联容器, 它存储唯一元素(不允许重复值), 并自动按照特定顺序(默认升序)排列元素. 它的核心特性包括: 

* 唯一性: 每个元素必须唯一(插入重复值的时候会被忽略), 使用`insert()`插入重复元素的时候, 返回`pair<iterator, bool>`, 其中, `bool=False`表示插入失败
* 自动排序: 元素默认按照`operator<`升序排列, 可以通过自定义比较函数或者函数对象修改排序规则
* 底层实现: 通常依赖于红黑树, 保证插入, 删除, 查找操作的时间复杂度为`O(log n)`
* 不可修改元素值: 直接修改元素会破坏颞n内部结构(因为元素位置取决于值), 修改需要先删除旧值, 再插入新值

```cpp
#include <set>
#include <iostream>

int main() {
    // 默认升序排列
    std::set<int> numSet = {5, 2, 8, 2}; // 重复值 2 被忽略
    // 输出:2 5 8
    for (int num : numSet) std::cout << num << " ";

    // 降序排列
    std::set<int, std::greater<int>> descSet = {5, 2, 8};
    // 输出:8 5 2
    for (int num : descSet) std::cout << num << " ";

    // 插入元素
    auto [it, success] = numSet.insert(3); // 插入成功
    auto [it2, success2] = numSet.insert(2); // 失败(重复)

    // 查找元素
    if (auto pos = numSet.find(5); pos != numSet.end()) {
        std::cout << "Found: " << *pos; // 输出 5
    }

    // 删除元素
    numSet.erase(5); // 通过值删除
    numSet.erase(it); // 通过迭代器删除
}
```

### 查找操作

```cpp
#include <iostream>
#include <set>

int main() {
	std::set<int> set1{1, 2, 3, 4, 5};
	set1.insert(1);
	set1.insert(2);
	set1.insert(-4);

    std::cout << "4?: " << set1.count(4) << std::endl;
    std::cout << "4?: " << set1.contains(4) << std::endl;

    auto found = set1.find(4);
    if (found != set1.end()) {
        std::cout << "Found: " << *found << std::endl;
    } else {
        std::cout << "Not found" << std::endl;
    }

	return 0;
}
```

|方法|返回值类型|最佳使用场景|
|---|---|---|
|`count()`|`size_t`(0 or 1)|兼容旧标准的存在性检查|
|`contains()`|`bool`|C++20+存在性检查(最简洁方式)|
|`find()`|迭代器|需要元素位置/引用时|

## `std::unordered_set`的用法

std::unordered_set是C++标准库中的无序集合容器, 基于哈希表实现, 用于存储唯一元素, 特点是插入, 删除和查找操作的平均时间复杂度为O(1).

1. 头文件

    ```cpp
    #include <unordered_set>
    ```

2. 声明与初始化

    ```cpp
    std::unordered_set<int> s1; // 空集合
    std::unordered_set<std::string> s2 = {"apple", "banana"}; // 初始化列表
    ```

3. 插入元素

    ```cpp
    s1.insert(10);  // 插入单个元素
    s1.emplace(20); // 原地构造元素
    s1.insert({30, 40, 50}); // 插入多个元素
    ```

4. 查找元素

    ```cpp
    if(s1.find(10) != s1.end()) {
    // 元素存在
    }
    auto count = s1.count(20); // 返回1(存在)或0(不存在)
    ```

5. 删除元素

    ```cpp
    s1.erase(10);   // 删除值为10的元素
    s1.erase(s1.find(20)); // 通过迭代器删除
    s1.clear();     // 清空集合
    ```

6. 遍历集合

    ```cpp
    for(const auto& elem : s1) {
    std::cout << elem << " ";
    }
    ```

7. 容量查询

    ```cpp
    bool isEmpty = s1.empty(); 
    size_t size = s1.size(); 
    ```

## `std::multiset`的用法

`std::multiset`是C++标准模板库(STL)中的一个关联容器, 其特性和`std::set`类似, 但允许存储重复的键. 元素默认按升序排序.

1. 头文件

    要使用`std::multiset`, 需要包含头文件`<set>`.

    ```cpp
    #include <iostream>
    #include <set>
    #include <string>
    ```

2. 创建`std::multiset`

    可以创建一个空的`multiset`, 或者在创建时进行初始化.

    ```cpp
    // 创建一个存储int的空multiset
    std::multiset<int> m1;

    // 使用初始化列表创建multiset
    std::multiset<int> m2 = {5, 2, 8, 2, 5};

    // 创建一个降序排序的multiset
    std::multiset<int, std::greater<int>> m3 = {5, 2, 8, 2, 5};
    ```

3. 插入元素

    使用`insert()`成员函数向`multiset`中添加元素.

    ```cpp
    std::multiset<int> ms;

    // 插入单个元素
    ms.insert(10);
    ms.insert(20);
    ms.insert(10); // 允许重复

    // 插入初始化列表 (C++11)
    ms.insert({30, 40, 30});
    ```

4. 删除元素

    使用`erase()`成员函数删除元素.

    ```cpp
    std::multiset<int> ms = {10, 20, 10, 30, 40, 30};

    // 删除所有值为10的元素
    ms.erase(10);

    // 删除指向第一个元素的迭代器
    ms.erase(ms.begin());

    // 删除一个范围内的元素
    auto it = ms.find(30);
    if (it != ms.end()) {
        ms.erase(it); // 只会删除一个30
    }
    ```

5. 查找和计数

    * `find()`: 返回一个指向第一个匹配元素的迭代器. 如果未找到, 返回`end()`迭代器.
    * `count()`: 返回具有特定值的元素的数量.
    * `lower_bound()`: 返回指向第一个不小于给定值的元素的迭代器.
    * `upper_bound()`: 返回指向第一个大于给定值的元素的迭代器.
    * `equal_range()`: 返回一个`std::pair`, 包含`lower_bound`和`upper_bound`的结果.

    ```cpp
    std::multiset<int> ms = {10, 20, 10, 30, 40, 30, 10};

    // 查找元素
    auto it = ms.find(20);
    if (it != ms.end()) {
        std::cout << "Found: " << *it << std::endl;
    }

    // 统计元素数量
    size_t num = ms.count(10); // num 将会是 3

    // 使用lower_bound和upper_bound遍历所有值为10的元素
    for (auto it = ms.lower_bound(10); it != ms.upper_bound(10); ++it) {
        std::cout << *it << " ";
    }
    std::cout << std::endl; // 输出: 10 10 10

    // 使用equal_range
    auto range = ms.equal_range(30);
    for (auto it = range.first; it != range.second; ++it) {
        std::cout << *it << " ";
    }
    std::cout << std::endl; // 输出: 30 30
    ```

6. 遍历

    通常使用基于范围的for循环或迭代器进行遍历.

    ```cpp
    std::multiset<int> ms = {50, 20, 80, 20, 70};

    // 使用基于范围的for循环 (C++11)
    for (int val : ms) {
        std::cout << val << " ";
    }
    // 输出将是排序后的结果: 20 20 50 70 80
    std::cout << std::endl;

    // 使用迭代器
    for (auto it = ms.begin(); it != ms.end(); ++it) {
        std::cout << *it << " ";
    }
    // 输出: 20 20 50 70 80
    std::cout << std::endl;
    ```

| 特性 | `std::multiset` | `std::set` |
| :--- | :--- | :--- |
| 重复元素 | 允许 | 不允许 |
| `insert()`返回值 | `iterator` | `std::pair<iterator, bool>` |
| `erase(key)` | 删除所有等于`key`的元素 | 删除等于`key`的唯一元素 |
| `count(key)` | 返回等于`key`的元素数量 | 返回0或1 |

`std::multiset::insert()`总是会插入元素并返回指向新元素的迭代器. 而`std::set::insert()`只有在元素不存在时才会插入,并通过返回的`std::pair`中的`bool`值来指示插入是否成功.

## `std::unordered_multiset`的用法

`std::unordered_multiset`是STL中的一个关联容器, 它存储一组元素(键), 并允许键重复, 和`std::multiset`不同, 其内部元素不是有序的, 而是使用哈希表来组织, 这使得在平均情况下查找, 插入和删除操作的复杂度为常数时间O(1).

| 特性 | `std::unordered_multiset` | `std::multiset` |
| :--- | :--- | :--- |
| 内部实现 | 哈希表 | 红黑树 |
| 元素顺序 | 无序 | 升序 |
| 查找/插入/删除 | 平均$O(1)$, 最坏$O(n)$ | $O(\\log n)$ |
| 迭代器 | 前向迭代器 | 双向迭代器 |
| 额外开销 | 哈希表管理的开销 | 树节点指针的开销 |
| 头文件 | `<unordered_set>` | `<set>` |o

## `std::pair`的用法

`std::pair`是STL中的一个模板类, 它将两个可能不同类型的值组合成一个单一的对象. 这个组合对象可以被当做一个独立的单元来处理. 它的特性包括:

* 组合: 将两个值(称为`first`和`second`)打包在一起
* 异构性: 两个值的类型可以不同, 例如`std::pair<int, std::string>`
* 便携性: 常用于需要从函数中返回多个值, 或在关联容器(如`std::map`)中存储键值对的场景

1. 头文件

    ```cpp
    #include <utility> // 主要头文件
    #include <iostream> // 用于示例输出
    #include <string>   // 用于示例类型
    ```

2. 声明和初始化

    有多种方式可以创建`std::pair`.

    * 使用构造函数

        ```cpp
        std::pair<int, std::string> p1(1, "hello");
        ```

    * 使用`std::make_pair()`辅助函数 (C++11前常用)
        `std::make_pair`可以自动推断类型, 使代码更简洁.

        ```cpp
        auto p2 = std::make_pair(2, "world");
        ```

    * 使用聚合初始化 (C++11及以后)
        这是最现代, 最简洁的方式.

        ```cpp
        std::pair<int, double> p3 = {3, 3.14};
        std::pair<std::string, bool> p4{"test", true};
        ```

3. 访问元素

    `std::pair`的两个成员可以通过`.first`和`.second`公开访问.

    ```cpp
    std::pair<int, std::string> p(10, "apple");

    // 访问第一个元素
    int id = p.first; // id 为 10

    // 访问第二个元素
    std::string name = p.second; // name 为 "apple"

    std::cout << "ID: " << p.first << ", Name: " << p.second << std::endl;

    // 修改元素
    p.first = 20;
    p.second = "banana";
    ```

4. 结构化绑定 (C++17及以后)

    C++17引入了结构化绑定, 提供了一种更优雅的方式来分解`std::pair`(以及其他类似`struct`的类型)的成员到独立的变量中.

    ```cpp
    std::pair<int, std::string> user = {101, "Alice"};

    auto [userId, userName] = user; // 自动分解

    std::cout << "User ID: " << userId << std::endl;   // 输出: User ID: 101
    std::cout << "User Name: " << userName << std::endl; // 输出: User Name: Alice
    ```

5. 比较操作

    `std::pair`支持比较运算符 (`==`, `!=`, `<`, `>`, `<=`, `>=`). 比较是按字典序进行的:

    1.  首先比较`first`成员.
    2.  如果`first`成员相等, 则比较`second`成员.

    ```cpp
    std::pair<int, int> p1 = {10, 20};
    std::pair<int, int> p2 = {10, 30};
    std::pair<int, int> p3 = {5, 40};

    if (p1 < p2) { // true, 因为 p1.first == p2.first 且 p1.second < p2.second
        std::cout << "p1 is less than p2" << std::endl;
    }

    if (p3 < p1) { // true, 因为 p3.first < p1.first
        std::cout << "p3 is less than p1" << std::endl;
    }
    ```

### 常见应用场景

1. 从函数返回多个值

    ```cpp
    #include <iostream>
    #include <string>
    #include <utility>

    std::pair<int, std::string> get_user_data() {
        // 假设这里有一些逻辑来获取数据
        return {123, "Bob"};
    }

    int main() {
        // C++17 结构化绑定
        auto [id, name] = get_user_data();
        std::cout << "ID: " << id << ", Name: " << name << std::endl;

        // C++11/14 写法
        auto user_data = get_user_data();
        std::cout << "ID: " << user_data.first << ", Name: " << user_data.second << std::endl;

        return 0;
    }
    ```

2. 在`std::map`中使用

    `std::map`的每个元素本质上就是一个`std::pair<const Key, T>`.

    ```cpp
    #include <iostream>
    #include <string>
    #include <map>

    int main() {
        std::map<std::string, int> word_counts;

        // 插入元素, 可以使用make_pair或聚合初始化
        word_counts.insert(std::make_pair("hello", 1));
        word_counts.insert({"world", 2});
        word_counts["hello"]++; // 访问并增加 "hello" 的计数值

        // 遍历map
        for (const auto& pair : word_counts) {
            // pair 是一个 const std::pair<const std::string, int>&
            std::cout << pair.first << ": " << pair.second << std::endl;
        }

        // C++17 结构化绑定遍历
        for (const auto& [word, count] : word_counts) {
            std::cout << word << " appears " << count << " times." << std::endl;
        }

        return 0;
    }
    ```

## `std::map`的用法

`std::map`是C++标准库中的一个关联容器, 它存储的元素是键值对(key-value pairs), 并且会根据键(key)自动排序. 当你需要存储键值对, 并且希望能够根据键快速查找值, 同时还要求数据自动保持有序时, `std::map`是理想的选择. 例如, 存储学生ID和对应的学生信息, 或者统计单词出现的频率并按字母顺序输出.

1. 头文件

    ```cpp
    #include <iostream>
    #include <string>
    #include <map>
    ```

2. 声明和初始化

    ```cpp
    // 默认构造
    std::map<std::string, int> word_counts;

    // 使用初始化列表 (C++11及以后)
    std::map<char, int> char_map = {
        {'a', 1},
        {'b', 2},
        {'c', 3}
    };
    ```

3. 访问和修改元素

  * 使用`[]`操作符

    这是最常用和最方便的方式. 如果键存在, 它返回对应值的引用. 如果键不存在, 它会自动插入一个新元素, 键为指定的键, 值为默认构造的值(对于`int`是0, `string`是空字符串等), 然后返回这个新值的引用.

    ```cpp
    std::map<std::string, int> scores;

    // 赋值 (如果"Alice"不存在, 会自动创建)
    scores["Alice"] = 95;
    scores["Bob"] = 88;

    // 修改
    scores["Alice"] = 98;

    // 访问
    std::cout << "Bob's score: " << scores["Bob"] << std::endl;

    // 注意: 仅仅是访问一个不存在的键也会导致插入
    std::cout << scores["Charlie"]; // 会插入"Charlie":0, 并输出0
    ```

  * 使用`at()`成员函数

    `at()`提供带边界检查的访问. 如果键存在, 它返回值的引用. 如果键不存在, 它会抛出`std::out_of_range`异常, 而不会插入新元素.

    ```cpp
    try {
        scores.at("Alice") = 100; // 安全的修改
        std::cout << scores.at("David"); // 会抛出异常
    } catch (const std::out_of_range& e) {
        std::cerr << "Error: " << e.what() << std::endl;
    }
    ```

4. 插入元素

    * `insert()`

        `insert()`是更通用的插入方法. 它返回一个`std::pair<iterator, bool>`.

        * `iterator`指向被插入的元素或已存在的具有相同键的元素.
        * `bool`表示插入是否成功. 如果键已存在, 插入会失败, `bool`为`false`.

        ```cpp
        std::map<int, std::string> students;

        // 使用std::make_pair
        auto result1 = students.insert(std::make_pair(101, "Eve"));
        if (result1.second) {
            std::cout << "Inserted successfully." << std::endl;
        }

        // 使用聚合初始化 (C++11)
        auto result2 = students.insert({102, "Frank"});

        // 尝试插入一个已存在的键
        auto result3 = students.insert({101, "Elsa"}); // 插入会失败
        if (!result3.second) {
            std::cout << "Key 101 already exists. Value is: " << result3.first->second << std::endl;
        }
        ```

5. 查找元素

  * `find()`

    `find()`用于查找一个键. 如果找到, 返回指向该元素的迭代器. 如果找不到, 返回`end()`迭代器.

    ```cpp
    auto it = scores.find("Alice");
    if (it != scores.end()) {
        // it->first 是键, it->second 是值
        std::cout << it->first << "'s score is " << it->second << std::endl;
    } else {
        std::cout << "Alice not found." << std::endl;
    }
    ```

  * `count()`

    由于`std::map`的键是唯一的, `count()`只会返回0或1, 可以用来检查键是否存在.

    ```cpp
    if (scores.count("Bob")) {
        std::cout << "Bob is in the map." << std::endl;
    }
    ```

6. 删除元素

  * `erase()`

    可以按键删除, 按迭代器删除, 或按范围删除.

    ```cpp
    // 按键删除
    size_t num_erased = scores.erase("Charlie"); // 返回删除的元素数量 (0或1)

    // 按迭代器删除
    auto it_bob = scores.find("Bob");
    if (it_bob != scores.end()) {
        scores.erase(it_bob);
    }
    ```

7. 遍历

    由于`std::map`是有序的, 遍历的结果也是有序的.

    * 使用范围`for`循环 (C++11及以后)

        这是最简单的方式.

        ```cpp
        std::map<std::string, int> fruit_prices = {{"banana", 3}, {"apple", 2}, {"orange", 4}};

        // 使用结构化绑定 (C++17)
        for (const auto& [fruit, price] : fruit_prices) {
            std::cout << fruit << ": " << price << std::endl;
        }
        // 输出会是:
        // apple: 2
        // banana: 3
        // orange: 4
        ```

    * 使用迭代器

        ```cpp
        for (auto it = fruit_prices.begin(); it != fruit_prices.end(); ++it) {
            std::cout << it->first << " -> " << it->second << std::endl;
        }
        ```

| 特性 | `std::map` | `std::unordered_map` |
| :--- | :--- | :--- |
| 内部实现 | 红黑树 | 哈希表 |
| 元素顺序 | 按键排序 | 无序 |
| 查找/插入/删除 | $O(\\log n)$ | 平均$O(1)$, 最坏$O(n)$ |
| 内存使用 | 通常更少 | 哈希表管理有额外开销 |
| 头文件 | `<map>` | `<unordered_map>` |

如果你需要有序数据, 或者对最坏情况下的性能有严格要求, 选择`std::map`. 如果你追求最快的平均性能且不关心顺序, `std::unordered_map`通常是更好的选择.

## `std::multimap`的用法

`std::multimap`是C++标准库中的一个关联容器, 它存储键值对(key-value pairs), 并根据键自动排序. 与`std::map`不同, `std::multimap`允许键重复. 当你需要存储键值对, 并希望根据键排序, 同时一个键需要对应多个值时, `std::multimap`是最佳选择. 例如, 一个字典应用中, 一个单词(键)可能有多种释义(值); 或者一个电话簿中, 一个人名(键)可能对应多个电话号码(值).

`std::multimap`与`std::map`非常相似, 主要区别在于:

1.  键的唯一性: `std::map`的键是唯一的, 而`std::multimap`允许键重复.
2.  访问方式: `std::multimap`没有`[]`操作符和`.at()`成员函数. 因为一个键可能对应多个值, `m[key]`这种访问方式会产生歧义. 你必须使用其他方法(如`find`, `equal_range`)来访问元素.

1. 头文件

    ```cpp
    #include <iostream>
    #include <string>
    #include <map> // multimap也在此头文件中
    ```

2. 声明和初始化

    ```cpp
    // 默认构造
    std::multimap<std::string, int> scores;

    // 使用初始化列表 (C++11及以后)
    std::multimap<std::string, std::string> contacts = {
        {"Alice", "123-4567"},
        {"Bob", "234-5678"},
        {"Alice", "987-6543"} // "Alice"键重复
    };
    ```

3. 插入元素

    使用`insert()`成员函数. 因为键可以重复, `insert`总会成功并添加一个新元素.

    ```cpp
    std::multimap<std::string, int> student_scores;

    // 插入总是会成功
    student_scores.insert({"Eve", 90});
    student_scores.insert(std::make_pair("Frank", 85));
    student_scores.insert({"Eve", 95}); // 再次插入"Eve", 值不同
    ```

4. 查找和访问元素

    由于键可以重复, 访问与特定键关联的所有值是`std::multimap`的核心操作.

    * `find()`
        `find(key)`返回一个指向第一个匹配该键的元素的迭代器. 如果找不到, 返回`end()`.

        ```cpp
        auto it = contacts.find("Alice");
        if (it != contacts.end()) {
            // it->first 是键, it->second 是值
            std::cout << "Found one contact for Alice: " << it->second << std::endl;
        }
        ```

    * `count()`
        `count(key)`返回具有特定键的元素的数量.

        ```cpp
        size_t num_alice = contacts.count("Alice"); // 返回 2
        std::cout << "Alice has " << num_alice << " contacts." << std::endl;
        ```

    * `equal_range()`
        这是处理重复键最常用, 最强大的方法. 它返回一个`std::pair<iterator, iterator>`, 这两个迭代器构成一个半开区间`[first, second)`, 包含了所有匹配该键的元素.

        ```cpp
        std::cout << "All contacts for Alice:" << std::endl;
        auto range = contacts.equal_range("Alice");
        for (auto it = range.first; it != range.second; ++it) {
            std::cout << "  - " << it->second << std::endl;
        }
        ```

5. 删除元素

  * `erase()`

      * `erase(key)`: 删除所有匹配该键的元素, 并返回被删除元素的数量.
      * `erase(iterator)`: 只删除迭代器指向的那个元素.

    ```cpp
    // 按键删除 (会删除所有 "Alice" 的条目)
    size_t num_erased = contacts.erase("Alice");
    std::cout << "Erased " << num_erased << " entries for Alice." << std::endl;

    // 按迭代器删除 (只删除一个)
    auto it_bob = contacts.find("Bob");
    if (it_bob != contacts.end()) {
        contacts.erase(it_bob);
    }
    ```

6. 遍历

    遍历`std::multimap`会按键的顺序访问所有元素.

    ```cpp
    std::multimap<std::string, int> mm = {
        {"b", 20},
        {"a", 10},
        {"c", 30},
        {"a", 15}
    };

    // 使用范围for循环 (C++11) 和结构化绑定 (C++17)
    for (const auto& [key, value] : mm) {
        std::cout << key << ": " << value << std::endl;
    }

    /*
    输出 (按键排序):
    a: 10
    a: 15
    b: 20
    c: 30
    */
    ```

## `std::unordered_map`的用法

`std::unordered_map`是一个关联容器, 用于存储由"键 (Key)"和"值 (Value)"组成的元素对. 它的核心特点是无序和快速.

1.  实现方式: `std::unordered_map`内部基于\*\*哈希表 (Hash Table)\*\*实现. 它通过一个哈希函数将键转换为一个哈希值 (一个整数), 并以此作为元素在内存中的索引, 从而实现快速访问.
2.  无序性: 由于基于哈希表, `std::unordered_map`中的元素不会像`std::map`那样根据键自动排序. 遍历它时, 元素的顺序是不确定的, 并且可能在每次程序运行时发生变化.
3.  性能: 它的主要优点是性能. 在平均情况下, 插入, 删除和查找操作的时间复杂度都是常数时间$O(1)$. 在最坏情况下 (所有元素都产生哈希冲突), 时间复杂度会退化到线性时间$O(N)$.

1. 包含头文件

    ```cpp
    #include <iostream>
    #include <string>
    #include <unordered_map>
    ```

2. 声明与初始化

    ```cpp
    // 声明一个键为string, 值为int的unordered_map
    std::unordered_map<std::string, int> wordCount;

    // 声明并使用初始化列表进行初始化
    std::unordered_map<std::string, int> ages = {
        {"Alice", 25},
        {"Bob", 30},
        {"Charlie", 22}
    };
    ```

3. 插入与修改元素

    有两种主要方法:

    - 使用`[]`操作符: 这是最简单直接的方式. 如果键不存在, 则会创建新元素; 如果键已存在, 则会更新其对应的值.

        ```cpp
        ages["Bob"] = 31; // Bob已存在, 更新值为31
        ages["David"] = 28; // David不存在, 创建新元素
        ```

    - 使用`insert()`方法: 这种方法更灵活. 如果键已存在, `insert`不会执行任何操作.

        ```cpp
        // 使用std::make_pair
        ages.insert(std::make_pair("Eve", 29));

        // 使用{}初始化列表 (C++11及以上)
        ages.insert({"Frank", 40});

        // insert会返回一个std::pair, .second是一个bool值, 表示是否插入成功
        auto result = ages.insert({"Alice", 99}); // Alice已存在
        if (!result.second) {
            std::cout << "Insert failed, Alice already exists. " << std::endl;
        }
        ```

4. 访问元素

    - 使用`[]`操作符: 方便, 但有风险. 如果键不存在, 它会自动插入一个具有默认值 (例如`int`的0, `string`的"") 的新元素. 这可能会引入意想不到的bug.

        ```cpp
        std::cout << "Alice's age is " << ages["Alice"] << std::endl; // 输出: 25
        std::cout << "George's age is " << ages["George"] << std::endl; // 输出: 0, 并且"George"被添加到了map中
        ```

    - 使用`at()`方法: 更安全的方式. 如果键存在, 它会返回值; 如果键不存在, 它会抛出`std::out_of_range`异常.

        ```cpp
        try {
            std::cout << "Bob's age is " << ages.at("Bob") << std::endl;
            // std::cout << ages.at("Zoe") << std::endl; // 这行会抛出异常
        } catch (const std::out_of_range& e) {
            std::cout << "Key not found: " << e.what() << std::endl;
        }
        ```

5. 检查键是否存在

    在访问前检查键是否存在是一个好习惯.

    - 使用`contains()` (C++20): 这是最现代, 最清晰的方法.
        ```cpp
        if (ages.contains("Charlie")) {
            std::cout << "Charlie is in the map. " << std::endl;
        }
        ```
    - 使用`find()` (C++20之前): `find`返回一个指向元素的迭代器. 如果未找到, 则返回`end()`迭代器.
        ```cpp
        if (ages.find("David") != ages.end()) {
            std::cout << "David is in the map. " << std::endl;
        }
        ```
    - 使用`count()` (C++20之前): 由于键是唯一的, `count`只会返回0 (不存在)或1 (存在).
        ```cpp
        if (ages.count("Eve") > 0) {
            std::cout << "Eve is in the map. " << std::endl;
        }
        ```

6. 删除元素

    使用`erase()`方法.

    ```cpp
    // 按键删除
    ages.erase("Frank");

    // erase会返回被删除元素的数量 (0或1)
    if (ages.erase("NonExistentKey") == 0) {
        std::cout << "Key was not found to be erased. " << std::endl;
    }
    ```

7. 遍历

    使用范围`for`循环是遍历`unordered_map`最简单的方式.

    ```cpp
    std::cout << "All ages:" << std::endl;
    // 使用const auto&避免不必要的拷贝
    for (const auto& pair : ages) {
        // pair是一个std::pair对象
        std::cout << " - " << pair.first << ": " << pair.second << std::endl;
    }
    ```

    再次强调: 遍历的顺序是不确定的.

| 特性 | `std::unordered_map` | `std::map` |
| :--- | :--- | :--- |
| 内部实现 | 哈希表 (Hash Table) | 平衡二叉搜索树 (通常是红黑树) |
| 元素顺序 | 无序 | 按键排序 |
| 平均性能 | $O(1)$ | $O(\log N)$ |
| 最坏性能 | $O(N)$ | $O(\log N)$ |
| 键的要求 | 需要哈希函数和`operator==` | 需要严格弱序比较 (如`operator<`) |
| 适用场景 | 追求极致的查找性能, 不关心顺序 | 需要按顺序访问元素 |

## `std::unordered_multimap`的用法

`std::unordered_multimap`是C++标准库中的一个关联容器, 它储存由键(Key)和值(Value)组成的元素对(pair). 与`std::unordered_map`不同, `std::unordered_multimap`允许存在具有相同键的多个元素.

它的主要特点是:

  * 关联性: 元素通过键进行访问, 而不是通过它们在容器中的绝对位置.
  * 无序性: 元素在内部并不按任何特定顺序排序, 而是根据其哈希值组织到桶(bucket)中, 这使得查找, 插入和删除操作的平均时间复杂度为$O(1)$.
  * 允许多键: 允许插入具有相同键的多个键值对.

当你需要一个字典或哈希表结构, 并且一个键可以关联多个值时, `std::unordered_multimap`是一个理想的选择. 例如, 一个储存一个单词所有定义的字典.

1. 头文件

    要使用`std::unordered_multimap`, 你需要包含以下头文件:

    ```cpp
    #include <iostream>
    #include <string>
    #include <unordered_map> // 注意是<unordered_map>, 不是<unordered_multimap>
    ```

2. 初始化

    你可以创建一个空的`std::unordered_multimap`, 或者使用初始化列表进行初始化.

    ```cpp
    // 创建一个键为std::string, 值为int的空unordered_multimap
    std::unordered_multimap<std::string, int> umm1;

    // 使用初始化列表创建
    std::unordered_multimap<std::string, int> umm2 = {
        {"apple", 1},
        {"orange", 2},
        {"apple", 3}, // 允许重复的键
        {"banana", 2}
    };
    ```

3. 插入元素

    使用`insert()`成员函数插入元素.

    ```cpp
    std::unordered_multimap<std::string, int> umm;

    // 插入std::pair
    umm.insert(std::make_pair("apple", 10));
    umm.insert(std::pair<std::string, int>("orange", 20));

    // 使用初始化列表 (C++11)
    umm.insert({"banana", 30});
    umm.insert({"apple", 40});
    ```

4. 访问元素

    由于`std::unordered_multimap`允许重复的键, 它没有提供`operator[]`. 你必须使用`find()`, `equal_range()`, 或`count()`来访问元素.

    * `find(key)`: 返回一个指向第一个匹配键的元素的迭代器. 如果未找到, 则返回`end()`.

        ```cpp
        auto it = umm2.find("apple");
        if (it != umm2.end()) {
            std::cout << "Found an apple with value: " << it->second << std::endl;
        }
        ```

    * `count(key)`: 返回具有特定键的元素的数量.

        ```cpp
        size_t apple_count = umm2.count("apple");
        std::cout << "Number of apples: " << apple_count << std::endl; // 输出: Number of apples: 2
        ```

    * `equal_range(key)`: 返回一个`std::pair`, 其中包含两个迭代器, 这两个迭代器定义了所有具有特定键的元素的范围`[first, second)`. 这是遍历具有相同键的所有值的最常用方法.

        ```cpp
        // 遍历所有键为 "apple" 的元素
        auto range = umm2.equal_range("apple");
        for (auto it = range.first; it != range.second; ++it) {
            std::cout << "Value for apple: " << it->second << std::endl;
        }
        ```

5. 删除元素

    * `erase(key)`: 删除所有具有特定键的元素.

        ```cpp
        size_t num_erased = umm2.erase("apple");
        std::cout << "Erased " << num_erased << " elements with key 'apple'." << std::endl;
        ```

    * `erase(iterator)`: 删除迭代器指向的单个元素.

        ```cpp
        auto it_to_erase = umm2.find("orange");
        if (it_to_erase != umm2.end()) {
            umm2.erase(it_to_erase);
        }
        ```

6. 遍历

    你可以像遍历其他容器一样使用基于范围的for循环来遍历`std::unordered_multimap`.

    ```cpp
    std::unordered_multimap<std::string, int> umm = {
        {"grape", 5},
        {"lemon", 7},
        {"grape", 8}
    };

    for (const auto& pair : umm) {
        std::cout << "Key: " << pair.first << ", Value: " << pair.second << std::endl;
    }
    ```

## `std::stack`的用法

`std::stack`是C++标准库中的一个容器适配器, 它提供后进先出(LIFO)的栈数据结构. 它不是一个独立的容器, 而是对现有容器(如`std::deque`, `std::vector`或`std::list`)的封装. 要使用`std::stack`, 需要包含头文件:

```cpp
#include <stack>
```

stack的特点有:

* LIFO: Last-In, First-Out. 最后压入栈的元素最先被弹出.
* 容器适配器: 默认使用`std::deque`作为其底层容器. 你也可以指定`std::vector`或`std::list`.
* 接口限制: 只能访问栈顶元素, 不支持迭代器, 不能遍历整个栈.

假设有一个`std::stack<T> s`:

  * `s.push(element)`: 将一个元素压入栈顶.
  * `s.pop()`: 移除栈顶元素, 但不返回该元素的值.
  * `s.top()`: 返回对栈顶元素的引用.
  * `s.empty()`: 检查栈是否为空. 如果为空返回`true`, 否则返回`false`.
  * `s.size()`: 返回栈中元素的数量.

下面的代码展示了`std::stack`的基本用法.

```cpp
#include <iostream>
#include <stack>
#include <vector>

int main() {
    // 默认使用 std::deque
    std::stack<int> s1;

    // 推入元素
    s1.push(10);
    s1.push(20);
    s1.push(30);

    std::cout << "Stack size: " << s1.size() << std::endl; // 输出: Stack size: 3
    std::cout << "Top element: " << s1.top() << std::endl; // 输出: Top element: 30

    // 弹出元素
    s1.pop();
    std::cout << "After pop, top element is: " << s1.top() << std::endl; // 输出: After pop, top element is: 20

    // 遍历并清空栈
    std::cout << "Stack elements: ";
    while (!s1.empty()) {
        std::cout << s1.top() << " "; // 访问栈顶
        s1.pop();                   // 弹出
    }
    std::cout << std::endl; // 输出: Stack elements: 20 10

    std::cout << "Final stack size: " << s1.size() << std::endl; // 输出: Final stack size: 0

    // 使用 std::vector 作为底层容器
    std::stack<std::string, std::vector<std::string>> s2;
    s2.push("hello");
    s2.push("world");
    std::cout << "Top of s2: " << s2.top() << std::endl; // 输出: Top of s2: world

    return 0;
}
```

`std::stack`非常适合需要后进先出逻辑的场景. 它的接口简洁, 易于使用, 但功能也相对受限, 因为它被设计为只对栈顶进行操作.

## `std::queue`的用法

`std::queue`是C++标准库中的一个容器适配器, 它提供了先进先出(FIFO)的队列数据结构. 与`std::stack`类似, 它也是对现有容器的封装.

要使用`std::queue`, 需要包含头文件:

```cpp
#include <queue>
```

queue的特点包括:

* FIFO: First-In, First-Out. 最先进入队列的元素最先被移出.
* 容器适配器: 默认使用`std::deque`作为其底层容器. 你也可以指定`std::list`作为底层容器, 但不能使用`std::vector`, 因为`std::vector`没有高效的`pop_front()`操作.
* 接口限制: 只能访问队列的头部和尾部元素, 不支持迭代器, 不能遍历整个队列.

假设有一个`std::queue<T> q`:

* `q.push(element)`: 将一个元素添加到队列的尾部.
* `q.pop()`: 移除队列的头部元素, 但不返回其值.
* `q.front()`: 返回对队列头部元素的引用.
* `q.back()`: 返回对队列尾部元素的引用.
* `q.empty()`: 检查队列是否为空. 如果为空返回`true`, 否则返回`false`.
* `q.size()`: 返回队列中元素的数量.

下面的代码展示了`std::queue`的基本用法.

```cpp
#include <iostream>
#include <queue>
#include <string>

int main() {
    // 默认使用 std::deque
    std::queue<int> q;

    // 推入元素
    q.push(10); // q 现在是 {10}
    q.push(20); // q 现在是 {10, 20}
    q.push(30); // q 现在是 {10, 20, 30}

    std::cout << "Queue size: " << q.size() << std::endl; // 输出: Queue size: 3
    std::cout << "Front element: " << q.front() << std::endl; // 输出: Front element: 10
    std::cout << "Back element: " << q.back() << std::endl;   // 输出: Back element: 30

    // 弹出元素
    q.pop(); // 移出 10, q 现在是 {20, 30}
    std::cout << "After pop, front element is: " << q.front() << std::endl; // 输出: After pop, front element is: 20

    // 遍历并清空队列
    std::cout << "Queue elements: ";
    while (!q.empty()) {
        std::cout << q.front() << " "; // 访问头部元素
        q.pop();                     // 移出头部元素
    }
    std::cout << std::endl; // 输出: Queue elements: 20 30

    std::cout << "Final queue size: " << q.size() << std::endl; // 输出: Final queue size: 0

    return 0;
}
```

`std::queue`是实现需要按顺序处理任务(如任务调度, 广度优先搜索BFS等)的理想选择. 它的接口强制执行FIFO规则, 使得代码逻辑清晰且不易出错.

## `std::priority_queue`的用法

`std::priority_queue`是C++标准库中的一个容器适配器, 它提供常数时间的最大元素查找, 以及对数时间的插入和删除操作. 它通常被实现为堆(heap).

要使用`std::priority_queue`, 需要包含`<queue>`头文件.

`std::priority_queue`的模板定义如下:

```cpp
template<
    class T,
    class Container = std::vector<T>,
    class Compare = std::less<typename Container::value_type>
> class priority_queue;
```

* `T`: 存储的元素类型.
* `Container`: 用于存储元素的底层容器, 默认为`std::vector<T>`.
* `Compare`: 比较函数对象, 用于确定元素的优先级. 默认为`std::less<T>`, 这会创建一个最大堆(max-heap), 即队首元素总是最大的.

常用成员函数:

  * `empty()`: 检查优先级队列是否为空.
  * `size()`: 返回优先级队列中的元素个数.
  * `top()`: 返回队首元素的引用(即优先级最高的元素), 但不删除它.
  * `push(const T& value)`: 插入一个元素.
  * `pop()`: 删除队首元素.

1. 最大堆 (默认)

    默认情况下, `std::priority_queue`是一个最大堆, 最大的元素拥有最高的优先级.

    ```cpp
    #include <iostream>
    #include <queue>
    #include <vector>

    int main() {
        std::priority_queue<int> pq; // 默认是最大堆

        pq.push(30);
        pq.push(100);
        pq.push(25);
        pq.push(40);

        std::cout << "Top element: " << pq.top() << std::endl; // 输出 100

        pq.pop();

        std::cout << "Top element after pop: " << pq.top() << std::endl; // 输出 40

        std::cout << "Queue elements: ";
        while (!pq.empty()) {
            std::cout << pq.top() << " "; // 输出: 40 30 25
            pq.pop();
        }
        std::cout << std::endl;

        return 0;
    }
    ```

2. 最小堆

    要创建一个最小堆(min-heap), 即最小的元素拥有最高的优先级, 你需要提供`std::greater<T>`作为比较类型.

    ```cpp
    #include <iostream>
    #include <queue>
    #include <vector>

    int main() {
        // 创建一个最小堆
        std::priority_queue<int, std::vector<int>, std::greater<int>> pq;

        pq.push(30);
        pq.push(100);
        pq.push(25);
        pq.push(40);

        std::cout << "Top element: " << pq.top() << std::endl; // 输出 25

        pq.pop();

        std::cout << "Top element after pop: " << pq.top() << std::endl; // 输出 30

        return 0;
    }
    ```

## 迭代器

在C++中, 迭代器是一种对象, 它可以被看作是泛化的指针. 它的核心作用是提供一种统一的方式来访问一个容器(如`std::vector`, `std::map`, `std::list`等)中的每一个元素, 而不必暴露该容器的内部数据结构. 

### 主要作用

想象一下, 无论你面对的是一个数组, 一个链表, 还是一棵树, 你都希望使用同样的方式去遍历它: 

1. 获取指向第一个元素的指针
2. 读取当前元素的值
3. 移动到下一个元素
4. 检查是否已经达到了容器的末尾

### 核心概念

* 抽象: 迭代器将指针的行为(访问`*`和移动`++`)抽象出来, 使其能用于各种不同的数据结构.
* 桥梁: 它是算法(`std::sort`, `std::find`等)和容器之间的桥梁. 标准库算法不直接操作容器, 而是通过迭代器来操作容器中的元素范围. 这使得一个`std::sort`算法可以用于排序`std::vector`, `std::deque`, 甚至一个普通数组.

### 基本操作

迭代器通常支持以下基本操作:

  * 解引用(Dereferencing): 使用`*`操作符来访问迭代器所指向的元素.
    ```cpp
    std::vector<int> v = {10, 20, 30};
    auto it = v.begin();
    std::cout << *it; // 输出 10
    ```
  * 自增(Incrementing): 使用`++`操作符将迭代器移动到容器中的下一个元素.
    ```cpp
    ++it; // 现在it指向20
    std::cout << *it; // 输出 20
    ```
  * 比较(Comparison): 使用`==`和`!=`来检查两个迭代器是否指向同一个位置. 这对于循环的终止条件至关重要.

### `begin()` 和 `end()`

每个标准库容器都提供两个重要的成员函数来获取迭代器:

  * `begin()`: 返回一个指向容器中第一个元素的迭代器.
  * `end()`: 返回一个指向容器\*\*尾端后一个位置(past-the-end)\*\*的迭代器. 这个迭代器本身并不指向任何有效元素, 它只是一个标记, 表示遍历已经结束.

`end()`是循环的停止标志, 永远不要尝试解引用`end()`迭代器.

### 使用迭代器遍历容器

这是迭代器最常见的用法.

```cpp
#include <iostream>
#include <vector>
#include <map>

int main() {
    std::vector<int> vec = {1, 2, 3, 4, 5};

    // C++98/03 传统方式
    for (std::vector<int>::iterator it = vec.begin(); it != vec.end(); ++it) {
        std::cout << *it << " ";
    }
    std::cout << std::endl; // 输出: 1 2 3 4 5

    // C++11及以后, 使用auto简化类型声明
    for (auto it = vec.begin(); it != vec.end(); ++it) {
        *it *= 2; // 也可以通过迭代器修改元素
    }

    // C++11及以后, 使用范围for循环 (这是语法糖, 内部仍然使用迭代器)
    for (const auto& elem : vec) {
        std::cout << elem << " ";
    }
    std::cout << std::endl; // 输出: 2 4 6 8 10

    return 0;
}
```

### 迭代器的种类

C++根据迭代器的能力将其分为五类. 算法可以根据其需要的最低能力来指定接受哪种迭代器.

1.  输入迭代器 (Input Iterator): 最基本, 只读, 只能向前移动, 只能单遍扫描 (一旦`++`后, 旧的迭代器可能失效). 例如, 从`std::cin`读取数据.
2.  输出迭代器 (Output Iterator): 只写, 只能向前移动, 只能单遍扫描. 例如, 向`std::cout`写入数据.
3.  前向迭代器 (Forward Iterator): 结合了输入和输出的能力, 可读可写, 只能向前移动, 但可以多遍扫描. `std::forward_list`的迭代器就是这种.
4.  双向迭代器 (Bidirectional Iterator): 在前向迭代器的基础上, 增加了向后移动的能力(支持`--`操作符). `std::list`, `std::set`, `std::map`的迭代器是这种.
5.  随机访问迭代器 (Random Access Iterator): 最强大, 拥有指针的所有算术运算能力, 包括`it + n` (向前移动n步), `it - n` (向后移动n步), `it[n]` (访问第n个元素), 以及`it2 - it1` (计算两个迭代器之间的距离). `std::vector`, `std::deque`和普通C风格数组的指针都是这种.

### 其他重要概念

  * `const_iterator`: 一种只读迭代器. `*it`返回的是一个常量引用, 你不能通过它来修改元素的值. 容器提供`cbegin()`和`cend()`来专门获取`const_iterator`.
  * 反向迭代器 (`reverse_iterator`): 通过`rbegin()`(指向最后一个元素)和`rend()`(指向第一个元素之前的位置)获得, `++`操作会使其在容器中向后移动.
  * 迭代器失效 (Iterator Invalidation): 当对容器进行某些操作(如在`std::vector`中间插入或删除元素)时, 可能会导致原有的迭代器, 指针和引用失效. 这是一个常见的bug来源, 使用时需要特别小心, 并查阅文档了解何种操作会导致迭代器失效.

总之, 迭代器是C++标准库的基石之一, 它解耦了算法和数据结构, 是泛型编程思想的完美体现.