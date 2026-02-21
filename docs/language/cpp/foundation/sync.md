---
title: 异步
icon: material/sync
comments: true
---

## `std::thread`

`std::thread` 是C++11标准库中引入的类, 用于在C++程序中创建和管理线程. 它提供了一种面向对象的方式来处理多线程, 使得并发编程更加直接和方便. 使用`std::thread`需要包含`<thread>`头文件.

### 创建线程

创建一个`std::thread`对象会自动启动一个新的执行线程. 这个新线程会调用你提供的可调用对象 (函数指针, 函数对象, 或lambda表达式).

```cpp
#include <iostream>
#include <thread>

void task() {
    std::cout << "任务在新线程中执行." << std::endl;
}

int main() {
    // 创建一个新线程并开始执行task()
    std::thread myThread(task);

    // 等待新线程执行完毕
    myThread.join();

    return 0;
}
```

### 关键成员函数

1. `join()`

    `join()`函数会阻塞当前线程 (例如`main`函数所在的线程), 直到`std::thread`对象所代表的线程执行完成. 一个线程在被`join()`后, 其所有资源都会被正确清理. 对一个已经`join()`过的线程再次调用`join()`是未定义行为.

2. `detach()`

    `detach()`函数会将子线程从`std::thread`对象中分离, 允许它独立于主线程继续执行. 分离后, `std::thread`对象不再代表任何线程, 即使线程执行完毕, 其资源也由C++运行时环境自动回收. 一旦线程被分离, 就不能再被`join()`了. 如果主线程退出, 所有分离的线程都会被强制终止.

    !!! note "何时需要`detach()`"

        `detach`的主要目的是创建"发后不理"(fire and forget)的线程. 这些线程在后台独立运行, 主线程不需要等待它们完成, 也不再与它们有任何直接的同步关系. 以下是需要`detach`的一些关键场景:

        1.  后台任务(Background Tasks): 当你需要一个长时间运行的任务在后台执行, 而主线程不需要其结果, 也不关心它何时结束时.

            * 日志记录: 一个专门的线程可以持续将日志信息写入文件, 主程序不必等待日志写完.
            * 监控: 一个后台线程可以定期检查网络连接, 系统健康状况或更新缓存, 这些操作独立于程序的核心逻辑.

        2.  提升响应性(Improving Responsiveness): 在图形用户界面(GUI)应用中, 如果一个操作(如文件下载, 复杂计算)会花费很长时间, 将它放在一个单独的线程中并`detach`可以防止UI线程被阻塞, 从而保持界面对用户的响应.

        3.  实现守护进程(Daemon-like Threads): 创建一个生命周期与整个应用程序一样长的服务线程. 这个线程从程序开始时启动, 在后台提供服务, 直到程序结束时被系统强行终止.

        `detach`与`join`的核心区别:

        * `join()`: 意味着"我需要等你完成, 因为我依赖你的结果或状态". 这是一种同步点.
        * `detach()`: 意味着"你去忙你的, 我不关心你何时结束". `std::thread`对象和其管理的执行线程就此分道扬镳.

        使用`detach`的风险和责任:

        虽然`detach`很有用, 但它也带来了巨大的风险, 必须谨慎使用:

        * 悬空引用/指针: 这是最危险的问题. 如果分离的线程访问了主线程中的局部变量, 而主线程的函数返回导致这些变量被销毁, 那么后台线程就会访问无效内存, 引发未定义行为(通常是程序崩溃).

            ```cpp
            void create_detached_worker() {
                int local_value = 10;
                // 错误! 线程访问了即将被销毁的局部变量的引用.
                std::thread t([&]() {
                    std::this_thread::sleep_for(std::chrono::seconds(1));
                    std::cout << local_value << std::endl; // 未定义行为!
                });
                t.detach();
            } // local_value在这里被销毁, 但线程可能还在后台运行.
            ```

        * 程序退出: 如果`main`函数执行完毕并退出, 所有被`detach`的线程都会被系统粗暴地终止, 无论它们是否完成了任务. 这可能导致文件损坏或资源泄露.

        因此, 只有当你能确保被分离的线程不会访问任何可能被销毁的外部资源, 并且它的提前终止不会造成问题时, 才应该使用`detach`. 在现代C++ (C++20)中, `std::jthread`的出现大大减少了需要手动调用`detach`或`join`的场景. `std::jthread`在其析构函数中会自动调用`join()`, 提供了更安全的默认行为.

