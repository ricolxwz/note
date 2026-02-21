---
title: 类型
comments: true
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

> 所以, 右值引用到底是怎么发挥它的效果的呢? 我认为如果一个函数传入的是右值引用, 这就相当于告诉我们这个参数是一个临时对象, 可以直接抢占它的资源, 或者随意玩弄它, 这也就是为什么右值引用会被用于资源/句柄的转移. 这样, 如果在代码中调用这个函数之后还有100完行代码, 这个可恶的临时对象就不会一直占着坑位, 浪费内存资源, 我们要在函数中榨干它. 推荐阅读对象里面的"移动构造函数和移动赋值操作符"一小节, 里面有一个很有趣的例子.


## `const`的用法

1. 创建只读的变量: `const int x = 10;`
2. 创建只读的函数参数: `void func(const int x);`, 在拷贝构造函数中`UDT(const UDT& rhs)`, 这个`const`使我们不仅能接受左值, 还可以接受右值(见上面的左值右值部分).
3. 作为一种成员函数修饰符: `void func() const;`, 这意味着这个函数不会修改类的成员变量
4. `const int *var` 表示指针可变但所指整数不可通过它修改; `int * const var` 表示指针自身不可变但所指整数可通过它修改; 而 `const int * const var` 则表示指针不可变且所指整数也不可通过它修改

## `decltype`的用法

```cpp
#include <iostream>
#include <string>
#include <vector>

int main() {
    int i = 10;
    decltype(i) j = 20; // j 的类型是 int

    double x = 3.14;
    decltype(x) y = 2.71; // y 的类型是 double

    std::string s = "hello";
    decltype(s) t = "world"; // t 的类型是 std::string

    decltype(i + x) k; // k 的类型是 double, 因为 i (int) + x (double) 的结果是 double

    std::cout << "j: " << j << std::endl;
    std::cout << "y: " << y << std::endl;
    std::cout << "t: " << t << std::endl;
    // std::cout << "k: " << k << std::endl; // k 未初始化, 输出其值是未定义行为

    std::vector<int> vec = {1, 2, 3};
    decltype(vec[0]) first_element_ref = vec[0]; // first_element_ref 的类型是 int& (引用)
    first_element_ref = 100; // 修改 vec[0] 的值

    std::cout << "vec[0]: " << vec[0] << std::endl; // 输出 100

    const int ci = 5;
    decltype(ci) cj = 15; // cj 的类型是 const int

    return 0;
}
```

在这个例子里:

1.  `decltype(i)` 推断出 `i` 的类型是 `int`, 所以 `j` 也是 `int`.
2.  `decltype(i + x)` 推断出表达式 `i + x` 的结果类型是 `double`, 所以 `k` 是 `double`.
3.  `decltype(vec[0])` 推断出 `vec[0]` (访问 `std::vector` 元素) 的类型是 `int&` (对 `int` 的引用).
4.  `decltype(ci)` 推断出 `ci` 的类型是 `const int`, 所以 `cj` 也是 `const int`.

## `union`的用法

在C++中, `union`是一种特殊的数据结构, 它允许在相同的内存位置存储不同的数据类型. 但在任何时候, 只有一个成员可以包含值. 在`union`中, 所有成员共享同一块内存空间. 并且, 你只能同时使用`union`中的一个成员, 给一个成员赋值会覆盖其他成员的值. 它的大小取决于最大成员的大小.

```cpp
#include <iostream>

union U {
    int i;
    short s;
    float f;

    void printi() {
        std::cout << i << std::endl;
    }
};

int main() {
    U myUnion;
    myUnion.i = 50253;
    std::cout << "Integer value: " << myUnion.i << std::endl;
    std::cout << "Short value: " << myUnion.s << std::endl;
    std::cout << "size of union: " << sizeof(myUnion) << " bytes" << std::endl;
    myUnion.printi();
    return 0;
}
```

输出:

```bash
Integer value: 50253
Short value: -15283
size of union: 4 bytes
50253
```

为什么要用`union`呢? 举个例子, 看SDL_Event这个union(它是用C实现的, 所以有`typedef`):

```c
typedef union SDL_Event
{
    Uint32 type;                            /< Event type, shared with all events */
    SDL_CommonEvent common;                 /< Common event data */
    SDL_DisplayEvent display;               /< Display event data */
    SDL_WindowEvent window;                 /< Window event data */
    SDL_KeyboardEvent key;                  /< Keyboard event data */
    SDL_TextEditingEvent edit;              /< Text editing event data */
    SDL_TextEditingExtEvent editExt;        /< Extended text editing event data */
    SDL_TextInputEvent text;                /< Text input event data */
    SDL_MouseMotionEvent motion;            /< Mouse motion event data */
    SDL_MouseButtonEvent button;            /< Mouse button event data */
    SDL_MouseWheelEvent wheel;              /< Mouse wheel event data */
    SDL_JoyAxisEvent jaxis;                 /< Joystick axis event data */
    SDL_JoyBallEvent jball;                 /< Joystick ball event data */
    SDL_JoyHatEvent jhat;                   /< Joystick hat event data */
    SDL_JoyButtonEvent jbutton;             /< Joystick button event data */
    SDL_JoyDeviceEvent jdevice;             /< Joystick device change event data */
    SDL_JoyBatteryEvent jbattery;           /< Joystick battery event data */
    SDL_ControllerAxisEvent caxis;          /< Game Controller axis event data */
    SDL_ControllerButtonEvent cbutton;      /< Game Controller button event data */
    SDL_ControllerDeviceEvent cdevice;      /< Game Controller device event data */
    SDL_ControllerTouchpadEvent ctouchpad;  /< Game Controller touchpad event data */
    SDL_ControllerSensorEvent csensor;      /< Game Controller sensor event data */
    SDL_AudioDeviceEvent adevice;           /< Audio device event data */
    SDL_SensorEvent sensor;                 /< Sensor event data */
    SDL_QuitEvent quit;                     /< Quit request event data */
    SDL_UserEvent user;                     /< Custom event data */
    SDL_SysWMEvent syswm;                   /< System dependent window event data */
    SDL_TouchFingerEvent tfinger;           /< Touch finger event data */
    SDL_MultiGestureEvent mgesture;         /< Gesture event data */
    SDL_DollarGestureEvent dgesture;        /< Gesture event data */
    SDL_DropEvent drop;                     /< Drag and drop event data */

    /* This is necessary for ABI compatibility between Visual C++ and GCC.
       Visual C++ will respect the push pack pragma and use 52 bytes (size of
       SDL_TextEditingEvent, the largest structure for 32-bit and 64-bit
       architectures) for this union, and GCC will use the alignment of the
       largest datatype within the union, which is 8 bytes on 64-bit
       architectures.

       So... we'll add padding to force the size to be 56 bytes for both.

       On architectures where pointers are 16 bytes, this needs rounding up to
       the next multiple of 16, 64, and on architectures where pointers are
       even larger the size of SDL_UserEvent will dominate as being 3 pointers.
    */
    Uint8 padding[sizeof(void *) <= 8 ? 56 : sizeof(void *) == 16 ? 64 : 3 * sizeof(void *)];
} SDL_Event;
```

可以看到, 如果我们创建一个非`union`的`SDL_Event`, 那么我们就需要给这么多这么多的变量分配内存, 而实际情况是, 由于实际上我们每一时刻仅仅会使用其中的一个变量, 所以需要使用`union`来节省空间.

### `std::variant`

`std::variant`是C++17引入的一个非常有用的特性, 它是一个类型安全的`union`. 它可以在任何时候持有其预定义类型列表中的一个值. 在声明`std::variant`的时候, 你必须指定它可以持有的所有可能类型, 例如`std::variant<int, double, std::string>`, 这个`v`可以持有`int`, `double`, 或者`std::string`. 访问值的方法一般由两种:

1. `std::get<T>v`: 如果`v`当前持有类型`T`的值, 则返回该值的引用, 如果`v`不持有类型`T`的值, 则会抛出`std::bad_variant_access`异常
2. `std::get<I>v`: 如果`v`当前持有第`I`个备选类型(索引从0开始)的值, 则返回该值的引用, 否则抛出`std::bad_variant_access`异常

那么, 它的类型安全是啥意思呢?

```cpp
union MyUnion {
    int i;
    double d;
};
MyUnion u;
u.i = 10;
// double value = u.d; // 编译通过, 但这是未定义行为, value可能是垃圾值
```

但是对于`std::variant`:

```cpp
std::variant<int, double> v;
v = 10; // v 现在持有 int
// double d = std::get<double>(v); // 会抛出 std::bad_variant_access 异常
// int i = std::get<int>(v);     // 正确, i 的值为 10
```

另外, 你会发现相同情况下, `std::variant`的内存占用比`union`要大:

```cpp
#include <iostream>
#include <variant>

union U {
    int i;
    float s;
};

int main() {
    std::variant<int, float> data;
    std::cout << "U: " << sizeof(U) << std::endl;
    std::cout << "data: " << sizeof(data) << std::endl;
    return 0;
}
```

