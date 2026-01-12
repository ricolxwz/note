---
title: PY总结
comments: false
---

## 多进程

在Python里面, 可以使用多种方式创建子进程. 当我们执行`.py`文件的时候, 我们创建了一个进程, 在这个文件中, 我们通过一些手段又创建了一些进程, 我们称这些进程为子进程. 

子进程拷贝/继承了父进程的环境, 但是无法直接访问父进程的变量, 函数或者其他资源, 子进程的变量和父进程的变量是独立的. 如果子进程要和父进程共享数据, 可以使用进程之间的通信机制, 比如说, 管道, 队列, 共享内存等等. 子进程有子集独立的地址空间. 

Python中创建子进程的模块一共有三个: `os`, `subprocess`和`multiprocessing`. 

### `os`模块

`os`模块的`fork()`函数适用于Unix系系统的低级进程创建, 直接调用系统的`fork()`接口, 适用于简单的子进程创建, 没有高级复杂的进程间通信/同步功能. 调用`os.fork()`函数, 会将当前进程(父进程)复制一份(子进程), 然后, 分别执行后面的代码. 调用`os.fork()`的返回值对于父进程来说是子进程的pid, 对于子进程来说是0. 

```py title="输入"
import os

print('Process (%s) start...' % os.getpid())
pid = os.fork()
if pid == 0:
    print('I am child process (%s) and my parent is %s.' % (os.getpid(), os.getppid()))
else:
    print('I (%s) just created a child process (%s).' % (os.getpid(), pid))
```

```sh  title="输出"
$ python main.py
Process (876) start...
I (876) just created a child process (877).
I am child process (877) and my parent is 876.
```

### `subprocess`模块

`subprocess`模块用于启动和管理命令行子进程, 能够和外部命令行子进程通过`communicate`实现进程之间的通信, 它提供了发出`stdin`, 接受`stdout`, `stderr`的共嗯那个, 其中的`Popen()`函数用于返回一个子进程对象. 

```py  title="输入"
import subprocess

print('$ nslookup')
p = subprocess.Popen(['nslookup'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
output, err = p.communicate(b'set q=mx\npython.org\nexit\n')
print(output.decode('utf-8'))
print('Exit code:', p.returncode)
```

```sh  title="输出"
$ nslookup
Server:     192.168.19.4
Address:    192.168.19.4#53

Non-authoritative answer:
python.org  mail exchanger = 50 mail.python.org.

Authoritative answers can be found from:
mail.python.org internet address = 82.94.164.166
mail.python.org has AAAA address 2001:888:2000:d::a6


Exit code: 0
```

`[subprocess_instance].communicate()`方法是一种父进程和子进程间的进程间通信方式, 它是阻塞的, 意味着父进程会等待子进程完成之后才继续执行. 通信是一次性的, 即父进程发送数据到子进程, 然后读取子进程的输出, 不能持续进行双向通信, 适用于简单的父进程和子进程之间的进程间通信.

### `multiprocessing`模块

`multiprocessing`模块适用于并行处理和多进程编程, 提供了丰富的进程间通信和同步机制, 支持跨平台, 其中的`Process`类能够用于创建子进程对象. 

```py  title="输入"
from multiprocessing import Process
import os

# 子进程要执行的代码
def run_proc(name):
    print('Run child process %s (%s)...' % (name, os.getpid()))

if __name__=='__main__':
    print('Parent process %s.' % os.getpid())
    p = Process(target=run_proc, args=('test',))
    print('Child process will start.')
    p.start()
    p.join()
    print('Child process end.')
```

```sh  title="输出"
Parent process 928.
Child process will start.
Run child process test (929)...
Process end.
```

`p.join()`用于阻塞主进程, 直到子进程执行完毕. 

```py   title="输入"
import multiprocessing
import time

def worker(number):
    print(f"Worker {number} started")
    time.sleep(2)
    print(f"Worker {number} finished")

if __name__ == "__main__":
    processes = []
    for i in range(4):  # 创建4个子进程
        process = multiprocessing.Process(target=worker, args=(i,))
        processes.append(process)
        process.start()

    for process in processes:
        process.join()  # 等待所有子进程完成

    print("All workers completed")
```

