---
title: 对象
icon: material/code-braces
---

## 类

可以使用`class{};`定义一个类.

```cpp
#include <iostream>
#include <string>

class Student {
    public:
        Student() {
            std::cout << "Student constructor called." << std::endl;
        }
        ~Student() {
            std::cout << "Student destructor called." << std::endl;
        }
    private:
        std::string m_name;
};

int main() {
    Student joe;
    return 0;
}
```

!!! note "重新写到cpp, hpp中"

    可以将类的定义放到一个头文件中, 然后在源文件中包含这个头文件. 这样可以更好地组织代码.

    `student.hpp`:

    ```cpp
    #ifndef STUDENT_HPP
    #define STUDENT_HPP

    #include <iostream>
    #include <string>

    class Student {
        public:
            Student();
            ~Student();
        private:
            std::string m_name;
    };

    #endif // STUDENT_HPP
    ```

    `student.cpp`:

    ```cpp
    #include "student.hpp"

    Student::Student() {
        std::cout << "Student constructor called." << std::endl;
    }

    Student::~Student() {
        std::cout << "Student destructor called." << std::endl;
    }
    ```

    !!! tip ":::的用法"

        在C++中, `::`是作用域解析运算符, 它左边通常可以是以下几种:

        1. 命名空间: `std::cout`表示使用`std`命名空间中的`cout`对象.
        2. 类:
            * 访问类的静态成员: `ClassName::static_value`.
            * 在类外定义或类的成员函数: `ClassName::memberFunction()`, 就像上面的一样
            * ...
        3. ...

!!! note "在栈和堆上面创建对象"

    在栈上面创建对象:

    ```cpp
    #include <iostream>
    #include <string>

    class Student {
        public:
            Student() {
                std::cout << "Student constructor called." << std::endl;
            }
            ~Student() {
                std::cout << "Student destructor called." << std::endl;
            }
        private:
            std::string m_name;
    };

    int main() {
        Student joe;
        return 0;
    }
    ```

    ```bash
    Student constructor called.
    Student destructor called.
    ```

    在堆上面创建对象:

    ```cpp
    #include <iostream>
    #include <string>

    class Student {
        public:
            Student() {
                std::cout << "Student constructor called." << std::endl;
            }
            ~Student() {
                std::cout << "Student destructor called." << std::endl;
            }
        private:
            std::string m_name;
    };

    int main() {
        Student* joe = new Student();
        return 0;
    }
    ```

    ```bash
    Student constructor called.
    ```

    在栈上面创建对象的时候, 你会发现对象离开他的作用域的时候, 会自动调用析构函数; 但是如果是在堆上面创建对象的时候, 你会发现离开作用域的时候, 析构函数不会自动调用. 这个时候就需要手动使用`delete`来释放内存. 或者使用一个智能指针, 因为只智能指针是一个栈对象, 所以当智能指针离开栈对象这个作用于的时候, 它的析构函数会自动调用, 关键在于, 智能指针的析构函数被设计为自动`delete`它所管理的那个堆对象.

    使用智能指针:

    ```cpp
    #include <iostream>
    #include <string>
    #include <memory>

    class Student {
        public:
            Student() {
                std::cout << "Student constructor called." << std::endl;
            }
            ~Student() {
                std::cout << "Student destructor called." << std::endl;
            }
        private:
            std::string m_name;
    };

    int main() {
        std::unique_ptr<Student> joe = std::make_unique<Student>();
        return 0;
    }
    ```

    ```bash
    Student constructor called.
    Student destructor called.
    ```

## 权限修饰符

C++中的class有三种访问权限修饰符:

1.  `public` (公有):
    * 成员可以从类的外部访问.
    * 任何代码都可以访问公有成员.

2.  `private` (私有):
    * 成员只能由类的成员函数和友元函数访问.
    * 这是`class`关键字定义的类的默认权限.

3.  `protected` (保护):
    * 成员可以由类的成员函数, 友元函数以及派生类(子类)的成员函数访问.
    * 外部代码无法直接访问保护成员.