使用C++17编译之后, 发现:

```bash
U: 4
data: 8
```

为啥呢? 这是因为`std::variant`会和最大的类型对齐(`float`, 4个字节), 然后用一些额外的空间存储当前类型的tag, 由于要和最大的类型对齐, 所以用于存储tag的空间是4个字节, 所以加起来总共8个字节. 这就是为啥`std::variant`又被称为tagged union.

还有另一个点是`std:get_if`的使用. 它的主要作用是, 在不抛出异常的情况下(上面的`std::bad_variant_access`), 尝试获取`std::variant`中特定类型的值的指针. `std::get_if<T>(&v)`会检查`std::variant`对象`v`是否持有类型为`T`的值. 如果`v`确实持有类型为`T`的值, `std::get_if`会返回一个指向该值的指针. 如果`v`不持有类型为`T`的值, `std::get_if`会返回`nullptr`. 它和`std::get`的主要区别是, `std::get<T>(v)`在类型不匹配的时候会抛出`std::bad_variant_access`异常, 而`std::get_if`则通过返回`nullptr`来表示类型不匹配或者值不存在, 使得你可以使用更加平和的方式(如`if`语句检查指针)来处理这种情况.

## `constexpr`的用法

constexpr是C++11引入的关键字. 它用于声明可以在编译时求值的常量表达式.

具体来说, constexpr可以用于以下几个方面:

1.  constexpr变量: 声明的变量必须在编译时初始化, 且其值在整个程序运行期间保持不变. 初始化的表达式只能包含字面值, constexpr变量和constexpr函数. 例如:

    ```c++
    constexpr int max_size = 100 + 5;
    constexpr double pi = 3.14159 + 0.001;
    ```

2.  constexpr函数: 声明的函数如果其参数也是常量表达式, 则可以在编译时被求值. constexpr函数必须满足一些限制, 例如函数体只能包含return语句, 空语句和constexpr声明等. 例如:

    ```c++
    constexpr int square(int n) {
        return n * n;
    }

    int main() {
        constexpr int result = square(5); // result在编译时被计算为25
        int x = 2;
        // int runtime_result = square(x); // 可以在运行时计算
    }
    ```

3.  constexpr构造函数: 声明的构造函数可以用于创建constexpr对象. constexpr类的所有成员都必须是字面值类型, 并且构造函数的函数体必须为空. 例如:

    ```c++
    struct Point {
        constexpr Point(double x_val, double y_val) : x(x_val), y(y_val) {}
        double x;
        double y;
    };

    constexpr Point origin(0.0, 0.0);
    ```

使用 constexpr 的原因有很多, 主要包括以下几点:

1. 性能优化: constexpr 允许在编译时计算表达式的值. 这意味着在程序运行时, 这些值已经是预先计算好的, 避免了运行时的计算开销, 从而提高了程序的性能.
2. 编译时检查: constexpr 函数和变量的值在编译时确定, 编译器可以对它们进行更严格的类型检查和错误诊断. 这有助于在程序运行之前发现潜在的错误.
3. 定义常量: constexpr 可以用来定义真正的常量, 这些常量可以用于模板参数, 数组大小, 枚举值等需要在编译时确定的地方. 这增强了代码的灵活性和可读性.
4. 更好的代码可读性和可维护性: 通过使用 constexpr, 可以将一些计算逻辑放在编译时进行, 使得代码更加清晰, 易于理解和维护.
5. 在模板编程中的应用: constexpr 函数可以作为模板参数的非类型参数, 从而实现更强大的模板元编程.

简单来说, constexpr 的核心优势在于将计算从运行时提前到编译时, 从而提升性能, 增强类型安全, 并使代码更具表达力. 其实template也是在编译的时候起作用的.

## `auto`的用法

在C++中, `auto`关键字主要用于类型推导. 它允许你在声明变量时不必显式指定其类型, 而是让编译器根据初始化表达式自动推断出变量的类型. 自C++11标准引入以来,`auto`的主要作用体现在以下几个方面:

1.  简化代码, 提高可读性: 当变量的类型很长或很明显时, 使用`auto`可以减少代码的冗余, 使代码更简洁易懂. 例如:
    ```cpp
    std::vector<std::pair<std::string, int>> my_vector;
    // 不使用 auto
    std::vector<std::pair<std::string, int>>::iterator it = my_vector.begin();
    // 使用 auto
    auto it = my_vector.begin();
    for (it; my_vector.end(); it++) {
        ...
    }
    ```
    在上面的例子中, 使用`auto`可以避免写出冗长的迭代器类型.

2.  处理复杂类型: 对于一些难以书写或名称复杂的类型 (例如 lambda 表达式的类型),`auto`非常有用. 你不需要知道或显式写出 lambda 表达式的具体类型.
    ```cpp
    // lambda 表达式
    auto my_lambda = [](int x) { return x * 2; };
    ```

3.  泛型编程: 在模板编程中,`auto`可以方便地处理依赖于模板参数的类型.
    ```cpp
    template <typename T, typename U>
    auto add(T t, U u) -> decltype(t + u) {
        return t + u;
    }
    ```
    虽然上面的例子使用了尾置返回类型(使用`decltype`自动推导), 但在 C++14 中, 函数的返回类型也可以直接使用`auto`让编译器推导.

4.  避免类型不匹配: 有时, 表达式的类型可能很复杂或容易出错, 使用`auto`可以确保变量的类型与初始化表达式的类型完全一致, 从而避免潜在的类型不匹配问题.

需要注意的是:

* 使用`auto`声明的变量必须进行初始化, 因为编译器需要根据初始化表达式来推导类型.
* `auto`不是一个占位符, 它会根据初始化表达式推导出一个确切的类型.
* `auto`不能用于函数参数的类型 (C++14 中 lambda 表达式的参数可以使用 `auto`).
* `auto`可以和引用(`&`)或指针(`*`)结合使用. 例如: `auto& ref = variable;` 或`auto* ptr = &variable;`.
* `auto`会忽略初始化表达式的顶层 `const`和`volatile`限定符, 但如果需要保留这些限定符, 可以显式地添加, 例如`const auto`或`volatile auto`. 对于引用类型, `const`会被保留.

## 类型转换

在C++中, "casting"(类型转换) 是指将一个数据类型的值转换为另一个数据类型的过程. 这在需要不同类型的数据进行操作或交互时非常有用. 类型转换主要分为隐式转换和显示转换.

1. 隐式转换

    记起来类那一节讲到的`explicit`关键字吗? 它的作用就是防止隐式地类型转换, 例如`MyString s1 = 10`; 如果构造函数前面有`explicit`, 那么会报错, 因为将`10`隐式转换为了`MyString`对象. 必须显式地写成例如`MyString s1{10};`才行. 隐式转换是由编译器自动完成的, 通常发生在安全且无信息丢失风险的情况下, 例如将较小的整数类型转换为较大的整数类型, 或将派生对象转换为其基类指针或者引用.

2. 显式转换

    需要程序员明确指定要进行的转换, 用于可能存在信息丢失或者类型不兼容风的情况, C++提供了4种命名的强制类型转换操作符, `static_cast`, `dynamic_cast`, `reinterpret_cast`, `const_cast`. 下面将会一一展开.

### C风格转换

看这个例子:

```cpp
#include <iostream>

int main() {
    std::cout << 7/5 << std::endl;
    return 0;
}
```

输出:

```bash
1
```

这是因为`7`是`long`, `7`是`long`, `5`是`int`, 所以`7/5`的结果是`long/long`, 结果是`1`. 如果我们想要得到`1.4`, 那么就需要将至少其中一个数转换为浮点数, 例如:

```cpp
#include <iostream>

int main() {
    std::cout << float(7)/5 << std::endl; // C风格的类型转换
    return 0;
}
```

输出:

```bash
1.4
```

再来看下面的这个例子:

```cpp
#include <iostream>

int main() {
    int result = 50000;
    short c = result;
    std::cout << c << std::endl;
    std::cout << sizeof(result) << std::endl>>
    std::cout << sizeof(c) << std:;endl;
    return 0;
}
```

输出:

```
-15536
4
2
```

你会发现, 咦, 为啥不是5000, 这是因为`int`的大小是4字节, 但是`short`的大小是2字节, 我们进行了隐式类型转换, 中间损失了两个字节.

C风格的转换会尝试显式转换, 直到找到一个可以成功还行的转换. 它的行为可以被理解为尝试以下C++转换, 大致按照顺序进行: 1.`const_cast`, 2.`static_cast`, 3.`reinterpret_cast`. 因此, C风格类型的转换功能非常强大, 但也因此不安全, 它会尝试"最不坏"的转换, 但可能不是程序员真正想要的, 强烈建议在C++代码中优先使用C++命名的转换, 因为它们更加明确, 更加安全.

### 比较

在不同的两个类型进行比较前, 编译器会自动对它们进行隐式类型转换, 已使它们具有相同的类型, 然后再进行比较. 所以在这个过程中, 可能会产生一些问题, 例如:

