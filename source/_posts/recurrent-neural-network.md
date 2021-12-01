---
title: 循环神经网络
date: 2018-06-20 10:29:57
updated: 2018-06-20 14:33:32
tags: Deep Learning
mathjax: true
typora-root-url: ./recurrent-neural-network
---

## 前言

按照吴恩达 Deeplearning 系列课程，应该是先学卷积神经网络，但是自己的实验中要用到递归神经网络，感觉不能再拖了，就先学习一下序列模型这一章节。在普通的神经网络中，一般都是输入一个向量，然后输出一个向量或者通过 Sigmoid 函数后输出一个值。

<!-- more -->

## 循环神经网络

循环神经网络 (Recurrent neural network) 是一类用于处理**序列数据**的神经网络。在普通的神经网络中，前一个输入和后一个输入没有关系；而在有时候需要网络在处理当前输入的时候，记住之前的输入的相关信息。如果将整个序列当成一个整体输入普通神经网络的话，则会遇到输入的长度不同(可通过填充解决)和参数量大的问题。

根据处理的问题，网络按结构可以分为以下几种：

* 一对一：非 RNN 结构，例如图片分类
* 一对多：序列输出，例如生成图片的描述
* 多对一：序列输入，例如评论的情感分类
* 多对多：
  * 序列输入和序列输出，例如机器翻译
  * 同步序列输入和输出，例如视频的帧分类

* 递归神经网络 (Recursive nerual network) 是空间上的展开，处理的是树状结构信息(例如语法树)；循环神经网络是时间上的展开(也叫时间递归神经网络)，处理的是序列结构信息； RNN 一般指循环神经网络。

## 前向传播

在同步序列输入和输出结构中，有 $T_x=T_y$ ，其结构如下图所示：

![](rnn.png)

一共有 $T_x$ 个时间步，所以只需要实现一个时间步，然后循环 $T_x$ 次则可以实现 RNN 的前向传播。

### RNN 细胞

一个循环神经网络可以看成是单个细胞(即时间步)的循环，所有细胞共享参数。细胞内部结构如下图所示：

![](rnn_step_forward.png)

细胞的输入有当前(第 $t$ 个时间步)的输入 $x^{\langle t\rangle}$ 和之前的隐藏状态 $a^{\langle t-1\rangle}$ (包含了以前的信息)，输出有 $a^{\langle t\rangle}$ 和 $\hat y^{\langle t\rangle}$ 。在前向传播过程中，需要缓存各种值用于反向传播计算参数梯度，实现 RNN 细胞代码主要分为以下几个步骤：

1. 用 $tanh$ 激活函数计算隐藏状态：$a^{\langle t\rangle}=tanh(W_{aa}a^{\langle t-1\rangle}+W_{ax}x^{\langle t\rangle}+b_a)$
2. 用新的隐藏状态 $a^{\langle t \rangle}$ 计算预测值 $\hat y^{\langle t\rangle}=softmax(W_{ya}a^{\langle t\rangle}+b_y)$
3. 缓存 $a^{\langle t\rangle}, a^{\langle t-1\rangle}, x^{\langle t\rangle}$
4. 返回 $a^{\langle t\rangle}, \hat y^{\langle t\rangle}$ 和缓存

一共有 $m$ 个样本数据，其中 $x^{\langle t\rangle}$ 的维度为 $(n_x, m)$，$a^{\langle t\rangle}$ 的维度为 $(n_a, m)$。代码中使用 `_prev` 表示上一个时间步 $\langle t-1\rangle$ ，`_next` 和 `t` 表示当前时间步 $\langle t\rangle$：

``` python
def rnn_cell_forward(xt, a_prev, parameters):
    # Retrieve parameters from "parameters"
    Wax = parameters["Wax"]
    Waa = parameters["Waa"]
    Wya = parameters["Wya"]
    ba = parameters["ba"]
    by = parameters["by"]
    
    # compute next activation state using the formula given above
    a_next = np.tanh(np.dot(Wax, xt) + np.dot(Waa, a_prev) + ba)
    # compute output of the current cell using the formula given above
    yt_pred = softmax(np.dot(Wya, a_next) + by)
    
    # store values you need for backward propagation in cache
    cache = (a_next, a_prev, xt, parameters)
    
    return a_next, yt_pred, cache
```

### RNN 前向传播

![](cell_rnn.png)

RNN 的前向传播主要分为以下几个步骤：

