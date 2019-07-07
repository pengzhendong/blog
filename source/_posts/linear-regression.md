---
title: 线性回归
date: 2018-03-10 22:00:12
updated: 2018-03-10 22:56:32
tags: Machine Learning
mathjax: true
---

## 前言

不知不觉研一已经过去了一个学期，上学期真实忙得没有时间总结。天天忙着上课和做实验，随机过程和工程硕士数学确实有些收获，就是感觉上课的形式花的时间太多；模式识别和计算机网络体系结构做了几个实验，收获颇丰。说实话，在教学方面，清华的老师也强不到哪里去(听师兄说本部也差不多)，根本就不能吸引学生注意力，课堂气氛也不行。

<!-- more -->

上学期也算是入门了机器学习吧，跟着吴恩达在 Coursera 上的 Machine Learning 学了半个学期，也看了一些书和论文。现在总结一下，不然就连最简单的线性回归还是一知半解，毕竟只有写出来，讲出来才是自己的。

## 线性回归

> 给定数据集 $\boldsymbol{D}=\lbrace(\boldsymbol{x}^{(i)}, y^{(i)}); i=1, …, m\rbrace$，其中 $\boldsymbol{x}^{(i)}=(x^{(i)}_1; x^{(i)}_2; …; x^{(i)}_d)$，$y^{(i)}\in\mathbb{R}$，线性回归就是试图去学习线性模型以尽可能准确地根据输入 $\boldsymbol{x}$ 预测输出 $y$。

线性回归并不陌生，例如高中的时候学过的父母身高预测法，假设父母的身高 $\boldsymbol{x}=(x_1; x_2)$ 和子女的身高 $y$ 之间存在某种线性的关系(其实还和子女的性别有关，对于性别这种离散且不存在“序”的值，可以用一个 2 维向量表示：男(0; 1)、女(1; 0))，线性回归就是要根据统计的数据去学习这个假设(hypothesis)存在的关系 $h_\boldsymbol{\theta}(\boldsymbol{x})=\theta_1x_1+\theta_2x_2+b=\boldsymbol{\theta}^ \mathrm{T}\boldsymbol{x}+b$。

假设存在 $x_0=1$ 且令 $\theta_{0}=b$，则$h_\boldsymbol{\theta}(\boldsymbol{x})=\theta_0x_0+\theta_1x_1+\theta_2x_2=\boldsymbol{\theta}^ \mathrm{T}\boldsymbol{x}$，线性回归就是要找到 $\boldsymbol{\theta}$，使得预测结果尽可能准确。

以下实验数据来自于吴恩达在 Coursera 的 Machine Learning 课程的实验 ex1。

### Ex 1

一个餐厅的 CEO 考虑在不同的城市开一家新店，所以希望能根据城市人口的数量(先不考虑其他因素，即一元线性回归)预测商铺的利润 $y$ ，以决定在哪座城市开店。

商铺利润 $y$ 和城市人口数量 $x_1$ 之间大体上呈线性关系，所以可以使用线性回归的方法学习出这个关系，即找到 $\boldsymbol{\theta}$，那么给定一个新的城市人口数时候，就可以根据 $\boldsymbol{x}$ 尽准确预测可能出商铺利润 $h_\boldsymbol{\theta}(\boldsymbol{x})$。

### 符号解释

- $\boldsymbol{x}^{(i)}$：“输入”变量，也叫做输入特征。例如 $\boldsymbol{x}^{(i)}=(1; x^{(i)}_1)$, $x^{(i)}_1$ 就是第 $i$ 座城市的人口数量。
$$
\boldsymbol{X}=\begin{bmatrix} - (\boldsymbol{x}^{(1)})^\mathrm{T} - \\\ . \\\ . \\\ . \\\ - (\boldsymbol{x}^{(m)})^\mathrm{T} - \end{bmatrix}=\begin{bmatrix} 1 & x^{(1)}_1 \\\ . & . \\\ . & . \\\ . & .\\\ 1 & x^{(m)}_1 \end{bmatrix}\quad
$$
- $y^{(i)}$：“输出”，也叫做目标变量。例如第 $i$ 座城市的利润。
$$
\boldsymbol{y}=\begin{bmatrix} y^{(1)} \\\ . \\\ . \\\ . \\\ y^{(m)} \end{bmatrix}\quad
$$
- $(\boldsymbol{x}^{(i)}, y^{(i)})$：一个训练样本