```cpp
#include <iostream>

int main() {
    int i = -2;
    unsigned int u = 1;
    if (i > u) {
        std::cout << "huh?" << std::endl;
    }
    return 0;
}
```

输出:

```
huh?
```

可以看到, 这里即便`i`是-2, 但是结果是`i`比`u`大. 对于这种情况, 我们大概有两种方法:

1. 使用`-Wall`选项: 在编译的时候, 我们可以加上`-Wall`选项, 例如`g++ -Wall my_program.cpp`, 因为当你使用这个命令编译代码的时候, 编译器会像一个严格的代码审核员, 对你的代码进行更加深入的静态分析, 并报告它发现出的各种潜在问题.
2. 使用`std::cmp_greater`进行比较.

### `static_cast`

`static_cast`是 C++ 提供的四种主要转换运算符之一, 用于在编译时进行已知安全的类型转换. 它会在编译阶段根据类型信息执行相应转换, 不会进行运行时检查.

#### 数值类型转型

常见用法有: 数值类型之间转换, 如 double 转 int:

```cpp
int x = static_cast<int>(3.14);
```

#### 实体类型转型

实体类型转换是指将一个类的实体对象按照继承链转为另一个类的实体对象. 分为两种, 一种是上转型(up casting), 一种是下转型(down casting). 上转型是指将派生对象转换为基类对象, 下转型是指将基类对象转换为派生类对象.

1. 下转型: 编译直接报错, 不允许
2. 上转型: 会发生对象切片, 只保留基类对象的部分, 派生类的部分会被丢弃.

#### 指针类型转型

指针类型转换是指将一个类的指针按照继承链转为另一个类的指针. 分为两种, 一种是上转型(up casting), 一种是下转型(down casting). 上转型是指将派生对象指针转换为基类对象指针, 下转型是指将基类对象指针转换为派生类对象指针.

1. 下转型: 编译的时候允许, 但是运行的时候不安全. 可能导致未定义行为, 见`dynamic_cast`部分
2. 上转型: 编译和运行都安全, 不会发生切片

### `dynamic_cast`

!!! warning "注意"

    `dynamic_cast`仅仅可以用于:

    * 至少有一个虚函数的类
    * 指针类型转换, 实体类型转型不适用, 数值类型转型不适用

!!! tip "指针类型上转型"

    指针类型上转型通常采用`static_cast`进行, 因为`dynamic_cast`在运行的时候会做额外的类型检查, 性能上更加耗费, 而上转型在运行时是安全的, 所以没必要用`dynanmic_cast`.

#### 指针类型下转型

`static_cast`仅仅在编译期间进行类转换, 不会在运行的时候检查实际对象类型. `dynamic_cast`会通过RTTI(Run Time Type Information)检查对象的类型, 类似于Java的反射. 通常用于将基类的指针转为派生类的指针(down casting). 如果对象不是`derived`会返回`nullptr`, 如果对象是``derived`会返回指向派生类的指针. 那么, 为什么不直接使用`static_cast`进行down casting呢? 来看下面的这个例子:

```cpp
#include <iostream>
using namespace std;

class Base {
public:
    virtual ~Base() {}
};

class Derived: public Base {
public:
    void doDerived() {
        cout<<"Called Derived method"<<endl;
    }
};

class AnotherDerived: public Base {
public:
    void doAnother() {
        cout<<"Called AnotherDerived method"<<endl;
    }
};

void process(Base* ptr) {
    // 尝试使用static_cast将Base*转换为Derived*
    Derived* d1 = static_cast<Derived*>(ptr);
    // 如果ptr实际指向AnotherDerived, 以下调用会导致未定义行为
    d1->doDerived(); // 可能崩溃

    // 使用dynamic_cast更安全
    Derived* d2 = dynamic_cast<Derived*>(ptr);
    if(d2) {
        d2->doDerived();
    } else {
        cout<<"ptr不指向Derived, 转换失败"<<endl;
    }
}

int main() {
    Base* obj1 = new Derived();
    Base* obj2 = new AnotherDerived();

    process(obj1); // obj1实际指向Derived, 都能正常调用
    process(obj2); // obj2实际指向AnotherDerived, static_cast编译通过但在运行时调用doDerived未定义, dynamic_cast返回nullptr
    delete obj1;
    delete obj2;
    return 0;
}
```

你会发现, `static_cast`无论`ptr`是否指向`Derived`实例, 都会执行转换, 但是如果`ptr`指向其他类型, 然后你调用了其他类型的成员函数, 如`d1->doDerived()`, 这会导致未定义行为. `dynamic_cast`则会在运行时检查类型, 如果转换失败, 返回`nullptr`, 否则返回有效指针, 这样的转换更加安全. 这就是为啥`static_cast`通常用于up casting(将派生类指针转换为基类指针), 而`dynamic_cast`通常用于down casting(将基类指针转换为派生类指针).

总结来说, 如果想要`dynamic_cast`返回一个有效的指针, 需要`<>`里面的指针类型和`ptr` `new`的那个类型一致, 也就是说, 转换之后要能够调用`new`的那个类型的所有成员函数, 否则返回的是`nullptr`.

### `reinterpret_cast`

`reinterpret_cast是C++`中一种非常底层的类型转换运算符. 它允许将任何指针类型转换为任何其他指针类型.

```cpp
#include <iostream>

int main() {
    float pi = 3.14f;
    std::cout << &(pi) << std::endl;
    std::cout << reinterpret_cast<int*>(&pi) << std::endl;
    std::cout << reinterpret_cast<float*>(&pi) << std::endl;
    std::cout << *reinterpret_cast<int*>(&pi) << std::endl;
    std::cout << *reinterpret_cast<float*>(&pi) << std::endl;
    return 0;
}
```

输出:

```bash
0x7ffecd8dc924
0x7ffecd8dc924
0x7ffecd8dc924
1078523331
3.14
```

你会发现, 尽管他们的地址都是相同的, 但是存储的值却截然不同. 当通过`*reinterpret_cast<int*>(&pi)`访问时, 存储浮点数`3.14f`的内存位模式被当作整数解析, 得到了`1078523331`. 而通过`*reinterpret_cast<float*>(&pi)`访问时, 同样的位模式被正确解析为浮点数`3.14`.

这清晰地展示了`reinterpret_cast`的核心作用: 它不改变实际存储的二进制数据, 仅改变编译器如何解释这些数据对应的类型. 浮点数 (例如遵循IEEE 754标准) 与整数在内存中的二进制表示方式有本质区别. 因此, 同一段二进制码, 在不同的类型视角下会呈现出不同的数值.

那么, 什么时候用`interpret_cast`呢?

```cpp
#include <iostream>
#include <cstring>

struct GameState {
    int level;
    int health;
    int points;
    bool GameComplete;
    bool BossDefeated;
};

int main() {
    GameState gs = {66, 100, 999, false, false};
    std::cout << sizeof(GameState) << std::endl << std::endl;
    char bagOfbytes[sizeof(GameState)];  // 假设这是一个文件, 我们要往里面写入GameState(即序列化)
    std::memcpy(bagOfbytes, &gs, sizeof(GameState));  // 将GameState的内容复制到bagOfbytes中
    // 现在, 我们要从文件中读取内容
    std::cout << *reinterpret_cast<int*>(bagOfbytes) << std::endl;
    std::cout << *reinterpret_cast<int*>(bagOfbytes + 4) << std::endl;
    std::cout << *reinterpret_cast<int*>(bagOfbytes + 8) << std::endl;
    std::cout << *reinterpret_cast<bool*>(bagOfbytes + 12) << std::endl;
    std::cout << *reinterpret_cast<bool*>(bagOfbytes + 13) << std::endl;
    return 0;
}
```

上面的`GameState`成员变量在内存中的分布为: level(4字节), health(4字节), points(4字节), GameComplete(1字节), BossDefeated(1字节), 由于最大的成员变量占用4个字节, 所以另外还有2个字节的padding, 所以整个`GameState`结构体占用16个字节.

输出:

```bash
16