```sh   title="输出"
Worker 0 started
Worker 1 started
Worker 3 started
Worker 2 started
Worker 0 finished
Worker 1 finished
Worker 3 finished
Worker 2 finished
All workers completed
```

上述的例子中, 创建了4个子进程, 每个子进程执行worker函数, 如果任务都在主进程中顺序执行, 总共需要8秒完成. 而使用多进程同时执行4个任务, 只需要大约2秒的即可完成所有任务. process.join()函数用于阻塞当前的主进程, 当子进程全部执行完之后, 才打印"All workers completed". 上述代码可以优化为使用进程池. 

#### 进程池

进程池由`multiprocessing`模块的`Pool`类提供支持. 

```py title="输入"
from multiprocessing import Pool
import os, time, random

def long_time_task(name):
    print('Run task %s (%s)...' % (name, os.getpid()))
    start = time.time()
    time.sleep(random.random() * 3)
    end = time.time()
    print('Task %s runs %0.2f seconds.' % (name, (end - start)))

if __name__=='__main__':
    print('Parent process %s.' % os.getpid())
    p = Pool(4)
    for i in range(5):
        p.apply_async(long_time_task, args=(i,))
    print('Waiting for all subprocesses done...')
    p.close()
    p.join()
    print('All subprocesses done.')
```

```sh title="输出"
Parent process 669.
Waiting for all subprocesses done...
Run task 0 (671)...
Run task 1 (672)...
Run task 2 (673)...
Run task 3 (674)...
Task 2 runs 0.14 seconds.
Run task 4 (673)...
Task 1 runs 0.27 seconds.
Task 3 runs 0.86 seconds.
Task 0 runs 1.41 seconds.
Task 4 runs 1.91 seconds.
All subprocesses done.
```

[pool_instance].apply_async()用于提交任务, 任务是否立即被执行取决于当前进程池中工人的数量, 即进程池对象被创建时的参数Pool([worker_number]), 默认的大小是当前电脑CPU的核心数量. 如在上述的例子中, 我们定义了进程池中工人的数量是4个, 那么最多同时只能执行4个任务, 任务0, 1, 2, 3是立即执行的, 而任务4是等待前面某个任务执行完成之后才执行. 如果没有明确工人的数量, 那么默认是CPU的核心数量, 比如说8核处理器, 那么至少提交9个任务才会看到上面的等待效果. `p.close`的作用是关闭线程池的入口, 防止新的任务被继续提交. 

| 方法 | 作用 | 核心说明 |
| :--- | :--- | :--- |
| `p.apply_async()` | 非阻塞地向进程池分发任务 | 立即返回一个 Result 对象, 主进程继续向下执行. |
| `p.close()` | 停止接收新任务 | 关闭池入口. 已在执行的任务会继续完成, 但不能再添加新任务. |
| `p.terminate()` | 立即终止所有进程 | 不管任务是否完成, 强制杀死所有子进程. |
| `p.join()` | 阻塞主进程 | 等待所有子进程退出. 调用前必须先执行 `close()` 或 `terminate()`. |

#### 进程间通信

队列式进程间通信由`multiprocessing`模块的`Queue`类提供支持, 此外还有管道式进程间通信. 

```py  title="输入"
from multiprocessing import Process, Queue
import os, time, random

# 写数据进程执行的代码:
def write(q):
    print('Process to write: %s' % os.getpid())
    for value in ['A', 'B', 'C']:
        print('Put %s to queue...' % value)
        q.put(value)
        time.sleep(random.random())

# 读数据进程执行的代码:
def read(q):
    print('Process to read: %s' % os.getpid())
    while True:
        value = q.get(True)
        print('Get %s from queue.' % value)

if __name__=='__main__':
    # 父进程创建Queue, 并传给各个子进程: 
    q = Queue()
    pw = Process(target=write, args=(q,))
    pr = Process(target=read, args=(q,))
    # 启动子进程pw, 写入:
    pw.start()
    # 启动子进程pr, 读取:
    pr.start()
    # 等待pw结束:
    pw.join()
    # pr进程里是死循环, 无法等待其结束, 只能强行终止:
    pr.terminate()
```

