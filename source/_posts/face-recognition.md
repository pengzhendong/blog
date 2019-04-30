---
title: 人脸识别
date: 2019-01-12 15:53:03
updated: 2019-01-12 18:26:20
tags: Deep Learning
mathjax: true
---

## 前言

人脸识别这部分内容的实验 idea 主要来自于 FaceNet，其中还有部分来自 DeepFace。网络结构没有什么特殊的地方，主要是其损失函数的构造。

<!-- more -->

## 人脸识别

人脸识别问题通常分为两类：

* 人脸验证：例如苹果的 Face ID 技术，判断当前人脸是否为机主，这就是 1:1 匹配问题。
* 人脸识别：例如有些公司的门禁，判断当前人脸是否为公司员工，这就是 1:K 匹配问题。

FaceNet [2] 神经网络可以将一张人脸图像编码成一个 128 维的向量，然后通过比较两个向量来判断是否属于同一个人。实验内容主要分为三部分：

1. 实现三重损失函数
2. 使用预训练的模型将人脸图像编码成 128 维向量
3. 使用上述编码来进行人脸验证和人脸识别

首先需要引入各种 package 和导入数据集，虽然在深度学习领域没有统一的标准，但是为了方便，这里使用的图像数据集是 "channels first" 的，即维度为 $(m, n_C, n_H, n_W)$。

### 人脸验证

人脸验证问题就是给定两张人脸图像，判断他们是否是同一个人。最简单的方法就是计算每个像素的差异，然后给定一个阈值，差异超过这个阈值就不是同一个人，但是如果同一个人在不同亮度下或者不同角度下照片的差异通常很大。因此需要对图像进行编码后分析而不是简单对像素进行分析，即使用神经网络提取图像特征进行对比。

### 编码人脸

