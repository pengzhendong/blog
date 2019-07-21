---
title: 递归
date: 2016-09-14 18:51:48
updated: 2016-09-14 20:33:00
tags: Algorithms
mathjax: true
---

## 前言

难得有点空闲时间总结一下这段时间刷过的算法题，就从递归开始。

<!-- more -->

## 递归

> 递归函数是一种可以调用自身的函数，每次成功调用都使得输入变得更加精细。

### 基本递归

`n! = n * (n - 1) * (n - 2) * ... * 2 * 1` 

数学中的阶乘就是一个可以使用递归的很好的例子，如果不使用递归，我们也能通过 while 循环来依次乘以小于 n 的数。如果使用递归，我们就可以将 n! 定义为 `n * (n - 1)!`，将问题的规模缩小，直到 n = 1。

$$
F(n) =
\begin{cases}
1 & \text{$n$  = 0、1} \\\
nF(n - 1) & \text{$n$ > 1}  \\\
\end{cases}
$$

``` C++
#include <iostream>
using namespace std;

unsigned long long F(int n) {
    if (n == 1 || n == 0) return 1;
    else return n * F(n - 1);
}

int main() {
    unsigned long long result = F(65);
    cout << result << endl;
    return 0;
}
```

递归过程包括两个阶段: 递推和回归。

#### 递推
 在递推阶段，每一个递归调用通过进一步调用自己来缩小问题规模，当满足终止条件时，即问题规模已不能再缩小时，递推结束。例如当 n = 1 或者 n = 0 时，它们的阶乘就是 1，此时函数只要返回 1 就行。递归函数必须拥有至少一个终止条件，否则会陷入死循环。

#### 回归

递推结束后，处理过程就会进入回归阶段，函数以逆序的方式回归，直到最初调用的函数为止。当调用 $ F(n) $ 时，会在栈中分配一块空间来保存与这个调用先关的信息，称为活跃记录。因为递推阶段结束后还有回归阶段，所以在终止条件之前调用了几次函数本身就会生成几个活跃记录，在回归阶段的时候才逐渐将栈中的活跃记录销毁(后建先销)，因此会花费大量空间和时间来生成销毁活跃记录。这个问题在尾递归中可能得到解决。

$$
F(4) = (4 × (3 × (2 × 1)))
$$

### 尾递归

> 如果一个函数中所有递归形式的调用都出现在函数的末尾，我们称这个递归函数是尾递归的。

就是说整个递归过程只有递推阶段，推到最后就能直接得到结果不用再回归。所以从理论上来说不需要保留原来的活跃记录，如果能覆盖当前的活跃记录而不是在栈中去创建一个新的，这就是尾递归的优化。但是，这是编译器的工作，它能优化就能提高效率；它不优化，尾递归就并没有什么卵用。 
C 语言和 C++ 就有尾递归优化，Java 和 Python 就没有， 听说它们不做尾递归优化是为了抛出异常时有完整的 stack trace 。

根据尾递归的定义可以想到应该在调用递归前先计算一下部分结果，然后把它作为第二个参数传给函数，部分结果初始化为1。

$$
F(n, a) =
\begin{cases}
a & \text{$n$  = 0、1} \\\
F(n - 1, na) & \text{$n$ > 1}  \\\
\end{cases}
$$

``` C++
#include <iostream>
using namespace std;

unsigned long long F(int n, unsigned long long part_result) {
    if (n == 1 || n == 0) return part_result;
    else return F(n - 1, n * part_result);
}

int main() {
    unsigned long long result = F(65, 1);
    cout << result << endl;
    return 0;
}
```

在尾递归中，每次调用函数本身时都会把当前的计算的部分结果传过去，避免了回归的过程。这时如果能覆盖之前的活跃记录而不是压栈再去新建一个记录就能达到优化的效果。

