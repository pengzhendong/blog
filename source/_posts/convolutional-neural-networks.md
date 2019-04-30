---
title: 卷积神经网络
date: 2018-12-03 13:16:18
updated: 2018-12-03 15:16:50
tags: Deep Learning
mathjax: true
---

## 前言

“如果我们要建成一个更好的世界，我们必须有从头做起的勇气”，我差的很远，最近没什么效率，总是不想改开题报告和论文，只能看看书和学学深度学习。读研以前对未来的那种憧憬也没了，我现在的想法就是赶紧毕业，找一个工程师的岗位，在实践中成长吧！学术搞不来！

<!-- more -->

## 卷积神经网络

平常我们使用神经网络的时候，输入的特征的维度一般不会很大，但是如果需要处理图片，例如一张 $1000\times 1000$ 像素的三通道图，那么就会有三百万个输入。如果下一层神经元的节点数为 1000，那么就需要三十亿个参数！很难处理这么多的参数，而且也很难有足够多的数据来保证模型不会过拟合，因此就需要卷积运算。

卷积神经网络的思想就是检测图像左上角的特征检测器也适用于图像的右下角，图像的分布通常差不多，参数通过移动卷积核达到共享的效果。卷积神经网络的原理就是把卷积的滤波器（算子）当成参数来学习，而不是用固定的 Sobel 算子或者其他人工定义的算子。需要注意的是，在深度学习领域，卷积神经网络中实际的操作是相关操作，即省略了滤波器翻转的过程，不过这影响并不大，因此人们还是把它叫做卷积神经网络。

**符号定义：**

- $[l]$ 表示第 $l$ 层，例如 $W^{[5]}$ 是第五层的参数
- $(i)$ 表示第 $i$ 个样本，例如 $x^{(i)}$ 是第 $i$ 个训练样本
- $i$ 表示向量的第 $i$ 维，例如 $a^{[l]}_i$ 是第 $l$ 层的激活向量得第 $i$ 维
- $n^{[l]}_H, n^{[l]}_W$ 和 $n^{[l]}_C$ 分别表示第 $l$ 层的高、宽和通道数
- $n^{[l]}_{H_{prev}}, n^{[l]}_{W_{prev}}$ 和 $n^{[l]}_{C_{prev}}$ 分别表示第 $l$ 层的的上一层高、宽和通道数，即 $n^{[l-1]}_H, n^{[l-1]}_W$ 和 $n^{[l-1]}_C$ 

### 卷积

对于一张 $n\times n$ 的图片和尺寸为 $f\times f$ 的滤波器，对于步长为 1 的卷积神经网络，卷积后的图片大小是：
$$
n\times n \* f\times f \rightarrow (n-f+1)\times (n-f+1)
$$
多通道图像的滤波器的通道数要和图像的一致，通道数为 $n_C$ 的立体卷积输出的图像大小为：
$$
n\times n\times n_C \* f\times f\times n_C \rightarrow (n-f+1)\times (n-f+1)
$$

#### 零填充

没有零填充的叫 **Valid 卷积**，由于网络的层数可能会比较多，经过卷积之后的图片就会越来越小，所以需要对图片的进行零填充。

