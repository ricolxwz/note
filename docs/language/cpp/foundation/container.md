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