1. 创建零向量 $\boldsymbol{a}$ 用于存储**所有**隐藏状态
2. 初始化隐藏状态 $a_0$
3. 循环所有时间步，当前时间步为 $t$
   * 使用 `run_cell_forward` 函数更新隐藏状态 $a^{\langle t\rangle}$ 和缓存
   * 存储 $a^{\langle t\rangle}$ 到 $\boldsymbol{a}$ 中的第 $t$ 个位置
   * 存储预测值 $\hat y^{\langle t\rangle}$ 到 $\boldsymbol{\hat y}$ 中
   * 添加缓存到缓存列表中
4. 返回 $\boldsymbol{a}, \boldsymbol{\hat y}$ 和缓存列表

``` python
def rnn_forward(x, a0, parameters):
    # Initialize "caches" which will contain the list of all caches
    caches = []
    
    # Retrieve dimensions from shapes of x and Wy
    n_x, m, T_x = x.shape
    n_y, n_a = parameters["Wya"].shape
    
    # initialize "a" and "y" with zeros
    a = np.zeros((n_a, m, T_x))
    y_pred = np.zeros((n_y, m, T_x))
    
    # Initialize a_next
    a_next = a0
    
    # loop over all time-steps
    for t in range(T_x):
        # Update next hidden state, compute the prediction, get the cache
        a_next, yt_pred, cache = rnn_cell_forward(x[:,:,t], a_next, parameters)
        # Save the value of the new "next" hidden state in a
        a[:,:,t] = a_next
        # Save the value of the prediction in y
        y_pred[:,:,t] = yt_pred
        # Append "cache" to "caches"
        caches.append(cache)
        
    # store values needed for backward propagation in cache
    caches = (caches, x)
    
    return a, y_pred, caches
```

### 长期依赖

循环神经网络具有长期依赖的问题，在经过许多阶段传播后的梯度倾向于消失(大部分情况)或爆炸(很少而且容易发现，但对优化过程影响很大，可以使用梯度截断的方法解决)，因此只能学习到短期的依赖关系。以一个简单的、缺少非线性激活函数和输入 $x$ 的循环神经网络为例：
$$
a^{\langle t\rangle}=W_{aa}a^{\langle t-1\rangle}
$$

$$
a^{\langle t\rangle}=W_{aa}^ta^{\langle 0\rangle}
$$
类似于深度神经网络，当 $W_{aa}$ 的特征值小于 1 时就会导致隐藏状态约等于 0。即 RNN 会忘了很久以前的信息，如果不需要用很久以前的信息(有意义的信息都在前**几个**时间步)就能估计输出 $\hat y^{\langle t\rangle}$ ，那么 RNN 效果也不错。而 LSTM 则可以很好得解决这个问题，可以记住更多时间步以前的信息。目前实际应用中最有效的序列模型称为门控 RNN (gated RNN)。包括基于长短期记忆 (Long Short-Term Memory, LSTM) 和基于门控循环单元 (gated recurrent unit, GRU) 网络。

### LSTM 细胞

基于长短期记忆 (LSTM) 的网络的细胞结构如下图所示：

![](LSTM.png)

**LSTM 最关键的地方就在于细胞的状态 $c^{\langle t\rangle}$，即上图中上面横穿的水平线，这种结构能够很轻松地实现信息从整个细胞中穿过而不做改变(没有经过 $tanh$ 激活函数)，从而实现了长时期的记忆保留**。可以参考反向传播时的分析，LSTM 通过门 (gates) 的结构来实现给细胞的状态添加或者删除信息。

#### 遗忘门

假如我们希望用 LSTM 来跟踪主语是单数还是复数，如果主语从单数变成复数，我们需要忘记之前存储的状态。在 LSTM 中使用遗忘门 (**F**orget gate) 实现这一点：
$$
\Gamma_f^{\langle t\rangle}=\sigma(W_f[a^{\langle t-1\rangle}, x^{\langle t\rangle}]+b_f)\tag{1}
$$
其中 $W_f$ 是控制遗忘门行为的权重，遗忘门的输出 $\Gamma_f^{\langle t \rangle}$ 最后要作用于细胞的状态 ($\Gamma_f^{\langle t\rangle}*c^{\langle t-1\rangle}$)，因此使用 $sigmoid$ 激活函数保证输出是一个 0，1 之间的向量，表示让 $c^{\langle t-1\rangle}$ 各部分信息通过的比例，0 表示不让任何信息通过，1 表示让所有信息通过。

#### 更新门

