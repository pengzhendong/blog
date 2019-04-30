---
title: 风格迁移
date: 2019-01-14 16:16:19
updated: 2019-01-14 18:42:42
tags: Deep Learning
mathjax: true
---

## 前言

我觉得卷积神经网络最神奇的应用就是风格迁移！大部分应用的思想都相差无几，重点就是如何构造损失函数，将我们的目标用损失函数的方式表示，让模型按照指定的方向去学习。

<!-- more -->

## 可视化

在学习风格迁移之前，首先了解一下卷积神经网络的可视化。训练好的 CNN 模型的隐藏层中的每一个滤波器对应一种特征，每一个滤波器与输入的图像进行卷积运算后经过激活层。如果输入的图像具有该滤波器对应的特征，那么经过激活层后就会被激活，即输出特征图对应的数值大于 0。可视化过程涉及到反卷积和反池化，具体过程可参考 Visualizing and Understanding Convolutional Networks [2]。[DeepVis Toolbox](https://github.com/yosinski/deep-visualization-toolbox) 是一个开源的可视化工具，可视化结果如下图所示：

![](https://s1.ax2x.com/2019/01/14/5dljVG.jpg)

图中可视化的是 AlexNet 的卷积层 Conv5，一共有 $16\times 16=256$ 个滤波器。输入为一张公交车的图像，索引为 26 的滤波器的值如箭头指向所示。将滤波器反卷积和反池化回原图像，结果如左下角所示。右边红框选中的图像为训练集中可以激活这个滤波器的前 9 张图像，黄色框的是其反卷积反池化回原图像的结果。

可以看出，该滤波器提取的是类似车轮的特征。由于茶壶的把柄有点类似车轮，因此右上角的茶壶与该滤波器进行卷积，输入激活函数后也可以得到一个比较大的值。

## 风格迁移

给定一张内容图像 C 和一张风格图像 S，风格迁移模型生成一张具有 C 的内容和 S 的风格图像 G。如下图所示：

![](https://s1.ax2x.com/2019/01/14/5dlxLp.png)

### 迁移学习

风格迁移任务中，需要提取图像的内容特征和风格特征，然后根据特征生成图像（初始化为一张随机噪声图）。通过构造损失函数，令模型学习生成的图像 G 具有 C 的内容和 S 的风格，训练完毕后给定任意两张图像都能生成它们的风格迁移图像。实验使用了迁移学习提取图像特征，首先在 ImageNet 上预训练了一个用于分类的 VGG-19 网络，然后直接应用过来提取图像特征。

``` python
model = load_vgg_model("pretrained-model/imagenet-vgg-verydeep-19.mat")
```

使用 `tf.assign` 函数为模型输入数据，获取模型中间隐藏层的输出如下所示：

``` python
model["input"].assign(image)
sess.run(model["conv4_2"])
```

### 代价函数

风格迁移的代价函数分为两部分：内容代价函数 $J_{content}(C,G)$ 和风格代价函数 $J_{style}(S,G)$。完整的代价函数为：
$$
J(G) = \alpha J_{content}(C,G) + \beta J_{style}(S,G)
$$

其中 $\alpha$ 和 $\beta$ 是超参数，代码实现如下所示：

``` python
def total_cost(J_content, J_style, alpha = 10, beta = 40):
    J = alpha * J_content + beta * J_style
    
    return J
```

#### 内容代价函数

由可视化可知，通常浅层的滤波器提取的特征都是一些简单的特征，例如边角和纹理；比较深的、靠近全连接层的滤波器提取的特征就比较高级，例如一些复杂的纹理或者对象的类别。因此我们需要将比较中间的卷积层的输出作为图像的内容特征，假设选择的层数为 $l$，图像 C 经过该层激活函数后的输出为 $a^{[l](C)}$，为了表示方便，后续内容将省略层数，用 $a^{(C)}$ 表示图像 C 的内容特征，同时后续内容实验会测试不同 $l​$ 取值的影响。

那么如何衡量生成的图像 G 和 C 之间的内容匹配了多少？内容代价函数比较简单，就是计算 C 和 G 的内容特征图每个像素点的差异，然后进行归一化。计算公式如下所示：
$$
J_{content}(C,G) =  \frac{1}{4 \times n_H \times n_W \times n_C}\sum _{ \text{all entries}} (a^{(C)} - a^{(G)})^2
$$
其中 $n_H$、$n_W$ 和 $n_C$ 分别表示特征图的高、宽和通道数。为了**便于理解**，将 3 维的特征图展开成两维，如下所示：

![](https://s1.ax2x.com/2019/01/14/5dSurh.png)

由于 `reshape` 只是修改维度，而不改变填充顺序，因此需要先使用 `transpose` 对矩阵进行转置。使用 Tensorflow 实现内容代码函数分为以下三个步骤：

1. 获取图像维度
2. 展开 $a_C$ 和 $a_G$
3. 计算内容损失

``` python
def compute_content_cost(a_C, a_G):
    # Retrieve dimensions from a_G (≈1 line)
    m, n_H, n_W, n_C = a_G.get_shape().as_list()
    # Reshape a_C and a_G (≈2 lines)
    a_C_unrolled = tf.reshape(tf.transpose(a_C, [3, 2, 1, 0]), [n_C, n_H * n_W, m])
    a_G_unrolled = tf.reshape(tf.transpose(a_G, [3, 2, 1, 0]), [n_C, n_H * n_W, m])
    # compute the cost with tensorflow (≈1 line)
    J_content = (1/ (4* n_H * n_W * n_C)) * tf.reduce_sum(tf.pow((a_G_unrolled - a_C_unrolled), 2))
    
    return J_content
```

计算过程中展开和不展开并不会影响矩阵元素之间的计算，而且 `transpose` 函数默认的参数 `perm` 可以省略。

#### 风格代价函数

图像的风格定义为 $l$ 层中各个通道之间激活项的相关系数，即风格矩阵（也叫 Gram 矩阵）。这里有个小问题就是风格矩阵用 $G$ 表示，生成的图像也是用 $G$ 表示。

##### Gram 矩阵

给定展开成两位的特征图矩阵，其由 $n_C$ 个横向量$(v_{1},\dots ,v_{n_H\times n_W})$ 组成。根据定义，Gram 矩阵中每个元素的值 ${\displaystyle G_{ij} = v_{i}^T v_{j} = np.dot(v_{i}, v_{j})  }$，即 $G_{ij}$ 衡量滤波器 $i$ 的激活值 $v_i$ 和滤波器 $j$ 的激活值 $v_j$ 的相似性，如下图所示：

![](https://s1.ax2x.com/2019/01/15/5dRkqE.png)

输出的 Gram 矩阵的维度为 $(n_C, n_C)$，值得注意的是 $G_{ii} = v_{i}^T v_{i}$ 衡量的是图像中滤波器 $i$ 对应的特征的活跃性。假设 $i$ 对应水平纹理，$G_{ii}$ 的值越大就表示图像中水平纹理越多。通过计算各种特征之间的 $G_{ij}$ 即这些特征同时出现的可能性，就可以衡量一张图像的风格。

``` python
def gram_matrix(A):
    GA = tf.matmul(A, tf.transpose(A))
    
    return GA
```

##### 风格代价

我们的目标是最小化风格图像 S 和生成图像 G 之间的 Gram 矩阵的距离，这里只考虑第 $l$ 个隐藏层的风格（考虑的层数越多，风格越相似），其对应的风格代价计算公式如下所示：
$$
J_{style}^{[l]}(S,G)=\frac{1}{4\times {n_C}^2\times (n_H\times n_W)^2}\sum _{i=1}^{n_C}\sum_{j=1}^{n_C}(G^{(S)}\_{ij}-G^{(G)}\_{ij})^2
$$
计算过程分为四个步骤：

1. 获取风格矩阵的维度
2. 展开 $a_S$ 和 $a_G$
3. 计算 S 和 G 的风格矩阵
4. 计算风格代价

``` python
def compute_layer_style_cost(a_S, a_G):
    # Retrieve dimensions from a_G (≈1 line)
    m, n_H, n_W, n_C = a_G.get_shape().as_list()
    
    # Reshape the images to have them of shape (n_H*n_W, n_C) (≈2 lines)
    a_S = tf.transpose(tf.reshape(a_S, [n_H*n_W, n_C]))
    a_G = tf.transpose(tf.reshape(a_G, [n_H*n_W, n_C]))

    # Computing gram_matrices for both images S and G (≈2 lines)
    GS = gram_matrix(a_S)
    GG = gram_matrix(a_G)

    # Computing the loss (≈1 line)
    J_style_layer = (1./(4 * n_C**2 * (n_H*n_W)**2)) * tf.reduce_sum(tf.pow((GS - GG), 2))
    
    return J_style_layer
```

##### 风格权值

综合考虑每个隐藏层的风格会令实验效果更好，因此对每个隐藏层的风格代价一个权值，进行加权平均：

``` python
STYLE_LAYERS = [
    ('conv1_1', 0.2),
    ('conv2_1', 0.2),
    ('conv3_1', 0.2),
    ('conv4_1', 0.2),
    ('conv5_1', 0.2)]
```

整体的风格代价函数为：
$$
J_{style}(S,G) = \sum_{l} \lambda^{[l]} J^{[l]}_{style}(S,G)
$$
其中 $\lambda^{[l]}$ 就是给定的 `STYLE_LAYERS[l]`。代码实现如下：

``` python
def compute_style_cost(model, STYLE_LAYERS):
    # initialize the overall style cost
    J_style = 0

    for layer_name, coeff in STYLE_LAYERS:

        # Select the output tensor of the currently selected layer
        out = model[layer_name]

        # Set a_S to be the hidden layer activation from the layer we have selected, by running the session on out
        a_S = sess.run(out)

        # Set a_G to be the hidden layer activation from same layer. Here, a_G references model[layer_name] and isn't evaluated yet. Later in the code, we'll assign the image G as the model input, so that when we run the session, this will be the activations drawn from the appropriate layer, with G as input.
        a_G = out
        
        # Compute style_cost for the current layer
        J_style_layer = compute_layer_style_cost(a_S, a_G)

        # Add coeff * J_style_layer of this layer to overall style cost
        J_style += coeff * J_style_layer

    return J_style
```

在循环中 `a_S` 和 `a_G` 都是选择同一隐藏层的激活值，但是前者使用了 `sess.run` 而后者没有。因此后续需要将生成的图像 G 作为输入，然后运行对话才可以得到具体 `a_G`  的值。

### 解决优化问题

最后需要结合上述代码，实现风格迁移。实验分为以下几个步骤：

1. 创建交互式会话

   ``` python
   # Reset the graph
   tf.reset_default_graph()
   # Start interactive session
   sess = tf.InteractiveSession()
   ```

2. 载入 VGG19 模型、内容图像和风格图像

   ``` python
   model = load_vgg_model("pretrained-model/imagenet-vgg-verydeep-19.mat")
   
   content_image = scipy.misc.imread("images/louvre_small.jpg")
   content_image = reshape_and_normalize_image(content_image)
   style_image = scipy.misc.imread("images/monet.jpg")
   style_image = reshape_and_normalize_image(style_image)
   ```

3. 随机初始化生成图像（通过对内容图像添加大量噪声而不是完全随机，可以让生成的图像内容快速匹配）

   ``` python
   generated_image = generate_noise_image(content_image)
   imshow(generated_image[0])
   ```

   ![](https://s1.ax2x.com/2019/01/16/5dg6Pe.png)

4. 构建 Tensorflow 图模型

   * 通过 VGG19 模型运行内容图像，计算内容代价

     ``` python
     # Assign the content image to be the input of the VGG model.  
     sess.run(model['input'].assign(content_image))
     
     # Select the output tensor of layer conv4_2
     out = model['conv4_2']
     
     # Set a_C to be the hidden layer activation from the layer we have selected
     a_C = sess.run(out)
     
     # Set a_G to be the hidden layer activation from same layer. Here, a_G references model['conv4_2'] and isn't evaluated yet. Later in the code, we'll assign the image G as the model input, so that when we run the session, this will be the activations drawn from the appropriate layer, with G as input.
     a_G = out
     
     # Compute the content cost
     J_content = compute_content_cost(a_C, a_G)
     ```

   * 通过 VGG19 模型运行风格图像，计算风格代价

     ```python
     # Assign the input of the model to be the "style" image 
     sess.run(model['input'].assign(style_image))
     
     # Compute the style cost
     J_style = compute_style_cost(model, STYLE_LAYERS)
     ```

   * 计算整体代价、定义优化器和学习率

     ``` python
     J = total_cost(J_content, J_style, alpha = 10, beta = 40)
     optimizer = tf.train.AdamOptimizer(2.0)
     train_step = optimizer.minimize(J)
     ```

5. 初始化图模型，迭代输入**生成的图像**，更新生成的图像

   ``` python
   def model_nn(sess, input_image, num_iterations = 200):
       # Initialize global variables (you need to run the session on the initializer)
       sess.run(tf.global_variables_initializer())
       
       # Run the noisy input image (initial generated image) through the model. Use assign().
       sess.run(model['input'].assign(input_image))
       
       for i in range(num_iterations):
           # Run the session on the train_step to minimize the total cost
           sess.run(train_step)
           
           # Compute the generated image by running the session on the current model['input']
           generated_image = sess.run(model['input'])
   
           # Print every 20 iteration.
           if i%20 == 0:
               Jt, Jc, Js = sess.run([J, J_content, J_style])
               print("Iteration " + str(i) + " :")
               print("total cost = " + str(Jt))
               print("content cost = " + str(Jc))
               print("style cost = " + str(Js))
               
               # save current generated image in the "/output" directory
               save_image("output/" + str(i) + ".png", generated_image)
       
       # save last generated image
       save_image('output/generated_image.jpg', generated_image)
       
       return generated_image
   ```

运行模型 `model_nn(sess, generated_image)` 后即可得到保存在输出文件夹中的生成图像，实验为了节省时间直接设定好了所有超参数，例如风格权值 `STYLE_LAYERS`、迭代的次数和 $(\alpha, \beta)$。

## 总结

深度学习具有各种各样的模型，这次实验是首次对图像的像素值进行更新优化而不是权值，由于不需要手动实现反向传播所以不算很难，但是还需要多了解 Tensorflow 的文档。收获比较大的就是将直观感觉用数学语言描述出来，即如何表示一张图像的内容和风格！然后才能设计合适的代价函数，让模型学习出我们想要的内容。

## 参考文献

1. 吴恩达. DeepLearning. 
2. Matthew D Zeiler, Rob Fergus, (2013). Visualizing and Understanding Convolutional Networks(https://arxiv.org/abs/1311.2901)
3. Leon A. Gatys, Alexander S. Ecker, Matthias Bethge, (2015). A Neural Algorithm of Artistic Style (<https://arxiv.org/abs/1508.06576>)