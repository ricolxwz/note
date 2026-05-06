---
title: 软件工程
comments: false
---

## Java

### 自动拆箱/装箱

* 装箱: 将基本数据类型转换为包装类型, 例如`int`转换为`Integer`
* 拆箱: 将包装类型转换为基本数据类型

```java
Integer i = 10;  //装箱
int n = i;   //拆箱
```

### `&`和`&&`的区别

`&`是逻辑与, `&&`是短路与, 这两个差别很大, `&&`之所以叫做短路与是因为, 如果左边的表达式值是`false`, 右边的表达式会直接短路掉, 不会进行运算.

逻辑或`|`和短路或`||`也是一样的道理.

### 自动类型转换, 强制类型转换

当把一个范围较小的数值或者变量赋值给另一个范围较大的变量的时候, 会进行自动类型转换, 反之, 需要强制类型转换.

1. `float f = 3.4`对吗? 不正确, 因为`3.4`默认是双精度, 将双精度复制给浮点型属于down casting, 会造成精度丢失, 所以需要强制类型转换.
2. `short s1 = 1; s1 = s1 + 1`对吗, `short s1 = 1; s1 += 1`对吗? 前者会编译出错, 因为`1`是int类型, 因此计算结果也是int型, 需要强制类型转换才能赋值给short型; 后者因为`s1 += 1`相当于`s1 = (short(s1 + 1))`, 有隐含的强制类型转换.

### Boolean类型实际占用几个字节

Java虚拟机规范中, 没有明确规定boolean类型的大小, 实测是1个字节.

### `switch`是否可以用在byte/long/String上

Java 5 以前 switch(expr) 中, expr 只能是 byte, short, char, int. 从 Java 5 开始, Java 中引入了枚举类型,  expr 也可以是 enum 类型. 从 Java 7 开始, expr 还可以是字符串. 从 Java 21 开始, switch 语句迎来了根本性的变革, 不仅可以处理 long 类型, 也能处理包括 null 在内的任意对象类型, 并可通过 when 子句添加复杂的判断条件.

### `break`, `continue`, `return`的区别和作用

`break`跳出整个循环, 不再执行循环(结束当前的循环体). `continue`跳出本次循环, 继续执行下次循环(结束正在执行的循环, 进入下一个循环条件). `return`程序返回, 不再执行下面的代码(结束当前的方法 直接返回)

### 用效率最高的方法计算2*8

`2 << 3`.

### 说说自增/自减运算

用一句口诀就是: "符号在前就先加/减, 符号在后就后加/减".

```java
int i  = 1;
i = i++;
System.out.println(i);
```

```java
int count = 0;
for(int i = 0;i < 100;i++)
{
    count = count++;
}
System.out.println("count = "+count);
```

答案都是`0`.

### 数据准确性高是如何保证的

在金融计算中, 保证数据准确性有两种方案, 一种使用`BigDecimal`, 另一种将浮点数转换为整数`int`进行计算(即将金额统一放大, 如1.23元放到到123分). 肯定不能使用`float`或者`double`类型, 他们无法避免浮点数运算中常见的精度问题.

### 面向对象和面向过程的区别

面向过程是以过程为核心, 通过函数完成任务. 面向对象是以对象为核心, 通过对象交互完成任务, 程序结构是类和对象组成的模块化结构, 代码可以通过继承, 组合, 多态等方式复用.

### 面向对象编程有哪些特性

* 封装: 封装是指将数据(属性, 或者叫字段)和操作数据的方法捆绑在一起, 形成一个独立的对象(类的实例).
* 继承: 继承是允许一个类继承现有类的属性和方法, 以提高代码的复用性, 建立类之间的层次关系. 同时, 子类还可以重写或者扩展从父类继承来的属性和方法, 从而实现多态
* 多态: 多态允许不同类的对象对同一消息做出响应, 但是表现出不同的行为

为什么Java里面要多组合少继承?

继承适合描述"is-a"的关系, 但继承容易导致类之间的强耦合, 一旦父类发生改变, 子类也要随之改变, 违反了开闭原则. 组合适合描述"has-a"或者"can-do"的关系, 通过在类中组合其他类, 能够更灵活地扩展功能. 组合避免了复杂的类继承体系, 同时遵循了开闭原则和松耦合的设计原则.

### 多态的实现原理

多态指同一个接口或者方法在不同的类中有不同的实现, 比如动态绑定, 父类引用指向子类对象, 方法的具体调用会延迟到运行时决定. 多态通过动态绑定实现, Java使用虚方法表存储方法指针, 方法调用时根据对象实际类型从虚方法表查找具体实现.

