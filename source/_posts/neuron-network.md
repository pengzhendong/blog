---
title: 单隐层神经网络
date: 2018-05-19 22:27:43
updated: 2018-05-19 23:44:14
tags: Deep Learning
mathjax: true
typora-root-url: ./neuron-network
---

## 前言

Logistic 回归和 Softmax 回归解决的是线性分类问题，即不同类别之间可以被线性平面分隔开，所以相当于没有隐藏层的神经网络。对于线性不可分的数据，由于线性模型无法理解任何两个特征间的相互作用，所以就需要有隐藏层(使用了非线性激活函数)的神经网络提取特征，将线性不可分的数据变得线性可分。

<!-- more -->

从输入层到输出层，向前计算代价函数的过程称为前向传播。从输出层到输出层，向后使用链式法则计算梯度的过程称为反向传播，得到梯度后就可以使用梯度下降算法更新模型的参数。最后可以得到比 Logistic 回归复杂得多的模型，拟合能力强但是也容易过拟合，由于代价函数不是凸函数，所以会给优化带来一些困难。

## 单隐层神经网络

单隐层神经网络相当于由多个对率回归模型组成。中间的隐藏层可以看成特征提取的过程，由于对率回归使用了非线性激活函数，所以通过特征提取，就可以把原本线性不可分的数据变得线性可分，最后通过输出层进行线性分类。

### 特征提取

> 隐藏层 $\vec z=\sigma(W\vec x+\vec b)$，其中 $\vec x$ 是输入向量，$\vec z$ 是输出向量，$W$ 是权重矩阵，$\vec b$ 是偏移向量，$\sigma()$ 是激活函数。每一层仅仅是把输入 $\vec x$ 经过简单的操作得到 $\vec y$。

在线性代数或者计算机图形学中学过，空间中的物体乘以一个矩阵就可以对物体进行放大/缩小、升维/降维或者旋转；加上一个向量就可以进行平移；这里的非线性激活函数还可以让物体变弯曲，如果使用线性函数作为激活函数，那么无论神经网络有多少层，输出都是输入的线性组合。

