---
title: 算法
comments: true
icon: material/cow
---

## 一些建议

### 优先使用容器的成员函数

某些操作既可以在通用算法库中找到, 如`std::find`, 又可以在特定容器成员函数中找到, 如`std::set::find`. 当一个算法同时有通用版本和容器成员函数版本的时候, 强烈推荐使用容器自身的版本. 因为容器的成员函数了解其内部数据结构, 所以通常经过了特别优化, 性能更好. 例如, 在`std::set`上调用`std::set::find`效率远远高于通用的`std::find`, 前者利用`std::set`的红黑树结构, 时间复杂度为`O(log n)`, 而后者需要遍历整个容器, 时间复杂度为`O(n)`.

### 正交设计

这是STL设计的一个关键哲学. “正交”的意思就是独立或者解耦; 算法的设计独立于容器的设计. 他们之间通过迭代器这个桥梁进行通信. 这种设计实现了泛型编程, 你可以编写一个算法, 比如`std::sort`, 然后将它作用于任何兼容迭代器的容器, 如`std::vector`, `std::deque`等, 无需为每种容器重写排序逻辑.

### 避免原生循环

建议使用算法库中的函数, 如`std::for_each`, `std::transform`, `std::accumulate`等来代替手写的`for`或者`while`循环. 这样做的好处是代码意图更加清晰, 函数名直接说明了操作的目的; 更少的错误, 避免了手写循环的时候可能出现的边界错误; 更高的性能, 标准库的实现经过了高度优化, 可能比手写的循环更快.

## 搜索 🔍

### 修改性序列算法/非修改性序列算法

非修改性序列算法 (Non-modifying sequence algorithms) 是C++标准模板库(STL)中的一类函数, 它们用于查询或处理一个元素序列(例如, `vector`或`list`中的数据), 但绝不会改变序列中元素的值或顺序. 它们只读取数据并返回查询结果. 可以把它们想象成对数据进行 "只读" 操作的工具. 它们会遍历容器内的元素, 检查它们的属性或在其中寻找特定内容, 但会保证操作结束后, 原始容器的数据完好无损. 与之相对的是修改性序列算法, 例如 `sort` (排序), `remove` (移除元素), `copy` (复制), `reverse` (反转序列), 这些算法会直接改变容器内元素的值或它们的排列顺序.

### `std::find`

`find`算法用于在一个序列中查找特定值的第一次出现. 它通过逐个比较序列中的元素与给定值来实现.

函数原型

```cpp
template<class InputIt, class T>
InputIt find(InputIt first, InputIt last, const T& value);
```

* `first`, `last`: 定义了搜索范围的输入迭代器`[first, last)`.
* `value`: 需要查找的值.

返回值

* 如果找到该值, 返回指向序列中第一个匹配元素的迭代器.
* 如果没有找到, 返回`last`.

示例

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

int main() {
    std::vector<int> vec = {10, 20, 30, 40, 50};
    int value_to_find = 30;

    auto it = std::find(vec.begin(), vec.end(), value_to_find);

    if (it != vec.end()) {
        std::cout << "找到了值: " << *it << ", 索引是: " << std::distance(vec.begin(), it) << std::endl;
    } else {
        std::cout << "未找到值." << std::endl;
    }
    return 0;
}
```

输出结果

```
找到了值: 30, 索引是: 2
```

### `std::find_if`

`find_if`算法用于在一个序列中查找第一个满足特定条件的元素. 条件由一个一元谓词(一个返回布尔值的函数或函数对象)指定.

函数原型

```cpp
template<class InputIt, class UnaryPredicate>
InputIt find_if(InputIt first, InputIt last, UnaryPredicate p);
```

* `first`, `last`: 定义了搜索范围的输入迭代器`[first, last)`.
* `p`: 一元谓词, 应用于序列中的每个元素. `find_if`会返回第一个使`p`返回`true`的元素.

返回值

* 如果找到满足条件的元素, 返回指向该元素的迭代器.
* 如果没有找到, 返回`last`.

示例

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

// 谓词函数: 检查一个数是否是偶数
bool is_even(int i) {
    return (i % 2) == 0;
}

int main() {
    std::vector<int> vec = {1, 3, 5, 8, 10, 12};

    auto it = std::find_if(vec.begin(), vec.end(), is_even);

    if (it != vec.end()) {
        std::cout << "找到了第一个偶数: " << *it << ", 索引是: " << std::distance(vec.begin(), it) << std::endl;
    } else {
        std::cout << "未找到偶数." << std::endl;
    }
    return 0;
}
```

输出结果

```
找到了第一个偶数: 8, 索引是: 3
```

### `std::search`

`search`算法用于在一个序列中查找另一个子序列的第一次出现.

函数原型

```cpp
template<class ForwardIt1, class ForwardIt2>
ForwardIt1 search(ForwardIt1 first1, ForwardIt1 last1,
                  ForwardIt2 first2, ForwardIt2 last2);
```

* `first1`, `last1`: 定义了主序列的范围`[first1, last1)`.
* `first2`, `last2`: 定义了要查找的子序列的范围`[first2, last2)`.

返回值

* 如果找到子序列, 返回一个指向主序列中子序列起始位置的迭代器.
* 如果主序列中不存在该子序列, 返回`last1`.

示例

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

int main() {
    std::vector<int> main_vec = {1, 2, 3, 4, 5, 6, 7, 3, 4, 5, 8};
    std::vector<int> sub_vec = {3, 4, 5};

    auto it = std::search(main_vec.begin(), main_vec.end(), sub_vec.begin(), sub_vec.end());

    if (it != main_vec.end()) {
        std::cout << "子序列找到了, 起始位置索引是: " << std::distance(main_vec.begin(), it) << std::endl;
    } else {
        std::cout << "未找到子序列." << std::endl;
    }
    return 0;
}
```

输出结果

```
子序列找到了, 起始位置索引是: 2
```

### `std::adjacent_find`

`adjacent_find`算法用于在一个序列中查找第一对相等的相邻元素.

函数原型

```cpp
template<class ForwardIt>
ForwardIt adjacent_find(ForwardIt first, ForwardIt last);
```

* `first`, `last`: 定义了搜索范围的前向迭代器`[first, last)`.

返回值

* 如果找到这样一对相邻元素, 返回指向第一个元素的迭代器.
* 如果没有找到, 返回`last`.

示例

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

int main() {
    std::vector<int> vec = {1, 2, 3, 3, 4, 5, 5};

    auto it = std::adjacent_find(vec.begin(), vec.end());

    if (it != vec.end()) {
        std::cout << "找到了第一对相邻的相等元素: " << *it << ", 索引是: " << std::distance(vec.begin(), it) << std::endl;
    } else {
        std::cout << "未找到相邻的相等元素." << std::endl;
    }
    return 0;
}
```

输出结果

```
找到了第一对相邻的相等元素: 3, 索引是: 2
```

### 总结比较

| 算法 | 主要用途 | 查找目标 |
| :--- | :--- | :--- |
| `find` | 查找单个 特定值 | 单个元素 |
| `find_if` | 查找满足 特定条件 的单个元素 | 单个元素 |
| `search` | 查找一个 子序列 | 元素序列 |
| `adjacent_find` | 查找第一对 相等的相邻元素 | 两个相邻元素 |

### `std::lower_bound`, `std::upper_bound`

`std::lower_bound`返回一个迭代器, 指向序列中第一个不小于 (not less than) 给定值的元素. 换句话说, 它是第一个大于或等于给定值的元素的位置.

函数原型:

```cpp
// 1. 使用 operator<
template< class ForwardIt, class T >
ForwardIt lower_bound( ForwardIt first, ForwardIt last, const T& value );

// 2. 使用自定义比较函数
template< class ForwardIt, class T, class Compare >
ForwardIt lower_bound( ForwardIt first, ForwardIt last, const T& value, Compare comp );
```

关键特性:

* 返回值:
    * 如果找到一个或多个等于`value`的元素, 返回指向第一个`value`的迭代器.
    * 如果没有等于`value`的元素, 返回指向第一个大于`value`的元素的迭代器.
    * 如果`value`大于序列中所有元素, 返回`last`迭代器.
* 记忆技巧: 把它想成在寻找`value`可以插入的最低 (最左侧) 的边界, 而不破坏排序.

---

`std::upper_bound`返回一个迭代器, 指向序列中第一个大于 (greater than) 给定值的元素.

函数原型:

```cpp
// 1. 使用 operator<
template< class ForwardIt, class T >
ForwardIt upper_bound( ForwardIt first, ForwardIt last, const T& value );

// 2. 使用自定义比较函数
template< class ForwardIt, class T, class Compare >
ForwardIt upper_bound( ForwardIt first, ForwardIt last, const T& value, Compare comp );
```

关键特性:

* 返回值:
    * 无论是否存在等于`value`的元素, 都返回指向第一个严格大于`value`的元素的迭代器.
    * 如果`value`大于或等于序列中所有元素, 返回`last`迭代器.
* 记忆技巧: 把它想成在寻找`value`可以插入的最高 (最右侧) 的边界, 而不破坏排序.

### `std::binary_search`

`std::binary_search`是一个C++标准库算法, 用于高效地检查一个已排序的序列中是否存在某个特定的值. 🕵️ 它的工作方式类似于在字典中查词: 从中间开始, 如果目标值更大, 就查找后半部分; 如果更小, 就查找前半部分, 依此类推, 直到找到或确定不存在.

核心要点:

* 前提条件: 序列必须已经根据所用的比较标准排好序. 如果序列未排序, 其行为是未定义的.
* 返回值: 这是一个简单的谓词函数, 只返回一个布尔值 (`bool`).
    * `true`: 找到了该元素.
    * `false`: 未找到该元素.
* 功能: 它只告诉你元素存不存在, 并不会返回元素的位置 (迭代器). 如果你需要找到元素的位置, 应该使用 `std::lower_bound`.
* 性能: 非常高效, 时间复杂度为对数时间, 即$O(\log N)$.

函数原型:

```cpp
// 1. 使用 operator< 进行比较
template<class ForwardIt, class T>
bool binary_search(ForwardIt first, ForwardIt last, const T& value);

// 2. 使用自定义比较函数
template<class ForwardIt, class T, class Compare>
bool binary_search(ForwardIt first, ForwardIt last, const T& value, Compare comp);
```

示例:

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

int main() {
    std::vector<int> v = {10, 20, 30, 40, 50}; // 必须是已排序的

    // 检查存在的元素
    int value_to_find = 30;
    if (std::binary_search(v.begin(), v.end(), value_to_find)) {
        std::cout << "Found " << value_to_find << " in the vector." << std::endl;
    } else {
        std::cout << value_to_find << " is not in the vector." << std::endl;
    }

    // 检查不存在的元素
    value_to_find = 25;
    if (std::binary_search(v.begin(), v.end(), value_to_find)) {
        std::cout << "Found " << value_to_find << " in the vector." << std::endl;
    } else {
        std::cout << value_to_find << " is not in the vector." << std::endl;
    }

    return 0;
}
```

输出

```
Found 30 in the vector.
25 is not in the vector.
```

### `std::includes`

`std::includes`是C++标准库`<algorithm>`头文件中的一个函数模板, 用于检查一个有序序列中的所有元素是否都存在于另一个有序序列中. 换言之, 它可以判断一个集合是否是另一个集合的子集.

定义:

`std::includes`会检查序列`[first2, last2)`中的每个元素是否都存在于序列`[first1, last1)`中.

```cpp
template<class InputIt1, class InputIt2>
bool includes(InputIt1 first1, InputIt1 last1,
              InputIt2 first2, InputIt2 last2);

template<class InputIt1, class InputIt2, class Compare>
bool includes(InputIt1 first1, InputIt1 last1,
              InputIt2 first2, InputIt2 last2, Compare comp);
```

参数:

* `first1`, `last1`: 定义第一个有序序列的输入迭代器.
* `first2`, `last2`: 定义第二个有序序列的输入迭代ator.
* `comp`: 一个可选的二元谓词 (binary predicate), 用于比较两个元素. 如果不提供, 则默认使用`<`运算符.

返回值:

* 如果序列`[first2, last2)`中的所有元素都在序列`[first1, last1)`中找到, 则返回`true`.
* 否则返回`false`.

前提条件:

* 两个序列`[first1, last1)`和`[first2, last2)`都必须已经按照相同的标准排好序 (默认是升序).
* 如果提供了自定义比较函数`comp`, 那么两个序列都必须是根据该函数排好序的.

复杂度:

该算法的时间复杂度是线性的, 最多进行$2 \cdot (\text{N1} + \text{N2}) - 1$次比较, 其中`N1`和`N2`分别是两个序列的长度.

示例:

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

int main() {
    std::vector<int> v1 = {1, 2, 3, 4, 5, 6, 7};
    std::vector<int> v2 = {3, 5, 7};
    std::vector<int> v3 = {3, 5, 8};

    // 检查 v2 是否是 v1 的子集
    if (std::includes(v1.begin(), v1.end(), v2.begin(), v2.end())) {
        std::cout << "v1 includes v2" << std::endl;
    } else {
        std::cout << "v1 does not include v2" << std::endl;
    }

    // 检查 v3 是否是 v1 的子集
    if (std::includes(v1.begin(), v1.end(), v3.begin(), v3.end())) {
        std::cout << "v1 includes v3" << std::endl;
    } else {
        std::cout << "v1 does not include v3" << std::endl;
    }

    return 0;
}
```

输出:

```
v1 includes v2
v1 does not include v3
```

在这个例子中, 因为`v2`的所有元素 (`3`, `5`, `7`) 都存在于`v1`中, 所以第一次调用`std::includes`返回`true`. 而`v3`中的元素`8`不在`v1`中, 因此第二次调用返回`false`.

## 比较 ⚖️

### `std::mismatch`

`std::mismatch`是C++ STL中的一个算法, 用于在两个序列中查找 第一对不匹配 的元素. 它会同时遍历两个序列, 逐一比较对应位置的元素, 直到找到第一个差异点或者其中一个序列遍历完毕. `std::mismatch`会返回一个`std::pair`, 其中包含两个迭代器, 分别指向两个序列中第一个不匹配的元素.

`std::mismatch`有两个主要重载版本.

1. 使用相等性比较 (`==`)

    ```cpp
    template<class InputIt1, class InputIt2>
    std::pair<InputIt1, InputIt2>
        mismatch(InputIt1 first1, InputIt1 last1, InputIt2 first2);
    ```

    * `first1`, `last1`: 定义了第一个序列的范围 `[first1, last1)`.
    * `first2`: 第二个序列的起始迭代器. `mismatch`假定第二个序列至少与第一个序列一样长.

2. 使用自定义谓词比较

    ```cpp
    template<class InputIt1, class InputIt2, class BinaryPredicate>
    std::pair<InputIt1, InputIt2>
        mismatch(InputIt1 first1, InputIt1 last1, InputIt2 first2, BinaryPredicate p);
    ```

    * `p`: 一个二元谓词 (返回布尔值的函数或函数对象), 用于比较两个序列中的元素. 如果`p(element1, element2)`返回`false`, 则认为元素不匹配.

`std::mismatch`返回一个`std::pair`, 包含两个迭代器:

* `pair.first`: 指向第一个序列中不匹配的元素的迭代器.
* `pair.second`: 指向第二个序列中对应位置不匹配的元素的迭代器.

如果两个序列在第一个序列的范围内完全匹配, `pair.first`将等于`last1`, `pair.second`将指向第二个序列中超出比较范围的下一个元素.

使用示例:

假设我们想比较两个序列, 找出它们从哪里开始不同.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <string>

int main() {
    std::vector<int> v1 = {1, 2, 3, 4, 5};
    std::vector<int> v2 = {1, 2, 9, 4, 5}; // 在索引2处不同

    auto p = std::mismatch(v1.begin(), v1.end(), v2.begin());

    if (p.first != v1.end()) {
        std::cout << "在索引 " << std::distance(v1.begin(), p.first) << " 处发现不匹配." << std::endl;
        std::cout << "序列1的值是: " << *p.first << std::endl;
        std::cout << "序列2的值是: " << *p.second << std::endl;
    } else {
        std::cout << "序列完全匹配." << std::endl;
    }

    return 0;
}
```

输出结果:

```
在索引 2 处发现不匹配.
序列1的值是: 3
序列2的值是: 9
```

示例2: 使用自定义谓词

我们可以用一个自定义比较规则, 例如, 比较字符串的长度.

```cpp
#include <iostream>
#include <vector>
#include <string>
#include <algorithm>

// 谓词: 比较两个字符串的长度是否相等
bool have_same_length(const std::string& s1, const std::string& s2) {
    return s1.length() == s2.length();
}

int main() {
    std::vector<std::string> words1 = {"hello", "world", "is", "great"};
    std::vector<std::string> words2 = {"greetings", "earth", "are", "awesome"};

    auto p = std::mismatch(words1.begin(), words1.end(), words2.begin(), have_same_length);

    if (p.first != words1.end()) {
        std::cout << "在索引 " << std::distance(words1.begin(), p.first) << " 处发现长度不匹配." << std::endl;
        std::cout << "序列1的词是 '" << *p.first << "' (长度 " << (*p.first).length() << ")" << std::endl;
        std::cout << "序列2的词是 '" << *p.second << "' (长度 " << (*p.second).length() << ")" << std::endl;
    } else {
        std::cout << "所有对应词的长度都匹配." << std::endl;
    }

    return 0;
}
```

输出结果:

```
在索引 0 处发现长度不匹配.
序列1的词是 'hello' (长度 5)
序列2的词是 'greetings' (长度 9)
```

### `std::equal`

`std::equal`是C++ STL中的一个算法, 用于比较两个序列是否相等. 它逐一比较两个序列中的对应元素, 如果所有对应元素都满足相等条件, 则返回`true`, 否则返回`false`. `std::equal`通过遍历两个序列并应用一个比较操作来工作. 如果在任何点上比较结果为`false`, 它会立即停止并返回`false`. 只有当第一个序列遍历完成且所有元素都与第二个序列的对应元素匹配时, 它才会返回`true`.

`std::equal`有两个主要的重载版本.

1. 使用相等性比较 (`==`)

    ```cpp
    template<class InputIt1, class InputIt2>
    bool equal(InputIt1 first1, InputIt1 last1, InputIt2 first2);
    ```

    * `first1`, `last1`: 定义了第一个序列的范围 `[first1, last1)`.
    * `first2`: 第二个序列的起始迭代器. `equal`假定第二个序列至少与第一个序列一样长. 它只会比较`last1 - first1`个元素.

2. 使用自定义谓词比较

    ```cpp
    template<class InputIt1, class InputIt2, class BinaryPredicate>
    bool equal(InputIt1 first1, InputIt1 last1, InputIt2 first2, BinaryPredicate p);
    ```

    * `p`: 一个二元谓词 (返回布尔值的函数或函数对象), 用于比较两个序列中的元素. 算法会检查对于每一对元素`p(element1, element2)`是否都返回`true`.

返回值

* 如果第一个序列中的所有元素都与第二个序列中的对应元素相等 (或满足谓词), 则返回`true`.
* 否则返回`false`.

示例1: 基本用法

检查两个整数向量是否相等.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

int main() {
    std::vector<int> v1 = {1, 2, 3, 4, 5};
    std::vector<int> v2 = {1, 2, 3, 4, 5};
    std::vector<int> v3 = {1, 2, 9, 4, 5}; // 与v1不同

    if (std::equal(v1.begin(), v1.end(), v2.begin())) {
        std::cout << "v1 和 v2 相等." << std::endl;
    } else {
        std::cout << "v1 和 v2 不相等." << std::endl;
    }

    if (std::equal(v1.begin(), v1.end(), v3.begin())) {
        std::cout << "v1 和 v3 相等." << std::endl;
    } else {
        std::cout << "v1 和 v3 不相等." << std::endl;
    }

    return 0;
}
```