3. `joinable()`

    `joinable()`函数返回一个布尔值, 用来检查`std::thread`对象是否可以被`join()`或`detach()`. 一个`std::thread`对象在以下情况下是`joinable`的:

    * 它代表一个正在执行的线程.
    * 它代表一个已经执行完毕但尚未被`join()`的线程.

    在默认构造, 被`move`后, 或已经被`join()`或`detach()`的`std::thread`对象上调用`joinable()`会返回`false`. 在调用`join()`或`detach()`之前检查`joinable()`是一个好习惯, 可以避免程序异常终止.

    ```cpp
    if (myThread.joinable()) {
        myThread.join();
    }
    ```

4. `get_id()`

    `get_id()`返回一个`std::thread::id`类型的对象, 代表线程的唯一标识符. 如果`std::thread`对象不代表任何线程 (例如默认构造的), `get_id()`会返回一个默认构造的`std::thread::id`对象, 该对象不表示任何特定线程.

### 向线程传递参数

向线程函数传递参数非常直接, 只需在构造`std::thread`对象时将参数附加在可调用对象之后即可. 注意: 参数默认以值传递的方式被复制到新线程的存储空间中. 如果需要引用传递, 必须使用`std::ref`或`std::cref`进行包装.

```cpp
#include <iostream>
#include <thread>
#include <string>
#include <functional> // for std::ref

void print_message(const std::string& message) {
    std::cout << "消息: " << message << std::endl;
}

void update_value(int& value) {
    value = 20;
}

int main() {
    // 值传递
    std::string msg = "你好, C++";
    std::thread t1(print_message, msg);
    t1.join();

    // 引用传递
    int val = 10;
    std::thread t2(update_value, std::ref(val));
    t2.join();
    std::cout << "更新后的值: " << val << std::endl; // 输出 20

    return 0;
}
```

### 移动语义

`std::thread`对象不可复制 (`non-copyable`), 但支持移动 (`movable`). 这意味着线程的所有权可以从一个`std::thread`对象转移到另一个. 这在需要将线程从一个函数返回或存储在容器中时非常有用.

```cpp
#include <iostream>
#include <thread>
#include <vector>

void worker() {
    std::cout << "工作线程执行." << std::endl;
}

std::thread create_thread() {
    return std::thread(worker);
}

int main() {
    std::thread t1(worker);
    std::thread t2 = std::move(t1); // t1不再代表线程, 所有权转移给t2

    // t1.join(); // 错误, t1不再joinable
    t2.join();

    // 从函数返回线程
    std::thread t3 = create_thread();
    t3.join();

    // 在容器中存储线程
    std::vector<std::thread> threads;
    threads.push_back(std::thread(worker));
    threads.push_back(std::thread(worker));

    for (auto& thread : threads) {
        thread.join();
    }

    return 0;
}
```

### 异常处理

线程中抛出的异常不能在创建线程的`try-catch`块中直接捕获, 因为线程的执行是独立的. 如果线程函数中的异常未被捕获, 程序会调用`std::terminate`终止.

一种常见的处理方式是在线程函数内部设置`try-catch`块, 并通过某种机制将异常信息传递回主线程. `std::exception_ptr`就是为此设计的.

```cpp
#include <iostream>
#include <thread>
#include <exception>
#include <stdexcept>

void risky_task(std::exception_ptr& eptr) {
    try {
        throw std::runtime_error("线程中发生错误!");
    } catch (...) {
        eptr = std::current_exception(); // 捕获异常并存入exception_ptr
    }
}

int main() {
    std::exception_ptr eptr = nullptr;
    std::thread t(risky_task, std::ref(eptr));
    t.join();

    if (eptr) {
        try {
            std::rethrow_exception(eptr); // 在主线程中重新抛出捕获的异常
        } catch (const std::exception& e) {
            std::cerr << "主线程捕获到异常: " << e.what() << std::endl;
        }
    }

    return 0;
}
```