默认权限是`private`. 类似于Python, Java中的那样, 可以使用getter, setter来访问私有成员.

```cpp
#include <iostream>
#include <string>

class Student {
    public:
        Student() {
            std::cout << "Student constructor called." << std::endl;
        }
        ~Student() {
            std::cout << "Student destructor called." << std::endl;
        }
    private:
        std::string m_name;
};

int main() {
    Student joe;
    // joe.m_name = "Mike"; // 不能访问, 因为 m_name 是私有成员
    return 0;
}
```

## 默认构造函数和析构函数

C++中, 如果你没有定义构造函数和析构函数, 编译器会自动生成一个默认的构造函数和析构函数. 但是如果你定义了一个构造函数或析构函数, 编译器就不会再生成默认的构造函数和析构函数了.

```cpp
// student.hpp
#ifndef STUDENT_HPP
#define STUDENT_HPP

#include <iostream>
#include <string>

class Student {
    private:
        std::string m_name;
};

#endif

// student.cpp
#include "student.hpp"

// main.cpp
#include <iostream>
#include <string>
#include "student.hpp"

int main() {
    Student joe;
    // joe.m_name = "Mike"; // 不能访问, 因为 m_name 是私有成员
    return 0;
}
```

你会发现, 上面的代码执行`g++ student.cpp main.cpp -o prog && ./prog`什么也没有发生. 这是因为编译器自动生成的默认构造函数和析构函数是空的, 所以没有任何输出.

## 拷贝构造函数

其实, C++在创建对象的时候, ^^除了自动生成constructor和destuctor之外, 还会自动生成一个拷贝构造函数, 还有一个拷贝赋值运算符^^, 这个深拷贝构造函数的signature应该是`const ClassName& other`, 所以它既可以接受左值, 又可以接受右值(但是如果你特别定义了一个移动构造函数且signature是`ClassName&& other`, 那么这个时候, 编译器会优先使用移动构造函数).

!!! question "`data`定义的差异会导致什么"

    === "`data`是指针, 动态分配给他数组"

        ```cpp
        #include <iostream>
        #include <string>

        class Array {
            public:
                Array() {
                    data = new int[10];
                    for (int i = 0; i < 10; i++) {
                        data[i] = i*i;
                    }
                }
                ~Array() {
                    delete[] data;
                }
                void PrintingData() {
                    for (int i = 0; i < 10; i++) {
                        std::cout << data[i] << " ";
                    }
                    std::cout << std::endl;
                }
                void setData(int index, int value) {
                    data[index] = value;
                }
            private:
                int* data;
        };

        int main() {
            Array myArray;
            Array myArray2 = myArray;
            myArray.setData(0, 100);
            myArray2.PrintingData();
            myArray.PrintingData();
            return 0;
        }
        ```

        输出结果:

        ```bash
        100 1 4 9 16 25 36 49 64 81
        100 1 4 9 16 25 36 49 64 81
        free(): double free detected in tcache 2
        ```

        这时候, 你会发现, 欸, 都是100, 这是因为复制的时候复制的是指针, 也就是堆中的数组的地址, 那么复制之后, 新对象的`data`只是原始对象的`data`指针的一个副本, 都指向同一块内存, 所以可以一起更新. 这种复制被称为shallow copy.

        所以, 如果你想要重新创建一个一摸一样的堆数组, **就需要自己写一个copy constructor**!.

    === "`data`为普通数组"

        ```cpp
        #include <iostream>
        #include <string>

        class Array {
            public:
                Array() {
                    for (int i = 0; i < 10; i++) {
                        data[i] = i*i;
                    }
                }
                ~Array() {
                }
                void PrintingData() {
                    for (int i = 0; i < 10; i++) {
                        std::cout << data[i] << " ";
                    }
                    std::cout << std::endl;
                }
                void setData(int index, int value) {
                    data[index] = value;
                }
            private:
                int data[10];
        };

        int main() {
            Array myArray;
            Array myArray2 = myArray;
            myArray.setData(0, 100);
            myArray2.PrintingData();
            myArray.PrintingData();
            return 0;
        }
        ```

        输出是:

        ```bash
        0 1 4 9 16 25 36 49 64 81
        100 1 4 9 16 25 36 49 64 81
        ```

        这是因为复制的时候, 把整个数组复制过去了, 之后两个对象中的`data`就不是相干的了, 所以之后改变原来数组中的值不会影响新对象中的数组.