- $\boldsymbol{D}=\lbrace(\boldsymbol{x}^{(i)}, y^{(i)}); i=1,…,m)\rbrace$：$m$ 个训练样本组成的训练集，上标 $(i)$ 表示样本在训练集中的索引，和指数没有关系



$$
\boldsymbol{D}=\begin{bmatrix}\boldsymbol{X} & \boldsymbol{y}\end{bmatrix}=\begin{bmatrix} 1 & x^{(1)}_1 & y^{(1)} \\\ . & . & . \\\ . & . & . \\\ . & . & . \\\ 1 & x^{(m)}_1 & y^{(m)} \end{bmatrix}\quad
$$

## 性能度量

如何找到 $\boldsymbol{\theta}$ 就需要了解什么样的 $\boldsymbol{\theta}$ 能使预测结果更准确。如果 $h_\boldsymbol{\theta1}(\boldsymbol{x})$ 与真实的结果 $y$ 之间的<font color= red size=4>差别</font>比  $h_\boldsymbol{\theta2}(\boldsymbol{x})$ 与真实的结果 $y$ 之间的差别更小，那么 $\boldsymbol{\theta1}$ 就比 $\boldsymbol{\theta2}$ 更好，能使预测结果更准确。

假设使用 $\boldsymbol{\theta1}$ 预测出来的利润 $h_\boldsymbol{\theta1}(\boldsymbol{x})$ 与真实利润 $y$ 之间的差别更小，但是如何用数学语言衡量 $h_\boldsymbol{\theta}(\boldsymbol{x})$ 和 $y$ 之间的差别呢？。

### 损失函数、代价函数和目标函数

> **损失函数**是一种衡量**损失**和错误程度的**函数**

在机器学习领域，经常会出现损失函数、代价函数和目标函数，它们之间并没有严格的规定，然而它们的定义一般如下：

1. 损失函数(Loss function)：定义在单个训练样本上，衡量一个样本的输出与真实值差别，例如：
   * 平方损失(通常用于线性回归)：$l_\boldsymbol{\theta}(i)=\left(h_\boldsymbol{\theta}(\boldsymbol{x}^{(i)})-y^{(i)}\right)^2$
   * 铰链损失(用于 SVM，像铰链)：$l_\boldsymbol{\theta}(i) = \max\left(0, 1-h_\boldsymbol{\theta}(\boldsymbol{x}^{(i)})y^{(i)}\right)$
   * ...
2. 代价函数(Cost function)：定义在整个训练集上，即选定参数 $\boldsymbol{\theta}$ 后对数据进行估计所要支付的代价加上一些惩罚函数(例如正则化项)，例如：
   * 均方误差(几何意义是“欧氏距离”)：$MSE(\boldsymbol{\theta}) = \frac{1}{m} \sum_{i=1}^m\left(h_\boldsymbol{\theta}(\boldsymbol{x}^{(i)})-y^{(i)}\right)^2$
   * SVM 的代价函数：$SVM(\boldsymbol{\theta}) = \|\boldsymbol{\theta}\|^2 + C \sum_{i=1}^m \xi^{(i)}$ 
   * ...
3. 目标函数(Objective function)：代价函数的推广，即需要优化的函数。可能是最大化，也可能是最小化(此时就是代价函数)，例如：
   * 似然函数：用最大似然估计评估模型参数(MLE)
   * 后验：用最大后验估计模型参数
   * ...