更现代的方法: 使用`std::packaged_task`和`std::future`可以更简单地实现异常的传递, 因为`std::future::get()`会自动重新抛出在异步任务中发生的异常.

## `std::jthread`

`std::jthread`是C++20中引入的一个新线程类, 旨在成为`std::thread`的更安全, 更易用的替代品. 它的名称中的"j"代表"joining", 核心特性是在析构时自动加入(join)线程, 并引入了协作式中断机制. `std::jthread`同样在`<thread>`头文件中定义.

### 自动加入 (RAII)

这是`std::jthread`最显著的改进. `std::thread`对象在销毁时, 如果其管理的线程仍然是`joinable`的(即既没有`join()`也没有`detach()`), 程序会调用`std::terminate`异常终止. 这迫使程序员必须手动管理线程的生命周期. `std::jthread`通过实现RAII (Resource Acquisition Is Initialization)解决了这个问题. 当一个`std::jthread`对象离开作用域时, 它的析构函数会自动调用`join()`, 等待其管理的线程执行完毕.

对比`std::thread`和`std::jthread`:

```cpp
#include <iostream>
#include <thread>
#include <chrono>

void worker() {
    std::this_thread::sleep_for(std::chrono::seconds(1));
    std::cout << "工作完成." << std::endl;
}

void use_thread() {
    std::thread t(worker);
    // 如果忘记t.join()或t.detach(), 程序会在这里因t的销毁而终止.
}

void use_jthread() {
    std::jthread jt(worker);
    // 无需手动join. 当jt离开作用域时, 析构函数会自动调用join().
}

int main() {
    // use_thread(); // 会导致程序异常终止
    std::cout << "使用jthread:" << std::endl;
    use_jthread(); // 安全, 程序会等待1秒后输出 "工作完成."
    std::cout << "jthread演示结束." << std::endl;
    return 0;
}
```

### 协作式中断机制

`std::jthread`提供了一个标准的, 内置的协作式中断机制. 这使得一个线程可以安全地请求另一个线程停止执行, 而被请求的线程可以定期检查该请求并优雅地退出.

这个机制通过`std::stop_source`和`std::stop_token`实现:

  * `std::stop_source`: 拥有请求停止的能力.
  * `std::stop_token`: 线程用来检查是否被请求停止的凭证.

`std::jthread`内部管理了一个`stop_source`. 我们可以通过`get_stop_token()`获取其关联的`stop_token`.

```cpp
#include <iostream>
#include <thread>
#include <chrono>

// jthread会自动将一个stop_token作为第一个参数传递给可调用对象
void cancellable_worker(std::stop_token token) {
    int counter = 0;
    while (!token.stop_requested()) { // 检查是否被请求停止
        std::cout << "循环中... " << counter++ << std::endl;
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }
    std::cout << "已请求停止, 退出循环." << std::endl;
}

int main() {
    std::jthread jt(cancellable_worker);

    std::cout << "主线程休眠3秒." << std::endl;
    std::this_thread::sleep_for(std::chrono::seconds(3));

    std::cout << "主线程请求停止." << std::endl;
    jt.request_stop(); // 请求jthread停止

    // jt的析构函数会在这里被调用, 等待线程结束
    return 0;
}
```

在上面的例子中, `main`线程在等待3秒后调用`jt.request_stop()`. `cancellable_worker`线程在其循环中通过`token.stop_requested()`检测到这个请求, 从而干净地退出循环, 结束线程.

### `std::jthread` vs `std::thread`