拷贝构造函数可以这么写:

```cpp
ClassName(const ClassName& other) {} // 上面其实已经写过了
```

```cpp linenums="1" hl_lines="15-20"
#include <iostream>
#include <string>

class Array {
    public:
        Array() {
            data = new int[10];
            for (int i = 0; i < 10; i++) {
                data[i] = i*i;
            }
        }
        ~Array() {
            delete[] data;
        }
        Array(const Array& other) {
            data = new int[10];
            for (int i = 0; i < 10; i++) {
                data[i] = other.data[i];
            }
        }
        void PrintingData() {
            for (int i = 0; i < 10; i++) {
                std::cout << data[i] << " ";
            }
            std::cout << std::endl;
        }
        void setData(int index, int value) {
            data[index] = value;
        }
    private:
        int* data;
};

int main() {
    Array myArray;
    Array myArray2 = myArray;
    myArray.setData(0, 100);
    myArray2.PrintingData();
    myArray.PrintingData();
    return 0;
}
```

现在的输出就是:

```bash
0 1 4 9 16 25 36 49 64 81
100 1 4 9 16 25 36 49 64 81
```

然而, 如果我稍微改写一下, 你就会发现输出结果又变回老样子了:

```cpp linenums="1" hl_lines="36-37"
#include <iostream>
#include <string>

class Array {
    public:
        Array() {
            data = new int[10];
            for (int i = 0; i < 10; i++) {
                data[i] = i*i;
            }
        }
        ~Array() {
            delete[] data;
        }
        Array(const Array& other) {
            data = new int[10];
            for (int i = 0; i < 10; i++) {
                data[i] = other.data[i];
            }
        }
        void PrintingData() {
            for (int i = 0; i < 10; i++) {
                std::cout << data[i] << " ";
            }
            std::cout << std::endl;
        }
        void setData(int index, int value) {
            data[index] = value;
        }
    private:
        int* data;
};

int main() {
    Array myArray;
    Array myArray2;
    myArray2 = myArray;
    myArray.setData(0, 100);
    myArray2.PrintingData();
    myArray.PrintingData();
    return 0;
}
```

输出结果:

```bash
100 1 4 9 16 25 36 49 64 81
100 1 4 9 16 25 36 49 64 81
free(): double free detected in tcache 2
```

这是因为先声明, 后拷贝赋值调用的是拷贝赋值运算符.

