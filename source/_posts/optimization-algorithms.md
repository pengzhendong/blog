---
title: 优化算法
date: 2018-06-06 10:34:00
updated: 2018-06-06 12:02:28
tags: Machine Learning
mathjax: true
---

## 前言

单单通过特征缩放提高梯度下降的收敛速度并不够，有时候还需要改进梯度下降算法。例如动量梯度下降 (Grandient descent with Momentum)、RMSprop 算法和 Adam 优化算法(Adam optimization algorithm)。

<!-- more -->

## 动量梯度下降法

在大数据时代，使用批量梯度下降会非常耗时，而小批量梯度下降每次只使用小批量的数据，在梯度下降过程中并不是每次迭代都向着整体最优化的方向。动量梯度下降法 (Gradient descent with Momentum) 则可以帮助梯度下降尽可能保持向着整体最优化的方向，可以加速算法的收敛，动量梯度下降法使用指数加权平均，在计算当前梯度的同时也使用了之前迭代过程的梯度。

### 指数加权平均

[指数加权平均](https://zh.wikipedia.org/wiki/%E7%A7%BB%E5%8B%95%E5%B9%B3%E5%9D%87#%E6%8C%87%E6%95%B8%E7%A7%BB%E5%8B%95%E5%B9%B3%E5%9D%87)（Exponential weighted average，简称 EXWA 或者 EWA）也叫指数移动平均（Exponential moving average，简称 EXMA 或者 EMA），是以指数式递减加权的移动平均。各数值的加权影响力随时间而指数式递减，越近期的数据加权影响力越重，但较旧的数据也给予一定的加权值。
$$
v_t=\beta v_{t-1}+(1-\beta)\theta_t
$$
其中 $v_t$ 表示指数加权平均值 ($v_0=0$)，$\theta_t$ 表示当前数据，$\beta$ 为参数，其取值范围为 $[0, 1)$。例如 $\beta=0.9$，有：
$$
\begin{align}
v_{100} &= (1-\beta)\theta_{100}+(1-\beta)\beta\theta_{99}+(1-\beta)\beta^2\theta_{98}+...+(1-\beta)\beta^{99}\theta_{1} \\\
&= 0.1\theta_{100}+(0.1\times 0.9)\theta_{99}+(0.1\times 0.9^2)\theta_{98}+...+(0.1\times 0.9^{99})\theta_{1}
\end{align}
$$
越旧的数据权值越小，如何给 $\beta$ 一个直观的感觉呢？当权值 $\beta^n$ 小于 $\frac{1}{e}$ 就可以说只关注了前 $n$ 个数据，因为更旧的数据权值只有不到 $\frac{1}{e}$：
$$
\lim_{x \to 0}(1+x)^{-\frac{1}{x}}=\frac{1}{e}
$$
令 $x=\beta-1$，得
$$
\lim_{\beta \to 1}(\beta)^{\frac{1}{1-\beta}}=\frac{1}{e}
$$
因此可以**简单地**认为 $v_t$ 是前 $\frac{1}{1-\beta}$ 个数据的指数加权平均(并不是严格的数学证明)。$\beta$ 越大表示当前数据所占的权值越小，即求出来的平均值对当前数据越不敏感，则曲线越平坦。例如下图中的红线(“<font color="red">---</font>”)为 $cos(\frac{4\pi x}{3})$ 在 $[0, 1]$ 的函数图像，蓝点(“<font color="blue">·</font>”)为随机采样的数据，具有一定的高斯噪声，绿线(“<font color="#00FF00">---</font>”)则是直接用直线把所有数据连接起来，黑线(“—”)是指数加权平均 ($\beta=0.9$) 的结果，通过考虑之前的数据，对之前的数据进行指数加权平均得到了比较平滑的曲线。

![](https://s1.ax2x.com/2018/06/06/RMyJO.png)

#### 偏差修正

由于默认 $v_0=0$，所以对一开始的数据计算移动平均数作为估计就不太准确。可以用 $\frac{v_{t}}{1- \beta^{t}}$ 作为估计值，当随着 $t$ 增加，$\beta^{t}$ 接近于 0，因此当$t$较大的时候，紫线(“<font color="purple">---</font>”)基本和黑线(“---”)重合了。

![](https://s1.ax2x.com/2018/06/06/Rb5sJ.png)

### 动量梯度下降

动量梯度下降的基本想法就是计算梯度的指数加权平均数，并利用该梯度更新权重。

![](https://s1.ax2x.com/2018/06/06/RbHE3.png)

在每次迭代中，参数的更新公式如下所示：
$$
v_{dW}=\beta v_{dW}+(1-\beta)dW
$$

$$
W=W-\alpha v_{dW}
$$

使用动量梯度下降法，由于每次都尽量朝着整体最优化的方向更新参数，所以算法的速度回比较快，其梯度下降轨迹如下图所示：

![](https://s1.ax2x.com/2018/06/06/Rbzvn.png)

## RMSprop

RMSprop(root mean square prop) 算法，也可以加速梯度下降。如上图 without momentum 中，$w_2$ 方向上的梯度要大于 $w_1$ 方向上的梯度(因为 $w_2$ 方向上一步跨得比较大，$W=W-\alpha dW$)，RMSprop 算法通过让学习率除以一个衰减系数(历史梯度平方和的平方根)，使得每个参数的学习率不同。在参数空间更为平缓的方向(衰减系数较小)，获得更大的步伐，从而加快训练速度。
$$
S_{dW}= \beta S_{dW} + (1 - \beta)({dW})^{2}
$$

$$
W=W-\frac{\alpha}{\sqrt{S_{dw}}+\varepsilon}dW
$$

其中 $\varepsilon$ 是为了避免分母为 0。

## Adam 优化算法

Adam(Adaptive Moment Estimation) 优化算法基本上就是将 Momentum 和 RMSprop 结合在一起：
$$
v_{dW}= \beta_{1}v_{dW} + ( 1 - \beta_{1})dW
$$

$$
S_{dW}=\beta_{2}S_{dW} + ( 1 - \beta_{2}){(dW)}^{2}
$$

偏差修正：
$$
v_{dW}^{\text{corrected}}= \frac{v_{dW}}{1 - \beta_{1}^{t}}
$$

$$
S_{dW}^{\text{corrected}} =\frac{S_{dW}}{1 - \beta_{2}^{t}}
$$

权值更新：
$$
W= W - \frac{\alpha}{\sqrt{S_{dW}^{\text{corrected}}} +\varepsilon}v_{dW}^{\text{corrected}}
$$
Adam 算法结合了 Momentum 和 RMSprop 梯度下降法，是一种极其常用的学习算法，被证明能有效适用于不同神经网络，适用于广泛的结构。其中超参数学习率 $\alpha$ 很重要，也经常需要调试；$\beta_{1}$常用的缺省值为 0.9；Adam 论文作者推荐使用 0.999 作为超参数 $\beta_{2}$ 的默认值；$\varepsilon$ 建议为 $10^{-8}$。但是在使用 Adam 的时候，人们往往使用缺省值即可。

## 学习率衰减

随时间慢慢减少学习率也可以加快学习算法，我们将之称为学习率衰减。因为在学习初期，模型可以承受较大的步伐，当开始收敛的时候，则需要逐渐减小步伐，否则容易错过最优值。

使用小批量梯度下降进行训练，每遍历一次训练集称为一个 `epoch` (一代)，学习率可以随着 epoch 的变大而减小：
$$
\alpha=\frac{1}{1+\text{decay_rate}*\text{epoch_num}}\alpha_0
$$
其中 decay_rate 是衰减率(需要调整的超参数)，epoch_num 是代数，$\alpha_0$ 是出事学习率。除了这个公式，还可以用其他的公式使学习率递减或者通过手动的方式调整学习率：
$$
\alpha=0.95^\text{epoch_num}\alpha_0
$$

$$
\alpha=\frac{k}{\sqrt{\text{epoch_num}}}\alpha_0
$$

$$
\alpha=\frac{k}{\sqrt{t}}\alpha_0
$$

## 局部最优问题

在深度学习研究早期，人们总是担心优化算法会被困在一些局部最优点处。如下图中存在不少局部最优，梯度下降法可能被困在某个局部最优中，而不会抵达全局最优。

![](https://s1.ax2x.com/2018/06/07/RZHEa.png)

而事实上，在神经网络中上图所示的局部最优点出现的可能性很小，梯度为 0 时，通常是**鞍点**：

![](https://s1.ax2x.com/2018/06/07/RZmVS.png)

因为代价函数梯度为 0 时，那么在每个方向(权值)上，它可能是凸函数，也可能是凹函数。在一个 $n$ 维的高维空间中，如果想要得到局部最优，那么 $n$ 个方向上都需要一样，发生这种情况的概率是 $\frac{1}{2^n}$。而大部分情况却是一部分方向是凸函数，一部分方向是凹函数，即鞍点。但问题是在鞍点处，会有平稳段，即曲面很平坦，下降速度慢，而 Adam 算法正好可以加快速度，尽早走出平稳段。


## 参考文献

1. 吴恩达. DeepLearning. 
2. [Momentum methods](https://jermwatt.github.io/mlrefined/blog_posts/13_Multilayer_perceptrons/13_5_Momentum_methods.html)