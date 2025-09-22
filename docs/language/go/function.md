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

## 匿名函数

- 匿名函数指没有函数名的函数, 可直接在代码中定义并使用
- 在 Go 中使用 `func` 关键字定义匿名函数, 常用于一次性调用或作为变量赋值
- 示例: `getSqrt := func(a float64) float64 { return math.Sqrt(a) }` 调用 `getSqrt(4)` 输出 2
- 匿名函数可以赋值给变量, 存入切片, 作为结构体字段, 放入 channel 等
- 常见用法包括函数变量, 函数集合, 结构体字段, channel 传递等示例展示
- 匿名函数的优势在于可以直接使用外部变量, 无需显式声明函数名

## 闭包

Go 语言的闭包是指函数可以捕获并引用其外部作用域中的变量, 即使外部函数已经返回, 内部函数仍然可以访问这些变量.

关键点:

- 闭包本质上是一个匿名函数或具名函数, 内部引用了外部函数的局部变量.
- 每次调用外部函数都会生成一个新的闭包实例, 捕获的变量会保持独立.
- 闭包常用于延迟执行, 状态保存, 函数式编程等场景.

示例代码

```go
package main

import "fmt"

func counter() func() int {
    i := 0               // i 属于外部函数的局部变量
    return func() int { // 匿名函数形成闭包, 捕获 i
        i++
        return i
    }
}

func main() {
    inc := counter() // 获得闭包实例
    fmt.Println(inc()) // 1
    fmt.Println(inc()) // 2

    // 再生成一个独立的闭包
    another := counter()
    fmt.Println(another()) // 1
}
```

解释:

- `counter` 返回一个匿名函数, 该函数在执行时会访问并修改 `i`.
- `inc` 和 `another` 分别是两个闭包实例, 它们各自持有独立的 `i`, 因此计数不互相影响.

### 逃逸分析

在 Go 中, 闭包会捕获外部函数的局部变量. 编译器需要保证这些变量在闭包存活期间仍然有效, 于是会把它们从栈"逃逸"到堆.

**逃逸分析的关键点**:

- 当一个局部变量的地址被闭包返回或被传递到另一个 goroutine 时, 编译器判定该变量可能在函数返回后仍被使用.
- 此时变量会在堆上分配, 闭包持有对堆对象的引用.
- 逃逸的决定在编译阶段完成, `go build -gcflags="-m"` 可以查看具体的逃逸报告.

**示例**

```go
package main

import "fmt"

func makeAdder(x int) func(int) int {
    // x 的地址被返回的匿名函数引用, x 必须逃逸到堆
    return func(y int) int {
        return x + y
    }
}

func main() {
    add5 := makeAdder(5)
    fmt.Println(add5(3)) // 8
}
```

运行 `go build -gcflags="-m"` 会得到类似 "x escapes to heap".

**为什么要逃逸**:

- 栈的生命周期随函数调用结束而销毁, 不能保证闭包在函数外部仍能访问.
- 堆的生命周期由垃圾回收管理, 闭包持有的引用可以在任何时刻安全使用.

**性能注意**:

- 堆分配比栈分配稍慢, 且会增加 GC 压力.
- 如果闭包在函数内部立即调用且不返回, 可以使用 `func(){}` 直接捕获局部变量, 编译器通常会继续把它们放在栈上, 从而避免逃逸.

总结: 闭包捕获的变量如果在函数返回后仍被使用, 就会触发逃逸分析, 被分配到堆上, 以保证闭包的正确性和内存安全.

## 延迟调用

延迟调用(defer)在 Go 中用于在函数返回前执行清理操作. 特性包括: 1. defer 注册的函数在 return 前执行; 2. 多个 defer 按后进先出顺序执行; 3. defer 参数在注册时就确定.

使用场景:

- 关闭文件或网络连接
- 释放锁
- 事务提交或回滚

注意事项:

- defer 会产生性能开销, 循环中大量使用需慎重
- 若在错误路径未成功获取资源, 需检查后再 defer
- 使用闭包时, 变量在 defer 注册时已捕获, 避免闭包陷阱

示例:

```go
func main() {
    f, err := os.Open("file.txt")
    if err != nil { log.Fatal(err) }
    defer f.Close()        // 确保文件关闭

    // 业务代码
}
```

## 异常

异常处理概述

1. Go 没有结构化异常, 使用 panic 抛出异常, recover 捕获异常.

2. panic 与 defer:
   - panic 触发后, 当前函数立即停止执行, 随后执行已注册的 defer.
   - defer 按注册顺序逆序执行, 若其中再次 panic, 则后续的 defer 仍会执行.

3. recover 用法:
   - 必须在 defer 中调用, 否则无效.
   - recover 捕获到的异常为 interface{}, 可转型为具体错误类型或 string.

4. 常见场景:
   - 向已关闭的通道发送数据会 panic: `send on closed channel`.
   - 延迟函数内部 panic, 只会被外层的 defer recover 捕获.

5. 推荐做法:
   - 用 error 返回值表示可预期错误; 仅在不可恢复的错误或程序员错误时使用 panic.
   - 可封装 Try/ Catch 结构:

```go
func Try(fn func(), handler func(interface{})) {
    defer func() {
        if err := recover(); err != nil {
            handler(err)
        }
    }()
    fn()
}
```

6. 示例:

```go
func main() {
    Try(func() { panic("test panic") },
        func(e interface{}) { fmt.Println(e) })
}
```

输出: `test panic`

7. 结论: 使用 panic/recover 处理不可恢复的异常, 业务错误请返回 error.