类似于遗忘门，更新门 (**U**pdate gate) 也可以叫输入门 (**I**nput gate)，决定让多少新的信息加入到细胞状态中：
$$
\Gamma_u^{\langle t\rangle}=\sigma(W_u[a^{\langle t-1\rangle}, x^{\langle t\rangle}]+b_u)\tag{2}
$$
更新门的输出 $\Gamma_u^{\langle t\rangle}$ 要作用于新的信息 $\tilde{c}^{\langle t\rangle}$，生成更新内容 $\Gamma_u^{\langle t\rangle}*\tilde{c}^{\langle t\rangle}$，然后再添加到细胞的状态上：
$$
\tilde{c}^{\langle t\rangle}=\tanh(W_c[a^{\langle t-1\rangle}, x^{\langle t\rangle}]+b_c)\tag{3}
$$

$$
c^{\langle t\rangle}=\Gamma_f^{\langle t\rangle}*c^{\langle t-1\rangle}+\Gamma_u^{\langle t\rangle}*\tilde{c}^{\langle t\rangle}\tag{4}
$$

#### 输出门

输出门 (**O**utput gate) 的输出如下所示：
$$
\Gamma_o^{\langle t\rangle}=\sigma(W_o[a^{\langle t-1\rangle}, x^{\langle t\rangle}]+b_o)\tag{5}
$$
最后细胞的隐藏状态为：
$$
a^{\langle t \rangle}=\Gamma_o^{\langle t\rangle}*\tanh(c^{\langle t\rangle})\tag{6}
$$
遗忘门、更新门和输出门的输入只取决于 $a^{\langle t-1\rangle}$ 和 $x^{\langle t\rangle}$，如果还取决与上一个细胞的状态 $c^{\langle t-1\rangle}$ 则称为**窥孔连接**。类似于 RNN 细胞需要缓存各种值用于反向传播计算参数梯度，实现 LSTM 细胞代码主要分为以下几个步骤：

1. 连接 $a^{\langle t-1\rangle}$ 和 $x^{\langle t \rangle}$ 到一个矩阵中：$concat = \begin{bmatrix} a^{\langle t-1 \rangle} \\\ x^{\langle t \rangle} \end{bmatrix}$
2. 实现公式 $(1)-(6)$
3. 计算预测值 $y^{\langle t \rangle}$

``` python
def lstm_cell_forward(xt, a_prev, c_prev, parameters):
    # Retrieve parameters from "parameters"
    Wf = parameters["Wf"]
    bf = parameters["bf"]
    Wu = parameters["Wu"]
    bu = parameters["bu"]
    Wc = parameters["Wc"]
    bc = parameters["bc"]
    Wo = parameters["Wo"]
    bo = parameters["bo"]
    Wy = parameters["Wy"]
    by = parameters["by"]
    
    # Retrieve dimensions from shapes of xt and Wy
    n_x, m = xt.shape
    n_y, n_a = Wy.shape

    # Concatenate a_prev and xt
    concat = np.zeros([n_a + n_x, m])
    concat[:n_a,:] = a_prev
    concat[n_a:,:] = xt

    # Compute values for ft, ut, cct, c_next, ot, a_next using the formulas
    ft = sigmoid(np.dot(Wf, concat) + bf)
    ut = sigmoid(np.dot(Wu, concat) + bu)
    cct = np.tanh(np.dot(Wc, concat) + bc)
    c_next = ft * c_prev + ut * cct
    ot = sigmoid(np.dot(Wo, concat) + bo)
    a_next = ot * np.tanh(c_next)
    
    # Compute prediction of the LSTM cell
    yt_pred = softmax(np.dot(Wy, a_next) + by)

    # store values needed for backward propagation in cache
    cache = (a_next, c_next, a_prev, c_prev, ft, ut, cct, ot, xt, parameters)

    return a_next, c_next, yt_pred, cache
```

### LSTM 前向传播

![](LSTM_rnn.png)

类似于 RNN 前向传播，只不过多了一个细胞的状态，所以需要初始化为 0 向量：

``` python
def lstm_forward(x, a0, parameters):
    # Initialize "caches", which will track the list of all the caches
    caches = []
    
    # Retrieve dimensions from shapes of xt and Wy
    n_x, m, T_x = x.shape
    n_y, n_a = parameters['Wy'].shape
    
    # initialize "a", "c" and "y" with zeros
    a = np.zeros([n_a, m, T_x])
    c = np.zeros([n_a, m, T_x])
    y = np.zeros([n_y, m, T_x])
    
    # Initialize a_next and c_next
    a_next = a0
    c_next = np.zeros([n_a, m])
    
    # loop over all time-steps
    for t in range(T_x):
        # Update next hidden state, next memory state, compute the prediction, get the cache
        a_next, c_next, yt, cache = lstm_cell_forward(x[:,:,t], a_next, c_next, parameters)
        # Save the value of the new "next" hidden state in a
        a[:,:,t] = a_next
        # Save the value of the prediction in y
        y[:,:,t] = yt
        # Save the value of the next cell state
        c[:,:,t]  = c_next
        # Append the cache into caches
        caches.append(cache)
        
    # store values needed for backward propagation in cache
    caches = (caches, x)

    return a, y, c, caches
```

