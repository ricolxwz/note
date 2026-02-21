---
title: 调试
comments: false
icon: material/mirror
---

## `assert`的用法

C++ 中的`assert`用于在代码中插入检查点, 以验证某个条件是否为真. 如果条件为假(即表达式的值为0), `assert`将会输出错误信息并终止程序的执行.

```
#include <cassert>

int main() {
  int x = 10;
  int y = 5;
  assert(x > y); // 条件为真, 程序继续执行
  assert(x < y); // 条件为假, assert 会触发, 输出错误信息并终止程序
  return 0;
}
```

输出:

```bash
proj: main.cpp:7: int main(): Assertion `x < y' failed.
Aborted (core dumped)
```

上述的这个`assert`是运行时检查的, 还有一个`static_assert`是编译时检查的, 但是它检查的必须是`const`量. 

```cpp
#include <cassert>

int main() {
  const int x = 10;
  const int y = 5;
  static_assert(x > y); // 条件为真, 程序继续执行
  static_assert(x < y); // 条件为假, assert 会触发, 输出错误信息并终止程序
  return 0;
}
```

输出:

```
main.cpp: In function ‘int main()’:
main.cpp:7:19: error: static assertion failed
    7 |   static_assert(x < y); // 条件为假, assert 会触发, 输出错误信息并终止程序
      |                 ~~^~~
```

可以和`constexpr`一起用, 因为它本质上是一个`const`. 