实验使用 FaceNet 提取人脸特征，这个 ConvNet 网络的架构是 Inception 模型，模型细节可以参考 [inception_blocks.py](https://github.com/pengzhendong/DeepLearning/blob/master/4.%20Convolutional%20Neural%20Networks/Week%204/Face%20Recognition/inception_blocks.py)。输入模型的图像尺寸为 $96\times 96$，即输入维度为 $(m, n_C, n_H, n_W) = (m, 3, 96, 96)$，输出为 $(m, 128)$。通过计算两个向量之间的距离，就可以判断对应的两张人脸图像是否属于同一个人，如下图所示：

![](https://s1.ax2x.com/2019/01/12/5dKbPJ.png)

如果编码足够好，即模型提取人脸的特征足够好，那么对于同一个人的不同照片，最后计算的距离应该很小；对于不同人脸，计算出的距离应该很大。FaceNet 在训练过程中使用的三重损失函数就可以保证这个模型提取的特征足够好。

#### 三重损失

三重损失的思想是最小化不同人脸的编码距离，最大化同一个人脸的编码距离。给定一张图像 $x$，定义其编码为 $f(x)$，函数 $f$ 即神经网络计算的功能。

![](https://s1.ax2x.com/2019/01/12/5dKuH6.png)

给定三元组图像 $(A, P, N)$，其中：

* A: Anchor 图像，即人脸图像
* P: Positive 图像，与 Anchor 图像为同一个人
* N: Negative 图像，与 Anchor 图像不是同一个人

对于训练集中的第 $i$ 个样本 $(A^{(i)}, P^{(i)}, N^{(i)})$，有：
$$
\mid \mid f(A^{(i)}) - f(P^{(i)}) \mid \mid_2^2 + \alpha < \mid \mid f(A^{(i)}) - f(N^{(i)}) \mid \mid_2^2
$$
其中参数 $\alpha$ 是为了避免对于所有的图像，模型都编码为 0，这里手动设置为 0.2。因此可以构造三重代价函数：
$$
\mathcal{J} = \sum^{N}_{i=1} max\large( \small \underbrace{\mid \mid f(A^{(i)}) - f(P^{(i)}) \mid \mid_2^2}_\text{(1)} - \underbrace{\mid \mid f(A^{(i)}) - f(N^{(i)}) \mid \mid_2^2}_\text{(2)} + \alpha, 0 \large )
$$
通常还会对编码进行归一化，即令 $\mid \mid f(img)\mid \mid_2=1$。实现上述代价函数分为四个步骤：

1. 计算 A 和 P 编码的距离：$\mid \mid f(A^{(i)}) - f(P^{(i)}) \mid \mid_2^2$
2. 计算 A 和 N 编码的距离：$\mid \mid f(A^{(i)}) - f(N^{(i)}) \mid \mid_2^2$
3. 对于每个三元组样本，计算损失函数：$\mid \mid f(A^{(i)}) - f(P^{(i)}) \mid - \mid \mid f(A^{(i)}) - f(N^{(i)}) \mid \mid_2^2 + \alpha$
4. 计算代价函数

``` python
def triplet_loss(y_true, y_pred, alpha = 0.2):
    anchor, positive, negative = y_pred[0], y_pred[1], y_pred[2]
    
    # Step 1: Compute the (encoding) distance between the anchor and the positive
    pos_dist = tf.reduce_sum(tf.square(tf.subtract(anchor, positive)))
    # Step 2: Compute the (encoding) distance between the anchor and the negative
    neg_dist = tf.reduce_sum(tf.square(tf.subtract(anchor, negative)))
    # Step 3: subtract the two previous distances and add alpha.
    basic_loss = tf.add(tf.subtract(pos_dist, neg_dist), alpha)
    # Step 4: Take the maximum of basic_loss and 0.0. Sum over the training examples.
    loss = tf.maximum(tf.reduce_mean(basic_loss), 0.0)
    
    return loss
```

## 载入预训练模型

训练 FaceNet 的过程就是最小化三重损失，由于 FaceNet 在训练的时候需要大量数据和时间，因此实验直接给了一个预训练的 ConvNet 模型：

``` python
FRmodel = faceRecoModel(input_shape=(3, 96, 96))
FRmodel.compile(optimizer = 'adam', loss = triplet_loss, metrics = ['accuracy'])
load_weights_from_FaceNet(FRmodel)
```

以下为模型在三个人的人脸图像上计算的编码距离，距离越小表示为同一个人的概率越大。

![](https://s1.ax2x.com/2019/01/12/5dKvMG.png)

## 模型应用

例如构建一个人脸验证系统，用户输入姓名，然后系统拍摄人脸，判断该用户是否是姓名对应那个人。与人脸识别不同的是，人脸识别系统不需要提供姓名，直接拍摄人脸，然后判断数据库中是否有该用户。

### 人脸验证

首先往数据库中存入数据集：

``` python
database = {}
database["danielle"] = img_to_encoding("images/danielle.png", FRmodel)
database["younes"] = img_to_encoding("images/younes.jpg", FRmodel)
database["tian"] = img_to_encoding("images/tian.jpg", FRmodel)
```

实现验证过程主要分为以下几个步骤：

1. 计算人脸图像的编码
2. 计算该编码与数据库中<font color='red'>**指定**</font>的编码的距离
3. 差异小于阈值 0.7 即判断为同一个人

``` python
def verify(image_path, identity, database, model):
    # Step 1: Compute the encoding for the image. Use img_to_encoding() see example above. (≈ 1 line)
    encoding = img_to_encoding(image_path, model)
    # Step 2: Compute distance with identity's image (≈ 1 line)
    dist = np.linalg.norm(encoding-database[identity])
    # Step 3: Return True if dist < 0.7 (≈ 3 lines)
    if dist < 0.7:
        print("It's " + str(identity) + ", welcome home!")
        return True
    else:
        print("It's not " + str(identity) + ", please go away")
        return False
```

### 人脸识别

人脸识别和人脸验证的区别就是人脸验证需要提供其他信息，然后只需要判断用户是否为信息指定的那个人；人脸识别不需要提供其他信息，但是需要和数据库中所有数据进行比较，判断是否属于其中任何一个人。实现识别过程主要分为以下几个步骤：

1. 计算人脸图像的编码（目标编码）

2. 找到数据库中与目标编码距离最小的编码
   * 初始化 `min_dist` 为一个比较大的值，用于存储最小的距离
   * 遍历数据库中所有编码
     * 计算编码与目标编码的距离
     * 如果距离小于 `min_dist`，记录新的距离和该编码对应的信息

``` python
def who_is_it(image_path, database, model):
    ## Step 1: Compute the target "encoding" for the image. Use img_to_encoding() see example above. ## (≈ 1 line)
    encoding = img_to_encoding(image_path, model)
    ## Step 2: Find the closest encoding ##
    # Initialize "min_dist" to a large value, say 100 (≈1 line)
    min_dist = 100
    # Loop over the database dictionary's names and encodings.
    for (name, db_enc) in database.items():
        # Compute L2 distance between the target "encoding" and the current "emb" from the database. (≈ 1 line)
        dist = np.linalg.norm(encoding-db_enc)
        # If this distance is less than the min_dist, then set min_dist to dist, and identity to name. (≈ 3 lines)
        if dist < min_dist:
            min_dist = dist
            identity = name
    
    if min_dist > 0.7:
        print("Not in the database.")
    else:
        print ("it's " + str(identity) + ", the distance is " + str(min_dist))
        
    return min_dist, identity
```

通过对数据集的扩增，例如提供同一个用户在不同光照下照片等等可以提高系统的准确率；通过对图像的处理，例如裁剪图像只保留人脸等等可以提高系统的鲁棒性。

## 总结

人脸验证是 1:1 匹配问题，只需要对比一张人脸图像；而人脸识别就比较难，1:K 匹配问题需要比较数据库中所有的人脸。最小化三重损失得到的网络可以有效提取人脸的特征。同样的编码既可以用来进行人脸验证，也可以用来进行人脸识别。

## 参考文献

1. 吴恩达. DeepLearning. 
2. Florian Schroff, Dmitry Kalenichenko, James Philbin (2015). [FaceNet: A Unified Embedding for Face Recognition and Clustering](https://arxiv.org/pdf/1503.03832.pdf)
3. Yaniv Taigman, Ming Yang, Marc'Aurelio Ranzato, Lior Wolf (2014). [DeepFace: Closing the gap to human-level performance in face verification](https://research.fb.com/wp-content/uploads/2016/11/deepface-closing-the-gap-to-human-level-performance-in-face-verification.pdf)