## 反向传播

在 DeepLearning 课程作业中，RNN 反向传播直接忽略了细胞的输出，没有考虑细胞的输出的误差对参数的梯度，降低了作业的难度，在 LSTM 反向传播中考虑了细胞的输出的误差对参数的梯度。

在预测输出的时候，RNN 使用了 Softmax 函数，关于 Softmax 函数的求导过程可以参考 [Logistic 回归和 Softmax 回归](/2018/04/26/logistic-regression)。RNN 在时间步上反向传播，因此也叫做 BackPropagation Through Time(BPTT) 算法。

### 简单版 RNN 细胞

没有输出只有隐藏状态的 RNN 细胞的反向传播过程如下图所示：

![](rnn_cell_backprop.png)

由链式求导公式、复合求导公式和矩阵的求导公式或者参考[单隐层神经网络](/2018/05/19/neuron-network)可以推导出右边的表达式，其代码实现如下：

```python
def rnn_cell_backward(da_next, cache):
    # Retrieve values from cache
    (a_next, a_prev, xt, parameters) = cache
    
    # Retrieve values from parameters
    Wax = parameters["Wax"]
    Waa = parameters["Waa"]
    ba = parameters["ba"]

    # compute the gradient of tanh with respect to a_next
    dtanh = (1-a_next * a_next) * da_next  

    # compute the gradient of the loss with respect to Wax
    dxt = np.dot(Wax.T,dtanh)
    dWax = np.dot(dtanh, xt.T)

    # compute the gradient with respect to Waa
    da_prev = np.dot(Waa.T,dtanh)
    dWaa = np.dot(dtanh, a_prev.T)

    # compute the gradient with respect to b
    dba = np.sum(dtanh, keepdims=True, axis=-1)

    # Store the gradients in a python dictionary
    gradients = {"dxt": dxt, "da_prev": da_prev, "dWax": dWax, "dWaa": dWaa, "dba": dba}
    
    return gradients
```

### RNN 反向传播

在 RNN 反向传播中不但要计算参数的梯度，也要计算 $a^{\langle t\rangle}$ 的梯度，这样才能将梯度反向传播到前一个 RNN 细胞，代码中还保存了输入的梯度到 $dx$ 中：

``` python
def rnn_backward(da, caches):
    # Retrieve values from the first cache (t=1) of caches
    (caches, x) = caches
    (a1, a0, x1, parameters) = caches[0]
    
    # Retrieve dimensions from da's and x1's shapes
    n_a, m, T_x = da.shape
    n_x, m = x1.shape
    
    # initialize the gradients with the right sizes
    dx = np.zeros([n_x, m, T_x])
    dWax = np.zeros([n_a, n_x])
    dWaa = np.zeros([n_a, n_a])
    dba = np.zeros([n_a, 1])
    da0 = np.zeros([n_a, m])
    da_prevt = np.zeros([n_a, m])
    
    # Loop through all the time steps
    for t in reversed(range(T_x)):
        # Compute gradients at time step t. Choose wisely the "da_next" and the "cache" to use in the backward propagation step.
        gradients = rnn_cell_backward(da[:,:,t] + da_prevt, caches[t])
        # Retrieve derivatives from gradients
        dxt, da_prevt, dWaxt, dWaat, dbat = gradients["dxt"], gradients["da_prev"], gradients["dWax"], gradients["dWaa"], gradients["dba"]
        # Increment global derivatives w.r.t parameters by adding their derivative at time-step t
        dx[:,:,t] = dxt
        dWax += dWaxt
        dWaa += dWaat
        dba += dbat
        
    # Set da0 to the gradient of a which has been backpropagated through all time-steps
    da0 = da_prevt

    # Store the gradients in a python dictionary
    gradients = {"dx": dx, "da0": da0, "dWax": dWax, "dWaa": dWaa,"dba": dba}
    
    return gradients
```

### 完整版 RNN 细胞