![](https://randy-1251769892.cos.ap-beijing.myqcloud.com/hidden-layer.gif)

因此每层神经网络的作用就是对输入使用线性变换和非线性变换，通过最小化代价函数使得在输出空间中尽量线性可分；

![](https://randy-1251769892.cos.ap-beijing.myqcloud.com/success.gif)

如果神经网络学习的效果不好，就会导致在输出空间中不能线性可分。

![](https://randy-1251769892.cos.ap-beijing.myqcloud.com/fail.gif)



可以在斯坦福大学的网站中体验单隐层神经网络的运行过程 [ConvNetJS demo: Classify toy 2D data](http://cs.stanford.edu/people/karpathy/convnetjs/demo/classify2d.html)

## 单隐层分类平面数据

以下内容基于 Deeplearning.ai 的 Neural Networks and DeepLearning 第三周的课程实验 `Planar data classification with one hidden layer`。

### 数据集

实验中通过添加噪声生成了一些非线性可分的二维数据：

``` python
# planar_utils.py 生成数据部分代码
for j in range(2):
    ix = range(N*j,N*(j+1))
    t = np.linspace(j*3.12,(j+1)*3.12,N) + np.random.randn(N)*0.2 # theta
    r = a*np.sin(4*t) + np.random.randn(N)*0.2 # radius
    X[ix] = np.c_[r*np.sin(t), r*np.cos(t)]
    Y[ix] = j
```

实验中使用了 `sklearn.linear_model.LogisticRegressionCV()` 数据进行分类，由于数据线性不可分，因此测试集的准确率只有 47%，因此需要使用多层神经网络进行分类。

### 神经网络模型

实验生成的数据是平面(二维)数据，因此输入是一个二维的向量，隐藏层具有四个神经元并且隐藏层使用的激活函数是 `Tanh` 函数，最后一层需要输出属于哪一类的概率，所以只能使用 Sigmoid 激活函数。

* Tanh 函数是双曲正切函数

  ![](/tanh.png)

  $$
  tanh(x)=\frac{sinhx}{coshx}=\frac{e^x-e^{-x}}{e^x+e^{-x}}
  $$
  
$$
  tanh'(x)=sech^2x=1-tanh^2x
  $$
  
Tanh 和 Sigmoid 函数可以通过缩放平移重合，为什么 Tanh 函数表现更好？Deep Learning 中给出的解释是：因为 Tanh 函数经过原点，且在原点附近梯度比 Sigmoid 函数的梯度大，所以在训练过程中优化会比较容易。
  
Tanh 和 Sigmoid 函数能否拟合任意函数呢？不能！首先来看一下什么叫 `Squashing` (压扁；压制)函数：
  
> A function $\Psi: R\to[0, 1]$ is a squashing function if it is non-decreasing, $\lim\limits_{\lambda \to \infty }{\Psi(\lambda)}=1$ and $\lim\limits_{\lambda \to -\infty }{\Psi(\lambda)}=0$.
  
显然 Tanh 函数通过缩放平移和 Sigmoid  函数满足这个定义，那么 Squashing 函数有什么性质呢？Hornik 等人在 1989 年中的一篇文章中说道：即使单隐层神经网络，用任意的 Squashing 函数作为激活函数，当神经元数量足够多时，可以拟合任意的博雷尔可测(Borel measurable)函数。那么博雷尔不可测函数又是什么意思呢？
  
定义集合 $S$ 为一个博雷尔不可测集合，有
  $$
  f(x) =
  \begin{cases}
  0 & x \not\in S \\\
  1 & x \in S
  \end{cases}
  $$
  则函数 $f(x)$ 就是博雷尔不可测函数。那么博雷尔不可测集合又是什么呢？这就触及到我的知识盲区了，总之用 Squashing 函数拟合实际问题中的函数是绰绰有余的，也不难想象足够多的 Squashing 函数的线性组合确实能拟合很多函数了。
  
* 模型结构：

对于一个样本数据 $x^{(i)}$，有：
$$
z^{[1] (i)} =  W^{[1]} x^{(i)} + b^{[1]}\tag{1}
$$

$$
a^{[1] (i)} = \tanh(z^{[1] (i)})\tag{2}
$$

$$
z^{[2] (i)} = W^{[2]} a^{[1] (i)} + b^{[2]}\tag{3}
$$

$$
\hat{y}^{(i)} = a^{[2] (i)} = \sigma(z^{ [2] (i)})\tag{4}
$$

$$
y^{(i)}\_{prediction} =
\begin{cases}
1 & \mbox{if}\quad a^{[2]\(i\)} > 0.5 \\\
0 & \mbox{otherwise} 
\end{cases}\tag{5}
$$

给定所有样本数据，代价函数为：
$$
J = - \frac{1}{m} \sum\limits_{i = 0}^{m} \left(y^{(i)}\log(a^{[2] (i)}) + (1-y^{(i)})\log(1- a^{[2] (i)})\right)\tag{6}
$$
这里的 $a^{[2] (i)}$ 就是最后一层(不算输入层即第二层)神经网络的输出，类似于对率回归中的 $h_\theta(x^{(i)})$。

构建神经网络模型主要分为以下几部分：

1. 定义神经网络结构(神经元的个数、隐藏层的层数等)
2. 初始化模型参数
3. 循环
   * 实现前向传播(实现公式 1~4，得到预测值 $\hat y$，即 $a^{[2]}$)
   * 计算代价(根据前向传播得到的预测值和测试集的标签，实现公式 6，得到代价)
   * 实现反向传播，计算梯度
   * 梯度下降更新模型参数

#### 定义神经网络结构

在生成的实验数据中，`X.shape = (2, 400)`、`y.shape = (1, 400)`，因此输入层的神经元个数 $n^{[x]}=2$；隐藏层的神经元个数定义为 $n^{[h]}=4$；输出层神经元的个数 $n^{[y]}=1$。

``` python
def layer_sizes(X, Y):
    n_x = X.shape[0] # size of input layer
    n_h = 4
    n_y = Y.shape[0] # size of output layer
    
    return (n_x, n_h, n_y)
```

#### 初始化模型参数

使用 `np.random.randn(a, b)` 初始化一个形状为 `(a, b)` 的矩阵，使其元素为标准正态分布中的样本。使用 `np.zeros((a, b))` 初始化一个形状为 `(a, b)` 的矩阵，使其各元素值为 0。

* 如果权值全部初始化为相同的数，那么隐藏层中神经元的输出就都是一样的，通过归纳法可以归纳出这些隐藏层的神经元一直在计算完全一样的函数，所以需要随机初始化打破对称性；
* 如果权值全部初始化为 0，更加糟糕的是不管输入是什么，隐藏层中神经元的输出就都是 0；
* 如果初始化为比较大的数，那么就会导致激活函数输出的值比较大，梯度较小，梯度下降的速度较慢，所以需要初始化为 0 附近的随机数。 

``` python
def initialize_parameters(n_x, n_h, n_y):
    W1 = np.random.randn(n_h, n_x) * 0.01
    b1 = np.zeros((n_h, 1))
    W2 = np.random.randn(n_y, n_h) * 0.01
    b2 = np.zeros((n_y, 1))
    
    parameters = {"W1": W1,
                  "b1": b1,
                  "W2": W2,
                  "b2": b2}
```

#### 循环

##### 前向传播

在前向传播计算预测值时需要缓存中间变量 $A^{[1]}$，用于反向传播计算梯度 $dW^{[2]}$。在实验中也缓存了所有中间变量包括 $Z^{[1]}$ 和 $Z^{[2]}$。

``` python
def forward_propagation(X, parameters):
    W1 = parameters["W1"]
    b1 = parameters["b1"]
    W2 = parameters["W2"]
    b2 = parameters["b2"]

    Z1 = np.dot(W1, X) + b1
    A1 = np.Tanh(Z1)
    Z2 = np.dot(W2, A1) + b2
    A2 = Sigmoid(Z2)
    
    cache = {"Z1": Z1,
             "A1": A1,
             "Z2": Z2,
             "A2": A2}
    
    return A2, cache
```

##### 计算代价

``` python
def compute_cost(A2, Y, parameters):
    m = Y.shape[1] # number of example

    logprobs = np.multiply(np.log(A2), Y) + np.multiply(np.log(1 - A2), 1 - Y)
    cost = - (1.0 / m) * np.sum(logprobs)
    cost = np.squeeze(cost)     # makes sure cost is the dimension we expect. 
    
    return cost
```

##### 反向传播

为了快速计算，实验对所有样本数据使用向量化编程。同时为了表示简单，以下求导公式省去上标 `(i)`。所以对于一个样本数据的输入、隐藏层输入、隐藏层输出和标签分别用小写字母 `x`、`z`、`a` 和 `y` 表示；所有样本数据则对应大写字母 `X`、`Z`、`A` 和 `Y`。

* 对于一个样本数据 $x$ (随机梯度下降)，有：

$$
\mathscr{l}(\hat y, y)=-\left(y^{(i)}\log(a^{[2] (i)}) + (1-y^{(i)})\log(1- a^{[2] (i)})\right)
$$


$$
\begin{align}
dz^{[2]}=\frac{\partial{\mathscr{l}(\hat y, y)}}{\partial{z^{[2]}}} & = -\left(\frac{y}{a^{[2]}}\sigma'(z^{[2]})+\frac{1-y^{(i)}}{1-a^{[2]}}\sigma'(z^{[2]})\right) \\\
& = a^{[2]}-y
\end{align}
$$

$$
\begin{align}
dW^{[2]}=\frac{\partial{\mathscr{l}(\hat y, y)}}{\partial{z^{[2]}}}\frac{\partial{z^{[2]}}}{\partial{W^{[2]}}}
& = dz^{[2]}a^{[1]\mathrm{T}}
\end{align}
$$

$$
db^{[2]}=\frac{\partial{\mathscr{l}(\hat y, y)}}{\partial{z^{[2]}}}\frac{\partial{z^{[2]}}}{\partial{b^{[2]}}}=dz^{[2]}
$$

$$
\begin{align}
dz^{[1]} = W^{[2]\mathrm{T}}dz^{[2]}*\left(1-tanh^2(z)\right) = W^{[2]\mathrm{T}}dz^{[2]}*(1-a^{[1]2})
\end{align}
$$

$$
dW^{[1]}=dz^{[1]}x^{\mathrm{T}}
$$

$$
db^{[1]}=dz^{[1]}
$$

导数写在左边还是右边？是否需要转置？点乘还是叉乘？在矩阵求导中有[两种布局](https://en.wikipedia.org/wiki/Matrix_calculus)：分子布局和分母布局，不同布局求导规则不一样 。但是在实验中，我们已知各个变量和导数的维度，所以只需要根据数据的维度计算选择布局即可($dfoo.shape=foo.shape$)。例如：
$$
dz^{[1]}=da^{[1]}*\frac{\partial{a^{[1]}}}{\partial{z^{[1]}}}=W^{[2]\mathrm{T}}dz^{[2]}*(1-a^{[1]2})
$$
$m$ 表示样本数量($m = 1$)，由于 $a^{[1]}$ 和 $z^{[1]}$ 只是进行了一个非线性变换，具有相同的维度，所以用点乘；所以只需要求 $da^{[1]}$ 且满足 $da^{[1]}.shape=(n^{[h]}, m)$：
$$
(n^{[h]}, m) = (n^{[y]}, n^{[h]})^{\mathrm{T}}(n^{[y]}, m) = (n^{[h]}, n^{[y]})(n^{[y]}, m)
$$

* 对于所有样本数据，有：

$$
dZ^{[2]}=A^{[2]}-Y
$$

$$
dW^{[2]}=\frac{1}{m}dZ^{[2]}A^{[1]\mathrm{T}}
$$

$$
db^{[2]}=\frac{1}{m}\sum\limits_{i = 0}^{m}dZ^{[2]}
$$

$$
dZ^{[1]}=W^{[2]\mathrm{T}}dZ^{[2]}*(1-A^{[1]2})
$$
$$
dW^{[1]}=\frac{1}{m}dZ^{[1]}X^{\mathrm{T}}
$$

$$
db^{[1]}=\frac{1}{m}\sum\limits_{i = 0}^{m}dZ^{[1]}
$$

``` python
def backward_propagation(parameters, cache, X, Y):
    m = X.shape[1]
    
    W1 = parameters["W1"]
    W2 = parameters["W2"]
    A1 = cache['A1']
    A2 = cache['A2']

    dZ2 = A2 - Y
    dW2 = (1.0 / m) * np.dot(dZ2, A1.T)
    db2 = (1.0 / m) * np.sum(dZ2, axis=1, keepdims=True)
    dZ1 = np.dot(W2.T, dZ2) * (1 - np.power(A1, 2))
    dW1 = (1.0 / m) * np.dot(dZ1, X.T)
    db1 = (1.0 / m) * np.sum(dZ1, axis=1, keepdims=True)
    
    grads = {"dW1": dW1,
             "db1": db1,
             "dW2": dW2,
             "db2": db2}
    
    return grads
```

##### 梯度下降更新模型参数

> 梯度下降规则：$\theta = \theta - \alpha \frac{\partial J }{ \partial \theta }$

在[线性回归](/2018/03/10/Linear-regression/)中总结过，在梯度下降中好的学习率可以快速收敛，不好的学习率则会发散(实验中默认学习率为1.2)，如下图所示：

![](https://randy-1251769892.cos.ap-beijing.myqcloud.com/sgd.gif)

![](https://randy-1251769892.cos.ap-beijing.myqcloud.com/sgd_bad.gif)

``` python
def update_parameters(parameters, grads, learning_rate = 1.2):
    W1 = parameters["W1"]
    b1 = parameters["b1"]
    W2 = parameters["W2"]
    b2 = parameters["b2"]

    dW1 = grads["dW1"]
    db1 = grads["db1"]
    dW2 = grads["dW2"]
    db2 = grads["db2"]

    W1 = W1 - learning_rate * dW1
    b1 = b1 - learning_rate * db1
    W2 = W2 - learning_rate * dW2
    b2 = b2 - learning_rate * db2
    
    parameters = {"W1": W1,
                  "b1": b1,
                  "W2": W2,
                  "b2": b2}
    
    return parameters
```

### 集成模型

集成单隐层神经网络的所有模块：

``` python
def nn_model(X, Y, n_h, num_iterations = 10000, print_cost=False):
    np.random.seed(3)
    n_x = layer_sizes(X, Y)[0]
    n_y = layer_sizes(X, Y)[2]
    
    parameters = initialize_parameters(n_x, n_h, n_y)
    W1 = parameters["W1"]
    b1 = parameters["b1"]
    W2 = parameters["W2"]
    b2 = parameters["b2"]

    for i in range(0, num_iterations):
        A2, cache = forward_propagation(X, parameters)
        cost = compute_cost(A2, Y, parameters)
        grads = backward_propagation(parameters, cache, X, Y)
        parameters = update_parameters(parameters, grads)

        if print_cost and i % 1000 == 0:
            print("Cost after iteration %i: %f" %(i, cost))

    return parameters
```

### 预测

最后要根据神经网络的输出和阈值，预测输出，即实现公式 5：

``` python
def predict(parameters, X):
    A2, cache = forward_propagation(X, parameters)
    predictions = A2 > 0.5
    
    return predictions
```

### 评估分析

``` python
parameters = nn_model(X, Y, n_h = 4, num_iterations = 10000, print_cost=True)
plot_decision_boundary(lambda x: predict(parameters, x.T), X, Y)
plt.title("Decision Boundary for hidden layer size " + str(4))
```

对实验数据进行学习分类，最后输出分类准确率高达 90%，通过调节隐藏层神经元个数，可以发现模型越大(隐藏层神经元越多)，则模型的拟合能力越强，但是达到一定程度后就会对训练集产生过拟合(可以添加正则化项避免过拟合)。本次实验数据结果发现隐藏层神经元个数为 5 的时候拟合能力最好。

## 参考文献

[1] 吴恩达. DeepLearning. 

[2] Ian Goodfellow, Yoshua Bengio, Aaron Courville. Deep Learning. 人民邮电出版社. 2017.

[3] Hornik, K., Stinchcombe, M., & White, H. (1989). Multilayer feedforward networks are universal approximators. *Neural networks*, *2*(5), 359-366.