## 方法

方法定义简要说明:

1. 基本语法
   `func (receiver type) MethodName(params) (results) { … }`
   *receiver* 只能是当前包内定义的类型或其指针, 不能是接口或指针.
   接收者可以是值 `T` 也可以是指针 `*T`.

2. 示例
   ```go
   type Test struct{}
   // 无参数, 无返回
   func (t Test) method0() {}

   // 单参数, 无返回
   func (t Test) method1(i int) {}

   // 多参数, 无返回
   func (t Test) method2(x, y int) {}

   // 无参数, 单返回
   func (t Test) method3() (i int) { return }

   // 多参数, 多返回
   func (t Test) method4(x, y int) (z int, err error) { return }
   ```

3. 值接收者 vs 指针接收者
   * 值接收者: 方法内部操作的是副本, 修改不会影响原对象.
   * 指针接收者: 方法接收对象指针, 内部修改会改变原对象.

4. 调用方式
   ```go
   u := User{Name:"go", Email:"go@go.com"}
   u.Notify()          // 值调用, 编译器会自动取地址调用指针方法
   p := &u
   p.Notify()          // 指针调用
   ```

5. 关键点
   - 同一类型可以同时拥有值接收者和指针接收者的方法.
   - 方法只能在同一包内为自定义类型定义, 不能为内置类型或接口添加方法.
   - 编译器在调用时会自动在值与指针之间做转换(满足条件时).

### 匿名字段

匿名字段是 Go 结构体的一种嵌入方式, 能够让外部结构体直接访问嵌入结构体的字段和方法, 类似于继承但没有显式的子类关系. 代码示例和解释如下:

```go
package main

import "fmt"

type User struct {
    id   int
    name string
}
type Manager struct {
    User               // 匿名字段, 嵌入 User
    title string
}

// User 方法
func (self *User) ToString() string {
    return fmt.Sprintf("User: %p, %v", self, self)
}

// Manager 自己的 ToString 方法会覆盖嵌入的 User 方法
func (self *Manager) ToString() string {
    return fmt.Sprintf("Manager: %p, %v", self, self)
}

func main() {
    m := Manager{
        User:  User{1, "Tom"},
        title: "Administrator",
    }
    fmt.Println(m.ToString())            // 调用 Manager 的 ToString
    fmt.Println(m.User.ToString())        // 调用 User 的 ToString
}
```

输出:

```
Manager: 0xc420074180, &{{1 Tom} Administrator}
User: 0xc420074180, &{1 Tom}
```

要点:
- 匿名字段使嵌入结构体的字段和方法可以被外层结构体直接访问.
- 外层结构体可以自行实现同名方法, 这会覆盖嵌入结构体的方法(实现 override).
- 通过 `m.User` 可以显式访问嵌入结构体的成员或方法.

### 方法集

方法集是指为结构体或指针类型定义的所有方法, 规则如下:

1. 类型 T(值)只拥有使用 T 作为接收者的方法;
2. 类型 *T(指针)拥有使用 T 与 *T 作为接收者的方法;
3. 若结构体 S 嵌入了匿名字段 T, 则 S 与 *S 都拥有 T 的方法;
4. 若结构体 S 嵌入了匿名字段 *T, 则 S 与 *S 都拥有 T 与 *T 的方法;
5. 对于嵌套结构体, 编译器会提升(promote)内部字段的方法到外层结构体, 使得外层结构体也能直接调用这些方法.

### 表达式

表达式章节内容概述如下:

1. 表达式
   - Go 方法有两种调用形式: method value 与 method expression.
   - `instance.method(args...)` 实际转换为 `<type>.func(instance, args...)`.
   - 前者称为 method value, 后者称为 method expression.
   - 两者都像普通函数一样可赋值和传参, 但区别在于:
     * method value 会绑定实例(receiver)并复制, 之后再修改实例不影响已绑定的函数.
     * method expression 不绑定实例, 需要在调用时显式传递 receiver.

2. 示例代码
   ```go
   type User struct {
       id   int
       name string
   }

   func (self *User) Test() {
       fmt.Printf("%p, %v\n", self, self)
   }

   func main() {
       u := User{1, "Tom"}
       u.Test()                     // 直接调用

       // method value: 绑定 receiver
       mv := u.Test
       mv()                         // receiver 已经绑定

       // method expression: 不绑定, 需要显式传递 receiver
       me := (*User).Test
       me(&u)                       // 显式传递 receiver
   }
   ```

3. 关键点
   - method value 会捕获当前 receiver 的拷贝, 后续对原实例的修改不影响该函数.
   - method expression 只是在编译期产生函数指针, 不绑定实例, 调用时必须显式传递 receiver.
   - 对值接收者(非指针)的方法, method value 会复制 receiver 的值; 对指针接收者的方法, method value 绑定指针地址.

4. 其它说明
   - 将方法"还原"为普通函数后, 更容易理解其内部实现.
   - 方法表达式可用于泛型或函数式编程场景, 如传递给高阶函数.
   - 方法值在闭包环境中常用于延迟执行或回调.

### 自定义error

1. **系统 panic**: 直接调用 panic 抛出错误, 适用于不可恢复的异常.
2. **返回 error**: 函数返回 (value, error) 形式, 由调用方检查 error 并处理, 适用于可恢复的错误.
3. **自定义 error 类型**: 实现 error 接口的结构体, 包含 path, op, createTime, message 等字段, 可在调用方通过 type assertion 捕获并获取详细信息.
