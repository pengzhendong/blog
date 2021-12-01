---
title: 字符级别的语言模型
date: 2018-06-27 09:10:57
updated: 2018-06-27 11:32:46
tags: Deep Learning
mathjax: true
typora-root-url: ./character-level-language-model
---

## 前言

在介绍 RNN 的文章中，重点是学习 RNN 的结构，前向传播和反向传播的大致流程，所以在实现代码中并不是很全面，甚至没有关于损失函数的定义，这个作业基于字符级别，实现了一个语言模型。

<!-- more -->

作业背景：根据已有的[恐龙的名字](https://nbviewer.jupyter.org/github/pengzhendong/DeepLearning/blob/master/5.%20Sequence%20Models/Week%201/Dinosaurus%20Island%20-%20Character%20level%20language%20model/dinos.txt)，生成一些相似风格的恐龙名字。

## 数据处理

首先需要读取所有名字，然后保存所有名字中出现过的不同字符：

``` python
data = open('dinos.txt', 'r').read()
data= data.lower()
chars = list(set(data))
data_size, vocab_size = len(data), len(chars)
print('There are %d total characters and %d unique characters in your data.' % (data_size, vocab_size))
```

```
There are 19909 total characters and 27 unique characters in your data.
```

字符有 a-z 和 "\n"，换行符的作用类似 `<EOS>` (End Of Sentence)，在这里是恐龙名字的结束符。然后需要创建字典来保存这些字符，在 Softmax 输出的概率分布中，就能知道哪个索引对应哪个字符，也能将名字中的每个字符转化成向量：

``` python
char_to_ix = { ch:i for i,ch in enumerate(sorted(chars)) }
ix_to_char = { i:ch for i,ch in enumerate(sorted(chars)) }
print(ix_to_char)
```

```
{0: '\n', 1: 'a', 2: 'b', 3: 'c', 4: 'd', 5: 'e', 6: 'f', 7: 'g', 8: 'h', 9: 'i', 10: 'j', 11: 'k', 12: 'l', 13: 'm', 14: 'n', 15: 'o', 16: 'p', 17: 'q', 18: 'r', 19: 's', 20: 't', 21: 'u', 22: 'v', 23: 'w', 24: 'x', 25: 'y', 26: 'z'}
```

## 模型

模型的结构如下所示：

* 初始化参数
* 运行优化循环
  * 前向传播计算损失函数
  * 反向传播计算关于损失函数的梯度
  * 梯度裁剪避免梯度爆炸
  * 使用梯度下降更新规则更新参数
* 返回学习好的参数

![](rnn.png)

在每一个时间步给定前一个字符，RNN 就会预测出下一个字符，所以对于每一个时间步有 $y^{\langle t \rangle} = x^{\langle t+1 \rangle}$。

### 初始化参数

初始化三个权值参数 $W_{ax}, W_{aa}, W_{ya}$ 和两个偏置参数 $b_a, b_y$：

``` python
def initialize_parameters(n_a, n_x, n_y):
    np.random.seed(1)
    Wax = np.random.randn(n_a, n_x)*0.01 # input to hidden
    Waa = np.random.randn(n_a, n_a)*0.01 # hidden to hidden
    Wya = np.random.randn(n_y, n_a)*0.01 # hidden to output
    ba = np.zeros((n_a, 1)) # hidden bias
    by = np.zeros((n_y, 1)) # output bias
    
    parameters = {"Wax": Wax, "Waa": Waa, "Wya": Wya, "ba": ba,"by": by}
    
    return parameters
```

### 前向传播

$$
a^{\langle t\rangle}=tanh(W_{ax}x^{\langle t\rangle}+W_{aa}^{\langle t-1\rangle}+b_a)
$$

$$
\hat y^{\langle t\rangle}=softmax(W_{ya}a^{\langle t\rangle}+b_y)
$$

前向传播的代码和[循环神经网络](2018/06/20/Recurrent-neural-network)稍有区别，输入 `rnn_step_foward` 中的参数不需要缓存返回。输入一个字符，通过 RNN 细胞得到下一个字符的概率分布，RNN 细胞的代码如下所示：

``` python
def rnn_step_forward(parameters, a_prev, x):
    Waa, Wax, Wya, by, ba = parameters['Waa'], parameters['Wax'], parameters['Wya'], parameters['by'], parameters['ba']
    a_next = np.tanh(np.dot(Wax, x) + np.dot(Waa, a_prev) + ba) # hidden state
    yt_pred = softmax(np.dot(Wya, a_next) + by) # unnormalized log probabilities for next chars # probabilities for next chars 
    
    return a_next, yt_pred
```

在完整的 RNN 前向传播中，需要定义一个字典 `a` 来存储每个时间步 $\langle t\rangle$ 与其对应的隐藏状态 $a^{\langle t\rangle}$；输入一个序列：0 +  `X` (一个恐龙的名字)，然后遍历序列的每个字符 `X[t]`，将其转化成一个 27 维的 ont-hot 向量 `x[t]`；计算每个时间步的损失函数 $loss=-log\hat y^{\langle t\rangle}_{y^{\langle t\rangle}}$ ($\hat y^{\langle t\rangle}$ 为 Softmax 函数输出的概率分布，$y^{\langle t\rangle}$ 为真实的下一个字符，即 $x^{\langle t+1\rangle}$，损失函数可参考 Softmax 回归的损失函数)：

``` python
def rnn_forward(X, Y, a0, parameters, vocab_size = 27):
    # Initialize x, a and y_hat as empty dictionaries
    x, a, y_hat = {}, {}, {}
    a[-1] = np.copy(a0)
    
    # initialize your loss to 0
    loss = 0
    
    for t in range(len(X)):
        # Set x[t] to be the one-hot vector representation of the t'th character in X.
        # if X[t] == None, we just have x[t]=0. This is used to set the input for the first timestep to the zero vector. 
        x[t] = np.zeros((vocab_size,1)) 
        if (X[t] != None):
            x[t][X[t]] = 1
        
        # Run one step forward of the RNN
        a[t], y_hat[t] = rnn_step_forward(parameters, a[t-1], x[t])
        
        # Update the loss by substracting the cross-entropy term of this time-step from it.
        loss -= np.log(y_hat[t][Y[t],0])
        
    cache = (y_hat, a, x)
        
    return loss, cache
```

### 反向传播

$$
dW_{ya}=\sum_{t=1}^{T_x}dy^{\langle t\rangle}*a^T
$$

$$
db_y=\sum_{t=1}^{T_x}dy^{\langle t\rangle}
$$

$$
da=W_{ya}^Tdy+W_{aa}^Tda^{\langle t+1\rangle}diag(1-a^{\langle t+1\rangle2})
$$

$$
db_a=\sum_{t=1}^{T_x}diag(1-a^{\langle t\rangle2})a^{\langle t\rangle}
$$

$$
dW_{ax}=\sum_{t=1}^{T_x}diag(1-a^{\langle t\rangle2})a^{\langle t\rangle}x^{\langle t\rangle T}
$$

在反向传播中需要实现以上公式，在反向传播中需要注意代码的顺序，代码实现如下所示：
``` python
def rnn_step_backward(dy, gradients, parameters, x, a, a_prev):
    gradients['dWya'] += np.dot(dy, a.T)
    gradients['dby'] += dy
    da = np.dot(parameters['Wya'].T, dy) + gradients['da_next'] # backprop into h
    daraw = (1 - a * a) * da # backprop through tanh nonlinearity
    gradients['dba'] += daraw
    gradients['dWax'] += np.dot(daraw, x.T)
    gradients['dWaa'] += np.dot(daraw, a_prev.T)
    gradients['da_next'] = np.dot(parameters['Waa'].T, daraw)
    return gradients
```

在完整的 RNN 反向传播中，需要定义参数的梯度且形状应该和该参数一样，例如 `gradients['dWax'] = np.zeros_like(Wax)`；遍历所有时间步，计算当前时间步的损失函数对输出的梯度 $dy^{\langle t\rangle}[\hat y^{\langle t\rangle }]-=1$ (可参考  Softmax 回归损失函数关于输出的梯度)：

``` python
def rnn_backward(X, Y, parameters, cache):
    # Initialize gradients as an empty dictionary
    gradients = {}
    
    # Retrieve from cache and parameters
    (y_hat, a, x) = cache
    Waa, Wax, Wya, by, ba = parameters['Waa'], parameters['Wax'], parameters['Wya'], parameters['by'], parameters['ba']
    
    # each one should be initialized to zeros of the same dimension as its corresponding parameter
    gradients['dWax'], gradients['dWaa'], gradients['dWya'] = np.zeros_like(Wax), np.zeros_like(Waa), np.zeros_like(Wya)
    gradients['dba'], gradients['dby'] = np.zeros_like(ba), np.zeros_like(by)
    gradients['da_next'] = np.zeros_like(a[0])
    
    # Backpropagate through time
    for t in reversed(range(len(X))):
        dy = np.copy(y_hat[t])
        dy[Y[t]] -= 1
        gradients = rnn_step_backward(dy, gradients, parameters, x[t], a[t], a[t-1])
    
    return gradients, a
```

### 梯度裁剪

在反向传播中，我们需要对参数求梯度，然后根据参数梯度更新参数。在更新参数之前，需要对参数梯度进行裁剪，保证梯度不会爆炸，即梯度的取值不会太大。

![](clip.png)

梯度裁剪的实现有许多不同方法，例如对梯度的 L2 范数进行裁剪和对梯度值进行裁剪，这里实现的是对梯度值进行裁剪，确保梯度在 $[-maxValue, maxValue]$ 中：

```python
def clip(gradients, maxValue):
    dWaa, dWax, dWya, dba, dby = gradients['dWaa'], gradients['dWax'], gradients['dWya'], gradients['dba'], gradients['dby']
   
    # clip to mitigate exploding gradients, loop over [dWax, dWaa, dWya, dba, dby].
    for gradient in [dWax, dWaa, dWya, dba, dby]:
        np.clip(gradient, a_min=-maxValue, a_max=maxValue, out=gradient)
    
    gradients = {"dWaa": dWaa, "dWax": dWax, "dWya": dWya, "dba": dba, "dby": dby}
    
    return gradients
```

### 更新参数

更新参数部分的代码比较简单，就是减去学习率 (**l**earning **r**ate) 乘以梯度：

``` python
def update_parameters(parameters, gradients, lr):
    parameters['Wax'] += -lr * gradients['dWax']
    parameters['Waa'] += -lr * gradients['dWaa']
    parameters['Wya'] += -lr * gradients['dWya']
    parameters['ba']  += -lr * gradients['dba']
    parameters['by']  += -lr * gradients['dby']
    return parameters
```

### 构建语言模型

将上面步骤结合在一起，实现模型，最后需要返回最后一个时间步的隐藏状态，用做**下一个序列**的第 0 个时间步的隐藏状态：

``` python
def optimize(X, Y, a_prev, parameters, learning_rate = 0.01):
    # Forward propagate through time
    loss, cache = rnn_forward(X, Y, a_prev, parameters)

    # Backpropagate through time (≈1 line)
    gradients, a = rnn_backward(X, Y, parameters, cache)

    # Clip your gradients between -5 (min) and 5 (max)
    gradients = clip(gradients, maxValue = 5)

    # Update parameters
    parameters = update_parameters(parameters, gradients, learning_rate)
    
    return loss, gradients, a[len(X)-1]
```

## 采样

训练出参数后，我们可能想让模型生成一些恐龙的名字，看看效果怎么样，生成流程如下图所示：

![](dinos3.png)

1. $a^{\langle 0\rangle}$ 和 $x^{\langle 1\rangle}$ 为 0 向量

2. 向前传播一个时间步得到隐藏状态 $a^{\langle 1\rangle}$ 输出 $\hat y^{\langle 1\rangle}$ (即各个字符的概率分布)：
   $$
   a^{\langle t+1 \rangle} = \tanh(W_{ax}  x^{\langle t \rangle } + W_{aa} a^{\langle t \rangle } + ba)
   $$

   $$
   \hat y^{\langle t + 1 \rangle } = softmax(W_{ya}  a^{\langle t + 1 \rangle } + b_y)
   $$





3. 进行采样：假设 $\hat{y}^{\langle t+1 \rangle }_i = 0.16$，则以 16% 的概率选取索引 i 所对应的字符，可以使用 `np.random.choice` 实现。这也正是 `softmax` 名字的由来，没有强硬地输出一个最大值，而是输出每个值为最大的概率，虽然大部分情况下用的就是概率最大的那个，但是采样的时候就可以按概率分布随机采样。
4. 用上一个时间步的输出作为输入，重复采样，直到遇到结束符(或者名字长度为 50 个字符，避免停不下来)。
``` python
def sample(parameters, char_to_ix, seed):
    # Retrieve parameters and relevant shapes from "parameters" dictionary
    Waa, Wax, Wya, by, ba = parameters['Waa'], parameters['Wax'], parameters['Wya'], parameters['by'], parameters['ba']
    vocab_size = by.shape[0]
    n_a = Waa.shape[1]
    
    # Step 1: Create the one-hot vector x for the first character (initializing the sequence generation).
    x = np.zeros((vocab_size, 1))
    # Step 1': Initialize a_prev as zeros
    a_prev = np.zeros((n_a, 1))
    
    # Create an empty list of indices, this is the list which will contain the list of indices of the characters to generate
    indices = []
    
    # Idx is a flag to detect a newline character, we initialize it to -1
    idx = -1 
    
    # Loop over time-steps t. At each time-step, sample a character from a probability distribution and append 
    # its index to "indices". We'll stop if we reach 50 characters (which should be very unlikely with a well 
    # trained model), which helps debugging and prevents entering an infinite loop. 
    counter = 0
    newline_character = char_to_ix['\n']
    
    while (idx != newline_character and counter != 50):
        
        # Step 2: Forward propagate x using the equations (1), (2) and (3)
        a = np.tanh(np.dot(Wax, x) + np.dot(Waa, a_prev) + ba)
        z = np.dot(Wya, a) + by
        y = softmax(z)
        
        # for grading purposes
        np.random.seed(counter+seed)  
        
        # Step 3: Sample the index of a character within the vocabulary from the probability distribution y
        idx = np.random.choice(list(range(vocab_size)), p = y[:,0])

        # Append the index to "indices"
        indices.append(idx)
        
        # Step 4: Overwrite the input character as the one corresponding to the sampled index.
        x = np.zeros((vocab_size,1))
        x[idx] = 1
        
        # Update "a_prev" to be "a"
        a_prev = a
        
        # for grading purposes
        seed += 1
        counter +=1
        
    if (counter == 50):
        indices.append(char_to_ix['\n'])
    
    return indices
```

## 训练模型

对于数据集中的每一行数据(随机打乱)，随机梯度下降 100 次后则随机采样生成 10 个名字。首先需要生成数据的标签，即每个字符对于的标签是它的下一个字符：

```python
index = j % len(examples)
X = [None] + [char_to_ix[ch] for ch in examples[index]] 
Y = X[1:] + [char_to_ix["\n"]]
```

由于使用的梯度下降法是随机梯度下降，会存在振荡现象，需要用带修正的指数加权平均的方法来减小噪声：

``` python
def get_initial_loss(vocab_size, seq_length):
    return -np.log(1.0/vocab_size)*seq_length
```

``` python
def smooth(loss, cur_loss):
    return loss * 0.999 + cur_loss * 0.001
```

模型的完整代码如下所示：

``` python
def model(data, ix_to_char, char_to_ix, num_iterations = 35000, n_a = 50, dino_names = 7, vocab_size = 27):
    # Retrieve n_x and n_y from vocab_size
    n_x, n_y = vocab_size, vocab_size
    
    # Initialize parameters
    parameters = initialize_parameters(n_a, n_x, n_y)
    
    # Initialize loss (this is required because we want to smooth our loss, don't worry about it)
    loss = get_initial_loss(vocab_size, dino_names)
    
    # Build list of all dinosaur names (training examples).
    with open("dinos.txt") as f:
        examples = f.readlines()
    examples = [x.lower().strip() for x in examples]
    
    # Shuffle list of all dinosaur names
    shuffle(examples)
    
    # Initialize the hidden state of your LSTM
    a_prev = np.zeros((n_a, 1))
    
    # Optimization loop
    for j in range(num_iterations):
        
        # Use the hint above to define one training example (X,Y) (≈ 2 lines)
        index = j % len(examples)
        X = [None] + [char_to_ix[ch] for ch in examples[index]] 
        Y = X[1:] + [char_to_ix["\n"]]
        
        # Perform one optimization step: Forward-prop -> Backward-prop -> Clip -> Update parameters
        # Choose a learning rate of 0.01
        curr_loss, gradients, a_prev = optimize(X, Y, a_prev, parameters, learning_rate = 0.01)
        
        # Use a latency trick to keep the loss smooth. It happens here to accelerate the training.
        loss = smooth(loss, curr_loss)

        # Every 2000 Iteration, generate "n" characters thanks to sample() to check if the model is learning properly
        if j % 2000 == 0:
            print('Iteration: %d, Loss: %f' % (j, loss) + '\n')
            # The number of dinosaur names to print
            seed = 0
            for name in range(dino_names):
                # Sample indices and print them
                sampled_indices = sample(parameters, char_to_ix, seed)
                print_sample(sampled_indices, ix_to_char)
                seed += 1  # To get the same result for grading purposed, increment the seed by one. 
            print('\n')
        
    return parameters
```

## * 莎士比亚风格

作业最后还展示了如何使用 LSTM 生成莎士比亚风格的诗词，由于恐龙的名字很短，所以长期依赖问题不明显。生成莎士比亚风格诗词的时候就很明显，所以需要使用 LSTM 来解决长期以来问题。

基于字符的语言模型有优点也有缺点，优点是不必担心出现未知的标识，例如 `Mau` 这样的序列。而基于词汇的语言模型，如果 `Mau` 不在字典中就只能把它当成 UNK。缺点是序列太长，即时间步太多，很难捕捉长期依赖关系，计算成本高。除非需要处理大量未知文本和未知词汇的应用，大多数都是使用基于词汇的语言模型。

## 参考文献

1. 吴恩达. DeepLearning. 