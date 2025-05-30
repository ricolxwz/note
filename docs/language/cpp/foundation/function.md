---
title: 函数
comments: true
icon: material/function-variant
---

## 作用域

可以使用花括号来定义域.

## 循环

循环的语法是和C那里一样的.

```cpp
#include <iostream>
#include <array>

int main() {;
    int arr[] = {1, 3, 5};
    for(int i = 0; i < 3; i++) {
        std::cout << arr[i] << std::endl;
    }
    std::array<int, 3> arr2 = {1, 3, 5};
    for (int i = 0; i < arr2.size(); i++) {
        std::cout << arr2[i] << std::endl;
    }
    // 基于range的for循环, 有点像python中的for ... in ...循环
    for (auto element : arr2) {
        std::cout << element << std::endl;
    }
    // while循环
    while(true) { // 手动创建一个死循环
        std::cout << "Hello, World!" << std::endl;
    }
    // do while循环
    do {
        std::cout << "Hello, World!" << std::endl;
    } while (true);
    return 0;
}
```

!!! note "`auto`"

    `auto`是C++11引入的一个关键字, 用于自动推导变量的类型. 在上面的例子中, `element`的类型会被自动推导为`int`, 这使得代码更加简洁和易读. 在使用`auto`时, 需要注意变量的类型会在编译时确定.

!!! note "`auto&`"

    上述代码中的`auto`可以写为`auto&`, 这样可以避免拷贝, 直接引用原来的对象. 如果在循环体中修改了`element`, 那么原来的对象也会被修改. 但是如果使用`auto`, 那么`element`是一个拷贝, 修改它不会影响原来的对象.

## 函数不能在其他函数内部

需要注意的是, C++的函数不能定义在其他函数的内部. 主要有这几个考虑点, 我认为其中比较重要的是代码的组织和可读性, 函数本身是一个清晰, 独立的逻辑单元. 当然, 还有其他的一些原因, 比如说闭包, 链接的原因. 还有一点是, 函数必须在使用之前定义. 还有一点是, C++的函数支持重载, 这个在C, Python里面是不行的.

## 操作符重载

在C++中, 有很多的操作符都可以重载, 例如, +, -, *, /, <, <<, <=>, ... 操作符的作用就是不用写函数的名称, 可以直接使用操作符代替, 但是在实际写代码中, 不推荐,.... , 因为用到最后, 你可能自己都忘了有这个操作符重载, 然后搞出bug.

```cpp
#include <iostream>

class Vector3f {
public:
    Vector3f() {
        x = 0.0f;
        y = 0.0f;
        z = 0.0f;
    }
    Vector3f(const Vector3f& other) {
        std::cout << "Copy Constructor Called" << std::endl;
        x = other.x;
        y = other.y;
        z = other.z;
    }
    Vector3f& operator=(const Vector3f& other) {
        std::cout << "Copy Assignment Operator Called" << std::endl;
        x = other.x;
        y = other.y;
        z = other.z;
        return *this;
    }
    Vector3f operator+(const Vector3f& other) {
        Vector3f result;
        result.x = x + other.x;
        result.y = y + other.y;
        result.z = z + other.z;
        return result; // 这里会调用拷贝构造函数, 因为返回的不是一个引用, 是一个对象
    }
    Vector3f& operator++() {
        x = x + 1;
        y = y + 1;
        z = z + 1;
        return *this;
    }
    bool operator==(const Vector3f& rhs) {
        if (x == rhs.x && y == rhs.y && z = rhs.z) {
            return true;
        }
        return false;
    }
    float x, y, z;
};

std::ostream& operator<<(std::ostream& os, const Vector3f& v) { // 注意, 必须定义在外面, 因为操作符的左边不是Vector3f的示例
    os << v.x << " " << v.y << " " << v.z;
    return os; // 不会自动RVO
}

int main() {
    Vector3f myVector;
    myVector.x = 1.0f;
    myVector.y = 2.0f;
    myVector.z = 3.0f;
    Vector3f myVector2;
    myVector2.x = 4.0f;
    myVector2.y = 5.0f;
    myVector2.z = 6.0f;
    Vector3f myVector3;
    myVector3 = myVector + myVector2; // 这里首先会调用我们自己定义的操作符=, 然后调用拷贝赋值操作符=
    std::cout << myVector3.x << " " << myVector3.y << " " << myVector3.z << std::endl;
    ++myVector3;
    if (myVector == myVector2) {
        std::cout << "Vectors are qeual" << std::endl;
    } else {
        std::cout << "Vectors are not equal" << std::endl;
    }
    return 0;
}
```

然后编译运行:

```bash
$ g++ main.cpp -o proj && ./proj
Copy Assignment Operator Called
5 7 9
```

