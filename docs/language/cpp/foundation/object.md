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

!!! note "拷贝重载运算符"

    ```cpp
    Vector3 myVector;
    Vector3 myVector2 = myVector;
    ```

    这里的等号就是拷贝赋值运算符. 如果你没有在类里面定义这个等号, 那么编译器会自动生成一个默认的拷贝赋值运算符. 这个默认版本会逐个拷贝对象的成员变量. 这个运算符是经过重载的, 和Java里面的类似, 它不是一个简单的等号.

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

```cpp hl_lines="15-20"
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
