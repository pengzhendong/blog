---
title: Logistic 回归和 Softmax 回归
date: 2018-04-26 20:24:05
updated: 2018-04-26 21:32:11
tags: Machine Learning
mathjax: true
typora-root-url: ./logistic-regression
---

## 前言

最近在看吴恩达的 DeepLearning，学习了不少关于深度学习的知识，正好参考着作业的内容总结一下，挖这个坑必须得填，哈哈。

<!-- more -->

几乎所有深度学习的书都是从 **Logistic Regression** 开始讲，因为这是一个最简单的“神经网络”。以前看到网上有不少人把这个词组翻译为“逻辑回归”，但是看到西瓜书🍉上说 logistic != logic ，作者把这个翻译为对数几率回归，简称对率回归。对率回归可以解决线性二分类问题，推广成 Softmax 回归可以解决线性多分类问题。

## Logistic 回归

线性回归预测的 y 是连续的值，对于二分类问题，我们希望预测的 y 只能取 0/1 两个值。例如假设肿瘤是否是恶性肿瘤只和肿瘤的大小有关，然后给定肿瘤的大小，判断它是否是恶性肿瘤，1 表示正例(是)，0 表示负例(否)。

> 分类是监督学习的一个核心问题，在监督学习中，当输出变量 Y 取有限个离散值时，预测问题便成为分类问题。这时，输入变量 X 可以是离散的，也可以是连续的。监督学习从数据中学习一个分类模型或分类决策函数，称为分类器(classifier)。分类器对新的输入进行输出的预测(prediction)，称为分类(classification)。

如果使用线性回归解决二分类任务，因为输出会有大于 1 和小于 0 的数，解决这个问题只需要将线性回归的预测值 $h_\boldsymbol{\theta}(\boldsymbol{x})=\boldsymbol{\theta}^ \mathrm{T}\boldsymbol{x}$ 映射到值域为 (0, 1) 的空间上，即：

$$h_\boldsymbol{\theta}(\boldsymbol{x})=g(\boldsymbol{\theta}^ \mathrm{T}\boldsymbol{x})=\frac{1}{1+e^{-\boldsymbol{\theta}^ \mathrm{T}\boldsymbol{x}}}$$

因此 $ln\frac{h_\boldsymbol{\theta}(\boldsymbol{x})}{1-h_\boldsymbol{\theta}(\boldsymbol{x})}=\boldsymbol{\theta}^ \mathrm{T}\boldsymbol{x}$，实际上是在用线性回归模型的预测结果去逼近样本真实标记为正例和反例的可能性的比值，即真实标记的对数几率。$g(z)$ 也叫做 `Logistic function` 或者 `Sigmoid function`。

![](sigmoid.png)

该函数的导数为：

$$g'(z)=\frac{d}{dz}\frac{1}{1+e^{-z}}=\frac{e^{-z}}{(1+e^{-z})^2}=g(z)\left(1-g(z)\right)$$

$z$ 趋于正无穷时，$g(z)$ 趋于 1；$z$ 趋于负无穷时，$g(z)$ 趋于 0。

$h_\boldsymbol{\theta}(\boldsymbol{x}) \geq 0.5$ 即 $\boldsymbol{\theta}^\mathrm{T}\boldsymbol{x}\geq0$ 表示是恶性肿瘤的可能性大于等于 50%，因此可以给定一个阈值例如就是 0.5，恶性肿瘤的可能性大于等于 50% 就判定是恶性肿瘤，否则判定不是恶性肿瘤。即
$$
y =
\begin{cases}
0 & h_\boldsymbol{\theta}(\boldsymbol{x}) < 0.5 \\\
1 & h_\boldsymbol{\theta}(\boldsymbol{x}) \geq 0.5
\end{cases}
$$
在判定是否为恶性肿瘤的时候，医生会更加注重召回率而不是准确率，“宁可杀错也不放过”，所以阈值可能会更小一些，例如只要有 40% 可能性就要判定为恶性肿瘤，然后进行治疗。

在对率回归中如果像线性回归模型一样将平方损失作为损失函数，那么目标函数为：

$$E_{\theta}=\sum_{i=1}^m(y^{(i)}-\frac{1}{1+e^{-\boldsymbol{\theta}^ \mathrm{T}\boldsymbol{x}^{(i)}}})^2$$