输出结果:

```
v1 和 v2 相等.
v1 和 v3 不相等.
```

示例2: 使用自定义谓词

假设我们想进行不区分大小写的字符串比较.

```cpp
#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <cctype>

// 谓词: 不区分大小写比较两个字符
bool case_insensitive_char_equal(char c1, char c2) {
    return std::tolower(c1) == std::tolower(c2);
}

int main() {
    std::string s1 = "Hello";
    std::string s2 = "hello";

    if (std::equal(s1.begin(), s1.end(), s2.begin(), case_insensitive_char_equal)) {
        std::cout << "'" << s1 << "' 和 '" << s2 << "' 在不区分大小写的情况下相等." << std::endl;
    } else {
        std::cout << "'" << s1 << "' 和 '" << s2 << "' 在不区分大小写的情况下不相等." << std::endl;
    }

    return 0;
}
```

输出结果:

```
'Hello' 和 'hello' 在不区分大小写的情况下相等.
```

### `std::lexicographical_compare`

`std::lexicographical_compare`是C++ STL中的一个算法, 它以字典序(dictionary order)比较两个序列. 简单来说, 它就像在字典中比较两个单词一样, 确定一个序列是否在另一个序列之前.

该算法会逐一比较两个序列`[first1, last1)`和`[first2, last2)`中的对应元素.

1.  如果找到第一对不相等的元素 (例如在位置`i`), 它会比较`range1[i]`和`range2[i]`. 如果`range1[i] < range2[i]`, 则第一个序列在字典序上小于第二个, 算法返回`true`. 如果`range1[i] > range2[i]`, 则返回`false`.
2.  如果在比较完所有元素后, 其中一个序列先耗尽 (例如, 序列1是序列2的前缀, 如 "cat" 和 "cattle"), 那么较短的序列 (序列1) 被认为在字典序上更小, 算法返回`true`.
3.  如果两个序列完全相等且长度相同, 则第一个序列并不小于第二个, 算法返回`false`.

`std::lexicographical_compare`有两个主要重载版本.

1. 使用 `<` 运算符比较

    ```cpp
    template<class InputIt1, class InputIt2>
    bool lexicographical_compare(InputIt1 first1, InputIt1 last1,
                                InputIt2 first2, InputIt2 last2);
    ```

    * `first1`, `last1`: 定义了第一个序列的范围 `[first1, last1)`.
    * `first2`, `last2`: 定义了第二个序列的范围 `[first2, last2)`.

    此版本使用默认的 `<` 运算符来比较元素.

2. 使用自定义比较函数

    ```cpp
    template<class InputIt1, class InputIt2, class Compare>
    bool lexicographical_compare(InputIt1 first1, InputIt1 last1,
                                InputIt2 first2, InputIt2 last2,
                                Compare comp);
    ```

    * `comp`: 一个二元谓词 (返回布尔值的函数或函数对象), 用于代替 `<` 进行比较. 如果`comp(a, b)`返回`true`, 则认为`a`小于`b`.

返回值

* 如果第一个序列在字典序上 小于 第二个序列, 则返回`true`.
* 否则返回`false`.

示例1: 基本用法 (比较字符串和向量)

```cpp
#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <iomanip> // For std::boolalpha

int main() {
    std::cout << std::boolalpha; // 将 bool 输出为 true/false

    // 示例 1: 比较字符串
    std::string s1 = "apple";
    std::string s2 = "apply";
    // 'e' < 'y', 所以 s1 < s2
    std::cout << "Is '" << s1 << "' lexicographically less than '" << s2 << "'? "
              << std::lexicographical_compare(s1.begin(), s1.end(), s2.begin(), s2.end()) << std::endl;

    // 示例 2: 比较向量 (前缀情况)
    std::vector<int> v1 = {1, 2, 3};
    std::vector<int> v2 = {1, 2, 3, 4};
    // v1 是 v2 的前缀, 所以 v1 < v2
    std::cout << "Is {1,2,3} less than {1,2,3,4}? "
              << std::lexicographical_compare(v1.begin(), v1.end(), v2.begin(), v2.end()) << std::endl;

    // 示例 3: 比较向量 (完全相同)
    std::vector<int> v3 = {1, 2, 3};
    // v1 和 v3 完全相同, 所以 v1 不小于 v3
    std::cout << "Is {1,2,3} less than {1,2,3}? "
              << std::lexicographical_compare(v1.begin(), v1.end(), v3.begin(), v3.end()) << std::endl;

    return 0;
}
```

输出结果:

```
Is 'apple' lexicographically less than 'apply'? true
Is {1,2,3} less than {1,2,3,4}? true
Is {1,2,3} less than {1,2,3}? false
```

示例2: 使用自定义谓词 (降序比较)

如果我们想知道一个序列按降序排列是否 "小于" 另一个, 我们可以提供一个 "大于" 谓词.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <functional> // For std::greater
#include <iomanip>

int main() {
    std::cout << std::boolalpha;

    std::vector<int> v1 = {1, 5, 2};
    std::vector<int> v2 = {1, 4, 9};

    // 使用默认的 '<' 比较: v1 不小于 v2, 因为 5 > 4
    bool default_comp = std::lexicographical_compare(v1.begin(), v1.end(), v2.begin(), v2.end());
    std::cout << "Default compare (<): " << default_comp << std::endl;

    // 使用 std::greater<int>() 作为比较函数
    // 比较逻辑变为: 1==1, 5>4. 因为 comp(5, 4) 是 true, 所以 v1 "小于" v2
    bool custom_comp = std::lexicographical_compare(v1.begin(), v1.end(),
                                                    v2.begin(), v2.end(),
                                                    std::greater<int>());
    std::cout << "Custom compare (>): " << custom_comp << std::endl;

    return 0;
}
```

输出结果:

```
Default compare (<): false
Custom compare (>): true
```

## 统计 📊

### `std::all_of`, `std::any_of`, `std::none_of`

这三个算法都属于C++ STL中的非修改性序列算法, 它们都用于检查序列中的元素是否满足某个特定的条件 (通过谓词函数定义). 它们像是在对序列进行提问, 并返回一个布尔值 (`true`或`false`) 作为答案. 这三个函数的核心是 谓词. 谓词是一个可调用的表达式 (通常是函数指针, 函数对象或lambda表达式), 它接受一个序列中的元素作为参数, 并返回一个可以转换为`bool`的值.

例如, 一个检查整数是否为偶数的谓词:

```cpp
bool is_even(int n) {
    return n % 2 == 0;
}
```

---

`std::all_of`:

`all_of` (所有都满足?) 算法检查序列中 所有 元素是否都满足谓词指定的条件.

* 工作原理: 它会遍历序列, 将谓词应用于每个元素. 如果遇到任何一个元素使谓词返回`false`, 它会立即停止并返回`false`. 只有当所有元素都使谓词返回`true`时, 它才会返回`true`.
* 对于空序列: 对一个空序列调用`all_of`会返回`true`.

函数原型

```cpp
template<class InputIt, class UnaryPredicate>
bool all_of(InputIt first, InputIt last, UnaryPredicate p);
```

-----

`std::any_of`:

`any_of` (任何一个满足?) 算法检查序列中是否 至少有一个 元素满足谓词指定的条件.

* 工作原理: 它会遍历序列, 将谓词应用于每个元素. 如果遇到任何一个元素使谓词返回`true`, 它会立即停止并返回`true`. 只有当所有元素都使谓词返回`false`时, 它才会返回`false`.
* 对于空序列: 对一个空序列调用`any_of`会返回`false`.

函数原型

```cpp
template<class InputIt, class UnaryPredicate>
bool any_of(InputIt first, InputIt last, UnaryPredicate p);
```

---

`std::none_of`

`none_of` (没有一个满足?) 算法检查序列中是否 没有任何 元素满足谓词指定的条件.

* 工作原理: 它会遍历序列, 将谓词应用于每个元素. 如果遇到任何一个元素使谓词返回`true`, 它会立即停止并返回`false`. 只有当所有元素都使谓词返回`false`时, 它才会返回`true`.
* 对于空序列: 对一个空序列调用`none_of`会返回`true`.
* 逻辑关系: `std::none_of(..., p)` 等价于 `!std::any_of(..., p)`.

函数原型

```cpp
template<class InputIt, class UnaryPredicate>
bool none_of(InputIt first, InputIt last, UnaryPredicate p);
```

---

使用示例:

下面的例子将使用同一个lambda表达式作为谓词来演示这三个函数的不同之处.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <iomanip> // For std::boolalpha

int main() {
    std::cout << std::boolalpha; // 将 bool 输出为 true/false

    std::vector<int> v = {2, 4, 6, 8, 10};
    auto is_odd = [](int i) { return i % 2 != 0; };

    std::cout << "序列 v: {2, 4, 6, 8, 10}" << std::endl;
    std::cout << "谓词: 是否为奇数?" << std::endl;
    std::cout << "--------------------------------" << std::endl;

    // 是否所有元素都是奇数?
    if (std::all_of(v.cbegin(), v.cend(), is_odd)) {
        std::cout << "all_of:  是的, 所有元素都是奇数." << std::endl;
    } else {
        std::cout << "all_of:  不, 不是所有元素都是奇数." << std::endl;
    }

    // 是否至少有一个元素是奇数?
    if (std::any_of(v.cbegin(), v.cend(), is_odd)) {
        std::cout << "any_of:  是的, 至少有一个元素是奇数." << std::endl;
    } else {
        std::cout << "any_of:  不, 没有任何元素是奇数." << std::endl;
    }

    // 是否没有任何元素是奇数?
    if (std::none_of(v.cbegin(), v.cend(), is_odd)) {
        std::cout << "none_of: 是的, 没有任何元素是奇数." << std::endl;
    } else {
        std::cout << "none_of: 不, 至少有一个元素是奇数." << std::endl;
    }

    return 0;
}
```

输出结果:

```
序列 v: {2, 4, 6, 8, 10}
谓词: 是否为奇数?
--------------------------------
all_of:  不, 不是所有元素都是奇数.
any_of:  不, 没有任何元素是奇数.
none_of: 是的, 没有任何元素是奇数.
```

-----

| 算法 | 问题 | 返回 `true` 的条件 |
| :--- | :--- | :--- |
| `all_of` | 所有元素都满足条件吗? | 序列中的 每个 元素都让谓词返回`true`. |
| `any_of` | 存在满足条件的元素吗? | 序列中 至少有一个 元素让谓词返回`true`. |
| `none_of` | 所有元素都不满足条件吗? | 序列中的 每个 元素都让谓词返回`false`. |

### `std::count`, `std::count_if`

这两个算法都用于统计序列中符合特定条件的元素数量. 它们遍历指定的范围并返回一个整数, 表示满足条件的元素个数.

---

`std::count`用于统计序列中等于 特定值 的元素数量.

* 工作原理: 算法遍历`[first, last)`范围内的每个元素, 并将其与给定的`value`使用`operator==`进行比较. 每当比较结果为`true`时, 内部计数器加一.
* 用途: 当你需要计算一个简单值 (如`int`, `char`, `std::string`) 在容器中出现了多少次时, 这个函数非常方便.

函数原型

```cpp
template<class InputIt, class T>
typename iterator_traits<InputIt>::difference_type
    count(InputIt first, InputIt last, const T& value);
```

* `first`, `last`: 定义了搜索范围的输入迭代器 `[first, last)`.
* `value`: 要在序列中搜索和计数的特定值.
* 返回值: 等于`value`的元素数量, 类型通常是`std::size_t`.

示例

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

int main() {
    std::vector<int> v = {1, 2, 3, 4, 2, 5, 2, 6};
    int target = 2;

    auto num_items = std::count(v.begin(), v.end(), target);

    std::cout << "在序列中, 数字 " << target << " 出现了 " << num_items << " 次." << std::endl;
    return 0;
}
```

输出结果:

```
在序列中, 数字 2 出现了 3 次.
```

---

`std::count_if`用于统计序列中满足 特定条件 的元素数量. 这个 "条件" 由一个谓词函数定义.

* 工作原理: 算法遍历`[first, last)`范围内的每个元素, 并将每个元素传递给谓词`p`. 如果`p(element)`返回`true`, 内部计数器加一.
* 用途: 当你需要根据更复杂的逻辑 (例如, 大于某个值, 是偶数, 字符串长度符合要求等) 来计数时, 这个函数非常强大和灵活.

函数原型

```cpp
template<class InputIt, class UnaryPredicate>
typename iterator_traits<InputIt>::difference_type
    count_if(InputIt first, InputIt last, UnaryPredicate p);
```

* `first`, `last`: 定义了搜索范围的输入迭代器 `[first, last)`.
* `p`: 一元谓词, 用于判断元素是否应被计数.
* 返回值: 使谓词`p`返回`true`的元素数量.

示例

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <string>

int main() {
    std::vector<int> nums = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};

    // 使用 lambda 表达式作为谓词, 统计偶数的数量
    auto num_even = std::count_if(nums.begin(), nums.end(), [](int i){
        return i % 2 == 0;
    });

    std::cout << "序列中有 " << num_even << " 个偶数." << std::endl;

    std::vector<std::string> words = {"apple", "banana", "kiwi", "grapefruit", "cherry"};

    // 统计长度大于5的单词数量
    auto long_words = std::count_if(words.begin(), words.end(), [](const std::string& s){
        return s.length() > 5;
    });

    std::cout << "序列中有 " << long_words << " 个长度大于5的单词." << std::endl;
    return 0;
}
```

输出结果:

```
序列中有 5 个偶数.
序列中有 3 个长度大于5的单词.
```

---

| 算法 | 用途 | 比较方式 |
| :--- | :--- | :--- |
| `std::count` | 统计 特定值 的出现次数 | 使用 `operator==` 与一个固定值比较 |
| `std::count_if` | 统计满足 特定条件 的元素个数 | 将元素传递给一个返回布尔值的谓词函数 |

## 复制 🔁

下列三个算法都用于将元素从一个序列复制到另一个序列, 但它们在"如何决定复制哪些或多少元素"上有所不同. 在使用这些函数时, 必须确保 目标容器有足够的空间 来接收被复制的元素, 否则会导致未定义行为. 通常使用`std::back_inserter`来动态扩展目标容器.

### `std::copy`

`std::copy`是最基础的复制算法, 它无条件地复制一个范围内的 所有 元素.

* 工作原理: 它会遍历`[first, last)`范围内的每一个元素, 并按顺序将它们复制到从`d_first`开始的目标位置.
* 用途: 用于完整地克隆一个序列或序列的一部分.

函数原型

```cpp
template<class InputIt, class OutputIt>
OutputIt copy(InputIt first, InputIt last, OutputIt d_first);
```

* `first`, `last`: 定义了 源序列 范围的输入迭代器 `[first, last)`.
* `d_first`: 目标序列 的起始输出迭代器.
* 返回值: 指向被复制到目标范围末尾的后一个位置的迭代器.

### `std::copy_if`

`std::copy_if`是一个条件复制算法, 它只复制那些满足 特定条件 的元素. 条件由一个谓词函数定义.

* 工作原理: 它遍历源序列中的每个元素, 并将元素传递给谓词`p`. 如果`p(element)`返回`true`, 该元素就会被复制到目标序列.
* 用途: 用于从一个序列中筛选元素并形成一个新的序列.

函数原型

```cpp
template<class InputIt, class OutputIt, class UnaryPredicate>
OutputIt copy_if(InputIt first, InputIt last, OutputIt d_first, UnaryPredicate p);
```

* `first`, `last`: 定义了 源序列 范围的输入迭代器.
* `d_first`: 目标序列 的起始输出迭代器.
* `p`: 一元谓词, 返回`true`的元素将被复制.
* 返回值: 指向被复制到目标范围末尾的后一个位置的迭代器.

### `std::copy_n`

`std::copy_n`用于从一个起始点开始, 复制 指定数量 (n个) 的元素.

* 工作原理: 它从`first`开始, 复制`count`个元素到从`d_first`开始的目标位置. 它不关心`first`后面的序列有多长, 只复制指定数量的元素.
* 用途: 当你需要精确控制复制元素的个数时使用, 而不是由序列的末尾或某个条件来决定.

函数原型

```cpp
template<class InputIt, class Size, class OutputIt>
OutputIt copy_n(InputIt first, Size count, OutputIt d_first);
```

* `first`: 源序列 的起始输入迭代器.
* `count`: 要复制的元素 数量.
* `d_first`: 目标序列 的起始输出迭代器.
* 返回值: 指向被复制到目标范围末尾的后一个位置的迭代器.

使用示例

下面的例子将演示这三个函数的用法和区别.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <iterator> // for std::back_inserter

// 辅助函数, 用于打印 vector
void print_vector(const std::string& title, const std::vector<int>& v) {
    std::cout << title;
    for (int i : v) {
        std::cout << i << " ";
    }
    std::cout << std::endl;
}

