---
title: 用 LSTM 网络创作爵士独奏
date: 2018-08-28 11:16:15
updated: 2018-08-28 14:22:43
tags: Deep Learning
mathjax: true
typora-root-url: ./jazz-with-an-lstm-network
---

## 前言

终于把论文投出去了，虽然中的概率很渺茫，但是我肖的态度确实好了不少。终于又可以闲下来好好学学深度学习了，论文的实验过程中用了 LSTM Autoencoder，正好趁着这个机会再强化一下。在上篇学习笔记中，由于恐龙名字不会很长，所以在生成恐龙名字的作业中使用 RNN 已经可以满足任务要求。本次作业是创作爵士独奏，普通 RNN 无法解决长期依赖问题，所以使用了 LSTM。

<!-- more -->

## 数据集

数据集是一首长达约8分钟的爵士音乐，下面是其中的一个小片段：

<center><audio controls controlsList="nodownload"><source src="https://randy-1251769892.cos.ap-beijing.myqcloud.com/30s_seq.mp3" type="audio/mpeg">Your browser does not support the audio element.</audio></center>

在这次实验中不用考虑和弦，只需要在数据集上训练出一个 RNN 模型，然后用来生成新的序列。首先加载数据 `data/original_metheny.mid`，然后将它处理成以下形状，每三十个值作为一个序列：

``` python
X, Y, n_values, indices_values = load_music_utils()
```

* 训练样本的个数 $m$: 60
* 序列的长度 $T_x$: 30
* 不同的值的总数(独热向量的维度): 78

* X 的形状: $(m, T_x, 78)$
* Y 的形状: $(T_x, m, 78)$

Y 实质上和 X 相同，只不过是偏移了一步。在训练过程中，给定序列 $x^{\langle 1\rangle}, \ldots, x^{\langle t \rangle}$，模型则预测 $y^{\langle t \rangle}$。在 RNN 中，数据的形状分为两种：time major `[max_time, batch_size, depth]` 和 batch major `[batch_size, max_time, depth]`。使用 `time_major=True` 效率更高，能够避免一些转置的操作，因此 Y 的形状是 time major。

## 模型

模型的结构如下图所示：

