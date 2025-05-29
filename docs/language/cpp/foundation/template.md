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