int main() {
    std::vector<int> source = {10, 25, 30, 45, 50, 65, 70};
    print_vector("源序列:       ", source);
    std::cout << "-------------------------------------------\n";

    // 1. std::copy: 复制所有元素
    std::vector<int> dest1;
    std::copy(source.begin(), source.end(), std::back_inserter(dest1));
    print_vector("std::copy 结果: ", dest1);

    // 2. std::copy_if: 只复制大于40的元素
    std::vector<int> dest2;
    std::copy_if(source.begin(), source.end(), std::back_inserter(dest2),
                 [](int x){ return x > 40; });
    print_vector("std::copy_if (>40) 结果: ", dest2);

    // 3. std::copy_n: 从头开始复制3个元素
    std::vector<int> dest3;
    std::copy_n(source.begin(), 3, std::back_inserter(dest3));
    print_vector("std::copy_n (3个) 结果: ", dest3);

    return 0;
}
```

输出结果:

```
源序列:       10 25 30 45 50 65 70
-------------------------------------------
std::copy 结果: 10 25 30 45 50 65 70
std::copy_if (>40) 结果: 45 50 65 70
std::copy_n (3个) 结果: 10 25 30
```

| 算法 | 决定复制的依据 | 复制的元素 |
| :--- | :--- | :--- |
| `std::copy` | 范围 (`[first, last)`) | 该范围内的所有元素 |
| `std::copy_if` | 范围 + 条件 | 范围中所有满足条件的元素 |
| `std::copy_n` | 起始点 + 数量 (`n`) | 从起始点开始的`n`个元素 |

## 填充 🧱

### `std::fill`, `std::fill_n`

`std::fill`和`std::fill_n`都是C++ `<algorithm>`库中的函数, 用于将一个区间内的元素替换为指定的值. `std::fill`将一个由起始迭代器和结束迭代器定义的区间`[first, last)`内的所有元素赋值为一个给定的`value`.

* 语法:

    ```cpp
    template< class ForwardIt, class T >
    void fill( ForwardIt first, ForwardIt last, const T& value );
    ```

* 参数:

    * `first`: 指向要修改的区间起始位置的迭代器.
    * `last`: 指向要修改的区间末尾位置之后一位的迭代器.
    * `value`: 要赋给区间内每个元素的值.

* 示例:

    ```cpp
    #include <iostream>
    #include <vector>
    #include <algorithm>

    int main() {
        std::vector<int> v = {0, 1, 2, 3, 4, 5};

        // 将整个vector填充为7
        std::fill(v.begin(), v.end(), 7); // v 现在是 {7, 7, 7, 7, 7, 7}

        for (int i : v) {
            std::cout << i << " ";
        }
        std::cout << std::endl;

        return 0;
    }
    ```

`std::fill_n`从一个起始迭代器开始, 将后续指定数量(`count`)的元素赋值为一个给定的`value`.

  * 语法:

    ```cpp
    template< class OutputIt, class Size, class T >
    OutputIt fill_n( OutputIt first, Size count, const T& value );
    ```

  * 参数:

      * `first`: 指向要修改的区间起始位置的迭代器.
      * `count`: 要修改的元素的数量.
      * `value`: 要赋给这些元素的值.

  * 返回值:

    返回一个指向最后被修改元素的下一位的迭代器 (即`first + count`).

  * 示例:

    ```cpp
    #include <iostream>
    #include <vector>
    #include <algorithm>

    int main() {
        std::vector<int> v = {0, 1, 2, 3, 4, 5};

        // 从v.begin()开始, 将3个元素填充为8
        std::fill_n(v.begin(), 3, 8); // v 现在是 {8, 8, 8, 3, 4, 5}

        for (int i : v) {
            std::cout << i << " ";
        }
        std::cout << std::endl;

        return 0;
    }
    ```

---

| 特性 | `std::fill` | `std::fill_n` |
| :--- | :--- | :--- |
| 定义范围 | 使用两个迭代器(`first`, `last`) | 使用一个起始迭代器和数量(`first`, `count`) |
| 适用场景 | 填充整个容器或一个已知的子区间 | 从某点开始填充固定数量的元素 |

  * 当你需要填充整个容器(例如`v.begin()`到`v.end()`)或者一个明确的子区间时, 使用`std::fill`.
  * 当你只知道起始位置和需要填充的元素个数时, `std::fill_n`更方便.

### `std::generate`, `std::generate_n`

`std::fill`使用一个固定的值填充序列, `std::generate`则使用一个函数调用的结果来填充序列, 这意味着每个元素可以被赋予不同的值. 好的, 这是对`std::generate`和`std::generate_n`算法的介绍. `std::generate`为一个已存在的 范围 `[first, last)`内的所有元素赋值.

* 工作原理: 它遍历由`first`和`last`迭代器定义的整个范围, 对范围内的每个位置, 调用生成器函数`g()`并将返回值赋给该位置的元素.
* 用途: 当你需要用某种规则 (如递增序列, 随机数, 常量等) 填充一个已经确定大小的容器或范围时使用. 你必须确保 `[first, last)` 是一个有效的范围.

函数原型:

```cpp
template<class ForwardIt, class Generator>
void generate(ForwardIt first, ForwardIt last, Generator g);
```

* `first`, `last`: 定义了要填充的目标范围 `[first, last)` 的前向迭代器.
* `g`: 生成器函数. 每次调用它时, 都应该返回一个可以赋给序列元素的值.
* 返回值: `void`.

`std::generate_n`从一个起始位置开始, 为 指定数量 (n个) 的元素赋值.

* 工作原理: 它从`first`迭代器指向的位置开始, 调用生成器函数`g()`共`count`次, 并将每次调用的结果依次赋给从`first`开始的连续`count`个元素.
* 用途: 当你想在容器的某个特定位置 (不一定是开头) 开始生成固定数量的元素时非常有用. 使用这个函数时, 必须确保从`first`开始有足够的空间来存放`count`个元素.

函数原型

```cpp
template<class OutputIt, class Size, class Generator>
OutputIt generate_n(OutputIt first, Size count, Generator g);
```

* `first`: 目标序列的起始输出迭代器.
* `count`: 要生成的元素数量.
* `g`: 生成器函数.
* 返回值: 指向最后一个被生成元素之后位置的迭代器.

-----

下面的例子将使用一个简单的递增数生成器来演示这两个函数的区别.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <string>

// 辅助函数, 用于打印 vector
void print_vector(const std::string& title, const std::vector<int>& v) {
    std::cout << title;
    for (int i : v) {
        std::cout << i << " ";
    }
    std::cout << std::endl;
}

// 一个简单的生成器类
class SequentialGenerator {
private:
    int current;
public:
    SequentialGenerator(int start = 0) : current(start) {}
    int operator()() {
        return current++;
    }
};

int main() {
    // 1. std::generate: 填充整个容器
    std::vector<int> v1(5); // 必须预先分配大小
    std::generate(v1.begin(), v1.end(), SequentialGenerator(10));
    print_vector("std::generate 结果:     ", v1);

    // 2. std::generate_n: 从头开始生成3个元素
    std::vector<int> v2(5, 0); // 容器大小为5, 初始值为0
    std::generate_n(v2.begin(), 3, SequentialGenerator(100));
    print_vector("std::generate_n 结果: ", v2);

    // 使用 lambda 表达式作为生成器
    int n = 0;
    std::generate(v1.begin(), v1.end(), [&n]{ return n++; });
    print_vector("Lambda generate 结果:    ", v1);

    return 0;
}
```

```
std::generate 结果:     10 11 12 13 14
std::generate_n 结果: 100 101 102 0 0
Lambda generate 结果:    0 1 2 3 4
```

---

| 算法 | 控制方式 | 用途 |
| :--- | :--- | :--- |
| `std::generate` | 由 范围 (`[first, last)`) 控制 | 填充一个完整的, 已确定大小的范围. |
| `std::generate_n` | 由 数量 (`count`) 控制 | 从一个起始点开始, 填充固定数量的元素. |

## 翻转 🔄

### `std::reverse`, `std::reverse_copy`

`std::reverse`是一个在原地反转序列中元素顺序的算法. 它直接修改原始容器中的元素.

函数原型:

```cpp
template<class BidirIt>
void reverse(BidirIt first, BidirIt last);
```

参数:

* `first`: 指向序列起始位置的双向迭代器.
* `last`: 指向序列结束位置之后一位的双向迭代器.

功能:

这个函数会反转`[first, last)`范围内的元素. `last`指向的元素不包含在内.

示例:

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

int main() {
    std::vector<int> v = {1, 2, 3, 4, 5};

    std::reverse(v.begin(), v.end());

    for (int i : v) {
        std::cout << i << " ";
    }
    // 输出: 5 4 3 2 1
    std::cout << std::endl;

    return 0;
}
```

`std::reverse_copy`创建一个序列的反转副本, 并将其存储到另一个序列中. 它不会修改原始序列.

```cpp
template<class BidirIt, class OutputIt>
OutputIt reverse_copy(BidirIt first, BidirIt last, OutputIt d_first);
```

参数:

* `first`: 指向源序列起始位置的双向迭代器.
* `last`: 指向源序列结束位置之后一位的双向迭代器.
* `d_first`: 指向目标序列起始位置的输出迭代器.

返回值:

返回一个指向目标序列中最后一个被写入元素之后一位的迭代器.

示例:

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

int main() {
    std::vector<int> source = {1, 2, 3, 4, 5};
    std::vector<int> destination(source.size()); // 确保目标容器有足够空间

    std::reverse_copy(source.begin(), source.end(), destination.begin());

    std::cout << "Source: ";
    for (int i : source) {
        std::cout << i << " ";
    }
    // 输出: Source: 1 2 3 4 5
    std::cout << std::endl;

    std::cout << "Destination: ";
    for (int i : destination) {
        std::cout << i << " ";
    }
    // 输出: Destination: 5 4 3 2 1
    std::cout << std::endl;

    return 0;
}
```

---

| 特性 | `std::reverse` | `std::reverse_copy` |
| --- | --- | --- |
| 操作对象 | 原地修改原始序列 | 创建一个反转后的副本到新序列 |
| 修改原始数据 | 是 | 否 |
| 所需容器 | 一个 | 两个 (源和目标) |
| 返回值 | `void` | 指向目标序列末尾的迭代器 |

## 移除 ❌

### erase-remove范式

STL中的"移除"算法并不会真正从容器中删除元素. 它们的工作方式是将所有未被移除的元素移动到序列的前端, 然后返回一个指向新的逻辑末尾位置的迭代器. 真正的删除操作需要结合容器自身的成员函数 (如erase) 来完成. 这种设计被称为erase-remove idiom.

### `std::remove`, `std::remove_if`

`std::remove`移除序列中所有等于特定值的元素.

函数原型:

```cpp
template<class ForwardIt, class T>
ForwardIt remove(ForwardIt first, ForwardIt last, const T& value);
```

参数:

* `first`, `last`: 定义操作范围`[first, last)`的迭代器.
* `value`: 需要被移除的值.

功能:

它会遍历`[first, last)`范围, 将所有不等于`value`的元素向前移动, 覆盖那些等于`value`的元素. 它返回一个迭代器, 指向这个新形成的、不包含`value`的序列的末尾. 原始容器的大小不变, 但末尾的元素处于一种未指定但有效的状态.

示例:

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

int main() {
    std::vector<int> v = {10, 20, 30, 30, 20, 10, 10, 20};

    // 移除所有值为20的元素
    auto new_end = std::remove(v.begin(), v.end(), 20);

    // v 现在可能是 {10, 30, 30, 10, 10, ?, ?, ?}
    // new_end 指向第五个元素之后的位置

    std::cout << "Vector after std::remove: ";
    for (auto it = v.begin(); it != new_end; ++it) {
        std::cout << *it << " "; // 输出: 10 30 30 10 10
    }
    std::cout << std::endl;

    // 使用erase-remove idiom真正删除元素
    v.erase(new_end, v.end());

    std::cout << "Vector after erase: ";
    for (int i : v) {
        std::cout << i << " "; // 输出: 10 30 30 10 10
    }
    std::cout << std::endl;

    return 0;
}
```

---

`std::remove_if`移除序列中所有满足特定条件的元素.

函数原型:

```cpp
template<class ForwardIt, class UnaryPredicate>
ForwardIt remove_if(ForwardIt first, ForwardIt last, UnaryPredicate p);
```

参数:

* `first`, `last`: 定义操作范围`[first, last)`的迭代器.
* `p`: 一个一元谓词 (返回`bool`的函数或函数对象), 如果元素应被移除, 则返回`true`.

功能:

它将所有不满足谓词`p` (即`p(element)`返回`false`) 的元素向前移动. 返回值和行为与`std::remove`类似.

示例:

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

// 谓词: 如果数字是奇数, 返回true
bool is_odd(int i) {
    return (i % 2) != 0;
}

int main() {
    std::vector<int> v = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};

    // 移除所有奇数
    auto new_end = std::remove_if(v.begin(), v.end(), is_odd);
    // 或者使用lambda表达式:
    // auto new_end = std::remove_if(v.begin(), v.end(), [](int i){ return (i % 2) != 0; });

    v.erase(new_end, v.end());

    std::cout << "Vector after removing odd numbers: ";
    for (int i : v) {
        std::cout << i << " "; // 输出: 2 4 6 8 10
    }
    std::cout << std::endl;

    return 0;
}
```

### `std::remove_copy`, `std::remove_copy_if`

这两个算法与`std::remove`和`std::remove_if`类似, 但它们不会修改原始序列. 相反, 它们将未被移除的元素复制到一个新的目标序列中.

* `std::remove_copy`: 复制所有不等于给定值的元素.
* `std::remove_copy_if`: 复制所有不满足给定谓词的元素.

函数原型:

```cpp
template<class InputIt, class OutputIt, class T>
OutputIt remove_copy(InputIt first, InputIt last, OutputIt d_first, const T& value);

template<class InputIt, class OutputIt, class UnaryPredicate>
OutputIt remove_copy_if(InputIt first, InputIt last, OutputIt d_first, UnaryPredicate p);
```

示例:

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <iterator> // for std::back_inserter

int main() {
    std::vector<int> source = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    std::vector<int> destination;

    // 复制所有不为奇数的元素 (即偶数) 到 destination
    std::remove_copy_if(source.begin(), source.end(),
                        std::back_inserter(destination), // 使用back_inserter可以自动扩展容器
                        [](int i){ return (i % 2) != 0; });

    std::cout << "Source (unchanged): ";
    for (int i : source) {
        std::cout << i << " "; // 输出: 1 2 3 4 5 6 7 8 9 10
    }
    std::cout << std::endl;

    std::cout << "Destination: ";
    for (int i : destination) {
        std::cout << i << " "; // 输出: 2 4 6 8 10
    }
    std::cout << std::endl;

    return 0;
}
```

### 总结

| 算法 | 功能 | 修改原始容器 |
| :--- | :--- | :--- |
| `std::remove` | 移除特定值 | 是 (逻辑上) |
| `std::remove_if` | 移除满足特定条件的元素 | 是 (逻辑上) |
| `std::remove_copy` | 复制不等于特定值的元素 | 否 |
| `std::remove_copy_if` | 复制不满足特定条件的元素 | 否 |

关键点是`remove`和`remove_if`需要配合容器的`erase`方法来物理删除元素, 而`remove_copy`和`remove_copy_if`则是在保留原始数据的基础上创建新的序列.

## 采样 🎲

### `std::sample`

`std::sample`是C++17引入的一个算法, 用于从一个序列中随机选择指定数量的元素, 并将它们复制到另一个序列中, 保持它们在原序列中的相对顺序. 这个算法在需要进行随机抽样或从大数据集中选取代表性样本时非常有用.

功能:

从输入范围`[first, last)`中, 无需替换地随机选择`n`个元素, 并将它们写入到输出迭代器`out`中. 如果输入范围的元素数量小于`n`, 则会选择所有元素. 被选择的每个元素都有相同的概率. 算法会保留被选元素的相对顺序.

函数原型:

```cpp
template<class PopulationIt, class SampleIt, class Distance, class URBG>
SampleIt sample(PopulationIt first, PopulationIt last,
                SampleIt out, Distance n, URBG&& g);
```

参数:

* `first`, `last`: 定义输入序列范围`[first, last)`的迭代器.
* `out`: 输出迭代器, 指向目标序列的起始位置, 用来存放抽样结果.
* `n`: 一个整数, 表示要抽样的元素数量.
* `g`: 一个均匀随机位生成器 (Uniform Random Bit Generator), 例如`std::mt19937`. 这是随机性的来源.

返回值:

一个输出迭代器, 指向被复制到目标序列的最后一个元素的下一个位置.

示例:

下面的例子展示了如何从一个`std::vector`中随机抽取5个元素.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <random>       // For std::mt19937 and std::random_device
#include <iterator>     // For std::back_inserter

int main() {
    // 源数据
    std::vector<int> population = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12};

    // 目标容器, 用于存放样本
    std::vector<int> sample_set;
    const int sample_size = 5;

    // 1. 创建随机数设备以获取种子
    std::random_device rd;

    // 2. 使用种子初始化Mersenne Twister引擎
    std::mt19937 gen(rd());

    // 3. 调用std::sample进行抽样
    std::sample(population.begin(),
                population.end(),
                std::back_inserter(sample_set),
                sample_size,
                gen);

    std::cout << "Population: ";
    for (int i : population) {
        std::cout << i << " ";
    }
    std::cout << std::endl;

    std::cout << "Sample of " << sample_size << " elements: ";
    for (int i : sample_set) {
        std::cout << i << " ";
    }
    std::cout << std::endl;

    return 0;
}
```

可能的输出:

每次运行的结果都可能不同, 因为它是随机的.

```
Population: 1 2 3 4 5 6 7 8 9 10 11 12
Sample of 5 elements: 2 5 6 9 11
```

或者

```
Population: 1 2 3 4 5 6 7 8 9 10 11 12
Sample of 5 elements: 1 4 7 8 12
```

## 旋转 🔄

### `std::rotate`

`std::rotate`是一个非常有用的算法, 它可以将一个范围内的元素进行循环左移, 使得范围中的某个特定元素成为新的起始元素.

功能:

`std::rotate` 接受一个由`[first, last)`定义的范围和一个指向该范围内某个元素`n_first`的迭代器. 它的作用是将`[first, n_first)`范围内的元素移动到序列的末尾, 而将`[n_first, last)`范围内的元素移动到序列的开头. 可以把它想象成将一个数组的元素向左"旋转", 直到`n_first`指向的元素成为第一个元素.

函数原型:

```cpp
template<class ForwardIt>
ForwardIt rotate(ForwardIt first, ForwardIt n_first, ForwardIt last);
```

参数:

* `first`: 指向要旋转范围起始位置的迭代器.
* `n_first`: 指向将成为序列新起始元素的那个元素. 这个迭代器必须在 `[first, last)` 范围内.
* `last`: 指向要旋转范围末尾之后一位的迭代器.

返回值:

返回一个迭代器, 指向原始的`first`元素在旋转后的新位置.

示例:

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

void print_vector(const std::string& message, const std::vector<int>& v) {
    std::cout << message;
    for (int i : v) {
        std::cout << i << " ";
    }
    std::cout << std::endl;
}

int main() {
    std::vector<int> v = {10, 20, 30, 40, 50, 60};
    print_vector("Original:   ", v);

    // 目标: 将元素 30 旋转到序列的开头.
    // first   = v.begin()      (指向 10)
    // n_first = v.begin() + 2  (指向 30)
    // last    = v.end()

    auto new_first_pos = std::rotate(v.begin(), v.begin() + 2, v.end());

    print_vector("Rotated:    ", v);
    // 输出: Rotated:    30 40 50 60 10 20

    // 返回值 new_first_pos 指向了元素 10 在新序列中的位置
    std::cout << "Element that was originally first (10) is now at position: "
              << std::distance(v.begin(), new_first_pos) << std::endl;
    std::cout << "Its value is: " << *new_first_pos << std::endl;
    // 输出:
    // Element that was originally first (10) is now at position: 4
    // Its value is: 10

    return 0;
}
```

## 打乱 🎲

### `std::shuffle`

`std::shuffle`是C++11引入的一个算法, 用于按均匀分布随机重排 (或称"洗牌") 指定范围内的元素. 它取代了旧的、有缺陷的`std::random_shuffle`.

功能:

`std::shuffle`接收一个范围`[first, last)`和一个随机数生成器, 然后利用这个生成器在指定的范围内对元素进行重新排序, 使得每个可能的排列组合都有相等的出现概率.

函数原型:

```cpp
template<class RandomIt, class URBG>
void shuffle(RandomIt first, RandomIt last, URBG&& g);
```

参数:

* `first`: 指向要重排范围起始位置的随机访问迭代器.
* `last`: 指向要重排范围末尾之后一位的随机访问迭代器.
* `g`: 一个均匀随机位生成器 (Uniform Random Bit Generator), 例如`std::mt19937`. 这是随机性的来源, 算法将调用它来决定如何交换元素.

返回值:

该函数没有返回值 (`void`). 它直接在原地修改容器中的元素顺序.

下面的例子展示了如何洗牌一个`std::vector`中的数字.

```cpp
#include <iostream>
#include <vector>
#include <algorithm> // for std::shuffle
#include <random>    // for std::random_device and std::mt19937

