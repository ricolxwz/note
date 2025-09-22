---
title: 对象
comments: false
---

# 对象

## 匿名字段

匿名字段(又称结构体嵌入)是 Go 中只写类型而不写字段名的写法, 例如:

```go
type Person struct {
    name string
    sex  string
    age  int
}

type Student struct {
    Person        // 匿名字段, 等价于 Person Person
    id   int
    addr string
}
```

特点:

1. **直接访问**: 嵌入的字段在外层结构体上可以直接使用, 如 `s.Name` 实际等价于 `s.Person.Name`.
2. **支持任意类型**: 不仅可以嵌入结构体, 还可以嵌入指针, 内置类型, 自定义别名类型等.
3. **同名字段冲突**: 若外层结构体和嵌入结构体都有同名字段, 需要使用完整路径(如 `s.Person.Name`)来消除歧义.
4. **指针嵌入**: 使用 `*Person` 进行嵌入后, 外层结构体持有指向嵌入对象的指针, 访问时同样直接 `s.Name`.

匿名字段实现了组合而不是继承, 使得结构体可以复用已有类型的字段和方法, 同时保持类型的独立性.

## 接口

Go语言中的接口(interface)是一种抽象类型, 用于定义对象的行为规范. 下面对接口的关键概念进行简要说明, 帮助你快速掌握:

### 接口定义
```go
type Sayer interface {
    Say()
}
```
- **接口名**: `Sayer`
- **方法集合**: 只包含一个 `Say` 方法, 无实现, 只描述行为.
### 实现接口的方式
#### 结构体实现

```go
type dog struct{}
func (d dog) Say() { fmt.Println("汪汪汪") }

type cat struct{}
func (c cat) Say() { fmt.Println("喵喵喵") }
```
- **值接收者**: `dog`, `cat` 的 `Say` 方法使用值接收者, 既实现了 `Sayer` 接口.

#### 接口变量存储实现
```go
var x Sayer
x = dog{}    // 存储 dog 实例
x.Say()      // 输出: 汪汪汪
x = cat{}    // 存储 cat 实例
x.Say()      // 输出: 喵喵喵
```
- **多态**: 同一接口变量可以保存不同类型的实例, 只要它们实现了接口方法.

### 接口与结构体的关系
- **一个结构体可实现多个接口**: 只需要为每个接口提供对应的方法即可.
- **多个结构体实现同一接口**: 实现同一行为的不同对象.

### 接口嵌套(组合)
```go
type Mover interface {
    Move()
}
type Animal interface {
    Sayer
    Mover
}
```
- `Animal` 同时拥有 `Sayer` 与 `Mover` 的方法集合, 实现该接口的结构体必须同时实现 `Say` 与 `Move`.

### 空接口(interface{})
```go
var any interface{}
any = "string"
any = 123
any = true
```
- **用途**: 可以存放任意类型的值, 常用于函数参数, 映射(map)或切片(slice)等需要通用容器的场景.

### 类型断言 & 类型判断
#### 类型断言
```go
if v, ok := any.(string); ok {
    fmt.Println(v) // 此处 v 为 string 类型的值
}
```
- **返回值**: 断言成功返回具体类型值和 `true`, 失败返回零值和 `false`.

#### 类型判断(switch)
```go
switch v := any.(type) {
case string:
    fmt.Println("string:", v)
case int:
    fmt.Println("int:", v)
default:
    fmt.Println("unknown")
}
```
- **`type` 关键字**: 在 `switch` 中使用可判断接口实际保存的具体类型.

### 接口实现要点
- **方法签名必须完全匹配**(名称, 参数, 返回值).
- 接口实现是 **隐式** 的, 无需显式声明 "实现了某接口".
- **值接收者** 能实现接口的值接收调用; **指针接收者** 只能通过指针或通过 `&` 取地址后使用.

### 常见面试题示例(代码能否编译? )
```go
type People interface {
    Speak(string) string
}
type Student struct{}
func (stu *Student) Speak(think string) (talk string) {
    if think == "sb" {
        talk = "你是个大老板"
    } else {
        talk = "您好"
    }
    return
}
```
- **结论**: 此代码**不能**编译. `Student` 使用指针接收者实现 `Speak`, 但是 `People` 接口要求的是值接收者, 导致 `Student` 未实现 `People` 接口. 修改为 `func (stu Student) Speak(...)` 或将接口变量声明为指针类型即可.

### 小结
- **接口**描述对象行为, **实现**通过提供对应方法完成.
- **空接口**是所有类型的父类, 用于通用容器.
- **类型断言**与 **类型判断**帮助在运行时获取具体类型信息.
熟练掌握这些概念, 你就可以在 Go 项目中灵活使用接口, 实现解耦, 可扩展的代码结构.