完整的 RNN 细胞有输出，代价函数是所有时间步的输出的损失函数的和，对参数 $W_{ya}$ 和 $b_y$ 的求导比较简单，因为它们当前梯度只和当前时间步的损失函数相关：
$$
J=\sum_{t=1}^{T_x}J^{\langle t\rangle}
$$

$$
\frac{\partial J}{\partial W_{ya}}=\sum_{t=1}^{T_x}(\hat y^{\langle t\rangle}-y^{\langle t\rangle})a^{\langle t\rangle T}
$$

$$
\frac{\partial J}{\partial b_y}=\sum_{t=1}^{T_x}\hat y^{\langle t\rangle}-y^{\langle t\rangle}
$$

参数 $W_{aa}, b_a$ 和 $W_{ax}$ 的梯度就比较复杂，因为它们的当前梯度不仅和当前时间步的损失函数相关，还和后面的时间步的损失函数相关。首先定义当前时间步的隐藏状态的梯度 $\delta^{\langle t\rangle}$，其递推公式如下所示：
$$
\begin{align}
\delta^{\langle t\rangle}&=\frac{\partial J}{\partial a^{\langle t\rangle}}=\frac{\sum_{i=t}^{T_x}\partial J^{\langle i\rangle}}{\partial a^{\langle t\rangle}} \\\
&=\frac{\partial J^{\langle t\rangle}}{\partial a^{\langle t\rangle}}+\frac{\sum_{i=t+1}^{T_x}\partial J^{\langle i\rangle}}{\partial a^{\langle t+1\rangle}}\frac{\partial a^{\langle t+1\rangle}}{\partial a^{\langle t\rangle}} \\\
&=W_{ya}^T(\hat y^{\langle t\rangle}-y^{\langle t\rangle})+W_{aa}^T\delta^{\langle t+1\rangle}diag(1-a^{\langle t+1\rangle2})\tag{1}
\end{align}
$$
隐藏状态在时间步方向上的代价函数的梯度(即不考虑当前时间步的输出) 为 $\delta^{\langle T_x\rangle}\prod_{i=t+1}^{T_x}W_{aa}^Tdiag(1-a^{\langle i\rangle2})$，当参数 $W_{aa}^T$ 小于 1 时就产生了梯度消失，即使使用 $ReLU$ 函数作为激活函数，梯度为 $\delta^{\langle T_x\rangle}\prod_{i=t+1}^{T_x}W_{aa}^T$，也不能解决长期依赖问题。隐藏状态在最后一个时间步 $\langle T_{x}\rangle$ 梯度只由该时间步的损失函数相关，因为后面不再有损失函数，所以有：
$$
\delta^{\langle T_x\rangle}=\frac{\partial J}{\partial a^{\langle T_x\rangle}}=\frac{\partial J^{\langle T_x\rangle}}{\partial a^{\langle T_x\rangle}}=W_{ya}^T(\hat y^{\langle t\rangle}-y^{\langle t\rangle})\tag{2}
$$
根据 $(1)$ 和 $(2)$ 递推公式可以求得 $\delta^{\langle t\rangle}$，有了 $\delta^{\langle t\rangle}$ 就可以很轻松地求解参数 $W_{aa}, b_a$ 和 $W_{ax}$ 的梯度：
$$
\frac{\partial J}{\partial W_{aa}}=\sum_{t=1}^{T_x}\frac{\partial J}{\partial a^{\langle t\rangle}}\frac{\partial a^{\langle t\rangle}}{\partial W_{aa}}=\sum_{t=1}^{T_x}diag(1-a^{\langle t\rangle2})\delta^{\langle t\rangle}a^{\langle t-1\rangle T}
$$

$$
\frac{\partial J}{\partial b_a}=\sum_{t=1}^{T_x}\frac{\partial J}{\partial a^{\langle t\rangle}}\frac{\partial a^{\langle t\rangle}}{\partial b_a}=\sum_{t=1}^{T_x}diag(1-a^{\langle t\rangle2})\delta^{\langle t\rangle}
$$

$$
\frac{\partial J}{\partial W_{ax}}=\sum_{t=1}^{T_x}\frac{\partial J}{\partial a^{\langle t\rangle}}\frac{\partial a^{\langle t\rangle}}{\partial W_{ax}}=\sum_{t=1}^{T_x}diag(1-a^{\langle t\rangle2})\delta^{\langle t\rangle}x^{\langle t\rangle T}
$$

### LSTM 细胞

