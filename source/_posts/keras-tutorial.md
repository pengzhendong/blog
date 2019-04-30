---
title: Keras 教程
date: 2018-12-06 10:11:22
updated: 2018-12-06 13:21:15
tags: Deep Learning
mathjax: true
---

## 前言

别人用 Keras 已经写完代码了，我还在学习 Tensorflow，说到底还是需要都熟悉这两个框架才能在使用的时候快速做出选择。对于深度学习这个领域，我不仅在选择超参的时候很疑惑，在选择框架的时候我也很疑惑，什么时候才能有大神一统天下？让我等渣渣学得轻松一点。

<!-- more -->

## Keras

> Keras 是一个用 Python 编写的高级神经网络 API，它能够以 TensorFlow、CNTK 或者 Theano 作为后端运行。

相对于 Python 来说，Tensorflow 是一个高级的框架，而 Keras 就是一个相对于 Tensorflow 来说更加高级的框架。Keras 可以快速的进行实验，能够以最小的时延把想法转换为实验结果，但是 Keras 的确定就是灵活性不够，它可以快速实现常见的模型，但是很难实现一些很复杂的模型。

这次实验是使用 Keras 来实现照片的情绪分类，根据表情判断一个人是高兴还是不高兴，数据集如下所示：

![](https://s1.ax2x.com/2018/12/05/50a7yu.png)

首先载入需要用到的 Keras 相关的包，并且载入数据集进行预处理：

``` python
import numpy as np
from keras import layers
from keras.layers import Input, Dense, Activation, ZeroPadding2D, BatchNormalization, Flatten, Conv2D
from keras.layers import AveragePooling2D, MaxPooling2D, Dropout, GlobalMaxPooling2D, GlobalAveragePooling2D
from keras.models import Model
from keras.preprocessing import image
from keras.utils import layer_utils
from keras.utils.data_utils import get_file
from keras.applications.imagenet_utils import preprocess_input
import pydot
from IPython.display import SVG
from keras.utils.vis_utils import model_to_dot
from keras.utils import plot_model
from kt_utils import *

import keras.backend as K
K.set_image_data_format('channels_last')
import matplotlib.pyplot as plt
from matplotlib.pyplot import imshow

%matplotlib inline

X_train_orig, Y_train_orig, X_test_orig, Y_test_orig, classes = load_dataset()

# Normalize image vectors
X_train = X_train_orig/255.
X_test = X_test_orig/255.

# Reshape
Y_train = Y_train_orig.T
Y_test = Y_test_orig.T
```

训练集中一共有 600 张图像，测试集中一共有 150 张图像，都是 $64\times 64$ 的三通道图像。

## 构建模型

Keras 可以快速构建一个模型原型，例如：

``` python
def HappyModel(input_shape):
    # Define the input placeholder as a tensor with shape input_shape. Think of this as your input image!
    X_input = Input(input_shape)

    # Zero-Padding: pads the border of X_input with zeroes
    X = ZeroPadding2D((3, 3))(X_input)

    # CONV -> BN -> RELU Block applied to X
    X = Conv2D(32, (7, 7), strides = (1, 1), name = 'conv0')(X)
    X = BatchNormalization(axis = 3, name = 'bn0')(X)
    X = Activation('relu')(X)

    # MAXPOOL
    X = MaxPooling2D((2, 2), name='max_pool')(X)

    # FLATTEN X (means convert it to a vector) + FULLYCONNECTED
    X = Flatten()(X)
    X = Dense(1, activation='sigmoid', name='fc')(X)

    # Create model. This creates your Keras model instance, you'll use this instance to train/test the model.
    model = Model(inputs = X_input, outputs = X, name='HappyModel')

    return model
```

在 Tensorflow 中，我们通常在前向传播的时候定义变量 `X`，`Z1`，`A1`，`Z2` 和 `A2`等等，但是在 Keras 通常都是用 `X` 来更新 `X` 的值，除了最后一步中的 `X_input`。构建完模型代码后，需要以下 4 个步骤来训练和测试模型：

1. 通过调用以上函数创建模型；
2. 通过调用 `model.compile(optimizer = "...", loss = "...", metrics = ["accuracy"])` 编译模型；
3. 通过调用 `model.fit(x = ..., y = ..., epochs = ..., batch_size = ...)` 训练模型，`fit` 函数只会首次初始化权值，多次调用则在原来的参数上继续训练;
4. 通过调用 `model.evaluate(x = ..., y = ...)` 测试模型。

``` python
happyModel = HappyModel(X_train.shape[1:])
happyModel.compile('adam', 'binary_crossentropy', metrics=['accuracy'])
happyModel.fit(X_train, Y_train, epochs=40, batch_size=50)
preds = happyModel.evaluate(X_test, Y_test, batch_size=32, verbose=1, sample_weight=None)
print ("Loss = " + str(preds[0]))
print ("Test Accuracy = " + str(preds[1]))
```

测试集的准确率能够达到 95% 左右，但是模型的准确率是在 2-5 个 epoch 的时候才比较稳定，因此通常可以多训练几组 epoch 进行模型的比较。如果需要调节超参数，那么测试集在这里扮演的角色其实是开发集，训练结束后有可能在开发集上过拟合。

### 模型概况

Keras 中还有两个比较好用的功能，即输出模型概况和绘制模型：

* `model.summary()`：用表格打印模型每一层的细节；

  ``` python
  happyModel.summary()
  ```

  ```
  _________________________________________________________________
  Layer (type)                 Output Shape              Param #   
  =================================================================
  input_1 (InputLayer)         (None, 64, 64, 3)         0         
  _________________________________________________________________
  zero_padding2d_1 (ZeroPaddin (None, 70, 70, 3)         0         
  _________________________________________________________________
  conv0 (Conv2D)               (None, 64, 64, 32)        4736      
  _________________________________________________________________
  bn0 (BatchNormalization)     (None, 64, 64, 32)        128       
  _________________________________________________________________
  activation_1 (Activation)    (None, 64, 64, 32)        0         
  _________________________________________________________________
  max_pool (MaxPooling2D)      (None, 32, 32, 32)        0         
  _________________________________________________________________
  flatten_1 (Flatten)          (None, 32768)             0         
  _________________________________________________________________
  fc (Dense)                   (None, 1)                 32769     
  =================================================================
  Total params: 37,633
  Trainable params: 37,569
  Non-trainable params: 64
  _________________________________________________________________
  ```

* `plot_model()`：用图的形式绘制模型。

  ``` python
  plot_model(happyModel, to_file='HappyModel.png')
  SVG(model_to_dot(happyModel).create(prog='dot', format='svg'))
  ```

  <center>![](https://s1.ax2x.com/2018/12/06/50rEiK.png)</center>

## 总结

如果模型的结构不是很复杂，Keras 确实是不二之选，在 Debug 的时候也很方便，感觉还是多看看论文吧！看看大家都怎么做。

## 参考文献

1. 吴恩达. DeepLearning. 