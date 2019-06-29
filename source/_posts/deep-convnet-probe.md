---
title: 深度卷积网络探究
date: 2018-12-10 15:30:00
updated: 2018-12-10 18:46:34
tags: Deep Learning
mathjax: true
typora-root-url: ./deep-convnet-probe
---

## 前言

自己给自己加个油！还有两周多的内容就结束了，慢慢学了快一年了，博客写写停停，也算是坚持下来了。这一周的内容是深度卷积网络的实例探究，介绍了好些个经典的模型，慢慢扩展吧！

<!-- more -->

## 卷积神经网络

比较经典的卷积神经网络有：LeNet-5、AlexNet 和 VGGNet，下面将简单介绍这三种网络。随着网络的加深则带来梯度消失、梯度爆炸和参数过多等问题，最后介绍 $1\times 1$ 滤波器和谷歌的 Inception 网络，下一篇博客再结合着实验介绍残差网络 ResNet。

### LeNet-5

LeNet-5 是卷积神经网络中比较适合入门的网络结构，也是年代比较久远的网络，由于采用的滤波器都是 $5\times 5$ 的，因此叫 LeNet-5。它在 1998年 由 Yann LeCuu 等人在论文 "Gradient-Based Learning Applied to Document Recognition"[2] 中提出，用于解决 mnist 数据集的字符识别问题，网络结构比较简单，如下图所示：