线性回归使用均方误差作为代价函数，因此可以算出中 $MSE(\boldsymbol{\theta1})$ 比 $MSE(\boldsymbol{\theta2}) $ 更小，即 $\boldsymbol{\theta1}$ 能使预测结果更准确。$MSE(\boldsymbol{\theta1})$ 为每个点到预测结果的距离（每个点与横坐标作垂线，与预测结果的交点）之和的平均：

但是在以均方误差作为性能度量的前提下，是不是还存在 $\boldsymbol{\theta^{\*}}$ 能使预测结果 $\boldsymbol{\theta1}$ 的预测结果更准确？如何找到最准确的 $\boldsymbol{\theta^{\*}}$ 是一个凸优化问题，更准确地说这是一个最小二乘问题。

$$\boldsymbol{\theta^{*}} = \arg \min_{\boldsymbol{\theta}}\frac{1}{m}\sum_{i=1}^m\left(h_\boldsymbol{\theta}(\boldsymbol{x}^{(i)})-y^{(i)}\right)^{2}$$

## 最小二乘问题

线性回归的代价函数是一个二次函数且半正定，所以这是一个最小二乘问题。所以最小化 $MSE(\boldsymbol{\theta})$ 求解 $\boldsymbol{\theta}$ 的过程也叫做最小二乘“参数估计”。一元线性回归的代价函数图是一个“碗状”图。

### 解析解

求解线性最小二乘问题可以通过对代价函数求导，然后令导数为零可以得到 $\boldsymbol{\theta}$ 的解析解，但是由于在求解过程中会涉及到矩阵求逆的计算，对于 $n$ 维的的输入变量 $\boldsymbol{x}=(x_0; x_1; …; x_{n-1})$，时间复杂度为 $O(n^3)$，因此当 $n>10000$ 时不推荐使用。其解析解为：

$$\boldsymbol{\theta}=(\boldsymbol{X}^ \mathrm{T}\boldsymbol{X})^{-1}\boldsymbol{X}^ \mathrm{T}\vec{y}$$

对于多元线性回归(输入变量维数大于 2)，如果数据的组数少于输入变量维数，那么矩阵 $\boldsymbol{X}^ \mathrm{T}\boldsymbol{X}$ 显然不满秩。很好理解，未知数的个数大于方程的个数，那么这个方程的解就不唯一，就会有多个解能使均方误差最小化，常见的解决方法就是引入正则化项(详情见《凸优化》第六章)。

求解过程涉及求一阶偏导数，一阶偏导数以一定方式排列成的矩阵又叫做**雅可比(Jacobian)矩阵**，所以在机器学习中一般使用 $J(\boldsymbol{\theta})$ 表示代价函数。

### 梯度下降算法

当 $n>10000$ 或者最小二乘问题是非线性的，可以考虑使用梯度下降算法。梯度下降是迭代法的一种，常用于求解最小二乘问题。在最小化代价函数时，可以通过梯度下降法来一步步的迭代求解(通过一个已经找到的 $\boldsymbol{\theta}$ 和迭代公式去算更好的 $\boldsymbol{\theta}$)，最后得到最小化的代价函数和模型参数值 $\boldsymbol{\theta}$。