| 特性 | `std::jthread` (C++20) | `std::thread` (C++11) |
| :--- | :--- | :--- |
| 析构行为 | 自动`join()`, 保证安全 | 调用`std::terminate`, 需要手动管理 |
| 中断机制 | 内置协作式中断 (`stop_token`) | 无内置机制, 需手动实现(如原子布尔值) |
| 分离 | 不支持`detach()` | 支持`detach()` |
| 适用性 | 现代C++的首选, 更安全, 更方便 | 用于需要`detach`的遗留场景或特定情况 |

结论: 在C++20及以上的项目中, `std::jthread`应该是创建和管理线程的默认选择. 它通过自动资源管理和标准化的中断机制, 极大地减少了多线程编程中常见的错误和复杂性.

## `std::mutex`

`std::mutex` (互斥量) 是C++标准库中的一个核心同步原语, 用于保护共享数据, 防止多个线程同时访问和修改, 从而避免数据竞争 (Data Race) 和其他并发问题. 它的工作方式像一把锁: 一个线程在访问共享数据前必须先获得这把锁. 一旦锁定, 其他任何试图获取该锁的线程都将被阻塞, 直到持有锁的线程释放它. 使用`std::mutex`需要包含`<mutex>`头文件.

### 核心成员函数

`std::mutex`本身提供了几个基本的成员函数来手动管理锁:

* `lock()`: 锁定互斥量. 如果互斥量当前已被其他线程锁定, 则调用此函数的线程将被阻塞, 直到锁被释放.
* `unlock()`: 解锁互斥量. 持有锁的线程必须调用此函数以释放锁, 允许其他等待的线程继续执行.
* `try_lock()`: 尝试锁定互斥量, 但不阻塞.
    * 如果成功获得锁, 它返回`true`.
    * 如果互斥量已被锁定, 它立即返回`false`, 线程可以继续执行其他任务, 而不是等待.

手动管理的风险:

直接使用`lock()`和`unlock()`是危险且不被推荐的. 如果在`lock()`和`unlock()`之间的代码抛出异常或提前返回, `unlock()`将不会被调用, 锁将永远不会被释放, 导致所有其他等待该锁的线程陷入永久阻塞, 这种情况被称为死锁 (Deadlock).

```cpp
#include <iostream>
#include <thread>
#include <mutex>

int shared_counter = 0;
std::mutex mtx; // 创建一个互斥量实例

void unsafe_increment() {
    for (int i = 0; i < 10000; ++i) {
        shared_counter++; // 数据竞争! 结果不可预测.
    }
}

void manual_lock_increment() {
    for (int i = 0; i < 10000; ++i) {
        mtx.lock();
        // 如果这里发生异常, unlock()将不会被调用, 造成死锁.
        shared_counter++;
        mtx.unlock();
    }
}
```

### RAII锁管理

为了解决手动管理的风险, C++标准库提供了基于RAII (Resource Acquisition Is Initialization)原则的锁管理类. 这些类在其构造函数中获取锁, 在析构函数中释放锁, 从而保证即使发生异常, 锁也总能被正确释放.

#### `std::lock_guard`

这是最简单, 最高效的RAII锁包装器. 它在构造时锁定给定的互斥量, 在销毁时 (离开作用域时) 自动解锁. `lock_guard`被锁定后不能手动解锁或移动. 适用场景: 当你需要在一个完整的作用域内 (例如一个函数或一个代码块) 锁定一个互斥量时, `std::lock_guard`是最佳选择.

```cpp
#include <iostream>
#include <thread>
#include <mutex>
#include <vector>

int counter = 0;
std::mutex counter_mutex;

void safe_increment() {
    for (int i = 0; i < 10000; ++i) {
        std::lock_guard<std::mutex> guard(counter_mutex); // 构造时自动加锁
        counter++;
    } // guard离开作用域, 析构函数自动解锁
}

int main() {
    std::thread t1(safe_increment);
    std::thread t2(safe_increment);

    t1.join();
    t2.join();

    std::cout << "最终计数器值: " << counter << std::endl; // 结果总是20000
    return 0;
}
```

#### `std::unique_lock`

`std::unique_lock`是功能更强大但也稍重一点的锁包装器. 它同样遵循RAII原则, 但提供了更大的灵活性:

* 可移动 (Movable): `unique_lock`的所有权可以转移.
* 延迟锁定: 可以在构造时不锁定, 之后再手动调用`lock()`.
* 手动解锁: 可以在其生命周期内随时调用`unlock()`提前释放锁.
* 与条件变量配合: 它是使用`std::condition_variable`的唯一选择.

适用场景:

* 需要提前解锁以减小锁的粒度, 提高并发性.
* 需要将锁的所有权从一个函数转移到另一个函数.
* 需要配合`std::condition_variable`进行线程通信.

```cpp
void flexible_lock_example() {
    std::unique_lock<std::mutex> lock(counter_mutex, std::defer_lock); // 创建时不加锁

    // ... 执行一些不需要锁的操作 ...

    lock.lock(); // 手动加锁
    counter++;
    lock.unlock(); // 提前解锁, 后续操作可以并发执行

    // ... 执行其他不需要锁的操作 ...
}
```

---

| 特性 | `std::lock_guard` | `std::unique_lock` |
| :--- | :--- | :--- |
| 设计目标 | 简单, 高效, 零开销 | 灵活, 功能强大 |
| RAII | 是 | 是 |
| 所有权 | 不可移动 | 可移动 |
| 手动解锁 | 不支持 | 支持 (`unlock()`) |
| 延迟锁定 | 不支持 | 支持 (`std::defer_lock`) |
| 适用场景 | 锁定完整作用域 | 复杂场景, 条件变量, 提前解锁 |

最佳实践: 始终优先使用RAII锁 (`std::lock_guard`或`std::unique_lock`) 而不是手动调用`lock()`和`unlock()`. 除非需要`std::unique_lock`的灵活性, 否则应选择更轻量的`std::lock_guard`.

## `std::atomic`

`std::atomic`是C++11中引入的一个模板类, 它能让一些基本类型的操作变成原子操作 (Atomic Operations). 原子操作是并发编程中的一个关键概念, 意为"不可分割的", 在多线程环境下, 一个原子操作一旦开始, 就会在不被任何其他线程中断的情况下执行完毕. `std::atomic`的主要目的是在多线程环境下, 对共享数据进行无锁 (lock-free)的, 线程安全的读写. 它通常被认为是比互斥锁 (`std::mutex`) 更轻量级的同步原语, 但仅适用于一些简单的操作 (如计数, 标志位设定等).

考虑一个简单的多线程计数器:

```cpp
int counter = 0;

void increment() {
    for (int i = 0; i < 10000; ++i) {
        counter++; // 非原子操作, 危险!
    }
}
```

`counter++`这个操作看起来只有一行, 但在底层它至少包含三个步骤:

1.  读取 (Read): 从内存中读取`counter`的当前值到寄存器.
2.  修改 (Modify): 在寄存器中将该值加1.
3.  写入 (Write): 将寄存器中的新值写回内存.

在多线程环境中, 两个线程可能同时执行完第一步 (读取了相同的值), 然后各自加1, 再写回内存. 这会导致一次增加操作被丢失, 最终结果会小于预期. 这就是典型的数据竞争 (race condition). 使用`std::mutex`可以解决这个问题, 但对于`counter++`这样简单的操作, 加锁和解锁的开销可能相对较大. `std::atomic`提供了一种更高效的解决方案.

我们可以用`std::atomic<T>`来包装一个基本类型`T`, 将其变为原子类型.

```cpp
#include <iostream>
#include <thread>
#include <vector>
#include <atomic>

std::atomic<int> atomic_counter(0); // 使用std::atomic包装int

void safe_atomic_increment() {
    for (int i = 0; i < 10000; ++i) {
        atomic_counter++; // 这是一个原子操作
    }
}

int main() {
    std::vector<std::thread> threads;
    for(int i = 0; i < 10; ++i) {
        threads.emplace_back(safe_atomic_increment);
    }

    for(auto& t : threads) {
        t.join();
    }

    // 结果总是 100000
    std::cout << "最终计数器值: " << atomic_counter << std::endl;
    return 0;
}
```