<figure markdown='1' id='fig'>
![](https://img.ricolxwz.cn/e9a3bc99c4e19261767803197a6cc655.webp#only-light){ loading=lazy width='800' }
![](https://img.ricolxwz.cn/e9a3bc99c4e19261767803197a6cc655_inverted.webp#only-dark){ loading=lazy width='800' }
</figure>

### 重载和重写的区别

如果一个类有多个名字相同但是参数个数不同的方法, 我们通常称这些方法为方法重载. 如果子类具有和父类一样的方法(参数相同, 返回类型相同, 方法名相同, 但是方法体不同), 我们称之为重写.

### `public`, `private`, `protedted`以及默认时的区别

Java支持4种不同的访问权限.

* 默认: 在同一包里面可见, 不使用任何修饰符, 可以修饰类, 接口, 变量, 方法
* `private`: 在同一类可见, 可以修饰变量, 方法, 但是不能修饰类
* `public`: 对所有类可见, 可以修饰类, 接口, 变量, 方法
* `protedted`: 对同一个包内的类和所有子类可见, 可以修饰变量, 方法, 但是不能修饰类

### `this`关键字的作用

`this`是自身的一个对象, 代表对象本身, 可以理解为: 指向对象本身的一个指针. `this`的用法在Java中大体可以分为三种,

1. 普通的直接引用, `this`相当于是指向当前的对象本身
2. 形参和成员变量名字重名, 用她来区分
3. 引用本类的构造方法

    ```java
    class Person {
        String name;
        int age;

        Person() {
            this("Unknown", 0);
        }

        Person(String name, int age) {
            this.name = name;
            this.age = age;
        }
    }
    ```

### 抽象类和接口的区别

| 对比维度    | 抽象类(Abstract Class)           | 接口(Interface)                   |
| ------- | ----------------------------- | ------------------------------- |
| 定义      | 描述一类事物的共性                     | 定义行为规范/能力                       |
| 关键字     | `abstract class`              | `interface`                     |
| 实例化     | ❌ 不能实例化                       | ❌ 不能实例化                         |
| 方法类型    | 抽象方法 + 具体方法                   | 抽象方法(Java8+支持 default / static) |
| 方法访问权限  | 任意(public/protected/private等) | 默认 public(Java9+支持 private)     |
| 成员变量    | 普通变量                          | 常量(public static final)📌       |
| 构造方法    | ✔ 有(供子类调用)                    | ❌ 没有                            |
| 继承方式    | 单继承(extends)                  | 多实现(implements)⚠️               |
| 是否支持多继承 | ❌ 不支持                         | ✔ 支持(可实现多个接口)                   |
| 代码复用    | ✔ 强(可写具体实现)                   | ❌ 弱(主要定义规范)                     |
| 设计目的    | 抽象共性 + 代码复用                   | 解耦系统 + 定义能力                     |
| 关系本质    | is-a(是什么)                     | can-do(能做什么)⚙️                  |
| 使用场景    | 有明确继承关系的类层次                   | 不同类实现相同能力                       |
| 示例      | Animal, Vehicle                | Flyable, Runnable                |

### 成员变量和局部变量的区别

1. 位置不同: 成员变量在类里面, 方法外; 局部变量在方法里面或者方法参数里
2. 修饰符不同: 成员变量可以加`public/private/static/final`等等; 局部变量不能加`public/private/static`, 但是可以加`final`
3. 生命周期不同: 成员变量跟着对象活着, 对象还在它就在, 局部变量方法一结束就没了
4. 默认值不同: 成员变量如果没赋值, Java会给默认值, 局部变量必须自己赋值后才能用, 不然编译会报错.

### `static`关键字

1. 修饰变量: `static`修饰变量后, 这个变量叫做静态变量/类变量
2. 修饰方法: `static`修饰方法后, 这个方法叫做静态方法/类方法
3. 修饰代码块: `static`修饰代码块, 叫做静态代码块, 类加载的时候执行一次

    ```java
    class Demo {
        static {
            System.out.println("类加载了");
        }
    }
    ```

    它常用来初始化一些只需要准备一次的数据.

4. 修饰内部类: 内部类如果加`static`, 叫做静态内部类

    ```java
    class Outer {
        static class Inner {
        }
    }
    ```

    它虽然写在外部类里面, 但是不依赖外部类对象.

    ```java
    Outer.Inner obj = new Outer.Inner();
    ```

### `final`, `finally`, `finalize`的区别

* `final`是一个修饰符, 可以修饰类, 方法和变量. 当`final`修饰一个类的时候, 表明这个类不能被继承; 当`final`修饰一个方法的时候, 表明这个方法不能被重写; 当`final`修饰一个变量的时候, 表明这个变量是个常量, 一旦赋值之后, 就不能再被修改了. 
* `finally`是Java中异常处理的一部分, 用来创建`try`块后面的`finnally`块. 无论`try`块中的代码是否抛出异常, `finally`块中的代码总是会被执行. 通常, `finally`块被用来释放资源, 如关闭文件, 数据库连接等. 
* `finalize`是Object类的一个方法, 用来在垃圾回收器将对象从内存中清除出去之前做一些必要的清理工作. 这个方法在垃圾回收器准备释放对象占用的内存之前被自动调用. 我们不能显式地调用`finalize`方法, 因为它总是由垃圾回收器在适当的时间自动调用. 

### `==`和`equals`的区别

在Java中, `==`和`equals()`方法用于比较两个对象. 

* `==`用来比较两个对象的引用, 即他们是否指向同一个对象实例. 如果两个变量引用同一个对象实例, `==`返回`true`, 否则返回`false`. 对于基本数据类型, `==`比较值是否相等
* `equals()`用来比较两个对象的内容是否相等. 默认情况下, `equals()`方法的行为和`==`相同, 即比较对象引用. 然而, `equals()`是可以被各种类重写的. 例如, `String`类重写了`equals()`方法, 以便它可以比较两个字符串的字符内容是否完全一样. 

### 为什么重写`equals()`的时候必须重写`hashCode()`方法

因为基于哈希的集合类, 如HashMap需要基于这一点来正确存储和查找对象. 很多集合以来`hashCode()`先分组, 然后再用`equals()`判断是否真相等, 比如`HashMap`, `HashSet`, `Hashtable`. 

```java
class User {
    String name;
    User(String name) {
        this.name = name;
    }
    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (!(obj instanceof User)) return false;
        User other = (User) obj;
        return Objects.equals(name, other.name);
    }
    @Override
    public int hashCode() {
        return Objects.hash(name);
    }
}
```

要注意的是, 如果两个对象通过equals相等, 那么他们的`hashCode`必须相等. 否则会导致哈希表类数据结构(如HashMap, HashSet)的行为异常. 

### Java是值传递还是引用传递

Java是值传递, 不是引用传递. 当一个对象作为参数传递到方法中的时候, 参数的值就是该对象的引用. 引用的值就是对象在堆中的地址. 对象是存储在堆中的, 所以传递对象的时候, 可以理解为把变量存储的对象地址给传递过去. 

### 说说深拷贝和浅拷贝的区别

在Java中, 深拷贝和浅拷贝是两种拷贝对象的方式. 浅拷贝会创建一个新的对象, 但是这个新对象的属性和原对象的属性完全相同. 如果属性是基本数据类型, 拷贝的是基本数据类型的值; 如果属性是引用类型, 拷贝的是引用地址, 因此新旧对象共享同一个引用对象. 

浅拷贝的实现方式为, 实现`Cloneable`接口并重写`clone()`方法, 深拷贝也会创建一个新对象, 但是会递归地赋值所有的引用对象, 确保新对象和原对象完全独立, 深拷贝的实现方式有, 手动赋值所有的引用对象, 或者使用序列化和反序列化. 

### Java创建对象有哪几种方式

Java创建对象有四种方式:

1. `new`关键字创建, 这是最常见和直接的方式, 通过调用类的构造方法来创建对象: `Person person = new Person();`. 
2. 反射机制创建: 反射机制允许在运行的时候创建对象, 并且可以访问类的私有成员, 在框架和工具类中比较常见. 

    ```java
    Class clazz = Class.forName("Person");
    Person person = (Person) clazz.newInstance();
    ```

3. `clone`拷贝创建, 通过`clone`方法创建对象, 需要实现`Cloneable`接口并重写`clone`方法

    ```java
    Person person = new Person();
    Person person2 = (Person) person.clone();
    ```

4. 序列化机制创建, 通过序列化将对象转换为字节流, 再通过反序列化从字节流中恢复对象, 需要实现Serializable接口.

    ```java
    Person person = new Person();
    ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream("person.txt"));
    oos.writeObject(person);
    ObjectInputStream ois = new ObjectInputStream(new FileInputStream("person.txt"));
    Person person2 = (Person) ois.readObject();
    ```

new子类的时候, 包括以下的步骤:

1. 首先执行父类的静态代码块(仅在类第一次加载的时候执行)
2. 接着执行子类的静态代码块(仅在类第一次加载的时候执行)
3. 再执行父类的构造方法
4. 最后执行子类的构造方法

### `String`和`StringBuilder`, `StringBuffer`的区别

`String`, `StringBuffer`, `StringBuilder`都是处理字符串的, 他们之间的区别是, `String`是不可变的, 平常开发用的最多, 当遇到大量字符串连接的时候, 就用`StringBuilder`, 它不会生成很多新的对象, `StringBuffer`和`StingBuilder`类似, 但是每个方法都加了`synchronized`关键字, 所以是线程安全的. 

`String`的特点:

`String`类对象是不可变的, 就是说, 一单一个`String`对象被创建,它t所包含的字符串内容是不可变的, 每次对`String`对象进行修改操作, 如拼接, 替换等, 实际上都会生成一个新的`String`对象, 而不是修改原有对象, 这可能会导致内存和性能开销, 尤其是在大量字符串操作的情况下. 

`StringBuilder`的特点:

* `StringBuilder`提供了一系列的方法进行的符串的增删改查操作, 这些操作都是直接在原有字符串对象的底层数组上进行的, 而不是生成新的`String`对象
* `StringBuilder`不是线程安全的, 这意味着在没有外部同步的情况下, 它不适用于多线程环境
* 相比于`String`, 在进行频繁的字符串修改操作的时候, 能提供更好的性能.

`StringBuffer`的特点:

`StringBuffer`和`StringBuilder`类似, 但是`StringBuffer`是线程安全的, 方法前面都加了`synchronized`关键字. 

### `String str1 = new String("abc")`和`String str2 = "abc"`的区别

`String str1 = new String("abc")` 会先确保字符串常量池中有 `"abc"` 这个对象, 然后再在堆内存中创建一个新的 `String` 对象, 最后让 `str1` 指向堆中的新对象; 而 `String str2 = "abc"` 是直接使用字符串常量池中的 `"abc"` 对象, 让 `str2` 指向它. 所以两者内容相同, `str1.equals(str2)` 为 `true`, 但它们不是同一个对象, `str1 == str2` 通常为 `false`. 

### `String`是不可变类吗? 字符串拼接是如何实现的?

`String`是不可变的, 这意味着一旦一个`String`对象被创建, 其存储的文本内容就不能被改变. 

1. 不可变性使得`String`对象在使用中更加安全. 因为字符串经常用作参数传递给其他Java方法, 例如网络连接, 打开文件等. 如果`String`是可变的, 这些方法调用的参数值就可能在不知不觉中被改变, 从而导致网络连接被篡改, 文件被莫名其妙地修改等问题
2. 不可变地对象因为状态不会改变, 所以更加容易进行缓存和重用, 字符串常量池地出现基于这个原因. 当代码中出现相同的字符串字面量的时候, JVM会确保所有的引用都指向常量池中的同一个对象, 从而节约内存. 
3. 因为`String`的内容不会改变, 所以它的哈希值也就固定不变. 这使得`String`对象特别适合作为HashMap或者是HashSet等集合的键, 因为计算哈希值只需要进行一次, 提高了哈希表操作的效率. 

### 字符串拼接是如何实现的

因为`String`是不可变的. 因此通过`+`操作符进行的字符串拼接, 会生成新的字符串对象. 例如:

```java
String a = "hello ";
String b = "world!";
String ab = a + b;
```

Java8对`+`的字符串拼接进行了优化, 在编译期间基于`StringBuilder`的`append`方法进行拼接. 上述代码相当于:

```java
String a = "hello ";
String b = "world!";
StringBuilder sb = new StringBuilder();
sb.append(a);
sb.append(b);
String ab = sb.toString();
```

### 如何保证`String`不可变?

1. `String`类内部使用一个私有的字符数组来存储字符串数据. 这个字符数组在创建字符串的时候被初始化, 之后不允许被改变. 
2. `String`类没有提供任何可以修改其内容的公共方法, 像`concat`这些看似能够修改字符串的操作, 实际上都是返回一个新创建的字符串对象, 而原始字符串对象保持不变. 
3. `String`类本身被申明为`final`, 这意味着它不能被继承, 防止了子类可能通过添加修改方法来改变字符串内容的可能性. 