然后你会发现, 嗯? 怎么`return result`为啥没有调用拷贝构造函数, 照理来说, 如果它返回的是一个对象的话, 它就会调用拷贝构造函数构造出一个临时对象返回啊? 这是因为C++的编译器非常智能, 他进行了返回值优化, 若要禁用返回值优化, 可以在编译的时候加上`-fno-elide-constructors`选项:

```bash
g++ main.cpp -o proj -fno-elide-constructors  && ./proj
Copy Constructor Called
Copy Assignment Operator Called
5 7 9
```

!!! note "操作符函数的位置"

    看了上面的代码, 你会发现有些操作符函数定义在一个类的内部, 但是也有操作符函数是定义在类的外面的. well, 如果定义在类的里面, 操作符函数最多只能接受一个参数, 也就是rhs, 二元运算符; 或者不接受参数, 一元运算符. 如果定义在类的外面, 可以接受一个或者两个参数, 一个参数对应的是一元运算符, 两个参数对应的是二元运算符. 老师的建议是最好把这种操作符函数写在外面, 这样就可以很清楚的知道可以用啥参数. 然后, 还要强调一下, 如果有两个重载相同操作符的操作符重载函数, 一个写在类里面, 一个写在类外面, 那么默认类里面的优先级更高.

## 返回值优化(RVO)

返回值优化 (Return Value Optimization, RVO) 是 C++ 编译器使用的一种重要的性能优化技术. 它的核心思想是: 当一个函数按值返回一个对象时, 通常会创建一个临时对象来存储返回值, 然后再将这个临时对象拷贝 (或移动) 到接收它的变量中. RVO 的目的就是消除 (elide) 这些中间的临时对象和相关的拷贝/移动操作.

1.  RVO: 广义上的返回值优化.
2.  NRVO (Named Return Value Optimization): RVO 的一种常见形式, 特指当函数返回一个具名的局部变量时 (就像之前的 `result` 对象).

编译器会改变函数的调用方式. 它会安排函数直接在调用方预留给最终结果的内存位置上构造返回的对象, 如上面`result`对象直接构造在`myVector3`的坑位上, 而不是先在函数内部构造一个局部对象, 然后再拷贝出来. 它能显著减少了不必要的拷贝构造函数的调用, 尤其是在返回大型对象时, 能极大地提升程序性能. 允许开发者更自然地按值返回对象. 可以使用`-fno-elide-constructors`禁用.

!!! warning "RVO触发的前提"

    RVO触发的前提是那个对象必须是在函数的内部创建的, 不能是在scope之外的对象. 如果是之外的对象, 编译器无法优化这个对象的构造过程, 因为这个对象已经构造完毕了. 例如下面的这个例子:

    ```cpp
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
    ```

    这个时候, 是会调用拷贝构造函数的, 因为`*this`是一个在scope之外的对象, 已经创建好了, RVO无法优化.

## 工厂函数

工厂函数是用于创建对象的函数. 他们常用于抽象对象创建的逻辑, 隐藏对象的具体类型和创建过程. 工厂函数的主要优点包括: (1) 封装性, 他们封装了对象创建的细节, 客户端代码不需要知道如何创建对象, 只需要调用工厂函数即可. (2) 灵活性: 工厂函数可以根据不同的输入返回不同类型的对象, 从而提高更大的灵活性. (3) 延迟实例化: 对象可以在被需要的时候才创建; (4) 易于测试: 可以更容易地替换工厂函数以进行单元测试.

```cpp
#include <iostream>
#include <string>
#include <memory>

// 接口类
class Shape {
public:
    virtual ~Shape() {}
    virtual void draw() = 0;
};

// 具体类: Circle
class Circle : public Shape {
private:
    double radius;
public:
    Circle(double r) : radius(r) {}
    void draw() override {
        std::cout << "Drawing a circle with radius: " << radius << std::endl;
    }
};

// 具体类: Rectangle
class Rectangle : public Shape {
private:
    double width;
    double height;
public:
    Rectangle(double w, double h) : width(w), height(h) {}
    void draw() override {
        std::cout << "Drawing a rectangle with width: " << width << " and height: " << height << std::endl;
    }
};

// 工厂函数
std::unique_ptr<Shape> createShape(const std::string& type, double param1 = 0, double param2 = 0) {
    if (type == "circle") {
        return std::make_unique<Circle>(param1);
    } else if (type == "rectangle") {
        return std::make_unique<Rectangle>(param1, param2);
    } else {
        return nullptr;
    }
}

int main() {
    // 使用工厂函数创建对象
    std::unique_ptr<Shape> circle = createShape("circle", 5.0);
    if (circle) {
        circle->draw();
    }

    std::unique_ptr<Shape> rectangle = createShape("rectangle", 4.0, 6.0);
    if (rectangle) {
        rectangle->draw();
    }

    std::unique_ptr<Shape> unknown = createShape("triangle", 3.0, 3.0);
    if (!unknown) {
        std::cout << "Unknown shape type." << std::endl;
    }

    return 0;
}
```

BTW, `std::make_unique`这个函数也是工厂函数. 