LSTM 的细胞结构比较复杂，反向传播的公式也比较难，关于隐藏状态的梯度公式和普通 RNN 类似。参数的梯度不仅和当前时间步的损失函数相关(通过隐藏状态 $a^{\langle t\rangle}$)，还和后面的时间步的损失函数相关(通过细胞的状态 $c^{\langle t\rangle}$)。定义当前时间步的细胞状态的梯度 $\delta^{\langle t\rangle}$，其递推公式如下所示：
$$
\begin{align}
\delta^{\langle t\rangle}&=\frac{\partial J}{\partial c^{\langle t\rangle}}=\frac{\sum_{i=t}^{T_x}\partial J^{\langle i\rangle}}{\partial c^{\langle t\rangle}} \\\
&=\frac{\partial J^{\langle t\rangle}}{\partial c^{\langle t\rangle}}+\frac{\sum_{i=t+1}^{T_x}\partial J^{\langle i\rangle}}{\partial c^{\langle t+1\rangle}}\frac{\partial c^{\langle t+1\rangle}}{\partial c^{\langle t\rangle}} \\\
&=\frac{\partial J^{\langle t\rangle}}{\partial c^{\langle t\rangle}}+\delta^{\langle t+1\rangle}\Gamma_f^{\langle t\rangle}
\end{align}
$$
细胞状态在时间步方向上的代价函数的梯度为 $\delta^{\langle T_x\rangle}\prod_{i=t+1}^k\Gamma_f^{\langle i\rangle}$，因为最原始的 LSTM 没有遗忘门，即 $\Gamma_f^{\langle t\rangle}=1$，所以不存在梯度消失问题。目前流行的深度学习框架中 $b_f$ 一般会设置的大一些，这样遗忘门的输出 $\Gamma_f^{\langle t\rangle}=\sigma(W_f[a^{\langle t-1\rangle}, x^{\langle t\rangle}]+b_f)$ 就会约等于 1，可以减缓梯度消失，所以即使遗忘门的输出很小，那也是当前时间步的输入导致的模型的选择，不是多层嵌套导致的梯度消失。

LSTM 细胞的梯度主要分为两部分：门的梯度和参数的梯度，参数的梯度公式如下：

* 门的梯度
  $$
  d\Gamma_o^{\langle t \rangle}=da^{\langle t\rangle}*\tanh(c^{\langle t\rangle})
  $$

  $$
  d\tilde c^{\langle t\rangle}=dc^{\langle t\rangle}*\Gamma_u^{\langle t \rangle}+\Gamma_o^{\langle t\rangle}\big(1-\tanh(c^{\langle t\rangle})^2\big)*\Gamma_u^{\langle t \rangle}*da^{\langle t\rangle}
  $$

  $$
  d\Gamma_u^{\langle t \rangle}=dc^{\langle t\rangle}*\tilde c^{\langle t\rangle}+\Gamma_o^{\langle t\rangle}\big(1-\tanh(c^{\langle t\rangle})^2\big)*\tilde c^{\langle t\rangle}*da^{\langle t\rangle}
  $$

  $$
  d\Gamma_f^{\langle t\rangle}=dc^{\langle t\rangle}*c^{\langle t-1\rangle}+\Gamma_o^{\langle t\rangle}\big(1-\tanh(c^{\langle t\rangle})^2\big)*c^{\langle t-1\rangle}*da^{\langle t\rangle}
  $$

* 参数的梯度
  $$
  dW_f = d\Gamma_f^{\langle t\rangle}*\Gamma_f^{\langle t\rangle}*(1-\Gamma_f^{\langle t\rangle})\begin{bmatrix} a^{\langle t-1\rangle} \\\ x^{\langle t\rangle}\end{bmatrix}^T
  $$

  $$
  dW_u=d\Gamma_u^{\langle t \rangle}*\Gamma_u^{\langle t\rangle}*(1-\Gamma_u^{\langle t\rangle})*\begin{bmatrix} a^{\langle t-1\rangle} \\\ x^{\langle t\rangle}\end{bmatrix}^T
  $$

  $$
  dW_c=d\tilde c^{\langle t \rangle}*(1-\tilde c^{\langle t\rangle 2})*\begin{bmatrix} a^{\langle t-1\rangle} \\\ x^{\langle t\rangle}\end{bmatrix}^T
  $$

  $$
  dW_o=d\Gamma_o^{\langle t\rangle}*\Gamma_o^{\langle t\rangle}*(1-\Gamma_o^{\langle t\rangle})*\begin{bmatrix} a^{\langle t-1\rangle} \\\ x^{\langle t\rangle}\end{bmatrix}^T
  $$