这是一个非凸函数，不容易求解，容易得到局部最优值。在对率回归中，经常使用最大似然的方法估计模型的参数，因此损失函数是基于最大似然估计推导得到的对数似然损失函数。

## 两大学派的争论

在学习最大似然估计之前先了解一下频率学派和贝叶斯学派对世界的认知。对事物建模时，用 $\theta$ 表示模型的参数，解决问题的本质就是求 $\theta$。例如通过抛硬币估计硬币正面朝上的概率 $P(head)=\theta$。

概率和似然都是指可能性，但是在统计学中，概率和似然有截然不同的用法。

- 概率：描述了已知参数 $\theta$ 时的随机变量的输出结果。例如已知参数 $\theta=0.5$ ，求抛 m 次硬币出现 n 次正面朝上的概率。
- 似然：描述已知随机变量输出结果时，未知参数 $\theta$ 的可能取值。例如已知抛 100 次硬币出现 50 次正面朝上，求参数 $\theta=x$ 的似然程度。

### 频率学派

根据随机重复事件的**频率**来考察**概率**。抛 10 次有 4 次正面朝上，则 $\theta=0.4$。当数据量趋于无穷时就可以得到精准的估计，当缺乏数据时则可能出现严重的偏差(过拟合)，例如对于一枚均匀的硬币，抛 10 次有 10 次正面朝上(这种情况的概率是 $\frac{1}{2^{10}}$)，频率学派会直接估计 $\theta=1$，然后预测抛这个硬币 100% 正面朝上。

### 贝叶斯学派

根据先验(Prior)概率和似然函数(Likelihood function)，计算后验(Posterior)概率。

贝叶斯公式如下：

$$P(\theta|X)=\frac{P(X|\theta)P(\theta)}{P(X)}$$

假设抛 10 次硬币是一次实验，$P(X)$ 相当于是一个归一化项，所以 $P(\theta|X)\propto{P(X|\theta)P(\theta)}$。

#### 先验概率 $P(\theta)$

观测到数据之前，一些关于参数 $\theta$ 的假设，即参数 $\theta$ 取某个值的概率。所以 $\theta$ 是一个随机变量，符合一定的概率分布。当先验分布是均匀分布时，贝叶斯方法等价于频率方法。一般伯努利分布把先验分布选择为 Beta 分布，因为它正比于 $\theta$ 和 $1-\theta$ 的幂指数，那么后验分布就会有和先验分布相同的函数形式(共轭性)，接下来观测到更多数据时后验分布就可以扮演先验分布的角色(详情见 PRML 2.1.1)。

下图为 Beta 分布的函数分布图，表示关于参数 $\theta$ 的假设。例如普通的硬币，Beta 分布的超参数 a 和 b 可以取 10，即抛 20 次硬币应该会有 10 次正面朝上和 10 次反面朝上。从图中可以看出，参数 $\theta$ 取 0.5 时先验概率最大，取其他值时先验概率比较小。

> 可以简单地把先验概率中的超参数 a 和 b 分别看出 x = 1 和 x = 0 的有效观测次数。

![](beta1.png)

如果对关于参数 $\theta$ 的假设的把握更大，即抛 100 次硬币应该会有 50 次正面朝上和 50 次反面朝上。那么参数 $\theta$ 取 0.5 的概率就更大，取其他值的概率就更小。

![](beta2.png)

#### 似然函数 $P(X|\theta)$

假设参数 $\theta$ 已知后观测到已有数据的概率，是关于参数 $\theta$ 的函数。例如抛 10 次硬币有 2 次正面朝上，那么似然函数

$$P(X|\theta)=\binom{10}{2}\theta^2(1-\theta)^8$$

函数图像如下图所示，从图中可以看出，参数 $\theta$ 取 0.2 时似然程度最大，取其他值时似然程度比较小。

![](beta3.png)

#### 后验概率 $P(\theta|X)$

通过似然函数修正后，参数 $\theta$ 取某个值的概率。参数 $\theta$ 的概率分布就是后验分布。

对于先验分布为超参数 a = b = 10 的 Beta 分布，似然函数 $P(X|\theta)=\binom{10}{2}\theta^2(1-\theta)^8$ ，可以算出对应的后验分布是超参数为 a = 12，b = 18 的 Beta 分布。

> 定量地描述不确定性，并且根据少量新的数据对不确定性进行精确的修改，对接下来要采取的动作进行修改，或者对最终的决策进行修改。