66
100
999
0
0
```

### 类型双关

Type punning 指的是通过某种技术让一段内存中的二进制数据可以被当作多种不同类型来解释或访问. 它的本质是绕过C++的静态类型系统, 直接操作底层的数据位 (bits), 告诉编译器: "别管这里原来是什么类型, 现在就把它当作另一种类型来处理". 它的主要动机是性能和底层操作. 在某些场景下, 我们需要:

1.  低级数据转换: 例如, 将一个`float`的二进制表示提取为一个`uint32_t`来检查它的指数位或符号位.
2.  序列化/反序列化: 在网络编程或文件IO中, 将一个对象 (如 `struct`) 的内存块直接转换为一个字节流 (`char*` 或 `std::byte*`) 来发送或写入, 反之亦然.
3.  硬件交互: 与硬件寄存器交互时, 可能需要将一个整数写入特定地址, 而这个地址在代码中被当作一个结构体指针.

C++有一个非常重要的规则叫做严格别名规则. 这条规则规定, 如果你有一个类型为`T`的对象, 你不能随意地通过一个类型为`U`的指针 (`U*`) 去访问它 (除非`U`和`T`是兼容的类型, 如`char*`或`std::byte*`). 如果违反了这个规则, 编译器会认为这两种类型的指针指向不同的内存位置. 为了优化, 编译器可能会自由地重排代码的读写顺序, 最终导致完全意想不到的程序行为. 因此, 大多数传统的 type punning 方法 (如下面提到的) 都会导致未定义行为 (Undefined Behavior, UB). 简单来说: 随便用`reinterpret_cast`或`union`来进行类型双关, 代码很可能会在某些编译器或优化级别下悄无声息地出错.

正确的方式: `std::bit_cast` (C++20). 为了提供一种安全、标准的 type punning 方法, C++20引入了 `std::bit_cast`. `std::bit_cast` 的作用是将一个对象底层的二进制表示原封不动地复制到另一个不同类型的对象中. 它就像一个安全的, 编译期版本的`memcpy`. 使用要求:

- 源类型和目标类型必须大小相同.
- 必须都是可平凡复制 (TriviallyCopyable) 的类型 (例如, 没有虚函数的简单`struct`/`class`, 以及基本数据类型).

示例:

```cpp
#include <iostream>
#include <bit> // 必须包含 <bit>
#include <cstdint>

int main() {
    float f = 3.14159f;

    // 安全地将 float 的位模式转换为 uint32_t
    // 这不会违反严格别名规则
    uint32_t u = std::bit_cast<uint32_t>(f);

    std::cout << "Float value: " << f << std::endl;
    std::cout << "Integer representation (hex): 0x" << std::hex << u << std::endl;

    // 同样可以安全地转换回来
    float f_again = std::bit_cast<float>(u);
    std::cout << "Float value again: " << f_again << std::endl;
}
```

`std::bit_cast`是现代C++中进行类型双关的唯一官方推荐方式.

错误的 (历史) 方式 (应避免):

1. 使用 `reinterpret_cast`

    这是最直接但最危险的方式.

    ```cpp
    // ❌ 错误: 违反严格别名规则, 属于未定义行为!
    float f = 3.14f;
    uint32_t* p_u = reinterpret_cast<uint32_t*>(&f);
    // 当你解引用 *p_u 时, UB 就会发生. 编译器可能优化掉这次读取.
    std::cout << *p_u << std::endl;
    ```

2. 使用联合体 (Union)

    这在C语言中是合法的, 但在C++中, 读取联合体中与最后一次写入的成员不同的成员, 也是未定义行为.

    ```cpp
    // ❌ 错误: 在C++中是未定义行为!
    union Converter {
        float f;
        uint32_t u;
    };

    Converter c;
    c.f = 3.14f; // 写入 float 成员
    std::cout << c.u << std::endl; // 读取 uint32_t 成员 -> UB!
    ```

## 宏

### `#define`的用法

#### 文本替换

`#define`是C++预处理器指令, 用于创建宏. 宏主要有两种形式: 类对象宏 (object-like macros) 和类函数宏 (function-like macros).

1.  类对象宏 (定义常量或符号):

    这种宏用于将一个标识符定义为一个特定的文本片段. 预处理器会在编译前将代码中所有出现的该标识符替换为指定的文本片段.

    语法:
    ```cpp
    #define 标识符 替换文本
    ```

    示例:
    ```cpp
    #define PI 3.14159
    #define GREETING "Hello, World!"
    #define MAX_USERS 100
    ```
    在预处理阶段:

    * `double circumference = 2 * PI * radius;` 会变成 `double circumference = 2 * 3.14159 * radius;`
    * `std::cout << GREETING << std::endl;` 会变成 `std::cout << "Hello, World!" << std::endl;`

    优点:

    * 可以提高代码的可读性, 用有意义的名称代替魔法数字或字符串.
    * 方便修改, 只需修改`#define`语句即可更新所有引用的地方.

    注意:

    * 替换文本可以是任何内容, 包括表达式, 但通常用于定义常量.
    * 宏定义不进行类型检查.

2.  类函数宏 (定义带参数的宏):

    这种宏看起来像函数调用, 但实际上也是文本替换. 它可以接受参数.

    语法:
    ```cpp
    #define 标识符(参数列表) 替换文本
    ```
    重要提示: 标识符和左括号`( `之间不能有空格.

    示例:
    ```cpp
    #define SQUARE(x) ((x) * (x))
    #define MAX(a, b) (((a) > (b)) ? (a) : (b))
    #define PRINT_VAR(var) std::cout << #var << " = " << var << std::endl;
    ```
    在预处理阶段:

    * `int area = SQUARE(5);` 会变成 `int area = ((5) * (5));`
    * `int larger = MAX(x + 1, y);` 会变成 `int larger = (((x + 1) > (y)) ? (x + 1) : (y));`
    * `PRINT_VAR(myVariable);` 会变成 `std::cout << "myVariable" << " = " << myVariable << std::endl;` (这里的`#var`是字符串化操作符, 会将参数名转换为字符串)

    优点:

    * 可以减少函数调用的开销 (对于非常简单的操作).
    * 可以进行一些文本操作, 如字符串化 (`#`) 和标记连接 (`##`).

    重要注意事项 (陷阱):

    * 括号: 在宏定义中, 参数和整个表达式通常需要用括号括起来, 以避免操作符优先级问题.
        例如, 如果`SQUARE(x)`定义为`x*x`, 那么`SQUARE(2+3)`会变成`2+3*2+3`, 结果是`2+6+3=11`, 而不是预期的`5*5=25`. 使用`((x)*(x))`可以避免这个问题.
    * 副作用: 如果参数带有副作用 (例如`i++`), 它们可能会被多次求值.
        例如, `int i = 3; int j = SQUARE(i++);` 可能会变成 `int j = ((i++) * (i++));`, `i`的值会增加两次, 结果可能不是预期的.
    * 类型安全: 宏不进行类型检查, 这可能导致难以发现的错误.
    * 调试: 宏会在预处理阶段被替换掉, 调试时可能看到的是替换后的代码, 这会增加调试难度.
    * 作用域: 宏定义从其定义点开始到文件末尾有效, 或者直到遇到`#undef`指令.

    ```cpp
    #define MY_VALUE 10
    // ... MY_VALUE is 10
    #undef MY_VALUE
    // ... MY_VALUE is no longer defined
    ```

尽管宏在某些情况下很有用 (例如条件编译中的标志, 非常简单的文本替换), 但在现代C++中, 对于类对象宏, 通常推荐使用`const`或`constexpr`变量, 因为它们具有类型安全且遵循作用域规则. 对于类函数宏, 通常推荐使用内联函数 (inline functions) 或模板 (templates), 它们也提供类型安全且行为更可预测.

#### 条件编译

`#define`还可以用于条件编译, 通过与`#ifdef`, `#ifndef`, `#if`, `#else`, `#elif`, `#endif`等指令结合使用, 可以根据宏是否被定义来控制代码的编译. 例如:

以下是解释和示例:

当你使用`#define`定义一个宏时, 该宏就被认为是"已定义"状态.

```cpp
#define MY_FEATURE_ENABLED
// 或者定义一个带值的宏 (尽管在条件编译中, 通常只检查是否定义)
// #define VERSION 2
```

然后, 其他预处理指令可以检查这个宏的状态:

1.  `#ifdef 标识符`: "if defined" (如果标识符已定义)
    如果`标识符`通过`#define`定义了, 那么`#ifdef`和对应的`#endif` (或`#else`/`#elif`) 之间的代码块将被编译.

    ```cpp
    #define DEBUG_MODE

    #ifdef DEBUG_MODE
      // 这部分代码只有在 DEBUG_MODE 被定义时才会被编译
      std::cout << "Debugging information..." << std::endl;
    #endif
    ```

2.  `#ifndef 标识符`: "if not defined" (如果标识符未定义)
    如果`标识符`没有通过`#define`定义, 那么`#ifndef`和对应的`#endif` (或`#else`/`#elif`) 之间的代码块将被编译. 这常用于防止头文件被多次包含 (头文件保护符).

    ```cpp
    #ifndef MY_HEADER_H
    #define MY_HEADER_H
      // 头文件内容
    #endif // MY_HEADER_H
    ```

3.  `#if 表达式`: "if expression is true"
    `#if`指令会计算后面的常量表达式. 如果表达式的结果为非零 (真), 则其后的代码块被编译. 你可以在表达式中使用通过`#define`定义的宏 (通常是代表数值的宏).

    ```cpp
    #define VERSION_NUMBER 3

    #if VERSION_NUMBER > 2
      // 这部分代码只有在 VERSION_NUMBER 大于 2 时才会被编译
      std::cout << "Using features from version 3 or later." << std::endl;
    #elif VERSION_NUMBER == 2
      std::cout << "Using features from version 2." << std::endl;
    #else
      std::cout << "Using legacy features." << std::endl;
    #endif
    ```
    也可以使用`defined(标识符)`操作符在`#if`中检查宏是否被定义:
    ```cpp
    #define FEATURE_A
    // #define FEATURE_B // FEATURE_B 未定义

    #if defined(FEATURE_A) && !defined(FEATURE_B)
      // 只有当 FEATURE_A 定义了且 FEATURE_B 未定义时, 这部分代码才会被编译
      std::cout << "Feature A is enabled, Feature B is not." << std::endl;
    #endif
    ```