![](https://s1.ax2x.com/2018/12/04/5YoolY.png)

如果填充使得输出和原图一样大，就叫 **Same 卷积**，假设进行了 $p$ 次零填充，有：
$$
n+2p-f+1=n
$$
解得 $p=\frac{f-1}{2}$。对数据集中的图像进行零填充的代码如下：

``` python
def zero_pad(X, pad):
    """
    X -- (m, n_H, n_W, n_C) representing a batch of m images
    pad -- integer
    X_pad -- (m, n_H + 2*pad, n_W + 2*pad, n_C)
    """
    
    X_pad = np.pad(X, ((0,0), (pad,pad), (pad,pad), (0,0)), 'constant', constant_values = (0, 0))
    
    return X_pad
```

#### 步长

卷积神经网络中还有一个参数叫做步长（stride），也就是滤波器移动的步长 $s$，卷积后的图片大小是：
$$
n\times n \* f\times f \rightarrow (\lfloor\frac{n+2p-f}{s}+1\rfloor)\times (\lfloor\frac{n+2p-f}{s}+1\rfloor)
$$

对于后面所有内容，如果两个维度上的数值相等，则只记一个维度。例如 $f\times f$ 的滤波器，则说是大小为 $f$ 的滤波器；两个维度上的步长为 $1\times 1$，则说是步长为 1。 

### 单层卷积神经网络

步长为 1 的立体 valid 卷积输出的图像是单通道图像，代表图像的某一种特征，可以使用多个提取图像多种特征，如下图所示：

![](https://s1.ax2x.com/2018/12/04/5YoZdB.png)

上图中滤波器的通道数等于原图像的通道数，一共有两个滤波器（例如黄色检测水平线和橙色检测竖直线），最后卷积输出两张单通道的图像，这两张图像叠在一起就可以得到一张 $4\times 4$ 的双通道图像，可以在该图像上继续进行卷积，提取更加高级的特征。

在卷积神经网络中，得到上图两张 $4\times 4$ 的单通道图像后通常还需要进行激活函数操作，即加上偏置后经过 ReLU 函数，最后才叠在一起 。假设原图像为 $I$，对于第 $i$ 个滤波器 $f_i$， 输出图像的第 $i$ 个通道 $O_i$ 为：
$$
O_i=ReLU(I\* f_i+b_i)
$$
卷积神经网络的动态视频如下所示：

<center><video width="620" height="440" controls>
  <source src="https://randy-1251769892.cos.ap-beijing.myqcloud.com/conv_kiank.mp4" type="video/mp4">
Your browser does not support the video tag.
    </video></center>


#### 代码

在计算卷积的过程中，每次从图像中选出一部分与滤波器进行加权求和，然后加上偏置。代码如下所示：

``` python
def conv_single_step(a_slice_prev, W, b):
    """
    a_slice_prev -- (f, f, n_C_prev) slice of input data
    W -- (f, f, n_C_prev) Weight parameters contained in a window
    b -- (1, 1, 1) Bias parameters contained in a window
    """

    # Element-wise product between a_slice and W. Do not add the bias yet.
    s = np.multiply(a_slice_prev, W)
    # Sum over all entries of the volume s.
    Z = np.sum(s)
    # Add bias b to Z. Cast b to a float() so that Z results in a scalar value.
    Z = Z + b

    return Z
```

那么如何从图像中选出一部分呢？需要对选出的部分图像进行定义，定义其水平和竖直的起点和终点。如下图所示：

![](https://s1.ax2x.com/2018/12/04/50BIRE.png)

根据前面的定义，卷积输出的大小为：
$$
n_H = \lfloor \frac{n_{H_{prev}} - f + 2 \times pad}{stride} \rfloor +1
$$

$$
n_W = \lfloor \frac{n_{W_{prev}} - f + 2 \times pad}{stride} \rfloor +1
$$

全部的前向卷积过程的代码如下所示：

``` python
def conv_forward(A_prev, W, b, hparameters):    
    # Retrieve dimensions from A_prev's shape (≈1 line)  
    (m, n_H_prev, n_W_prev, n_C_prev) = A_prev.shape
    
    # Retrieve dimensions from W's shape (≈1 line)
    (f, f, n_C_prev, n_C) = W.shape
    
    # Retrieve information from "hparameters" (≈2 lines)
    stride = hparameters['stride']
    pad = hparameters['pad']
    
    # Compute the dimensions of the CONV output volume using the formula given above. Hint: use int() to floor. (≈2 lines)
    n_H = int((n_H_prev - f + 2 * pad) / stride) + 1
    n_W = int((n_W_prev - f + 2 * pad) / stride) + 1
    
    # Initialize the output volume Z with zeros. (≈1 line)
    Z = np.zeros((m, n_H, n_W, n_C))
    
    # Create A_prev_pad by padding A_prev
    A_prev_pad = zero_pad(A_prev, pad)
    
    for i in range(m):                               # loop over the batch of training examples
        a_prev_pad = A_prev_pad[i,:,:,:]                               # Select ith training example's padded activation
        for h in range(n_H):                           # loop over vertical axis of the output volume
            for w in range(n_W):                       # loop over horizontal axis of the output volume
                for c in range(n_C):                   # loop over channels (= #filters) of the output volume
                    
                    # Find the corners of the current "slice" (≈4 lines)
                    vert_start = stride * h
                    vert_end = vert_start + f
                    horiz_start = stride * w
                    horiz_end = horiz_start + f
                    
                    # Use the corners to define the (3D) slice of a_prev_pad (See Hint above the cell). (≈1 line)
                    a_slice_prev = a_prev_pad[vert_start:vert_end,horiz_start:horiz_end,:]
                    
                    # Convolve the (3D) slice with the correct filter W and bias b, to get back one output neuron. (≈1 line)
                    Z[i, h, w, c] = conv_single_step(a_slice_prev,W[:,:,:,c], b[:,:,:,c])
                                        
    # Making sure your output shape is correct
    assert(Z.shape == (m, n_H, n_W, n_C))
    
    # Save information in "cache" for the backprop
    cache = (A_prev, W, b, hparameters)
    
    return Z, cache
```

最后还需要对输出进行激活函数操作：`A[i, h, w, c] = activation(Z[i, h, w, c])`。

#### 参数

假设有 10 个 $3\times 3\times 3$ 的滤波器，那么单层卷积神经网络有多少参数呢？每个滤波器对应 $3\times 3\times 3+1=28$ 个参数，其中 $3\times 3\times 3$ 表示滤波器中的数值，1 表示滤波器的偏置项。因此 10 个滤波器就一共有 $28\times 10=280$ 个参数，不管图像的大小是多少都不会改变参数的个数。

### 池化层

在卷积层之后通常还有池化层，其目的是为了缩减模型的大小，提高计算速度，同时提高所提取特征的鲁棒性。其实池化层就是属于非线性空间滤波中的统计排序滤波器。该层一共有两个参数 $f$ 和 $s$，分别表示滤波器的大小和步长，如果 $f=s$ 则是正常池化，如果 $s>f$ 则是重叠池化（Overlapping），重叠池化有避免过拟合的作用。$f=s=2$ 的最大池化如下图所示： 

![](https://s1.ax2x.com/2018/12/04/5Yo72d.png)

由于池化层两个参数都是超参数，不需要训练，因此卷积层和池化层一起通常算一层。类似于卷积层，池化层的输出的图像大小为：
$$
n_H = \lfloor \frac{n_{H_{prev}} - f}{stride} \rfloor +1
$$

$$
n_W = \lfloor \frac{n_{W_{prev}} - f}{stride} \rfloor +1
$$

$$
n_C = n_{C_{prev}}
$$

类似于卷积层，池化层的代码如下所示：

``` python
def pool_forward(A_prev, hparameters, mode = "max"):
    # Retrieve dimensions from the input shape
    (m, n_H_prev, n_W_prev, n_C_prev) = A_prev.shape
    
    # Retrieve hyperparameters from "hparameters"
    f = hparameters["f"]
    stride = hparameters["stride"]
    
    # Define the dimensions of the output
    n_H = int(1 + (n_H_prev - f) / stride)
    n_W = int(1 + (n_W_prev - f) / stride)
    n_C = n_C_prev
    
    # Initialize output matrix A
    A = np.zeros((m, n_H, n_W, n_C))              
    
    for i in range(m):                         # loop over the training examples
        for h in range(n_H):                     # loop on the vertical axis of the output volume
            for w in range(n_W):                 # loop on the horizontal axis of the output volume
                for c in range (n_C):            # loop over the channels of the output volume

                    # Find the corners of the current "slice" (≈4 lines)
                    vert_start = stride * h
                    vert_end = vert_start + f
                    horiz_start = stride * w
                    horiz_end = horiz_start + f

                    # Use the corners to define the current slice on the ith training example of A_prev, channel c. (≈1 line)
                    a_prev_slice = A_prev[i, vert_start:vert_end, horiz_start:horiz_end, c]

                    # Compute the pooling operation on the slice. Use an if statment to differentiate the modes. Use np.max/np.mean.
                    if mode == "max":
                        A[i, h, w, c] = np.max(a_prev_slice)
                    elif mode == "average":
                        A[i, h, w, c] = np.mean(a_prev_slice)
    
    # Store the input and hparameters in "cache" for pool_backward()
    cache = (A_prev, hparameters)
    
    # Making sure your output shape is correct
    assert(A.shape == (m, n_H, n_W, n_C))
    
    return A, cache
```

### 多层卷积神经网络

一个卷积层、一个激活层加上一个池化层算一层，通常还会在卷积神经网络后面加上一个全连接层，多层卷积神经网络的模型结构如下图所示：

![](https://s1.ax2x.com/2018/12/04/50BfTz.png)

上图为两个（x2）卷积层和一个全连接层的神经网络，假设输入为 $32\times 32\times 3$ 的图像，参数如下所示：

* CONV1：8 个大小为 5 的滤波器，步长为 1；
* POOL1：滤波器大小为 2，步长为 2；
* CONV2：16 个大小为 5 的滤波器，步长为 1；
* POOL2：滤波器大小为 2，步长为 2；
* FC：128 个神经元节点；
* SOFTMAX：10 个神经元节点（用于手写数字分类）。

网络各层的参数个数如下表所示：

|                 | Activation Shape | Activation Size | # parameters             |
| --------------- | ---------------- | --------------- | ------------------------ |
| Input           | (32, 32, 3)      | 3,072           | 0                        |
| CONV1(f=5, s=1) | (28, 28, 8)      | 6,272           | $208=8\times (25+1)$     |
| POOL1(f=2, s=2) | (14, 14, 8)      | 1,568           | 0                        |
| CONV2(f=5, s=1) | (10, 10, 16)     | 1,600           | $416=16\times (25+1)$    |
| POOL2(f=2, s=2) | (5, 5, 16)       | 400             | 0                        |
| FC              | (128, 1)         | 128             | $51,201=400\times 128+1$ |
| SOFTMAX         | (10, 1)          | 10              | $1281=128\times 10+1$    |

## 反向传播

相比较于循环神经网络，卷积神经网络的反向传播就比较简单，因为卷积操作的过程就是加权求和（线性滤波）。卷积神经网络的反向传播分为两部分：卷积层和池化层。

### 卷积层

类似是普通的深度神经网络，卷积层的反向传播主要计算 $dA$、$dW_c$ 和 $db$。

#### 计算 dA

给定一个滤波器 $W_c$，卷积层关于代价函数的梯度为：
$$
dA+=\sum_{h=0}^{n_H}\sum_{w=0}^{n_W}W_c\times dZ_{hw}
$$
其中 $dZ_{hw}$ 为卷积层 $Z$ 的第 $h$ 行的第 $w$ 列关于代价函数的梯度。因为在前向卷积的时候，不同的 `a_slice` 与同一个滤波器进行运算，因此在反向传播的时候也是用同一个 $W_c$。

```python
da_prev_pad[vert_start:vert_end, horiz_start:horiz_end, :] += W[:,:,:,c] * dZ[i, h, w, c]
```

#### 计算 dW

$dW_{c}$ 是损失函数关于一个滤波器的导数，定义为：
$$
dW_c+=\sum_{h=0}^{n_H}\sum_{w=0}^{n_W} a_{slice} \times dZ_{hw}
$$

``` python
dW[:,:,:,c] += a_slice * dZ[i, h, w, c]
```

#### 计算 db

$db$ 为滤波器中偏置关于损失函数的导数，定义为：
$$
db=\sum_h\sum_w dZ_{hw}
$$

``` python
db[:,:,:,c] += dZ[i, h, w, c]
```

卷积层全部反向传播的代码如下所示：

``` python
def conv_backward(dZ, cache):    
    # Retrieve information from "cache"
    (A_prev, W, b, hparameters) = cache
    
    # Retrieve dimensions from A_prev's shape
    (m, n_H_prev, n_W_prev, n_C_prev) = A_prev.shape
    
    # Retrieve dimensions from W's shape
    (f, f, n_C_prev, n_C) = W.shape
    
    # Retrieve information from "hparameters"
    stride = hparameters['stride']
    pad = hparameters['pad']
    
    # Retrieve dimensions from dZ's shape
    (m, n_H, n_W, n_C) = dZ.shape
    
    # Initialize dA_prev, dW, db with the correct shapes
    dA_prev = np.zeros((m, n_H_prev, n_W_prev, n_C_prev))                           
    dW = np.zeros((f, f, n_C_prev, n_C))
    db = np.zeros((1, 1, 1, n_C))

    # Pad A_prev and dA_prev
    A_prev_pad = zero_pad(A_prev, pad)
    dA_prev_pad = zero_pad(dA_prev, pad)
    
    for i in range(m):                       # loop over the training examples
        
        # select ith training example from A_prev_pad and dA_prev_pad
        a_prev_pad = A_prev_pad[i,:,:,:]
        da_prev_pad = dA_prev_pad[i,:,:,:]
        
        for h in range(n_H):                   # loop over vertical axis of the output volume
            for w in range(n_W):               # loop over horizontal axis of the output volume
                for c in range(n_C):           # loop over the channels of the output volume
                    
                    # Find the corners of the current "slice"
                    vert_start = stride * h
                    vert_end = vert_start + f
                    horiz_start = stride * w
                    horiz_end = horiz_start + f
                    
                    # Use the corners to define the slice from a_prev_pad
                    a_slice = a_prev_pad[vert_start:vert_end,horiz_start:horiz_end,:]

                    # Update gradients for the window and the filter's parameters using the code formulas given above
                    da_prev_pad[vert_start:vert_end, horiz_start:horiz_end, :] +=  W[:,:,:,c] * dZ[i,h,w,c]
                    dW[:,:,:,c] += a_slice * dZ[i, h, w, c]
                    db[:,:,:,c] += dZ[i, h, w, c]
                    
        # Set the ith training example's dA_prev to the unpaded da_prev_pad (Hint: use X[pad:-pad, pad:-pad, :])
        dA_prev[i, :, :, :] = da_prev_pad[pad:-pad,pad:-pad,:]
    
    # Making sure your output shape is correct
    assert(dA_prev.shape == (m, n_H_prev, n_W_prev, n_C_prev))
    
    return dA_prev, dW, db
```

### 池化层

好在池化层中只有超参数，因此不需要学习。但是为了让梯度反向传播，还是需要计算 $dZ$。由于池化层是非线性操作，因此最大池化需要计算一个 mask 矩阵用来记录最大元素的位置。例如滤波器大小为 2 的最大池化中的 mask 矩阵 $M$ 为：
$$
X = \begin{bmatrix}
1 && 3 \\\
4 && 2
\end{bmatrix} \quad \rightarrow  \quad M =\begin{bmatrix}
0 && 0 \\\
1 && 0
\end{bmatrix}
$$

``` python
def create_mask_from_window(x):
    mask = (x==np.max(x))  
    
    return mask
```

最大池化的反向传播只需要让梯度乘上 mask 矩阵即可。而滤波器大小为 2 的平均池化的 mask 矩阵如下所示：
$$
dZ = 1 \quad \rightarrow  \quad dZ =\begin{bmatrix}
1/4 && 1/4 \\\
1/4 && 1/4
\end{bmatrix}
$$

``` python
def distribute_value(dz, shape):
    # Retrieve dimensions from shape (≈1 line)
    (n_H, n_W) = shape
    
    # Compute the value to distribute on the matrix (≈1 line)
    average = np.float(dz) / np.float(n_H * n_W)
    
    # Create a matrix where every entry is the "average" value (≈1 line)
    a = np.ones((n_H, n_W)) * average

    return a
```

池化层全部反向传播的代码如下所示：

``` python
def pool_backward(dA, cache, mode = "max"):    
    # Retrieve information from cache (≈1 line)
    (A_prev, hparameters) = cache
    
    # Retrieve hyperparameters from "hparameters" (≈2 lines)
    stride = hparameters['stride']
    f = hparameters['f']
    
    # Retrieve dimensions from A_prev's shape and dA's shape (≈2 lines)
    m, n_H_prev, n_W_prev, n_C_prev = A_prev.shape
    m, n_H, n_W, n_C = dA.shape
    
    # Initialize dA_prev with zeros (≈1 line)
    dA_prev = np.zeros((m,n_H_prev,n_W_prev,n_C_prev))
    
    for i in range(m):                       # loop over the training examples
        
        # select training example from A_prev (≈1 line)
        a_prev = A_prev[i,:,:,:]
        
        for h in range(n_H):                   # loop on the vertical axis
            for w in range(n_W):               # loop on the horizontal axis
                for c in range(n_C):           # loop over the channels (depth)
                    
                    # Find the corners of the current "slice" (≈4 lines)
                    vert_start = stride * h
                    vert_end = vert_start + f
                    horiz_start = stride * w
                    horiz_end = horiz_start + f
                    
                    # Compute the backward propagation in both modes.
                    if mode == "max":
                        
                        # Use the corners and "c" to define the current slice from a_prev (≈1 line)
                        a_prev_slice = a_prev[vert_start:vert_end, horiz_start:horiz_end, c]
                        # Create the mask from a_prev_slice (≈1 line)
                        mask = create_mask_from_window(a_prev_slice)
                        # Set dA_prev to be dA_prev + (the mask multiplied by the correct entry of dA) (≈1 line)
                        dA_prev[i, vert_start: vert_end, horiz_start: horiz_end, c] += np.multiply(mask,dA[i, h, w, c])
                        
                    elif mode == "average":
                        
                        # Get the value a from dA (≈1 line)
                        da = dA[i, h, w, c]
                        # Define the shape of the filter as fxf (≈1 line)
                        shape = (f, f)
                        # Distribute it to get the correct slice of dA_prev. i.e. Add the distributed value of da. (≈1 line)
                        dA_prev[i, vert_start: vert_end, horiz_start: horiz_end, c] += distribute_value(da, shape)
                            
    # Making sure your output shape is correct
    assert(dA_prev.shape == A_prev.shape)
    
    return dA_prev
```

## 总结

卷积神经网络听起来很难，但是理解后比循环神经网络简单多了。说到底就是卷积这个概念听起来难，其实也就是那么回事。之前一直不太理解池化层的操作，前几篇博客总结了滤波器后反而有意外的收获，池化也就是非线性空间滤波，只不过通常步长会大点，让输出的图像小点，从而加速计算；重叠池化也是在计算速度和过拟合之间的一个 trade-off。最后还有收获比较大的一点就是池化层中并没有参数需要学习，也就是不需要计算参数的梯度，同时最大池化需要记录最大值的位置用于计算上一层的梯度。

## 参考文献

1. 吴恩达. DeepLearning. 