void print_vector(const std::vector<int>& v) {
    for (int i : v) {
        std::cout << i << " ";
    }
    std::cout << std::endl;
}

int main() {
    std::vector<int> v = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};

    std::cout << "Original vector: ";
    print_vector(v);

    // 1. 创建随机数设备以获取一个高质量的种子
    std::random_device rd;

    // 2. 使用种子初始化一个Mersenne Twister引擎
    //    这是推荐的随机数生成器
    std::mt19937 gen(rd());

    // 3. 使用引擎来打乱vector
    std::shuffle(v.begin(), v.end(), gen);

    std::cout << "Shuffled vector: ";
    print_vector(v);

    // 再次打乱
    std::shuffle(v.begin(), v.end(), gen);
    std::cout << "Shuffled again:  ";
    print_vector(v);

    return 0;
}
```

可能的输出:

每次运行的结果都可能不同.

```
Original vector: 1 2 3 4 5 6 7 8 9 10
Shuffled vector: 3 10 4 1 8 5 2 6 7 9
Shuffled again:  6 1 9 4 7 2 5 3 10 8
```

## 去重 🔍

### `std::unique`, `std::unique_copy`

`std::unique`是一个C++标准库算法, 用于就地移除范围内的连续重复元素. 它通过将不重复的元素移动到范围的起始位置来实现这一点.

关键点:

* 修改原始容器: `std::unique`会直接修改传入的迭代器范围内的元素顺序.
* 不删除元素: 该函数实际上并不从容器中删除任何元素. 它只是返回一个指向新的逻辑末尾的迭代器. 通常需要配合容器的`erase`成员函数来真正删除多余的元素, 类似于之前讲到的"erase-remove idiom".
* 要求有序: 为了移除所有重复项, 而不仅仅是连续的重复项, 容器内的元素必须预先排序.

工作原理:

`std::unique`遍历指定的范围, 当找到一个不等于前一个元素的元素时, 就将其复制到当前不重复序列的末尾.

返回值:

返回一个迭代器, 指向这个新的, 不包含连续重复元素的逻辑序列的末尾.

示例:

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

int main() {
    std::vector<int> v = {1, 2, 2, 3, 3, 3, 4, 1, 1};

    // 为了移除所有重复项, 先排序
    std::sort(v.begin(), v.end()); // v 现在是 {1, 1, 1, 2, 2, 3, 3, 3, 4}

    auto last = std::unique(v.begin(), v.end());
    // v 现在是 {1, 2, 3, 4, ?, ?, ?, ?, ?}, last 指向元素 4 后面的位置
    // ? 代表未指定值的有效int

    // 擦除多余的元素
    v.erase(last, v.end());

    for (int i : v) {
        std::cout << i << " "; // 输出: 1 2 3 4
    }
    std::cout << std::endl;

    return 0;
}
```

---

`std::unique_copy`与`std::unique`功能类似, 但它不会修改原始范围. 相反, 它将原始范围中不连续重复的元素复制到一个新的目标范围中.

关键点:

  * 不修改原始容器: 原始数据保持不变.
  * 复制到新容器: 结果被存储在另一个容器中.
  * 要求有序: 与`std::unique`一样, 为了移除所有重复项, 输入范围应预先排序.

工作原理:

`std::unique_copy`遍历输入范围, 并将每个不与前一个复制的元素相等的元素复制到目标范围.

返回值:

返回一个指向复制的目标范围末尾的迭代器.

示例:

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <iterator>

int main() {
    std::vector<int> src = {1, 2, 2, 3, 3, 3, 4, 1, 1};
    std::vector<int> dest;

    // 为了移除所有重复项, 先排序
    std::sort(src.begin(), src.end()); // src 仍然是 {1, 1, 1, 2, 2, 3, 3, 3, 4}

    // 使用 std::back_inserter 将结果插入到 dest 中
    std::unique_copy(src.begin(), src.end(), std::back_inserter(dest));

    // src 保持不变
    std::cout << "Source vector: ";
    for (int i : src) {
        std::cout << i << " "; // 输出: 1 1 1 2 2 3 3 3 4
    }
    std::cout << std::endl;

    std::cout << "Destination vector: ";
    for (int i : dest) {
        std::cout << i << " "; // 输出: 1 2 3 4
    }
    std::cout << std::endl;

    return 0;
}
```

| 特性 | `std::unique` | `std::unique_copy` |
| --- | --- | --- |
| 操作对象 | 修改原始容器 | 复制到新容器 |
| 数据修改 | 是 | 否 (仅写入目标容器) |
| 返回值 | 指向原始容器中逻辑末尾的迭代器 | 指向目标容器末尾的迭代器 |
| 主要用途 | 在原容器中高效移除重复元素 | 从一个容器中提取唯一元素到另一个容器 |

## 映射 🔄

### `std::transform`

`std::transform`是一个C++标准库算法, 它可以对一个或两个范围内的元素应用一个指定的函数, 并将结果存储到另一个范围中. 它非常适合用于逐元素地处理容器数据.

`std::transform`有两种主要形式:

1. 一元操作

    这种形式接受一个输入范围 (`[first1, last1)`) 和一个一元函数. 它会遍历输入范围, 对每个元素调用该函数, 并将返回值写入到指定的输出范围中.

    语法:

    ```cpp
    template <class InputIt, class OutputIt, class UnaryOperation>
    OutputIt transform(InputIt first1, InputIt last1, OutputIt d_first, UnaryOperation unary_op);
    ```

    * `first1`, `last1`: 定义输入范围的迭代器.
    * `d_first`: 定义目标范围起始位置的迭代器. 目标范围必须足够大以容纳所有结果.
    * `unary_op`: 一个接受单个参数的一元函数或函数对象, 参数类型应与输入范围的元素类型兼容.

    示例: 将`vector`中每个整数乘以2.

    ```cpp
    #include <iostream>
    #include <vector>
    #include <algorithm>
    #include <iterator>

    int main() {
        std::vector<int> v1 = {1, 2, 3, 4, 5};
        std::vector<int> v2;

        // 将 v1 中的每个元素乘以 2, 结果存入 v2
        std::transform(v1.begin(), v1.end(), std::back_inserter(v2), [](int n) {
            return n * 2;
        });

        for (int i : v2) {
            std::cout << i << " "; // 输出: 2 4 6 8 10
        }
        std::cout << std::endl;

        return 0;
    }
    ```

2. 二元操作

    这种形式接受两个输入范围 (`[first1, last1)`和`[first2, ...)`) 以及一个二元函数. 它会并行遍历这两个范围, 将每对对应元素作为参数传递给该函数, 并将结果写入目标范围. 第二个输入范围至少需要和第一个范围一样长.

    语法:

    ```cpp
    template <class InputIt1, class InputIt2, class OutputIt, class BinaryOperation>
    OutputIt transform(InputIt1 first1, InputIt1 last1, InputIt2 first2, OutputIt d_first, BinaryOperation binary_op);
    ```

    * `first1`, `last1`: 定义第一个输入范围的迭代器.
    * `first2`: 定义第二个输入范围起始位置的迭代器.
    * `d_first`: 定义目标范围起始位置的迭代器.
    * `binary_op`: 一个接受两个参数的二元函数或函数对象, 参数类型应与两个输入范围的元素类型兼容.

    示例: 将两个`vector`的对应元素相加.

    ```cpp
    #include <iostream>
    #include <vector>
    #include <algorithm>
    #include <iterator>

    int main() {
        std::vector<int> v1 = {1, 2, 3, 4, 5};
        std::vector<int> v2 = {10, 20, 30, 40, 50};
        std::vector<int> result;

        // 将 v1 和 v2 的对应元素相加, 结果存入 result
        std::transform(v1.begin(), v1.end(), v2.begin(), std::back_inserter(result),
                    [](int a, int b) {
                        return a + b;
                    });

        for (int i : result) {
            std::cout << i << " "; // 输出: 11 22 33 44 55
        }
        std::cout << std::endl;

        return 0;
    }
    ```

关键点:

* 原地操作: `std::transform`允许输入范围和输出范围重叠. 你可以将结果写回原始容器中. 例如, `std::transform(v.begin(), v.end(), v.begin(), op);`.
* 灵活性: 接受的函数可以是普通函数指针, 函数对象 (functors) 或lambda表达式, 这使其非常灵活和强大.
* 效率: `std::transform`通常由编译器高度优化, 是执行逐元素操作的首选方式, 比手写循环更具表现力且不易出错.

## 重排 🔄

### `std::partition`, `std::stable_partition`

`std::partition`是C++标准库中的一个算法, 用于根据指定的条件 (一个谓词函数) 就地重排一个范围内的元素. 它会将所有满足条件的元素移动到范围的前部, 而所有不满足条件的元素移动到后部.

关键点:

* 原地重排: `std::partition`直接在原始容器上进行操作, 修改其元素的顺序.
* 不保证相对顺序: 函数执行后, 满足条件的元素之间以及不满足条件的元素之间的原始相对顺序不被保证会保留. 如果需要保留相对顺序, 应该使用`std::stable_partition`.
* 二分分区: 它将容器内的元素有效地划分为两个组.

工作原理:

`std::partition`接受一个范围 `[first, last)` 和一个一元谓词 `p`. 它会遍历范围内的每个元素, 并检查该元素是否满足谓词 `p`. 如果满足, 该元素就被认为是第一组的一部分; 否则, 它是第二组的一部分. 函数通过交换元素将所有第一组的元素放在所有第二组的元素之前.

语法和返回值:

```cpp
template <class BidirIt, class UnaryPredicate>
BidirIt partition(BidirIt first, BidirIt last, UnaryPredicate p);
```

* `first`, `last`: 定义要分区的范围的双向迭代器.
* `p`: 一个一元谓词 (返回`bool`的函数或函数对象). 如果元素应在第一部分, 则返回`true`.
* 返回值: 返回一个迭代器, 指向第二组 (不满足条件的元素) 的第一个元素. 这个迭代器被称为"分区点".

示例:

假设我们想将一个`vector`中的所有偶数移动到所有奇数之前.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

// 谓词函数: 判断一个数是否是偶数
bool is_even(int n) {
    return n % 2 == 0;
}

int main() {
    std::vector<int> v = {1, 2, 3, 4, 5, 6, 7, 8, 9};

    // 使用 std::partition 将偶数移动到前面
    auto partition_point = std::partition(v.begin(), v.end(), is_even);
    // v 可能变为: {8, 2, 6, 4, 5, 3, 7, 1, 9} (注意相对顺序不保证)
    // partition_point 指向第一个不满足条件的元素 (比如 5)

    std::cout << "Partitioned vector: ";
    for (int i : v) {
        std::cout << i << " ";
    }
    std::cout << std::endl;

    std::cout << "Elements that are even: ";
    for (auto it = v.begin(); it != partition_point; ++it) {
        std::cout << *it << " "; // 输出: 8 2 6 4
    }
    std::cout << std::endl;

    return 0;
}
```

* `std::partition`: 更快, 但不保留分区内部元素的相对顺序.
* `std::stable_partition`: 保证分区内部元素的原始相对顺序, 但通常比`std::partition`慢.

如果你只需要将元素按条件分成两组, 而不关心它们原来的顺序, `std::partition`是更高效的选择.

### `std::partition_copy`

`std::partition_copy`是一个C++标准库算法, 用于根据给定的谓词 (predicate) 将一个范围内的元素复制到两个不同的目标范围中. 满足谓词的元素被复制到第一个目标范围, 不满足的则被复制到第二个目标范围. 原始范围内的元素顺序保持不变.

函数原型:

```cpp
template< class InputIt, class OutputIt1, class OutputIt2, class UnaryPredicate >
std::pair<OutputIt1, OutputIt2> partition_copy( InputIt first, InputIt last,
                                               OutputIt1 d_first_true, OutputIt2 d_first_false,
                                               UnaryPredicate p );
```

参数:

* `first`, `last`: 定义要处理的源范围的输入迭代器.
* `d_first_true`: 指向第一个目标范围起始位置的输出迭代器, 用于存放满足谓词`p`的元素.
* `d_first_false`: 指向第二个目标范围起始位置的输出迭代器, 用于存放不满足谓词`p`的元素.
* `p`: 一元谓词, 如果元素应被放入第一个目标范围, 则返回`true`, 否则返回`false`.

返回值:

返回一个`std::pair`, 其中包含两个迭代器. 第一个迭代器指向第一个目标范围中最后一个被复制元素的下一个位置, 第二个迭代器指向第二个目标范围中最后一个被复制元素的下一个位置.

示例:

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <iterator>

int main() {
    std::vector<int> source = {1, 2, 3, 4, 5, 6, 7, 8, 9};
    std::vector<int> evens;
    std::vector<int> odds;

    // 使用lambda表达式作为谓词, 判断是否为偶数
    auto is_even = [](int i){ return i % 2 == 0; };

    // 将偶数复制到evens, 奇数复制到odds
    std::partition_copy(source.begin(), source.end(),
                        std::back_inserter(evens),
                        std::back_inserter(odds),
                        is_even);

    std::cout << "Even numbers: ";
    for (int n : evens) {
        std::cout << n << " ";
    }
    std::cout << std::endl;

    std::cout << "Odd numbers: ";
    for (int n : odds) {
        std::cout << n << " ";
    }
    std::cout << std::endl;

    return 0;
}
```

输出

```
Even numbers: 2 4 6 8
Odd numbers: 1 3 5 7 9
```

### `std::partition_point`

`std::partition_point`用于在一个已经分区的范围 (`[first, last)`) 中查找分区点. 分区点是指向第二个分区起始位置的迭代器, 即第一个不满足谓词的元素. 范围必须已经根据谓词`p`进行了分区, 意味着所有满足`p`的元素都在不满足`p`的元素之前.

函数原型:

```cpp
template< class ForwardIt, class UnaryPredicate >
ForwardIt partition_point( ForwardIt first, ForwardIt last, UnaryPredicate p );
```

参数:

* `first`, `last`: 定义已分区范围的正向迭代器.
* `p`: 一元谓词, 与用于分区的谓词相同.

返回值:

返回一个迭代器, 指向第二个分区的第一个元素. 如果所有元素都满足谓词, 则返回`last`.

示例:

`std::partition_point`通常与`std::partition`结合使用.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <iterator>

int main() {
    std::vector<int> v = {9, 2, 7, 4, 5, 6, 3, 8, 1};

    // 使用std::partition对向量进行分区
    auto is_even = [](int i){ return i % 2 == 0; };
    std::partition(v.begin(), v.end(), is_even);

    // 此时v可能为: {8, 2, 6, 4, 5, 7, 3, 9, 1} (分区后顺序不保证)
    std::cout << "Partitioned vector: ";
    for (int n : v) {
        std::cout << n << " ";
    }
    std::cout << std::endl;

    // 查找分区点
    auto pp = std::partition_point(v.begin(), v.end(), is_even);

    std::cout << "Elements before partition point (evens): ";
    std::copy(v.begin(), pp, std::ostream_iterator<int>(std::cout, " "));
    std::cout << std::endl;

    std::cout << "Elements after partition point (odds): ";
    std::copy(pp, v.end(), std::ostream_iterator<int>(std::cout, " "));
    std::cout << std::endl;

    // 输出分区点指向的元素值
    if (pp != v.end()) {
        std::cout << "Partition point is at element: " << *pp << std::endl;
    }

    return 0;
}
```

输出

```
Partitioned vector: 8 2 6 4 5 7 3 9 1
Elements before partition point (evens): 8 2 6 4
Elements after partition point (odds): 5 7 3 9 1
Partition point is at element: 5
```

## 排序 🔢

### `std::sort`, `std::stable_sort`

`std::sort`是一个高效但不稳定的排序算法. "不稳定"意味着如果序列中有两个或多个等价的元素 (根据排序标准), 它们在排序后的相对顺序不保证与排序前相同.

函数原型:

```cpp
// 1. 使用 operator<
template< class RandomIt >
void sort( RandomIt first, RandomIt last );

// 2. 使用自定义比较函数
template< class RandomIt, class Compare >
void sort( RandomIt first, RandomIt last, Compare comp );
```

关键特性:

* 性能: 通常比`std::stable_sort`更快. 在大多数实现中, 它采用内省排序 (Introsort), 这是一种混合排序算法, 结合了快速排序, 堆排序和插入排序的优点, 平均时间复杂度为$O(N \log N)$, 最坏情况下也是$O(N \log N)$.
* 稳定性: 不稳定. 等价元素的相对顺序可能会改变.
* 使用场景: 当你不需要保留等价元素的原始相对顺序, 并且追求最快的排序速度时, `std::sort`是首选.

---

`std::stable_sort`是一个稳定的排序算法. "稳定"意味着如果序列中有两个或多个等价的元素, 它们在排序后的相对顺序保证与排序前完全相同.

函数原型:

```cpp
// 1. 使用 operator<
template< class RandomIt >
void stable_sort( RandomIt first, RandomIt last );

// 2. 使用自定义比较函数
template< class RandomIt, class Compare >
void stable_sort( RandomIt first, RandomIt last, Compare comp );
```

关键特性:

* 性能: 时间复杂度通常是$O(N \log^2 N)$. 如果有足够的额外内存可用, 它可以执行归并排序 (Merge Sort), 此时时间复杂度为$O(N \log N)$. 总体而言, 它通常比`std::sort`慢, 并且可能需要额外的内存.
* 稳定性: 稳定. 保证保留等价元素的相对顺序.
* 使用场景: 当你需要保持等价元素的原始相对顺序时, `std::stable_sort`是必需的. 例如, 对一个已经按姓名排序的列表再按城市排序, 你希望相同城市的条目仍然保持按姓名排序.

示例比较:

假设我们有一个包含学生姓名和分数的结构体, 我们只想按分数对他们进行降序排序.

