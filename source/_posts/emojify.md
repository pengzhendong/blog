---
title: Emojify 文本情感分析
date: 2018-08-31 10:18:33
updated: 2018-08-31 12:18:57
tags: Deep Learning
mathjax: true
typora-root-url: ./emojify
---

## 前言

写论文做实验的时候曾经想过用文本分类的模型，无奈样本太不均衡，所以最后用了自编码器提取特征。在 Coursera 的作业中，该实验分为两个小实验，一个是普通的文本分类，一个是使用 LSTM RNN 进行文本分类。

<!-- more -->

## Baseline 模型: Emojifier-V1

训练集 X 中包含 127 个句子，其标签为 0 到 4 分别对应一个 emoji 表情，如下图所示：

![](https://s1.ax2x.com/2018/08/31/5BvpY3.png)

现在载入数据集，并且测试一下：

``` python
X_train, Y_train = read_csv('data/train_emoji.csv')
X_test, Y_test = read_csv('data/tesss.csv')
maxLen = len(max(X_train, key=len).split())

index = 1
print(X_train[index], label_to_emoji(Y_train[index]))
```

```
I am proud of your achievements 😄
```

### Emojifier-V1 概况

Emojifier-V1 的概况如下图所示：

![](https://s1.ax2x.com/2018/08/31/5BydTN.png)

该模型比较简单，首先去训练好的 Embedding 中找到每个单词的嵌入，然后对句子中所有单词的嵌入求平均，将其作为输入，输入到一个多分类的全连接网络中，最后预测句子的情感。

### 实现 Emojifier-V1

此处不再细述多分类的过程，模型的主要内容如下所示：
$$
z^{(i)} = W \times avg^{(i)} + b
$$

$$
a^{(i)} = softmax(z^{(i)})
$$

$$
\mathcal{L}^{(i)} = - \sum_{k = 0}^{n_y - 1} Yoh^{(i)}_k * log(a^{(i)}_k)
$$

其中 $Yoh$ (Y one hot) 是输出的独热编码。最后模型在训练集和测试集上的准确率能够达到 97% 和 86% ，同时对于一些在训练集中没有出现过的单词 (例如: adore) 也能得到不错的结果：

``` python
X_my_sentences = np.array(["i adore you", "i love you", "funny lol", "lets play with a ball", "food is ready", "you are not happy"])
Y_my_labels = np.array([[0], [0], [2], [1], [4],[3]])

pred = predict(X_my_sentences, Y_my_labels , W, b, word_to_vec_map)
print_predictions(X_my_sentences, pred)
```

```
Accuracy: 0.8333333333333334

i adore you ❤️
i love you ❤️
funny lol 😄
lets play with a ball ⚾
food is ready 🍴
you are not happy ❤️
```

但是该模型并不能分析 not happy 是表示不开心，而只是简单地学习了 happy 这个单词。输出模型的混淆矩阵看一下模型的表现：

```python
print(Y_test.shape)
print('           '+ label_to_emoji(0)+ '    ' + label_to_emoji(1) + '    ' +  label_to_emoji(2)+ '    ' + label_to_emoji(3)+'   ' + label_to_emoji(4))
print(pd.crosstab(Y_test, pred_test.reshape(56,), rownames=['Actual'], colnames=['Predicted'], margins=True))
plot_confusion_matrix(Y_test, pred_test)
```

```
(56,)
           ❤️   ⚾   😄   😞  🍴
Predicted  0.0  1.0  2.0  3.0  4.0  All
Actual                                 
0            6    0    0    1    0    7
1            0    8    0    0    0    8
2            2    0   16    0    0   18
3            1    1    2   12    0   16
4            0    0    1    0    6    7
All          9    9   19   13    6   56
```

![](https://s1.ax2x.com/2018/08/31/5Byc9X.png)

矩阵对角线上的颜色比较深，表示模型的表现还不错。但是模型却无法分析 not xxx 这类的短语，因为嵌入矩阵中没有对应的表示，而且单纯地对所有单词的嵌入求平均会丢失输入的单词的顺序，因此需要更好的算法。

## Emojifier-V2: 在 Keras 中使用 LSTMs

Emojifier-V2 的概况如下图所示：

![](https://s1.ax2x.com/2018/08/31/5ByeQ6.png)

这是一个两层的 LSTM 序列分类器。这次实验使用 mini-batches 来训练 Keras，因此一个 batch 中的序列的长度应该相同，因此需要补 0。例如一个 batch 中的序列的最大长度为 5，那么 "I love you" 这个句子的表示为 $(e_{i}, e_{love}, e_{you}, \vec{0}, \vec{0})$。

### Embedding 层

在 Keras 中，嵌入矩阵被表示成一个层，然后将词的索引匹配成嵌入向量。嵌入矩阵可以被训练出来，也可以用一个训练好的矩阵来初始化它。`Embedding()` 层如下图所示：

![](https://s1.ax2x.com/2018/08/31/5ByAXK.png)

输出是一个 (batch size, max input length, dimension of word vectors) 的矩阵。word_to_index 的实现如下所示：

``` python
def sentences_to_indices(X, word_to_index, max_len):
    m = X.shape[0]                                   # number of training examples
    
    # Initialize X_indices as a numpy matrix of zeros and the correct shape
    X_indices = np.zeros((m, max_len))
    
    for i in range(m):                               # loop over training examples
        
        # Convert the ith training sentence in lower case and split is into words. You should get a list of words.
        sentence_words = X[i].lower().split()
        
        # Initialize j to 0
        j = 0
        
        # Loop over the words of sentence_words
        for w in sentence_words:
            
            # Set the (i,j)th entry of X_indices to the index of the correct word.
            X_indices[i, j] = word_to_index[w]
            # Increment j to j + 1
            j += 1
            
    return X_indices
```

接下来需要实现预训练的 Embedding 层，将训练好的嵌入矩阵设置到 `Embedding()` 层的权值中：

``` python
def pretrained_embedding_layer(word_to_vec_map, word_to_index):
    vocab_len = len(word_to_index) + 1                  # adding 1 to fit Keras embedding (requirement)
    emb_dim = word_to_vec_map["cucumber"].shape[0]      # define dimensionality of your GloVe word vectors (= 50)
    
    # Initialize the embedding matrix as a numpy array of zeros of shape (vocab_len, dimensions of word vectors = emb_dim)
    emb_matrix = np.zeros((vocab_len, emb_dim))
    
    # Set each row "index" of the embedding matrix to be the word vector representation of the "index"th word of the vocabulary
    for word, index in word_to_index.items():
        emb_matrix[index, :] = word_to_vec_map[word]

    # Define Keras embedding layer with the correct output/input sizes, make it trainable.
    # Use Embedding(...). Make sure to set trainable=False.
    embedding_layer = Embedding(vocab_len, emb_dim, trainable = False)

    # Build the embedding layer, it is required before setting the weights of the embedding layer. Do not modify the "None".
    embedding_layer.build((None,))
    
    # Set the weights of the embedding layer to the embedding matrix. Your layer is now pretrained.
    embedding_layer.set_weights([emb_matrix])
    
    return embedding_layer
```

### 构建模型

接下来需要构建模型，模型分为：

* 输入层: `Input((max_len, m), dtype='int32')`
* LSTM 层: `LSTM(hidden_units, return_sequence)(embeddings)`
* Dropout 层: `Dropout(keep_prob)(X)`
* 全连接层: `Dense(output_dimension)(X)`
* 激活层: `Activation(activation_func)(X)`

``` python
def Emojify_V2(input_shape, word_to_vec_map, word_to_index):
    # Define sentence_indices as the input of the graph, it should be of shape input_shape and dtype 'int32' (as it contains indices).
    sentence_indices = Input(input_shape, dtype='int32')
    
    # Create the embedding layer pretrained with GloVe Vectors (≈1 line)
    embedding_layer = pretrained_embedding_layer(word_to_vec_map, word_to_index)
    
    # Propagate sentence_indices through your embedding layer, you get back the embeddings
    embeddings = embedding_layer(sentence_indices)   
    
    # Propagate the embeddings through an LSTM layer with 128-dimensional hidden state
    # Be careful, the returned output should be a batch of sequences.
    X = LSTM(128, return_sequences=True)(embeddings)
    # Add dropout with a probability of 0.5
    X = Dropout(0.5)(X)
    # Propagate X trough another LSTM layer with 128-dimensional hidden state
    # Be careful, the returned output should be a single hidden state, not a batch of sequences.
    X = LSTM(128, return_sequences=False)(X)
    # Add dropout with a probability of 0.5
    X = Dropout(0.5)(X)
    # Propagate X through a Dense layer with softmax activation to get back a batch of 5-dimensional vectors.
    X = Dense(5)(X)
    # Add a softmax activation
    X = Activation('softmax')(X)
    
    # Create Model instance which converts sentence_indices into X.
    model = Model(inputs=sentence_indices, outputs=X)
    
    return model
```

构建好模型后可以通过模型的 `summary()` 方法来检查模型的概要 (max_len = 10)：

``` python
model = Emojify_V2((maxLen,), word_to_vec_map, word_to_index)
model.summary()
```

``` 
_________________________________________________________________
Layer (type)                 Output Shape              Param #   
=================================================================
input_1 (InputLayer)         (None, 10)                0         
_________________________________________________________________
embedding_2 (Embedding)      (None, 10, 50)            20000050  
_________________________________________________________________
lstm_1 (LSTM)                (None, 10, 128)           91648     
_________________________________________________________________
dropout_1 (Dropout)          (None, 10, 128)           0         
_________________________________________________________________
lstm_2 (LSTM)                (None, 128)               131584    
_________________________________________________________________
dropout_2 (Dropout)          (None, 128)               0         
_________________________________________________________________
dense_1 (Dense)              (None, 5)                 645       
_________________________________________________________________
activation_1 (Activation)    (None, 5)                 0         
=================================================================
Total params: 20,223,927
Trainable params: 223,877
Non-trainable params: 20,000,050
_________________________________________________________________
```

由于嵌入矩阵是训练好的 `trainable = False`，因此有 400,001 * 50 = 20,000,050 个参数是 Non-trainable 参数。接下来需要编译模型，定义损失函数、优化器和评估指标，最后拟合模型：

``` python
model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=['accuracy'])

X_train_indices = sentences_to_indices(X_train, word_to_index, maxLen)
Y_train_oh = convert_to_one_hot(Y_train, C = 5)
model.fit(X_train_indices, Y_train_oh, epochs = 50, batch_size = 32, shuffle=True)
```

训练集和测试集上的准确率能接近 100% 和 91%。对于 not happy 也能准确预测：

``` python
x_test = np.array(['you are not happy'])
X_test_indices = sentences_to_indices(x_test, word_to_index, maxLen)
print(x_test[0] +' '+  label_to_emoji(np.argmax(model.predict(X_test_indices))))
```

```
you are not happy 😞
```

因为 LSTM 网络具有长短期记忆，所以能够很好地预测某些单词的组合。

## 总结

在 NLP 任务中，如果训练集比较小，比较适合直接用训练好的嵌入矩阵而不是自己训练一个。在 RNN 中，如果想用 mini-batches 提高效率(矩阵的运算比循环快)，那么就需要对样本进行补 0。`LSTM()` 的 `return_sequence` 参数决定返回所有的隐藏状态还是只返回最后一个时间步的隐藏状态。

## 参考文献

1. 吴恩达. DeepLearning. 