在上面的代码中, `atomic_counter++`保证是原子的. CPU会使用特殊的指令 (例如x86上的`lock inc`) 来确保 "读-改-写" 这三个步骤作为一个整体完成, 不会被其他线程打断.

### 常用操作

`std::atomic`模板重载了常用的运算符, 使其可以像普通变量一样使用.

* `atomic_var++`, `atomic_var--`: 原子自增/自减.
* `atomic_var += val`, `atomic_var -= val`: 原子加/减.
* `T val = atomic_var;`: 原子读取, 等价于`atomic_var.load()`.
* `atomic_var = val;`: 原子写入, 等价于`atomic_var.store(val)`.

它也提供了一些成员函数用于更复杂的操作:

* `store(value)`: 原子性地写入一个新值.
* `load()`: 原子性地读取当前值.
* `exchange(value)`: 原子性地写入一个新值, 并返回写入前的值.
* `compare_exchange_strong(expected, desired)` / `compare_exchange_weak(expected, desired)`: 这是最核心的CAS (Compare-And-Swap) 操作. 它比较当前值与`expected`是否相等, 如果相等, 就将当前值设为`desired`并返回`true`; 否则, 用当前值更新`expected`并返回`false`.

### 内存序

这是一个更高级但非常重要的概念. `std::atomic`的操作可以接受一个额外的`std::memory_order`参数, 用来告诉编译器和CPU在多大程度上可以重排指令. 这会影响代码的性能和线程间的可见性. 对于初学者, 使用默认的内存序 (`std::memory_order_seq_cst`) 是最安全的, 它提供了最强的顺序一致性保证, 确保所有线程都以相同的顺序看到所有原子操作的结果.

---

| 特性 | `std::mutex` | `std::atomic` |
| :--- | :--- | :--- |
| 用途 | 保护代码块 (临界区) | 保护对单个变量的访问 |
| 性能 | 开销较大 (可能涉及系统调用) | 开销较小 (通常是CPU指令) |
| 使用场景 | 保护复杂的数据结构或多个操作 | 简单的标志位, 计数器, 指针等 |
| 死锁风险 | 有 (忘记解锁, 加锁顺序错误) | 无 |

`std::atomic`是编写高性能并发代码的基石, 特别是在需要实现无锁数据结构时. 对于简单的共享变量修改, 它通常是比`std::mutex`更好的选择.

## `std::async`

`std::async`是C++11中引入的一个非常实用的工具, 它能让你以一种简单的方式异步地运行一个函数 (或其他可调用对象), 并且能轻松地获取其返回值或捕获其抛出的异常. 你可以把它看作是`std::thread`的一个更高级, 更易用的封装. 它将创建线程, 传递参数, 返回结果和处理异常等繁琐的工作打包在了一起. `std::async`的核心是与`std::future`配合使用.

### 如何工作

1.  启动任务: 你调用`std::async`并传入一个你想要异步执行的函数和它的参数.
2.  返回`std::future`: `std::async`会立即返回一个`std::future`对象. 这个`future`对象就像一个"期货"或"提货单", 它承诺在未来的某个时间点会包含那个异步函数的返回值.
3.  获取结果: 当你需要异步函数的结果时, 你可以在`std::future`对象上调用`.get()`方法.
      * 如果此时异步任务已经执行完毕, `.get()`会立即返回结果.
      * 如果异步任务还在执行中, 调用`.get()`的线程会被阻塞, 直到任务完成并返回结果.
      * 如果异步任务在执行过程中抛出了异常, 这个异常会被`std::future`捕获, 并在你调用`.get()`时被重新抛出.

示例:

假设我们有一个耗时的计算任务.

