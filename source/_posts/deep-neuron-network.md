---
title: 深度神经网络
date: 2018-05-21 13:56:22
updated: 2018-05-21 15:54:16
tags: Deep Learning
mathjax: true
typora-root-url: ./deep-neuron-network
---

## 前言

为什么需要深度学习？为什么需要多个隐藏层？隐藏层中神经元的数量越多拟合能力不就越强吗？这个问题困惑了我好久，说白了就是书读的太少，想得太多。吴恩达用电路理论和二叉树解决了我这个困惑！

<!-- more -->

## 电路理论和深度学习

> There are functions you can compute with a "small" L-layer deep nerual network that shallower networks require exponentiall more hidden units to compute.

也就是说有一些函数，一个很小的 L 层深度神经网络就能实现，而浅层神经网络需要的神经元的数量是指数级别的。例如异或操作，对于三维数据，深度神经网络的拟合为：$x_1\oplus x_2\oplus x_3=(x_1\oplus x_2)\oplus x_3$，浅层神经网络拟合为：$x_1\oplus x_2\oplus x_3=x_1\cdot x_2\cdot x_3+x'_1\cdot x'_2\cdot x_3+x'_1\cdot x_2\cdot x'_3+x_1\cdot x'_2\cdot x'_3$；所以深度神经网络的层数也就是二叉树的高度 $O(logn)$，神经元的数量不会很大，而单隐层神经网络需要的神经元的个数则是 $2^{n-1}$ 个，指数爆炸！

## 深度神经网络模型

深度神经网络模型和单隐层神经网络模型的模块一样，只不过深度神经网络模型的隐藏层不止一个。在单隐层神经网络的隐藏层中使用了 `Tanh` 激活函数，而现在更加常用的激活函数是 `ReLU` (线性整流)函数。

### ReLU

ReLU 函数是一个分段函数，其函数图如下图所示：

![](/ReLU.png)
$$
ReLU(x)=max(0, x)
$$
这是一个非线性函数，当 $x<0$ 时，$ReLu(x)=0$，梯度为 0；当 $x\geq 0$ 时，$ReLu(x)=x$，梯度为 1。

#### Squashing 函数

第一次看到 ReLU 函数，就觉得它虽然是非线性的，但是它不是 Squashing 函数啊！可以通过两个 ReLU 神经元的叠加，构造一个 Squashing 函数：
$$
\Psi(x)=ReLU(x)-ReLU(x-1)=max(0, x)-max(0, x-1)
$$
使用 ReLU 函数作为激活函数的最大好处是激活状态的神经元的梯度不会消失，且梯度固定可以加快学习速度；其次，对于**每个样本数据**，一部分神经元输出为 0 造成了网络的稀疏性，缓解了过拟合问题的发生。虽然**每个样本数据**经过神经网络后的输出都是输入的线性组合，但是不同的输入激活的神经元是不同的，正是因为这种变换引入了非线性。例如单隐层神经网络拟合 $f(x)=x^2$:

* 两个神经元：

$$
h_1(x)=ReLU(x)+ReLU(-x)=|x|
$$

* 四个神经元：
  $$
  h_2(x)=ReLU(x)+ReLU(-x)+2ReLU(x-1)+2ReLU(-x-1)
  $$

多个 ReLU 神经元叠加确实可以拟合出各种形状，所以只要神经元个数足够多，拟合实际问题中的函数就卓卓有余。

#### 神经元坏死

ReLU 函数也有其缺点，那就是神经元容易“坏死”。如果**所有样本数据**都不能激活某个神经元(即不管输入是什么，输出都一样)，那么 <font color="red">ReLU 函数的梯度 $g'()$ 为 0</font>，在反向传播的时候参数就不会被更新，迭代后还是一样：
$$
dW^{[l]} \propto g'(Z^{[l]})
$$
学习率过大或者参数 $w_1$ 的梯度过大，$w_1$ 的变化就会很大，原来 $w_1x_1+w_2x_2+b$ 对于不同的样本数据，输出可能有正有负，现在很有可能就只出现负数。对于第一层隐藏层的神经元，一旦坏死就再也无法被激活；对于第二层及以后的神经元，由于它的输入(上一层的输出)也是别的神经元的输入，所以上一层的输出更新后有可能再次激活这个坏死的神经元。