```sh  title="输出"
Process to write: 50563
Put A to queue...
Process to read: 50564
Get A from queue.
Put B to queue...
Get B from queue.
Put C to queue...
Get C from queue.
```

#### 进程锁

进程锁主要依靠`multiprocessing`模块中的`Lock`类创建的锁对象来解决.

```py title="输入"
import multiprocessing
import time

# 定义一个函数, 用于多个进程执行的任务
def worker(lock, shared_resource, index):
    with lock:
        print(f'Process {index} is accessing the shared resource...')
        shared_resource.value += 1
        time.sleep(1)
        print(f'Process {index} done. Shared resource value: {shared_resource.value}')

if __name__ == '__main__':
    lock = multiprocessing.Lock()
    shared_resource = multiprocessing.Value('i', 0)  # 定义一个共享整数资源, 初始值为0

    processes = []
    for i in range(5):
        p = multiprocessing.Process(target=worker, args=(lock, shared_resource, i))
        processes.append(p)
        p.start()

    for p in processes:
        p.join()

    print('All processes are done. Final value of shared resource:', shared_resource.value)
```

```sh  title="输出"
Process 0 is accessing the shared resource...
Process 0 done. Shared resource value: 1
Process 3 is accessing the shared resource...
Process 3 done. Shared resource value: 2
Process 1 is accessing the shared resource...
Process 1 done. Shared resource value: 3
Process 2 is accessing the shared resource...
Process 2 done. Shared resource value: 4
Process 4 is accessing the shared resource...
Process 4 done. Shared resource value: 5
All processes are done. Final value of shared resource: 5
```

## 多线程

进程是由若干线程组成的, 一个进程至少有一个进程. 线程是操作系统直接支持的执行最小单元. 由于任何进程默认都会启动一个线程, 我们将该线程称为主线程, 其他由主线程创造出来的线程称为子线程. Python中创建线程的模块一共由两个, `_thread`和`threading`, `_thread`是低级模块, `threading`是高级模块, 对`_thread`进行了封装, 提供了一些更加简单的接口, 一般情况下, 只需要使用`threading`模块. 

```py  title="输入"
import time, threading

# 新线程执行的代码:
def loop():
    print('thread %s is running...' % threading.current_thread().name)
    n = 0
    while n < 5:
        n = n + 1
        print('thread %s >>> %s' % (threading.current_thread().name, n))
        time.sleep(1)
    print('thread %s ended.' % threading.current_thread().name)

print('thread %s is running...' % threading.current_thread().name)
t = threading.Thread(target=loop, name='LoopThread')
t.start()
t.join()
print('thread %s ended.' % threading.current_thread().name)
```

```sh  title="输出"
thread MainThread is running...
thread LoopThread is running...
thread LoopThread >>> 1
thread LoopThread >>> 2
thread LoopThread >>> 3
thread LoopThread >>> 4
thread LoopThread >>> 5
thread LoopThread ended.
thread MainThread ended.
```

`threading`模块的`current_thread()`函数, 用于返回当前线程的实例, 我们可以访问这个实例的`name`属性来查看它的名字, 子线程的名字是在创建的时候指定的, 主线程的名字为`MainThread`. 如果子线程没有起名字, 那么Python就会自动给线程命名为`Thread-1`, `Thread-2`, ....

### 线程无法并行

