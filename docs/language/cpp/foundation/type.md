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
    Uint32 type;                            /**< Event type, shared with all events */
    SDL_CommonEvent common;                 /**< Common event data */
    SDL_DisplayEvent display;               /**< Display event data */
    SDL_WindowEvent window;                 /**< Window event data */
    SDL_KeyboardEvent key;                  /**< Keyboard event data */
    SDL_TextEditingEvent edit;              /**< Text editing event data */
    SDL_TextEditingExtEvent editExt;        /**< Extended text editing event data */
    SDL_TextInputEvent text;                /**< Text input event data */
    SDL_MouseMotionEvent motion;            /**< Mouse motion event data */
    SDL_MouseButtonEvent button;            /**< Mouse button event data */
    SDL_MouseWheelEvent wheel;              /**< Mouse wheel event data */
    SDL_JoyAxisEvent jaxis;                 /**< Joystick axis event data */
    SDL_JoyBallEvent jball;                 /**< Joystick ball event data */
    SDL_JoyHatEvent jhat;                   /**< Joystick hat event data */
    SDL_JoyButtonEvent jbutton;             /**< Joystick button event data */
    SDL_JoyDeviceEvent jdevice;             /**< Joystick device change event data */
    SDL_JoyBatteryEvent jbattery;           /**< Joystick battery event data */
    SDL_ControllerAxisEvent caxis;          /**< Game Controller axis event data */
    SDL_ControllerButtonEvent cbutton;      /**< Game Controller button event data */
    SDL_ControllerDeviceEvent cdevice;      /**< Game Controller device event data */
    SDL_ControllerTouchpadEvent ctouchpad;  /**< Game Controller touchpad event data */
    SDL_ControllerSensorEvent csensor;      /**< Game Controller sensor event data */
    SDL_AudioDeviceEvent adevice;           /**< Audio device event data */
    SDL_SensorEvent sensor;                 /**< Sensor event data */
    SDL_QuitEvent quit;                     /**< Quit request event data */
    SDL_UserEvent user;                     /**< Custom event data */
    SDL_SysWMEvent syswm;                   /**< System dependent window event data */
    SDL_TouchFingerEvent tfinger;           /**< Touch finger event data */
    SDL_MultiGestureEvent mgesture;         /**< Gesture event data */
    SDL_DollarGestureEvent dgesture;        /**< Gesture event data */
    SDL_DropEvent drop;                     /**< Drag and drop event data */

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