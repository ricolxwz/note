---
title: 模版
comments: false
icon: material/checkbox-multiple-blank-outline
---

## 为什么要用模版

看下面的这个例子.

```cpp
#include <iostream>

int square(int input) {
    return input * input;
}

int main() {
    std::cout << square(5) << std::endl;
    std::cout << square(5.5) << std::endl;
    std::cout << square(5.5f) << std::endl;
    return 0;
}
```

输出:

```bash
25
25
```

hmmm. 怎么全是25, 这是因为都调用的是`int square(int input)`这个函数. 所以你要使用重载把用到的每个类型都写上, 例如.

```cpp
int square(int input) {
    return input * input;
}

float square(float input) {
    return input * input;
}

double square(double input) {
    return input * input;
}

int main() {
    std::cout << square(5) << std::endl;
    std::cout << square(5.5) << std::endl;
    std::cout << square(5.5f) << std::endl;
    return 0;
}
```

所以, 最后的结果是`25, 30.25, 30.25`. 但是, 我们写了很多个类似只是类型不同的函数, 如果我们要修改其中一个函数的逻辑, 就要修改其他所有函数的逻辑, 这是非常的耗时耗力的, 所以有没有什么方法只写一个"template", 然后在我们要用到的时候生成他的类型的代码呢? 这就是模版的作用. 上述的代码可以写为:

```cpp
#include <iostream>

template <typename T>
T square(T input) {
    return input * input;
}

int main() {
    std::cout << square<int>(5) << std::endl;
    std::cout << square<double>(5.5) << std::endl;
    std::cout << square<float>(5.5f) << std::endl;
    return 0;
}
```

## 函数模版

### 使用`template`

就是上面这么用.

```cpp
template <typename T, typename U, typename V>
T foo(const U& u, const V& v) {};
int main() {
    foo<U, V>(u, v)
    return 0;
}
```

`T`, `U`, `V`的生命周期是这个函数内.

```cpp
#include <iostream>

template <typename T>
T square(T input) {
    return input * input;
}

int main() {
    std::cout << square<int>(5) << std::endl;
    std::cout << square<double>(5.5) << std::endl;
    std::cout << square<float>(5.5f) << std::endl;
    return 0;
}
```

这段代码在编译器的眼里其实是这样的:

```cpp
#include <iostream>

template<typename T>
T square(T input)
{
  return input * input;
}

/* First instantiated from: insights.cpp:9 */
#ifdef INSIGHTS_USE_TEMPLATE
template<>
int square<int>(int input)
{
  return input * input;
}
#endif


/* First instantiated from: insights.cpp:10 */
#ifdef INSIGHTS_USE_TEMPLATE
template<>
double square<double>(double input)
{
  return input * input;
}
#endif


/* First instantiated from: insights.cpp:11 */
#ifdef INSIGHTS_USE_TEMPLATE
template<>
float square<float>(float input)
{
  return input * input;
}
#endif


int main()
{
  std::cout.operator<<(square<int>(5)).operator<<(std::endl);
  std::cout.operator<<(square<double>(5.5)).operator<<(std::endl);
  std::cout.operator<<(square<float>(5.5F)).operator<<(std::endl);
  return 0;
}
```

!!! tip "使用`auto`自动推断返回值类型"

    可以使用`auto`自动推断返回值的类型, 例如:

    ```cpp
    template <typename T1, typename T2>
    auto Multiply(const T1& a, const T2& b) {
        return a * b;
    }
    ```

### 使用`auto`

另外一种实现模版的方法是使用`auto`, 它会帮我们自动推断类型.

```cpp
#include <iostream>

auto square(auto input) {
    return input * input;
}

int main()
{
  std::cout.operator<<(square<int>(5)).operator<<(std::endl);
  std::cout.operator<<(square<double>(5.5)).operator<<(std::endl);
  std::cout.operator<<(square<float>(5.5F)).operator<<(std::endl);
  return 0;
}
```

上述的这段代码在编译器的眼里其实是这样的:

```cpp
#include <iostream>

template<class type_parameter_0_0>
auto square(type_parameter_0_0 input)
{
  return input * input;
}

#ifdef INSIGHTS_USE_TEMPLATE
template<>
int square<int>(int input)
{
  return input * input;
}
#endif


#ifdef INSIGHTS_USE_TEMPLATE
template<>
double square<double>(double input)
{
  return input * input;
}
#endif


#ifdef INSIGHTS_USE_TEMPLATE
template<>
float square<float>(float input)
{
  return input * input;
}
#endif


int main()
{
  std::cout.operator<<(square<int>(5)).operator<<(std::endl);
  std::cout.operator<<(square<double>(5.5)).operator<<(std::endl);
  std::cout.operator<<(square<float>(5.5F)).operator<<(std::endl);
  return 0;
}
```

你会发现, 其实和用`template`没什么两样.

---