```cpp
#include <iostream>
#include <vector>
#include <string>
#include <algorithm>

struct Student {
    std::string name;
    int score;
};

// 比较函数, 按分数降序
bool compareByScore(const Student& a, const Student& b) {
    return a.score > b.score;
}

void printStudents(const std::string& title, const std::vector<Student>& students) {
    std::cout << title << std::endl;
    for (const auto& s : students) {
        std::cout << "  Name: " << s.name << ", Score: " << s.score << std::endl;
    }
}

int main() {
    std::vector<Student> students = {
        {"Alice", 90},
        {"Bob", 85},
        {"Charlie", 90}, // 与Alice分数相同
        {"David", 75},
        {"Eve", 85}      // 与Bob分数相同
    };

    std::vector<Student> studentsForSort = students;
    std::vector<Student> studentsForStableSort = students;

    printStudents("Original:", students);

    // 使用 std::sort
    std::sort(studentsForSort.begin(), studentsForSort.end(), compareByScore);
    printStudents("\nAfter std::sort (unstable):", studentsForSort);

    // 使用 std::stable_sort
    std::stable_sort(studentsForStableSort.begin(), studentsForStableSort.end(), compareByScore);
    printStudents("\nAfter std::stable_sort (stable):", studentsForStableSort);

    return 0;
}
```

可能的输出:

```
Original:
  Name: Alice, Score: 90
  Name: Bob, Score: 85
  Name: Charlie, Score: 90
  Name: David, Score: 75
  Name: Eve, Score: 85

After std::sort (unstable):
  Name: Charlie, Score: 90   // Charlie和Alice的顺序可能改变
  Name: Alice, Score: 90
  Name: Eve, Score: 85       // Eve和Bob的顺序可能改变
  Name: Bob, Score: 85
  Name: David, Score: 75

After std::stable_sort (stable):
  Name: Alice, Score: 90     // Alice和Charlie的顺序保持不变
  Name: Charlie, Score: 90
  Name: Bob, Score: 85       // Bob和Eve的顺序保持不变
  Name: Eve, Score: 85
  Name: David, Score: 75
```

在`std::sort`的输出中, 分数同为90的`Charlie`和`Alice`的相对顺序可能与原始顺序相反. `std::stable_sort`则保证`Alice`仍然在`Charlie`之前, 因为在原始列表中就是如此.

总结:

| 特性 | `std::sort` | `std::stable_sort` |
| --- | --- | --- |
| 稳定性 | 不稳定 | 稳定 |
| 性能 | 更快, $O(N \log N)$ | 可能更慢, $O(N \log^2 N)$ 或 $O(N \log N)$ |
| 内存使用 | 在位 (In-place) | 可能需要额外内存 |
| 选择依据 | 速度优先, 不关心等价元素顺序 | 必须保持等价元素的相对顺序 |

### `std::is_sorted`, `std::is_sorted_until`

`std::is_sorted`是一个简单的谓词函数, 用于检查给定范围 `[first, last)` 内的所有元素是否已经完全排序. 📝

函数原型:

```cpp
// 1. 使用 operator<
template<class ForwardIt>
bool is_sorted(ForwardIt first, ForwardIt last);

// 2. 使用自定义比较函数
template<class ForwardIt, class Compare>
bool is_sorted(ForwardIt first, ForwardIt last, Compare comp);
```

关键特性:

* 返回值: 返回一个布尔值 (`bool`).
    * 如果整个范围是升序的 (或根据`comp`是无序的), 返回 `true`.
    * 否则, 返回 `false`.
    * 空范围或只有一个元素的范围被认为是已排序的.
* 功能: 对整个范围进行 "是" 或 "否" 的判断.

示例:

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

int main() {
    std::vector<int> v1 = {1, 2, 3, 4, 5};
    std::vector<int> v2 = {1, 2, 5, 4, 3};
    std::vector<int> v3 = {5, 4, 3, 2, 1};

    // 检查v1是否升序排序
    std::cout << "v1 is sorted: " << std::boolalpha << std::is_sorted(v1.begin(), v1.end()) << std::endl;

    // 检查v2是否升序排序
    std::cout << "v2 is sorted: " << std::boolalpha << std::is_sorted(v2.begin(), v2.end()) << std::endl;

    // 检查v3是否降序排序 (使用自定义比较器)
    std::cout << "v3 is sorted in descending order: "
              << std::boolalpha << std::is_sorted(v3.begin(), v3.end(), std::greater<int>())
              << std::endl;

    return 0;
}
```

输出

```
v1 is sorted: true
v2 is sorted: false
v3 is sorted in descending order: true
```

---

`std::is_sorted_until`更为强大, 它不仅能判断序列是否排序, 还能定位到第一个破坏排序规则的元素. 🔍

函数原型:

```cpp
// 1. 使用 operator<
template<class ForwardIt>
ForwardIt is_sorted_until(ForwardIt first, ForwardIt last);

// 2. 使用自定义比较函数
template<class ForwardIt, class Compare>
ForwardIt is_sorted_until(ForwardIt first, ForwardIt last, Compare comp);
```

关键特性:

* 返回值: 返回一个迭代器.
    * 该迭代器指向范围 `[first, last)` 中第一个不满足排序顺序的元素.
    * 如果整个范围都是排序好的, 它会返回迭代器 `last`.
* 功能: 查找已排序子范围的末尾.

示例:

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

int main() {
    std::vector<int> v = {1, 2, 5, 4, 3, 6};

    // 查找第一个未排序的元素
    auto it = std::is_sorted_until(v.begin(), v.end());

    // 计算已排序部分的长度
    auto sorted_len = std::distance(v.begin(), it);
    std::cout << "The first " << sorted_len << " elements are sorted." << std::endl;

    // 如果it不是指向末尾, 说明序列未完全排序
    if (it != v.end()) {
        std::cout << "The first unsorted element is: " << *it << std::endl;
    } else {
        std::cout << "The entire vector is sorted." << std::endl;
    }

    // 对于一个完全排序的向量
    std::vector<int> sorted_v = {10, 20, 30};
    auto it2 = std::is_sorted_until(sorted_v.begin(), sorted_v.end());
    if (it2 == sorted_v.end()) {
        std::cout << "The vector {10, 20, 30} is fully sorted." << std::endl;
    }

    return 0;
}
```

输出:

```
The first 3 elements are sorted.
The first unsorted element is: 4
The vector {10, 20, 30} is fully sorted.
```

| 特性 | `std::is_sorted` | `std::is_sorted_until` |
| --- | --- | --- |
| 目的 | 检查整个范围是否已排序. | 查找从头开始的最长已排序子范围. |
| 返回值 | `bool` (是/否). | `iterator` (指向第一个乱序元素或 `last`). |
| 信息量 | 较低, 只告诉你整体情况. | 较高, 告诉你排序在哪里中断. |
| 使用场景 | 当你只需要一个快速的整体检查时. | 当你需要知道序列中已排序部分的边界时. |

### `std::nth_element`, `std::partial_sort`


`std::nth_element`是一个非常有用的算法, 它的核心功能是将第n个位置的元素放置在它在完全排序后应该在的位置. 🎯

函数原型:

```cpp
// 1. 使用 operator<
template<class RandomIt>
void nth_element(RandomIt first, RandomIt nth, RandomIt last);

// 2. 使用自定义比较函数
template<class RandomIt, class Compare>
void nth_element(RandomIt first, RandomIt nth, RandomIt last, Compare comp);
```

关键特性:

* 保证:
1.  位于`nth`位置的元素就是如果整个序列被完全排序后, 应该出现在该位置的那个元素.
2.  `[first, nth)`范围内的所有元素都小于或等于`nth`位置的元素.
3.  `[nth, last)`范围内的所有元素都大于或等于`nth`位置的元素.
* 不保证: `[first, nth)`和`[nth, last)`这两个子范围内部是无序的.
* 性能: 平均线性时间复杂度$O(N)$, 这使得它在查找中位数或百分位点等场景下非常高效.
* 使用场景: 快速查找第k大/小的元素, 例如查找中位数, 百分位数等, 而不关心其他元素的顺序.

示例: 查找中位数

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <functional>

void print_vector(const std::vector<int>& v) {
    for (int i : v) {
        std::cout << i << " ";
    }
    std::cout << std::endl;
}

int main() {
    std::vector<int> v = {5, 10, 2, 8, 3, 9, 4, 7, 6, 1};

    // 找到中位数
    // 对于10个元素, 中位数是第5个元素 (索引为4)
    auto median_it = v.begin() + v.size() / 2;
    std::nth_element(v.begin(), median_it, v.end());

    std::cout << "The median is: " << *median_it << std::endl;

    std::cout << "Vector after nth_element: ";
    print_vector(v);

    std::cout << "Elements before median are all less than or equal to it: ";
    for (auto it = v.begin(); it != median_it; ++it) {
        std::cout << *it << " ";
    }
    std::cout << std::endl;

    return 0;
}
```

输出

```
The median is: 6
Vector after nth_element: 3 1 2 4 5 6 9 7 8 10
Elements before median are all less than or equal to it: 3 1 2 4 5
```

可以看到, `6`被正确地放在了它的排序位置上. `6`左边的元素 (`3, 1, 2, 4, 5`) 都小于等于`6`, 但它们之间是无序的. `6`右边的元素也都大于等于`6`.

---

`std::partial_sort`用于对序列的一部分进行排序. 它会将序列中最小的N个元素 (或根据比较函数确定的前N个元素) 排序后放置在序列的开头. 🏆

函数原型:

```cpp
// 1. 使用 operator<
template<class RandomIt>
void partial_sort(RandomIt first, RandomIt middle, RandomIt last);

// 2. 使用自定义比较函数
template<class RandomIt, class Compare>
void partial_sort(RandomIt first, RandomIt middle, RandomIt last, Compare comp);
```

关键特性:

* 保证:
1.  `[first, middle)`范围内的元素是整个序列中最小的 `middle - first` 个元素.
2.  `[first, middle)`范围内部是完全排序的.
* 不保证: `[middle, last)`范围内的元素是无序的.
* 性能: 时间复杂度约为$O(N \log M)$, 其中$N$是`last - first`的距离, $M$是`middle - first`的距离.
* 使用场景: 需要获取前N个最小/最大的元素, 并且要求这N个元素是有序的. 例如, 查找排行榜的前10名.

示例: 查找最小的3个元素

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <functional>

int main() {
    std::vector<int> v = {5, 10, 2, 8, 3, 9, 4, 7, 6, 1};

    // 找到并排序最小的3个元素
    std::partial_sort(v.begin(), v.begin() + 3, v.end());

    std::cout << "The 3 smallest elements are: ";
    for (int i = 0; i < 3; ++i) {
        std::cout << v[i] << " ";
    }
    std::cout << std::endl;

    std::cout << "Vector after partial_sort: ";
    for (int i : v) {
        std::cout << i << " ";
    }
    std::cout << std::endl;

    return 0;
}
```

输出

```
The 3 smallest elements are: 1 2 3
Vector after partial_sort: 1 2 3 10 8 9 5 7 6 4
```

如输出所示, 前3个元素是整个向量中最小的三个 (`1, 2, 3`), 并且它们自身是排好序的. 向量的其余部分是无序的.

| 特性 | `std::nth_element` | `std::partial_sort` |
| --- | --- | --- |
| 主要目的 | 定位第n个元素. | 排序前M个元素. |
| 排序保证 | 仅`nth`位置的元素保证正确, 其余元素只保证在其两侧. | `[first, middle)`范围内的元素是全局最小的M个, 且已排序. |
| 复杂度 | 平均$O(N)$ | $O(N \log M)$ |
| 核心问题 | "找到第k大的数是多少?" | "找到最小的k个数是哪些, 并且排好序?" |

### `std::merge`, `std::inplace_merge`

`std::merge`将两个已排序的序列`[first1, last1)`和`[first2, last2)`合并到一个独立的目标范围`[d_first, d_last)`中.

函数原型:

```cpp
// 1. 使用 operator<
template<class InputIt1, class InputIt2, class OutputIt>
OutputIt merge(InputIt1 first1, InputIt1 last1,
               InputIt2 first2, InputIt2 last2,
               OutputIt d_first);

// 2. 使用自定义比较函数
template<class InputIt1, class InputIt2, class OutputIt, class Compare>
OutputIt merge(InputIt1 first1, InputIt1 last1,
               InputIt2 first2, InputIt2 last2,
               OutputIt d_first, Compare comp);
```

关键特性:

* 输入: 两个独立的已排序序列.
* 输出: 一个新的目标序列. 你必须提前为这个目标序列分配足够的空间.
* 内存: 需要额外的内存来存储合并后的结果.
* 源序列: 源序列在操作后保持不变.
* 返回值: 返回一个指向输出序列中最后一个被复制元素之后位置的迭代器.
* 稳定性: 合并是稳定的. 如果两个序列中存在等价元素, 来自第一个序列的元素会排在来自第二个序列的元素之前.

示例:

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <iterator>

int main() {
    std::vector<int> v1 = {1, 3, 5, 7};
    std::vector<int> v2 = {2, 4, 6, 8};
    std::vector<int> dest(v1.size() + v2.size()); // 必须预先分配空间

    std::merge(v1.begin(), v1.end(),
               v2.begin(), v2.end(),
               dest.begin());

    std::cout << "Merged vector: ";
    for (int n : dest) {
        std::cout << n << " ";
    }
    std::cout << std::endl;

    return 0;
}
```

输出:

```
Merged vector: 1 2 3 4 5 6 7 8
```

---

`std::inplace_merge`用于合并一个连续内存块中相邻的两个已排序序列. 它直接在原始序列上进行操作, 不需要额外的输出容器.

函数原型:

```cpp
// 1. 使用 operator<
template<class BidirIt>
void inplace_merge(BidirIt first, BidirIt middle, BidirIt last);

// 2. 使用自定义比较函数
template<class BidirIt, class Compare>
void inplace_merge(BidirIt first, BidirIt middle, BidirIt last, Compare comp);
```

关键特性:

* 输入: 一个序列`[first, last)`, 这个序列被`middle`迭代器分为两个相邻且已排序的子序列: `[first, middle)`和`[middle, last)`.
* 输出: 直接在原始序列`[first, last)`上完成合并.
* 内存: "原地" (in-place) 操作. 如果有足够的额外内存, 它会使用临时缓冲区以获得更好的性能 (接近线性时间). 如果内存不足, 它会执行一个真正的原地合并, 性能会降低 (最坏情况$O(N \log N)$).
* 返回值: `void`.
* 稳定性: 合并是稳定的.

示例:

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

int main() {
    std::vector<int> v = {1, 3, 5, 2, 4, 6};
    // v中包含两个相邻的已排序序列: {1, 3, 5} 和 {2, 4, 6}
    // middle指向第二个序列的开头
    auto middle_it = v.begin() + 3;

    std::inplace_merge(v.begin(), middle_it, v.end());

    std::cout << "Vector after inplace_merge: ";
    for (int n : v) {
        std::cout << n << " ";
    }
    std::cout << std::endl;

    return 0;
}
```

输出

```
Vector after inplace_merge: 1 2 3 4 5 6
```

| 特性 | `std::merge` | `std::inplace_merge` |
| :--- | :--- | :--- |
| 输入 | 两个任意位置的已排序序列. | 一个连续内存块中的两个相邻已排序序列. |
| 输出 | 需要一个独立的目标容器. | 在原始容器上直接修改. |
| 内存使用 | 需要额外的输出缓冲区. | 原地操作, 可能会临时分配内存以提高性能. |
| 主要用途 | 将不同容器或不相邻的数据合并. | 合并一个容器内相邻的两个已排序部分, 是归并排序算法的核心步骤. |

## 集合 🔗

### `std::set_union`

`std::set_union`计算两个已排序序列的并集. 结果序列包含所有在第一个序列, 第二个序列或同时在两个序列中都出现的元素. 如果某个元素在两个序列中都出现, 结果中只会包含一个该元素的副本.

数学上, 这相当于$A \cup B$.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <iterator>

void print(const std::string& name, const std::vector<int>& v) {
    std::cout << name << ": ";
    for (int x : v) {
        std::cout << x << " ";
    }
    std::cout << std::endl;
}

int main() {
    std::vector<int> v1 = {1, 2, 3, 4, 5};
    std::vector<int> v2 = {3, 4, 5, 6, 7};
    std::vector<int> result;

    std::set_union(v1.begin(), v1.end(),
                   v2.begin(), v2.end(),
                   std::back_inserter(result));

    print("v1", v1);
    print("v2", v2);
    print("Union", result); // 输出: 1 2 3 4 5 6 7
}
```

### `std::set_intersection`

`std::set_intersection`计算两个已排序序列的交集. 结果序列仅包含同时存在于两个输入序列中的元素.

数学上, 这相当于$A \cap B$.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <iterator>

// print函数同上

int main() {
    std::vector<int> v1 = {1, 2, 3, 4, 5};
    std::vector<int> v2 = {3, 4, 5, 6, 7};
    std::vector<int> result;

    std::set_intersection(v1.begin(), v1.end(),
                          v2.begin(), v2.end(),
                          std::back_inserter(result));

    print("v1", v1);
    print("v2", v2);
    print("Intersection", result); // 输出: 3 4 5
}
```

### `std::set_difference`

`std::set_difference`计算两个已排序序列的差集. 结果序列包含所有存在于第一个序列但不存在于第二个序列中的元素.

数学上, 这相当于$A - B$或$A \setminus B$.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <iterator>

// print函数同上

int main() {
    std::vector<int> v1 = {1, 2, 3, 4, 5};
    std::vector<int> v2 = {3, 4, 5, 6, 7};
    std::vector<int> result;

    std::set_difference(v1.begin(), v1.end(),
                        v2.begin(), v2.end(),
                        std::back_inserter(result));

    print("v1", v1);
    print("v2", v2);
    print("Difference (v1 - v2)", result); // 输出: 1 2
}
```

### `std::set_symmetric_difference`

`std::set_symmetric_difference`计算两个已排序序列的对称差. 结果序列包含所有只存在于其中一个序列但不同时存在于两个序列中的元素.

数学上, 这相当于$(A \cup B) \setminus (A \cap B)$或$A \Delta B$.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <iterator>

// print函数同上

int main() {
    std::vector<int> v1 = {1, 2, 3, 4, 5};
    std::vector<int> v2 = {3, 4, 5, 6, 7};
    std::vector<int> result;

    std::set_symmetric_difference(v1.begin(), v1.end(),
                                  v2.begin(), v2.end(),
                                  std::back_inserter(result));

    print("v1", v1);
    print("v2", v2);
    print("Symmetric Difference", result); // 输出: 1 2 6 7
}
```

## 堆 🔺

C++标准库在`<algorithm>`头文件中提供了四个用于操作堆(heap)的函数. 这些函数可以直接在支持随机访问迭代器的容器 (如`std::vector`或`std::deque`) 上工作. 默认情况下, 这些操作都构建一个最大堆 (max-heap), 即堆顶元素是序列中的最大值. 你也可以提供一个自定义比较函数来创建最小堆 (min-heap).

### `std::make_heap`

`std::make_heap`函数可以将一个任意序列转换成一个堆. 它会重排`[first, last)`区间内的元素, 使其满足堆的性质.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

void print_heap(const std::vector<int>& v) {
    std::cout << "Heap: ";
    for (int x : v) {
        std::cout << x << " ";
    }
    std::cout << std::endl;
}

