---
title: 函数
comments: false
---

Go语言中的函数定义有以下特点:

*   **无需声明原型**: 无需在使用前声明函数原型.

    在Go语言中. 你不需要像C或C++那样. 在使用函数之前单独声明函数的原型 (即函数的签名). 你可以直接定义函数. 然后在代码的任何地方调用它. 编译器会自动识别函数的存在.

        例如:

        ```go
        package main

        import "fmt"

        func main() {
            // 在定义 calculate 函数之前就可以调用它
            result := calculate(10, 20)
            fmt.Println(result)
        }

        func calculate(a, b int) int {
            return a + b
        }
        ```

        在这个例子中. `main` 函数在 `calculate` 函数被定义之前就调用了它. 如果是在C语言中. 你需要在 `main` 函数之前声明 `calculate` 函数的原型.



*   **支持不定变参**: 函数可以接受数量可变的参数.
*   **支持多返回值**: 函数可以返回多个值.
*   **支持命名返回参数**: 可以为返回值命名.

    Go语言允许你为函数的返回值命名. 这样做的主要好处是. 你可以在函数体内部直接使用这些命名参数. 并且在函数结束时. 如果没有显式地使用 `return` 语句指定返回值. 命名返回参数的值会自动作为函数的返回值返回. 这被称为 "裸返回" (naked return).

        例如:

        ```go
        package main

        import "fmt"

        func divide(numerator, denominator int) (result int, err error) {
            if denominator == 0 {
                err = fmt.Errorf("不能除以零")
                return // 裸返回. 返回 result 的零值和 err 的值
            }
            result = numerator / denominator
            return // 裸返回. 返回 result 的值和 err 的零值
        }

        func main() {
            res1, err1 := divide(10, 2)
            if err1 != nil {
                fmt.Println("错误:", err1)
            } else {
                fmt.Println("结果:", res1)
            }

            res2, err2 := divide(10, 0)
            if err2 != nil {
                fmt.Println("错误:", err2)
            } else {
                fmt.Println("结果:", res2)
            }
        }
        ```

        在这个例子中. `divide` 函数的返回值被命名为 `result` 和 `err`. 在函数体内部. 我们可以直接给 `result` 和 `err` 赋值. 然后使用 `return` 语句不带任何参数. 它们的值就会被作为函数的返回值返回. 这种方式可以提高代码的可读性. 尤其是在处理多个返回值时.

*   **支持匿名函数和闭包**: 可以定义没有名称的函数和闭包.
*   **函数也是一种类型**: 函数可以赋值给变量.
*   **不支持嵌套**: 包内不能有两个同名函数.
*   **不支持重载**: 不支持函数重载.
*   **不支持默认参数**: 不支持默认参数.

**函数声明**:

函数声明包括函数名. 参数列表. 返回值列表和函数体. 如果函数没有返回值. 返回值列表可以省略. 函数从第一条语句开始执行. 直到执行 `return` 语句或函数最后一条语句.

**示例**:

```go
func test(x, y int, s string) (int, string) {
    // 类型相同的相邻参数, 参数类型可合并. 多返回值必须用括号.
    n := x + y
    return n, fmt.Sprintf(s, n)
}
```

函数是第一类对象. 可以作为参数传递. 建议将复杂签名定义为函数类型. 以便阅读.

**示例**:

```go
package main

import "fmt"

func test(fn func() int) int {
    return fn()
}
// 定义函数类型.
type FormatFunc func(s string, x, y int) string

func format(fn FormatFunc, s string, x, y int) string {
    return fn(s, x, y)
}

func main() {
    s1 := test(func() int { return 100 }) // 直接将匿名函数当参数.

    s2 := format(func(s string, x, y int) string {
        return fmt.Sprintf(s, x, y)
    }, "%d, %d", 10, 20)

    println(s1, s2)
}
```

有返回值的函数必须有明确的终止语句. 否则会引发编译错误. 有时会遇到没有函数体的函数声明. 这表示该函数不是用Go实现的. 例如在汇编语言中实现的函数.

## 参数

1.  **函数参数**:
    *   **形参和实参**: 函数定义时的参数称为形参. 调用函数时传入的变量称为实参.
    *   **值传递**: 调用函数时复制实参的值给形参. 在函数内部修改参数不会影响实参. Go 语言默认使用值传递.
    *   **引用传递**: 调用函数时传递实参的地址给形参. 在函数内部修改参数会影响实参. `map`, `slice`, `chan`, 指针, `interface` 默认以引用方式传递. 引用传递通常比值传递更高效.
2.  **不定参数 (可变参数)**:
    *   Go 语言中的可变参数本质上是 `slice`.
    *   一个函数只能有一个可变参数 且 必须是最后一个参数.
    *   可变参数可以是零个或多个 (例如 `func myfunc(args ...int)`).
    *   可以使用 `args[index]` 访问参数. `len(args)` 获取参数个数.
    *   **任意类型的不定参数**: 使用 `...interface{}` 传递任意类型数据. `interface{}` 是类型安全的.
    *   当使用 `slice` 对象作为可变参数时, 必须使用 `slice...` 的形式展开 `slice`.