```cpp
#include <iostream>
#include <future>   // 必须包含 <future>
#include <chrono>
#include <thread>

// 一个耗时的计算函数, 它返回一个值
int heavy_computation(int input) {
    std::cout << "开始计算, 输入值为: " << input << std::endl;
    std::this_thread::sleep_for(std::chrono::seconds(2)); // 模拟耗时操作
    if (input < 0) {
        throw std::invalid_argument("输入值不能为负数!");
    }
    return input * 10;
}

int main() {
    std::cout << "主线程: 准备启动异步任务." << std::endl;

    // 启动异步任务, future1 会在未来的某个时刻包含 heavy_computation(10) 的结果
    std::future<int> future1 = std::async(heavy_computation, 10);

    // 启动另一个会抛出异常的异步任务
    std::future<int> future2 = std::async(heavy_computation, -5);

    std::cout << "主线程: 异步任务已启动, 我可以先做点别的事情." << std::endl;
    // ... 在这里主线程可以并行地做其他工作 ...
    std::this_thread::sleep_for(std::chrono::seconds(1));
    std::cout << "主线程: 其他事情做完了, 现在需要第一个任务的结果." << std::endl;

    try {
        int result1 = future1.get(); // 获取结果, 如果没算完就会等待
        std::cout << "第一个任务的结果是: " << result1 << std::endl;

        std::cout << "主线程: 准备获取第二个任务的结果." << std::endl;
        int result2 = future2.get(); // 这行会重新抛出任务中的异常
        std::cout << "第二个任务的结果是: " << result2 << std::endl; // 这行不会被执行

    } catch (const std::exception& e) {
        std::cerr << "捕获到异步任务中的异常: " << e.what() << std::endl;
    }

    return 0;
}
```

### 启动策略

`std::async`可以接受一个额外的启动策略参数, 来控制任务如何被执行:

  * `std::launch::async`: 强制在一个新线程中异步执行任务. 这是我们通常期望的行为.
  * `std::launch::deferred`: 延迟执行. 任务不会立即开始, 而是在你第一次对它返回的`std::future`调用`.get()`或`.wait()`时, 才会在当前调用线程中同步执行.
  * `std::launch::async | std::launch::deferred` (默认值): 允许实现自行决定. 它可能会创建一个新线程 (像`async`), 也可能延迟执行 (像`deferred`), 具体取决于系统负载和可用资源. 这可能导致不确定性, 因此显式指定策略通常是更好的做法.

示例: `auto fut = std::async(std::launch::async, my_func);`

### 相比`std::thread`的优势

1.  易于获取返回值: `std::thread`本身不直接支持返回值的传递, 你需要自己通过指针, 引用或`std::promise`等复杂的机制来处理. `std::async`和`std::future`的组合完美地解决了这个问题.
2.  简化的异常处理: `std::thread`中如果发生异常而没有在线程内部捕获, 程序会直接调用`std::terminate`崩溃. `std::async`会自动捕获异常并存储在`std::future`中, 允许你在主线程的`try-catch`块中安全地处理它.
3.  可能避免创建线程: 使用默认或`deferred`策略时, 系统可能会优化掉不必要的线程创建, 减少资源开销.
4.  自动管理线程: `std::async`返回的`future`在析构时会自动等待异步任务完成 (如果它正在运行), 这可以防止因忘记`join()`而导致程序异常终止的问题, 代码更安全.

总之, `std::async`是一个更高层次的并发工具, 当你关心的是任务的异步执行和其结果时, 它通常是比手动管理`std::thread`更简单, 更安全, 也更推荐的选择.

## `std::future`

`std::future`是C++11并发库中的一个核心组件, 它的名字非常形象. 你可以把它理解为一张"未来的提货单"或一个"结果的占位符". 它代表一个可能当前尚未就绪的异步操作的结果. 当你启动一个异步任务时 (例如通过`std::async`), 你不能立即得到结果, 但你会得到一个`std::future`对象. 这个对象就是你将来用以获取结果或等待任务完成的凭证.

### 核心作用

1.  从异步任务中获取返回值: 这是`std::future`最主要的功能. 它提供了一个通道, 让你可以从一个线程 (调用者) 安全地获取另一个线程 (执行者) 的计算结果.
2.  捕获异步任务的异常: 如果异步任务在执行过程中抛出了异常, 这个异常会被捕获并存储在`std::future`对象中. 当你在主线程对`future`调用`.get()`时, 这个被存储的异常会被重新抛出, 使得你可以在主线程的`try-catch`块中处理它.
3.  线程间的同步: `std::future`提供了一种简单的等待机制. 调用者线程可以等待, 直到异步任务完成.