$b_f, b_u, b_c, b_o$ 的梯度只需要将 $\Gamma_f^{\langle t\rangle}, \Gamma_u^{\langle t\rangle}, \tilde c^{\langle t\rangle}, \Gamma_o^{\langle t\rangle}$ 的梯度沿水平方向 (axis=1) 累加即可，当前时间步的输入、上一个时间步的细胞状态和隐藏状态的梯度如下所示：
$$
\begin{align}
da^{\langle t-1\rangle} &= W_f^T*d\Gamma_f^{\langle t\rangle}*\Gamma_f^{\langle t\rangle}*(1-\Gamma_f^{\langle t\rangle})  \\\
&+ W_u^T * d\Gamma_u^{\langle t \rangle}*\Gamma_u^{\langle t\rangle}*(1-\Gamma_u^{\langle t\rangle}) \\\
&+ W_c^T * d\tilde c^{\langle t \rangle}*(1-\tilde c^{\langle t\rangle 2})  \\\
&+ W_o^T * d\Gamma_o^{\langle t\rangle}*\Gamma_o^{\langle t\rangle}*(1-\Gamma_o^{\langle t\rangle})
\end{align}
$$

$$
dc^{\langle t-1\rangle} = dc^{\langle t\rangle}\Gamma_f^{\langle t \rangle} + \Gamma_o^{\langle t \rangle} * (1- \tanh(c^{\langle t-1\rangle})^2)*\Gamma_f^{\langle t \rangle}*da^{\langle t\rangle}
$$

$$
\begin{align}
dx^{\langle t \rangle} &= W_f^T*d\Gamma_f^{\langle t\rangle}*\Gamma_f^{\langle t\rangle}*(1-\Gamma_f^{\langle t\rangle}) \\\
&+ W_u^T * d\Gamma_u^{\langle t \rangle}*\Gamma_u^{\langle t\rangle}*(1-\Gamma_u^{\langle t\rangle}) \\\
&+ W_c^T * d\tilde c^{\langle t \rangle}*(1-\tilde c^{\langle t\rangle 2}) \\\
&+ W_o^T * d\Gamma_o^{\langle t\rangle}*\Gamma_o^{\langle t\rangle}*(1-\Gamma_o^{\langle t\rangle})
\end{align}
$$

DeepLearning 的目前最新版本作业中的公式和代码的表示有些小问题，这里已经修正。其代码实现如下：

``` python
def lstm_cell_backward(da_next, dc_next, cache):
    # Retrieve information from "cache"
    (a_next, c_next, a_prev, c_prev, ft, ut, cct, ot, xt, parameters) = cache
    
    # Retrieve dimensions from xt's and a_next's shape
    n_x, m = xt.shape
    n_a, m = a_next.shape
    
    # Compute gates related derivatives, you can find their values can be found by looking carefully at equations (7) to (10)
    dot = da_next * np.tanh(c_next)
    dcct = (dc_next * ut + ot * (1 - np.square(np.tanh(c_next))) * ut * da_next)
    dut = (dc_next * cct + ot * (1 - np.square(np.tanh(c_next))) * cct * da_next)
    dft = (dc_next * c_prev + ot * (1 - np.square(np.tanh(c_next))) * c_prev * da_next)
    
    # Compute parameters related derivatives. Use equations (11)-(14)
    concat = np.concatenate((a_prev, xt), axis=0).T
    dWf = np.dot(dft * ft * (1 - ft), concat)
    dWu = np.dot(dut * ut * (1 - ut), concat)
    dWc = np.dot(dcct * (1 - np.square(cct)), concat)
    dWo = np.dot(dot * ot * (1 - ot), concat)
    dbf = np.sum(dft * ft * (1 - ft), axis=1, keepdims=True)  
    dbu = np.sum(dut * ut * (1 - ut), axis=1, keepdims=True)  
    dbc = np.sum(dcct * (1 - np.square(cct)), axis=1, keepdims=True)  
    dbo = np.sum(dot * ot * (1 - ot),axis=1,keepdims=True)  

    # Compute derivatives w.r.t previous hidden state, previous memory state and input. Use equations (15)-(17).
    da_prev = np.dot(parameters["Wf"][:, :n_a].T, dft * ft * (1 - ft)) + np.dot(parameters["Wc"][:, :n_a].T, dcct * (1 - np.square(cct))) + np.dot(parameters["Wu"][:, :n_a].T, dut * ut * (1 - ut)) + np.dot(parameters["Wo"][:, :n_a].T, dot * ot * (1 - ot))
    dc_prev = dc_next*ft+ot*(1-np.square(np.tanh(c_next)))*ft*da_next
    dxt = np.dot(parameters["Wf"][:, n_a:].T, dft * ft * (1 - ft)) + np.dot(parameters["Wc"][:, n_a:].T, dcct * (1 - np.square(cct))) + np.dot(parameters["Wu"][:, n_a:].T, dut * ut * (1 - ut)) + np.dot(parameters["Wo"][:, n_a:].T, dot * ot * (1 - ot))
    
    # Save gradients in dictionary
    gradients = {"dxt": dxt, "da_prev": da_prev, "dc_prev": dc_prev, "dWf": dWf,"dbf": dbf, "dWu": dWu,"dbu": dbu,
                "dWc": dWc,"dbc": dbc, "dWo": dWo,"dbo": dbo}

    return gradients
```