!!! tip "怎么得到上面的'编译器眼里'的代码的"

    使用这个网站: [C++ Insights](https://cppinsights.io/).

## 传入非对象参数

有时候, 我们需要模版帮助我们填写一些非对象的参数, 例如在`std::array`的实现中:

```cpp
template <class T, std::size_t N> struct array;
```

再举个例子:

```cpp
#include <iostream>

template <typename T1, size_t N>
void foo(T1 input1) {
    for (size_t i = 0; i < N; i++) {
        std::cout << "hello" << std::endl;
    }
}

int main() {
    foo<int, 5>(5);
    foo<int, 4>(5);
    foo<int, 3>(5);
    return 0;
}
```

上述的代码在编译器眼里是这样的:

```cpp
#include <iostream>

template<typename T1, size_t N>
void foo(T1 input1)
{
  for(size_t i = 0; i < N; i++) {
    std::operator<<(std::cout, "hello").operator<<(std::endl);
  }

}

/* First instantiated from: insights.cpp:11 */
#ifdef INSIGHTS_USE_TEMPLATE
template<>
void foo<int, 5>(int input1)
{
  for(size_t i = 0; i < 5UL; i++) {
    std::operator<<(std::cout, "hello").operator<<(std::endl);
  }

}
#endif


/* First instantiated from: insights.cpp:12 */
#ifdef INSIGHTS_USE_TEMPLATE
template<>
void foo<int, 4>(int input1)
{
  for(size_t i = 0; i < 4UL; i++) {
    std::operator<<(std::cout, "hello").operator<<(std::endl);
  }

}
#endif


/* First instantiated from: insights.cpp:13 */
#ifdef INSIGHTS_USE_TEMPLATE
template<>
void foo<int, 3>(int input1)
{
  for(size_t i = 0; i < 3UL; i++) {
    std::operator<<(std::cout, "hello").operator<<(std::endl);
  }

}
#endif


int main()
{
  foo<int, 5>(5);
  foo<int, 4>(5);
  foo<int, 3>(5);
  return 0;
}
```

## 部分模板化

有些时候, 我们对所有的类都定义了一个统一的模版, 这可能不是我们想要的, 比如对于`int`, `char`来说, 能用`==`判断两个数是否相等; 但是对于`float`, `double`来说, 是无法通过`==`判断两个数是否相等的, 例如下面的代码:

```cpp
#include <iostream>

template <typename T>
bool equal(T a, T b) {
    return a == b;
}

int main() {
    std::cout << equal<int>(1, 1) << std::endl;
    std::cout << equal<float>(1.0f-0.999999f, 0.000001f) << std::endl;
    return 0;
}
```

输出:

```bash
1
0 # 这里是0, 说明两个数是不相等的, 但是实际上是相等的
```

所以我们就想, 能不能为`float`专门写一个模版呢? 是可以的:

```cpp
#include <iostream>
#include <cmath>

template <typename T>
bool equal(T a, T b) {
    return a == b;
}

template<>
bool equal<float>(float a, float b) {
    std::cout << "partial template called" << std::endl;
    return fabs(a - b) < 0.00001f;
}

template<>
bool equal<double>(double a, double b) {
    std::cout << "partial template called" << std::endl;
    return abs(a - b) < 0.00001;
}

int main() {
    std::cout << equal<int>(1, 1) << std::endl;
    std::cout << equal<float>(1.0f-0.999999f, 0.000001f) << std::endl;
    return 0;
}
```

你会发现, 就是从C++ insights里面挑了一个用`float`重载的函数出来, 然后稍微改了一下. 输出:

```bash
1
partial template called
1
```

## 可变参数模版

可变参数模板(Variadic Templates)是 C++11 引入的一个强大的特性. 它允许你创建可以接受任意数量参数的函数和类模板, 而不需要在模板定义时指定参数的个数和类型

```cpp
#include <iostream>

template<typename T>
T Sum(T arg){ // 基本情况: 只有一个参数
    return arg;
}

template<typename T, typename... Args>
T Sum(T start, Args... args){ // 递归情况: 至少有两个参数
    return start + Sum(args...); // 将第一个参数与剩余参数的和相加
}

int main() {
    int sum1 = Sum(1);        // 调用 Sum(int)
    // 1. 匹配到 template<typename T> T Sum(T arg)
    // 2. T 被推导为 int, arg 的值为 1
    // 3. 返回 arg, 即返回 1

    double sum2 = Sum(1.1, 2.2, 3, 4.4);
    // 请见Cpp insights

    std::cout << sum1 << ", " << sum2 << std::endl;  // 输出: 1, 10.3
    return 0;
}
```

上述的代码在编码器眼里是这样的:

```cpp
#include <iostream>

template<typename T>
T Sum(T arg)
{
  return arg;
}

/* First instantiated from: insights.cpp:14 */
#ifdef INSIGHTS_USE_TEMPLATE
template<>
int Sum<int>(int arg)
{
  return arg;
}
#endif


/* First instantiated from: insights.cpp:10 */
#ifdef INSIGHTS_USE_TEMPLATE
template<>
double Sum<double>(double arg)
{
  return arg;
}
#endif


template<typename T, typename ... Args>
T Sum(T start, Args... args)
{
  return start + Sum(args... );
}

#ifdef INSIGHTS_USE_TEMPLATE
template<>
int Sum<int>(int start);
#endif


/* First instantiated from: insights.cpp:19 */
#ifdef INSIGHTS_USE_TEMPLATE
template<>
double Sum<double, double, int, double>(double start, double __args1, int __args2, double __args3)
{
  return start + Sum(__args1, __args2, __args3);
}
#endif


/* First instantiated from: insights.cpp:10 */
#ifdef INSIGHTS_USE_TEMPLATE
template<>
double Sum<double, int, double>(double start, int __args1, double __args2)
{
  return start + static_cast<double>(Sum(__args1, __args2));
}
#endif


/* First instantiated from: insights.cpp:10 */
#ifdef INSIGHTS_USE_TEMPLATE
template<>
int Sum<int, double>(int start, double __args1)
{
  return static_cast<int>(static_cast<double>(start) + Sum(__args1));
}
#endif


#ifdef INSIGHTS_USE_TEMPLATE
template<>
double Sum<double>(double start);
#endif


int main()
{
  int sum1 = Sum(1);
  double sum2 = Sum(1.1000000000000001, 2.2000000000000002, 3, 4.4000000000000004);
  std::operator<<(std::cout.operator<<(sum1), ", ").operator<<(sum2).operator<<(std::endl);
  return 0;
}
```

可以看到, 这是一个递归的逻辑, 当然, 如果我这样写:

```cpp linenums="1" hl_lines="19"
#include <iostream>

template<typename T>
T Sum(T arg){ // 基本情况: 只有一个参数
    return arg;
}

template<typename T, typename... Args>
T Sum(T start, Args... args){ // 递归情况: 至少有两个参数
    return start + Sum(args...); // 将第一个参数与剩余参数的和相加
}

int main() {
    int sum1 = Sum(1);        // 调用 Sum(int)
    // 1. 匹配到 template<typename T> T Sum(T arg)
    // 2. T 被推导为 int, arg 的值为 1
    // 3. 返回 arg, 即返回 1

    double sum2 = Sum<double, double, double>(1.1, 2.2, 3, 4.4);
    // 请见Cpp insights

    std::cout << sum1 << ", " << sum2 << std::endl; // 输出: 1, 10.7
    return 0;
}
```

再看一下C++ insights的代码:

```cpp
#include <iostream>

template<typename T>
T Sum(T arg)
{
  return arg;
}

/* First instantiated from: insights.cpp:14 */
#ifdef INSIGHTS_USE_TEMPLATE
template<>
int Sum<int>(int arg)
{
  return arg;
}
#endif


/* First instantiated from: insights.cpp:10 */
#ifdef INSIGHTS_USE_TEMPLATE
template<>
double Sum<double>(double arg)
{
  return arg;
}
#endif


template<typename T, typename ... Args>
T Sum(T start, Args... args)
{
  return start + Sum(args... );
}

#ifdef INSIGHTS_USE_TEMPLATE
template<>
int Sum<int>(int start);
#endif


/* First instantiated from: insights.cpp:19 */
#ifdef INSIGHTS_USE_TEMPLATE
template<>
double Sum<double, double, double, double>(double start, double __args1, double __args2, double __args3)
{
  return start + Sum(__args1, __args2, __args3);
}
#endif


/* First instantiated from: insights.cpp:10 */
#ifdef INSIGHTS_USE_TEMPLATE
template<>
double Sum<double, double, double>(double start, double __args1, double __args2)
{
  return start + Sum(__args1, __args2);
}
#endif


/* First instantiated from: insights.cpp:10 */
#ifdef INSIGHTS_USE_TEMPLATE
template<>
double Sum<double, double>(double start, double __args1)
{
  return start + Sum(__args1);
}
#endif


#ifdef INSIGHTS_USE_TEMPLATE
template<>
double Sum<double>(double start);
#endif


int main()
{
  int sum1 = Sum(1);
  double sum2 = Sum<double, double, double>(1.1000000000000001, 2.2000000000000002, 3, 4.4000000000000004);
  std::operator<<(std::cout.operator<<(sum1), ", ").operator<<(sum2).operator<<(std::endl);
  return 0;
}
```

!!! warning "为啥要写成`<double, double, double>`"

    你会发现生成的代码中原本的`int`变成了`double`. 这其实是正确的做法, 为啥呢? 因为最后一个元素`4.4`是`double`类型的, 如果第三个元素不声明是`double`, 那么这个函数:

    ```cpp
    /* First instantiated from: insights.cpp:10 */
    #ifdef INSIGHTS_USE_TEMPLATE
    template<>
    int Sum<int, double>(int start, double __args1)
    {
    return static_cast<int>(static_cast<double>(start) + Sum(__args1));
    }
    #endif
    ```

    由于上面的函数要求返回一个`int`, 会使用`static_cast<int>`将`static_cast<double>(start) + Sum(__args1)`的结果`7.4`强制转为`7`, 所以有`0.4`消失了, 这就是为什么结果是1.1+2.2+7=10.3. 而如果我们使用`<double, double, double>`, 声明第三个是`double`, 就不会有`static_cast<int>`这样的转换, 就不会损失精度了, 所以输出是正确的10.7.

## 模板类

模板类的思想是和函数模版是差不多的.

```cpp
#include <iostream>

template <typename T>
class Container {
    public:
        Container(int N) {
            m_data = new T[N];
        }
        ~Container() {
            delete[] m_data;
        }
    private:
        T* m_data;
};

int main() {
    Container<int> c{10};
    Container<double> c2{10};
    Container<float> c3{10};
    return 0;
}
```

在编译器眼里是这样的:

```cpp
#include <iostream>

template<typename T>
class Container
{

  public:
  inline Container(int N)
  {
    this->m_data = new T[static_cast<unsigned long>(N)];
  }

  inline ~Container()
  {
    delete[] this->m_data;
  }


  private:
  T * m_data;
};

/* First instantiated from: insights.cpp:17 */
#ifdef INSIGHTS_USE_TEMPLATE
template<>
class Container<int>
{

  public:
  inline Container(int N)
  {
    this->m_data = new int[static_cast<unsigned long>(N)];
  }

  inline ~Container() noexcept
  {
    delete[] this->m_data;
  }


  private:
  int * m_data;
  public:
};

#endif
/* First instantiated from: insights.cpp:18 */
#ifdef INSIGHTS_USE_TEMPLATE
template<>
class Container<double>
{

  public:
  inline Container(int N)
  {
    this->m_data = new double[static_cast<unsigned long>(N)];
  }

  inline ~Container() noexcept
  {
    delete[] this->m_data;
  }


  private:
  double * m_data;
  public:
};

#endif
/* First instantiated from: insights.cpp:19 */
#ifdef INSIGHTS_USE_TEMPLATE
template<>
class Container<float>
{

  public:
  inline Container(int N)
  {
    this->m_data = new float[static_cast<unsigned long>(N)];
  }

  inline ~Container() noexcept
  {
    delete[] this->m_data;
  }


  private:
  float * m_data;
  public:
};

#endif

int main()
{
  Container<int> c = Container<int>{10};
  Container<double> c2 = Container<double>{10};
  Container<float> c3 = Container<float>{10};
  return 0;
}
```

### 带有静态成员变量

有时候, 可能在模板类中需要包含一个静态的成员变量, 比如:

```cpp
#include <iostream>

template <typename T>
class Container {
    public:
        Container(int N) {
            m_data = new T[N];
        }
        ~Container() {
            delete[] m_data;
        }

        static T m_variable;
    private:
        T* m_data;
};

int main() {
    Container<int> c{10};
    Container<double> c2{10};
    Container<float> c3{10};
    return 0;
}
```

上述的代码在编译器眼里是这样的:

```cpp
#include <iostream>

template<typename T>
class Container
{

  public:
  inline Container(int N)
  {
    this->m_data = new T[static_cast<unsigned long>(N)];
  }

  inline ~Container()
  {
    delete[] this->m_data;
  }

  static T m_variable;

  private:
  T * m_data;
};

/* First instantiated from: insights.cpp:19 */
#ifdef INSIGHTS_USE_TEMPLATE
template<>
class Container<int>
{

  public:
  inline Container(int N)
  {
    this->m_data = new int[static_cast<unsigned long>(N)];
  }

  inline ~Container() noexcept
  {
    delete[] this->m_data;
  }

  static int m_variable;

  private:
  int * m_data;
  public:
};

#endif
/* First instantiated from: insights.cpp:20 */
#ifdef INSIGHTS_USE_TEMPLATE
template<>
class Container<double>
{

  public:
  inline Container(int N)
  {
    this->m_data = new double[static_cast<unsigned long>(N)];
  }

  inline ~Container() noexcept
  {
    delete[] this->m_data;
  }

  static double m_variable;

  private:
  double * m_data;
  public:
};

#endif
/* First instantiated from: insights.cpp:21 */
#ifdef INSIGHTS_USE_TEMPLATE
template<>
class Container<float>
{

  public:
  inline Container(int N)
  {
    this->m_data = new float[static_cast<unsigned long>(N)];
  }

  inline ~Container() noexcept
  {
    delete[] this->m_data;
  }

  static float m_variable;

  private:
  float * m_data;
  public:
};

#endif

int main()
{
  Container<int> c = Container<int>{10};
  Container<double> c2 = Container<double>{10};
  Container<float> c3 = Container<float>{10};
  return 0;
}
```

你会发现, 在每个生成的模板类的示例中, 都会有一个不的静态`m_variable`. 第一个`m_variable`的所属类是`Container<int>`, 第二个`m_variable`的所属类是`Container<double>`, 第三个`m_variable`的所属类是`Container<float>`, 所以这三个`m_variable`实际上在静态区上的位置是不同的, 需要通过`Container<int>::m_variable`来访问第一个静态变量, 以此类推. 当然, 必须在全局作用域进行一个声明: `template <typename T> T Container<T>::m_variable;`.  所以正确的代码应该写为:

```cpp linenums="1" hl_lines="18-19 25-27"
#include <iostream>

template <typename T>
class Container {
    public:
        Container(int N) {
            m_data = new T[N];
        }
        ~Container() {
            delete[] m_data;
        }

        static T m_variable;
    private:
        T* m_data;
};

template <typename T>
T Container<T>::m_variable;

int main() {
    Container<int> c{10};
    Container<double> c2{10};
    Container<float> c3{10};
    Container<int>::m_variable = 10;
    Container<double>::m_variable = 10.5;
    Container<float>::m_variable = 10.4f;
    return 0;
}
```

你会发现编译器帮我们生成了这些声明:

```cpp
#ifdef INSIGHTS_USE_TEMPLATE
int Container<int>::m_variable;
#endif
#ifdef INSIGHTS_USE_TEMPLATE
double Container<double>::m_variable;
#endif
#ifdef INSIGHTS_USE_TEMPLATE
float Container<float>::m_variable;
#endif
```

### CTAD

CTAD, Class Template Argument Deduction, 简单来说, 它是 C++17 引入的一个特性, 允许编译器在创建类模板的对象时, 根据构造函数参数的类型自动推导出模板参数, 而不需要你显式指定它们.

```cpp
#include <vector>
#include <string>
#include <utility> // for std::pair

template <typename T1, typename T2>
struct MyPair {
    T1 first;
    T2 second;
    MyPair(T1 f, T2 s) : first(f), second(s) {}
};

int main() {
    std::pair p1(10, "hello"); // 编译器自动推导出 T1=int, T2=const char*
                               // 对于 std::pair<int, std::string> p(10, "hello") 来说,
                               // 推导出的pair类型是 std::pair<int, const char*>,
                               // 然后 p1 会被构造成 std::pair<int, std::string>.

    MyPair mp1(3.14, "pi"); // 编译器自动推导出 T1=double, T2=const char*
                            // mp1 的类型是 MyPair<double, const char*>

    std::vector v = {1, 2, 3, 4, 5}; // 推导出 std::vector<int>
}
```

最好不要使用CTAD.

### 默认参数

模板类的默认模板参数 (default template arguments) 允许你在定义类模板时, 为它的一个或多个模板参数指定一个默认值.

```cpp
#include <iostream>

template <typename T, int size=10>
class Container {
    public:
        Container() {
            m_data = new T[size];
        }
        ~Container() {
            delete[] m_data;
        }

        static T m_variable;
    private:
        T* m_data;
};

int main() {
    Container<int, 15> c;
    Container<int> c2; // size是10
    return 0;
}
```

或者:

```cpp
#include <iostream>

template <typename T=int, int size=10>
class Container {
    public:
        Container() {
            m_data = new T[size];
        }
        ~Container() {
            delete[] m_data;
        }

        static T m_variable;
    private:
        T* m_data;
};

int main() {
    Container<int, 15> c;
    Container<int> c2; // size是10
    Container c3; // T是int, size是10
    return 0;
}
```

如果你看一下`std::vector`的实现, 你会发现他其实模版是`template <class T, class Allocator = std::allocator<T>> class vector`, 所以有一个默认给定的`Allocator`类, 我们可以自定义的其实. 还有`std::unique_ptr`的实现是`template <class T, class Deleter = std::default_delete<T>> class unique_ptr`这个`Deleter`也是可以自己实现的.

## SFINAE

SFINAE是C++模板元编程的核心机制, 全称为SubstitutionFailureIsNotAnError. 它允许编译器在模板实例化过程中, 当类型替换导致无效代码时, 不触发编译错误, 而是跳过该模板候选, 继续匹配其他重载版本. 这使得开发者能通过精心设计的模板签名, 实现条件性的模板选择和重载分辨. 在C++中, 模板函数或类在被使用时会进行实例化. 编译器会尝试将模板参数替换为实际类型. 如果替换后形成well-formed代码, 则该模板有效; 否则, 如果失败仅发生在立即上下文中(如模板参数列表, 返回类型或函数参数类型), 则触发SFINAE, 该候选被忽略, 不视为错误.

例如, 考虑两个模板函数:

```cpp
template<typename T>
void func(T t) { /* 通用版本 */ }

template<typename T>
void func(typename T::iterator it) { /* 针对有iterator的类型 */ }
```
调用func(5)时, 第二个模板的替换会导致T::iterator无效(因为int无iterator), 于是SFINAE忽略它, 选择第一个版本. 而对vector<int>的迭代器调用时, 第二个版本有效.

关键应用:

1. 模板重载分辨: 通过在模板签名中引入依赖于类型的表达式, 如T::value或sizeof(T), 来筛选类型. 如果表达式无效, SFINAE移除该重载.
2. 条件启用模板: 使用std::enable_if(从C++11起). 它是一个模板, 如果条件为true, 则提供type成员; 否则无type, 导致替换失败.

    示例:

    ```cpp
    #include <type_traits>

    template<typename T, typename = std::enable_if_t<std::is_integral_v<T>>>
    void process(T t) { /* 只处理整数类型 */ }
    ```
    这里, 如果T不是整数, enable_if_t无定义, 替换失败, SFINAE忽略此模板.

3. 检测类型 trait: 通过SFINAE构建类型检测, 如检查类是否有特定成员.

    示例: 检测是否有nested type.

    ```cpp
    template<typename T, typename = void>
    struct has_type : std::false_type {};

    template<typename T>
    struct has_type<T, std::void_t<typename T::nested>> : std::true_type {};
    ```
    如果T::nested存在, 第二个特化有效; 否则SFINAE忽略, fallback到第一个.

注意事项:

- SFINAE仅适用于模板替换的立即上下文, 不包括函数体内部. 函数体中的错误仍会引发编译错误.
- C++11引入std::enable_if和void_t, 简化SFINAE使用.
- 滥用可能导致代码晦涩, 建议结合concept(C++20)提升可读性.
- 编译器如GCC/Clang严格遵守SFINAE规则, 但需注意标准版本差异.

SFINAE是C++模板的强大工具, 用于泛型编程和元编程, 但需谨慎设计以避免调试难题. 如果需代码示例或具体场景, 请进一步说明.

### `std::enable_if`

`std::enable_if`是C++11引入的一个模板元编程工具, 用于根据编译时条件来启用或禁用模板的特定重载版本, 它的工作原理与SFINAE机制紧密相关. 简单来说, `std::enable_if`像一个开关: 当满足你设定的条件时, 开关打开, 对应的模板就有效; 当不满足条件时, 开关关闭, 对应的模板在SFINAE规则下被编译器忽略, 而不会导致编译错误.

`std::enable_if`本身是一个结构体模板:

```cpp
template<bool B, typename T = void>
struct enable_if;
```

它有两个模板参数:

* `bool B`: 一个编译期的布尔常量表达式, 通常是一个类型萃取 (type trait) 的结果, 如`std::is_integral<T>::value`.
* `typename T`: 当`B`为`true`时提供的类型, 默认为`void`.

它的工作机制如下:

* 如果`B`为`true`, `std::enable_if<B, T>`内部会有一个名为`type`的成员, 其类型为`T`.
* 如果`B`为`false`, `std::enable_if<B, T>`内部什么都没有, 没有`type`成员.

为了方便使用, C++14提供了别名模板`std::enable_if_t<B, T>`, 它等同于`typename std::enable_if<B, T>::type`.

`std::enable_if`主要有三种使用方式, 目的都是在模板类型替换失败时触发SFINAE. 下面我们通过一个例子来演示: 创建一个只接受整数类型 (integral types) 的函数.

1. 用作函数返回类型

    这是最经典的方式. 我们将`std::enable_if_t`放在函数返回类型的位置.

    ```cpp
    #include <iostream>
    #include <type_traits> // 包含 is_integral, enable_if_t

    // 只有当 T 是整数类型时, enable_if_t 才会定义出 void 类型, 函数才有效
    template<typename T>
    std::enable_if_t<std::is_integral_v<T>> // C++17 的 _v 更简洁
    process(T val) {
        std::cout << "Processing an integral value: " << val << std::endl;
    }

    // 一个备用或通用的重载版本 (可选)
    template<typename T>
    std::enable_if_t<!std::is_integral_v<T>>
    process(T val) {
        std::cout << "Processing a non-integral value: " << val << std::endl;
    }
    ```

    工作原理:

    * 调用`process(10)`时, `T`是`int`. `std::is_integral_v<int>`为`true`, `std::enable_if_t`有效 (结果为`void`), 第一个模板被成功实例化.
    * 调用`process(5.5)`时, `T`是`double`. 对于第一个模板, `std::is_integral_v<double>`为`false`, `std::enable_if`中没有`type`成员, 导致模板替换失败. SFINAE生效, 该模板被忽略. 编译器接着尝试第二个模板, `!std::is_integral_v<double>`为`true`, 成功匹配.

2. 用作函数参数

    我们可以将`std::enable_if_t`作为函数的一个额外参数, 并给予默认值.

    ```cpp
    #include <iostream>
    #include <type_traits>

    template<typename T>
    void process(T val, std::enable_if_t<std::is_integral_v<T>, int> = 0) {
        std::cout << "Processing an integral value: " << val << std::endl;
    }
    ```

    工作原理:

    * 这个用法稍微tricky一点. 同样, 当`T`是整数时, `std::enable_if_t`有效 (结果为`int`), 函数签名变为`void process(T val, int = 0)`, 匹配成功.
    * 当`T`不是整数时, `std::enable_if_t`无效, 导致函数签名在SFINAE规则下被丢弃. 这里的`int`可以换成任何类型, `0`也可以是其他默认值, 它们本身不重要, 只是为了让语法成立.

3. 用作模板参数

    这是另一种常见且清晰的方式, 将`std::enable_if_t`添加为模板参数列表的一部分.

    ```cpp
    #include <iostream>
    #include <type_traits>

    template<typename T, typename = std::enable_if_t<std::is_integral_v<T>>>
    void process(T val) {
        std::cout << "Processing an integral value: " << val << std::endl;
    }
    ```

    工作原理:

    * 当`T`是整数时, `std::enable_if_t`有效 (结果为`void`), 第二个模板参数被推导为`void`, 模板有效.
    * 当`T`不是整数时, `std::enable_if_t`无效, 模板参数列表在SFINAE规则下无效, 该模板被忽略.

### `std::void_t`

`std::void_t`是C++17中引入的一个元编程工具, 它可以将任意数量的模板类型参数转换为`void`. 尽管看起来很简单, 但它在模板元编程中, 尤其是在SFINAE (Substitution Failure Is Not An Error) 上下文中非常有用.

`std::void_t`的定义本质上等同于:

```cpp
template<typename...>
using void_t = void;
```

它是一个模板别名, 无论接收多少个模板参数, 最终都会得到`void`类型.

`std::void_t`的核心价值在于其在模板推导过程中的行为. 如果`std::void_t`的任何一个模板参数是无效的类型表达式, 那么根据SFINAE规则, 包含该`std::void_t`的模板特化就会被编译器丢弃, 而不是引发编译错误. 这使得我们能够优雅地检查一个类型是否具有特定的成员或属性.  它的主要用途是检测表达式的有效性.

1. 示例: 检查是否存在成员类型

    我们可以使用`std::void_t`来检查一个类是否拥有特定的成员类型 (例如, `value_type`).

    ```cpp
    #include <iostream>
    #include <vector>
    #include <type_traits>

    // 主要模板
    template<typename T, typename = std::void_t<>>
    struct has_value_type : std::false_type {};

    // 特化版本: 仅当 T::value_type 是一个有效类型时, 此特化才会被选择
    template<typename T>
    struct has_value_type<T, std::void_t<typename T::value_type>> : std::true_type {};

    template<typename T>
    constexpr bool has_value_type_v = has_value_type<T>::value;

    int main() {
        std::cout << std::boolalpha;
        std::cout << "std::vector<int> has value_type: " << has_value_type_v<std::vector<int>> << std::endl;
        std::cout << "int has value_type: " << has_value_type_v<int> << std::endl;
        return 0;
    }
    ```

    工作原理:

    1.  当`T`是`std::vector<int>`时, `typename T::value_type`是有效的 (即`int`), 因此第二个特化版本`has_value_type<std::vector<int>, void>`被启用, 继承自`std::true_type`.
    2.  当`T`是`int`时, `typename T::value_type`是无效的, 因为`int`没有成员类型`value_type`. 由于SFINAE, 第二个特化版本被丢弃. 编译器转而选择第一个更通用的主要模板, 继承自`std::false_type`.

2. 检查是否支持某个操作

    `std::void_t`也可以和`decltype`结合, 用于检查一个类型是否支持某个操作 (例如`++`前缀自增).

    ```cpp
    #include <iostream>
    #include <type_traits>

    // 主要模板
    template<typename T, typename = std::void_t<>>
    struct is_incrementable : std::false_type {};

    // 特化版本: 仅当 ++std::declval<T&>() 是一个有效表达式时, 此特化才会被选择
    template<typename T>
    struct is_incrementable<T, std::void_t<decltype(++std::declval<T&>())>> : std::true_type {};

    template<typename T>
    constexpr bool is_incrementable_v = is_incrementable<T>::value;

    struct Foo {};

    int main() {
        std::cout << std::boolalpha;
        std::cout << "Can increment int? " << is_incrementable_v<int> << std::endl;
        std::cout << "Can increment Foo? " << is_incrementable_v<Foo> << std::endl;
        return 0;
    }
    ```

    工作原理:

    * 对于`int`类型, `++std::declval<int&>()`是有效的表达式, 因此选择特化版本, 结果为`true`.
    * 对于`Foo`类型, 它没有定义`operator++`, `++std::declval<Foo&>()`是无效表达式, 因此特化版本被丢弃, 选择主要模板, 结果为`false`.

    `std::declval<T&>()`在这里用于在不实际创建`T`类型对象的情况下, 获得一个`T`类型的左值引用, 以便用于`decltype`内部的表达式有效性检查.

总之, `std::void_t`是现代C++中实现类型萃取 (Type Traits) 和进行编译时检查的强大工具, 其语法比传统的SFINAE实现方式更加简洁和直观.

### `concept`

C++20引入的Concepts (概念)是一项革命性的新特性, 它极大地改变了我们编写和使用模板的方式. 简单来说, Concepts允许你为模板参数指定明确的约束 (constraints), 从而使代码更具可读性, 更易于调试, 并产生更清晰的编译错误信息. 在Concepts出现之前, 我们通常依赖SFINAE (Substitution Failure Is Not An Error) 或`static_assert`来约束模板参数, 但这些方法往往代码复杂, 且编译错误信息晦涩难懂 (通常是长篇大论的模板替换失败日志). Concepts旨在解决这些问题.

Concepts主要由两部分组成:

1.  概念的定义 (Definition): 使用`concept`关键字定义一个编译时谓词 (predicate). 这个谓词用于判断一个类型是否满足某些要求.
2.  约束的应用 (Application): 使用`requires`关键字将定义好的概念应用到模板上, 约束其模板参数.

一个Concept通过`concept`关键字定义, 后面跟着它的名称和模板参数, 其主体是一个`requires`表达式, 用于列出对类型的具体要求.

`requires`表达式可以包含以下几种类型的要求:

1.  简单要求 (Simple requirements): 检查某个表达式是否有效. 例如`t++;`.
2.  类型要求 (Type requirements): 使用`typename`关键字检查是否存在嵌套的成员类型. 例如`typename T::value_type;`.
3.  复合要求 (Compound requirements): 检查表达式是否有效, 并可以额外约束表达式的结果类型. 例如`{ t.size() } -> std::same_as<std::size_t>;`.
4.  嵌套要求 (Nested requirements): 在`requires`表达式内部再次使用`requires`关键字.

示例: 定义一个`Integral`概念

标准库已经提供了`std::integral`, 我们可以模仿它来定义一个判断类型是否为整型的概念.

```cpp
template<typename T>
concept Integral = std::is_integral_v<T>;
```

 示例: 定义一个更复杂的`Addable`概念

这个概念要求类型支持`+`运算符, 并且结果可以被转换为其自身类型.

```cpp
template<typename T>
concept Addable = requires(T a, T b) {
    { a + b } -> std::convertible_to<T>; // 复合要求
};
```

使用Concepts来约束模板参数有多种语法形式.

1. `requires`子句

    这是最通用和明确的方式.

    ```cpp
    template<typename T>
    requires Integral<T>
    void print_integer(T value) {
        // ...
    }
    ```

2. 约束模板参数 (Constrained template parameter)

    直接将Concept用作类型.

    ```cpp
    template<Integral T>
    void print_integer(T value) {
        // ...
    }
    ```

3. `auto`占位符 (Abbreviated function template)

    对于函数模板, 如果不想显式写出`template<...>`, 可以使用`auto`.

    ```cpp
    void print_integer(Integral auto value) {
        // ...
    }
    ```

Concepts的优势:

1.  极高的可读性: `template<Integral T>`远比复杂的SFINAE实现要清晰易懂, 代码意图一目了然.
2.  清晰的编译错误信息: 这是Concepts最显著的优点之一. 如果你尝试用一个不满足Concept的类型去实例化模板, 编译器会直接告诉你"模板参数'T' (例如'double') 不满足概念'Integral'".

    未使用Concept的错误 (可能长达数页):

    ```
    error: no matching function for call to 'print_integer(double)'
    note: candidate: 'template<class T> void print_integer(T)'
    note:   template argument deduction/substitution failed:
    ... (大量无关的SFINAE错误信息)
    ```

    使用Concept的错误 (清晰明了):

    ```
    error: cannot call function 'void print_integer(T) [with T = double]'
    note:   concept constraint 'Integral<double>' was not satisfied
    ```

3.  语法简化: 提供了多种简洁的语法来约束模板, 使代码更紧凑.
4.  更好的重载决议: 编译器会优先选择约束最严格的模板重载, 使得函数重载行为更加符合直觉.

#### 何时需要`requires`

当你的概念定义需要检查表达式的有效性 (例如, 成员是否存在, 函数能否调用, 表达式能否通过编译) 而不是直接使用一个现成的布尔常量时, 你就需要`requires`关键字. `requires`关键字引入一个`requires-expression`, 用于陈述这些语法要求.

1.  直接布尔表达式

    这种形式检查一个编译期的值.

    ```cpp
    // std::is_integral_v<T> 在编译期返回 true 或 false.
    template<typename T>
    concept Integral = std::is_integral_v<T>;
    ```

2.  `requires`表达式:

    这种形式检查一段代码在语法上是否有效.

    ```cpp
    template<typename T>
    concept Hashable = requires(T a) {
        // 检查 std::hash<T>{}(a) 这个表达式是否能通过编译
        { std::hash<T>{}(a) } -> std::convertible_to<std::size_t>;
    };
    ```

    在`Hashable`的例子中, 我们并不关心`std::hash`在编译期求出的具体值是多少. 我们只关心`std::hash<T>`这个类型是可用的, 并且它的调用结果可以转换为`std::size_t`. 这种对语法结构有效性的检查正是`requires`表达式的用途.

总结来说, `requires`关键字用于引入一个检查语法要求的块; 如果你的概念可以直接由一个编译期布尔值来定义, 那么`requires`就是非必需的.
