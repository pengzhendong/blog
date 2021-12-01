---
title: 卷积神经网络应用
date: 2018-12-05 11:16:44
updated: 2018-12-05 15:45:07
tags: Deep Learning
mathjax: true
typora-root-url: ./convnet-application
---

## 前言

写了两周基金申请报告也是醉了，说什么基金申请下来后我们出国交流就不用钱啦！多么拙劣的谎言，我只想中一篇论文达到毕业要求，然后去实习就行。今天又吐槽我说我晚上出勤不够，您真不愧是大学城最努力的老师。这都还没毕业，实验室的同学们都已经过上了公务员那种朝九晚五的生活。继续学习卷积神经网络，看看怎么用 Tensorflow 实现多分类问题。

<!-- more -->

## Tensorflow 模型

这个实验的要求是对手势进行识别，分析图片中的手势表示的是哪个数字（0~6）。手势图像如下所示：

![](SIGNS.png)

首先载入需要用到的包和数据集，对数据进行简单的预处理：

``` python
import math
import numpy as np
import h5py
import matplotlib.pyplot as plt
import scipy
from PIL import Image
from scipy import ndimage
import tensorflow as tf
from tensorflow.python.framework import ops
from cnn_utils import *

%matplotlib inline
np.random.seed(1)

X_train_orig, Y_train_orig, X_test_orig, Y_test_orig, classes = load_dataset()
X_train = X_train_orig/255.
X_test = X_test_orig/255.
Y_train = convert_to_one_hot(Y_train_orig, 6).T
Y_test = convert_to_one_hot(Y_test_orig, 6).T
conv_layers = {}
```

### 创建 placeholders

需要给数据创建 placeholders，在运行 session 的时候就可以喂入数据。使用 `None` 作为 batch size，这样就可以在后面的时候比较灵活地设置小批量的大小：

``` python
def create_placeholders(n_H0, n_W0, n_C0, n_y):
    X = tf.placeholder(tf.float32, [None, n_H0, n_W0, n_C0])
    Y = tf.placeholder(tf.float32, [None, n_y])
    
    return X, Y
```

### 初始化参数

网络为两层卷积神经网络，分别初始化每一层的权值 $W1$ 和 $W2$，也就是滤波器 。其中 $W1$ 包含 8 个大小为 4 的 3 通道滤波器，$W2$ 包含 16 个大小为 2 的 8 通道滤波器：

``` python
def initialize_parameters():
    tf.set_random_seed(1)
        
    W1 = tf.get_variable("W1", [4, 4, 3, 8], initializer=tf.contrib.layers.xavier_initializer(seed=0))
    W2 = tf.get_variable("W2", [2, 2, 8, 16], initializer=tf.contrib.layers.xavier_initializer(seed=0))
    
    return {"W1": W1, "W2": W2}
```

### 前向传播

在 Tensorflow 中，提供了以下函数可以用来快速构建卷积神经网络：

* `tf.nn.conv2d(X, W1, strides=[1,s,s,1], padding='SAME')`：给定输入 $X$ 和一组滤波器 $W1$，该函数回使用 $W1$ 中的滤波器和 $X$ 进行卷积运算，第三个参数指定了 $X$ 每个维度的卷积步长。
* `tf.nn.max_pool(A, ksize=[1,f,f,1], strides=[1,s,s,1], padding='SAME')`：给定输入 A，滤波器大小为 f，使用最大池化进行运算。
* `tf.nn.relu(Z1)`：对 Z1 中的每个元素进行 ReLU 运算。
* `tf.contrib.layers.flatten(P)`：给定输入 P，将其变平（flatten）成一维向量。如果 P 中包含 batch-size 则变成形状为 [batch_size, k] 的张量。
* `tf.contrib.layers.fully_connected(F, num_outputs)`：给定变平的输入，返回全连接神经网络层计算的输出，该层自动初始化权值。

卷积神经网络的前向传播主要流程为：`CONV2D -> RELU -> MAXPOOL -> CONV2D -> RELU -> MAXPOOL -> FLATTEN -> FULLYCONNECTED`，每一层的参数配置如下所示：

1. Conv2D：步长为 1，零填充为 SAME 卷积；
2. ReLU；
3. Max pool：滤波器大小为 8，步长为 8；
4. Conv2D：卷积步长为 1，零填充为 SAME 卷积；
5. ReLU；
6. Max pool：滤波器尺大小为 4，步长为 4
7. 将前面的输出变平（flatten）；
8. FULLYCONNECTED (全连接) 层：此处不需要使用 softmax 函数，在 Tensorflow 中，softmax 和代价函数被写成了一个单独的函数，所以可以直接在全连接层的输出上计算代价。