!!! note "还可以通过命令行参数定义宏"

    通过编译器的命令行参数来定义宏, 进而影响`#if`, `#ifdef`等条件编译指令的行为, 是一种非常常见且强大的实践. 编译器通常提供一个选项 (例如GCC/Clang中的`-D`, MSVC中的`/D`) 来在命令行中定义宏, 就像在代码中使用了`#define`一样.

    工作原理:

    1.  在代码中: 你像之前那样使用条件编译指令.
        ```cpp
        // main.cpp
        #include <iostream>

        #ifndef BUILD_MESSAGE
        #define BUILD_MESSAGE "Default build message."
        #endif

        #ifdef SPECIAL_FEATURE
        #define FEATURE_LEVEL 2
        #else
        #define FEATURE_LEVEL 1
        #endif

        int main() {
            std::cout << BUILD_MESSAGE << std::endl;

            #if FEATURE_LEVEL > 1
                std::cout << "Special feature is enabled at level " << FEATURE_LEVEL << std::endl;
            #else
                std::cout << "Basic feature set at level " << FEATURE_LEVEL << std::endl;
            #endif

            #ifdef DEBUG_BUILD
                std::cout << "This is a debug build." << std::endl;
            #endif

            return 0;
        }
        ```

    2.  在编译时: 你可以通过命令行参数传入宏定义.

        * 定义一个宏 (不带值, 主要用于`#ifdef`或`defined()`):
            ```bash
            g++ -DSPECIAL_FEATURE main.cpp -o main_special
            g++ -DDEBUG_BUILD main.cpp -o main_debug
            ```
            在第一个命令中, `SPECIAL_FEATURE`被定义了, 所以`FEATURE_LEVEL`会被设为`2`.
            在第二个命令中, `DEBUG_BUILD`被定义了.

        * 定义一个带值的宏:
            ```bash
            g++ -DBUILD_MESSAGE="\"Custom message from command line\"" main.cpp -o main_custom_msg
            g++ -DSPECIAL_FEATURE -DFEATURE_LEVEL=3 main.cpp -o main_feature_level_3
            ```
            注意: 当宏的值是字符串时, 通常需要在命令行中额外使用引号来确保字符串被正确传递.
            在第一个命令中, `BUILD_MESSAGE`会被设为`"Custom message from command line"`.
            在第二个命令中, `SPECIAL_FEATURE`被定义, 并且`FEATURE_LEVEL`被命令行直接定义为`3`, 这会覆盖代码中 `#else` 分支的 `#define FEATURE_LEVEL 1`. (如果`SPECIAL_FEATURE`未在命令行定义, 则代码中的逻辑会生效).

    输出示例:

    * 执行 `./main_special`:
        ```
        Default build message.
        Special feature is enabled at level 2
        ```

    * 执行 `./main_debug`:
        ```
        Default build message.
        Basic feature set at level 1
        This is a debug build.
        ```

    * 执行 `./main_custom_msg`:
        ```
        Custom message from command line
        Basic feature set at level 1
        ```

    * 执行 `./main_feature_level_3`:
        ```
        Default build message.
        Special feature is enabled at level 3
        ```
总结:

`#define`用于创建这些条件编译指令赖以判断的"开关". 通过定义或取消定义不同的宏, 你可以有效地告诉预处理器哪些代码段应该包含在最终的编译单元中, 哪些应该被忽略.

常见用途:

* 平台特定代码:
    ```cpp
    #ifdef _WIN32
      // Windows特定代码
    #elif __linux__
      // Linux特定代码
    #endif
    ```
* 调试代码的启用/禁用: 如第一个`#ifdef DEBUG_MODE`示例.
* 功能切换: 根据需要启用或禁用实验性功能或可选模块.
* 头文件保护: 防止头文件被重复包含, 如`#ifndef MY_HEADER_H`示例.

通过这种方式, `#define`与条件编译指令结合, 为C++代码的灵活性和可移植性提供了强大的机制.

### `__file__`和`__line__`用法

`__FILE__`和`__LINE__`是C++中预定义的宏, 主要用于调试和日志记录.

* `__FILE__`: 一个字符串字面量, 代表当前源文件的文件名.
* `__LINE__`: 一个整型常量, 代表当前代码在源文件中的行号.

```cpp linenums="1"
#include <iostream>

void log_message(const char* message, const char* file, int line) {
    std::cerr << "Message: " << message << " at " << file << ":" << line << std::endl;
}

#define LOG(msg) log_message(msg, __FILE__, __LINE__)

int main() {
    std::cout << "This is file: " << __FILE__ << " at line: " << __LINE__ << std::endl;
    int x = 10;
    if (x > 5) {
        LOG("x is greater than 5");
    }
    return 0;
}
```

当编译并运行上述代码时:

* 第一条`std::cout`会打印出包含该语句的文件名和行号.
* `LOG("x is greater than 5");`会展开为`log_message("x is greater than 5", "your_file_name.cpp", 13);`, 从而在错误输出流中打印包含文件名和行号的日志信息.

输出:

```bash
This is file: main.cpp at line: 10
Message: x is greater than 5 at main.cpp:13
```

它们帮助定位代码中产生信息或错误的确切位置.

!!! tip "`std::source_location`的用法"

    在C++20中, `std::source_location`提供了一种更强大和灵活的方式来获取源代码位置的信息. 它可以替代`__FILE__`和`__LINE__`, 提供更多的上下文信息, 如函数名、类名等.

    使用示例:

    ```cpp linenums="1"
    #include <iostream>
    #include <source_location>

    void log_message(const char* message, const std::source_location& location = std::source_location::current()) {
        std::cerr << "Message: " << message
                  << " at " << location.file_name()
                  << ":" << location.line()
                  << " in function " << location.function_name()
                  << std::endl;
    }

    #define LOG(msg) log_message(msg)

    int main() {
        LOG("This is a log message");
        return 0;
    }
    ```

    输出:

    ```bash
    Message: This is a log message at main.cpp:15 in function int main()
    ```

## 内联变量

C++17引入了内联变量 (inline variables), 允许在头文件中定义变量 (包括全局变量和类的静态成员变量), 而不会违反"单一定义规则" (One Definition Rule, ODR).

核心要点:

1.  目的: 解决在头文件中定义全局或静态变量时可能导致的多重定义链接错误.
2.  关键字: 使用`inline`关键字.
3.  行为: 即使头文件被多个`.cpp`文件包含, `inline`变量也确保在整个程序中只有一个实例. 链接器会合并所有定义为一个.
4.  定义位置: 通常在头文件中定义.
5.  适用场景:
    * 在头文件中定义全局常量或变量.
    * 在类定义内部初始化静态成员变量 (尤其是在C++17之前这比较麻烦, 通常需要在类外定义).

示例:

在头文件 (`config.h`) 中:
```cpp
#ifndef CONFIG_H
#define CONFIG_H

#include <string>

// 内联全局变量
inline int globalMaxUsers = 100;
inline const std::string globalAppName = "MyApplication";

struct Settings {
    // 内联静态成员变量 (C++17起可以直接在类内初始化)
    inline static double version = 1.2;
    inline static const int defaultTimeout = 5000; // const static 成员C++17前也可类内初始化
};

#endif
```

在多个`.cpp`文件中使用:
```cpp
// main.cpp
#include <iostream>
#include "config.h"

int main() {
    std::cout << "App Name: " << globalAppName << std::endl;
    std::cout << "Max Users: " << globalMaxUsers << std::endl;
    globalMaxUsers = 150; // 修改的是同一个变量实例
    std::cout << "Settings Version: " << Settings::version << std::endl;
    return 0;
}
```

```cpp
// utils.cpp
#include <iostream>
#include "config.h"

void printConfig() {
    std::cout << "From utils - App Name: " << globalAppName << std::endl;
    std::cout << "From utils - Max Users: " << globalMaxUsers << std::endl; // 会看到main.cpp中修改后的值
    std::cout << "From utils - Settings Version: " << Settings::version << std::endl;
}
```

如果`config.h`被`main.cpp`和`utils.cpp`都包含, `globalMaxUsers`, `globalAppName`, `Settings::version`, 和 `Settings::defaultTimeout` 都将只有一个定义和实例在整个程序中, 避免了链接错误.

对于类的`static const`整型或枚举成员, C++17之前就可以在类内初始化. `inline`变量将此能力扩展到其他类型的静态成员变量和全局变量, 使得在头文件中管理它们更为便捷.

