---
title: 对象
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

## 成员初始化列表

### 为啥要用

C++中的成员初始化列表(Member Initializer Lists)是在构造函数中初始化类成员变量的一种简洁而高效的方式. 有些小朋友可能会问, 为啥不直接在构造函数里面直接赋值的方法呢?

因为成员初始化列表直接对成员进行初始化, 想象一下你正在创建一个新的盒子, 你直接在制作这个盒子的过程中就放入了特定的物品, 成员初始化列表就像这个过程, 它在对象创建的时候就赋予了成员变量初始值. 而在构造函数里面赋值就相当于你先创建了一个空盒子, 然后打开盒子放入物品. 在构造函数体内部赋值就像这个过程, 成员变量首先会被赋予一个默认值(如果存在), 然后再在构造函数内部赋予新的值. 所以关键区别在于, 初始化是一步到位, 但是赋值可能涉及到先初始化, 再赋予新值两个步骤.

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

### 直接vs贝列表初始化

```cpp
struct C{
    C(int,int);          // 隐式
    explicit C(int);     // 显式
};

C c1{1,2};      // OK, 直接列表初始化
C c2 = {1,2};   // OK, 拷贝列表初始化

C c3{1};        // OK, explicit 可用
// C c4 = {1};  // ❌ explicit 禁止使用拷贝列表初始化
```

> 口诀: `T obj{...}` 能用 `explicit`, `T obj = {...}` 不能.


## `explicit` 关键字

* 目的: 禁止"隐式"把其他类型转成该类.
* 不影响你显式调用构造函数, 也不阻止基本类型的标准转换.
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
UDT u5(5.8f);      // ✅ float → int 标准转换后再直接初始化
```

为什么 `UDT u1 = 5;` 出错?
拷贝初始化会尝试先把 `5` 隐式转换成临时 `UDT`, explicit 禁止了这一步; `UDT u1 = {5};` 同理.
