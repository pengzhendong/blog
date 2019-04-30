---
title: Linux fork 函数和 exec 函数族的使用
date: 2015-09-15 20:52:13
updated: 2015-09-15 21:47:43
tags: Linux
---

## 前言

接触 Linux 已经有几个月了，以前在网上看各路大神均表示 Windows 是最烂的开发平台，我总是不以为然，但是经过这段时间琢磨，确实觉得 Linux 开发给我带来不少的便利。下面总结一下学习 Linux 多进程遇到的两个函数： fork() 和 exec() 函数族。

<!-- more -->

## fork()

   根据百度百科可以知道 fork 函数将运行着的程序分成2个（几乎）完全一样的进程，每个进程都启动一个从代码的同一位置开始执行的线程。所以如果成功对 fork 函数一次则返回两个值，子进程返回0，父进程返回子进程标记；否则，出错返回-1。

   例如：我们通过 while 条件来 fork 四个子进程，这四个进程完全由第一个进程创建。即这四个新的进程他们是兄弟关系，只是出生的时间不一样。

``` c
#include <stdio.h>
#include <unistd.h>
int main()
{

    int ppid = getpid();
    printf("我是父进程,我的pid是 %d ... 我要创建四个新的进程!\n", ppid);
    
    int count = 0;
    
    while (count < 4) {
    
        int fpid = fork();
        count++;
    
        if (fpid > 0) { //fork() 返回值大于0为父进程,返回值表示子进程的pid
        
            printf("我是父进程, 我是 %d 的父亲.\n", fpid);
        
        } else if (fpid == 0) { //fork() 返回值等于0为子进程
        
            int pid = getpid();
            printf("我是第 %d 个新进程, 我的pid是 %d, 我的父亲是 %d\n", count, pid, ppid);
            return -1;  //我们这里是用父进程创建子进程,而不想让子进程也创建子进程,所以return
        
        } else {
        
            printf("Error in fork!");
        
        }
    }
    
    return 0;
}	
```

上面的代码执行后的结果为：

``` bash
$ gcc ./concurrent.c -o ./concurrent
$ ./concurrent	
我是父进程,我的pid是 37515 ... 我要创建四个新的进程!
我是父进程, 我是 37516 的父亲.
我是父进程, 我是 37517 的父亲.
我是第 1 个新进程, 我的pid是 37516, 我的父亲是 37515
我是第 2 个新进程, 我的pid是 37517, 我的父亲是 37515
我是父进程, 我是 37518 的父亲.
我是父进程, 我是 37519 的父亲.
我是第 3 个新进程, 我的pid是 37518, 我的父亲是 37515
我是第 4 个新进程, 我的pid是 37519, 我的父亲是 37515
```

如果把这张图看成是以父进程为根节点的二叉树的话，那么所有叶子节点就是最终的进程个数，父进程不断调用 fork 函数，最终创建了四个新的进程。

## exec() 函数族

有 fork 函数我们知道 fork 出来的进程几乎是完全一样的，这感觉并没有什么用，所以我们想着使用这个新的进程去干点大事，例如运行一个别的程序 A ，一旦系统调用 exec() 函数族的函数，那么当前进程（也就是和父进程一样的进程）就死掉了，不再执行 fork() 后面的代码，即这个创建出来的进程就被进程 A 给替换了，系统重新分配资源，只留下进程号pid。
先看一个例子，然后我们再说 exec() 函数族里面各个函数的区别：

``` c
#include <stdio.h>
#include <unistd.h>
int main(int argc, char *argv[])
{
    int pid = fork();
    
    if (pid > 0) {
    
        printf("我是父进程.........\n");
    
    } else if (pid == 0) {
    
        if (argc < 3) {
        
            printf("参数太少!\n");
            return -1;
        
        }
        printf("我是新进程, 我要执行 %s....\n", argv[2]);
    
        char * const *argvs = &argv[2];
        execvp(argv[1], argvs);
        printf("看看你能不能打印这句话!");
    
    } else {
    
        printf("Error in fork!");
    
    }
    
    return 0;
}
```


上面代码创建了一个子进程，然后子进程通过系统调用去执行了一个新的程序，就直接执行刚刚那个程序吧！

``` bash
$ gcc ./exer2.c -o ./exer2
$ ./exer2 ./concurrent ./concurrent
我是父进程.........
我是新进程, 我要执行 ./concurrent....
我是父进程,我的pid是 37790 ... 我要创建四个新的进程!
我是父进程, 我是 37795 的父亲.
我是父进程, 我是 37796 的父亲.
我是第 1 个新进程, 我的pid是 37795, 我的父亲是 37790
我是第 2 个新进程, 我的pid是 37796, 我的父亲是 37790
我是父进程, 我是 37797 的父亲.
我是第 3 个新进程, 我的pid是 37797, 我的父亲是 37790
我是父进程, 我是 37798 的父亲.
我是第 4 个新进程, 我的pid是 37798, 我的父亲是 37790
```

恩，很明显 **printf("看看你能不能打印这句话!");** 这段代码并不能执行，因为调用 exec() 函数族之后，和父进程一样的子进程就被杀死了~

现在我们来讨论一下 exec() 函数族里的函数有什么区别，在这之前想先提一下环境变量这个东西，要是想在命令行里面直接通过输入程序的名字来调用一个程序，那么我们就要把这个程序的绝对路径加到环境变量里面去，就是你直接用这个程序的时候不用输入再绝对路径，你只要输入程序的名字，系统就会自动去环境变量里面找他的绝对路径：

exec 家族一共有六个函数，分别是：

1. int execl(const char *path, const char *arg, ......);

2. int execle(const char *path, const char *arg, ...... , char * const envp[]);

3. int execv(const char *path, char *const argv[]);

4. int execve(const char *filename, char *const argv[], char *const envp[]);

5. int execvp(const char *file, char * const argv[]);

6. int execlp(const char *file, const char *arg, ......);


* L:参数传递为逐个列举方式: execl  execle  execlp
* V:参数传递为构造指针数组方式: execv  execve  execvp
* E:可传递新进程环境变量: execle  execve
* P:可执行文件查找方式为文件名: execlp  execvp

前四个函数的查找方式都是完整的文件目录路径，而最后两个函数 (以p结尾的函数) 可以只给出文件名，系统就会自动从环境变量 **$PATH** 所指出的路径中进行查找。