在贝叶斯学派和频率学派的观点中，似然函数都起着重要的作用，然而使用的方式有着本质的不同。频率学家观点认为参数 $\theta$ 是一个固定的参数，频率学派广泛使用最大似然估计，参数 $\theta$ 的值就是使似然函数 $P(X|\theta)$ 达到最大值的 $\theta$ 的值；贝叶斯学派则广泛使用最大后验估计，参数 $\theta$ 的值就是使后验分布 $P(\theta|X)\propto{P(X|\theta)P(\theta)}$ 达到最大值的 $\theta$ 的值。

贝叶斯观点的优点是包含了先验概率，相当于加了正则化项，避免产生过拟合。一个带有合理的先验分布的贝叶斯方法不会预测抛一枚普通的硬币会 100% 正面朝上，但是如果先验分布选择不好，贝叶斯方法也会有很大的可能给出错误的结果。

### 最大似然估计(MLE)

Maximun Likelihood Estimation 是频率学派广泛用的估计方法。假设数据 $X$是独立同分发布的一组抽样。那么 MLE 对 $\theta$ 的估计方法可以如下推导：
$$
\begin{align}
\hat\\theta_{MLE} & = \arg \max P(X;\theta) \\\
 & = \arg \min -log P(X;\theta)
\end{align}
$$

这里之所以用 $P(X;\theta)$ 而不是 $P(X|\theta)$ 是因为频率学派认为参数 $\theta$ 是固定的值(只是当前未知)而不是随机变量。最后要优化的函数被称为 Negative Log Likelihood (NLL)。

### 最大后验估计(MAP)

Maximum A Posteriori 是贝叶斯学派广泛使用的估计方法。假设数据 $X$ 是独立同分发布的一组抽样。那么 MAP 对 $\theta$ 的估计方法可以如下推导：
$$
\begin{align}
\hat\\theta_{MAP} & = \arg \max P(\theta|X) \\\
 & = \arg \min - log P(\theta|X) \\\
 & = \arg \min - log P(X|\theta)-log P(\theta)+log P(X) \\\
 & = \arg \min - log P(X|\theta)-log P(\theta)
\end{align}
$$


MLE 和 MAP 在优化时的不同就是在于先验项 $-log P(\theta)$。假设在某次实验中，先验分布是标准高斯分布，即参数 $\theta$ 满足标准高斯分布，则 $P(\theta) = Ce^{-\frac{\theta^2}{2}}$，$-log P(\theta) = C + \frac{\theta^2}{2}$。所以在 MAP 中选择标准高斯分布作为先验分布时就等价于在 MLE 中采用了 L2 的正则化项。

## 代价函数

由于无法使用均方误差作为代价函数，所以分析当真实标签为 1 时，我们希望 $h_\boldsymbol{\theta}(\boldsymbol{x})$ 尽可能接近于 $1^-$ ，即 $-log(h_\boldsymbol{\theta}(\boldsymbol{x}))$ 尽可能接近于 $0^+$，也就是最小化负对数。

![](cost.png)

同理可构造损失函数如下：

$$
loss\left(h_\boldsymbol{\theta}(\boldsymbol{x}), y\right) =
\begin{cases}
-log\left(h_\boldsymbol{\theta}(\boldsymbol{x})\right) & y=1 \\\
-log\left(1-h_\boldsymbol{\theta}(\boldsymbol{x})\right) & y=0
\end{cases}
$$
合并得损失函数为：$loss\left(h_\boldsymbol{\theta}(\boldsymbol{x}), y\right)=-ylog\left(h_\boldsymbol{\theta}(\boldsymbol{x})\right)-(1-y)log\left(1-h_\boldsymbol{\theta}(\boldsymbol{x})\right)$

