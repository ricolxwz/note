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

    `std::begin`和`std::end`是C++标准库中的函数模板, 用于获取容器的开始和结束迭代器. 迭代器是C++ STL中用于遍历容器的对象, 类似于Python中的迭代器. `std::begin`返回一个指向容器第一个元素的迭代器, 而`std::end`返回一个指向容器最后一个元素之后的位置的迭代器. 这两个函数可以用于任何支持范围的容器, 包括数组, `std::vector`, `std::list`等.

    !!! note "函数模板"

        函数模板是C++中的一种强大特性, 允许你编写一个函数, 该函数可以接受不同类型的参数. 当你调用这个函数时, 编译器会根据传入的参数类型自动生成相应的函数实例. 这使得代码更加灵活和可重用. 在上面的例子中, `std::begin`和`std::end`都是函数模板, 它们可以接受任何类型的容器作为参数.

    !!! note "迭代器"

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

`std::array`是C++11引入的容器, 用于封装一个固定大小的数组. 它在行为上像一个STL容器, 但其性能和内存布局与C风格的静态数组完全相同. 在现代C++编程中, 推荐使用`std::array`替代C风格数组, 主要原因在于`std::array`提供了更高的安全性和便利性, 同时没有性能损失.

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

* STL容器接口: `std::array`提供了与其它STL容器 (如`std::vector`) 一致的接口, 例如:
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

    在range循环中, 程序首先会从`myVector`中取出第一个元素的值`1`, 将其拷贝作为一个副本赋值给`elem`, 然后, `myVector.erase`修改的是`myVector`, 删除了其中的`1`, 但是由于`elem`是一个副本, 所以第一次输出的还是`1`. **range循环的底层是由迭代器实现的**, 循环结束后, 迭代器要进行++, 由于此时的`myVector`是`{2, 3, 4}`, 所以移动了`3`上面, 将`3`拷贝作为一个副本赋值给`elem`, 第二次循环结束后, 迭代器继续++, 此时的`myVector`是`{3, 4}`, 迭代器指向的是一块未知的内存, 在上面这种情况下, 由于这块内存原先是`4`, 所以大概率没有经过修改, 所以输出还是4; 第4次循环, `myVector`是`{4}`, 同样的, 迭代器指向的也是位置的内存, 但是由于原先是`4`, 所以输出还是4.

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

`std::deque`(双端队列)是 C++ 标准模板库(STL)中的动态数组容器,支持在**头部和尾部高效插入/删除元素**(时间复杂度 O(1)).与 `std::vector` 相比,它在头部操作更高效;与 `std::list` 相比,它支持随机访问.以下是核心用法和示例:

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