ReLU 的变种 Leaky ReLU 可以一定程度上克服神经元坏死的问题。由于在使用深度学习模型的时候，训练数据的维度比较大，对于部分神经元坏死还是可以接受的。

#### 参数初始化

既然 ReLU 函数避免了过饱和，那么在初始化参数的时候为什么还要从 (0, 1) 正态分布里抽样呢？首先分析一下以下几种情况：

* $W$ 都初始化成绝对值大于 1 的数：最后输入 Sigmoid 函数的值就会指数爆炸💥，$sigmoid(x)=\frac{1}{1+e^{-x}}$，而 `np.exp(710)` 溢出；代价函数中包含 $log(1-a)$，其中 $a=sigmoid(x)$，而 `np.exp(-37)=1` 导致代价函数包含 $log(0)$ 产生运行时警告。

* 因此 $W$ 需要在 $(-1, 1)$ 之间采样，前面分析过不能都初始化为 0；如果全部在 $(-1, 0)$ 或者 $(0, 1)$ 之间采样则 ReLU 函数是线性的，学习能力较差。

* $W$ 都初始化成满足 $(0, 1)$ 正态分布的绝对值**特别小**的数：$dW^{[l]} \propto W^{[l+1]}$，在深度网络中梯度会指数级递减引发梯度消失的问题。

* $Z=\sum\limits_{i = 0}^{n}w_ix_i$，神经元的个数 $n$ 越大，下一层神经网络的输入和输入的方差也就越大($w_i$ 和 $x_i$ 同 0 均值分布)：
  $$
  \begin{align}
  Var(Z) &= Var(\sum\limits_{i = 0}^{n}w_ix_i) \\\
  &= \sum\limits_{i = 0}^{n}Var(w_ix_i) \\\
  &= \sum\limits_{i = 0}^{n}[E(w_i)]^2Var(x_i)+[E(x_i)]^2Var(w_i)+Var(x_i)Var(w_i) \\\
  &= \sum\limits_{i = 0}^{n}Var(x_i)Var(w_i) \\\
  &= nVar(w_i)Var(x_i)
  \end{align}
  $$
  所以 $n$ 越大我们希望 $w_i$ 越小，这样下一层神经网络的输入和该输入的方差都不会太大，输入就还是 0 附近比较小的数。既不会导致梯度消失，也不会导致梯度爆炸。 

因此参数既不能太大也不能太小，所以参数的初始化很重要！一种方法是让每层神经网络的输入的方差和输入层的方法一致，这种方法虽然不能彻底解决问题，但是很有效。即 $Var(Z)=Var(x_i)$，所以 $Var(w_i)=\frac{1}{n}$。因为 $Var(cw)=c^2Var(w)$，所以在标准正态分布的基础上乘以 $\frac{1}{\sqrt{n}}$ 即可保证 $w$ 的方差为 $\frac{1}{n}$。

``` python
params['W' + str(l)] = np.random.randn(laye_dims[l], laye_dims[l-1]) * np.sqrt(1/layer_dims[l-1])
```

##### Xavier 初始化

方法同时考虑了反向传播时的情形，此时的输入是前向传播的输出，因此 $Var(w_i)=\frac{1}{n}=\frac{1}{n_{out}}$，于是结合以上两点要求，有 $Var(w_i)=\frac{2}{n_{in}+n_{out}}$。

``` python
params['W' + str(l)] = np.random.randn(laye_dims[l], laye_dims[l-1]) * np.sqrt(2/(layer_dims[l-1]+layer_dims[l-1]))
```
在吴恩达的深度学习课程中建议如果使用 Tanh 激活函数，则初始化参数方差为 $\frac{1}{n}$ 或者 $\frac{2}{n_{in}+n_{out}}$；如果使用 ReLU 激活函数，会发现效果并不好，因为 ReLU 激活函数有一部分神经元的输出是 0(即没有被激活)，于是何凯明等人提出了 MSRA 初始化的方法，也叫 He 初始化。

##### He 初始化

He 初始化的思想是：在 ReLU 网络中，假设有一般的神经元被激活，另一半输出为 0，所以要保持方差不变则需要初始化参数方差为 $\frac{2}{n}$。还可以把分子当成一个超级参数来调节，但是这个超级参数并不是很重要，所以优先级可以放得比较低。由于没有考虑反向传播，所以在深度学习领域，还是使用 Xavier 初始化方法的比较多。

### 模型结构

