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