### 如何获得

你通常不直接创建`std::future`, 而是通过以下三种方式之一获得它:

1.  `std::async`: 这是最简单直接的方式. 调用`std::async`会返回一个与异步任务关联的`std::future`.
2.  `std::packaged_task`: 这是一个将"任务(函数)"和"未来的结果(future)"打包在一起的模板类. 你可以创建一个`packaged_task`, 从中获取`future`, 然后把这个任务交给一个`std::thread`去执行.
3.  `std::promise`: `promise` (承诺) 和`future` (未来) 是一对. `promise`用于在一个线程中设置一个值或异常, 而与它关联的`future`则可以在另一个线程中获取这个值或异常. 它们之间通过一个共享状态进行通信.

### 主要成员函数

假设你有一个`std::future<T> fut;`

  * `fut.get()`: 这是最核心的函数.

      * 它会等待异步任务完成, 然后返回其结果 (类型为`T`).
      * 如果任务抛出异常, `.get()`会重新抛出该异常.
      * 注意: `get()`只能被调用一次. 一旦你取走了结果, 这张"提货单"就失效了. 再次调用`get()`会导致程序错误.

  * `fut.wait()`:

      * 阻塞当前线程, 直到异步任务完成.
      * 它不返回任何值. 你可以在`wait()`之后, 再安全地调用`get()`来获取结果 (因为此时结果肯定已经就绪).

  * `fut.wait_for(duration)`:

      * 等待指定的一段时间 (`duration`).
      * 它会返回一个枚举值 (`std::future_status`) 来告诉你等待的结果:
          * `std::future_status::ready`: 任务已完成, 结果已就绪.
          * `std::future_status::timeout`: 等待超时, 任务仍未完成.
          * `std::future_status::deferred`: 任务是延迟执行的 (`std::async`的`deferred`策略), 需要调用`get()`或`wait()`来启动它.

  * `fut.valid()`:

      * 返回一个布尔值, 检查`future`对象是否与一个共享状态相关联.
      * 刚从`std::async`等函数返回的`future`是有效的 (`valid() == true`).
      * 调用`get()`之后, `future`会变为无效 (`valid() == false`).
      * 移动(move)一个`future`后, 原`future`也会变为无效.

示例 (使用`std::async`):

```cpp
#include <iostream>
#include <future>
#include <thread>
#include <chrono>

int calculate_the_answer() {
    std::this_thread::sleep_for(std::chrono::seconds(2)); // 模拟耗时
    return 42;
}

int main() {
    // 1. 启动异步任务, 获得代表未来的 "提货单"
    std::future<int> the_answer_future = std::async(calculate_the_answer);

    std::cout << "正在计算答案... 我可以先做点别的事." << std::endl;

    // 2. 检查 "提货单" 状态, 等待1秒
    std::future_status status;
    do {
        status = the_answer_future.wait_for(std::chrono::seconds(1));
        if (status == std::future_status::timeout) {
            std::cout << "还在算..." << std::endl;
        }
    } while (status != std::future_status::ready);

    std::cout << "算完了!" << std::endl;

    // 3. 使用 "提货单" 获取最终结果
    // get() 会等待任务完成 (虽然我们已经用wait_for确认它完成了)
    int result = the_answer_future.get();

    std::cout << "宇宙的终极答案是: " << result << std::endl;

    // 4. "提货单" 已经使用过了, 现在是无效的
    if (!the_answer_future.valid()) {
        std::cout << "future 现在是无效的, 因为 get() 已经被调用." << std::endl;
    }

    return 0;
}
```

总之, `std::future`是现代C++并发编程中一个极其有用的工具, 它极大地简化了线程间传递返回值和异常的复杂度, 让异步代码写起来更安全, 更清晰.