!!! note "如果在头文件中没有使用`inline`会怎样"

    如果你在头文件中定义一个普通的全局变量 (非`const`且没有`inline`关键字), 并且这个头文件被多个`.cpp`文件 (编译单元) 包含, 那么在链接阶段通常会导致多重定义 (multiple definition) 错误.

    原因:

    C++遵循单一定义规则 (One Definition Rule, ODR). 对于具有外部链接的实体 (如全局变量或非内联函数), 在整个程序中只能有一个定义.

    当头文件被多个`.cpp`文件`#include`时:

    1.  预处理器会将头文件的内容复制到每个包含它的`.cpp`文件中.
    2.  如果头文件中有一个变量定义, 例如 `int myGlobalVar = 100;`, 那么每个`.cpp`文件在被编译成目标文件 (`.o`或`.obj`) 时, 都会包含`myGlobalVar`的一个定义.
    3.  当链接器试图将这些目标文件链接成一个可执行程序时, 它会发现多个名为`myGlobalVar`的全局变量的定义, 这就违反了ODR.

    示例:

    `myheader.h`:
    ```cpp
    #ifndef MYHEADER_H
    #define MYHEADER_H

    // 没有inline关键字的全局变量定义
    int sharedCounter = 0;
    // 注意: 如果是 const int sharedCounter = 0; 行为会不同 (默认为内部链接)

    #endif
    ```

    `file1.cpp`:
    ```cpp
    #include "myheader.h"
    #include <iostream>

    void incrementCounter() {
        sharedCounter++;
        std::cout << "File1: " << sharedCounter << std::endl;
    }
    ```

    `file2.cpp`:
    ```cpp
    #include "myheader.h"
    #include <iostream>

    void printCounter() {
        std::cout << "File2: " << sharedCounter << std::endl;
    }

    // 假设main函数也在这里或者另一个包含myheader.h的文件中
    // int main() {
    //     incrementCounter();
    //     printCounter();
    //     return 0;
    // }
    ```

    编译和链接 (例如使用g++):
    ```bash
    g++ -c file1.cpp -o file1.o
    g++ -c file2.cpp -o file2.o
    g++ file1.o file2.o -o program
    ```

    在链接步骤 (`g++ file1.o file2.o -o program`), 你很可能会遇到类似以下的链接器错误:
    ```
    /usr/bin/ld: file2.o:(.data+0x0): multiple definition of `sharedCounter'; file1.o:(.data+0x0): first defined here
    collect2: error: ld returned 1 exit status
    ```
    这个错误明确指出`sharedCounter`被多次定义了.

    如何避免 (没有`inline`关键字的传统方法):

    1.  声明在头文件: 在头文件中使用`extern`关键字声明变量, 表示这个变量在其他地方定义.
        `myheader.h`:
        ```cpp
        #ifndef MYHEADER_H
        #define MYHEADER_H
        extern int sharedCounter; // 声明
        #endif
        ```
    2.  定义在一个源文件: 在一个且仅一个`.cpp`文件中提供该变量的实际定义.
        `file1.cpp` (或其他某个.cpp文件):
        ```cpp
        #include "myheader.h"
        int sharedCounter = 0; // 定义
        // ... rest of file1.cpp
        ```

    C++17的`inline`变量简化了这个过程, 允许你直接在头文件中定义变量, 而编译器/链接器会确保只有一个实例存在, 避免了上述的多重定义问题.

    特例: `const`全局变量
    如果全局变量在头文件中被声明为`const` (例如 `const int MAX_VALUE = 10;`), 它默认具有内部链接 (internal linkage). 这意味着每个包含该头文件的编译单元都会有它自己的独立副本, 并且不会导致链接错误. 但它们不是同一个变量实例. 如果你需要一个所有编译单元共享的`const`变量实例, 你会使用`extern const`声明并结合一个`.cpp`文件中的定义, 或者自C++17起使用`inline const`.

## `size_t`的用法

`size_t`是一个无符号类型, 它的具体大小(位数)是和平台相关的, 在32位系统上, 通常是32位无符号整数而在64位系统上, 通常是64位无符号整数. 这种设计确保了`size_t`足够大, 能够存储任何理论上可能存在的对象的大小. 所以, 为什么要使用`size_t`呢?

1. 避免循环中的负数和溢出


    ```cpp
    #include <iostream>
    #include <vector>
    #include <limits> // 用于检查max()

    int main() {
        std::vector<int> myVector;
        // 假设myVector被填充了大量元素 甚至超过20亿个

        // 错误示例: 使用int作为循环变量
        // 如果myVector.size()超过INT_MAX(大约20亿) 这个循环会产生错误行为或溢出
        // for (int i = 0; i < myVector.size(); ++i) {
        //     // ...
        // }

        // 正确示例: 使用size_t作为循环变量
        // size_t可以处理非常大的尺寸 即使myVector有数十亿个元素也能正常工作
        for (size_t i = 0; i < myVector.size(); ++i) {
            // 访问元素 myVector[i]
        }

        std::cout << "Maximum value of int: " << std::numeric_limits<int>::max() << std::endl;
        std::cout << "Maximum value of size_t: " << std::numeric_limits<size_t>::max() << std::endl;
        // 你会发现size_t的最大值远大于int的最大值
        // 在64位系统上 size_t的最大值大约是1.8e19
        // 在32位系统上 size_t的最大值大约是4.2e9 (也大于int的2.1e9)

        return 0;
    }
    ```

2. 处理`sizeof`运算符的返回值

    ```cpp
    #include <iostream>

    int main() {
        int arr[] = {1, 2, 3, 4, 5};
        size_t arrayBytes = sizeof(arr); // arr占用的总字节数
        size_t elementBytes = sizeof(arr[0]); // 单个元素占用的字节数

        size_t numberOfElements = arrayBytes / elementBytes;

        std::cout << "Array total bytes: " << arrayBytes << std::endl;
        std::cout << "Element bytes: " << elementBytes << std::endl;
        std::cout << "Number of elements: " << numberOfElements << std::endl; // 输出 5

        return 0;
    }
    ```

3. 在字符串和向量操作中使用

    ```cpp
    #include <iostream>
    #include <string>
    #include <vector>

    int main() {
        std::string text = "Hello world";
        // length()和size()都返回size_t
        size_t textLength = text.length();
        std::cout << "Text length: " << textLength << std::endl; // 输出 11

        // 查找字符时 find() 返回 size_t (位置)
        size_t pos = text.find('o');
        if (pos != std::string::npos) { // std::string::npos 也是 size_t 类型
            std::cout << "First 'o' found at position: " << pos << std::endl; // 输出 4
        }

        std::vector<double> scores = {90.5, 88.0, 95.5, 76.0};
        size_t numScores = scores.size();
        std::cout << "Number of scores: " << numScores << std::endl; // 输出 4

        // 遍历向量
        for (size_t i = 0; i < numScores; ++i) {
            std::cout << "Score " << i << ": " << scores[i] << std::endl;
        }

        return 0;
    }
    ```

## 原始字符串


在C++11之前, 定义包含特殊字符 (如换行符或反斜杠) 的字符串通常需要使用转义序列. 这会使代码变得难以阅读和维护, 尤其是在处理正则表达式或Windows文件路径时.

* 文件路径: `std::string path = "C:\\Users\\Admin\\Documents\\file.txt";`
* 多行文本: `std::string text = "第一行\n第二行\n第三行";`


原始字符串字面量是C++11引入的一项新特性. 它允许你创建"所见即所得"的字符串, 编辑器中的文本内容与程序输出的最终字符串完全一致, 无需进行任何转义. 使用原始字符串字面量可以显著提高代码的可读性和编写效率.

* 简化多行文本: 无需手动添加换行符`\n`, 可以直接在代码中按期望的格式书写多行文本.
* 避免转义: 在处理包含大量反斜杠`\`或引号`"`的字符串时 (例如正则表达式, 文件路径, HTML/XML代码), 可以直接复制粘贴, 无需手动转义.
* 代码原型设计: 在图形学编程 (如嵌入GLSL着色器代码) 或将脚本语言 (如Lua) 嵌入C++程序时非常方便.

基本语法使用`R"()"`将字符串内容包裹起来.

示例:

```cpp
#include <iostream>
#include <string>

int main() {
    // 传统方式
    std::string path_old = "C:\\Users\\Admin\\Documents";
    // 原始字符串方式
    std::string path_raw = R"(C:\Users\Admin\Documents)";

    std::cout << "传统方式: " << path_old << std::endl;
    std::cout << "原始字符串: " << path_raw << std::endl;

    std::string multi_line_text = R"(这是第一行.
这是第二行.
    这是带缩进的第三行.)";
    std::cout << multi_line_text << std::endl;

    return 0;
}
```

### 扩展语法

如果字符串本身需要包含`)"`序列, 可以使用自定义的定界符 (delimiter). 语法为`R"delimiter(...)delimiter"`. 定界符可以是任何不包含空格, 控制字符或括号的字符序列.

示例:

```cpp
// 字符串包含 )" 序列
std::string complex_str = R"xyz(这个字符串包含了一个序列 )". )xyz";
std::cout << complex_str << std::endl;
```

