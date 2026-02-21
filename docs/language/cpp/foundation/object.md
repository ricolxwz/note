---
title: 对象
comments: true
icon: material/code-braces
---

## 简单的介绍类

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

        在C++中, `::`是作用域解析操作符, 它左边通常可以是以下几种:

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

## 构造函数和析构函数

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

其实, C++在创建对象的时候, ^^除了自动生成constructor和destuctor之外, 还会自动生成一个拷贝构造函数, 还有一个拷贝赋值操作符^^, 这个深拷贝构造函数的signature应该是`const ClassName& other`, 所以它既可以接受左值, 又可以接受右值(但是如果你特别定义了一个移动构造函数且signature是`ClassName&& other`, 那么这个时候, 编译器会优先使用移动构造函数).

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

        所以, 如果你想要重新创建一个一摸一样的堆数组, 就需要自己写一个copy constructor!.

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

这是因为先声明, 后拷贝赋值调用的是拷贝赋值操作符(或者说没有用初始化的方式). 或者说, `Array myArray2`这个声明已经创建了一个默认对象了, 我们先要把默认对象删掉, 然后赋值. 不像`Array myArrays = myArray`是直接使用`myArray`初始化的, 没有创建默认对象这一步.

### 拷贝赋值操作符

```cpp
Vector3 myVector;
Vector3 myVector2;
myVector2 = myVector;
```

这里的等号就是拷贝赋值操作符. 如果你没有在类里面定义这个等号, 那么编译器会自动生成一个默认的拷贝赋值操作符. 这个默认版本会逐个拷贝对象的成员变量. 这个操作符是经过重载的, 和Java里面的类似, 它不是一个简单的等号.

!!! warning "何时会调用拷贝赋值操作符"

    注意, 这个拷贝赋值操作符是某个变量经过声明后, 例如`myVector2`经过声明后, 被`myVector`赋值才会调用这个拷贝赋值操作符. 换句话说, 如果是下面这样, 只会调用拷贝构造函数, 而不是拷贝赋值操作符:

    ```cpp
    Vector3 myVector;
    Vector3 myVector2 = myVector;
    ```

!!! abstract "总结拷贝构造函数和拷贝赋值操作符调用"

    * 直接使用其他对象初始化(又叫做拷贝初始化) -> 调用拷贝构造函数
    * 先新建一个对象(又叫做直接初始化), 再使用其他对象赋值 -> 调用拷贝赋值操作符

    同样的, 移动构造函数和移动赋值操作符也遵循这个规律.

