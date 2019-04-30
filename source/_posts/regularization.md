---
title: 正则化
date: 2018-05-29 15:26:54
updated: 2018-05-29 18:12:08
tags: Machine Learning
mathjax: true
---

## 前言

在机器学习中，当训练数据太少或者模型过于复杂等情况，当模型学习了数据的噪声的细节，那么模型在未知的数据表现就会不好，即泛化误差比训练误差大，这就是过拟合。模型选择的典型方法是正则化，使用正则化技术可以很大程度上减缓过拟合问题。

<!-- more -->

## “没有免费的午餐”定理(NFL)

“没有免费的午餐”定理表明，在机器学习中无论是瞎猜还是一些很牛的算法，它的期望性能都相同。也就是说，考虑**所有可能**的目标函数，没有哪个算法比其他算法高效。如果要想在某些问题上得到性能的提高，必须在一些问题上付出同等代价！就像算法的时间复杂度和空间复杂度。

符号说明：

* $\mathcal{X}$：样本空间(离散)
* $\mathcal{H}$：假设空间(离散)，例如在线性回归中我们假设数据满足某种线性关系
* $P(h|X, \mathcal{L}a)$：算法 $\mathcal{L}a$ 基于训练数据 $X$ 产生假设 $h$ 的概率
* $f$：真实目标函数
* $E_{ote}(\mathcal{L}a|X, f)$：算法 $\mathcal{L}a$ 的训练集外误差(Off-trainning error)，即算法 $\mathcal{L}a$ 在x 训练集之外的所有样本上的误差

对于一个特定问题，即真实目标函数确定，算法 $\mathcal{L}a$ 的训练集外误差为：
$$
E_{ote}(\mathcal{L}a|X, f) = \sum_{h}\sum_{x\in \mathcal{X}-X}P(x)1\lbrace h(x)\neq f(x)\rbrace P(h|X, \mathcal{L}a)
$$
对于二分类问题，真实目标函数一共有 $2^{\lvert\mathcal{X}\rvert}$ 个，且均匀分布。对于一个真实目标函数，一个假设 $h$ 的输出有 $\frac{1}{2}$ 的可能与真实目标函数相等。 所以对于所有可能的目标函数，算法 $\mathcal{L}a$ 的训练集外误差为：
$$
\begin{align}
\sum_{f}E_{ote}(\mathcal{L}a|X, f) &= \sum_{f}\sum_{h}\sum_{x\in \mathcal{X}-X}P(x)1\lbrace h(x)\neq f(x)\rbrace P(h|X, \mathcal{L}a) \\\
&= \sum_{x\in \mathcal{X}-X}P(x)\sum_{h}P(h|X, \mathcal{L}a)\sum_{f}1\lbrace h(x)\neq f(x)\rbrace \\\
&= \sum_{x\in \mathcal{X}-X}P(x)\sum_{h}P(h|X, \mathcal{L}a)\frac{1}{2}2^{\lvert\mathcal{X}\rvert} \\\
&= 2^{\lvert\mathcal{X}\rvert-1}\sum_{x\in \mathcal{X}-X}P(x)\cdot 1
\end{align}
$$

对于所有可能的目标函数，一个算法最终的总误差和这个算法无关。没有任何一个算法能够解决所有问题，在现实生活中我们有一套先验知识来判断哪些更优，这些先验知识包含简单性(“奥卡姆剃刀”原理)，平滑性等等，所以我们就应该更具这些先验知识来具体问题具体分析。

> NFL定理最重要的寓意是让我们清楚地认识到：脱离具体问题，空泛地谈论”什么学习算法更好“毫无意义。因为若考虑所有潜在的问题，则所有的算法一样好，要谈论算法的相对优劣，必须要针对具体问题；在某些问题上表现好的学习算法，在另一问题上却可能不尽如人意，学习算法自身的归纳偏好与问题是否相配，往往会起到决定性作用.

## “奥卡姆剃刀”原理

> 如无必要，勿增实体。

