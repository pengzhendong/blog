---
title: Master Method(主定理)
date: 2016-07-30 15:59:48
updated: 2016-07-30 16:23:39
tags: Algorithms
mathjax: true
---

## 前言

大二学习数据结构的时候记得老师并没有详细讲如何求时间复杂度，在学习<<算法导论>>的时候，视频里面的老师花了很多精力来讲如何求时间复杂度，学到了一个定理，觉得很有必要自己推导一遍并且记录下来。

<!-- more -->

## 主定理

>  在算法分析中，主定理提供了用渐进符号表示许多由分治法得到的递推关系的方法。

### 渐进符号

学习算法分析之前，首先要学习几个渐进符号的概念，分别是大O和小o、大Ω和小ω，还有一个大Θ。

#### 渐进上界: Ο(O)

$$
 f(n) = {O(g(n))}
$$

$∃ c, n$<sub>$0$</sub>($c, n$<sub>$0$</sub>为正数常数)，使得 $∀ n ≥ n$<sub>$0$</sub> 时，$0 ≤ f(n) ≤ cg(n)$，该符号渐进给出了一个函数的上界，类似于小于等于。

<center><img src="https://s1.ax2x.com/2018/03/14/LK0Un.png" width="200"></center>

#### 渐进下界: Ω(Omega)

$$
 f(n) = {Ω(g(n))}
$$

$∃ c, n​$<sub>$0​$</sub>($c, n​$<sub>$0​$</sub> 为正数常数)，使得 $∀ n ≥ n​$<sub>$0​$</sub> 时，$0 ≤ cg(n) ≤ f(n)​$，该符号渐进给出了一个函数的下界，类似于大于等于。

<center><img src="https://s1.ax2x.com/2018/03/14/LKjc2.png" width="200"></center>

#### 渐进确界: Θ(Theta)

$$
 f(n) = {Θ(g(n))}
$$

$∃ c$<sub>$1$</sub>, $c$<sub>$2$</sub>, $n$<sub>$0$</sub>(c$<sub>$1$</sub>, $c$<sub>$2$</sub>, $n$<sub>$0$</sub>为正数常数)，使得 $∀ n ≥ n$<sub>$0$</sub> 时，$0 ≤ c$<sub>$1$</sub>$g(n) ≤ f(n) ≤ c$<sub>$2$</sub>$g(n)$，该符号渐进给出了一个函数的上界和下界，$Θ(g(n)) = O(g(n)) ∩ Ω(g(n))$。

<center><img src="https://s1.ax2x.com/2018/03/14/LKOmz.png" width="200"></center>

#### 非渐进紧确上界: ο(O)

$$
 f(n) = {o(g(n))}
$$

$∃ c, n$<sub>$0$</sub>($c, n$<sub>$0$</sub> 为正数常数)，使得 $∀ n ≥ n$<sub>$0$</sub> 时，$0 ≤ f(n) < cg(n)$，该符号渐进给出了一个函数的非渐近紧确的上界，类似于小于。

#### ω(Omega)

$$
 f(n) = {ω(g(n))}
$$

$∃ c, n$<sub>$0$</sub>($c, n$<sub>$0$</sub> 为正数常数)，使得 $∀ n ≥ n$<sub>$0$</sub> 时，$0 ≤ cg(n) < f(n)$，该符号渐进给出了一个函数的非渐近紧确的上界，类似于大于。

### 递归方程

$$
T(n) = aT(\frac{n}b) + f(n), a ≥ 1，b > 1, f(n)为函数，T(n)为非负整数
$$

在分治法中我们需要将一个问题规模为 $n$ 的大问题，分解成 $a$ 个递归小问题，每个子问题的问题规模为 $n/b$，$f(n)$ 为递推以外进行的计算工作，例如合并子问题的结果。

### 递归树

<center><img src="https://s1.ax2x.com/2018/03/14/LK4bN.jpg" width="500"></center>

令树的高度为 $h$，则 

$$
\frac{n}{b^h} = 1 → h = \log_{b}n
$$

叶子节点数为: 
<center>$a$<sup>$h$</sup> = $a$<sup>$log$<sub>$b$</sub><sup>$n$</sup></sup> = $a$<sup>$log$<sub>$a$</sub><sup>$n$<sup></sup></sup>/$log$<sub>$a$</sub><sup>$b$<sup></sup></sup></sup> = $n$<sup>$1$/$log$<sub>$a$</sub><sup>$b$<sup></sup></sup></sup> = $n$<sup>$log$<sub>$b$</sub><sup>$a$</sup></sup></center>

#### 1. f(n) 为多项式