## `if`语句

Go语言的if语句用于根据布尔表达式的真假决定是否执行代码块

**基本语法**
```
if 条件表达式 {
    // 条件为 true 时执行
}
```
* condition 必须返回布尔值
* 大括号是必须的, 不能省略

**带初始化语句**
```
if init; 条件 {
    // init 在条件计算前执行, 作用域仅限本 if 语句块
}
```
示例:
```
if n := len(s); n > 0 {
    fmt.Println(s[n-1])
}
```

**else 分支**
```
if 条件 {
    // true
} else {
    // false
}
```

**else if 链**(可以多次嵌套)
```
if a > b {
    // a 大于 b
} else if a == b {
    // a 等于 b
} else {
    // a 小于 b
}
```

**嵌套 if**(在 if 或 else if 块内部再写 if)
```
if x > 0 {
    if y > 0 {
        fmt.Println("x 和 y 都为正")
    }
}
```

**要点**
- Go 没有三元运算符, 必须使用 if...else 完成条件选择
- 条件表达式不需要圆括号, 圆括号会被当成表达式的一部分而非语法要求
- init 语句与条件之间用分号 `;` 分隔, 分号是必须的

**完整示例**
```
package main

import "fmt"

func main() {
    a := 100
    b := 200

    if a == 100 {
        if b == 200 {
            fmt.Println("a 为 100 且 b 为 200")
        }
    } else {
        fmt.Println("a 不等于 100")
    }
}
```

运行结果:
```
a 为 100 且 b 为 200
```

## `for`循环

Go 语言只有一个循环关键字 for, 它可以实现 while, do‑while, foreach 等所有常见循环形式. 下面逐一说明常用写法及要点.

**1. 经典三段式**
```go
for i := 0; i < 10; i++ {
    fmt.Println(i)
}
```
init, condition, post 三部分都可以省略; 省略的部分对应的空语句不写即可.

**2. while 形式**
```go
j := 0
for j < 5 {
    fmt.Println(j)
    j++
}
```
只有 condition, 等价于 C 系语言的 while 循环.

**3. 无限循环**
```go
for {
    // 业务代码
    if stop {
        break
    }
}
```
condition 省略后默认始终为 true.

**4. range 循环(遍历)**
```go
arr := []int{1,2,3}
for idx, val := range arr {
    fmt.Println(idx, val)
}
```
可以遍历数组, 切片, 字符串, map, channel. 若只需要索引或值, 可使用 `_` 丢弃不需要的变量, 例如 `for _, v := range m {}`.

**5. 循环控制语句**
- `break` 立即结束最近的 for 循环.
- `continue` 跳过本次迭代, 直接进入下一次循环判断.
- 带标签的 break/continue 用于多层循环, 例如:
  ```go
  outer:
  for i := 0; i < 3; i++ {
      for j := 0; j < 3; j++ {
          if i+j == 3 {
              break outer   // 跳出外层循环
          }
      }
  }
  ```

**6. 常见注意点**
- init, condition, post 均可省略, 但分号仍需保留(省略时直接写 `for {}` 或 `for condition {}`).
- `range` 返回的第一个值对切片, 数组是索引, 对 map 是键.
- 变量在 for 循环内部声明(如 `for i := 0; ...`)的作用域仅限于该循环体.

掌握以上几种写法后, 基本可以覆盖所有 Go 项目中的循环需求.

## 返回值

这篇文档讲解了 Go 语言函数返回值的用法, 主要内容包括:

1. **返回值的命名**
   在函数声明的返回列表中可以给返回值起名字, 如 `func add(a, b int) (c int)`, 这样在函数体内可以直接给 `c` 赋值, 最后通过 `return` 返回, 也可以省略返回值表达式.

2. **使用 `_` 忽略返回值**
   当只需要其中的部分返回值时, 可以使用占位符 `_` 把不需要的值丢弃, 如 `x, _ := test()`.

3. **多返回值**
   Go 支持一次返回多个值, 直接在 `return` 后列出对应的表达式, 也可以使用 `return` 直接返回已有的多值表达式, 例如 `return a+b, (a+b)/2`.

4. **直接在调用中使用返回值**
   多返回值可以直接作为其他函数的参数传递, 如 `println(add(test()))` 或 `println(sum(test()))`.

5. **命名返回值与 `defer` 交互**
   `defer` 函数可以访问并修改命名返回值, 因为 `defer` 在函数返回前执行, 所以对返回值的修改会影响最终的返回结果. 示例:`defer func(){ z += 100 }(); z = x+y; return` 返回 `z+100`.

6. **显式返回与隐式返回的区别**
   当使用命名返回值时, `return` 可以省略表达式, 直接返回当前命名变量的值; 若不使用命名返回值, `return` 必须跟随返回表达式, 否则会报 "multiple-value … in single-value context" 错误.

7. **注意变量遮蔽**
   在同一作用域内不能声明同名的局部变量遮蔽返回值变量, 否则需要显式返回遮蔽的变量或改名.

通过这些要点, 开发者可以灵活地在 Go 中使用返回值来简化代码结构并提升可读性.