### 结合UTF编码

原始字符串字面量可以与不同的UTF编码前缀结合使用, 以创建特定编码的字符串.

* `u8R"(...)"` : UTF-8
* `uR"(...)"` : UTF-16
* `UR"(...)"` : UTF-32

示例:

```cpp
const char* s1 = u8R"(这是一个UTF-8编码的原始字符串.)";
const char16_t* s2 = uR"(This is a UTF-16 raw string.)";
const char32_t* s3 = UR"(This is a UTF-32 raw string.)";
```

## 常用据类型转换

在软件开发中, 我们经常需要在不同数据类型之间进行转换, 尤其是在处理文本输入 (如用户输入或文件数据) 时, 将字符串与数值类型相互转换是一项基本且重要的技能. C++11标准库提供了强大而易用的工具来完成这些任务.

字符串➡️数值:

C++11在`<string>`头文件中引入了一系列函数, 可以方便地将字符串转换为整数或浮点数.

转换为整数:

这些函数会从字符串的开头解析数字, 直到遇到非数字字符为止.

  * `std::stoi`: 字符串转换为`int`.
  * `std::stol`: 字符串转换为`long`.
  * `std::stoll`: 字符串转换为`long long`.
  * `std::stoul`, `std::stoull`: 对应上述类型的无符号 (unsigned) 版本.

示例代码:

```cpp
#include <iostream>
#include <string>
#include <stdexcept>

int main() {
    std::string num_str = "12345";
    std::string invalid_str = "hello";

    try {
        int num = std::stoi(num_str);
        std::cout << "转换后的整数: " << num << std::endl;

        // 尝试转换一个无效字符串
        int invalid_num = std::stoi(invalid_str);
    } catch (const std::invalid_argument& e) {
        std::cerr << "错误: 无效的参数. " << e.what() << std::endl;
    } catch (const std::out_of_range& e) {
        std::cerr << "错误: 超出范围. " << e.what() << std::endl;
    }
    return 0;
}
```

转换为浮点数:

与整数转换类似, C++也为浮点数提供了相应的转换函数.

  * `std::stof`: 字符串转换为`float`.
  * `std::stod`: 字符串转换为`double`.
  * `std::stold`: 字符串转换为`long double`.

示例代码:

```cpp
#include <iostream>
#include <string>

int main() {
    std::string float_str = "3.14159";
    double pi = std::stod(float_str);
    std::cout << "转换后的浮点数: " << pi << std::endl;
    return 0;
}
```

数值➡️字符串:

将数值类型转换回字符串同样简单, 主要使用`std::to_string`函数. 这个函数可以处理所有基本整数和浮点数类型.

示例代码:

```cpp
#include <iostream>
#include <string>

int main() {
    int my_int = 42;
    double my_double = 2.718;

    std::string int_str = std::to_string(my_int);
    std::string double_str = std::to_string(my_double);

    std::cout << "整数转字符串: " << int_str << std::endl;
    std::cout << "浮点数转字符串: " << double_str << std::endl;
    return 0;
}
```

## 自定义类型转换

C++允许我们为自定义的类或结构体 (user-defined types) 定义转换规则. 这使得我们的类型可以像内置类型一样在不同上下文中使用, 但同时也需要我们小心处理, 以避免意料之外的行为.

在深入用户自定义转换之前, 简单回顾一下C++的几种标准类型转换方式:

* `static_cast`: 用于在相关的类型之间进行转换, 例如将`int`转换为`double`, 或者在类的继承体系中进行上行或下行转换. 这是最常见的转换方式.
* `dynamic_cast`: 主要用于处理多态类型, 在继承体系中安全地进行下行转换, 如果转换无效会返回`nullptr` (对指针) 或抛出异常 (对引用).
* `reinterpret_cast`: 用于低级别的, 位模式的重新解释. 它的行为与平台相关, 应当谨慎使用.

我们可以通过在类内部定义一个特殊的转换函数 (conversion function) 来指定该类对象如何被转换成另一种类型. 转换函数的语法是 `operator type() const`, 其中`type`是你希望转换的目标类型. 注意, 它没有显式的返回类型, 因为返回类型就是`type`本身.

示例: 从`Pair`到`Triple`的转换: 假设我们有两个结构体, `Pair`和`Triple`. 我们希望能够将一个`Pair`对象自动转换为`Triple`对象, 并将第三个成员初始化为0.

```cpp
#include <iostream>

struct Triple {
    int x, y, z;
};

struct Pair {
    int a, b;

    // 定义一个转换函数, 将Pair转换为Triple
    operator Triple() const {
        std::cout << "调用了Pair到Triple的转换函数!" << std::endl;
        return {a, b, 0}; // C++11风格的返回
    }
};

void printTriple(Triple t) {
    std::cout << "Triple: (" << t.x << ", " << t.y << ", " << t.z << ")" << std::endl;
}

int main() {
    Pair p = {10, 20};

    // 此处发生了从Pair到Triple的隐式转换
    printTriple(p);

    // 也可以使用显式转换
    Triple t = static_cast<Triple>(p);
    printTriple(t);

    return 0;
}
```

### `explicit`关键字

上面的隐式转换虽然方便, 但也可能导致难以发现的错误和意外的函数调用. 为了增强代码的安全性和可读性, C++引入了`explicit`关键字. 将转换函数标记为`explicit`后, 编译器将不再允许其进行隐式转换, 只允许通过`static_cast`等方式进行显式转换. C++核心准则 (C++ Core Guidelines) 建议默认将单参数构造函数和转换函数标记为`explicit`, 以防止不必要的隐式类型转换.

示例:

```cpp
struct SafePair {
    int a, b;

    // 使用explicit关键字
    explicit operator Triple() const {
        return {a, b, 0};
    }
};

int main() {
    SafePair sp = {100, 200};

    // printTriple(sp); // 编译错误! 不允许隐式转换.

    // 必须使用显式转换
    Triple t_safe = static_cast<Triple>(sp);
    printTriple(t_safe); // 正确

    return 0;
}
```

---

转换的成本:

需要注意的是, 类型转换并非没有成本. 用户自定义的转换通常会创建一个目标类型的临时对象. 这个过程涉及:

1.  调用目标类型的构造函数.
2.  可能的数据成员复制.
3.  函数调用开销.

在性能敏感的代码中, 过多不必要的转换可能会成为性能瓶颈. 因此, 设计API时应有意识地控制类型转换的发生.

## `consteval`的用法

`consteval`是C++20引入的一个函数说明符, 用于声明一个立即函数 (immediate function). 核心要求是: 对`consteval`函数的每一次调用都必须在编译期产生一个常量结果. 如果一个函数被`consteval`修饰, 编译器会强制确保该函数在编译阶段就被执行并返回其结果. 任何企图在运行时调用它的行为都会导致编译失败. 这使得`consteval`成为实现纯编译期计算的最强约束.

在`consteval`出现之前, C++11引入的`constexpr`已经允许函数在编译期运行. 但`constexpr`函数有一个"双重身份":

* 如果用在需要编译期常量的上下文中(例如, 数组大小, `static_assert`), 它就在编译期执行.
* 如果用在普通运行时上下文中, 它可以像一个普通函数一样在运行时执行.

这种灵活性有时会成为一个问题. 开发者可能意图某个函数必须在编译期执行(例如, 用于解析配置文件, 生成编译期查找表等), 但由于调用代码无意中使用了运行时变量, 该函数被"降级"到运行时执行, 这违背了设计初衷, 甚至可能引发难以察觉的性能问题或逻辑错误. `consteval`的诞生就是为了解决这个问题. 它提供了一种毫不含糊的方式来声明一个函数只能在编译期执行, 保证了编译期计算的纯粹性.

`consteval` vs `constexpr`:

| 特性 | `consteval` (立即函数) | `constexpr` (常量表达式函数) |
| :--- | :--- | :--- |
| 执行时机 | 严格编译期. 必须在编译时求值. | 编译期或运行时. 可以在编译期求值, 也可以像普通函数一样在运行时执行. |
| 约束强度 | 非常强. 它保证了函数的调用总是在编译期完成. | 较弱. 它只保证函数*可以*在编译期执行, 但不强制. |
| 使用场景 | 编写必须在编译期完成的工具函数, 例如编译期字符串解析, 模板元编程的辅助函数等. | 编写既希望能在编译期求值(用于优化和常量定义)又希望能在运行时使用的通用函数. |
| 调用上下文 | 调用它的所有参数必须是编译期常量. | 当其结果用于编译期常量时, 参数必须是编译期常量; 否则, 参数可以是运行时变量. |

基本用法:

一个`consteval`函数必须满足`constexpr`函数的所有要求, 并且它的调用点必须能让编译器在当时就计算出结果.