!!! note "拷贝重载运算符"

    ```cpp
    Vector3 myVector;
    Vector3 myVector2;
    myVector2 = myVector;
    ```

    这里的等号就是拷贝赋值运算符. 如果你没有在类里面定义这个等号, 那么编译器会自动生成一个默认的拷贝赋值运算符. 这个默认版本会逐个拷贝对象的成员变量. 这个运算符是经过重载的, 和Java里面的类似, 它不是一个简单的等号.

    !!! warning "何时会调用拷贝重载运算符"

        注意, 这个拷贝重载运算符是某个变量经过声明后, 例如`myVector2`经过声明后, 被`myVector`赋值才会调用这个拷贝重载运算符. 换句话说, 如果是下面这样, 只会调用拷贝构造函数, 而不是拷贝重载运算符:

        ```cpp
        Vector3 myVector;
        Vector3 myVector2 = myVector;
        ```

    拷贝重载运算符可以这样写:

    ```cpp linenums="1" hl_lines="21-29"
    #include <iostream>
    #include <string>

    class Array {
        public:
            Array() {
                data = new int[10];
                for (int i = 0; i < 10; i++) {
                    data[i] = i*i;
                }
            }
            ~Array() {
                delete[] data;
            }
            Array(const Array& other) {
                data = new int[10];
                for (int i = 0; i < 10; i++) {
                    data[i] = other.data[i];
                }
            }
            void operator=(const Array& other) {
                if (this != &other) {
                    delete[] data;
                    data = new int[10];
                    for (int i = 0; i < 10; i++) {
                        data[i] = other.data[i];
                    }
                }
            }
            void PrintingData() {
                for (int i = 0; i < 10; i++) {
                    std::cout << data[i] << " ";
                }
                std::cout << std::endl;
            }
            void setData(int index, int value) {
                data[index] = value;
            }
        private:
            int* data;
    };

    int main() {
        Array myArray;
        Array myArray2;
        myArray2 = myArray;
        myArray.setData(0, 100);
        myArray2.PrintingData();
        myArray.PrintingData();
        return 0;
    }
    ```

    首先, 它会删除掉原有`myArray2`中的所有数据, 即`data`. 然后创建一个新的数据`data`, 把`myArray`中的内容复制过来. Ok, 现在我们成功了:

    ```bash
    0 1 4 9 16 25 36 49 64 81
    100 1 4 9 16 25 36 49 64 81
    ```

    !!! tip "`this`是啥"

        `this`本质上是一个指针. 它是一个隐含的, 特殊的指针, 指向调用成员函数的那个对象实例. 在类的成员函数内部, 你可以像使用其他指针一样使用它 (比如用`->`访问成员, 或者用`*`解引用), 只是你不能改变`this`指针本身的值.

    !!! note "`if (this != &other)`啥意思"

        `this`是`myArray2`的指针, `&other`是`myArray`的指针, 这个的意思就是防止自己赋值给自己, 当然`myArray2 = myArray`不是这种情况, 如果`myArray2 = myArray2`, 就不会触发这个if.

    !!! question "返回值是`Array&`还是`void`还是`Array`"

        Well... `Array&`和`Array`的区别主要是一个是引用返回, 一个是值返回. 但是这里我们好像不需要返回值, 因为`myArray2 = myArray`, 而不是`tmp = myArray2 = myArray`, 所以这里设置为`void`也可以, 跑起来没问题.

        但是, 官方教程推荐这里返回的是`Array&`, 支持链式赋值, 就是`tmp = myArray2 = myArray`. 为什么不是`Array`呢? 因为链式复制的时候可以少一次对象的拷贝:

        考虑链式赋值 `a = b = c;`.

        * 如果 `operator=` 返回 `Array&`:
            * `b = c` 执行, `b` 被修改, 并返回 `b` 自身的引用.
            * `a = (b 的引用)` 执行, `a` 被修改 (通过拷贝 `b` 的数据).
            * 整个过程只涉及两次赋值操作, 没有创建额外的临时对象.
        * 如果 `operator=` 返回 `Array`:
            * `b = c` 执行, `b` 被修改.
            * 然后, `operator=` 创建一个 `b` 的临时拷贝并返回它.
            * `a = (b 的临时拷贝)` 执行, `a` 被修改 (通过拷贝临时对象的数据).
            * 这个过程不仅有两次赋值操作, 还额外增加了一次对象的拷贝 (或移动) 和销毁, 带来了性能开销.

    !!! warning "`=`不能去掉"

        这里的`=`就是你要重载的那个符号. 去掉它就不叫重载赋值运算符了, 编译器不会调用这个重载, 也无法实现`a = b`这种语义.

    !!! warning "内存泄漏"

        上述的代码其实有可能内存泄漏的, 如果我忘记定义析构函数的话, 那么`data`是不会被销毁的. 但是离开作用域的时候, `data`这个指针变量没了, 内存还在, 所以引起了内存泄漏, 一个方法就是使用智能指针, 用`std::unique_ptr<int[]>`来管理这个堆数组, 当智能指针离开作用域的时候, 它会自动调用其内部的析构函数, 帮助我们清理掉这部分内存.
