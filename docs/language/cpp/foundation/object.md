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