### LSTM 反向传播

类似于 RNN 的反向传播，最后一个时间步的细胞状态和隐藏状态的梯度为 0，其代码实现如下：

``` python
def lstm_backward(da, caches):
    # Retrieve values from the first cache (t=1) of caches.
    (caches, x) = caches
    (a1, c1, a0, c0, f1, i1, cc1, o1, x1, parameters) = caches[0]
    
    # Retrieve dimensions from da's and x1's shapes (≈2 lines)
    n_a, m, T_x = da.shape
    n_x, m = x1.shape
    
    # initialize the gradients with the right sizes (≈12 lines)
    dx = np.zeros([n_x, m, T_x])
    da0 = np.zeros([n_a, m])
    da_prevt = np.zeros([n_a, m])
    dc_prevt = np.zeros([n_a, m])
    dWf = np.zeros([n_a, n_a + n_x])
    dWu = np.zeros([n_a, n_a + n_x])
    dWc = np.zeros([n_a, n_a + n_x])
    dWo = np.zeros([n_a, n_a + n_x])
    dbf = np.zeros([n_a, 1])
    dbu = np.zeros([n_a, 1])
    dbc = np.zeros([n_a, 1])
    dbo = np.zeros([n_a, 1])
    
    # loop back over the whole sequence
    for t in reversed(range(T_x)):
        # Compute all gradients using lstm_cell_backward
        gradients = lstm_cell_backward(da[:,:,t],dc_prevt,caches[t])
        # Store or add the gradient to the parameters' previous step's gradient
        dx[:,:,t] = gradients['dxt']
        dWf = dWf+gradients['dWf']
        dWu = dWu+gradients['dWu']
        dWc = dWc+gradients['dWc']
        dWo = dWo+gradients['dWo']
        dbf = dbf+gradients['dbf']
        dbu = dbu+gradients['dbu']
        dbc = dbc+gradients['dbc']
        dbo = dbo+gradients['dbo']
    # Set the first activation's gradient to the backpropagated gradient da_prev.
    da0 = gradients['da_prev']
    
    # Store the gradients in a python dictionary
    gradients = {"dx": dx, "da0": da0, "dWf": dWf,"dbf": dbf, "dWu": dWu,"dbu": dbu,
                "dWc": dWc,"dbc": dbc, "dWo": dWo,"dbo": dbo}
    
    return gradients
```

## 激活函数选择

* 在 RNN 中，使用 $tanh$ 函数作为激活函数是因为 RNN 主要存在梯度消失问题。相比于 $sigmoid$ 激活函数，$tanh$ 函数的二阶导数在 0 之前持续很长的范围，更加有利于保持梯度在激活函数的线性区域。
* 在 RNN 中，参数 $W_{ax}$ 和 $W_{aa}$ 参与了每个时间步的运算，即使使用 $ReLU$ 函数作为激活函数，当参数 $W$ 小于 1 时也会产生梯度消失问题，而且 $ReLU$ 函数还会导致模型的输出过大，$tanh$ 函数则可以控制输出范围在 $(-1, 1)$。
* 在 LSTM 的门单元中，使用 $sigmoid$ 函数作为激活函数是因为要保证门的输出是一个 0，1 之间的向量，例如遗忘门 的输出表示让 $c^{\langle t-1\rangle}$ 各部分信息通过的比例，0 表示不让任何信息通过，1 表示让所有信息通过。

## 参考文献

1. 吴恩达. DeepLearning. 
2. Ian Goodfellow, Yoshua Bengio, Aaron Courville. Deep Learning. 人民邮电出版社. 2017.
3. [Understanding LSTM Networks](http://colah.github.io/posts/2015-08-Understanding-LSTMs)