拷贝赋值操作符可以这样写:

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

    ??? example "其实你可以做一个小小的实验看出`Array&`和`Array`的区别"

        === "如果是`Array`"

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
                    Array(const Array& other) {
                        std::cout << "Copy Constructor Called" << std::endl;
                        data = new int[10];
                        for (int i = 0; i < 10; i++) {
                            data[i] = other.data[i];
                        }
                    }
                    Array operator=(const Array& other) {
                        if (this != &other) {
                            delete[] data;
                            data = new int[10];
                            for (int i = 0; i < 10; i++) {
                                data[i] = other.data[i];
                            }
                        }
                        return *this;
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

            输出:

            ```bash
            Copy Constructor Called
            0 1 4 9 16 25 36 49 64 81
            100 1 4 9 16 25 36 49 64 81
            ```

            你会发现调用了一次拷贝构造函数.

        === "如果是`Array&`"

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
                    Array(const Array& other) {
                        std::cout << "Copy Constructor Called" << std::endl;
                        data = new int[10];
                        for (int i = 0; i < 10; i++) {
                            data[i] = other.data[i];
                        }
                    }
                    Array& operator=(const Array& other) {
                        if (this != &other) {
                            delete[] data;
                            data = new int[10];
                            for (int i = 0; i < 10; i++) {
                                data[i] = other.data[i];
                            }
                        }
                        return *this;
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

            输出:

            ```bash
            0 1 4 9 16 25 36 49 64 81
            100 1 4 9 16 25 36 49 64 81
            ```

            你会发现没调用拷贝构造函数.

!!! warning "`=`不能去掉"

    这里的`=`就是你要重载的那个符号. 去掉它就不叫重载赋值操作符了, 编译器不会调用这个重载, 也无法实现`a = b`这种语义.

!!! warning "内存泄漏"

    上述的代码其实有可能内存泄漏的, 如果我忘记定义析构函数的话, 那么`data`是不会被销毁的. 但是离开作用域的时候, `data`这个指针变量没了, 内存还在, 所以引起了内存泄漏, 一个方法就是使用智能指针, 用`std::unique_ptr<int[]>`来管理这个堆数组, 当智能指针离开作用域的时候, 它会自动调用其内部的析构函数(不是类的我们手写的析构函数), 帮助我们清理掉这部分内存, 所以我们就不需要关心自己写的析构函数了, 反正自动会被释放.

### 拷贝构造函数调用时机

1. 一个对象赋值给另一个对象的时候(含有另一个对象的声明)

    看下面的这个例子:

    === "`main.cpp`"

        ```cpp
        #include <iostream>
        #include "array.hpp"

        int main() {
            Array arr;
            arr.set_data(0, 10);
            Array arr2 = arr;
            arr.print_data();
            arr2.print_data();
            return 0;
        }
        ```

    === "`array.cpp`"

        ```cpp
        #include "array.hpp"
        #include <iostream>

        Array::Array() {
            std::cout << "Array Constructor Called" << std::endl;
            for (int i = 0; i < 1; i++) {
                data.push_back(i);
            }
        }

        Array::~Array() {
            std::cout << "Array Destructor Called" << std::endl;
        }

        Array& Array::operator=(const Array& other) {
            std::cout << "Array Copy Assignment Operator Called" << std::endl;
            if (this == &other) {
                return *this;
            }
            data.clear();
            for (int i = 0; i < other.data.size(); i++) {
                data.push_back(other.data[i]);
            }
            return *this;
        }

        Array::Array(const Array& other) {
            std::cout << "Array Copy Constructor Called" << std::endl;
            if (!other.data.empty()) {
                for (int i = 0; i < other.data.size(); i++) {
                    data.push_back(other.data[i]);
                }
            }
        }

        void Array::print_data() {
            if (data.empty()) {
                std::cout << "Array is empty" << std::endl;
                return;
            }
            for (int i = 0; i < data.size(); i++) {
                std::cout << data[i] << std::endl;
            }
        }

        void Array::set_data(int index, int value) {
            if (index < 0 || index >= data.size()) {
                std::cerr << "Error: Index out of bounds" << std::endl;
                return;
            }
            data[index] = value;
        }
        ```

    === "`array.hpp`"

        ```cpp
        # ifndef ARRAY_HPP
        # define ARRAY_HPP
        #include <vector>

        class Array {
            public:
                Array();
                ~Array();
                Array(const Array& other);
                Array& operator=(const Array& other);
                void print_data();
                void set_data(int index, int value);
            private:
                std::vector<int> data;
        };
        # endif
        ```


    输出结果是:

    ```bash
    Array Constructor Called
    Array Copy Constructor Called
    10
    10
    Array Destructor Called
    Array Destructor Called
    ```

    `Array arr2 = arr`会调用拷贝构造函数.

2. 按值传递的时候

    看下面的这个例子:

    === "`main.cpp`"

        ```cpp  linenums="1" hl_lines="4-6 15"
        #include <iostream>
        #include "array.hpp"

        void print_array(Array a) {
            a.print_data();
        }

        int main() {
            Array arr;
            arr.set_data(0, 10);
            Array arr2 = arr;
            arr.print_data();
            arr2.print_data();

            print_array(arr);
            return 0;
        }
        ```

    === "`array.cpp`"

        ```cpp
        #include "array.hpp"
        #include <iostream>

        Array::Array() {
            std::cout << "Array Constructor Called" << std::endl;
            for (int i = 0; i < 1; i++) {
                data.push_back(i);
            }
        }

        Array::~Array() {
            std::cout << "Array Destructor Called" << std::endl;
        }

        Array& Array::operator=(const Array& other) {
            std::cout << "Array Copy Assignment Operator Called" << std::endl;
            if (this == &other) {
                return *this;
            }
            data.clear();
            for (int i = 0; i < other.data.size(); i++) {
                data.push_back(other.data[i]);
            }
            return *this;
        }

        Array::Array(const Array& other) {
            std::cout << "Array Copy Constructor Called" << std::endl;
            if (!other.data.empty()) {
                for (int i = 0; i < other.data.size(); i++) {
                    data.push_back(other.data[i]);
                }
            }
        }

        void Array::print_data() {
            if (data.empty()) {
                std::cout << "Array is empty" << std::endl;
                return;
            }
            for (int i = 0; i < data.size(); i++) {
                std::cout << data[i] << std::endl;
            }
        }

        void Array::set_data(int index, int value) {
            if (index < 0 || index >= data.size()) {
                std::cerr << "Error: Index out of bounds" << std::endl;
                return;
            }
            data[index] = value;
        }
        ```

    === "`array.hpp`"

        ```cpp
        # ifndef ARRAY_HPP
        # define ARRAY_HPP
        #include <vector>

        class Array {
            public:
                Array();
                ~Array();
                Array(const Array& other);
                Array& operator=(const Array& other);
                void print_data();
                void set_data(int index, int value);
            private:
                std::vector<int> data;
        };
        # endif
        ```

    输出结果是:

    ```bash linenums="1" hl_lines="5-6"
    Array Constructor Called
    Array Copy Constructor Called
    10
    10
    Array Copy Constructor Called
    10
    Array Destructor Called
    Array Destructor Called
    Array Destructor Called
    ```

    你可以看到, 在传递进入函数的时候, 会把这个对象`arr`复制一份给`a`, 调用了拷贝构造函数. 然后, 你可以进一步做实验, 把`print_array`签名中加上一个`&`, 就没有上面的这两行输出了, 因为是按引用传递, 不会复制.

!!! tip "如何彻底删掉拷贝构造函数"

    我就是不想要这个拷贝构造函数, 我可能有时候不小心用了它, 所以我想把它禁用掉, 怎么办呢? 有两种方法: 1. 在header文件中把拷贝构造函数的调用权限置为private; 2. 使用一种更加现代的方法: `Array(const Array& other)=delete`, 加上`=delete`这个小尾巴. 实际上, 在对象一节中, 我们学到的拷贝赋值操作符`=`也是一个操作符, 不是一个简单的等号.

## 成员变量初始化列表 {#member-variable-initializer}

### 为啥要用

C++中的成员变量初始化列表(Member Initializer Lists)是在构造函数中初始化类成员变量的一种简洁而高效的方式. 有些小朋友可能会问, 为啥不直接在构造函数里面直接赋值的方法呢?

因为成员变量初始化列表直接对成员进行初始化, 想象一下你正在创建一个新的盒子, 你直接在制作这个盒子的过程中就放入了特定的物品, 成员变量初始化列表就像这个过程, 它在对象创建的时候就赋予了成员变量初始值. 而在构造函数里面赋值就相当于你先创建了一个空盒子, 然后打开盒子放入物品. 在构造函数体内部赋值就像这个过程, 成员变量首先会被赋予一个默认值(如果存在), 然后再在构造函数内部赋予新的值. 所以关键区别在于, 初始化是一步到位, 但是赋值可能涉及到先初始化, 再赋予新值两个步骤.

由于这个原因, 某些类型的成员, 例如`const`成员, 必须使用初始化列表进行初始化, 因为它们在构造函数的赋值之前, 已经用默认值初始化过了.

它的写法很简单:

```cpp
class 类 {
public:
    类(): x(1.0f), y(2.0f), z(3.0f) {}
    float x, y, z;
}
```

### 顺序

成员的初始化顺序总是按照它们在类定义中声明的顺序进行, 而不是在初始化列表中出现的顺序. 因此, 为了避免潜在的依赖问题, 建议初始化列表中的成员顺序与声明顺序保持一致.

## `struct`

`class`的默认访问权限是`private`, `struct`的默认访问权限是`public`, 其他的东西基本上两个都是一样的. 这是为了和C兼容, 因为C里面有`struct`这个东西.

## RAII

RAII, Resource Acquisition Is Initialization是一种编程范式. 它的核心思想是: 1. 资源获取和对象初始化相结合, 当创建一个对象时, 同时获取它所需要的资源(例如, 内存, 文件句柄, 锁等); 2. 资源释放与对象声明周期结束相绑定. 当对象不再使用的时候(例如, 超出作用域被销毁)的时候, 自动释放其占有的资源. In simple words, RAII就是用对象的生命周期来管理资源的生命周期. 一般来说, 如果你用智能指针来管理这些资源, 就不需要在析构函数中写明了, 因为智能指针本身存储在当前作用域的栈中, 当离开栈(离开作用域)的时候, 这个智能指针会被销毁, 销毁之前会调用其内部的析构函数, 把它所管理的对象一并销毁掉, 所以我们就不用手动销毁了. 所以个人的建议是, 如果是存储在堆中的变量(排除自身已经实现RAII的类, 例如`std::vector`, `std::string`, `std::list`, `std::map`, 它们在类的内部管理自己的资源, 并在其内部的析构函数释放这些资源, 我们不用管), 全部都套上智能指针, 这样就不用在自己的类里面写析构函数了xiaxiaxia...

## 移动构造..和移动赋值...

其实和上面的拷贝构造函数和拷贝赋值操作符是差不多的东西. 只不过它们的函数签名里面接受的是右值, 传进来的对象是xvalue, 或者叫做将亡值, 也是右值的一种, 简单来说, 就是这个传进来的对象快死亡了, 我们需要把它的使命传递给一个新的对象, 它们的实现从本质上来说就是新的对象拿到了将亡对象的指针:

```cpp title="intarray.cpp"
// 假设我这个对象有属性m_name, 是一个std::string; 和一个m_data, 是一个堆数组
IntArray::IntArray(IntArray&& source) { // 这是移动构造函数
    m_name = source.m_name;
    source.m_name = ""; // 将亡值的m_name被"榨干"了
    m_data = source.m_data;
    source.m_data = source.m_data; // 转移指针给的新的对象
    source.m_data = nullptr; // again, 将亡值的m_data堆数组的指针也没了, 统统榨干
    std::cout << m_name << "used move assignment" << std::endl; // 不要忘记吟唱一下
}
IntArray& IntArray::operator=(IntArray&& source) { // 这是移动赋值操作符
    if (this != &source) { // 不要榨干自己
        m_name = source.m_name;
        source.m_name = "";
        m_data = source.m_data;
        source.m_data = nullptr;
        std::cout << " used move assignment" << std::endl;
    }
    return *this;
}
```

=== "调用拷贝构造函数"

    ```cpp title="main.cpp"
    int main() {
        std::vector<IntArray> myArrays;
        myArrays.reserve(10);
        for (int i = 0; i < 10; i++) {
            IntArray temp(std::to_string(i));
            myArrays.push_back(temp)
            // 100万行代码
        }
    }
    ```

    每次传参的时候, `push_back`都会自动调用拷贝构造函数, 创建一个和`tmp`一模一样的对象, 然鹅, 原来的一堆`tmp`对象还是在内存中, 并没有被释放掉, 这部分`tmp`是完全没有用的.

=== "调用移动构造函数"

    ```cpp title="main.cpp"
    int main() {
        std::vector<IntArray> myArrays;
        myArrays.reserve(10);
        for (int i = 0; i < 10; i++) {
            IntArray temp(std::to_string(i));
            myArrays.push_back(std::move(temp))
            // 100万行代码
        }
    }
    ```

    这个时候, `push_back`会自动调用移动构造函数, 原来的`tmp`就被榨干了, 然后再执行接下来的100万行代的时候, 就没有那部分`tmp`占用内存了.

## 规则 5/zero/3

* Rule of Zero (C++11 及以后推荐): 如果你的类不负责管理任何资源(例如原始指针指向的动态内存, 文件句柄, 锁等), 那么你不需要显式定义任何析构函数, 拷贝/移动构造函数或拷贝/移动赋值操作符. 编译器会为你生成默认的版本, 并且通常是正确的. 你应该尽量设计你的类遵循这条规则, 通过使用智能指针 (`std::unique_ptr`, `std::shared_ptr`) 和 RAII 习惯来自动管理资源.
* Rule of Five (C++11): 如果你的类需要管理资源(例如, 通过 `new` 分配的内存), 那么你很可能需要显式定义以下五个特殊成员函数, 以确保资源管理的正确性, 特别是涉及到对象的拷贝和移动时:

    1.  析构函数 (Destructor): 用于释放类对象拥有的资源.
    2.  拷贝构造函数 (Copy Constructor): 用于创建一个现有对象的副本.
    3.  拷贝赋值操作符 (Copy Assignment Operator): 用于将一个现有对象的值赋给另一个现有对象.
    4.  移动构造函数 (Move Constructor): 用于将资源的所有权从一个临时对象"移动"到新对象, 避免深拷贝.
    5.  移动赋值操作符 (Move Assignment Operator): 用于将一个临时对象的资源的所有权"移动"给另一个现有对象.

* Rule of Three (C++03 及更早): 在 C++11 引入移动语义之前, 如果一个类需要自定义析构函数(通常意味着它管理资源), 那么它很可能也需要自定义拷贝构造函数和拷贝赋值操作符, 以避免浅拷贝导致的资源管理问题(例如 double free).

## 友元

### 友元函数

友元函数是在 C++ 中声明在类外部但被授予访问该类私有 (private) 和受保护 (protected) 成员的权限的函数. 它不是类的成员函数, 但可以像类的成员函数一样访问类的内部数据. 需要在类的内部声明这个函数是我的朋友.

```cpp
#include <iostream>

class UDT {
    public:
        UDT() : m_private_member_variable(10) {}
        friend void print_private_member_variables_of_udt(UDT u);
    private:
        int m_private_member_variable;
};

void print_private_member_variables_of_udt(UDT u) {
    std::cout << "m_private_member_variable: " << u.m_private_member_variable << std::endl;
}

int main() {
    UDT u;
    print_private_member_variables_of_udt(u);
    return 0;
}
```

### 友元类

另一种use case是想要访问另一个私有的类, 比如我想要`UDT`能够访问`PST`这个类, 就要在`PST`类里面将`UDT`设置为朋友.

```cpp
class PST {
    friend class UDT;
    private:
        int passcode;
};

class UDT {
    public:
        UDT() : m_private_member_variable(10) {
            m_info.passcode = 7;
        }
        friend void print_private_member_variables_of_udt(UDT u);
    private:
        int m_private_member_variable;
        PST m_info;
};
```

---

最好不要用友元.

## 列表初始化

!!! warning "注意"

    列表初始化 ≠ 构造函数成员初始化列表

| 时代        | 语法                                                             | 说明          |
| --------- | -------------------------------------------------------------- | ----------- |
| C++11 之前  | `string s("hi");`<br>`string s = "hi";`                        | 小括号 / 等号初始化 |
| C++11 及以后 | `string s{"hi"};`  (直接列表初始化)<br>`string s = {"hi"};` (拷贝列表初始化) | "花括号"初始化    |

常见写法

```cpp
int x{0};
int a[]{1,2,3};
std::vector<int> v{1,2,3};
```

### `{}`的作用

使用花括号 {} 进行初始化 (也称为统一初始化或列表初始化) 有几个关键点:

* 优先选择签名中含有`std::initializer_list`构造函数: 如果类`T`有一个接受`std::initializer_list`的构造函数, 并且`{}`里的参数类型匹配, 那么会优先调用这个构造函数. 例如, `std::vector`就有一个接受`std::initializer_list<T>`的构造函数, 所以当你写`std::vector<int> v = {1, 2, 3}`的时候, 编译器就会优先选择那个构造函数

    !!! example "举个例子"

        ```cpp
        #include <vector>
        #include <initializer_list>
        #include <iostream>

        class MyData {
        public:
            // 接收 std::initializer_list<int> 的构造函数
            MyData(std::initializer_list<int> list) {
                std::cout << "Calling initializer_list constructor." << std::endl;
                // 可以像遍历普通容器一样遍历 list
                for (int item : list) {
                    m_data.push_back(item);
                }
            }

            // 另一个构造函数 (例如, 接收大小)
            MyData(size_t size) {
                std::cout << "Calling size constructor." << std::endl;
                m_data.resize(size, 0);
            }

            void print() {
                for (int item : m_data) {
                    std::cout << item << " ";
                }
                std::cout << std::endl;
            }

        private:
            std::vector<int> m_data;
        };

        int main() {
            MyData d1 = {1, 2, 3, 4, 5}; // 这里会调用 std::initializer_list 构造函数
            MyData d2(5);               // 这里会调用 size 构造函数

            d1.print(); // 输出: 1 2 3 4 5
            d2.print(); // 输出: 0 0 0 0 0

            return 0;
        }
        ```

* 防止窄化转换 (Narrowing Conversion): 列表初始化不允许可能导致信息丢失的隐式类型转换. 例如, `int x{3.14}`; 会编译失败, 因为`double`到`int`是窄化转换. 这是它相比于括号`()`初始化的一个安全优势.
* 可用于初始化聚合类型(Aggregate): 可以方便地初始化数组和简单的结构体.
* 解决"最令人烦恼的解析"(Most Vexing Parse): `Widget w();` 会被解析为函数声明, 但`Widget w{};`则明确表示是默认构造一个对象.

### 直接vs贝列表初始化

```cpp
struct C{
    C(int,int);          // 隐式
    explicit C(int);     // 显式
};

C c1{1,2};      // OK, 直接列表初始化
C c2 = {1,2};   // OK, 拷贝列表初始化

C c3{1};        // OK, explicit 可用
// C c4 = {1};  // ❌ explicit 禁止使用拷贝列表初始化, 因为会发生隐式类型转换, 从标量1到一个类C
```

> 口诀: `T obj{...}` 能用 `explicit`, `T obj = {...}` 不能.

## `explicit` 关键字

* 目的: 禁止"隐式"把其他类型转成该类.
* 不影响你显式调用构造函数
* 不阻止基本类型的标准转换.
* 会影响所有的拷贝初始化

```cpp
class UDT{
public:
    explicit UDT(int);
};

UDT u1 = 5;        // ❌ 拷贝初始化, 隐式转换被 explicit 拦住
UDT u2 = {5};      // ❌ 同上, 拷贝列表初始化, 隐式转换被 explicit 拦住
UDT u3(5);         // ✅ 直接调用构造函数
UDT u4{5};         // ✅ 直接列表初始化
UDT u5(5.8f);      // ✅ float → int 标准转换后再直接初始化, 可以使用下面的列表初始化阻止这种情况
UDT u6{5.8f};      //  ❌ 报错, 因为不能标准转换
```

为什么 `UDT u1 = 5;` 出错? 拷贝初始化会尝试先把 `5` 隐式转换成临时 `UDT`, explicit 禁止了这一步; `UDT u1 = {5};` 同理, 你会在错误里面看到`error: conversion from int to non-scalar type udt requested`, 说明这边是有一个隐式的转换的.

!!! note "为啥`explicit`和列表初始化要一起用"

    在`UDT u6{5.8f}`中, `explicit`无法阻止它进行标准转换, 所以要用到列表初始化, 防止窄化转换; `explicit`的作用是防止`UDT u6 = {5}`的情况出现, 因为这里会发生一个隐式的类型转换.

## 继承

C++ 中的继承允许一个类 (子类或派生类) 继承另一个类 (父类或基类) 的属性和方法. 这促进了代码重用和创建层次关系.

* 基类 (Base Class): 被继承的类.
* 派生类 (Derived Class): 继承基类的类. 派生类拥有基类的成员 (除了私有成员), 并且可以添加自己的成员或重写基类的方法.

举个简单的例子把.

```cpp
#include <iostream>

class Dog {
    public:
        Dog() {
        }
        void bark() {
            std::cout << "woof woof" << std::endl;
        }
        void walk() {
            x += 1;
            y += 1;
        }

        float x, y;
};

class Golden : public Dog {
    public:
        void retrieve() {
            std::cout << "retrieving a stick" << std::endl;
        }
};

class Husky: public Dog {

};

int main() {
    Golden golden;
    golden.bark();
    golden.walk();
    golden.retrieve();
    Husky husky;
    husky.bark();
    husky.walk();
    return 0;
}
```

输出:

```bash
woof woof
retrieving a stick
woof woof
```

### 继承类型

* 单一继承: 一个派生类只继承一个基类.
* 多重继承: 一个派生类继承多个基类.
* 多级继承: 一个派生类继承自另一个派生类.
* 层次继承: 一个基类被多个派生类继承.
* 混合继承: 上述类型的组合.

### 访问控制

继承时可以使用访问修饰符 (`public`, `protected`, `private`) 来控制基类成员在派生类中的访问权限:

* `public`继承: 基类的`public`成员在派生类中仍为`public`, `protected`成员仍为`protected`. 这是最常用的方式.
* `protected`继承: 基类的`public`和`protected`成员在派生类中都变为`protected`.
* `private`继承: 基类的`public`和`protected`成员在派生类中都变为`private`.

!!! warning "`protected`和`private`的区别"

    `protected`和`private`的主要区别在于基类成员在派生类的派生类(即孙子类)中的访问权限.

    1.  `protected` 继承:
        * 基类的 `public` 和 `protected` 成员在派生类中都变成 `protected`.
        * 这意味着这些成员可以被派生类的派生类 (孙子类) 访问.

    2.  `private` 继承:
        * 基类的 `public` 和 `protected` 成员在派生类中都变成 `private`.
        * 这意味着这些成员不可以被派生类的派生类 (孙子类) 访问. 它们只在派生类内部可用.

### 构造函数调用

在C++中, 派生类构造函数的调用遵循以下规则:

1.  先基类后派生类: 创建派生类对象时, 首先调用基类的构造函数, 然后再调用派生类自己的构造函数.
2.  基类构造函数初始化列表: 派生类构造函数可以通过初始化列表显式地调用基类的特定构造函数. 如果不显式调用, 编译器会尝试调用基类的默认构造函数. 看下面的例子.

简单来说, 就是从最基础的基类开始, 逐层向上构建, 直到最终的派生类.

#### 基类构造函数初始化列表 {#base-constructor-initializer}

其实和成员初始化列表很像, 都是在构造函数的后面加一个`:`, 例如`Monster(const std::string& name) : EntityBase(name)`, 意思就是指定派生类的这个构造函数`Monster(const std::strin& name)`被调用之前, 先调用`EntityBase(name)`. 如果没有显式写出, 即只有`Monster(const std::string& name)`, 那么会尝试调用默认构造函数. 举个例子:

=== "没有`EntityBase(name)`"

    ```cpp
    #include <iostream>
    #include <string>

    class EntityBase{
        public:
            EntityBase(){
                std::cout << "EntityBase Constructor" << std::endl;
            }
            EntityBase(const std::string& name) : m_name(name) {
                std::cout << "EntityBase Constructor with name: " << m_name << std::endl;
            }
            ~EntityBase(){
                std::cout << "EntityBase Destructor" << std::endl;
            }
        private:
            std::string m_name;
    };

    class Monster : public EntityBase{
        public:
            Monster(){ // 默认先调用EntityBase()
                std::cout << "Monster Constructor" << std::endl;
            }
            Monster(const std::string& name) { // 默认先调用EntityBase()
                std::cout << "Monster Constructor with name: " << name << std::endl;
            }
            ~Monster(){
                std::cout << "Monster Destructor" << std::endl;
            }
    };

    int main(){
        Monster badMonster("badMonster");
        return 0;
    }
    ```

    输出:

    ```bash
    EntityBase Constructor
    Monster Constructor with name: badMonster
    Monster Destructor
    EntityBase Destructor
    ```

    你会发现, 实际上, 会先调用`EntityBase`的默认构造函数. 并且你会发现, 如果`EntityBase()`这个函数没有显式给出, 会报错.

=== "有`EntityBase(name)`"

    ```cpp
    #include <iostream>
    #include <string>

    class EntityBase{
        public:
            EntityBase(){
                std::cout << "EntityBase Constructor" << std::endl;
            }
            EntityBase(const std::string& name) : m_name(name) {
                std::cout << "EntityBase Constructor with name: " << m_name << std::endl;
            }
            ~EntityBase(){
                std::cout << "EntityBase Destructor" << std::endl;
            }
        private:
            std::string m_name;
    };

    class Monster : public EntityBase{
        public:
            Monster(){ // 默认先调用EntityBase()
                std::cout << "Monster Constructor" << std::endl;
            }
            Monster(const std::string& name) : EntityBase(name) {
                std::cout << "Monster Constructor with name: " << name << std::endl;
            }
            ~Monster(){
                std::cout << "Monster Destructor" << std::endl;
            }
    };

    int main(){
        Monster badMonster("badMonster");
        return 0;
    }
    ```

    输出:

    ```bash
    EntityBase Constructor with name: badMonster
    Monster Constructor with name: badMonster
    Monster Destructor
    EntityBase Destructor
    ```

    你会发现, 经过显式写明之后, 会先调用`EntityBase`的`EntityBase(const std::string& name) : m_name(name)`函数, 这里还用了一个成员初始化列表. 再来举一个多层继承的例子.

    ```cpp
    #include <iostream>
    #include <string>

    class TopLevelClass {
        public:
            TopLevelClass() {
                std::cout << "TopLevelClass Constructor" << std::endl;
            }
            TopLevelClass(std::string arg) {
                std::cout << "TopLevelClass Constructor with arg: " << arg << std::endl;
            }
    };

    class EntityBase : public TopLevelClass {
        public:
            EntityBase(){ // 默认先调用TopLevelClass()
                std::cout << "EntityBase Constructor" << std::endl;
            }
            EntityBase(const std::string& name) : TopLevelClass(name), m_name(name) {
                std::cout << "EntityBase Constructor with name: " << m_name << std::endl;
            }
            ~EntityBase(){
                std::cout << "EntityBase Destructor" << std::endl;
            }
        private:
            std::string m_name;
    };

    class Monster : public EntityBase{
        public:
            Monster(){ // 默认先调用EntityBase()
                std::cout << "Monster Constructor" << std::endl;
            }
            Monster(const std::string& name) : EntityBase(name) {
                std::cout << "Monster Constructor with name: " << name << std::endl;
            }
            ~Monster(){
                std::cout << "Monster Destructor" << std::endl;
            }
    };

    int main(){
        Monster badMonster("badMonster");
        return 0;
    }
    ```

    输出:

    ```bash
    TopLevelClass Constructor with arg: badMonster
    EntityBase Constructor with name: badMonster
    Monster Constructor with name: badMonster
    Monster Destructor
    EntityBase Destructor
    ```

    虽然在`main`函数中没有涉及到无参构造函数, 也就是说, 实际上不会调用`EntityBase()`和`TopLevelClass()`, 但是again, `EntityBase()`没有基类构造函数初始化列表, 所以默认会调用`TopLevelClass()`, 虽然不会执行`TopLevelClass()`, 但是编译器找不到这个显式默认构造函数, 会报错.

### 多重继承

多重继承就是一个类可以继承多个基类. 这在 C++ 中是允许的, 但需要小心使用, 因为它可能导致一些复杂的问题, 如菱形继承问题 (Diamond Problem). 比如说, 假设有一个基类 `A`, 两个派生类 `B` 和 `C`, 以及一个派生类 `D` 继承自 `B` 和 `C`.

```cpp
#include <iostream>

struct Dog {
    virtual void bark() {
        std::cout << "Woof!" << std::endl;
    }
    float x, y; // 假设有一些属性
};

struct Golden : public Dog {
    void bark() override {
        std::cout << "Woof!" << std::endl;
    }
};

struct BorderCollie : public Dog {
    void bark() override {
        std::cout << "Woof!" << std::endl;
    }
};

struct Coltriever : public Golden, BorderCollie {
    // 不定义bark()函数, 继承的是哪个类的bark()函数呢?
};

int main() {
    Dog* dog1 = new Golden;
    Dog* dog2 = new BorderCollie;
    Dog* dog3 = new Coltriever; // 这一行就会报错
    dog1 -> bark();
    dog2 -> bark();
    dog3 -> bark();
    return 0;
}
```

输出:

```bash
main.cpp: In function 'int main()':
main.cpp:28:21: error: 'Dog' is an ambiguous base of 'Coltriever'
   28 |     Dog* dog3 = new Coltriever;
      |                     ^~~~~~~~~~
```

可以表示为:

``` mermaid
classDiagram
    Dog <|-- Golden
    Dog <|-- BorderCollie
    Golden <|-- Coltriever
    BorderCollie <|-- Coltriever
    class Dog{
    bark()
    x, y
    }
    class Golden{
    bark()
    }
    class BorderCollie{
    bark()
    }
    class Coltriever{
        我该继承哪个bark()函数呢?
    }
```

#### 虚拟继承

其实上面的菱形继承不是一个真正的菱形, 因为`Dog`类没有被虚拟继承, 所以`Coltriever`类有两个`Dog`类的实例, 这就导致了二义性(见下图). 为了解决这个问题, 可以使用虚拟继承 (Virtual Inheritance). 通过在基类前加上 `virtual` 关键字, 可以确保所有派生类共享同一个基类实例.

=== "真实的菱形继承"

    ``` mermaid
    classDiagram
        Dog1 <|-- Golden
        Dog2 <|-- BorderCollie
        Golden <|-- Coltriever
        BorderCollie <|-- Coltriever
        class Dog1{
            x, y
            bark()
        }
        class Golden{
            bark()
        }
        class Dog2{
            x, y
            bark()
        }
        class BorderCollie{
            bark()
        }
    ```

    所以这样就会产生一个问题, `Coltriever`类有两个`Dog`类的实例, 所以他们的`x, y`其实是不一样的, 这就导致了二义性(见上图和下面的例子).

    ```cpp
    #include <iostream>

    struct Dog {
        virtual void bark() {
            std::cout << "Woof!" << std::endl;
        }
        float x, y; // 假设有一些属性
    };

    struct Golden : public Dog {
        void bark() override {
            std::cout << "Woof!" << std::endl;
        }
    };

    struct BorderCollie : public Dog {
        void bark() override {
            std::cout << "Woof!" << std::endl;
        }
    };

    struct Coltriever : public Golden, BorderCollie {
        void bark() override {
            std::cout << "Woof!" << std::endl;
        }
    };

    int main() {
        Dog* dog1 = new Golden;
        Dog* dog2 = new BorderCollie;
        Dog* dog3 = new Coltriever;
        dog1 -> bark();
        dog2 -> bark();
        dog3 -> bark();
        std::cout << dog3 -> x << std::endl;
        return 0;
    }
    ```

    输出:

    ```bash
    main.cpp: In function 'int main()':
    main.cpp:31:25: error: 'Dog' is an ambiguous base of 'Coltriever'
    31 |         Dog* dog3 = new Coltriever;
        |                         ^~~~~~~~~~
    ```

    为了解决这个问题, 可以使用虚拟继承 (Virtual Inheritance). 通过在基类前加上 `virtual` 关键字, 可以确保所有派生类共享同一个基类实例.

    ```cpp linenums="1" hl_lines="10 16"
    #include <iostream>

    struct Dog {
        virtual void bark() {
            std::cout << "Woof!" << std::endl;
        }
        float x, y; // 假设有一些属性
    };

    struct Golden : virtual public Dog {
        void bark() override {
            std::cout << "Woof!" << std::endl;
        }
    };

    struct BorderCollie : virtual public Dog {
        void bark() override {
            std::cout << "Woof!" << std::endl;
        }
    };

    struct Coltriever : public Golden, BorderCollie {
        void bark() override {
            std::cout << "Woof!" << std::endl;
        }
    };

    int main() {
        Dog* dog1 = new Golden;
        Dog* dog2 = new BorderCollie;
        Dog* dog3 = new Coltriever;
        dog1 -> bark();
        dog2 -> bark();
        dog3 -> bark();
        std::cout << dog3 -> x << std::endl;
        return 0;
    }
    ```

    输出:

    ```bash
    Woof!
    Woof!
    Woof!
    0
    ```

=== "想象中的菱形继承"

    ``` mermaid
    classDiagram
        Dog <|-- Golden
        Dog <|-- BorderCollie
        Golden <|-- Coltriever
        BorderCollie <|-- Coltriever
        class Dog{
        bark()
        x, y
        }
        class Golden{
        bark()
        }
        class BorderCollie{
        bark()
        }
        class Coltriever{
        }
    ```

### 组合

继承表示的是"is-a"的关系, 组合表示的是"has-a"的关系. 组合是指一个类包含另一个类的实例作为其成员变量, 这使得组合类可以使用被组合类的功能, 而不需要继承它.

```cpp
struct Point2D {
    float x, y;
}

class Character {
    public:
        Character() {};
        ~Character() {};
    private:
        Point2D position; // 组合关系, Character 有一个 Point2D 成员变量
}
```

### 聚合

还有一种关系叫做"聚合" (Aggregation), 它和组合类似, 但有一个关键区别: 聚合表示的是一个类包含另一个类的引用或指针, 而不是直接包含其实例. 这意味着被聚合的类可以独立于聚合类存在, 而组合类的生命周期通常与被组合类的生命周期相关联.

```cpp
struct Point2D {
    float x, y;
};

class Character {
    public:
        Character(Point2D& position) : position(position) {}; // 聚合关系, 使用了成员初始化列表, 确保在声明的时候初始化
        ~Character() {};
    private:
        Point2D& position;
};

int main() {
    Point2D p{1.0f, 2.0f};
    Character c(p); // 创建一个 Character, 并将 Point2D 的引用传递给它
    return 0;
}
```

## 多态

### 为啥要用

首先, 和Python类似, 多态的目的就是能够写一个同一的函数, 接受基类及其所有派生类. 假设基类是`Base`, 派生类是`NPC, Player, Monster`, 那么如果你的函数签名是`void applyDamage(NPC* npc, int damage)`, 那么你需要为`player`和`Moster`也创建同样的函数`void applyDamage(Player* player, int damage)`, `void applyDamage(Monster* moster, int damage)`, 这样是非常不美观, 而且要增加新的派生类的时候, 就要再实现一遍对于那个派生类的特定函数, which is not efficient, 所以, 你可能需要一个这样的函数: `void applyDamage(Base* base, int damage)`, 虽然其对象是`NPC`, `Player`或者`Monster`, 当`applyDamaage`内部需要调用这个对象特定的成员函数的时候, C++的多态机制就发挥作用了, 这个多态机制是通过`virtual`和`override`关键字实现的. 先来看没加这两个关键字会怎样.

### `virtual`和`override`的使用

```cpp
#include <iostream>

class Base {
public:
    Base() { std::cout << "Base Constructor" << std::endl; }
    ~Base() { std::cout << "Base Destructor" << std::endl; }
    void MemberFunc() { std::cout << "Base::MemberFunc()\n"; }
};

class Derived : public Base {
public:
    Derived() { std::cout << "Derived Constructor" << std::endl; }
    ~Derived() { std::cout << "Derived Destructor" << std::endl; }
    void MemberFunc() {
        std::cout << "Derived::MemberFunc()\n";
    }
};

int main() {
    Base* instance = new Derived;
    instance->MemberFunc();
    delete instance;
    return 0;
}
```

输出:

```cpp
Base Constructor
Derived Constructor
Base::MemberFunc()
Base Destructor
```

你会发现, 调用的是`Base`的`MemberFunc()`函数, 而我们想要调用的是`Derived`的`MemberFunc()`函数; 另外, 还有一个很多的安全问题, 你会发现没有调用`Derived`的析构函数, 这会造成巨大的安全风险, 这是因为没有多态, 只有基类的析构函数会被调用, 我们暂时先不管这个问题, 将其改为多态的写法:

```cpp
#include <iostream>

class Base {
public:
    Base() { std::cout << "Base Constructor" << std::endl; }
    ~Base() { std::cout << "Base Destructor" << std::endl; }
    virtual void MemberFunc() { std::cout << "Base::MemberFunc()\n"; }
};

class Derived : public Base {
public:
    Derived() { std::cout << "Derived Constructor" << std::endl; }
    ~Derived() { std::cout << "Derived Destructor" << std::endl; }
    void MemberFunc() override {
        std::cout << "Derived::MemberFunc()\n";
    }
};

int main() {
    Base* instance = new Derived;
    instance->MemberFunc();
    delete instance;
    return 0;
}
```

输出:

```bash
Base Constructor
Derived Constructor
Derived::MemberFunc()
Base Destructor
```

!!! tip "如果你还想调用`Base`的`MemberFunc()`"

    如果你还想调用`Base`的`MemberFunc()`, 可以使用域限定符:

    ```cpp
    int main() {
        Base* instance = new Derived;
        instance->Base::MemberFunc();
        delete instance;
        return 0;
    }
    ```

    C++中其实有个东西叫做vtable, 之后小节会讲.

### `virtual`析构函数

上面留下了还没解决的问题: 没有调用`Derived`的析构函数, 解决:

```cpp linenums="1" hl_lines="6"
#include <iostream>

class Base {
public:
    Base() { std::cout << "Base Constructor" << std::endl; }
    virtual ~Base() { std::cout << "Base Destructor" << std::endl; }
    virtual void MemberFunc() { std::cout << "Base::MemberFunc()\n"; }
};

class Derived : public Base {
public:
    Derived() { std::cout << "Derived Constructor" << std::endl; }
    ~Derived() { std::cout << "Derived Destructor" << std::endl; }
    void MemberFunc() override {
        std::cout << "Derived::MemberFunc()\n";
    }
};

int main() {
    Base* instance = new Derived;
    instance->MemberFunc();
    delete instance;
    return 0;
}
```

### vtable

在C++中, 编译器为含有虚函数的类创建一个隐藏的函数指针数组, 这个数组被称为虚函数表 (vtable). 每个包含虚函数的类的对象都会有一个隐藏的指针, 通常表示为 `__vtbl`, 它指向该类的 vtable. 任何从基类派生出来的类, 也会拥有自己的vtable. 这个vtable的内容会基于派生类对基类虚函数的重写情况: (1) 如果派生类重写了基类的虚函数, 那么派生类vtable中对应的条目会存放派生类重写后函数的地址; (2) 如果派生类没有重写基类的虚函数, 那么派生类vtable中对应条目会直接继承基类vtable中该虚函数的地址.

当创建 `Derived` 类的对象并通过 `Base` 类的指针 `instance` 调用 `MemberFunc()` 时, 程序会通过 `instance` 指向的 `Derived` 对象的 `__vtbl` 指针找到 `Derived` 类的 vtable, 并在其中找到 `Derived::MemberFunc()` 的地址并执行它. 同样地, 当 `delete instance;` 被调用时, 会通过 `Derived` 对象的 vtable 找到正确的析构函数 (`Derived::~Derived` 然后是 `Base::~Base`) 并执行.

## 抽象类

抽象类, 和Java中的接口类似. 里面都是虚函数.

```cpp
#include <iostream>

class IRenderer {
    public:
        virtual void draw() {}
        virtual void update() {}
};

class OpenGL : public IRenderer {
    public:
        void draw() override {
            std::cout << "Drawing with OpenGL" << std::endl;
        }

        void update() override {
            std::cout << "Updating OpenGL state" << std::endl;
        }
};

class Vulkan : public IRenderer {
    public:
        void draw() override {
            std::cout << "Drawing with Vulkan" << std::endl;
        }

        void update() override {
            std::cout << "Updating Vulkan state" << std::endl;
        }
};

int main() {
    IRenderer* myRenderer = new OpenGL;
    myRenderer->draw();
    myRenderer->update();
    IRenderer* myRenderer2 = new Vulkan;
    myRenderer2->draw();
    myRenderer2->update();
    delete myRenderer;
    return 0;
}
```

上面的`IRenderer`就是一个抽象类, 里面有两个虚函数`draw()`和`update()`, 这两个函数没有实现, 只有声明. `OpenGL`和`Vulkan`类继承自`IRenderer`, 并实现了这两个虚函数.

### 纯虚函数

纯虚函数是一个没有实现的虚函数, 在类中声明时使用`= 0`来表示. 任何继承自这个抽象类的派生类都必须实现所有的纯虚函数, 否则会报错.

```cpp linenums="1" hl_lines="5-6"
#include <iostream>

class IRenderer {
    public:
        virtual void draw() = 0;
        virtual void update() = 0;
};

class OpenGL : public IRenderer {
    public:
        void draw() override {
            std::cout << "Drawing with OpenGL" << std::endl;
        }

        void update() override {
            std::cout << "Updating OpenGL state" << std::endl;
        }
};

class Vulkan : public IRenderer {
    public:
        void draw() override {
            std::cout << "Drawing with Vulkan" << std::endl;
        }

        void update() override {
            std::cout << "Updating Vulkan state" << std::endl;
        }
};

int main() {
    IRenderer* myRenderer = new OpenGL;
    myRenderer->draw();
    myRenderer->update();
    IRenderer* myRenderer2 = new Vulkan;
    myRenderer2->draw();
    myRenderer2->update();
    delete myRenderer;
    return 0;
}
```

输出:

```bash
Drawing with OpenGL
Updating OpenGL state
Drawing with Vulkan
Updating Vulkan state
```

!!! warning "抽象类的实例不能调用其内部虚函数之外的函数"

    ```cpp
    #include <iostream>

    class IRenderer {
        public:
            virtual void draw() = 0;
            virtual void update() = 0;
    };

    class OpenGL : public IRenderer {
        public:
            void draw() override {
                std::cout << "Drawing with OpenGL" << std::endl;
            }

            void update() override {
                std::cout << "Updating OpenGL state" << std::endl;
            }
    };

    class Vulkan : public IRenderer {
        public:
            void draw() override {
                std::cout << "Drawing with Vulkan" << std::endl;
            }

            void update() override {
                std::cout << "Updating Vulkan state" << std::endl;
            }
            void hello() {
                std::cout << "Hello from Vulkan" << std::endl;
            }
    };

    int main() {
        IRenderer* myRenderer = new OpenGL;
        myRenderer->draw();
        myRenderer->update();
        IRenderer* myRenderer2 = new Vulkan;
        myRenderer2->draw();
        myRenderer2->update();
        // myRenderer2->hello(); // ❌ 报错
        Vulkan* vulkanRenderer = new Vulkan;
        vulkanRenderer->hello(); // ✅ 可以调用
        delete myRenderer;
        return 0;
    }
    ```

    你会看到, 抽象类的实例`myRenderer2`无法调用`hello`函数, 尽管它是用`new Vulkan`创建的. 但是如果是`Vulkan* vulkanRenderer = new Vulkan;`就可以调用, 这是因为`myRenderer2`是一个抽象类的指针, 它只能调用抽象类中声明的虚函数, 而不能调用派生类中新增的函数.



## 成员函数修饰符

在 C++ 中, 成员函数可以使用多种修饰符来改变它们的行为或访问权限. 以下是一些常见的修饰符:

* `const`:
    * 表示该成员函数不会修改对象的数据成员.
    * 只能在 `const` 对象上调用 `const` 成员函数.

* `virtual`:
    * 声明一个虚函数.
    * 允许在派生类中重写该函数, 实现多态性.

* `override`:
    * (C++11) 明确指示该函数旨在重写基类中的虚函数.
    * 有助于编译器检查错误.

* `final`:
    * (C++11) 指定一个虚函数不能在派生类中被进一步重写.
    * 也可以用于类, 表示该类不能被继承.

* `static`:
    * 表示该函数属于类本身, 而不是类的任何特定实例.
    * 可以通过类名直接调用, 无需创建对象.
    * 不能访问非静态成员变量或调用非静态成员函数.

* `inline`:
    * 建议编译器在调用点内联展开函数体, 以减少函数调用开销.
    * 这只是一个建议, 编译器可以选择忽略.

* `explicit`:
    * (通常用于构造函数) 阻止编译器执行隐式类型转换.

* `constexpr`:
    * (C++11) 表示函数或变量的值可以在编译时确定.
    * 如果传递给 `constexpr` 函数的参数是编译时常量, 则该函数可以在编译时执行.

* `noexcept`:
    * (C++11) 指定一个函数不会抛出异常.
    * 有助于编译器进行优化.

* `= 0` (纯虚函数):
    * 将一个虚函数声明为纯虚函数, 使其所在的类成为抽象类.
    * 抽象类不能被实例化, 派生类必须实现所有纯虚函数才能被实例化.

* `= default`:
    * (C++11) 明确要求编译器生成默认的特殊成员函数 (如构造函数, 析构函数, 拷贝/移动操作).

* `= delete`:
    * (C++11) 禁用某个成员函数 (通常是特殊成员函数), 防止其被调用.

## 零初始化

当你在创建一个对象的时候, 如果这个类没有任何显式构造函数, 那么, 你尝试访问成员变量的时候, 发现输出的都是一些junk. 这是因为C++不会帮你把成员变量自动初始化为默认值. 但是, 如果某个成员变量是一个类类型, 并且这个类有默认的构造函数, 那么这个默认构造函数会被调用来初始化该成员变量, 如果没有默认构造函数, 那么它也可能处于未初始化状态. 可以使用零初始化来解决上述问题, 在创建对象的时候使用`{}`.

```cpp
struct Entity {
    std::string name;
    int* collection;
    int x;
    int y;
};

int main() {
    Entit e{}; // 零初始化
    std::cout << e.name << std::endl;
    std::cout << e.collection std::endl;
    std::cout << e.x << std::endl;
    std::cout << e.y << std::endl;
    return 0;
}
```

## 类内初始化

除了上述零初始化外, 在没有任何显式构造函数的情况下, 还可以在类的里面使用`{}`定义初始值, 并且, 相较于零初始化有更高的优先级.

```cpp
struct Entity {
    std::string name;
    int* collection{nullptr}; // 类内初始化
    int x{1}; // 类内初始化
    int y{7}; // 类内初始化
};

int main() {
    Entit e{}; // 零初始化
    std::cout << e.name << std::endl;
    std::cout << e.collection std::endl;
    std::cout << e.x << std::endl;
    std::cout << e.y << std::endl;
    return 0;
}
```

输出是`0 1 7`, 因为类内初始化优先级更高.

## 委托构造函数初始化列表 {#delegation-constructor-initializer}

到现在为止, 我看到了构造函数后面加`:`的两种用途, 第一种, 初始化成员变量, 第二种, 继承过程中调用基类的构造函数; 那么, 现在, 第三种, 可不可以调用自己的另一个构造函数呢? 这就是委托构造函数的用法. 它能防止写重复的代码, 也就是说如果我可以复用在另一个构造函数中的代码.

```cpp
#include <iostream>

class Rectangle {
private:
    double length;
    double width;

public:
    // 目标构造函数 (Target Constructor): 所有的初始化逻辑都在这里.
    Rectangle(double l, double w) : length(l), width(w) {
        std::cout << "正在调用目标构造函数 (" << l << ", " << w << ")..." << std::endl;
        // ... 所有复杂的初始化代码只需要写一次 ...
    }

    // 委托构造函数 1: 创建正方形.
    // 它将工作委托给 Rectangle(double, double).
    Rectangle(double side) : Rectangle(side, side) { // 委托!
        std::cout << "正在调用委托构造函数 (正方形)..." << std::endl;
        // 这个函数体会在 Rectangle(side, side) 执行完毕后执行.
    }

    // 委托构造函数 2: 创建默认矩形.
    // 它将工作委托给 Rectangle(double). (它又会委托给第一个)
    Rectangle() : Rectangle(1.0) { // 委托!
        std::cout << "正在调用默认委托构造函数..." << std::endl;
    }

    void print() {
        std::cout << "长: " << length << ", 宽: " << width << std::endl;
    }
};

int main() {
    std::cout << "创建 r1 (5, 3):" << std::endl;
    Rectangle r1(5.0, 3.0);
    r1.print();
    std::cout << std::endl;

    std::cout << "创建 r2 (4):" << std::endl;
    Rectangle r2(4.0); // 调用 Rectangle(double), 它会委托给 Rectangle(double, double)
    r2.print();
    std::cout << std::endl;

    std::cout << "创建 r3 ():" << std::endl;
    Rectangle r3;      // 调用 Rectangle(), 它会委托给 Rectangle(double)
    r3.print();
    std::cout << std::endl;

    return 0;
}
```

!!! warning "一个构造函数要么进行委托, 要么进行基类/成员初始化"

    如果一个构造函数在它的初始化列表中调用了同一个类的另一个构造函数 (即使用了委托构造函数), 那么这个初始化列表只能包含这一个委托调用, 不能再包含任何基类或成员变量的初始化.

## 构造函数初始化列表

总结一下, 一共三种:

* [成员变量初始化列表](#member-variable-initializer)
* [基类构造函数初始化列表](#base-constructor-initializer)
* [委托构造函数初始化列表](#delegation-constructor-initializer)

## 类的空间分布

C++中的类中成员变量在内存之间其实可能有padding的. 这会造成空间上的一定浪费. 这是因为内存分配大小是由类中最大的那个类型决定的, 比如说`double`占到了8个字节, 所以像是`bool`类型的就用不到那么大的空间. 比如说下面这个类:

```cpp
struct GameState {
    bool checkpoint;
    float score;
    short number_of_players;
}
```

在内存中的分布是, checkpoint占1个字节, 然后3个字节的padding, 然后4个字节的score, 然后2个字节的number_of_players, 然后两个字节的number_of_players, 总共占到了12个字节. 我们怎么对这个进行优化呢? well, 我们可以把number_of_players放到checkpoint后面的那3个字节的padding的位置:

```cpp
struct GameState {
    bool checkpoint;
    short number_of_players;
    float score;
}
```

现在, 只占到了`8`个字节. 所以最好把小的类型放在前面声明.

## pIMPL

在`hpp`文件中, 我们一般是可以看到类中`private`小节的实现的, 但是有些大公司就不满意了, 我不想让我的客户看见`private`部分的代码, 这就是为什么我们需要pIMPL(pointer to implementation).

```cpp title="person.hpp"
#ifndef PERSON_HPP
#define PERSON_HPP
#include <string>
#include <memory>

class Person {
    public:
        Person(std::string s);
        ~Person();
        std::string GetAttributes();
    private:
        struct pImplPerson;
        std::unique_ptr<pImplPerson> m_impl;
}
#endif
```

```cpp title="person.cpp"
#include "person.cpp"

struct Person::pImplPerson {
    std::string m_name;
    std::string m_strength;
    std::string m_speed;
};

Person::Person(std::string s) {
    m_impl = std::make_unique<pImplPerson>();
    m_impl -> m_name = s; // 由于你在pIMPL中定义了成员, 所以先要访问pIMPL的成员
    m_impl -> m_strength = "n/a";
    m_impl -> m_speed = "n/a";
}

Person::~Person() {
    // 不需要删除m_impl, 智能指针会帮我们管理
}
```

```cpp title="main.cpp"
#include <iostream>
#include "Person.hpp"

int main() {
    Person mike("mike");
    std::cout << mike.GetAttributes() << std::endl;
    return 0;
}
```

使用pIMPL还有一个好处, 如果我们需要新增私有成员变量, 我们无需修改hpp文件, 只需要修改cpp文件就可以了, 然后重新编译.

## `this`关键字

`this`是一个指针, 它只能在类的非静态成员函数内部使用, 指向调用该成员函数的那个对象市里, 和JavaScript中的那个`this`比较像. 当你在成员函数中直接访问成员变量, 如`m_var`或者调用其他非静态成员函数的时候, 编译器其实在背后隐式地使用了`this`指针, 如`this -> m_var`. 当成员函数的参数或局部参数和成员变量同名的时候, 必须使用`this ->`来明确指代成员变量. 它可以用于返回调用它的对象(在拷贝赋值操作符中, 我们返回的就是`*this`, 可以用于实现链式赋值).

```cpp
#inlcude <iostream>

class Person {
    public:
        Person(int age) {
            this.age = age;
            // age = age; // 不行
        }
    private:
        int age;
}

int main() {
    Person mike(500);
    std::cout << mike.GetAge() << std::endl;
    return 0;
}
```

## `static`关键字

static是除了堆和栈之外的另一种存储区域.

```cpp
#include <iostream>
int main() {
    int x = 0;
    int *p = new int;
    delete p;
    return 0;
}
```

在这里面, `x`和`p`处于栈中, `p`所指向的对象处于堆中. Ok, 我们来创建一个`static`.

```cpp
#include <iostream>
void foo() {
    static int s_variable = 0;
    s_variable += 1;
    std::cout << s_variable << std::endl;
}
int main() {
    for (int i = 0; i < 10; i++) {
        foo();
    }
    return 0;
}
```

这个`s_variable`在static区域或者叫做静态区中. 输出为:

```bash
1
2
3
4
5
6
7
8
9
10
```

你会发现, 静态区中的变量从程序开始(或者在函数第一次被调用)的时候就存在, 知道程序结束才被销毁. 而且静态局部变量只会被初始化一次 `static int s_variable=0;`只会在`foo()`第一次被调用的时候执行, 后续的调用会跳过初始化, 直接使用变量的当前值, 这就是为什么输出是`1 2 3...`, 而不是`1 1 1...`.

`static`关键字还在C++中有其他的重要用途, 包括:


1.  静态成员变量 (Static Member Variables):

    * 它们存储在静态存储区, 它们不存在于对象中, 只是需要一个域限定符`className::`来访问.
    * 就像之前例子里的 `s_variable` 一样, 它们具有静态存储期 (static storage duration). 这意味着它们在程序开始时 (或者首次需要时) 被分配内存, 并且在整个程序运行期间都存在, 直到程序结束才被释放.
    * 它们不属于任何特定的对象实例, 只有一份拷贝, 供所有对象共享 (或者在没有对象时也能访问, 因为它不是存储在对象里面的, 是存储在静态区的).

    ```cpp
    #include <iostream>

    struct API {
        API() {};
        ~API() {};
        static int MAJOR;
        static int MINOR;
    }

    int API::MAJOR = 7;

    int main() {
        std::cout << "Major:" << API::MAJOR << std::endl;
        return 0;
    }
    ```

    !!! warning "静态成员变量必须在类外部声明"

        静态成员变量必须在类的外部声明, 并且不能在任何函数内部声明, 说白了就是在全局作用域中声明, 一方面是因为C++ 语法规定静态数据成员的定义必须在类定义之外的命名空间作用域进行, 将其放入函数内部不符合该语法. 另一方面是因为在函数内部定义变量(如 main 中)会使该变量成为局部变量, 其作用域和生命周期仅限于该函数. 这与静态成员变量的特性相冲突.

        下面的这种就是错误的做法:

        ```cpp
        #include <iostream>

        struct API {
            API() {};
            ~API() {};
            int m_local;
            static int MAJOR;
            static int MINOR;

            static int GetMajorVersion() {
                // std::cout << this << std::endl; // 报错
                // reutrn m_local;  //  报错
                return MAJOR;
            }
        };

        int main() {
            int API::MAJOR = 7;
            std::cout << "Major:" << API::MAJOR << std::endl;
            std::cout << "Major:" << API::GetMajorVersion() << std::endl;
            return 0;
        }
        ```

        下是正确的做法:

        ```cpp
        #include <iostream>

        struct API {
            API() {};
            ~API() {};
            int m_local;
            static int MAJOR;
            static int MINOR;

            static int GetMajorVersion() {
                // std::cout << this << std::endl; // 报错
                // reutrn m_local;  //  报错
                return MAJOR;
            }
        };

        int API::MAJOR;

        int main() {
            API::MAJOR = 7;
            std::cout << "Major:" << API::MAJOR << std::endl;
            std::cout << "Major:" << API::GetMajorVersion() << std::endl;
            return 0;
        }
        ```

2.  静态成员函数 (Static Member Functions):

    * 代码通常存储在内存中的一个特殊区域, 称为 代码段 (Code Segment) 或 文本段 (Text Segment). 这个区域通常是只读的.
    * 函数本身并不 "存储" 在静态区. 它们被称为 "静态" 主要是因为:

        * 它们不与任何特定的对象实例绑定 (它们没有 `this` 指针).
        * 它们可以通过类名直接调用 (`ClassName::static_function()`).
        * 它们只能直接访问静态成员变量 (因为它们没有 `this` 指针来访问非静态成员).

    ```cpp
    #include <iostream>

    struct API {
        API() {};
        ~API() {};
        int m_local;
        static int MAJOR;
        static int MINOR;

        static int GetMajorVersion() {
            // std::cout << this << std::endl; // 报错
            // reutrn m_local;  //  报错
            return MAJOR;
        }
    }

    int API::MAJOR = 7;

    int main() {
        std::cout << "Major:" << API::MAJOR << std::endl;
        std::cout << "Major:" << API::GetMajorVersion() << std::endl;
        return 0;
    }
    ```

## 嵌套类

在C++中, 嵌套类 (nested class) 也是指在一个类的声明或定义内部声明或定义的另一个类. 它的主要特点为:

1. 作用域: 嵌套类的名称位于其外部类的作用域内, 要在外部类的作用域之外使用嵌套类, 需要使用外部类的名称作为前缀, 如 `OuterClass::NestedClass`.
2. 访问权限: 嵌套类的成员函数可以访问其外部类的所有成员. 但是如果要访问外部类的非静态成员, 嵌套类的成员函数需要一个外部类对象的实例(例如, 通过传递一个外部类对象的指针或引用), 嵌套类本身不持有外部类实例的隐式`this`指针. 外部类对嵌套类的成员没有特殊的访问权限, 访问权限遵循嵌套类中成员的访问修饰符(`public`, `protected`, `private`). 如果外部类需要访问嵌套类中的私有成员, 嵌套类可以将外部类声明为友元类. 
3. 独立性: 可以独立于外部类的对象来创建嵌套类的对象
4. 封装和组织: 用于将逻辑上紧密相连的类组织在一起, 可以将辅助来或者实现细节隐藏在主类的内部, 减少全局命名空间的污染. 

```cpp
#include <iostream>
#include <vector>

class ParticleSystem {
    public:
    struct Particle {
        float x{0.0f};
        float y{0.0f};
        float z{0.0f};
        float speed{1.0f};
        float lifetime{50.0f};
        void move() {};
    };
    void Simulation() {
        for (size_t i = 0; i < m_particles.size(); ++i) {
            m_particles[i].move();
        }
    }
    private:
    std::vector<Particle> m_particles;
};

int main() {
    ParticleSystem p;
    ParticleSystem::Particle individual_particle;
    p.Simulation();
    return 0;
}
```

## `mutable`的用法

在C++中, `mutable`关键字的作用是允许类的某个数据成员即使在对象被声明为`const`时也能被修改. 通常, 当一个对象被声明为`const`时, 它的所有非`static`数据成员都不能被修改. 但是, 如果你希望某个特定的数据成员可以在`const`成员函数中被修改, 或者在一个`const`对象中被修改, 就可以将其声明为`mutable`.

```cpp
#include <iostream>
#include <vector>

struct Point3f {
    public:
    explicit Point3f(float _x, float _y, float _z) : x{_x}, y{_y}, z{_z} {};
    void change_w(float new_w) const {
        w = new_w;
    }
    float x, y, z;
    mutable float w;
};

int main() {
    Point3f p{1.0f, 2.0f, 3.0f};
    p.change_w(5.0f);
    std::cout << p.x << std::endl << p.y << std::endl << p.z << std::endl << p.w << std::endl;
    return 0;
}
```

输出:

```bash
1
2
3
5
```