意思是相比较于复杂的假设，我们更倾向于选择简单的、参数少的假设。如果线性回归和高阶的多项式回归在某个问题上的表现相似(例如训练误差相同)，那么我们应该选择较为简单的线性回归。从贝叶斯估计的角度来看，简单的模型有较大的先验概率，毕竟一个高阶多项式随机采样的数据呈线性的概率太小了。

## 正则化

大部分正则化通过在代价函数上加一个正则项或者惩罚项，让算法在训练过程中尽量学习一个简单的模型，即满足“奥卡姆剃刀”原理，这样就可以减缓过拟合的发生。正则化项大概有以下几类：

* L0 正则化：L0 正则化的值是模型参数中非零参数的个数(0范数)。稀疏的参数可以让模型变得简单，但是 L0 正则化难于求解。
* L1(Lasso) 正则化：L1 正则化的值是模型各个参数的绝对值之和(1范数)，也会获得稀疏的参数。
* L2(Ridge) 正则化：L2 正则化的值是模型各个参数的平方之和(2范数的平方，平方是为了易于优化)，也称为权重衰减，因为最后会获得值很小的参数。
* Dropout：在深度学习的训练过程中，按照一定的概率随机让一些神经元结点失活。
* 数据增广：例如通过对图像进行旋转、扭曲等操作，获得更多的训练数据。
* Early stop：在泛化误差上升之前，停止网络的训练，缺点是会导致 $J$ 被优化得不够小。
* ...

### L1 正则化

$$
J(\boldsymbol{w})=\frac{1}{m}\sum_{i=1}^m\mathcal{L}(\hat y^{(i)}, y^{(i)})+\frac{\lambda}{m}\Vert\boldsymbol{w}\Vert_1
$$

$$
dw_i=\frac{\partial J}{\partial w_i}=\frac{\lambda}{2m}sign(w_i)=\pm\frac{\lambda}{m}
$$

$$
w_i=w_i-\alpha dw_i=w_i\mp\frac{\alpha\lambda}{m}
$$

通过梯度下降最小化代价函数时，更新参数 $w_i$ 每次都会加减一个固定的数，往 0 逼近，多次迭代后则有可能变成成 0，稀疏的参数可以用于特征选择。

### L2 正则化

$$
J(\boldsymbol{w})=\frac{1}{m}\sum_{i=1}^m\mathcal{L}(\hat y^{(i)}, y^{(i)})+\frac{\lambda}{2m}\Vert\boldsymbol{w}\Vert_2^2
$$

$$
dw_i=\frac{\partial J}{\partial w_i}=\frac{\lambda}{m}w_i
$$

$$
w_i=w_i-\alpha dw_i=(1-\frac{\alpha\lambda}{m})w_i
$$