所以对数似然代价函数为：
$$
J(\boldsymbol{\theta}) =-\frac{1}{m}\sum_{i=1}^m\Big(y^{(i)}log\left(h_\boldsymbol{\theta}(\boldsymbol{x}^{(i)})\right)+(1-y^{(i)})log\left(1-h_\boldsymbol{\theta}(\boldsymbol{x}^{(i)})\right)\Big)
$$
由 Sigmoid 函数的性质可知 $\frac{\partial{h_\boldsymbol{\theta}(\boldsymbol{x})}}{\partial{\theta_j}}=h_\boldsymbol{\theta}(\boldsymbol{x})(1-h_\boldsymbol{\theta}(\boldsymbol{x}))x_j$ ，所以在梯度下降求最优值时需要用到的梯度可以推导为：
$$
\begin{align}
\nabla_{\theta_j}J(\boldsymbol{\theta}) & = \frac{\partial{J(\boldsymbol{\theta})}}{\partial{\theta_j}} \\\
& = -\frac{1}{m}\sum_{i=1}^m\left(\frac{y^{(i)}}{h_\boldsymbol{\theta}(\boldsymbol{x}^{(i)})}\frac{\partial{h_\boldsymbol{\theta}(\boldsymbol{x}^{(i)})}}{\partial{\theta_j}}-\frac{1-y^{(i)}}{1-h_\boldsymbol{\theta}(\boldsymbol{x}^{(i)})}\frac{\partial{h_\boldsymbol{\theta}(\boldsymbol{x}^{(i)})}}{\partial{\theta_j}}\right) \\\
& = \frac{1}{m}\sum_{i=1}^m\left(h_\boldsymbol{\theta}(\boldsymbol{x}^{(i)})-y^{(i)}\right)x^{(i)}_j
\end{align}
$$
化简后发现和线性回归模型的代价函数一样。

## Softmax 回归

Softmax 回归是对率回归的推广，当类别数 K=2 的时候，Softmax 回归退化为对率回归。由于在模型中使用了 Softmax 函数，比较温和(soft)地输出样本属于各个类别的概率，而不是直接最可能属于的类别，因此叫做 Softmax 回归。

Softmax 函数或称**归一化指数函数**，是 Sigmoid 函数的一种推广。它能将一个含任意实数的 K 维向量 $\boldsymbol{z}$ “压缩”到另一个 K 维实向量 $\sigma(\boldsymbol{z})$ 中，使得每一个元素的范围都在 (0, 1) 之间，并且所有元素的和为 1。该函数的形式通常按下面的式子给出：
$$
\sigma(\boldsymbol{z})=\frac{1}{\sum_{i=1}^ke^{z_i}}\begin{bmatrix}
e^{z_1} \\\ 
e^{z_2} \\\ 
... \\\ 
e^{z_k}
\end{bmatrix}\quad
$$
Softmax 回归模型对于诸如 MNIST 手写数字分类等问题很有用。对于二分类问题，类标记 $y\in\lbrace0, 1\rbrace$；而在 K(K > 2) 分类问题中则是 $y\in\lbrace1, 2, …, k\rbrace$。例如，在 MNIST 数字识别任务中，10 个数字对应 K=10 个不同的类别。

对率回归的假设函数 $h_\boldsymbol{\theta}(\boldsymbol{x})=g(\boldsymbol{\theta}^ \mathrm{T}\boldsymbol{x})=\frac{1}{1+e^{-\boldsymbol{\theta}^ \mathrm{T}\boldsymbol{x}}}$ 计算的是样本属于正例的概率，由于只有两类，所以可以直接根据阈值进行判断。而 Softmax 回归则需要输出一个 K 维向量(元素和为 1，**归一化**)来表示样本属于每个类的概率，因此需要的模型参数也就更多。最后判断属于哪一类时则可以取最大的概率值对应的类别。
$$
h_\boldsymbol{\Theta}(\boldsymbol{x})=\begin{bmatrix}
p(y=1|\boldsymbol{x};\boldsymbol{\Theta}) \\\ 
p(y=2|\boldsymbol{x};\boldsymbol{\Theta}) \\\ 
... \\\ 
p(y=k|\boldsymbol{x};\boldsymbol{\Theta})
\end{bmatrix}=\frac{1}{\sum_{i=1}^ke^{\boldsymbol{\theta}^\mathrm{T}_i\boldsymbol{x}}}\begin{bmatrix}
e^{\boldsymbol{\theta}^\mathrm{T}_1\boldsymbol{x}} \\\ 
e^{\boldsymbol{\theta}^\mathrm{T}_2\boldsymbol{x}} \\\ 
... \\\ 
e^{\boldsymbol{\theta}^\mathrm{T}_k\boldsymbol{x}}
\end{bmatrix}\quad
其中 \boldsymbol{\Theta}=\begin{bmatrix}
-\boldsymbol{\theta}^\mathrm{T}_1- \\\ 
-\boldsymbol{\theta}^\mathrm{T}_2- \\\ 
... \\\ 
-\boldsymbol{\theta}^\mathrm{T}_k-
\end{bmatrix}
$$