![](https://s1.ax2x.com/2018/08/29/5BzDah.png)

每次从 `original_metheny.mid` 中随机选取 30 个值训练模型。与生成恐龙名字的模型类似，$x^{\langle 1 \rangle} = \vec{0}$ 作为输入的开始。

### 构建模型

本次实验使用隐藏状态是 64 维的 LSTM，对于序列生成模型，在实验之前输入序列未知，每个时间步的输出生成下一个时间步的输入 $x^{\langle t \rangle}=y^{\langle t-1 \rangle}$，因此需要使用 for 循环调用 LSTM 层 $T_x$ 次，且 LSTM 细胞共享参数。

* 定义层对象

``` python
reshapor = Reshape((1, 78))
LSTM_cell = LSTM(n_a, return_state = True)
densor = Dense(n_values, activation='softmax')
```

* 实现 `djmodel()`
  1. 创建空列表用于存储每个时间步的输出
  2. 循环 $T_x$ 个时间步
     1. 使用 Keras的 Lambda 层：`x = Lambda(lambda x: X[:,t,:])(X)`
     2. Reshape x 的形状成 $(1, 78)$
     3. 将 x 输入到一个 LSTM_cell 中：`a, _, c = LSTM_cell(input_x, initial_state=[previous hidden state, previous cell state])`
     4. 输出经过激活函数和全连接层后，保存到输出列表中

``` python
def djmodel(Tx, n_a, n_values):
    # Define the input of your model with a shape 
    X = Input(shape=(Tx, n_values))
    
    # Define s0, initial hidden state for the decoder LSTM
    a0 = Input(shape=(n_a,), name='a0')
    c0 = Input(shape=(n_a,), name='c0')
    a = a0
    c = c0
    
    # Step 1: Create empty list to append the outputs while you iterate (≈1 line)
    outputs = []
    # Step 2: Loop
    for t in range(Tx):
        # Step 2.A: select the "t"th time step vector from X. 
        x =  Lambda(lambda x: X[:, t, :])(X)
        # Step 2.B: Use reshapor to reshape x to be (1, n_values) (≈1 line)
        x = reshapor(x)
        # Step 2.C: Perform one step of the LSTM_cell
        a, _, c = LSTM_cell(x, initial_state=[a, c])
        # Step 2.D: Apply densor to the hidden state output of LSTM_Cell
        out = densor(a)
        # Step 2.E: add the output to "outputs"
        outputs.append(out)
    # Step 3: Create model instance
    model = Model(inputs=[X, a0, c0], outputs=outputs)
    
    return model
```

接下来使用 Adam 优化和一个分类的交叉熵损失训练模型 100 个 epochs：

``` python
model = djmodel(Tx = 30 , n_a = 64, n_values = 78)
opt = Adam(lr=0.01, beta_1=0.9, beta_2=0.999, decay=0.01)
model.compile(optimizer=opt, loss='categorical_crossentropy', metrics=['accuracy'])

m = 60
a0 = np.zeros((m, n_a))
c0 = np.zeros((m, n_a))
model.fit([X, a0, c0], list(Y), epochs=100)
```

### 生成

![](https://s1.ax2x.com/2018/08/29/5BzTJu.png)

在采样的每个时间步中，输出被用于生成音乐和作为下一个时间步的输入。实验步骤如下：

1. 使用 LSTM_Cell，输入时上一个时间步的输出 `y` 和隐藏状态 `a`
2. 对当前时间步的隐藏状态 `a` 使用 `softmax` 函数，将输入加入输出列表中
3. 对输出使用 `x = Lambda(one_hot)(out)` 转化成独热向量，输入下一个时间步

``` python
def music_inference_model(LSTM_cell, densor, n_values = 78, n_a = 64, Ty = 100):
    # Define the input of your model with a shape 
    x0 = Input(shape=(1, n_values))
    
    # Define s0, initial hidden state for the decoder LSTM
    a0 = Input(shape=(n_a,), name='a0')
    c0 = Input(shape=(n_a,), name='c0')
    a = a0
    c = c0
    x = x0

    # Step 1: Create an empty list of "outputs" to later store your predicted values (≈1 line)
    outputs = []
    # Step 2: Loop over Ty and generate a value at every time step
    for t in range(Ty):
        # Step 2.A: Perform one step of LSTM_cell (≈1 line)
        a, _, c = LSTM_cell(x, initial_state=[a, c])
        # Step 2.B: Apply Dense layer to the hidden state output of the LSTM_cell (≈1 line)
        out = densor(a)
        # Step 2.C: Append the prediction "out" to "outputs". out.shape = (None, 78) (≈1 line)
        outputs.append(out)
        # Step 2.D: Select the next value according to "out", and set "x" to be the one-hot representation of the
        #           selected value, which will be passed as the input to LSTM_cell on the next step. We have provided 
        #           the line of code you need to do this. 
        x = Lambda(one_hot)(out)
    # Step 3: Create model instance with the correct "inputs" and "outputs" (≈1 line)
    inference_model = Model(inputs=[x0, a0, c0], outputs=outputs)

    return inference_model
```

定义推断模型和初始化参数：

``` python
inference_model = music_inference_model(LSTM_cell, densor, n_values = 78, n_a = 64, Ty = 50)
x_initializer = np.zeros((1, 1, 78))
a_initializer = np.zeros((1, n_a))
c_initializer = np.zeros((1, n_a))
```

预测输出：

``` python
def predict_and_sample(inference_model, x_initializer = x_initializer, a_initializer = a_initializer, c_initializer = c_initializer):
    # Step 1: Use your inference model to predict an output sequence given x_initializer, a_initializer and c_initializer.
    pred = inference_model.predict([x_initializer, a_initializer, c_initializer])
    # Step 2: Convert "pred" into an np.array() of indices with the maximum probabilities
    indices = np.argmax(pred, axis = -1)
    # Step 3: Convert indices to one-hot vectors, the shape of the results should be (1, )
    results = to_categorical(indices, num_classes=78)
    
    return results, indices

results, indices = predict_and_sample(inference_model, x_initializer, a_initializer, c_initializer)
```

生成音乐：

``` python
out_stream = generate_music(inference_model)
```

<center><audio controls controlsList="nodownload"><source src="https://randy-1251769892.cos.ap-beijing.myqcloud.com/30s_trained_model.mp3" type="audio/mpeg">Your browser does not support the audio element.</audio></center>

## 总结

这篇博客写的有点简单，因为 Coursera 的资料也比较全面了，而且和恐龙名字生成模型也很类似。如果我再去仔细分析它各个工具的实现感觉进度有点慢，所以只是简单地实现了作业内容，再加上自己对整个作业的理解。

## 参考文献

1. 吴恩达. DeepLearning. 