int main() {
    std::vector<int> v = {3, 1, 4, 1, 5, 9, 2, 6};

    // 将整个 vector 转换成一个最大堆
    std::make_heap(v.begin(), v.end());

    print_heap(v); // 输出: Heap: 9 6 4 1 5 1 2 3 (输出可能因实现而异, 但 v[0] 始终是最大值9)
}
```

### `std::push_heap`

`std::push_heap`用于向一个已存在的堆中添加新元素. 这个操作有一个前提: 新元素必须已经通过`push_back`等方法被添加到了容器的末尾. `std::push_heap`的作用是将这个新加入的元素上浮 (sift-up) 到堆中的正确位置.

添加元素的步骤:

1.  在容器末尾添加新元素 (例如`v.push_back(value)`).
2.  调用`std::push_heap(v.begin(), v.end())`来修复堆的结构.

```cpp
// 接着上面的 main 函数
int main() {
    std::vector<int> v = {3, 1, 4, 1, 5, 9, 2, 6};
    std::make_heap(v.begin(), v.end());
    print_heap(v); // Heap: 9 6 4 1 5 1 2 3

    // 步骤 1: 在末尾添加新元素
    v.push_back(7);
    std::cout << "After push_back(7): ";
    for(int x : v) std::cout << x << " "; // 此刻还不是一个合法的堆
    std::cout << std::endl;

    // 步骤 2: 调用 push_heap 调整堆
    std::push_heap(v.begin(), v.end());

    print_heap(v); // Heap: 9 7 4 6 5 1 2 3 1 (v[0] 仍然是最大值)
}
```

输出:

```
Heap: 9 6 4 1 5 3 2 1
After push_back(7): 9 6 4 1 5 3 2 1 7
Heap: 9 7 4 6 5 3 2 1 1
```

### `std::pop_heap`

`std::pop_heap`用于从堆中移除堆顶元素 (即最大值). 它并不会真正删除元素, 而是将堆顶元素与堆的最后一个元素交换, 然后将除最后一个元素外的范围`[first, last-1)`重新调整为合法的堆.

移除元素的步骤:

1.  调用`std::pop_heap(v.begin(), v.end())`. 此操作后, 最大元素被移动到容器末尾.
2.  从容器中移除末尾的元素 (例如`v.pop_back()`).

```cpp
// 接着上面的 main 函数
int main() {
    std::vector<int> v = {9, 7, 4, 6, 5, 1, 2, 3, 1}; // 一个合法的堆
    print_heap(v);

    // 步骤 1: 将堆顶元素(9)移动到末尾
    std::pop_heap(v.begin(), v.end());
    std::cout << "After pop_heap: ";
    for(int x : v) std::cout << x << " "; // 输出中 9 已在末尾
    std::cout << std::endl;

    // 步骤 2: 移除末尾的元素
    int max_val = v.back();
    v.pop_back();

    std::cout << "Removed max value: " << max_val << std::endl; // Removed max value: 9
    print_heap(v); // 剩余元素组成一个新堆, Heap: 7 6 4 3 5 1 2 1
}
```

输出:

```
Heap: 9 7 4 6 5 1 2 3 1
After pop_heap: 7 6 4 3 5 1 2 1 9
Removed max value: 9
Heap: 7 6 4 3 5 1 2 1
```

### `std::sort_heap`

`std::sort_heap`可以将一个合法的堆转换成一个有序序列. 它通过反复执行类似`pop_heap`的操作, 将堆顶元素依次放到序列的末尾, 最终得到一个升序排列的序列. 操作完成后, 这个序列就不再是堆了.

```cpp
// 接着上面的 main 函数
int main() {
    std::vector<int> v = {7, 6, 4, 3, 5, 1, 2, 1}; // 一个合法的堆
    print_heap(v);

    // 将堆排序
    std::sort_heap(v.begin(), v.end());

    std::cout << "Sorted vector: ";
    for (int x : v) {
        std::cout << x << " ";
    }
    std::cout << std::endl; // 输出: Sorted vector: 1 1 2 3 4 5 6 7
}
```

输出:

```
Heap: 7 6 4 3 5 1 2 1
Sorted vector: 1 1 2 3 4 5 6 7
```

## 大小 😶‍🌫️

### `std::min`, `std::max`

在C++标准库的`<algorithm>`头文件中, 提供了两个非常实用的模板函数: `std::min`和`std::max`. 它们分别用于返回两个或多个值中的最小值和最大值.

最常见的用法是比较两个值.

```cpp
#include <iostream>
#include <algorithm>

int main() {
    int a = 10;
    int b = 20;
    std::cout << "The minimum of a and b is: " << std::min(a, b) << std::endl; // 输出 10
    std::cout << "The maximum of a and b is: " << std::max(a, b) << std::endl; // 输出 20

    double x = 3.14;
    double y = 2.71;
    std::cout << "The minimum of x and y is: " << std::min(x, y) << std::endl; // 输出 2.71
    std::cout << "The maximum of x and y is: " << std::max(x, y) << std::endl; // 输出 3.14

    return 0;
}
```

默认情况下, `std::min`和`std::max`使用小于号`<`运算符来比较两个值. 如果两个值相等, `std::min`返回第一个值, `std::max`返回第一个值.

initializer\_list重载 (C++11):

自C++11起, `std::min`和`std::max`可以通过`std::initializer_list`来接收多个值, 并返回其中的最小或最大值.

```cpp
#include <iostream>
#include <algorithm>
#include <vector>

int main() {
    std::cout << "The minimum of {1, 5, 2, 8, 3} is: " << std::min({1, 5, 2, 8, 3}) << std::endl; // 输出 1
    std::cout << "The maximum of {1, 5, 2, 8, 3} is: " << std::max({1, 5, 2, 8, 3}) << std::endl; // 输出 8

    return 0;
}
```

自定义比较函数:

`std::min`和`std::max`还提供了重载版本, 允许用户提供一个自定义的二元比较函数 (通常是lambda表达式, 函数指针或函数对象). 这在处理没有默认`<`运算符的自定义类型, 或需要基于特定条件进行比较时非常有用.

该比较函数接收两个参数, 如果第一个参数小于第二个参数, 则返回`true`, 否则返回`false`.

```cpp
#include <iostream>
#include <algorithm>
#include <string>

struct Person {
    std::string name;
    int age;
};

int main() {
    Person p1 = {"Alice", 30};
    Person p2 = {"Bob", 25};

    // 使用lambda表达式根据年龄比较
    auto min_age_person = std::min(p1, p2, [](const Person& a, const Person& b) {
        return a.age < b.age;
    });

    auto max_age_person = std::max(p1, p2, [](const Person& a, const Person& b) {
        return a.age < b.age;
    });

    std::cout << "The person with the minimum age is: " << min_age_person.name << std::endl; // 输出 Bob
    std::cout << "The person with the maximum age is: " << max_age_person.name << std::endl; // 输出 Alice

    return 0;
}
```

注意事项:

* 返回类型: `std::min`和`std::max`返回对两个输入参数中较小或较大者的常量引用 (`const T&`).
* 临时对象: 当参数为临时对象 (右值) 时要小心. 获取返回值的引用可能会导致悬垂引用.
* `std::minmax` (C++11): 如果需要同时找到最小值和最大值, 使用`std::minmax`会更高效, 因为它只需要进行一次遍历 (对于`initializer_list`). `std::minmax`返回一个`std::pair`, `pair.first`是最小值, `pair.second`是最大值.

```cpp
#include <iostream>
#include <algorithm>
#include <vector>

int main() {
    auto result = std::minmax({1, 5, 2, 8, 3});
    std::cout << "Minimum: " << result.first << ", Maximum: " << result.second << std::endl; // 输出 Minimum: 1, Maximum: 8

    return 0;
}
```

### `std::min_element`, `std::max_element`

`std::min_element`和`std::max_element`是C++标准库`<algorithm>`头文件中的函数, 用于在指定范围内查找最小和最大的元素. 与`std::min`和`std::max`不同, 它们不直接返回值, 而是返回指向范围内最小或最大元素的迭代器.

基本用法:

这两个函数最常见的形式接收两个迭代器参数, `first`和`last`, 定义了一个前闭后开的范围`[first, last)`.

* `std::min_element(first, last)`: 返回指向`[first, last)`范围内最小元素的迭代器.
* `std::max_element(first, last)`: 返回指向`[first, last)`范围内最大元素的迭代器.

如果找到多个相等的最小或最大元素, 函数会返回指向第一个出现的该元素的迭代器. 如果范围为空, 函数返回`last`.

示例:

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

int main() {
    std::vector<int> v = {3, 1, 4, 1, 5, 9, 2, 6};

    // 查找最小元素
    auto min_it = std::min_element(v.begin(), v.end());
    // 查找最大元素
    auto max_it = std::max_element(v.begin(), v.end());

    // 要获取值, 需要解引用返回的迭代器
    if (min_it != v.end()) {
        std::cout << "The minimum element is: " << *min_it << std::endl; // 输出: 1
        std::cout << "Its index is: " << std::distance(v.begin(), min_it) << std::endl; // 输出: 1
    }

    if (max_it != v.end()) {
        std::cout << "The maximum element is: " << *max_it << std::endl; // 输出: 9
        std::cout << "Its index is: " << std::distance(v.begin(), max_it) << std::endl; // 输出: 5
    }

    return 0;
}
```

自定义比较函数:

与`std::min`和`std::max`类似, `std::min_element`和`std::max_element`也有一个重载版本, 允许你提供一个自定义的二元比较函数. 这对于根据对象的特定属性进行比较非常有用.

比较函数接收两个参数, 如果第一个参数被认为小于第二个参数, 则返回`true`.

示例:

```cpp
#include <iostream>
#include <vector>
#include <string>
#include <algorithm>

struct Person {
    std::string name;
    int age;
};

int main() {
    std::vector<Person> people = {
        {"Alice", 30},
        {"Bob", 25},
        {"Charlie", 35}
    };

    // 使用lambda表达式定义比较规则 (按年龄比较)
    auto compare_age = [](const Person& a, const Person& b) {
        return a.age < b.age;
    };

    // 查找年龄最小的人
    auto youngest_it = std::min_element(people.begin(), people.end(), compare_age);
    // 查找年龄最大的人
    auto oldest_it = std::max_element(people.begin(), people.end(), compare_age);

    if (youngest_it != people.end()) {
        std::cout << "The youngest person is: " << youngest_it->name << " (" << youngest_it->age << ")" << std::endl; // 输出: Bob (25)
    }

    if (oldest_it != people.end()) {
        std::cout << "The oldest person is: " << oldest_it->name << " (" << oldest_it->age << ")" << std::endl; // 输出: Charlie (35)
    }

    return 0;
}
```

### `std::minmax`, `std::minmax_element`


`std::minmax`用于比较两个值或一个初值列 (initializer\_list), 并同时返回其中的最小值和最大值. 它返回一个`std::pair`, 其中`pair.first`是最小值, `pair.second`是最大值. 如果两个输入值相等, 则`first`和`second`都是第一个值的副本.

基本用法 (比较两个值):

```cpp
#include <iostream>
#include <algorithm>
#include <utility>

int main() {
    int a = 10;
    int b = 20;

    std::pair<int, int> result = std::minmax(a, b);

    std::cout << "Min: " << result.first << ", Max: " << result.second << std::endl; // 输出: Min: 10, Max: 20
}
```

* 返回值: 对于`std::minmax(a, b)`, 返回类型是`std::pair<const T&, const T&>`, 即对输入参数的常量引用.

`initializer_list`重载 (C++11):

这是`std::minmax`更常见的用途, 可以在一组数中高效地找出最小和最大值.

```cpp
#include <iostream>
#include <algorithm>
#include <utility>
#include <vector>

int main() {
    auto result = std::minmax({3, 1, 4, 1, 5, 9, 2, 6});

    std::cout << "Min: " << result.first << ", Max: " << result.second << std::endl; // 输出: Min: 1, Max: 9
}
```

* 返回值: 对于`std::minmax(initializer_list)`, 返回类型是`std::pair<T, T>`, 其中`T`是列表中的元素类型. 这里返回的是值而非引用.

---

`std::minmax_element`用于在指定迭代器范围`[first, last)`内查找最小和最大的元素. 它返回一个`std::pair`, 其中`pair.first`是指向最小元素的迭代器, `pair.second`是指向最大元素的迭代器.

* 如果存在多个相等的最小元素, `first`会指向第一个.
* 如果存在多个相等的最大元素, `second`会指向最后一个.
* 如果范围为空, 返回`std::make_pair(last, last)`.

基本用法:

```cpp
#include <iostream>
#include <algorithm>
#include <vector>
#include <utility>

int main() {
    std::vector<int> v = {3, 1, 4, 1, 5, 9, 2, 6, 9};

    auto result_iters = std::minmax_element(v.begin(), v.end());

    // 需要解引用迭代器来获取值
    if (result_iters.first != v.end()) {
        std::cout << "Min element is: " << *result_iters.first << " at index "
                  << std::distance(v.begin(), result_iters.first) << std::endl; // 输出: Min element is: 1 at index 1
    }

    if (result_iters.second != v.end()) {
        std::cout << "Max element is: " << *result_iters.second << " at index "
                  << std::distance(v.begin(), result_iters.second) << std::endl; // 输出: Max element is: 9 at index 8
    }
}
```

自定义比较函数:

这两个函数都有重载版本, 允许提供自定义的二元比较函数, 用法与`std::max_element`等类似.

```cpp
#include <iostream>
#include <algorithm>
#include <vector>
#include <string>

struct Person { std::string name; int age; };

int main() {
    std::vector<Person> people = {{"Alice", 30}, {"Bob", 25}, {"Charlie", 35}};

    auto compare_age = [](const Person& a, const Person& b) { return a.age < b.age; };

    auto result = std::minmax_element(people.begin(), people.end(), compare_age);

    std::cout << "Youngest: " << result.first->name << ", Oldest: " << result.second->name << std::endl; // 输出: Youngest: Bob, Oldest: Charlie
}
```

### `std::clamp`

`std::clamp`接收三个参数: 一个待检查的值`v`, 一个下界`lo`(low), 以及一个上界`hi`(high). 它的逻辑非常直观:

1.  如果值`v`小于下界`lo`, 则返回`lo`.
2.  如果值`v`大于上界`hi`, 则返回`hi`.
3.  如果值`v`在`lo`和`hi`之间 (包含边界), 则返回`v`本身.

可以把它看作是`std::max(lo, std::min(v, hi))`的简化写法, 但`std::clamp`的意图更清晰, 且可能由编译器进行优化.

语法:

```cpp
template<class T>
constexpr const T& clamp(const T& v, const T& lo, const T& hi);

template<class T, class Compare>
constexpr const T& clamp(const T& v, const T& lo, const T& hi, Compare comp);
```

* `v`: 要被限制的值.
* `lo`: 范围的下界 (最小值).
* `hi`: 范围的上界 (最大值).
* `comp` (可选): 一个自定义的比较函数. 默认使用`<`运算符.

重要前提: 函数假设下界`lo`不大于上界`hi`. 如果`lo > hi`, 行为是未定义的 (undefined behavior).

返回值:

函数返回对`lo`, `hi`或`v`三者之一的常量引用 (`const T&`).

示例:

```cpp
#include <iostream>
#include <algorithm>

int main() {
    int value = 50;
    int min_val = 0;
    int max_val = 100;

    // value在[0, 100]之间, 返回value本身
    std::cout << "Clamping 50 between 0 and 100: " << std::clamp(value, min_val, max_val) << std::endl; // 输出: 50

    value = -10;
    // value < 0, 返回下界0
    std::cout << "Clamping -10 between 0 and 100: " << std::clamp(value, min_val, max_val) << std::endl; // 输出: 0

    value = 120;
    // value > 100, 返回上界100
    std::cout << "Clamping 120 between 0 and 100: " << std::clamp(value, min_val, max_val) << std::endl; // 输出: 100

    // 也适用于浮点数
    double d_val = 1.23;
    double d_min = 3.14;
    double d_max = 4.56;
    std::cout << "Clamping 1.23 between 3.14 and 4.56: " << std::clamp(d_val, d_min, d_max) << std::endl; // 输出: 3.14
}
```

实际应用场景:

`std::clamp`在很多领域都非常有用, 例如:

  * 图形学: 颜色值通常被限制在`[0, 255]` (对于8位颜色通道) 或`[0.0, 1.0]` (对于浮点颜色) 范围内.
  * 游戏开发: 限制角色的生命值不能低于0, 或者限制其在地图上的坐标.
  * 物理模拟: 确保物理量 (如速度或位置) 保持在有效或安全的范围内.
  * 用户输入处理: 确保用户输入滑块或文本框的数值在允许的区间内.

例如, 控制一个对象的音量:

```cpp
void set_volume(float volume) {
    // 确保音量总是在0.0 (静音) 到 1.0 (最大) 之间
    float clamped_volume = std::clamp(volume, 0.0f, 1.0f);
    // ... 应用clamped_volume
}
```

## 数值计算 🔢

### `std::midpoint`

`std::midpoint`是C++20中引入的一个非常实用的数学函数, 位于`<numeric>`头文件中. 它的主要功能是安全地计算两个数的中间值. 为什么需要`std::midpoint`? 在`std::midpoint`出现之前, 计算`a`和`b`的中间值通常会用以下方式:

```cpp
auto mid = (a + b) / 2;
```

这种看似简单的方法存在两个主要问题:

1.  整数溢出: 如果`a`和`b`都是很大的正整数 (例如`INT_MAX`), 它们的和`a + b`可能会超出该类型所能表示的最大范围, 导致整数溢出 (integer overflow). 溢出后的结果是未定义的 (undefined behavior), 计算出的中间值自然也是错误的.
2.  浮点数精度: 对于浮点数, `(a + b)`可能会损失精度.

`std::midpoint`的出现就是为了以一种安全, 高效且无溢出的方式解决这个问题.

`std::midpoint`可以用于整数类型和指针类型. 对于整数类型: 它计算`a`和`b`的中间值, 并在结果为非整数时向`a`的方向舍入. 换句话说, 它计算的是$\lfloor \frac{a+b}{2} \rfloor$. 其实现方式可以等价于:

```cpp
if (a > b) std::midpoint(b, a); // 保证 a <= b
return a + (b - a) / 2;
```

通过计算`a`与两者差值的一半之和, 巧妙地避免了`a+b`可能导致的溢出.

示例 (整数):

```cpp
#include <iostream>
#include <numeric>
#include <limits>

int main() {
    // 基本用法
    std::cout << "Midpoint of 7 and 10 is " << std::midpoint(7, 10) << std::endl;   // 输出: 8 ( (7+10)/2 = 8.5, 向7舍入)
    std::cout << "Midpoint of 7 and 11 is " << std::midpoint(7, 11) << std::endl;   // 输出: 9 ( (7+11)/2 = 9 )
    std::cout << "Midpoint of 10 and 7 is " << std::midpoint(10, 7) << std::endl;   // 输出: 8 (向7舍入)

    // 避免溢出
    int a = std::numeric_limits<int>::max() - 2;
    int b = std::numeric_limits<int>::max();

    // (a + b) / 2 会导致溢出, 结果错误
    // std::midpoint 计算正确
    std::cout << "Safe midpoint: " << std::midpoint(a, b) << std::endl; // 输出: 2147483646 (正确结果)
}
```