梯度下降算法涉及到求代价函数 $J(\boldsymbol{\theta}) = \frac{1}{m} \sum_{i=1}^m\left(h_\boldsymbol{\theta}(\boldsymbol{x}^{(i)})-y^{(i)}\right)^2$ 的梯度(即[导数](https://www.zhihu.com/question/28684811/answer/159589897))，为了计算方便，一般 $J(\boldsymbol{\theta}) = \frac{1}{2m} \sum_{i=1}^m\left(h_\boldsymbol{\theta}(\boldsymbol{x}^{(i)})-y^{(i)}\right)^2$，根据链式求导法则得 $J(\boldsymbol{\theta})$ 在 $\theta_j$ 方向上的梯度的表达式为：

$$\nabla=\frac{\partial{J(\boldsymbol{\theta})}}{\partial{\theta_j}}=\frac{\partial{J(\boldsymbol{\theta})}}{\partial{h_\boldsymbol{\theta}(\boldsymbol{x})}}\frac{\partial{h_\boldsymbol{\theta}(\boldsymbol{x})}}{\partial{\theta_j}}=\frac{1}{m} \sum_{i=1}^m\left(h_\boldsymbol{\theta}(\boldsymbol{x}^{(i)})-y^{(i)}\right)x^{(i)}_j$$

所以梯度下降过程中，$\theta_j$ 的更新过程为：

$$\theta_j:=\theta_j-\alpha\frac{\partial{J(\boldsymbol{\theta})}}{\partial{\theta_j}}$$

其中 $\alpha$ 为学习率，即梯度下降的“步伐”大小，太大会错误最小值导致梯度上升，太小会导致下降速度太慢，一般开始的时候稍微大些然后逐渐变小，当一次迭代梯度下降小于 $10^{-3}$ 的时候就可以说是收敛了。其中 $m$ 为梯度下降时使用的样本个数，根据 $m$ 取值的不同梯度下降算法分为以下三种：

1. 批量梯度下降
2. 随机梯度下降
3. 小批量梯度下降

#### 批量梯度下降(Batch Gradient Descent，简称 BGD)

梯度下降的时候使用所有样本来更新参数 $\boldsymbol{\theta}$，最后会收敛到全局最优解，也易于并行实现。但是如果样本数目过多的时候，训练过程会很慢。

```matlab
for iter = 1:num_iteration
    h = X * theta;
    theta = theta - (alpha/m) * X' * (h - y);
end
```

#### 随机梯度下降(Stochastic Gradient Descent，简称 SGD)

梯度下降的时候使用一个样本来更新参数 $\boldsymbol{\theta}$，不一定能收敛到全局最优解，也不易于并行实现，但是训练过程会很快。

``` matlab
for iter = 1:num_iteration
    for i = 1:m
    	h = X(i, :) * theta;
    	theta = theta - alpha * X(i, :)' * (h - y(i));
    end
end
```

批量梯度下降和随机梯度下降的时间复杂度一样，但是对于迭代同样的次数，随机梯度下降中的参数更新的次数较多，所以收敛的速度就快。但是由于随机梯度下降计算的梯度是对于这一次所选取的这一个样本的平方损失的梯度，而不是全部样本的均方误差的梯度，所以计算的梯度可能不准确，所以最后不一定能收敛到全局最优点。

在数据量很大的情况下，单个样本的平方损失可能会很接近于全部样本的均方误差，那么随机梯度下降计算的梯度就会很准确，同时收敛的速度也很快。

#### 小批量梯度下降(Mini-batch Gradient Descent，简称 MBGD)

结合了批量梯度下降和随机梯度下降，在梯度下降的时候使用一部分样本来更新参数 $\boldsymbol{\theta}$。所以在数据集比较小的时候采用批量梯度下降算法，数据集比较大的时候采用随机梯度下降算法，一般情况下使用小批量梯度下降算法。

## 总结

线性回归主要就是观察数据，发现它满足一定的线性关系，然后就去找出这个关系，让预测尽可能地准确。一般都是使用小批量梯度下降算法，通过最小化代价函数算出模型的参数，得到的模型就可以用来对新的数据进行预测。

## 参考文献

[1] 周志华. 机器学习. 清华大学出版社.  2016.

[2] 吴恩达. 机器学习. 

[4] Ian Goodfellow, Yoshua Bengio, Aaron Courville. Deep Learning. 人民邮电出版社. 2017.

[4] Stephen Boyd, Lieven Vandenberghe. 凸优化. 清华大学出版社. 2017.

[5] 关治, 陆金甫. 数值方法. 清华大学出版社. 2017.


