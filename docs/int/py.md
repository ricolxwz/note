---
title: PY总结
comments: false
---

## 多进程


在Python里面, 可以使用多种方式创建子进程. 当我们执行`.py`文件的时候, 我们创建了一个进程, 在这个文件中, 我们通过一些手段又创建了一些进程, 我们称这些进程为子进程. 

子进程拷贝/继承了父进程的环境, 但是无法直接访问父进程的变量, 函数或者其他资源, 子进程的变量和父进程的变量是独立的. 如果子进程要和父进程共享数据, 可以使用进程之间的通信机制, 比如说, 管道, 队列, 共享内存等等. 子进程有子集独立的地址空间. 

### 创建子进程

Python中创建子进程的模块一共有三个: `os`, `subprocess`和`multiprocessing`. 

#### `os`模块

`os`模块的`fork()`函数适用于Unix系系统的低级进程创建, 直接调用系统的`fork()`接口, 适用于简单的子进程创建, 没有高级复杂的进程间通信/同步功能. 调用`os.fork()`函数, 会将当前进程(父进程)复制一份(子进程), 然后, 分别执行后面的代码. 调用`os.fork()`的返回值对于父进程来说是子进程的pid, 对于子进程来说是0. 

```py
import os

print('Process (%s) start...' % os.getpid())
pid = os.fork()
if pid == 0:
    print('I am child process (%s) and my parent is %s.' % (os.getpid(), os.getppid()))
else:
    print('I (%s) just created a child process (%s).' % (os.getpid(), pid))
```

```sh
$ python main.py
Process (876) start...
I (876) just created a child process (877).
I am child process (877) and my parent is 876.
```

#### `subprocess`模块