```cpp
#include <iostream>
#include <array>

// 一个consteval函数, 用于计算斐波那契数
consteval int fibonacci(int n) {
    if (n <= 1) {
        return n;
    }
    return fibonacci(n - 1) + fibonacci(n - 2);
}

int main() {
    // ✅ 合法: fibonacci(10) 的所有参数都是编译期常量.
    // 结果在编译期被计算出来, 就像直接写入了 `int val = 55;`
    int val = fibonacci(10);

    // ✅ 合法: 用于需要编译期常量的地方, 如 std::array 的大小
    constexpr int size = fibonacci(7); // 编译期计算出结果为 13
    std::array<int, size> my_array{};

    std::cout << "val = " << val << std::endl;
    std::cout << "array size = " << my_array.size() << std::endl;

    // ❌ 错误: 下面的代码将无法编译
    /*
    int x = 10;
    int runtime_val = fibonacci(x); // 编译错误!
                                    // x 是一个运行时变量, 不是编译期常量.
                                    // 对 consteval 函数的调用必须在编译期完成.
    */

    return 0;
}\*
```

`constexpr` 调用 `consteval`:

`constexpr`函数可以调用`consteval`函数, 因为`constexpr`函数在编译期执行时, 其上下文满足`consteval`的要求.

```cpp
consteval int square(int n) {
    return n * n;
}

constexpr int square_of_sum(int a, int b) {
    // 在编译期调用 constexpr 函数时, 内部对 consteval 函数的调用是合法的
    return square(a + b);
}

int main() {
    // ✅ 合法: square_of_sum 在编译期上下文中执行
    constexpr int result = square_of_sum(3, 4); // 结果是 49
    static_assert(result == 49);
}
```

反过来, `consteval`函数也可以调用`constexpr`函数.

## `constinit`的用法

`constinit`是C++20引入的一个新说明符, 用于断言一个具有静态或线程存储周期的变量在编译时进行常量初始化. 它的核心作用是保证变量的初始化在程序开始运行之前 (即编译链接阶段) 就已经完成, 从而避免静态初始化顺序问题 (static initialization order fiasco).

在C++中, 具有静态存储周期 (例如全局变量, `static`成员变量) 的变量的初始化可能发生在两个阶段:

1.  静态初始化 (Static Initialization): 初始值是常量表达式, 在编译期或加载时完成. 这是零开销的.
2.  动态初始化 (Dynamic Initialization): 初始值不是常量表达式, 需要在`main`函数执行前的某个时刻通过运行时代码来完成.

动态初始化可能带来一个著名的问题: "static initialization order fiasco". 如果一个全局变量`A`的初始化依赖于另一个全局变量`B`, 但`B`在`A`之后才被初始化, 程序就会产生未定义行为. `constinit`的出现就是为了在编译期强制解决这个问题. 如果一个变量被声明为`constinit`, 编译器会检查它的初始化表达式是否为常量表达式. 如果是, 就能保证其被静态初始化; 如果不是, 就会直接导致编译失败. 这样一来, 潜在的运行时初始化顺序风险就被提前暴露和消除了.

`constinit` vs `constexpr` vs `consteval`:

`constinit`与其他编译期关键字有着本质的区别. 它不是用来定义常量的, 而是用来保证变量的初始化时机.

| 关键字 | `constinit` | `constexpr` | `consteval` |
| :--- | :--- | :--- | :--- |
| 作用对象 | 变量 | 变量或函数 | 函数 |
| 核心功能 | 保证变量进行静态初始化 | 声明一个值或函数的结果是编译期常量 | 强制函数在编译期执行 |
| 可变性 | 变量值在初始化后可以被修改 | 变量是不可修改的 (`const`) | N/A (用于函数) |
| 目的 | 避免动态初始化, 解决初始化顺序问题 | 创建编译期常量, 用于优化和元编程 | 创建纯粹的编译期工具函数 |

关键区别: 一个`constinit`变量在编译期初始化后, 在运行时完全可以是一个普通的可修改的变量. 而一个`constexpr`变量则是一个真正的常量, 其值在整个程序生命周期中都不能改变.

基本用法:

```cpp
#include <iostream>

// 一个 constexpr 函数, 可以在编译期执行
constexpr int get_initial_value() {
    return 42;
}

// ✅ 合法: 使用常量表达式进行初始化
constinit int global_value = get_initial_value();

// ❌ 错误: 下面的代码无法编译
/*
int get_runtime_value() { return 100; }
constinit int another_value = get_runtime_value(); // 编译错误!
                                                   // get_runtime_value() 不是常量表达式,
                                                   // 无法保证静态初始化.
*/

// constinit 也可以和 const, constexpr 一起使用
constinit const int permanent_value = 123;
// `constinit constexpr` 是冗余的, 因为`constexpr`变量本身就保证了静态初始化.

int main() {
    std::cout << "Initial global_value: " << global_value << std::endl;

    // ✅ 合法: constinit 变量在初始化后可以被修改
    global_value = 99;

    std::cout << "Modified global_value: " << global_value << std::endl;

    return 0;
}
```

解决静态初始化顺序问题:

```cpp
// --- a.cpp ---
// extern int b; // 假设b在另一个文件中定义
// int a = b + 1; // 危险! 如果b在a之后初始化, 就会出问题.

// 使用 constinit 的安全做法
// --- b.h ---
extern constinit int b; // 在头文件中声明b为constinit

// --- b.cpp ---
#include "b.h"
constinit int b = 10; // 定义并常量初始化b

// --- a.cpp ---
#include "b.h"
constinit int a = b + 1; // 安全! 编译器保证a和b都在编译期初始化.
                         // a的值在编译期就确定为11.
```

## 定宽整数类型

定宽整数类型 (Fixed-width integer types) 是一组在C++11中引入的标准整数类型, 定义在头文件 `<cstdint>` 中. 它们的主要特点是宽度 (即占用的比特数) 是固定且跨平台一致的.

这些类型以一种非常清晰的模式命名:

- `intN_t`: 有符号整数, 宽度为`N`比特. 例如, `int8_t`, `int16_t`, `int32_t`, `int64_t`.
- `uintN_t`: 无符号整数, 宽度为`N`比特. 例如, `uint8_t`, `uint16_t`, `uint32_t`, `uint64_t`.

这里的`N`直接表明了该类型变量占用的内存大小, 比如 `uint8_t` 就是一个8比特 (1字节) 的无符号整数.

为什么需要定宽类型? 🤔

在C++11之前, 我们通常使用`short`, `int`, `long`, `long long`等基本整数类型. 然而, C++标准对这些类型的具体大小没有做出精确规定, 只规定了它们的最小尺寸. 例如:

- `int` 至少为16比特.
- `long` 至少为32比特.

这意味着 `int` 在一个平台 (如某些嵌入式系统) 上可能是16比特, 而在另一个平台 (如现代PC) 上是32比特. 这种不确定性会导致在特定场景下出现严重问题:

1.  二进制兼容性: 当你需要读写二进制文件, 或者通过网络发送数据时, 数据的大小必须是精确且一致的. 如果发送方用32位的`int`写入数据, 而接收方用16位的`int`读取, 就会导致数据解析错误.
2.  内存布局控制: 在进行底层系统编程或与硬件交互时, 程序员需要精确控制数据结构中每个成员的内存占用和布局.
3.  可移植性: 使用`int`等类型的代码在从一个平台移植到另一个平台时, 可能会因为整数溢出或内存对齐等问题而出现行为差异.

定宽整数类型正是为了解决这些问题而生. 通过使用`int32_t`或`uint8_t`等类型, 你可以确保无论代码在哪个平台编译运行, 这个变量的大小都是精确的32比特或8比特, 从而保证了代码的可预测性和可移植性.

如何使用定宽类型?  使用它们非常简单, 只需包含`<cstdint>`头文件即可. 代码示例:

```cpp
#include <iostream>
#include <cstdint> // 必须包含此头文件

// 假设这是一个用于网络协议的数据包结构
struct Packet {
    uint16_t transactionId; // 精确的16位事务ID
    uint32_t payloadSize;   // 精确的32位负载大小
    uint8_t  flags;         // 精确的8位标志位
};

int main() {
    // 打印各种定宽类型的大小, 结果在所有平台上都是一致的
    std::cout << "sizeof(int8_t)   = " << sizeof(int8_t) << " byte" << std::endl;
    std::cout << "sizeof(uint16_t) = " << sizeof(uint16_t) << " bytes" << std::endl;
    std::cout << "sizeof(int32_t)  = " << sizeof(int32_t) << " bytes" << std::endl;
    std::cout << "sizeof(uint64_t) = " << sizeof(uint64_t) << " bytes" << std::endl;

    std::cout << "-------------------------" << std::endl;

    Packet myPacket;
    myPacket.transactionId = 12345;
    myPacket.payloadSize = 1024;
    myPacket.flags = 0b00000001; // 设置一个标志

    std::cout << "Size of Packet struct = " << sizeof(Packet) << " bytes" << std::endl;

    // 使用定宽类型可以确保该结构体在任何系统上的大小和布局都是可预测的.
    // (注意: 编译器可能会为了对齐而增加填充位, 但字段本身的大小是固定的)

    return 0;
}
```