### 代价函数

> 示性函数：1{值为真的表达式} = 1

对数似然代价函数 $J(\boldsymbol{\theta}) =-\frac{1}{m} \sum_{i=1}^m(y^{(i)}log(h_\boldsymbol{\theta}(\boldsymbol{x}^{(i)}))+(1-y^{(i)})log(1-h_\boldsymbol{\theta}(\boldsymbol{x}^{(i)})))$ 可以推广为：
$$
J(\boldsymbol{\Theta}) =-\frac{1}{m}\sum_{i=1}^m\sum_{j=0}^11\lbrace y^{(i)}=j\rbrace logp(y^{(i)}=j|\boldsymbol{x}^{(i)};\boldsymbol{\Theta})
$$
和对数依然一样可以理解为当真实标签为 j 时，要让预测为 j 类的概率值 $p(y^{(i)}=j|\boldsymbol{x}^{(i)};\boldsymbol{\Theta})$ 尽可能接近 $1^-$。因此 Softmax 回归的代价函数为：
$$
J(\boldsymbol{\Theta}) =-\frac{1}{m}\sum_{i=1}^m\sum_{j=1}^k1\lbrace y^{(i)}=j\rbrace log\frac{e^{\boldsymbol{\theta}\_j^\mathrm{T}\boldsymbol{x}^{(i)}}}{\sum_{l=1}^ke^{\boldsymbol{\theta}^\mathrm{T}_l\boldsymbol{x}^{(i)}}}
$$

计算梯度公式如下：
$$
\begin{align}
\frac{\partial{J(\boldsymbol{\Theta})}}{\partial{\boldsymbol{\theta}\_j}} = -\frac{1}{m} \sum_{i=1}^m\left(\boldsymbol{x}^{(i)}(1\lbrace y^{(i)}=j\rbrace-\frac{e^{\boldsymbol{\theta}\_j^\mathrm{T}\boldsymbol{x}^{(i)}}}{\sum_{l=1}^ke^{\boldsymbol{\theta}^\mathrm{T}_l\boldsymbol{x}^{(i)}}})\right)
\end{align}
$$

在使用中一般会添加权重衰减项(正则项) $\frac{\lambda}{2}\sum_{i=1}^k\sum_{j=0}^n\theta^2_{ij}$ 惩罚过大的参数值，其在 $\theta_j$ 方向上的梯度为 $\lambda\theta_j$。

## * 神经网络

> 神经网络中最基本的成分是神经元模型，在生物神经网络是，每个神经元与其他神经元相连，当它“兴奋”时，就会向相连的神经元发送化学物质，从而改变这些神经元内的电位；如果某神经元的电位超过了一个“阈值”，那么它就会被激活，即“兴奋”起来，向其他神经元发送化学物质。

根据神经元的定义，可以将对率回归看成是一个很简单的神经网络模型。即只有输入层和输出层，如下图所示(来自[Tensorflow](http://playground.tensorflow.org/#activation=sigmoid&batchSize=10&dataset=gauss&regDataset=reg-gauss&learningRate=0.03&regularizationRate=0&noise=40&networkShape=&seed=0.49707&showTestData=false&discretize=false&percTrainData=50&x=true&y=true&xTimesY=false&xSquared=false&ySquared=false&cosX=false&sinX=false&cosY=false&sinY=false&collectStats=false&problem=classification&initZero=false&hideText=false&stepButton_hide=false&noise_hide=false))：

![Logistic regression](https://randy-1251769892.cos.ap-beijing.myqcloud.com/logistic-regression.gif)

有隐藏层的神经网络的输出层就是一个对率回归，也就是一个线性分类器。输入层和中间的隐藏层可以看成特征提取的过程，就是把对率回归的输出当作特征，然后再将它送入下一个对率回归，一层层变换。由于激活函数是非线性函数，所以通过特征提取，就可以把原本线性不可分的数据变得线性可分。

## 参考文献

[1] 周志华. 机器学习. 清华大学出版社.  2016.

[2] 吴恩达. DeepLearning. 

[3] Ian Goodfellow, Yoshua Bengio, Aaron Courville. Deep Learning. 人民邮电出版社. 2017.

[4] Stephen Boyd, Lieven Vandenberghe. 凸优化. 清华大学出版社. 2017.

[5] Christopher M.Bishop. Pattern Recognition and Machine Learning. 2006.