![](https://s1.ax2x.com/2018/12/10/5Q3372.png)

LeNet-5 除了输入层以外由 7 层网络构成：

1. 卷积层 Conv1：

   输入为 $32\times 32$ 的灰度图，本层使用 6 个 $5\times 5$ 的滤波器，步长为 1，当时人们并不适用零填充，也就是使用 valid 卷积，因此输出结果为 $28\times 28\times 6$；

2. 池化层 Pool1：

   虽然现在我们可能用最大池化更多一些，但是在这篇论文写成的那个年代，人们更喜欢使用平均池化。本层使用大小为 $2\times 2$ 的滤波器，步长为 2，因此图像的宽度和高度都会缩小一半，输出结果为 $14\times 14\times 6$；

3. 卷积层 Conv2：

   输入为 $14\times 14\times 6$，本层使用 16 个大小为 $5\times 5$ 的滤波器，步长为 1，输出结果为 $10\times 10\times 16$；

4. 池化层 Pool2：

   同样是 $2\times 2$ 的滤波器做步长为 2 的平均池化，输出结果为 $5\times 5\times 16$；

5. 全连接层 FC1：

   上一层变平后的 400 个神经元作为输入，本层包含 120 个神经元；

6. 全连接层 FC2：

   本层包含 84 个神经元。

最后还可以加一个节点来预测输出，例如使用 softmax 来进行多分类，当时 LeNet-5 网络在输出层使用的是一种现在已经很少用到的分类器 Guassian Connection，LeNet-5 和上一个实验中的网络结构基本一致。只不过当时人们普遍使用的激活函数是 sigmod 函数和 tanh 函数，而不是 ReLU 函数。模型用的正是这两种激活函数，池化层后用的是 sigmoid 函数。deeplearning.ai 视频中简化后的网络结构如下图所示：

![](https://s1.ax2x.com/2018/12/10/5QTNxn.png)

### AlexNet

AlexNet[3] 由 2012 年 ImageNet 竞赛冠军获得者 Alex Krizhevsky 设计，网络结构如下图所示：

![](https://s1.ax2x.com/2018/12/10/5QTSk2.png)

AlexNet 中首次提出了局部响应归一化技术 LRN（Local Response Normalization，虽然被证明在 AlexNet 中作用不大，现在很少使用），在激活、池化后用来防止过拟合，其操作是对附近通道（附近取多少通道由参数 `local_size` 决定）上同一个位置的像素值进行归一化，因此不改变图像尺寸大小。虽然文章中的输入的图像是 $224\times 224 \times 3$，但是根据公式可知 $227\times 227\times 3$ 的图像才能得到后面的结果。网络一共包含 5 个卷积层（5 个激活层、3 个池化层、2 个局部响应归一化层）和 3 个全连接层：

1. 卷积层 Conv1：

   * 输入：$227\times 227\times 3$；
   * 卷积层：96 个大小为 $11\times 11\times 3$ 的滤波器，步长为 4，valid卷积，输出结果为 $55\times 55\times 96$；
   * 激活层：ReLU 函数，输出结果为 $55\times 55\times 96$；
   * 池化层：最大（重叠）池化，大小为 $3\times 3$ 的滤波器，步长为 2，输出结果为 $27\times 27\times 96$；
   * 局部响应归一化层：local_size 为 5，输出结果为 $27\times 27\times 96$。
2. 卷积层 Conv2：

   * 输入：$27\times 27\times 96$；
   * 卷积层：256 个大小为 $5\times 5\times 96$ 的滤波器，步长为 1，same 卷积，输出结果为 $27\times 27\times 256$；
   * 激活层：ReLU 函数，输出结果为 $27\times 27\times 256$；
   * 池化层：最大池化，大小为 $3\times 3$ 的滤波器，步长为 2，输出结果为 $13\times 13\times 256$；
   * 局部响应归一化层：local_size 为 5，输出结果为 $13\times 13\times 256$。
3. 卷积层 Conv3：

   * 输入：$13\times 13\times 256$；
   * 卷积层：384 个大小为 $3\times 3\times 256$ 的滤波器，步长为 1，same 卷积，输出结果为 $13\times 13\times 384$；
   * 激活层：ReLU 函数，输出结果为 $13\times 13\times 384$。
4. 卷积层 Conv4：

   * 输入：$13\times 13\times 384$；
   * 卷积层：384 个大小为 $3\times 3\times 384$ 的滤波器，步长为 1，same 卷积，输出结果为 $13\times 13\times 384$；
   * 激活层：ReLU 函数，输出结果为 $13\times 13\times 384$。
5. 卷积层 Conv5：

   * 输入：$13\times 13\times384$；
   * 卷积层：256 个大小为 $3\times 3\times 384$ 的滤波器，步长为 1，same 卷积，输出结果为 $13\times 13\times 256$；
   * 激活层：ReLU 函数，输出结果为 $13\times 13\times 256$；
   * 池化层：最大池化，大小为 $3\times 3$ 的滤波器，步长为 2，输出结果为 $6\times 6\times 256$。
6. 全连接层 FC6：
   * 输入：$6\times 6\times 256=9216\times 1 $;
   * 神经元：4096 个神经元，输出为 $4096\times 1$；
   * Dropout：概率为 50%，输出为 $4096\times 1$。
7. 全连接层 FC7：
   - 输入：$4096\times 1$;
   - 神经元：4096 个神经元，输出为 $4096\times 1$；
   - Dropout：概率为 50%，输出为 $4096\times 1$。
8. 全连接层 FC8：
   - 输入：$4096\times 1$;
   - 神经元：1000 个神经元，输出为 $1000\times 1$，即 1000 中分类的概率。

AlexNet 和之前的网络相比，它有以下几点特定：

* 使用了数据增广的方法，即对数据集中的图像进行水平翻转、随机裁剪、平移变换、颜色、光照、对比度变换。或者按照 RGB 三个颜色通道计算均值和标准差，再在整个训练集上计算协方差矩阵，进行特征分解，得到特征向量和特征值，用来做 PCA Jittering（抖动）；
* 首次应用了 Dropout 有效防止过拟合；
* 使用 ReLU 代替传统的 sigmoid 和 tanh 函数；
* 使用了局部响应归一化，虽然这一作用有争议；
* 使用了重叠池化，减小过拟合；
* 多 GPU 并行训练，将网络分成两部分训练，提高了训练速度，整个网络大约有 6000 万个参数。

deeplearning.ai 视频中简化后的网络结构如下图所示：

![](https://s1.ax2x.com/2018/12/11/5QVXjS.png)

### VGG

VGG 网络出自 "Very Deep Convolutional Networks for Large-Scale Image Recognition"[4]，作者一共实验了 A、A-LRN、B、C、D 和 E 六种网络结构，根据网络的层数可以分类为 VGG-11、VGG-13、VGG-16 和 VGG-19。这六种网络结构的详情如下表所示，其中 conv3-512 表示该层使用 512 个大小为 $3\times 3$ 的滤波器：

![5QVz7H.png](https://s1.ax2x.com/2018/12/11/5QVz7H.md.png)

VGG 在 AlexNet 基础上对深度神经网络在深度和宽度上做了更多深入的研究，业界普遍认为更深的网络具有比浅网络更强的表达能力，更能刻画现实和完成更复杂的任务。通常 VGG 指的就是上表中网络结构 D，deeplearning.ai 视频中简化后的网络结构如下图所示：

![5QVQ89.png](https://s1.ax2x.com/2018/12/11/5QVQ89.png)

VGG 与 AlexNet 相比，具有如下改进几点：

* 作者实验发现深度网络中 LRN 的作用并不明显，于是去掉了 LRN 层；
* VGG 用 $3\times 3$ 的滤波器，相比较于 AlexNet 中 $11\times 11$ 的滤波器，参数量更少；
* 池化层使用 $2\times 2$ 的滤波器也比 AlexNet 的 $3\times 3$ 滤波器小。

VGG 主要采用增加卷积层的方法来加深网络，结果发现深度越深，网络学习能力越好，分类能力越强。为了更好的探究深度对网络的影响，必须要解决参数量的问题，作者分析认为 $3\times 3$ 的滤波器足以捕捉到横、竖以及斜对角像素的变化，使用大卷积核会带来参数量的爆炸不说，而且图像中会存在一些部分被多次卷积，可能会给特征提取带来困难。

### Network in Network

传统的卷积层只是将前一层的特征进行了线性组合，然后经过一个非线性激活提取的特征就是低度非线性的。在[单隐层神经网络](2018/05/19/Neuron-network/#神经网络模型)中我们知道，虽然单隐层神经网络几乎可以拟合任意函数，但是需要特别多神经元节点。类似的，传统的 CNN 就会使用大量的滤波器尽可能的提取更多的特征，这就会导致网络结构复杂和参数空间巨大。

#### $1\times 1$ 滤波器

对于单通道的图像，$1\times 1$ 的滤波器可能没什么用，相当于让图像上的每一个像素值都乘以一个数。但是对于多通道的图像，这个操作实现的就是多个通道的线性组合，类似于全连接神经网络，可以起到降维或者升维（滤波器个数大于原图像通道数）的作用，从而减少运算量。举个比较形象的例子就是 RGB 图像转灰度图 `rgb2gray`，通过对三个通道的像素值的线性组合得到单通道的灰度图，只不过 `rgb2gray` 中使用的滤波器也是人工设置的，而且只有一个滤波器。

如下图所示，使用大小为 $5\times 5\times 192$ 的滤波器对 $28\times 28\times 192$ 的输入进行滤波，如果希望输出结果为 $28\times 28\times 32$，那么就需要 32 个滤波器进行 Same 卷积。运算次数虽然和输入图像的大小无关，但是和输入图像的通道有关，通道越大和滤波器越大则运算次数越大，运算次数为 $(28\times 28\times 32)\times(5\times 5\times 192)$，大概需要 1.2 亿次。而先使用 $1\times 1$ 小滤波器压缩通道后再在小通道的图像使用大滤波器就可以解决这个问题，运算次数为：
$$
(28\times 28\times 16)\times(1\times 1\times 192)+(28\times 28\times 32)\times(5\times 5\times 16)
$$
大概只需要 1204 万次运算，计算量是原来的十分之一左右。

![](https://s1.ax2x.com/2018/12/12/5QjxSR.png)

多个 $1\times 1$ 的滤波器配合激活函数还可以实现对原图像的多通道做非线性的组合，可以减少需要的滤波器的个数进而实现参数的减少化。这个思想来自于 Network in Network 中的多层感知卷积层 Mlpconv layer。

#### 多层感知卷积层

在 Network in Network[5] 中，作者在卷积后使用一个微小的神经网络（主要是多层感知器）对提取的特征进行进一步抽象。因为传统的卷积层只是一个线性的过程，即使层次比较深的网络层也只是对于浅层网络层学习到的特征进行整合。因此，在对特征进行高层次整合之前，进行进一步的抽象是必要的，即使用微网络进行进一步的抽象，这也是该文章名字的由来。网络的结构如下图所示：

![](https://s1.ax2x.com/2018/12/12/5QdKsy.png)

为了便于解释，在原图中添加了图像和滤波器的尺寸，这是一个 384 种类别的分类问题。在第一层网络中，输入为 $224\times 224\times 3$ 的图像，首先使用 96 个 $11\times 11\times 3$ 的滤波器进行卷积，每计算一个**局部**后可以得到一个 96 维的向量；然后将其输入一个多层感知机（图中第一列为输入层，第二列为隐藏层），本例子中隐藏层神经元节点数等于输入层的神经元节点数（一共有 $96\times 96$ 个参数），最后输出一张 $55\times 55\times 96$ 的图像。

这里的多层感知机就等同于 $1\times 1$ 滤波器，对特征进一步抽象，进而非线性激活函数不需要太多神经元节点就可以拟合处很复杂的函数，多添加几层隐藏层就相当于多进行几次 $1\times 1$ 卷积。感知机中隐藏层的神经元节点个数就相当于 $1\times 1$ 滤波器的个数，可以这个数来减少模型的参数。

#### 全局池化

作者还用全局平均池化取代网络的全连接层，避免全连接层参数过多而且容易过拟合。全局池化就是滤波器大小和原图像一致，因此每张大小为 $W\times H\times C$ 的图像，池化后的输出为 $1\times 1\times C$。对大小为 $13\times 13\times 384$ 的图像进行全局平均池化就是每个通道的像素值求平均，最后得到一个 384 维的向量。

上图中最后一个多层感知机的隐藏层神经元节点数等于分类的类别数，主要是为了在全局平均池化的时候每一个通道（特征图）能够对应于一个输出类别，让模型的解释性更强，最后输入到 384 中分类的 Softmax 层中。

### GoogLeNet

GoogLeNet 是谷歌团队在 2014 年的 ILSVRC 比赛中使用的网络，这个名字也是为了向 LeNet 致敬。谷歌团队在 Going deeper with convolutions[6] 中提出 Inception 这种网络结构，也就是用 Inception 模块组成的网络都叫 Inception 网络，最后他们在比赛中使用的那个 22 层的 Inception 网络就叫 GoogLeNet，网络结构如下图所示：

![](https://s1.ax2x.com/2018/12/12/5QjGty.png)



细节可以点击[查看全图](https://randy-1251769892.cos.ap-beijing.myqcloud.com/GoogLeNet.pdf)，由于模型的层数比较多，就不再一一介绍。下面重点介绍一下文章中提出的 Inception 模块的思想。

#### Inception

Inception （盗梦空间）这个名字来自于电影名字是因为其中有一句台词：

> We need to go deeper

文章指出提高深度神经网络性能最直接的方法是增大网络规模：增加网络层数和增加各层神经元数量。但是在样本较少的情况下，参数越多越容易导致网络过拟合；而且需要的计算资源会直线上升。根据 Hebbian 原理，解决这两个问题的根本途径是将全连接改成稀疏连接，例如 Dropout 就是随机使神经元失活，进而让连接变得稀疏。但是由于实际运算过程中都是基于矩阵优化的，因此很难减少运算的时间，所以目前视觉领域的机器学习系统仅仅是利用卷积的空域稀疏性。

Inception 结构的主要思想是找到网络的最优稀疏的结构，也就是说不需要人为决定使用哪个滤波器或者是否需要池化，而是由网络自行确定这些参数，给网络添加这些参数的所有可能值后把这些输出连接起来，让网络自己学习它需要什么样的参数，采用哪些滤波器组合。Inception 模块的原始结构如下图所示：

![](https://s1.ax2x.com/2018/12/12/5QjATH.png)

后来 $1\times 1$ 滤波器广泛使用后，就被应用到了 Inception 模块中，模块结构如下图所示：

![](https://s1.ax2x.com/2018/12/12/5Qjg6i.png)

理解了 Inception 模块就能理解 Inception 网络，无非是很多个 Inception 模块组成了网络。自从 Inception 模块诞生以来，经过研究者们的不断发展而衍生了许多新的版本。比如 Inception V2、V3 和 V4，还有一个版本引入了跳跃连接的方法，即 ResNet 中防止梯度消失和梯度爆炸的思想。

## 总结

了解了卷积神经网络的发展历程，感觉还是很有意思的。人们提出了很多想法，无非就是为了让模型更复杂又不能出现过拟合，或者让模型运算得更快一点，总之百变不离其中，就是提取特征。但是整体感觉下来好像还是缺点什么，或许就是这种数据科学确实没有一个很标准的答案吧！同时还是默默期待哪一天会出现这个时代的牛顿，给所有一切很自然的东西一个公式或者定理吧。

## 参考文献

1. 吴恩达. DeepLearning. 
2. LeCun Y, Bottou L, Bengio Y, et al. Gradient-based learning applied to document recognition[J]. Proceedings of the IEEE, 1998, 86(11): 2278-2324.
3. Krizhevsky, Alex, Ilya Sutskever, and Geoffrey E. Hinton. "Imagenet classification with deep convolutional neural networks." Advances in neural information processing systems. 2012.
4. Simonyan K, Zisserman A. Very deep convolutional networks for large-scale image recognition[J]. arXiv preprint arXiv:1409.1556, 2014.
5. Lin M, Chen Q, Yan S. Network in network[J]. arXiv preprint arXiv:1312.4400, 2013.
6. Szegedy C, Liu W, Jia Y, et al. c[C]//Proceedings of the IEEE conference on computer vision and pattern recognition. 2015: 1-9.