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

## 比较 💮

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

## 复制

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

## 填充

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