构建一个 L 层的深度神经网络模型主要分为以下几部分：

1. 初始化 L 层神经网络的参数
2. 实现前向传播模型(图中紫色部分)
   * 计算每一层前向传播步骤的线性(LINEAR)部分，即计算 $Z^{[l]}$
   * 使用激活(ACTIVATION)函数 `ReLU` 或者 `Sigmoid`
   * 将两个步骤结合到一个新的前向函数中：`[LINEAR->ACTIVATION]`
   * 前 L-1 层： `[LINEAR->ACTIVATION]`，最后一层： `[LINEAR->SIGMOID]`
3. 计算损失
4. 实现反向传播模型(图中红色部分)
   * 计算每一层反向传播步骤的线性(LINEAR)部分
   * 使用激活(ACTIVATION)函数 `ReLU` 或者 `Sigmoid` 的梯度
   * 将两个步骤结合到一个新的反向函数中：`[LINEAR->ACTIVATION]`
   * 前 L-1 层： `[LINEAR->ACTIVATION]`，最后一层： `[LINEAR->SIGMOID]`
5. 更新参数

![](/final outline.png)

#### 初始化模型参数

实验中的训练数据是 209 张 `64*64*3` 的图片，变成向量后的 X 的维度是 (12288, 209)，因此模型参数的维度如下标所示：

|          | $W$ 的维度               | $b$ 的维度       | 激活函数的输入 $Z^{l}$                        | 激活函数的维度     |
| -------- | ------------------------ | ---------------- | --------------------------------------------- | ------------------ |
| Layer 1  | $(n^{[1]}, 12288)$       | $(n^{[1]}, 1)$   | $Z^{[1]} = W^{[1]}  X + b^{[1]}$              | $(n^{[1]}, 209)$   |
| Layer 1  | $(n^{[2]}, n^{[1]})$     | $(n^{[2]}, 1)$   | $Z^{[2]} = W^{[2]} A^{[1]} + b^{[2]}$         | $(n^{[2]}, 209)$   |
| $\vdots$ | $\vdots$                 | $\vdots$         | $\vdots$                                      | $\vdots$           |
| Layer 1  | $(n^{[L-1]}, n^{[L-2]})$ | $(n^{[L-1]}, 1)$ | $Z^{[L-1]} = W^{[L-1]} A^{[L-2]} + b^{[L-1]}$ | $(n^{[L-1]}, 209)$ |
| Layer 1  | $(n^{[L]}, n^{[L-1]})$   | $(n^{[L]}, 1)$   | $Z^{[L]} = W^{[L]} A^{[L-1]} + b^{[L]}$       | $(n^{[L]}, 209)$   |

```python
def initialize_parameters_deep(layer_dims):
    np.random.seed(3)
    parameters = {}
    L = len(layer_dims)            # number of layers in the network

    for l in range(1, L):
        parameters['W' + str(l)] = np.random.randn(layer_dims[l], layer_dims[l-1]) * np.sqrt(2/layer_dims[l-1])
        parameters['b' + str(l)] = np.zeros((layer_dims[l], 1))
        
    return parameters
```

参数 `layer_dims` 是一个数组，包含了定义的深度神经网络的每一层的神经元的个数。

#### 前向传播模块

在线性部分和激活函数部分，前向传播都会缓存所有输入，用于反向传播时计算梯度。

* 线性前向
  $$
  Z^{[l]}=W^{[l]}A^{[l-1]}+b^{[l]}, 其中 A^{[0]}=X
  $$

  ``` python
  def linear_forward(A, W, b):
      Z = np.dot(W, A) + b
  
      cache = (A, W, b)
      
      return Z, cache
  ```

* 线性-激活前向

  * Sigmoid: $g(Z)=\sigma(WA+b)=\frac{1}{1+e^{-(WA+b)}}$
  * ReLU: $g(Z)=ReLU(Z)=max(0, Z)$

  $$
  A^{[l]}=g(W^{[l]}A^{[l-1]}+b^{[l]})
  $$

  ``` python
  def linear_activation_forward(A_prev, W, b, activation):
      if activation == "sigmoid":
          Z, linear_cache = linear_forward(A_prev, W, b)
          A, activation_cache = sigmoid(Z)
      elif activation == "relu":
          Z, linear_cache = linear_forward(A_prev, W, b)
          A, activation_cache = relu(Z)
      
      cache = (linear_cache, activation_cache)
  
      return A, cache
  ```