对于指针类型: `std::midpoint`也可以用于计算两个指向同一个数组元素的指针的中间位置. 这在二分查找等算法中非常有用.

示例 (指针):

```cpp
#include <iostream>
#include <numeric>
#include <vector>

int main() {
    std::vector<int> v = {0, 10, 20, 30, 40, 50, 60};

    auto* start = v.data();         // 指向第一个元素 (0)
    auto* end = v.data() + v.size(); // 指向末尾之后的位置

    auto* mid_ptr = std::midpoint(start, end);

    // mid_ptr 指向元素30
    std::cout << "Midpoint element is " << *mid_ptr << std::endl; // 输出: 30
    std::cout << "Its index is " << std::distance(start, mid_ptr) << std::endl; // 输出: 3
}
```

使用`std::midpoint(p, q)`比传统的`p + (q - p) / 2`写法更简洁, 意图更清晰.

### `std::lerp`

`std::lerp`是C++20中引入的一个非常有用的浮点数函数, 位于`<cmath>`头文件中. `lerp`是Linear Interpolation (线性插值) 的缩写. `std::lerp`的功能是计算两个点`a`和`b`之间的线性插值. 简单来说, 就是在`a`和`b`之间, 根据一个比例因子`t`, 找出一个点.

它的数学公式为:

$$\text{lerp}(a, b, t) = a + t \cdot (b - a)$$

语法:

```cpp
float lerp(float a, float b, float t);
double lerp(double a, double b, double t);
long double lerp(long double a, long double b, long double t);
```

`std::lerp`仅为浮点类型 (`float`, `double`, `long double`) 定义.

* `a`: 起点值.
* `b`: 终点值.
* `t`: 插值因子或比例.

参数`t`的含义:

* 当`t = 0.0`, `lerp`返回`a`. (移动0倍距离)
* 当`t = 1.0`, `lerp`返回`b`. (移动1倍距离)
* 当`t = 0.5`, `lerp`返回`a`和`b`的正中间值. (移动一半距离)
* 当`0.0 < t < 1.0`, `lerp`返回`a`和`b`之间的某个点.

超出范围的`t` (外插):

`std::lerp`的一个强大之处在于`t`的值不一定需要限制在`[0.0, 1.0]`范围内.

* 当`t < 0.0`, 函数会进行外插 (Extrapolation), 返回在`a`点 "另一侧" 的点.
* 当`t > 1.0`, 函数同样会进行外插, 返回超过`b`点的点.

示例:

```cpp
#include <iostream>
#include <cmath> // 必须包含此头文件

int main() {
    double a = 10.0;
    double b = 20.0;

    // 在[0, 1]范围内插值
    std::cout << "t = 0.0: " << std::lerp(a, b, 0.0) << std::endl;  // 输出: 10
    std::cout << "t = 0.25: " << std::lerp(a, b, 0.25) << std::endl; // 输出: 12.5 (10 + 0.25 * 10)
    std::cout << "t = 0.5: " << std::lerp(a, b, 0.5) << std::endl;  // 输出: 15
    std::cout << "t = 1.0: " << std::lerp(a, b, 1.0) << std::endl;  // 输出: 20

    std::cout << "--------------------" << std::endl;
\\
    // 在[0, 1]范围外插值
    std::cout << "t = -0.5: " << std::lerp(a, b, -0.5) << std::endl; // 输出: 5 (10 - 0.5 * 10)
    std::cout << "t = 2.0: " << std::lerp(a, b, 2.0) << std::endl;   // 输出: 30 (10 + 2.0 * 10)
}
```

为什么需要`std::lerp`? 你可能会问, `a + t * (b - a)`这个表达式很简单, 为什么还需要一个专门的函数?

1.  精度: `std::lerp`的实现经过特殊设计, 可以在`t`接近0或1时, 或者`a`和`b`非常接近时, 提供比直接计算`a + t * (b - a)`更高的精度. 它能更好地处理浮点数的舍入误差.
2.  清晰性: `std::lerp(a, b, t)`的意图非常明确, 就是进行线性插值. 这使得代码更易读, 更易于维护.
3.  标准化: 提供了一个标准的方式来执行这个常用操作, 增强了代码的可移植性.

线性插值在许多领域都是基础操作:

* 动画和游戏: 平滑地移动一个物体从位置A到位置B. `t`可以代表动画完成的百分比.
* 图形学: 在两种颜色之间创建渐变. `a`和`b`是颜色值, `t`是渐变的位置.
* 音频处理: 改变音高或实现淡入淡出效果.
* 数据分析: 在离散的数据点之间估算值.

### `std::iota`

`std::iota`是C++11中引入的一个非常有用的函数, 位于`<numeric>`头文件中. 它的名字来源于APL语言, 意为生成一个整数序列.  `std::iota`的功能非常简单直接: 用一个从指定初始值开始连续递增的序列来填充一个范围 (range).  具体来说, 它会为你指定的范围内的第一个元素赋初始值, 然后为第二个元素赋`初始值 + 1`, 第三个元素赋`初始值 + 2`, 依此类推.

语法:

```cpp
#include <numeric> // 必须包含此头文件

template<class ForwardIt, class T>
void iota(ForwardIt first, ForwardIt last, T value);
```

* `first`: 指向要填充范围的起始位置的迭代器.
* `last`: 指向要填充范围的末尾之后位置的迭代器 (即前闭后开`[first, last)`) .
* `value`: 序列的初始值. `first`指向的元素将被赋予这个值.

这个函数没有返回值 (`void`). 它会直接修改传入的迭代器范围内的元素.

为什么需要`std::iota`? 在`std::iota`出现之前, 如果你想创建一个包含`0, 1, 2, 3, 4`的`vector`, 你可能需要手写一个循环:

```cpp
std::vector<int> v(5);
for (int i = 0; i < v.size(); ++i) {
    v[i] = i;
}
```

使用`std::iota`, 你可以用一行代码完成同样的事情, 代码意图更清晰, 也更简洁.

示例:

这是最常见的用法.

```cpp
#include <iostream>
#include <vector>
#include <numeric>
#include <list>

int main() {
    std::vector<int> v(5);

    // 用 0, 1, 2, 3, 4 填充vector
    std::iota(v.begin(), v.end(), 0);

    std::cout << "Vector contains: ";
    for (int i : v) {
        std::cout << i << " "; // 输出: 0 1 2 3 4
    }
    std::cout << std::endl;

    std::list<int> l(4);

    // 用 -2, -1, 0, 1 填充list
    std::iota(l.begin(), l.end(), -2);

    std::cout << "List contains: ";
    for (int i : l) {
        std::cout << i << " "; // 输出: -2 -1 0 1
    }
    std::cout << std::endl;
}
```

用于其他可递增类型:

`std::iota`不仅限于`int`, 它可以用于任何支持前缀自增运算符 (`++operator`) 的类型.

示例 (填充字符)

```cpp
#include <iostream>
#include <vector>
#include <numeric>

int main() {
    std::vector<char> alphabet(5);

    // 用 'a', 'b', 'c', 'd', 'e' 填充
    std::iota(alphabet.begin(), alphabet.end(), 'a');

    std::cout << "The first 5 letters are: ";
    for (char c : alphabet) {
        std::cout << c << " "; // 输出: a b c d e
    }
    std::cout << std::endl;
}
```

实际应用场景:

* 生成测试数据: 快速创建有序的数据集进行算法测试.
* 创建索引数组: 有时需要一个代表其他容器索引的数组, 例如 `std::vector<int> indices(N); std::iota(indices.begin(), indices.end(), 0);`. 这在排序或需要间接访问时非常有用.
* 初始化: 作为一种比循环更简洁的初始化序列的方式.

### `std::adjacent_difference`

`std::adjacent_difference`是C++标准库`<numeric>`头文件中的一个算法, 用于计算一个序列中相邻元素之间的差. 简单来说, 它会遍历一个输入序列, 并生成一个新的序列. 在新序列中, 除了第一个元素被直接复制外, 其他每个元素都是输入序列中当前元素与前一个元素的差值.

`std::adjacent_difference`有两个版本: 一个使用默认的减法操作, 另一个允许你提供自定义的二元操作.

1. 默认行为 (减法)

    它会执行以下计算:

    * `result[0] = input[0]`
    * `result[1] = input[1] - input[0]`
    * `result[2] = input[2] - input[1]`
    * `result[3] = input[3] - input[2]`
    * ...

    示例:

    ```cpp
    #include <iostream>
    #include <vector>
    #include <numeric> // 必须包含此头文件

    int main() {
        std::vector<int> v = {2, 5, 1, 8, 3};
        std::vector<int> diff(v.size());

        std::adjacent_difference(v.begin(), v.end(), diff.begin());

        std::cout << "Input: ";
        for (int x : v) std::cout << x << " "; // 输出: 2 5 1 8 3
        std::cout << std::endl;

        std::cout << "Differences: ";
        for (int x : diff) std::cout << x << " "; // 输出: 2 3 -4 7 -5
        std::cout << std::endl;
    }
    ```

    结果分析:

    * `diff[0]` = `v[0]` = `2`
    * `diff[1]` = `v[1] - v[0]` = `5 - 2` = `3`
    * `diff[2]` = `v[2] - v[1]` = `1 - 5` = `-4`
    * `diff[3]` = `v[3] - v[2]` = `8 - 1` = `7`
    * `diff[4]` = `v[4] - v[3]` = `3 - 8` = `-5`


2. 自定义二元操作

    你可以提供一个自定义函数来替代默认的减法. 例如,你可以用它来计算相邻元素的和, 乘积, 甚至是生成一个斐波那契数列.

    示例: 生成斐波那契数列
    斐波那契数列的规则是`F(n) = F(n-1) + F(n-2)`. 这与`adjacent_difference`的模式不完全匹配. 但如果我们反向思考, `std::partial_sum`的自定义版本可以生成斐波那契数列. `adjacent_difference`的自定义版本则更适合计算相邻元素的特定关系.

    让我们看一个计算相邻元素乘积的例子:

    ```cpp
    #include <iostream>
    #include <vector>
    #include <numeric>
    #include <functional> // for std::multiplies

    int main() {
        std::vector<int> v = {1, 2, 3, 5, 8};
        std::vector<int> result(v.size());

        // 使用乘法操作替代减法
        std::adjacent_difference(v.begin(), v.end(), result.begin(), std::multiplies<int>());

        std::cout << "Adjacent products: ";
        for (int x : result) std::cout << x << " "; // 输出: 1 2 6 15 40
        std::cout << std::endl;
    }
    ```

    结果分析:

    * `result[0]` = `v[0]` = `1`
    * `result[1]` = `v[1] * v[0]` = `2 * 1` = `2`
    * `result[2]` = `v[2] * v[1]` = `3 * 2` = `6`
    * `result[3]` = `v[3] * v[2]` = `5 * 3` = `15`
    * `result[4]` = `v[4] * v[3]` = `8 * 5` = `40`

### `std::partial_sum`

`std::partial_sum`是C++标准库`<numeric>`头文件中的一个经典算法, 用于计算一个序列的部分和 (Partial Sums), 也常被称为前缀和 (Prefix Sums). `std::partial_sum`会遍历一个输入序列, 并生成一个新的序列. 新序列中的每个元素都是输入序列中从开始到当前位置所有元素的总和.

1. 默认行为 (加法)

    它会执行以下计算:

    * `result[0] = input[0]`
    * `result[1] = input[0] + input[1]`
    * `result[2] = input[0] + input[1] + input[2]`
    * `result[3] = input[0] + input[1] + input[2] + input[3]`
    * ...

    或者可以更高效地描述为:

    * `result[0] = input[0]`
    * `result[n] = result[n-1] + input[n]`

    示例:

    ```cpp
    #include <iostream>
    #include <vector>
    #include <numeric> // 必须包含此头文件

    int main() {
        std::vector<int> v = {1, 2, 3, 4, 5};
        std::vector<int> sums(v.size());

        // 计算v的部分和, 结果存入sums
        std::partial_sum(v.begin(), v.end(), sums.begin());

        std::cout << "Input: ";
        for (int x : v) std::cout << x << " ";    // 输出: 1 2 3 4 5
        std::cout << std::endl;

        std::cout << "Partial sums: ";
        for (int x : sums) std::cout << x << " "; // 输出: 1 3 6 10 15
        std::cout << std::endl;
    }
    ```

    结果分析:

    * `sums[0]` = `v[0]` = `1`
    * `sums[1]` = `sums[0] + v[1]` = `1 + 2` = `3`
    * `sums[2]` = `sums[1] + v[2]` = `3 + 3` = `6`
    * `sums[3]` = `sums[2] + v[3]` = `6 + 4` = `10`
    * `sums[4]` = `sums[3] + v[4]` = `10 + 5` = `15`

2. 自定义二元操作

    与`<numeric>`中的许多其他算法一样, `std::partial_sum`也有一个重载版本, 允许你提供一个自定义的二元函数来替代默认的加法. 这极大地扩展了它的用途.

    示例: 计算部分积 (Running Product)
    我们可以提供一个乘法函数来计算一个序列的 "部分积".

    ```cpp
    #include <iostream>
    #include <vector>
    #include <numeric>
    #include <functional> // for std::multiplies

    int main() {
        std::vector<int> v = {1, 2, 3, 4, 5};
        std::vector<int> products(v.size());

        // 使用乘法操作替代加法
        std::partial_sum(v.begin(), v.end(), products.begin(), std::multiplies<int>());

        std::cout << "Input: ";
        for (int x : v) std::cout << x << " ";       // 输出: 1 2 3 4 5
        std::cout << std::endl;

        std::cout << "Partial products: ";
        for (int x : products) std::cout << x << " "; // 输出: 1 2 6 24 120
        std::cout << std::endl;
    }
    ```

    结果分析:

    * `products[0]` = `v[0]` = `1`
    * `products[1]` = `products[0] * v[1]` = `1 * 2` = `2`
    * `products[2]` = `products[1] * v[2]` = `2 * 3` = `6`
    * `products[3]` = `products[2] * v[3]` = `6 * 4` = `24`
    * `products[4]` = `products[3] * v[4]` = `24 * 5` = `120`

`std::partial_sum`允许输出迭代器与输入迭代器相同, 从而实现就地 (in-place)计算, 直接修改原始容器.

```cpp
#include <iostream>
#include <vector>
#include <numeric>

int main() {
    std::vector<int> v = {1, 2, 3, 4, 5};

    // 就地计算, 结果会覆盖v本身
    std::partial_sum(v.begin(), v.end(), v.begin());

    std::cout << "In-place partial sums: ";
    for (int x : v) std::cout << x << " "; // 输出: 1 3 6 10 15
    std::cout << std::endl;
}
```

### `std::inner_product`

`std::inner_product`是C++标准库`<numeric>`头文件中的一个强大算法, 主要用于计算两个序列的内积 (Inner Product), 通常也称为点积 (Dot Product).  `std::inner_product`的核心思想是: 它接收两个序列 (范围) 和一个初始值, 然后执行成对的 "乘法" 和 "加法" 操作.

1. 默认行为 (经典点积)

    最常用的版本接收两个范围的起始迭代器和一个初始值.
    `std::inner_product(first1, last1, first2, init)`

    它执行以下计算:
    `init + (v1[0] * v2[0]) + (v1[1] * v2[1]) + (v1[2] * v2[2]) + ...`

    其中`v1`是第一个序列, `v2`是第二个序列.

    步骤分解:

    1.  取第一个序列的元素`*first1`和第二个序列的元素`*first2`.
    2.  将它们相乘.
    3.  将乘积加到初始值`init`上.
    4.  移动到下一个元素, 重复此过程, 直到第一个序列结束.

    示例:

    ```cpp
    #include <iostream>
    #include <vector>
    #include <numeric> // 必须包含此头文件

    int main() {
        std::vector<int> v1 = {1, 2, 3};
        std::vector<int> v2 = {4, 5, 6};

        // 初始值为0
        // 计算: 0 + (1*4) + (2*5) + (3*6)
        int result = std::inner_product(v1.begin(), v1.end(), v2.begin(), 0);

        std::cout << "The inner product is: " << result << std::endl; // 输出: 32 (4 + 10 + 18)
    }
    ```

    注意: 第二个序列只需要提供起始迭代器. 函数假定它至少与第一个序列一样长.

2. 自定义操作 (通用版本)

    `std::inner_product`的真正威力在于其更通用的重载版本, 它允许你为 "加法" 和 "乘法" 操作提供自定义的二元函数.

    `std::inner_product(first1, last1, first2, init, op1, op2)`

    它执行的计算变为:
    `op1( init, op2(v1[0], v2[0]) )`
    `op1( ... , op2(v1[1], v2[1]) )`
    ...

    * `op1`: 替代默认加法的操作 (累积操作).
    * `op2`: 替代默认乘法的操作 (转换操作).

    示例: 检查两个序列是否相等

    我们可以利用这个通用版本来高效地比较两个序列是否完全相同, 而无需直接比较.

    ```cpp
    #include <iostream>
    #include <vector>
    #include <numeric>
    #include <functional> // For std::equal_to, std::logical_and

    int main() {
        std::vector<int> v1 = {1, 2, 3, 4};
        std::vector<int> v2 = {1, 2, 9, 4}; // 第三个元素不同

        // op1 (累加): 使用逻辑与 (logical_and)
        // op2 (转换): 使用等于 (equal_to)
        // 初始值: true
        // 计算逻辑: true && (1==1) && (2==2) && (3==9) && (4==4)
        bool are_equal = std::inner_product(
            v1.begin(),
            v1.end(),
            v2.begin(),
            true,            // 初始值为true
            std::logical_and<bool>(), // 替代加法
            std::equal_to<int>()      // 替代乘法
        );

        if (are_equal) {
            std::cout << "The vectors are equal." << std::endl;
        } else {
            std::cout << "The vectors are NOT equal." << std::endl; // 输出此行
        }
    }
    ```

    这个例子展示了`inner_product`如何被用于完全非数值的逻辑运算.

### `std::accumulate`

`std::accumulate`是C++标准库`<numeric>`头文件中的一个核心算法, 用于将一个范围内的元素累积或规约 (reduce) 成一个单一的值. 它是替代手写循环进行求和, 求积等聚合操作的首选方案. 🎯

1. 默认用法 (累加求和)

    `std::accumulate`最常见的用法是计算一个序列的总和. 它需要三个参数:

    1.  `first`: 指向序列起始位置的迭代器.
    2.  `last`: 指向序列末尾之后位置的迭代器.
    3.  `init`: 累加的初始值. 计算将从这个值开始.

    它的计算过程是 `init + v[0] + v[1] + ...`.

    示例:

    ```cpp
    #include <iostream>
    #include <vector>
    #include <numeric> // 必须包含此头文件

    int main() {
        std::vector<int> v = {1, 2, 3, 4, 5};

        // 1. 计算总和, 初始值为0
        // 计算过程: 0 + 1 + 2 + 3 + 4 + 5
        int sum = std::accumulate(v.begin(), v.end(), 0);
        std::cout << "Sum: " << sum << std::endl; // 输出: 15

        // 2. 初始值可以是任意值
        // 计算过程: 100 + 1 + 2 + 3 + 4 + 5
        int sum_with_offset = std::accumulate(v.begin(), v.end(), 100);
        std::cout << "Sum with offset: " << sum_with_offset << std::endl; // 输出: 115
    }
    ```