``` python
def forward_propagation(X, parameters):
    # Retrieve the parameters from the dictionary "parameters" 
    W1 = parameters['W1']
    W2 = parameters['W2']
    
    # CONV2D: stride of 1, padding 'SAME'
    Z1 = tf.nn.conv2d(X, W1, strides=[1, 1, 1, 1], padding='SAME')
    # RELU
    A1 = tf.nn.relu(Z1)
    # MAXPOOL: window 8x8, stride 8, padding 'SAME'
    P1 = tf.nn.max_pool(A1, ksize = [1, 8, 8, 1], strides = [1, 8, 8, 1], padding='SAME')
    # CONV2D: filters W2, stride 1, padding 'SAME'
    Z2 = tf.nn.conv2d(P1, W2, strides=[1, 1, 1, 1], padding='SAME')
    # RELU
    A2 = tf.nn.relu(Z2)
    # MAXPOOL: window 4x4, stride 4, padding 'SAME'
    P2 = tf.nn.max_pool(A2, ksize = [1, 4, 4, 1], strides = [1, 4, 4, 1], padding='SAME')
    # FLATTEN
    P = tf.contrib.layers.flatten(P2)
    # FULLY-CONNECTED without non-linear activation function (not not call softmax).
    # 6 neurons in output layer. Hint: one of the arguments should be "activation_fn=None" 
    Z3 = tf.contrib.layers.fully_connected(P, 6, activation_fn=None)

    return Z3
```

### 计算代价

* `tf.nn.softmax_cross_entropy_with_logits(logits=Z3, labels=Y)`：计算 softmax 交叉损失，该函数包含了 softmax 函数。
* `tf.reduce_mean`：计算张量每个维度的均值，用来计算整体的代价。

``` python
def compute_cost(Z3, Y):
    cost = tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits(logits=Z3, labels=Y))
    
    return cost
```

### 模型

整体的模型包含以上几个步骤，最后需要创建优化器，然后运行 session 迭代数据集 num_epochs 次，在每个最小批量上运行优化器。

``` python
def model(X_train, Y_train, X_test, Y_test, learning_rate=0.009,
          num_epochs=100, minibatch_size=64, print_cost=True):
    ops.reset_default_graph()                         # to be able to rerun the model without overwriting tf variables
    tf.set_random_seed(1)                             # to keep results consistent (tensorflow seed)
    seed = 3                                          # to keep results consistent (numpy seed)
    (m, n_H0, n_W0, n_C0) = X_train.shape             
    n_y = Y_train.shape[1]                            
    costs = []                                        # To keep track of the cost
    
    # Create Placeholders of the correct shape
    X, Y = create_placeholders(n_H0, n_W0, n_C0, n_y)

    # Initialize parameters
    parameters = initialize_parameters()
    
    # Forward propagation: Build the forward propagation in the tensorflow graph
    Z3 = forward_propagation(X, parameters)
    
    # Cost function: Add cost function to tensorflow graph
    cost = compute_cost(Z3, Y)
    
    # Backpropagation: Define the tensorflow optimizer. Use an AdamOptimizer that minimizes the cost.
    optimizer = tf.train.AdamOptimizer(learning_rate=learning_rate).minimize(cost)
    
    # Initialize all the variables globally
    init = tf.global_variables_initializer()
     
    # Start the session to compute the tensorflow graph
    with tf.Session() as sess:
        
        # Run the initialization
        sess.run(init)
        
        # Do the training loop
        for epoch in range(num_epochs):

            minibatch_cost = 0.
            num_minibatches = int(m / minibatch_size) # number of minibatches of size minibatch_size in the train set
            seed = seed + 1
            minibatches = random_mini_batches(X_train, Y_train, minibatch_size, seed)

            for minibatch in minibatches:

                # Select a minibatch
                (minibatch_X, minibatch_Y) = minibatch
                # IMPORTANT: The line that runs the graph on a minibatch.
                # Run the session to execute the optimizer and the cost, the feedict should contain a minibatch for (X,Y).
                _ , temp_cost = sess.run([optimizer, cost], feed_dict={X:minibatch_X, Y:minibatch_Y})
                
                minibatch_cost += temp_cost / num_minibatches
                
            # Print the cost every epoch
            if print_cost == True and epoch % 5 == 0:
                print ("Cost after epoch %i: %f" % (epoch, minibatch_cost))
            if print_cost == True and epoch % 1 == 0:
                costs.append(minibatch_cost)
        
        # plot the cost
        plt.plot(np.squeeze(costs))
        plt.ylabel('cost')
        plt.xlabel('iterations (per tens)')
        plt.title("Learning rate =" + str(learning_rate))
        plt.show()

        # Calculate the correct predictions
        predict_op = tf.argmax(Z3, 1)
        correct_prediction = tf.equal(predict_op, tf.argmax(Y, 1))
        
        # Calculate accuracy on the test set
        accuracy = tf.reduce_mean(tf.cast(correct_prediction, "float"))
        print(accuracy)
        train_accuracy = accuracy.eval({X: X_train, Y: Y_train})
        test_accuracy = accuracy.eval({X: X_test, Y: Y_test})
        print("Train Accuracy:", train_accuracy)
        print("Test Accuracy:", test_accuracy)
                
        return train_accuracy, test_accuracy, parameters
```

运行以下代码，将模型训练 100 个 epoch，同时每 5 个 epoch 输出模型的代价：

``` python
_, _, parameters = model(X_train, Y_train, X_test, Y_test)
```

![](output.png)

最后模型在训练集上的准确度能达到 94%，在测试集上能达到 78%。模型的方差比较高，还可以继续调节超参数和使用正则项提高模型的性能。

## 总结

投出去的论文的实验也是用 Tensorflow 实现的，Tensorflow 确实强大，但是如果不是很熟悉就想用还是有点难，当时遇到一些小问题都得花半天时间解决，看来还需要多学习一下，多看看文档。

## 参考文献

1. 吴恩达. DeepLearning. 