* L 层前向模型

  循环使用激活函数是 ReLU 的 `linear_activation_forward` L-1 次，再使用激活函数是 Sigmoid 的 `linear_activation_forward` 1 次，就可以构建一个 L 层神经网络模型。在实验过程中，需要把每层的缓存都放到同一个缓存列表中，然后返回输出和缓存，用于计算代价函数和反向传播计算梯度。

  $$
  \hat Y=A^{[L]}=\sigma(W^{[L]}A^{[L-1]}+b^{[L]})
  $$
  
``` python
  def L_model_forward(X, parameters):
      caches = []
      A = X
      L = len(parameters) // 2                  # number of layers in the neural network
      
      # [LINEAR -> RELU]*(L-1)
      for l in range(1, L):
          A_prev = A 
          A, cache = linear_activation_forward(A_prev, parameters['W' + str(l)], parameters['b' + str(l)], activation = "relu")
          caches.append(cache)
      
      # LINEAR -> SIGMOID
      AL, cache = linear_activation_forward(A, parameters['W' + str(L)], parameters['b' + str(L)], activation = "sigmoid")
      caches.append(cache)
      
      return AL, caches
  ```

#### 代价函数

$$
J=-\frac{1}{m}\sum\limits_{i=1}^{m}\left(y^{(i)}\log(a^{[L]\(i\)}) + (1-y^{(i)})\log(1- a^{[L]\(i\)})\right)
$$

```python
def compute_cost(AL, Y):
    m = Y.shape[1]
    cost = -np.sum(np.multiply(np.log(AL), Y) + np.multiply(np.log(1 - AL), 1 - Y)) / m
    cost = np.squeeze(cost)      # To make sure your cost's shape is what we expect (e.g. this turns [[17]] into 17).

    return cost
```

#### 反向传播模型

反向传播是用来计算代价函数对参数的梯度，通过梯度下降算法更新参数后继续前向传播，使得代价更小。在计算梯度的时候需要用到前向传播缓存的输入：

* 线性反向

  假设已经计算出导数 $dZ^{[l]}=\frac{\partial \mathcal{L} }{\partial Z^{[l]}}$，现在需要根据 $dZ^{[l]} $ 求 $dW^{[l]}, db^{[l]}, dA^{[l-1]}$。

  $$
  dW^{[l]}=\frac{\partial \mathcal{L}}{\partial W^{[l]}} = \frac{1}{m}dZ^{[l]}A^{[l-1]\mathrm{T}}
  $$
  
$$
  db^{[l]}=\frac{\partial \mathcal{L} }{\partial b^{[l]}}=\frac{1}{m}\sum_{i = 1}^{m}dZ^{[l]\(i\)}
  $$
  
$$
  dA^{[l-1]}=\frac{\partial \mathcal{L} }{\partial A^{[l-1]}}=W^{[l]\mathrm{T}}dZ^{[l]}
  $$
  
``` python
  def linear_backward(dZ, cache):
      A_prev, W, b = cache
      m = A_prev.shape[1]
  
      dW = np.dot(dZ, A_prev.T) / m
      db = np.sum(dZ, axis=1, keepdims=True) / m
      dA_prev = np.dot(W.T, dZ)
      
      return dA_prev, dW, db
  ```
  
* 线性-激活反向
  $$
  dZ^{[l]}= dA^{[l]} * g'(Z^{[l]})
  $$
  ReLU 函数的导数就是一个简单的分段函数，实验直接在 `dnn_utils` 模块中实现，只要调用以下函数，传入 $dA^{[l]}$ 和前向传播过程中的缓存就可以直接返回 $dZ^{[l]}$:

  * Sigmoid: `dZ = sigmoid_backward(dA, activation_cache)`
  * ReLU: `dZ = relu_backward(dA, activation_cache)`

  ``` python
  def linear_activation_backward(dA, cache, activation):
      linear_cache, activation_cache = cache
      
      if activation == "relu":
          dZ = relu_backward(dA, activation_cache)
          dA_prev, dW, db = linear_backward(dZ, linear_cache)
          
      elif activation == "sigmoid":
          dZ = sigmoid_backward(dA, activation_cache)
          dA_prev, dW, db = linear_backward(dZ, linear_cache)
      
      return dA_prev, dW, db
  ```

