---
title: 软件工程
comments: false
---

```
todolist:
 1. Java 基础
     重点补: 
     面向对象, 集合, 异常, String, 泛型, 反射基础, IO, 线程基础
     高频题: 
     ArrayList 和 LinkedList
     HashMap 原理
     == 和 equals
     重载和重写
     final / finally / finalize
     接口和抽象类
     异常分类
     线程和进程
     synchronized 和 Lock
  2. Spring / Spring Boot
     不用啃源码, 先补"面试能说"的层面: 
     IOC 是什么
     AOP 是什么
     Bean 生命周期
     Spring Boot 自动配置大概是什么
     @Autowired / @Resource 区别
     事务传播机制
     Spring MVC 请求流程
     你只要能把这些讲到 60 分, 就够比很多临时抱佛脚的人强了. 
  3. MySQL
     银行开发很容易问数据库. 
     必须会: 
     索引
     B+ 树
     事务 ACID
     隔离级别
     脏读/不可重复读/幻读
     MVCC
     left join
     如何优化慢 SQL
     varchar 和 char
     索引失效场景
  4. 计算机基础
     重点是: 
     TCP 三次握手
     HTTP/HTTPS
     Cookie/Session/Token
     进程线程
     死锁
     内存和垃圾回收基础
     不用太深, 但要能答
```

## Java

### ArrayList和LinkedList的区别 

**1. 底层结构 🧱**

* ArrayList: 基于**动态数组**(连续内存)
* LinkedList: 基于**双向链表**(节点+指针)

**2. 访问性能 ⚡**

* ArrayList: 支持**随机访问(O(1))**, 通过下标直接取值
* LinkedList: 访问需要遍历, **O(n)**

**3. 插入/删除性能 🔄**

* ArrayList: 

    * 尾部插入快(均摊 O(1))
    * 中间插入/删除慢(需要移动元素, O(n))

* LinkedList: 

    * 插入/删除节点快(O(1)), 但**前提是已找到位置**
    * 查找位置仍是 O(n)

**4. 内存占用 💾**

* ArrayList: 空间利用率高(只存数据)
* LinkedList: 每个节点额外存前后指针, **更耗内存**

**5. 扩容机制 📈**

* ArrayList: 容量不够时会**扩容(一般1.5倍)并复制数组**
* LinkedList: 无需扩容, 按需创建节点

**6. 使用场景 🎯**

* ArrayList: 
👉 读多写少, 频繁随机访问(最常用)
* LinkedList: 
👉 插入删除频繁, 对随机访问要求低(实际开发较少用)

**一句话总结 🧠**

* ArrayList: **查得快, 改得慢**
* LinkedList: **改得快(理论), 查得慢**

### HashMap原理

**HashMap 的核心原理可以概括为: 数组 + 哈希函数 + 冲突处理(链表/红黑树)** 🧠

**1. 基本结构 🧱**

HashMap 底层是一个**数组(table)**, 每个位置叫"桶(bucket)". 
每个桶里存的是: 

* 单个元素, 或
* 一个**链表**, 或
* 一棵**红黑树**(JDK 8 之后)

**2. 存储过程(put)📥**

插入一个 key-value 时会经历: 

1. 计算 hash 值

    * 通过 key 的 `hashCode()` 再做扰动运算

2. 定位数组下标

    * `index = hash & (n - 1)`(n 是数组长度)

3. 放入桶中

    * 该位置为空 → 直接放
    * 有元素 → 发生**哈希冲突**, 进入链表或树结构

4. 冲突处理

    * JDK 7: 链表
    * JDK 8: 

        * 链表长度 ≥ 8 且数组容量 ≥ 64 → 转为**红黑树** 🌳
        * 否则继续链表

**3. 查询过程(get)🔍**

1. 根据 key 算 hash
2. 定位桶位置
3. 在桶中查找: 
    * 单节点 → 直接返回
    * 链表 → 遍历
    * 红黑树 → 二叉搜索(更快)

**4. 扩容机制(resize)📈**

当元素数量超过阈值时触发扩容: 

* 阈值 = 容量 × 负载因子(默认 0.75)
* 扩容时: 

    * 数组长度变为**2倍**
    * 所有元素重新计算位置(rehash)