<center>![](https://s1.ax2x.com/2018/03/14/LUPJ3.png)</center>
<center>$ F(4, 1) = (((4 × 3) × 2) × 1) $</center>

### 运行时间测试

由于大数阶乘数字比较大，数字超过65就会溢出，所以使用的测试数据比较小，运行时间差距不大，但是还是有区别，优化后的运行时间的最大值也不会超过未优化的最小值。(`-O2` 参数是 `-O1` 的进阶，是推荐的优化等级，编译器会试图提高代码性能而不会增大体积和大量占用的编译时间)

``` C++
    //记录程序开始时间    
    clock_t tStart = clock();
    unsigned long long result = F(65, 1);
    cout << result << endl;
    //显示程序运行时间
    printf("Time taken: %.3fms\n", (double)(clock() - tStart) / CLOCKS_PER_SEC * 1000);
```

### 运行空间测试

由于测试数据较小，所以在主函数中定义一个大型的数组，尽可能地占用栈的空间，达到使优化后的运行时不会出现段错误，而未优化的运行时由于活跃记录的增加而出现段错误。

``` C++
int unused[1024 * 1024 * 1024];    //为了占用栈空间
```

## 分析

### 未优化

``` bash
$ g++ main.cpp -S
```
通过以上命令编译代码，不进行尾递归优化，生成 `main.s` 文件，截取其中部分汇编代码:

```
## BB#0:
	pushq	%rbp
Ltmp3:
	.cfi_def_cfa_offset 16
Ltmp4:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
Ltmp5:
	.cfi_def_cfa_register %rbp
	subq	$16, %rsp
	movl	$65, %edi
	movl	$1, %eax
	movl	%eax, %esi
	movl	$0, -4(%rbp)
	callq	__Z1Fiy
```

凭借现在遗留的汇编知识大致可以看出在调用函数 $F(n)$ `callq	__Z1Fiy` 之前会进行压栈 `pushq	%rbp` ，所以会保留当前活跃记录。

### 优化

``` bash
$ g++ main.cpp -O2 -S
```
通过以上命令编译代码，进行尾递归优化，截取其中部分汇编代码:

```
LBB0_6:                                 ## %tailrecurse
                                        ## =>This Inner Loop Header: Depth=1
	leaq	(%rax,%rdx), %rdi
	imulq	%rsi, %rdi
	leaq	-1(%rax,%rdx), %rsi
	leaq	-2(%rax,%rdx), %rcx
	imulq	%rsi, %rcx
	imulq	%rdi, %rcx
	leaq	-3(%rax,%rdx), %rdi
	leaq	-4(%rax,%rdx), %rsi
	imulq	%rdi, %rsi
	leaq	-5(%rax,%rdx), %rdi
	imulq	%rsi, %rdi
	imulq	%rcx, %rdi
	leaq	-6(%rax,%rdx), %rcx
	leaq	-7(%rax,%rdx), %rsi
	imulq	%rcx, %rsi
	imulq	%rdi, %rsi
	addq	$-8, %rdx
	leal	(%r8,%rdx), %ecx
	cmpl	$1, %ecx
	ja	LBB0_6
```

可见代码会被尾递归优化，并且自动加上注释，在代码中不会有压栈的行为，而是跳回去使用当前活跃记录 `ja	LBB0_6`。

## 总结

递归能把一个大的问题转化成一个规模较小的问题，递归只需少量的程序就能描述出解题过程所需要的多次重复计算，减少了程序的代码量，用递归思想写出的程序往往十分简洁易懂。 

但是递归算法的运行效率较低。在递归调用的过程当中系统为每一层的返回点、局部量等开辟了栈来存储。递归次数过多容易造成栈溢出等，即使进行了尾递归优化也会存在生成活跃记录和覆盖活跃记录的操作。

## 拓展

从尾递归优化的思想可以得到启发，如果在 $ Fa() $ 的末尾调用了 $ Fb() $，那么这就属于尾调用，就可以不用将当前的活跃记录压栈，而是直接新建一个，由于这里两个函数不同，不像尾递归，所以不能直接覆盖活跃记录，但是也可以达到优化的效果。