* L 层反向模型

  在反向传播的时候，首先需要计算代价函数对模型输出 $A^{[L]}$(即 $\hat Y$) 的梯度(计算公式见[单隐层神经网络](/2018/05/19/Neuron-network/))，然后调用 `linear_activation_backward` 函数，最后返回计算出的梯度列表：

  ``` python
def L_model_backward(AL, Y, caches):
      grads = {}
      L = len(caches) # the number of layers
      m = AL.shape[1]
      Y = Y.reshape(AL.shape) # after this line, Y is the same shape as AL
      
      # Initializing the backpropagation
      dAL = -(np.divide(Y, AL) - np.divide(1 - Y, 1 - AL))
      
      # Lth layer (SIGMOID -> LINEAR) gradients. Inputs: "dAL, current_cache". Outputs: "grads["dAL-1"], grads["dWL"], grads["dbL"]
      current_cache = caches[L-1]
      grads["dA" + str(L)], grads["dW" + str(L)], grads["db" + str(L)] = linear_activation_backward(dAL, current_cache, activation = "sigmoid")
      
      # Loop from l=L-2 to l=0
      for l in reversed(range(L-1)):
          # lth layer: (RELU -> LINEAR) gradients.
          # Inputs: "grads["dA" + str(l + 1)], current_cache". Outputs: "grads["dA" + str(l)] , grads["dW" + str(l + 1)] , grads["db" + str(l + 1)] 
          current_cache = caches[l]
          dA_prev_temp, dW_temp, db_temp = linear_activation_backward(grads["dA" + str(l + 2)], current_cache, activation = "relu")
          grads["dA" + str(l + 1)] = dA_prev_temp
          grads["dW" + str(l + 1)] = dW_temp
          grads["db" + str(l + 1)] = db_temp
  
      return grads
  ```

#### 更新参数

$$
W^{[l]} = W^{[l]} - \alpha \text{ } dW^{[l]}
$$

$$
b^{[l]} = b^{[l]} - \alpha \text{ } db^{[l]}
$$

``` python
def update_parameters(parameters, grads, learning_rate): 
    L = len(parameters) // 2 # number of layers in the neural network

    # Update rule for each parameter. Use a for loop.
    for l in range(L):
        parameters["W" + str(l+1)] = parameters["W" + str(l+1)] - learning_rate * grads["dW" + str(l+1)]
        parameters["b" + str(l+1)] = parameters["b" + str(l+1)] - learning_rate * grads["db" + str(l+1)]
        
    return parameters
```

### L 层神经网络

在实现 L 层神经网络的各个模块后，现在将它们组装成一个 L 层网络模型，通过 `layers_dims` 指定网络结构，设置学习率为 0.0075 迭代训练数据 3000 次，最后返回训练好的模型参数：

``` python
def L_layer_model(X, Y, layers_dims, learning_rate = 0.0075, num_iterations = 3000, print_cost=False):#lr was 0.009
    np.random.seed(1)
    costs = []                         # keep track of cost
    
    # Parameters initialization. (≈ 1 line of code)
    parameters = initialize_parameters_deep(layers_dims)
    
    # Loop (gradient descent)
    for i in range(0, num_iterations):

        # Forward propagation: [LINEAR -> RELU]*(L-1) -> LINEAR -> SIGMOID.
        AL, caches = L_model_forward(X, parameters)
        
        # Compute cost.
        cost = compute_cost(AL, Y)
    
        # Backward propagation.
        grads = L_model_backward(AL, Y, caches)
 
        # Update parameters.
        parameters = update_parameters(parameters, grads, learning_rate)
                
        # Print the cost every 100 training example
        if print_cost and i % 100 == 0:
            print ("Cost after iteration %i: %f" %(i, cost))
        if print_cost and i % 100 == 0:
            costs.append(cost)
            
    # plot the cost
    plt.plot(np.squeeze(costs))
    plt.ylabel('cost')
    plt.xlabel('iterations (per tens)')
    plt.title("Learning rate =" + str(learning_rate))
    plt.show()
    
    return parameters
```



## 参考文献

[1] 吴恩达. DeepLearning. 

[2] Christopher Olah. Neural Networks, Manifolds, and Topology. 2014

[3] X. Glorot, Y. Bengio, "Understanding the Difficulty of Training Deep Feedforward Neural Networks", *Proc. Conf. Artificial Intelligence and Statistics*, 2010.