**5. 关键特性 ⚡**

* 查询/插入平均复杂度: **O(1)**
* 冲突严重时: 

    * 链表 → O(n)
    * 红黑树 → O(log n)
    * 线程不安全(多线程需用 ConcurrentHashMap)

**6. 面试高频点 🎯**

* 为什么容量是 2 的幂? 👉 为了用位运算快速定位
* 为什么要树化? 👉 避免链表过长导致性能退化
* 扩容为什么慢? 👉 需要**数据迁移 + 重新计算位置**

### == 和 equals

在 Java 中, `==` 和 `equals()` 的区别是面试高频基础题, 核心在于: **比较"地址"还是"内容"**. 🧠

**1. `==` 是什么 ⚖️**

* 基本类型: 比较**值是否相等**
* 引用类型: 比较**内存地址是否相同(是否指向同一个对象)**

示例: 

```java
int a = 10, b = 10;
System.out.println(a == b); // true

String s1 = new String("abc");
String s2 = new String("abc");
System.out.println(s1 == s2); // false(不同对象)
```

**2. `equals()` 是什么 🔍**

* 是 `Object` 类的方法(所有类都有)
* 默认实现: 其实也是比较地址(和 `==` 一样)
* 很多类(如 String)**重写了 equals()**, 变为比较"内容"

示例: 

```java
String s1 = new String("abc");
String s2 = new String("abc");
System.out.println(s1.equals(s2)); // true(比较内容)
```

**3. 关键区别总结 📌**

* `==`: 
👉 判断是不是"同一个对象"
* `equals()`: 
👉 判断"内容是否相等"(前提是类重写了)

**4. 面试常考补充 ⚠️**

* 自定义类如果不重写 equals(): 
👉 equals 仍然是比较地址

* 一般规则: 
👉 重写 equals() 必须同时重写 `hashCode()`(否则在 HashMap 等集合中会出问题)

### 重载和重写

Java 里的"重载"和"重写"区别: 

**重载 Overload**: 同一个类中, 方法名相同, 但参数列表不同. 

```java
class Calculator {
    int add(int a, int b) {
        return a + b;
    }

    double add(double a, double b) {
        return a + b;
    }

    int add(int a, int b, int c) {
        return a + b + c;
    }
}
```

特点: 发生在同一个类中; 方法名相同; 参数个数, 类型或顺序不同; 返回值不同不能单独构成重载. 

**重写 Override**: 子类重新实现父类已有的方法. 

```java
class Animal {
    void speak() {
        System.out.println("Animal speaks");
    }
}

class Dog extends Animal {
    @Override
    void speak() {
        System.out.println("Dog barks");
    }
}
```

特点: 发生在父子类之间; 方法名, 参数列表必须相同; 返回值类型通常相同, 或是父类返回类型的子类; 访问权限不能更严格; 常用 `@Override` 标注. 

一句话记忆: 
**重载是"同名不同参", 重写是"子类改父类方法".**

### final / finally / finalize

这三个名字很像, 但用途完全不同: 

**1️⃣ `final`(关键字)**
用于"不可改变"的限制. 

* 修饰变量: 值不能再改

```java
final int x = 10;
// x = 20; ❌ 报错
```

* 修饰方法: 不能被子类重写

```java
class A {
    final void show() {}
}
```

* 修饰类: 不能被继承

```java
final class A {}
// class B extends A {} ❌
```

👉 核心: **锁死(不能改 / 不能继承 / 不能重写)**

**2️⃣ `finally`(代码块)**
用于异常处理中, 表示"无论如何都会执行". 

```java
try {
    int a = 1 / 0;
} catch (Exception e) {
    System.out.println("出错了");
} finally {
    System.out.println("一定会执行");
}
```

👉 常见用途: 关闭资源(文件, 数据库连接等)

**3️⃣ `finalize()`(方法)**
是 `Object` 类里的方法, 在对象被垃圾回收前调用. 

```java
@Override
protected void finalize() throws Throwable {
    System.out.println("对象被回收前调用");
}
```

**总结一句话 📌**

* `final`: 限制(不能改)
* `finally`: 一定执行
* `finalize()`: 对象回收前调用(基本不用了)

### 接口和抽象类