2. 自定义操作

    `std::accumulate`的强大之处在于它允许你提供第四个参数: 一个二元操作函数 (binary operation), 用来替代默认的加法.

    这个函数接收两个参数: 第一个是到目前为止的累积值, 第二个是序列中的下一个元素.

    示例 1: 计算乘积

    ```cpp
    #include <iostream>
    #include <vector>
    #include <numeric>
    #include <functional> // for std::multiplies

    int main() {
        std::vector<int> v = {1, 2, 3, 4, 5};

        // 计算乘积, 初始值必须是1
        // 第四个参数也可以是lambda表达式: [](int a, int b) { return a * b; }
        int product = std::accumulate(v.begin(), v.end(), 1, std::multiplies<int>());
        std::cout << "Product: " << product << std::endl; // 输出: 120
    }
    ```

    示例 2: 连接字符串
    `std::accumulate`同样适用于非数值类型. 只要为该类型定义了 `+` 运算符, 默认的`accumulate`就能工作.

    ```cpp
    #include <iostream>
    #include <vector>
    #include <string>
    #include <numeric>

    int main() {
        std::vector<std::string> words = {"C++", " is", " powerful"};

        // 使用一个空的std::string作为初始值
        std::string sentence = std::accumulate(words.begin(), words.end(), std::string(""));
        std::cout << "Sentence: " << sentence << std::endl; // 输出: C++ is powerful
    }
    ```

### `std::reduce`

`std::reduce`是C++17中引入的一个强大的数值算法, 位于`<numeric>`头文件中. 它可以被看作是其前辈`std::accumulate`的现代化且可并行化的版本.

虽然`std::reduce`和`std::accumulate`都用于将一个序列规约 (reduce) 为单个值, 但它们之间存在一个关键区别:

* `std::accumulate`: 严格按顺序执行. 它总是从左到右, 依次将序列中的每个元素应用到累加值上. 计算顺序是固定的: `((init + v[0]) + v[1]) + v[2]...`.
* `std::reduce`: 不保证执行顺序. 它可以乱序 (out-of-order) 执行, 甚至并行 (in parallel) 执行. 这意味着它可以将序列分成多个块, 在不同线程上同时计算每个块的部分和, 最后再将这些部分和合并起来.

这个区别带来了以下重要的推论:

1.  性能: 因为可以并行计算, `std::reduce`在处理大规模数据时通常比`std::accumulate`快得多.
2.  操作限制: `std::accumulate`的操作只需要满足左结合 (left-associative) 即可. 而`std::reduce`所使用的二元操作必须同时满足结合律 (associative)和交换律 (commutative), 否则乱序执行会产生不确定的结果. 对于常见的加法和乘法, 这是成立的.

`std::reduce`的接口与`std::accumulate`非常相似, 但增加了一个可选的执行策略 (Execution Policy)参数.

1. 顺序执行 (与`accumulate`类似)

    如果不提供执行策略, `std::reduce`的行为类似于`std::accumulate`, 但仍不保证顺序.

    ```cpp
    #include <iostream>
    #include <vector>
    #include <numeric>

    int main() {
        std::vector<long long> v = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};

        // 用法1: 只提供范围 (C++20), 初始值为0
        // long long sum1 = std::reduce(v.begin(), v.end());

        // 用法2: 提供初始值 (C++17)
        long long sum2 = std::reduce(v.begin(), v.end(), 0LL); // 使用0LL表示long long类型的0

        std::cout << "Sum: " << sum2 << std::endl; // 输出: 55
    }
    ```

2. 并行执行 (发挥真正威力)

    要启用并行计算, 你需要在第一个参数位置提供一个执行策略. 这需要包含`<execution>`头文件.

    * `std::execution::seq`: 顺序执行.
    * `std::execution::par`: 并行执行.
    * `std::execution::par_unseq`: 并行且非顺序执行 (允许向量化).

    示例:

    ```cpp
    #include <iostream>
    #include <vector>
    #include <numeric>
    #include <execution> // 必须包含此头文件
    #include <chrono>

    int main() {
        // 创建一个非常大的vector来体现并行计算的优势
        std::vector<long long> large_vec(100'000'000, 1);

        auto start = std::chrono::high_resolution_clock::now();

        // 使用并行策略执行reduce
        long long sum = std::reduce(std::execution::par, large_vec.begin(), large_vec.end(), 0LL);

        auto end = std::chrono::high_resolution_clock::now();
        std::chrono::duration<double, std::milli> duration = end - start;

        std::cout << "Sum: " << sum << std::endl; // 输出: 100000000
        std::cout << "Parallel execution took: " << duration.count() << " ms" << std::endl;
    }
    ```

    注意: 编译支持并行算法的程序通常需要特定的编译器标志, 例如GCC/Clang的`-ltbb`或MSVC的`/EHsc`.

### `std::transform_reduce`

`std::transform_reduce`是C++17中引入的一个非常强大且高效的算法, 位于`<numeric>`头文件中. 从它的名字就可以看出它的功能: 它是transform (转换)和reduce (规约)两个操作的结合体. 它可以在一个步骤内对序列中的元素进行转换, 然后将转换后的结果聚合起来, 并且整个过程是可并行化的. `std::transform_reduce`基本上是`std::inner_product`的可并行化、更通用的版本, 并且在某些情况下可以替代`std::accumulate`.

`std::transform_reduce`有两个主要的重载版本.

1. 单序列版本 (Transform then Reduce)

    这个版本处理一个序列. 它首先对序列中的每个元素应用一个一元转换函数 (unary operation), 然后用一个二元规约函数 (binary operation)将所有转换结果聚合起来.

    逻辑过程:
    `reduce( transform(v[0]), transform(v[1]), transform(v[2]), ... )`

    示例: 计算一个vector中所有整数的平方和

    在C++17之前, 你可能需要两步:

    1.  创建一个新vector来存储每个元素的平方.
    2.  使用`std::accumulate`对新vector求和.

    使用`std::transform_reduce`, 你可以一步完成, 无需额外内存, 并且可以并行.

    ```cpp
    #include <iostream>
    #include <vector>
    #include <numeric>
    #include <execution> // For parallel execution

    int main() {
        std::vector<int> v = {1, 2, 3, 4, 5};

        // 参数分解:
        // 1. (可选) 执行策略: std::execution::par
        // 2. 范围: v.begin(), v.end()
        // 3. 初始值: 0
        // 4. 规约操作 (Reduce): std::plus<>{} (加法)
        // 5. 转换操作 (Transform): [](int n){ return n * n; } (平方)
        int sum_of_squares = std::transform_reduce(
            std::execution::par, // 开启并行
            v.begin(),
            v.end(),
            0,                 // 初始值
            std::plus<>{},     // 规约操作: +
            [](int n){ return n * n; } // 转换操作: x -> x*x
        );

        // 计算过程: 0 + (1*1) + (2*2) + (3*3) + (4*4) + (5*5)
        std::cout << "Sum of squares: " << sum_of_squares << std::endl; // 输出: 55
    }
    ```

2. 双序列版本 (类似`inner_product`)

    这个版本处理两个序列. 它首先对来自两个序列的成对元素应用一个二元转换函数, 然后用另一个二元规约函数将所有转换结果聚合起来.

    这个版本的功能与`std::inner_product`几乎完全相同, 但关键区别在于`std::transform_reduce`可以并行执行.

    逻辑过程:
    `reduce( transform(v1[0], v2[0]), transform(v1[1], v2[1]), ... )`

    示例: 计算两个向量的点积 (Dot Product)

    ```cpp
    #include <iostream>
    #include <vector>
    #include <numeric>
    #include <execution>

    int main() {
        std::vector<int> v1 = {1, 2, 3};
        std::vector<int> v2 = {4, 5, 6};

        // 参数分解:
        // 1. (可选) 执行策略: std::execution::par
        // 2. 范围1: v1.begin(), v1.end()
        // 3. 范围2起始: v2.begin()
        // 4. 初始值: 0
        // 5. 规约操作 (Reduce): std::plus<>{} (加法)
        // 6. 转换操作 (Transform): std::multiplies<>{} (乘法)
        int dot_product = std::transform_reduce(
            std::execution::par,
            v1.begin(),
            v1.end(),
            v2.begin(),
            0,
            std::plus<>{},          // 规约: +
            std::multiplies<>{}     // 转换: *
        );

        // 计算过程: 0 + (1*4) + (2*5) + (3*6)
        std::cout << "Dot product: " << dot_product << std::endl; // 输出: 32
    }
    ```

为什么要使用`std::transform_reduce`?

1.  性能: 它是为并行计算而设计的. 对于大数据集, 使用`std::execution::par`策略可以极大地提升性能, 因为它将工作分配给多个CPU核心.
2.  效率: 它将转换和规约两个操作融合在一起, 避免了创建中间容器的需要, 减少了内存分配和数据拷贝的开销.
3.  表达力: 函数名`transform_reduce`清晰地表达了其意图, 使代码更易于理解和维护. 它将一个复杂的循环操作封装成了一行声明式的代码.

### `std::exclusive_scan`, `std::inclusive_scan`

`std::exclusive_scan`和`std::inclusive_scan`这两个C++17的算法都位于`<numeric>`头文件, 它们是执行前缀和 (Prefix Sum)或扫描 (Scan)操作的现代化、可并行化的工具. 它们最大的区别就在于名字中的 "exclusive" (排除性) 和 "inclusive" (包含性).

核心概念: 包含还是排除? 理解这两个函数的关键在于, 计算输出序列的第`i`个元素时, 是否包含了输入序列的第`i`个元素.

`std::inclusive_scan` (包含性扫描): 第`i`个输出是前`i`个输入元素的总和 (从第0个到第`i`个). 它的行为与经典的`std::partial_sum`完全相同.

* 公式: `result[i] = op(v[0], v[1], ..., v[i])`
* 记忆法: "Inclusive" -\> 包含我自己.

`std::exclusive_scan` (排除性扫描): 第`i`个输出是前`i-1`个输入元素的总和 (从第0个到第`i-1`个). 它排除了当前位置`i`的输入元素.

* 公式: `result[i] = op(init, v[0], v[1], ..., v[i-1])`
* 记忆法: "Exclusive" -\> 排除我自己.

---

* 对比示例 (默认加法)

    下面这个例子最能直观地展示它们的区别.

    ```cpp
    #include <iostream>
    #include <vector>
    #include <numeric>

    int main() {
        std::vector<int> v = {1, 2, 3, 4, 5};
        std::vector<int> inclusive_result(v.size());
        std::vector<int> exclusive_result(v.size());

        int init_val = 100;

        // --- 包含性扫描 ---
        std::inclusive_scan(v.begin(), v.end(), inclusive_result.begin());

        // --- 排除性扫描 ---
        // 注意: exclusive_scan必须提供一个初始值
        std::exclusive_scan(v.begin(), v.end(), exclusive_result.begin(), init_val);

        // --- 打印结果 ---
        std::cout << "Input:             ";
        for(int n : v) std::cout << n << "  ";
        std::cout << "\n\n";

        std::cout << "Inclusive Scan:    ";
        for(int n : inclusive_result) std::cout << n << "  ";
        std::cout << "  (与partial_sum相同)\n";
        // 计算过程:
        // 1
        // 1+2 = 3
        // 1+2+3 = 6
        // ...

        std::cout << "Exclusive Scan:    ";
        for(int n : exclusive_result) std::cout << n << "  ";
        std::cout << "  (初始值: " << init_val << ")\n";
        // 计算过程:
        // 100
        // 100+1 = 101
        // 100+1+2 = 103
        // ...
    }
    ```

    输出结果:

    ```
    Input:             1  2  3  4  5

    Inclusive Scan:    1  3  6  10 15   (与partial_sum相同)
    Exclusive Scan:    100  101  103  106  110   (初始值: 100)
    ```

    结果分析:

    * `inclusive_scan`的结果就像一个标准的累加过程. `result[i]`包含了`v[i]`.
    * `exclusive_scan`的结果总是"慢一拍". `result[i]`的值取决于`v[i]`之前的所有元素. 它的第一个值总是你提供的`init_val`.

    可以观察到, `exclusive_scan`的结果像是`inclusive_scan`的结果向右平移了一位, 并且在开头插入了初始值.

* 共同特性: 自定义与并行

    这两个函数都是现代C++算法, 因此它们共享以下强大特性:

    1.  自定义操作: 可以提供一个二元函数来替代默认的加法 (如乘法, `std::max`等).
    2.  并行执行: 可以在第一个参数位置提供一个执行策略 (如`std::execution::par`) 来启用并行计算, 大大提升在大数据集上的性能.

    <!-- end list -->

    ```cpp
    #include <vector>
    #include <numeric>
    #include <execution>
    #include <functional>

    void parallel_custom_scans() {
        std::vector<int> v = {1, 2, 3, 4, 5};
        std::vector<int> inc_prod(v.size());
        std::vector<int> exc_prod(v.size());

        // 并行计算包含性部分积
        std::inclusive_scan(std::execution::par, v.begin(), v.end(), inc_prod.begin(), std::multiplies<int>());
        // inc_prod -> {1, 2, 6, 24, 120}

        // 并行计算排除性部分积
        std::exclusive_scan(std::execution::par, v.begin(), v.end(), exc_prod.begin(), 1, std::multiplies<int>());
        // exc_prod -> {1, 1, 2, 6, 24}
    }
    ```

| 特性 | `std::inclusive_scan` | `std::exclusive_scan` |
| :--- | :--- | :--- |
| 别名 | `partial_sum`的现代版 | - |
| 计算`result[i]` | 包含`input[i]` | 排除`input[i]` |
| 初始值`init` | 不直接使用`init`参数 | 必须提供`init`参数, 作为`result[0]` |
| 常见用途 | 计算标准前缀和, 数据分析中的累积分布 | 并行算法中的数据依赖问题, 如计算每个元素在其分区内的偏移量 |

如何选择?

* 如果你需要一个标准的累积和数组, 其中每个位置的值代表到该位置为止的总和, 使用`std::inclusive_scan`.
* 如果你需要计算一个值序列, 其中每个位置的值取决于它前面所有元素的总和, 而非其自身, 使用`std::exclusive_scan`. 这个场景在并行计算中更为常见.

## 交换 💱

### `std::swap`, `std::iter_swap`

`std::swap`是一个基础工具函数, 用于交换两个对象的值. `std::swap`定义在头文件`<utility>`中.

```cpp
#include <utility>
```

函数原型:

```cpp
template<class T>
void swap(T& a, T& b) noexcept(/* see below */);
```

- 模板参数`T`: 要交换的对象的类型.
- 参数`T& a`, `T& b`: 对要交换的两个对象的左值引用.
- `noexcept`: 自C++11起, `std::swap`是条件`noexcept`的. 这意味着如果`T`的移动构造函数和移动赋值运算符都是`noexcept`的, 那么`swap`本身也不会抛出异常.

工作原理:

在C++11之前, `std::swap`通常通过一个临时变量和拷贝操作实现. 自C++11起, `std::swap`被高度优化, 默认使用移动语义(Move Semantics)而非拷贝, 这对于管理动态资源(如`std::vector`, `std::string`)的对象来说效率极高. 其典型实现等价于:

```cpp
T temp = std::move(a);
a = std::move(b);
b = std::move(temp);
```

这种方式避免了深拷贝, 只是交换了资源的"所有权", 因此性能非常好.

使用示例:

```cpp
#include <iostream>
#include <utility> // std::swap
#include <vector>
#include <string>

void print_vector(const std::string& name, const std::vector<int>& v) {
    std::cout << name << ": ";
    for (int i : v) {
        std::cout << i << " ";
    }
    std::cout << std::endl;
}

int main() {
    // 示例1: 交换基本类型
    int x = 10;
    int y = 20;
    std::cout << "Before swap: x = " << x << ", y = " << y << std::endl;
    std::swap(x, y);
    std::cout << "After swap:  x = " << x << ", y = " << y << std::endl;

    std::cout << "--------------------" << std::endl;

    // 示例2: 交换复杂类型 (高效的移动操作)
    std::vector<int> vec1 = {1, 2, 3};
    std::vector<int> vec2 = {9, 8, 7, 6};

    print_vector("Before swap vec1", vec1);
    print_vector("Before swap vec2", vec2);

    std::swap(vec1, vec2); // 非常高效, 只交换了内部指针和大小等成员

    print_vector("After swap vec1", vec1);
    print_vector("After swap vec2", vec2);

    return 0;
}
```

---

`std::iter_swap`是一个算法, 用于交换两个迭代器所指向的元素的值. `std::iter_swap`定义在头文件`<algorithm>`中.

```cpp
#include <algorithm>
```

函数原型:

```cpp
template<class ForwardIt1, class ForwardIt2>
void iter_swap(ForwardIt1 a, ForwardIt2 b);
```

- 模板参数`ForwardIt1`, `ForwardIt2`: 迭代器的类型. 至少要求是前向迭代器(Forward Iterator).
- 参数`a`, `b`: 两个迭代器. 函数会交换`*a`和`*b`的值.

工作原理:

`std::iter_swap`的核心是解引用(dereference)迭代器, 然后调用`swap`来交换它们指向的值. 其典型实现等价于:

```cpp
swap(*a, *b);
```

这意味着`std::iter_swap`最终依赖`std::swap`(或用户为特定类型定义的`swap`重载)来完成实际的交换工作. 它本身只负责处理迭代器.

使用示例:

`std::iter_swap`常用于在容器内或跨容器交换元素, 是许多排序和分区算法的构建模块.

```cpp
#include <iostream>
#include <vector>
#include <algorithm> // std::iter_swap

void print_vector(const std::vector<int>& v) {
    for (int i : v) {
        std::cout << i << " ";
    }
    std::cout << std::endl;
}

int main() {
    std::vector<int> numbers = {0, 1, 2, 3, 4, 5};

    std::cout << "Original vector: ";
    print_vector(numbers);

    // 获取指向第一个元素 (0) 和第四个元素 (3) 的迭代器
    auto it1 = numbers.begin();
    auto it2 = numbers.begin() + 3;

    std::cout << "Swapping element " << *it1 << " and " << *it2 << std::endl;

    std::iter_swap(it1, it2);

    std::cout << "Vector after iter_swap: ";
    print_vector(numbers);

    return 0;
}
```

---

| 特性 | `std::swap` | `std::iter_swap` |
| :--- | :--- | :--- |
| 操作对象 | 变量本身 (对象) | 迭代器所指向的元素 |
| 参数类型 | 对对象的引用 (`T&`) | 迭代器 (`ForwardIt`) |
| 头文件 | `<utility>` | `<algorithm>` |
| 核心作用 | 交换两个具名变量的内容 | 交换两个位置上元素的内容, 通常用于算法中 |
| 使用场景 | 当你有两个明确的变量`a`和`b`需要交换时 | 当你通过迭代器访问容器中的元素并需要交换它们时 |