通过梯度下降最小化代价函数时，更新参数 $w_i$ 每次都会乘以 $(1-\frac{\alpha\lambda}{m})$ 这个小于 1 的数(权重衰减)，往 0 逼近，多次迭代后也只能是更加逼近 0 而不会等于 0。Xavier [表示](https://www.quora.com/What-is-the-difference-between-L1-and-L2-regularization-How-does-it-solve-the-problem-of-overfitting-Which-regularizer-to-use-and-when)，除非需要稀疏的参数进行特征选择，在实际应用中，L2 总是比 L1 好，所以推荐使用 L2 正则化。

惩罚参数 $\lambda$ 增大则参数 $\boldsymbol{w}$ 减小。在神经网络中，如果参数值逼近 0，则该神经元结点对结果的影响也逼近 0，因此可以有效减缓过拟合。如果一个神经网络的激活函数是 Tanh 函数，而且所有参数值都逼近 0，那么神经元结点的输入就约等于输出(Tanh 函数原点处大致呈线性)，最终不管网络多深，都只能计算线性函数。

#### 前向传播

$$
J_{regularized} = \small \underbrace{-\frac{1}{m} \sum\limits_{i = 1}^{m} \large{(}\small y^{(i)}\log\left(a^{[L]\(i\)}\right) + (1-y^{(i)})\log\left(1- a^{[L]\(i\)}\right) \large{)} }_\text{cross-entropy cost} + \underbrace{\frac{1}{m} \frac{\lambda}{2} \sum\limits_l\sum\limits_k\sum\limits_j W_{k,j}^{[l]2} }_\text{L2 regularization cost}
$$

``` python
def compute_cost_with_regularization(A3, Y, parameters, lambd):
    m = Y.shape[1]
    W1 = parameters["W1"]
    W2 = parameters["W2"]
    W3 = parameters["W3"]
    
    cross_entropy_cost = compute_cost(A3, Y) # This gives you the cross-entropy part of the cost
    L2_regularization_cost = lambd * (np.sum(np.square(W1)) + np.sum(np.square(W2)) + np.sum(np.square(W3))) / (2 * m)
    
    cost = cross_entropy_cost + L2_regularization_cost
    
    return cost
```

#### 反向传播

$$
\frac{d}{dW} ( \frac{1}{2}\frac{\lambda}{m}  W^2) = \frac{\lambda}{m} W
$$

``` python
def backward_propagation_with_regularization(X, Y, cache, lambd):
    m = X.shape[1]
    (Z1, A1, W1, b1, Z2, A2, W2, b2, Z3, A3, W3, b3) = cache
    
    dZ3 = A3 - Y
    dW3 = 1. / m * np.dot(dZ3, A2.T) + (lambd * W3) / m
    db3 = 1. / m * np.sum(dZ3, axis=1, keepdims=True)
    dA2 = np.dot(W3.T, dZ3)
    dZ2 = np.multiply(dA2, np.int64(A2 > 0))
    dW2 = 1. / m * np.dot(dZ2, A1.T) + (lambd * W2) / m
    db2 = 1. / m * np.sum(dZ2, axis=1, keepdims=True)
    dA1 = np.dot(W2.T, dZ2)
    dZ1 = np.multiply(dA1, np.int64(A1 > 0))
    dW1 = 1. / m * np.dot(dZ1, X.T) + (lambd * W1) / m
    db1 = 1. / m * np.sum(dZ1, axis=1, keepdims=True)
    
    gradients = {"dZ3": dZ3, "dW3": dW3, "db3": db3, "dA2": dA2,
                 "dZ2": dZ2, "dW2": dW2, "db2": db2, "dA1": dA1, 
                 "dZ1": dZ1, "dW1": dW1, "db1": db1}
    
    return gradients
```

### Dropout

Dropout 也就是随机失活，通常用于计算机视觉领域，因为特征比较多。每个神经元结点都以固定的概率 `keep-prob` 随机保留，但是在 Dropout 后为了不影响 $Z$ 的期望而导致梯度消失，$Z=Z/keep-prob$，神经网络的训练过程如下所示：

<video width="620" height="440" src=" https://randy-1251769892.cos.ap-beijing.myqcloud.com/dropout.mp4" type="video/mp4" controls>
</video>

对于整个网络来说，随机失活后导致网络规模变小，减缓了过拟合的发生。对于每一个神经元结点，由于它的输入随时都有可能失活，因此训练后任何一个输入的权重都不会太大，由于这个神经元自己本身也可能失活，因此 Dropout 将产生**类似** L2 正则化的权重衰减的效果，但是只有当 Dropout 用于线性回归时才**相当于** L2 权重衰减。

Dropout 也可以被近似认为是集成大量深层神经网络的 Bagging 方法(结合多个模型降低泛化误差)，不太一样的地方是 Bagging 中所有模型都是独立的，而 Dropout 中所有模型共享参数。当可用训练样本太少时(例如 5000)，Dropout 的效果不会很好。

#### 前向传播

在前向传播时，需要生成失活矩阵 `D`，前向传播后需要缓存 `D` 用于反向传播。需要注意的是，Dropout 会导致代价函数不明确，因此可以先不 Dropout 观察代价函数是否下降，然后在开启 Dropout；同时在测试的时候不能开启 Dropout 。

``` python
def forward_propagation_with_dropout(X, parameters, keep_prob=0.5):
    np.random.seed(1)
    
    # retrieve parameters
    W1 = parameters["W1"]
    b1 = parameters["b1"]
    W2 = parameters["W2"]
    b2 = parameters["b2"]
    W3 = parameters["W3"]
    b3 = parameters["b3"]
    
    # LINEAR -> RELU -> LINEAR -> RELU -> LINEAR -> SIGMOID
    Z1 = np.dot(W1, X) + b1
    A1 = relu(Z1)
    D1 = np.random.rand(A1.shape[0], A1.shape[1])     # Step 1: initialize matrix D1 = np.random.rand(..., ...)
    D1 = D1 < keep_prob                            # Step 2: convert entries of D1 to 0 or 1 (using keep_prob as the threshold)
    A1 = A1 * D1                                      # Step 3: shut down some neurons of A1
    A1 = A1 / keep_prob                               # Step 4: scale the value of neurons that haven't been shut down
    Z2 = np.dot(W2, A1) + b2
    A2 = relu(Z2)
    D2 = np.random.rand(A2.shape[0], A2.shape[1])     # Step 1: initialize matrix D2 = np.random.rand(..., ...)
    D2 = D2 < keep_prob                           # Step 2: convert entries of D2 to 0 or 1 (using keep_prob as the threshold)                           
    A2 = A2 * D2                                      # Step 3: shut down some neurons of A2
    A2 = A2 / keep_prob                               # Step 4: scale the value of neurons that haven't been shut down
    Z3 = np.dot(W3, A2) + b3
    A3 = sigmoid(Z3)
    
    cache = (Z1, D1, A1, W1, b1, Z2, D2, A2, W2, b2, Z3, A3, W3, b3)
    
    return A3, cache
```

#### 反向传播

``` python
def backward_propagation_with_dropout(X, Y, cache, keep_prob): 
    m = X.shape[1]
    (Z1, D1, A1, W1, b1, Z2, D2, A2, W2, b2, Z3, A3, W3, b3) = cache
    
    dZ3 = A3 - Y
    dW3 = 1. / m * np.dot(dZ3, A2.T)
    db3 = 1. / m * np.sum(dZ3, axis=1, keepdims=True)
    dA2 = np.dot(W3.T, dZ3)
    dA2 = dA2 * D2              # Step 1: Apply mask D2 to shut down the same neurons as during the forward propagation
    dA2 = dA2 / keep_prob              # Step 2: Scale the value of neurons that haven't been shut down
    dZ2 = np.multiply(dA2, np.int64(A2 > 0))
    dW2 = 1. / m * np.dot(dZ2, A1.T)
    db2 = 1. / m * np.sum(dZ2, axis=1, keepdims=True)
    
    dA1 = np.dot(W2.T, dZ2)
    dA1 = dA1 * D1              # Step 1: Apply mask D1 to shut down the same neurons as during the forward propagation
    dA1 = dA1 / keep_prob              # Step 2: Scale the value of neurons that haven't been shut down
    dZ1 = np.multiply(dA1, np.int64(A1 > 0))
    dW1 = 1. / m * np.dot(dZ1, X.T)
    db1 = 1. / m * np.sum(dZ1, axis=1, keepdims=True)
    
    gradients = {"dZ3": dZ3, "dW3": dW3, "db3": db3,"dA2": dA2,
                 "dZ2": dZ2, "dW2": dW2, "db2": db2, "dA1": dA1, 
                 "dZ1": dZ1, "dW1": dW1, "db1": db1}
    
    return gradients
```



## 参考文献

[1] 吴恩达. DeepLearning. 

[2] Ian Goodfellow, Yoshua Bengio, Aaron Courville. Deep Learning. 人民邮电出版社. 2017.

[3] 周志华. 机器学习. 清华大学出版社.  2016.

[4] 李航. 统计学习方法. 清华大学出版社.  2017.