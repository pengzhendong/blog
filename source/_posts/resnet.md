---
title: 残差网络 ResNet
date: 2018-12-12 16:55:03
updated: 2018-12-12 17:42:48
tags: Deep Learning
mathjax: true
---

## 前言

稳稳地被拒了，现在再回顾自己写的内容，发现确实有不少地方似懂非懂的，特别是调用了别人代码的地方。继续我的 deeplearning 总结吧！由于实验中有 ResNet 的实现，所以将它单独作为一篇总结。

<!-- more -->

## 深度神经网络的问题

神经网络越深拟合能力就越强，也可以学到不同级别抽象的特征，但是太深就会导致梯度消失等问题，阻碍了网络的收敛。这个问题前面也介绍过，通常是通过标准初始化层和中间的标准化层来解决。这样虽然可以让网络收敛，但是准确度会随着网络的加深而变得饱和，然后退化，一个 20 层和一个 56 层的网络的训练误差和测试误差如下图所示：

![](https://s1.ax2x.com/2018/12/13/5QOf02.png)

## 残差网络 ResNet

ResNet[2] 的主要思想就是通过远跳连接（也叫捷径连接）来解决网络过深的问题，远跳连接允许在反向传播的时候，梯度直接传播给更前面的层，结构如下图所示：

![](https://s1.ax2x.com/2018/12/13/5Qb0nX.png)

左图为普通的神经网络块的传输，其前向传播的计算步骤为：
$$
z^{[l+1]}=W^{[l+1]}a^{[l]}+b^{[l+1]}
$$

$$
a^{[l+1]}=g(z^{[l+1]})
$$

$$
z^{[l+2]}=W^{[l+2]}a^{[l+1]}+b^{[l+2]}
$$

$$
a^{[l+2]}=g(z^{[l+2]})
$$

右图为一个残差块，通过增加了一个恒等映射，把当前输出不添加任何参数直接传给下一层网络。残差块的堆叠可以构建非常深的网络，其前向传播的计算步骤只有最后一步与上述步骤不同：
$$
a^{[l+2]}=g(z^{[l+2]}+a^{[l]})
$$

### ResNet 原理

残差网络看起来似乎同容易理解，但是还要理解为什么有了它就不怕增加网络的深度了。假设网络中均使用 ReLU 激活函数且最后的输出 $a\geq 0$，则：
$$
a^{[l+2]}=g(z^{[l+2]}+a^{[l]})=g(W^{[l+2]}a^{[l+1]}+b^{[l+2]}+a^{[l]})
$$
如果我们使用 L2 正则化项或者权重衰减，那么就可以压缩 $W$ 和 $b$ 的值，进而使网络的拟合能力逼近于更浅的网络。例如当 $W^{[l+2]}=0$ 和 $b^{[l+2]}=0$ 时，有：
$$
a^{[l+2]}=g(a^{[l]})=ReLU(a^{[l]})=a^{[l]}
$$
所以在增加了残差块后更深的网络的性能也并不逊色于没有增加残差块简单的网络，尽管增加了网络的深度，但是并不会影响网络的性能。同时如果增加的网络结构能够学习到一些有用的信息，那么就会提升网络的性能。

## 代码实现

实验同样是用 Keras 来实现，首先需要载入需要用到的包：

``` python
import numpy as np
from keras import layers
from keras.layers import Input, Add, Dense, Activation, ZeroPadding2D, BatchNormalization, Flatten, Conv2D, AveragePooling2D, MaxPooling2D, GlobalMaxPooling2D
from keras.models import Model, load_model
from keras.preprocessing import image
from keras.utils import layer_utils
from keras.utils.data_utils import get_file
from keras.applications.imagenet_utils import preprocess_input
import pydot
from IPython.display import SVG
from keras.utils.vis_utils import model_to_dot
from keras.utils import plot_model
from resnets_utils import *
from keras.initializers import glorot_uniform
import scipy.misc
from matplotlib.pyplot import imshow
%matplotlib inline

import keras.backend as K
K.set_image_data_format('channels_last')
K.set_learning_phase(1)
```

### 残差块

同时由于结构 $a^{[l+2]}=g(z^{[l+2]}+a^{[l]})$，ResNet 在设计中使用了很多 Same 卷积来保持图像大小相同。在通道不一致的时候，对增加的通道可以用 0 填充或者使用线性投影来保证维度一致（$1\times 1$ 滤波器）。因此残差块分为两种 Identity block 和 Convolutional block，前者维度一致，后者在捷径上添加了一个卷积层用来调节输出的维度。

#### Identity Block

实验实现的 Identity block 远跳了两层，同时使用了批标准化来加速网络的训练过程，结构如下图所示：

![](https://s1.ax2x.com/2018/12/13/5Qb4Un.png)

实现以上残差块的步骤如下所示：

1. 主路径的第一部分
   * 卷积层 Conv2D，其滤波器 $F_1$ 大小为 (1, 1) 和步长为 (1, 1)，valid 卷积并且命名为 `conv_name_base + '2a'`；
   * 在通道的维度上进行批标准化，命名为 `bn_name_base + '2a'`；
   * 使用 ReLU 激活函数，不需要命名并且没有超参数。
2. 主路径的第二部分
   * 卷积层 Conv2D，其滤波器 $F_2$ 大小为 $(f, f)$ 和步长为 (1, 1)，same 卷积并且命名为 `conv_name_base + '2b'`；
   * 在通道的维度上进行批标准化，命名为 `bn_name_base + '2b'`；
   * 使用 ReLU 激活函数。
3. 主路径的第三部分
   * 卷积层 Conv2D，其滤波器 $F_3$ 大小为 (1, 1)​ 和步长为 (1, 1)，same 卷积并且命名为 `conv_name_base + '2c'`；
   * 在通道的维度上进行批标准化，命名为 `bn_name_base + '2c'`；
4. 最后一步
   * 输入需要加上远跳连接；
   * 使用 ReLU 激活函数。

因此一共有三个卷积层，对应三组滤波器，代码如下所示：

``` python
def identity_block(X, f, filters, stage, block):
    # defining name basis
    conv_name_base = 'res' + str(stage) + block + '_branch'
    bn_name_base = 'bn' + str(stage) + block + '_branch'

    # Retrieve Filters
    F1, F2, F3 = filters

    # Save the input value. You'll need this later to add back to the main path. 
    X_shortcut = X

    # First component of main path
    X = Conv2D(filters=F1, kernel_size=(1, 1), strides=(1, 1), padding='valid', name=conv_name_base + '2a', kernel_initializer=glorot_uniform(seed=0))(X)
    X = BatchNormalization(axis=3, name=bn_name_base + '2a')(X)
    X = Activation('relu')(X)

    # Second component of main path (≈3 lines)
    X = Conv2D(filters=F2, kernel_size=(f, f), strides=(1, 1), padding='same', name=conv_name_base + '2b', kernel_initializer=glorot_uniform(seed=0))(X)
    X = BatchNormalization(axis=3, name=bn_name_base + '2b')(X)
    X = Activation('relu')(X)

    # Third component of main path (≈2 lines)
    X = Conv2D(filters=F3, kernel_size=(1, 1), strides=(1, 1), padding='valid', name=conv_name_base + '2c', kernel_initializer=glorot_uniform(seed=0))(X)
    X = BatchNormalization(axis=3, name=bn_name_base + '2c')(X)

    # Final step: Add shortcut value to main path, and pass it through a RELU activation (≈2 lines)
    X = Add()([X, X_shortcut])
    X = Activation('relu')(X)

    return X
```

#### Convolutional Block

在输入和输出维度不匹配的时候可以 Convolutional block，与 Identity block 的不同之处就在于在捷径上也有一个卷积层，其结构如下图所示：

![](https://s1.ax2x.com/2018/12/13/5QbcZS.png)

捷径上的卷积层可以用来调节 $x$ 的大小和通道数，调节通道数即上面提到的线性映射。实现步骤如下所示：

1. 主路径的第一、二和三部分和 Identity block 一致
2. 捷径
   * 卷积层 Conv2D，其滤波器 $F_3$ 大小为 (1, 1)​ 和步长为 $(s, s)$，same 卷积并且命名为 `conv_name_base + '1'`。需要注意的是用的滤波器和主路径第三部分的滤波器一样，只是步长不一样，此处只是为了调节 $x$ 的形状；
   * 在通道的维度上进行批标准化，命名为 `bn_name_base + '1'`；
3. 最后一步
   * 将捷径的输出添加到主路径上；
   * 使用 ReLU 激活函数。

因此一共有四个卷积层，对应三组滤波器，代码如下所示：

``` python
def convolutional_block(X, f, filters, stage, block, s=2):
    # defining name basis
    conv_name_base = 'res' + str(stage) + block + '_branch'
    bn_name_base = 'bn' + str(stage) + block + '_branch'

    # Retrieve Filters
    F1, F2, F3 = filters

    # Save the input value
    X_shortcut = X

    ##### MAIN PATH #####
    # First component of main path 
    X = Conv2D(filters=F1, kernel_size=(1, 1), strides=(s, s), padding='valid', name=conv_name_base + '2a', kernel_initializer=glorot_uniform(seed=0))(X)
    X = BatchNormalization(axis=3, name=bn_name_base + '2a')(X)
    X = Activation('relu')(X)

    # Second component of main path (≈3 lines)
    X = Conv2D(filters=F2, kernel_size=(f, f), strides=(1, 1), padding='same', name=conv_name_base + '2b', kernel_initializer=glorot_uniform(seed=0))(X)
    X = BatchNormalization(axis=3, name=bn_name_base + '2b')(X)
    X = Activation('relu')(X)

    # Third component of main path (≈2 lines)
    X = Conv2D(filters=F3, kernel_size=(1, 1), strides=(1, 1), padding='valid', name=conv_name_base + '2c', kernel_initializer=glorot_uniform(seed=0))(X)
    X = BatchNormalization(axis=3, name=bn_name_base + '2c')(X)

    ##### SHORTCUT PATH #### (≈2 lines)
    X_shortcut = Conv2D(filters=F3, kernel_size=(1, 1), strides=(s, s), padding='valid', name=conv_name_base + '1', kernel_initializer=glorot_uniform(seed=0))(X_shortcut)
    X_shortcut = BatchNormalization(axis=3, name=bn_name_base + '1')(X_shortcut)

    # Final step: Add shortcut value to main path, and pass it through a RELU activation (≈2 lines)
    X = Add()([X, X_shortcut])
    X = Activation('relu')(X)

    return X
```

### 构建 ResNet 模型

50 层的 ResNet-50 网络结构一共分为 5 个阶段（stage），如下图所示：

![](https://s1.ax2x.com/2018/12/13/5QbEDH.png)

ResNet-50 模型的细节为：

* 零填充的大小为 (3, 3)
* 阶段一：
  * 二维卷积使用 64 个大小为 (7, 7) 步长为 (2, 2) 的滤波器，命名为 `conv1`；
  * 批标准化应用于通道的维度；
  * 最大池化窗口大小为 (3, 3)，步长为 (2, 2)。
* 阶段二：
  * Convolutional block 使用的三组滤波器的数量分别为 [64, 64, 256]，f=3，s=1，块被命名为 `a`；
  * 两个 Identity block 使用的三组滤波器的数量分别为 [64, 64, 256]，f=3，块被命名为 `b` 和 `c`。
* 阶段三：
  - Convolutional block 使用的三组滤波器的数量分别为 [128, 128, 512]，f=3，s=2，块被命名为 `a`；
  - 三个 Identity block 使用的三组滤波器的数量分别为 [128, 128, 512]，f=3，块被命名为 `b`、`c` 和 `d`。
* 阶段四：
  - Convolutional block 使用的三组滤波器的数量分别为 [256, 256, 1024]，f=3，s=2，块被命名为 `a`；
  - 五个 Identity block 使用的三组滤波器的数量分别为 [256, 256, 1024]，f=3，块被命名为 `b`、`c`、`d`、`e` 和 `f`。
* 阶段五：
  - Convolutional block 使用的三组滤波器的数量分别为 [512, 512, 2048]，f=3，s=2，块被命名为 `a`；
  - 两个 Identity block 使用的三组滤波器的数量分别为 [512, 512, 2048]，f=3，块被命名为 `b` 和 `c`。
* 二维平均池化层使用的窗口大小为 (2, 2)，命名为 `avg_pool`
* 变平
* 全连接（Dense）层将 input 的神经元节点数降为类别数，用于 Softmax 分类，命名为 `'fc' + str(classes)`

代码实现如下所示：

``` python
def ResNet50(input_shape=(64, 64, 3), classes=6):
    # Define the input as a tensor with shape input_shape
    X_input = Input(input_shape)

    # Zero-Padding
    X = ZeroPadding2D((3, 3))(X_input)

    # Stage 1
    X = Conv2D(64, (7, 7), strides=(2, 2), name='conv1', kernel_initializer=glorot_uniform(seed=0))(X)
    X = BatchNormalization(axis=3, name='bn_conv1')(X)
    X = Activation('relu')(X)
    X = MaxPooling2D((3, 3), strides=(2, 2))(X)

    # Stage 2
    X = convolutional_block(X, f=3, filters=[64, 64, 256], stage=2, block='a', s=1)
    X = identity_block(X, 3, [64, 64, 256], stage=2, block='b')
    X = identity_block(X, 3, [64, 64, 256], stage=2, block='c')

    # Stage 3 (≈4 lines)
    X = convolutional_block(X, f=3, filters=[128, 128, 512], stage=3, block='a', s=2)
    X = identity_block(X, 3, [128, 128, 512], stage=3, block='b')
    X = identity_block(X, 3, [128, 128, 512], stage=3, block='c')
    X = identity_block(X, 3, [128, 128, 512], stage=3, block='d')

    # Stage 4 (≈6 lines)
    X = convolutional_block(X, f=3, filters=[256, 256, 1024], stage=4, block='a', s=2)
    X = identity_block(X, 3, [256, 256, 1024], stage=4, block='b')
    X = identity_block(X, 3, [256, 256, 1024], stage=4, block='c')
    X = identity_block(X, 3, [256, 256, 1024], stage=4, block='d')
    X = identity_block(X, 3, [256, 256, 1024], stage=4, block='e')
    X = identity_block(X, 3, [256, 256, 1024], stage=4, block='f')

    # Stage 5 (≈3 lines)
    X = X = convolutional_block(X, f=3, filters=[512, 512, 2048], stage=5, block='a', s=2)
    X = identity_block(X, 3, [512, 512, 2048], stage=5, block='b')
    X = identity_block(X, 3, [512, 512, 2048], stage=5, block='c')

    # AVGPOOL (≈1 line). Use "X = AveragePooling2D(...)(X)"
    X = AveragePooling2D(pool_size=(2, 2), padding='same')(X)

    # output layer
    X = Flatten()(X)
    X = Dense(classes, activation='softmax', name='fc' + str(classes), kernel_initializer=glorot_uniform(seed=0))(X)

    # Create model
    model = Model(inputs=X_input, outputs=X, name='ResNet50')

    return model
```

编译训练模型，用于前面实验的手势分类，这是一个六分类的问题，代码如下所示：

``` python
model = ResNet50(input_shape=(64, 64, 3), classes=6)
model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])
X_train_orig, Y_train_orig, X_test_orig, Y_test_orig, classes = load_dataset()

# Normalize image vectors
X_train = X_train_orig / 255.
X_test = X_test_orig / 255.

# Convert training and test labels to one hot matrices
Y_train = convert_to_one_hot(Y_train_orig, 6).T
Y_test = convert_to_one_hot(Y_test_orig, 6).T
model.fit(X_train, Y_train, epochs = 2, batch_size = 32)

preds = model.evaluate(X_test, Y_test)
print("Loss = " + str(preds[0]))
print("Test Accuracy = " + str(preds[1]))
```

运行两个 epoch 就到使测试的准确率达到 87%，最后可以使用 `model.summary()` 查看模型概况和使用以下代码绘制模型图：

``` python
plot_model(model, to_file='model.png')
SVG(model_to_dot(model).create(prog='dot', format='svg'))
```

## 总结

残差网络中的远跳连接解决了深度网络存在梯度消失等问题。为了解决输入和输出维度不匹配，作者提出了两种残差块，一种通过在捷径上使用卷积层调节输出的维度。最后就是将这些块堆叠起来形成深度残差网络。

## 参考文献

1. 吴恩达. DeepLearning. 
2. He K, Zhang X, Ren S, et al. Deep residual learning for image recognition[C]//Proceedings of the IEEE conference on computer vision and pattern recognition. 2016: 770-778.