因为 $f(n)$ 是多项式，设 $f(n) = O(n$<sup>$k$</sup>$), k ≥ 0$.
则

$$
\begin{align} 
T(n) & = n^k + a(\frac{n}{b})^k + a^2(\frac{n}{b^2})^k + ... + a^h(\frac{n}{b^h})^k \\\
& = n^k(1 + (\frac{a}{b^k}) + (\frac{a}{b^k})^2 + ... + (\frac{a}{b^k})^h) \\\
\end{align}
$$

括号中间为等比数列前 $h + 1$ 项和 $S$<sub>$h + 1$</sub>，首项 $a$<sub>$1$</sub> 为1，公比 $q$ 为 $a/b$<sup>$k$</sup>.

等比数列前 $n$ 项和公式为

$$
f(n) =
\begin{cases}
a_1\frac{1 - q^n}{1 - q} & \text{$q$  ≠ 1} \\\
na_1 & \text{$q$ = 1}  \\\
\end{cases}
$$

所以
1.当 $q = 1$ 时，即 $a/b$<sup>$k$</sup> $= 1$

$$
\begin{align} 
T(n) & = n^k(h+1) \\\
 & = O(n^kh) \\\ 
 & = O(n^k\log_{b}n) & \text{代入 $h$} \\\
\end{align}
$$

2.当 $q ≠ 1$ 时，即 $a/b$<sup>$k$</sup> $≠ 1$

$$
\begin{align} 
T(n) & = n^k\frac{1 - (a/b^k)^{h+1}}{1 - a/b^k} \\\
 & ≥ \frac{n^k - n^k(a/b^k)^h}{1 - a/b^k} \\\
 & = \frac{n^k - n^{\log_{b}a}}{1 - a/b^k} & \text{代入 $h$} \\\
\end{align}
$$

* 如果  k > $log$<sub>$b$</sub><sup>$a$</sup>，则

$$
T(n) = O(n^k)
$$

* 如果  k < $log$<sub>$b$</sub><sup>$a$</sup>，则

$$
T(n) = O(n^{\log_{b}a})
$$

#### 2. f(n) 为一般函数

当 $f(n)$ 为一般函数时有时候不一定能求出最终的解，通过递归树和等差等比数列的求和公式有些情况下还是可以求出最终解。

$$
T(n) = aT(n/b) + nlgn
$$

 由递归树得:

$$
\begin{align}
T(n) & = nlgn + a\frac{n}{b}(lgn - lgb) + a^2\frac{n}{b^2}(lgn - lgb^2) + ... + a^h\frac{n}{b^h}(lgn - lgb^h) \\\
 & = n[lgn + \frac{a}{b}(lgn - lgb) + (\frac{a}{b})^2(lgn - 2lgb) + ... + (\frac{a}{b})^h(lgn - hlgb)] \\\
\end{align}
$$

* 当 $a = b$ 时

$$
\begin{align}
T(n) & = n[(h + 1)lgn - h\frac{lgb + hlgb}{2}] \\\
 & = O(n(lgn)^2)
\end{align}
$$

* 当 $a ≠ b$ 时，得到一个等差等比数列相乘的数列，通过错位相减法计算:

$$
\begin{align}
\frac{T(n)}{n} - lgn & = \frac{a}{b}(lgn - lgb) + (\frac{a}{b})^2(lgn - 2lgb) + ... + (\frac{a}{b})^h(lgn - hlgb) & ①\\\
\end{align}
$$

$$
\begin{align}
(\frac{a}{b})(\frac{T(n)}{n} - lgn) & =  (\frac{a}{b})^2(lgn - lgb) + (\frac{a}{b})^3(lgn - 2lgb) + ... + (\frac{a}{b})^{h + 1}(lgn - hlgb) & ②\\\
\end{align}
$$

① - ②， 得

$$
\begin{align}
(1 - \frac{a}{b})(\frac{T(n)}{n} - lgn) & = \frac{a}{b}(lgn - lgb) - lgb[(\frac{a}{b})^2 + (\frac{a}{b})^3 + ... + (\frac{a}{b})^h] - (\frac{a}{b})^{h + 1}(lgn - hlgb) \\\
 & = \frac{a}{b}(lgn - lgb) - lgb[(\frac{a}{b})^2\frac{1 - (a / b) ^ {h - 1}}{1 - a / b})] - (\frac{a}{b})^{h + 1}(lgn - hlgb) \\\
\end{align}
$$

化简得:

$$
T(n) = O(nlgn - n^{\log_{b}a}lgn)
$$

* 当 $a > b$ 时

$$
T(n) = O(n^{\log_{b}a}lgn)
$$

* 当 $a < b$ 时

$$
T(n) = O(nlgn)
$$