由于GIL锁的存在, Python的多线程虽然是真正的多线程, 但是在CPython解释器执行代码的时候, 多线程其实还是交替执行的, 也就是说没有并行执行, 只能在一个CPU核心上跑. 所以说在计算密集型任务中, 多线程的表现甚至还不如单线程, 因为有额外的线程切换的开销. 但是在IO密集型任务中, IO操作通常会导致线程阻塞, 在这种情况下, 阻塞线程将不占用CPU, GIL锁将释放给其他的线程, 这种情况下, 多线程的优势就比较明显. 即: "线程可以并发但不能并行, 进程既可以并发, 又可以并行". 

### 线程的局部变量

在默认状态下, 同一个进程下的线程之间是可以互相访问, 修改数据的. 如果一个线程想要有自己的一份独立数据, 不希望其他线程访问, 就可以使用`threading`模块提供的`ThreadLocal`对象(需要在主线程中定义), 可以由`threading.local()`函数创建.

```py  title="输入"
import threading

# 创建全局ThreadLocal对象:
local_school = threading.local()

def process_student():
    # 获取当前线程关联的student:
    std = local_school.student
    print('Hello, %s (in %s)' % (std, threading.current_thread().name))

def process_thread(name):
    # 绑定ThreadLocal的student:
    local_school.student = name
    process_student()

t1 = threading.Thread(target= process_thread, args=('Alice',), name='Thread-A')
t2 = threading.Thread(target= process_thread, args=('Bob',), name='Thread-B')
t1.start()
t2.start()
t1.join()
t2.join()
```

执行: 

```sh   title="输出"
Hello, Alice (in Thread-A)
Hello, Bob (in Thread-B)
```

全局变量`local_school`就是一个`ThreadLocal`对象, 每个子线程都可以读写它自己的`student`属性, 相互之间没有影响. 可以把`local_school`堪称全局变量, 但是每个属性如`local_school.student`都是线程的局部变量, 可以任意读写而互不干扰.

### 线程锁

```py title="输入"
import threading
import time

# 工作线程函数
def worker(index):
    global shared_resource
    with lock:
        print(f'Thread {index} is accessing the shared resource...')
        shared_resource += 1
        time.sleep(1)
        print(f'Thread {index} done. Shared resource value: {shared_resource}')

if __name__ == '__main__':
    lock = threading.Lock()
    shared_resource = 0

    threads = []
    for i in range(5):
        t = threading.Thread(target=worker, args=(i,))
        threads.append(t)
        t.start()

    for t in threads:
        t.join()

    print('All threads are done. Final value of shared resource:', shared_resource)
```

```sh title="输出"
Thread 0 is accessing the shared resource...
Thread 0 done. Shared resource value: 1
Thread 1 is accessing the shared resource...
Thread 1 done. Shared resource value: 2
Thread 2 is accessing the shared resource...
Thread 2 done. Shared resource value: 3
Thread 3 is accessing the shared resource...
Thread 3 done. Shared resource value: 4
Thread 4 is accessing the shared resource...
Thread 4 done. Shared resource value: 5
All threads are done. Final value of shared resource: 5
```

## 协程

在传统线程的执行过程中, 函数都是顺序执行的. 而协程, Coroutine, 则不同, 在执行过程中, 其函数内部可以产生中断, 转而执行别的函数, 在适当的时候再返回来接着执行. 所以说, 这是一种并发执行, 和多线程差不多, 多线程也是并发执行, 而不是并行执行(由于GIL锁的存在).

```py title="输入"
import asyncio
import time

async def boil_water():
    print("开始烧水...")
    # await 表示: “我要等 2 秒, 这期间 CPU 可以去干别的任务”
    await asyncio.sleep(2) 
    print("水烧开了!")

async def cut_vegetables():
    print("开始切菜...")
    await asyncio.sleep(1)
    print("菜切好了!")

async def main():
    start = time.time()
    # 同时启动两个任务
    await asyncio.gather(boil_water(), cut_vegetables())
    print(f"总耗时: {time.time() - start:.2f} 秒")

asyncio.run(main())
# 输出: 总耗时 2.00 秒 (两个任务在“重叠”执行)
```

```sh title="输出"
开始烧水...
开始切菜...
菜切好了!
水烧开了!
总耗时: 2.00 秒
```
