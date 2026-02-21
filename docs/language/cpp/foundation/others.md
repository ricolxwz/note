---
title: 其他
icon: material/baseball-outline
comments: true
---

## 位运算

位运算是在二进制位 (bit) 级别上对数据进行操作的强大工具. 它在性能敏感的领域 (如图形学, 嵌入式系统, 网络编程) 中至关重要, 因为位运算直接对应处理器的底层指令, 速度极快. 为了精确控制位, 我们通常使用定宽整数类型 (如 `uint8_t`, `uint32_t`), 并以十六进制 (hexadecimal) 或二进制 (binary) 形式表示值, 这样能更直观地看到其底层的位模式.

- 十六进制 (Hex): 使用`0x`前缀. 例如, `0xFF`代表`11111111`.
- 二进制 (Binary): C++14起, 使用`0b`前缀. 例如, `0b1100`代表十进制的12.

```cpp
#include <iostream>
#include <cstdint>
#include <bitset> // 用于方便地打印二进制表示

int main() {
    // 使用十六进制初始化一个8位无符号整数 (1字节)
    // 0xA0 -> 10100000
    uint8_t my_value = 0xA0;

    // 使用std::bitset打印其二进制形式
    std::cout << "Value in binary: " << std::bitset<8>(my_value) << std::endl;

    // 使用std::hex打印其十六进制形式
    std::cout << "Value in hex:    0x" << std::hex << static_cast<int>(my_value) << std::endl;
}
```

### 位移运算

位移运算将一个数的所有二进制位向左或向右移动指定的位数.

#### 左移

左移 (Left Shift) `<<` 将所有位向左移动. 右侧空出的位用`0`填充, 左侧移出的位被丢弃.
效果: 每左移一位, 其数值相当于乘以2.

```cpp
uint8_t num = 0b00011001; // 十进制的 25
std::cout << "Original: " << std::bitset<8>(num) << " (" << static_cast<int>(num) << ")" << std::endl;

// 左移 2 位
uint8_t shifted_left = num << 2; // 变为 0b01100100
std::cout << "Left << 2: " << std::bitset<8>(shifted_left) << " (" << static_cast<int>(shifted_left) << ")" << std::endl; // 结果是 100 (25 * 4)
```

#### 右移

右移 (Right Shift) `>>` 将所有位向右移动. 左侧空出的位对于无符号数用`0`填充. 右侧移出的位被丢弃.
效果: 每右移一位, 其数值相当于除以2 (整数除法, 小数部分被截断).

```cpp
uint8_t num = 0b11001010; // 十进制的 202
std::cout << "Original: " << std::bitset<8>(num) << " (" << static_cast<int>(num) << ")" << std::endl;

// 右移 3 位
uint8_t shifted_right = num >> 3; // 变为 0b00011001
std::cout << "Right >> 3: " << std::bitset<8>(shifted_right) << " (" << static_cast<int>(shifted_right) << ")" << std::endl; // 结果是 25 (202 / 8)
```

### 位打包

位打包是一种将多个小数值 "打包" 存储到一个大整数中的技术, 以节省内存. 图像处理中的像素颜色是经典例子.

一个32位的`uint32_t`可以同时存储红 (R), 绿 (G), 蓝 (B), 透明 (A) 四个通道, 每个通道占8位.
`0xAARRGGBB` (Alpha, Red, Green, Blue)

示例: 从一个32位颜色值`0xFF8000FF`中提取各个颜色分量.

```cpp
#include <iostream>
#include <cstdint>
#include <iomanip> // std::setw, std::setfill

int main() {
    uint32_t packed_color = 0xFF8000FF; // A=FF, R=80, G=00, B=FF

    // 提取Alpha (最高8位): 右移24位
    uint8_t a = packed_color >> 24;
    // 提取Red (次高8位): 右移16位, 然后用掩码屏蔽掉Alpha
    uint8_t r = (packed_color >> 16) & 0xFF;
    // 提取Green (次低8位): 右移8位, 然后用掩码屏蔽掉高位
    uint8_t g = (packed_color >> 8) & 0xFF;
    // 提取Blue (最低8位): 直接用掩码屏蔽掉高位
    uint8_t b = packed_color & 0xFF;

    std::cout << std::hex << std::setfill('0');
    std::cout << "Alpha: 0x" << std::setw(2) << static_cast<int>(a) << std::endl;
    std::cout << "Red:   0x" << std::setw(2) << static_cast<int>(r) << std::endl;
    std::cout << "Green: 0x" << std::setw(2) << static_cast<int>(g) << std::endl;
    std::cout << "Blue:  0x" << std::setw(2) << static_cast<int>(b) << std::endl;
}
```

### 位掩码

位掩码是利用 `AND`, `OR`, `XOR` 等运算符, 配合一个称为 "掩码 (mask)" 的特定值, 来精确地读取, 设置, 翻转或清除一个数的某些位.

#### 按位与

`AND` 运算的规则是: 只有当两个位都为1时, 结果才为1.
常用于检查某位是否为1, 或清除某些位 (置为0).

```cpp
uint8_t flags = 0b10110101;
uint8_t mask = 0b00001000; // 只关心第3位 (从右数, 0-indexed)

// 检查第3位是否被设置
if ((flags & mask) != 0) {
    std::cout << "Flag at position 3 is set." << std::endl;
}

// 清除高4位
uint8_t cleared_flags = flags & 0x0F; // 0x0F is 0b00001111
std::cout << "Cleared high bits: " << std::bitset<8>(cleared_flags) << std::endl;
```

#### 按位或

`OR` 运算的规则是: 只要有一个位为1, 结果就为1.
常用于设置某些位 (置为1).

```cpp
uint8_t options = 0b00001001;
uint8_t mask_to_set = 0b01010000;

// 设置第4位和第6位
uint8_t new_options = options | mask_to_set;
std::cout << "Set bits: " << std::bitset<8>(new_options) << std::endl; // 结果为 0b01011001
```

#### 按位异或

`XOR` 运算的规则是: 两个位不同时, 结果为1; 相同时, 结果为0.
常用于翻转某些位.

```cpp
uint8_t data = 0b11001010;
uint8_t mask_to_flip = 0b00001111;

// 翻转低4位
uint8_t flipped_data = data ^ mask_to_flip;
std::cout << "Flipped low bits: " << std::bitset<8>(flipped_data) << std::endl; // 结果为 0b11000101
```
