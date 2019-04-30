---
title: 词向量表示
date: 2018-08-31 16:35:00
updated: 2018-08-31 20:18:30
tags: Deep Learning
mathjax: true
---

## 前言

实验和上一篇博客都使用了 Embedding，这篇博客正好可以加深对词向量和嵌入矩阵的理解。发现吴恩达课程里面很多内容他说在实验里有，但是我却没找到，例如本节中的负采样，难道他也喜欢挖坑不喜欢填？

<!-- more -->

## 词汇表征

在自然语言处理领域一个很重要的概念就是词嵌入 (Word Embeddings)，这是语言表示的一种方式，可以让算法理解一些**类似**的词。在使用词嵌入以前，通常用的都是词汇表，也就是将一个个单词变成独热向量，但是这样的表示没有办法让模型理解相似的词，引用夏树涛老师的一句话就是：独热向量的欧氏距离是没有意义的！

因此很有必要使用特征化的表示来表示每个词，也就是学习给每个词进行分类，例如词汇量为 5 的词汇表对应的嵌入矩阵如下所示：

|        | Man  | Woman | King  | Queen | Apple | Orange |
| ------ | ---- | ----- | ----- | ----- | ----- | ------ |
| Gender | -1   | 1     | -0.95 | 0.97  | 0.00  | 0.01   |
| Royal  | 0.01 | 0.02  | 0.93  | 0.95  | -0.01 | 0.00   |
| Age    | 0.03 | 0.02  | 0.7   | 0.69  | 0.03  | -0.02  |
| Food   | 0.09 | 0.01  | 0.02  | 0.01  | 0.95  | 0.97   |

对于词汇表中任意单词的独热向量 $O_i$，它的大小是 $5\times 1$ ，嵌入矩阵 $E$ 大小为 $4\times 5$ ， 那么 $EO_i$ 就可以得到词汇表中单词 $i$ 的嵌入向量。 模型在遇到 Apple 和 Orange 的时候就可以计算两个向量的余弦相似度，从而知道它们都是食物。在实践中可以使用 t-SNE 算法可视化高维特征向量，这个算法会将高维向量映射到一个二维空间中。

### 余弦相似度

为了衡量两个单词的相似性，我们需要一种衡量两个单词的嵌入向量的方法。给定两个向量 $u$ 和 $v$，其余弦相似度定义为：
$$
\text{CosineSimilarity(u, v)} = \frac {u . v} {||u||_2 ||v||_2} = cos(\theta)
$$
其中分子是两个向量的点乘，分母是两个向量的二范数的乘积，$\theta$ 是两个向量形成的角度。两个向量越相似，余弦相似度就越接近于 1，不相似则取值会很小。图像如下图所示：

![](https://s1.ax2x.com/2018/08/31/5BP8Bi.png)

```python
def cosine_similarity(u, v):
    distance = 0.0
    
    # Compute the dot product between u and v (≈1 line)
    dot = np.dot(u, v)
    # Compute the L2 norm of u (≈1 line)
    norm_u = np.sqrt(np.sum(np.power(u,2)))
    
    # Compute the L2 norm of v (≈1 line)
    norm_v = np.sqrt(np.sum(np.power(v,2)))
    # Compute the cosine similarity defined by formula (1) (≈1 line)
    cosine_similarity = np.divide(dot, norm_u * norm_v)
    
    return cosine_similarity
```

### 学习词嵌入

通常在使用词嵌入的时候，可以针对自己的数据集训练（也就是学习上面表格中的嵌入矩阵 $E$），如果数据集不是很充分也可以从网上下载训练好的词嵌入模型。在实践中通常是建立一个语言模型进行学习词嵌入（也就是说不是单独地去训练词嵌入），例如使用神经网络预测序列的下一个单词，I want a glass of orange __：

![](https://s1.ax2x.com/2018/11/28/5Vnf2R.png)

在实践中通常的做法是使用一个固定的历史窗口，例如上图中超参数窗口大小为 4，那么久只用前面 4 个单词来预测下一个单词。上图中的嵌入矩阵也是一个参数，可以在训练过程中学习出来。如果训练集中的句子比较复杂还可以考虑上下文，即用前面四个词和后面四个词来预测中间的词。所以如果使用预训练的嵌入矩阵，那么在这个步骤就可以再训练一下，或者不训练（把它当成超参数）直接使用。

#### Word2Vec

Word2Vec 算法有两种模型 Skip-grams 和 CBOW，视频中只介绍了 Skip-grams，因为它在大型语料库中表现更好。这个模型的做法是随机选择一个单词 $O_c$ 作为上下文，然后在一定的词距内随机选另一个词 $O_t$ 作为待预测的词，即目标词，然后进行监督学习。虽然不太容易预测，但是这个模型可以很好地学习出嵌入矩阵：

![](https://s1.ax2x.com/2018/11/28/5Vo3GB.png)

其中 $e_c=EO_c$，对于 10,000 个单词的词汇表，softmax 预测目标词 $O_t$ 的概率为：
$$
P(O_t|O_c) = \frac{e^{\theta_{t}^{T}e_{c}}}{\sum_{i=1}^{10,000}e^{\theta_{i}^{T}e_{c}}}
$$
其中 $\theta_t$ 是判断输出为 $O_t$ 这个类别的参数。损失函数为：
$$
L(\hat y,y)=-\sum_{i=1}^{10,000}{y_{i}\log\hat y_{i}}
$$
损失函数中的 $\hat y$ 和 $y$ 都是独热向量。在计算概率的时候，分母要累加所有词汇在给定词汇情况下的概率，所以词汇量比较大的时候计算量比较大，因此可以采用分级 softmax 分类器或者**负采样**。分级 softmax 分类器的思想是使用霍夫曼树，先判断词属于前 5000 个还是后 5000 个，然后继续分析，最后时间复杂度就从 N 变成 logN。 不过需要注意的是，在实践中使用的不是完全平衡的分类树，而且通常常用词会放在树根。详细的内容可以参考原文献[2]。

#### 负采样

Skim-grams 其实就是学习从 $x$ 映射到 $y$ 的监督模型，只不过时间复杂度有点大。而负采样需要构造一个新的监督学习问题，即给定一对单词，例如 orange 和 juice，预测它们是否属于一对上下文-目标词。例如有一个句子：I want a glass of orange juice to go along with my cereal.

首先从句子中采样得到一个上下文词 orange 和一个目标词 juice，然后标记为 1；然后去字典中随机选 k （这里 k=4）个单词，标记为 0（即使 of 也出现在句子中）：

| Context | Word  | Target? |
| ------- | ----- | ------- |
| orange  | juice | 1       |
| orange  | king  | 0       |
| orange  | book  | 0       |
| orange  | the   | 0       |
| orange  | of    | 0       |

给定输入的上下文词 $O_c$ 和可能的目标词 $O_t$ ，定义一个逻辑回归模型，判断输出：
$$
P(y=1|c,t)=\sigma(\theta_t^Te_c)
$$
即每个正样本都有 K 个对应的负样本来训练一个逻辑回归模型，相对而言每次迭代的成本更低，详细内容可以参考原文献[3]。在负采样的时候如果均匀采样，则学不到单词的分布，如果根据单词的频率采样又可能导致一些介词的频率很高，因此通常介于这两者之间：
$$
P(\omega_i)=\frac{f(\omega_i)^{\frac{3}{4}}}{\sum_{j=1}^{10,000}f(\omega_i)^{\frac{3}{4}}}
$$
其中 $f(\omega_i)$ 是语料库中某个单词的词频。 

#### GloVe 词向量

GloVe 表示**用于词表示的全局变量**（Global vectors for word representation），假设 $X_{ij}$ 为单词 $i$ 在上下文词 $j$ 中出现的次数（即两个词出现在同一个窗口中的次数）。如果上下文词和目标词的范围定义为左右各 10 各词的话，根据定义有 $X_{ij}=X_{ji}$，矩阵 $X$ 也叫做语料库的共现矩阵。GloVe 就是要最小化：
$$
\text{minimize}\sum_{i=1}^{10,000}\sum_{j=1}^{10,000}f(X_{ij})(\theta_i^Te_j+b_i+\tilde{b_j}-logX_{ij})^2
$$
其中 $b_i$ 和 $\tilde{b_j}$ 是两个词向量的偏置项， 权重函数 $f(X_{ij})$ 是一个截断函数：
$$
f(x) =
\begin{cases}
(x/x_{max})^\alpha & \text{if $x<x_{max}$ } \\\
1 & \text{otherwise}
\end{cases}
$$
原文献中 $\alpha$ 的取值都是 0.75，而 $x_{max}$ 取值都是 100，损失函数的详细推导过程可以参考原文献[4]。

## 单词类比任务

**man is to woman as king is to queen**，即给定单词 a(man)、b(woman) 和 c(king)，需要找到一个单词 d 满足 $e_b - e_a \approx e_d - e_c$。这里衡量 $e_b - e_a$ 就用余弦相似度。

``` python
def complete_analogy(word_a, word_b, word_c, word_to_vec_map):
    # convert words to lower case
    word_a, word_b, word_c = word_a.lower(), word_b.lower(), word_c.lower()
    
    # Get the word embeddings v_a, v_b and v_c (≈1-3 lines)
    e_a, e_b, e_c = word_to_vec_map[word_a], word_to_vec_map[word_b], word_to_vec_map[word_c]
    
    words = word_to_vec_map.keys()
    max_cosine_sim = -100              # Initialize max_cosine_sim to a large negative number
    best_word = None                   # Initialize best_word with None, it will help keep track of the word to output

    # loop over the whole word vector set
    for w in words:        
        # to avoid best_word being one of the input words, pass on them.
        if w in [word_a, word_b, word_c] :
            continue
        
        # Compute cosine similarity between the vector (e_b - e_a) and the vector ((w's vector representation) - e_c)  (≈1 line)
        cosine_sim = cosine_similarity(e_b - e_a, word_to_vec_map[w] - e_c)
        
        # If the cosine_sim is more than the max_cosine_sim seen so far,
            # then: set the new max_cosine_sim to the current cosine_sim and the best_word to the current word (≈3 lines)
        if cosine_sim > max_cosine_sim:
            max_cosine_sim = cosine_sim
            best_word = w
        
    return best_word
```

## 去偏词向量

首先计算一个向量 $g = e_{woman}-e_{man}$，这个向量可以粗略地看成是性别 **g**ender。或者可以同时计算:

* $g_1 = e_{mother}-e_{father}$

* $g_2 = e_{girl}-e_{boy}$

最后取这三个向量的均值作为性别则会更加精确。可以通过以下代码验证我们的想法：

```python
name_list = ['john', 'marie', 'sophie', 'ronaldo', 'priya', 'rahul', 'danielle', 'reza', 'katy', 'yasmin']

for w in name_list:
    print (w, cosine_similarity(word_to_vec_map[w], g))
```

```
List of names and their similarities with constructed vector:
john [-0.23163356]
marie [0.31559794]
sophie [0.3186879]
ronaldo [-0.31244797]
priya [0.17632042]
rahul [-0.16915471]
danielle [0.24393299]
reza [-0.0793043]
katy [0.28310687]
yasmin [0.23313858]
```

可以看出，一些比较女性化的名字和 $g$ 的相似性大于0，比较男性化的名字和 $g$ 的相似性则小于 0。

### 中和无性别单词的偏差

下面是一些词和性别的相似性，虽然大部分的工程师是男性，但是这有点性别歧视了，而且这些词本身是不应该有性别之分的。

```
receptionist [0.33077942]
technology [-0.13193732]
teacher [0.17920923]
engineer [-0.0803928]
```

假如词嵌入是 50 维，则可以分为两部分：偏置方向 $g$ 和其余的 49 维 $g_{\perp}$。其余的 49 维与性别无关，所以是正交的。下面的任务就是把向量 $e_{receptionist}$ 的 $g$ 方向置 0，得到 $e_{receptionist}^{debiased}$。如下图所示：

![](https://s1.ax2x.com/2018/08/31/5Ba9AE.png)
$$
e^{bias\\_component} = \frac{e \cdot g}{||g||_2^2} * g
$$

$$
e^{debiased} = e - e^{bias\\_component}
$$

$e^{bias\\_component}$ 也就是 $e$ 在方向 $g$ 上的投影。

``` python
def neutralize(word, g, word_to_vec_map):
    # Select word vector representation of "word". Use word_to_vec_map. (≈ 1 line)
    e = word_to_vec_map[word]
    
    # Compute e_biascomponent using the formula give above. (≈ 1 line)
    e_biascomponent = np.divide(np.dot(e, g), np.linalg.norm(g)**2) * g

 
    # Neutralize e by substracting e_biascomponent from it 
    # e_debiased should be equal to its orthogonal projection. (≈ 1 line)
    e_debiased = e - e_biascomponent
    
    return e_debiased
```

### 性别专用词均衡算法

均衡算法可以应用于两个只有性别之分的词。例如男演员 (actor) 和女演员 (actress)，可能女演员更接近保姆 (babysit)，通过对 babysit 的中和可以减少保姆和性别的关联性，但是还是不能保证这两种演员和其他词的关联性是否相同。均衡算法就可以处理这个问题，均衡算法的原理如下图所示：

![](https://s1.ax2x.com/2018/08/31/5Ba0FN.png)

原理就是保证这两个词到 49 维的 $g_\perp$ 的距离相等，公式参考 Bolukbasi et al., 2016：
$$
\mu = \frac{e_{w1} + e_{w2}}{2}
$$

$$
\mu_{B} = \frac {\mu \cdot \text{bias_axis}}{||\text{bias_axis}||_2^2} *\text{bias_axis}
$$

$$
\mu_{\perp} = \mu - \mu_{B}
$$

$$
e_{w1B} = \frac {e_{w1} \cdot \text{bias_axis}}{||\text{bias_axis}||_2^2} *\text{bias_axis}
$$

$$
e_{w2B} = \frac {e_{w2} \cdot \text{bias_axis}}{||\text{bias_axis}||_2^2} *\text{bias_axis}
$$

$$
e_{w1B}^{corrected} = \sqrt{ |{1 - ||\mu_{\perp} ||^2_2} |} * \frac{e_{\text{w1B}} - \mu_B} {|(e_{w1} - \mu_{\perp}) - \mu_B)|}
$$

$$
e_{w2B}^{corrected} = \sqrt{ |{1 - ||\mu_{\perp} ||^2_2} |} * \frac{e_{\text{w2B}} - \mu_B} {|(e_{w2} - \mu_{\perp}) - \mu_B)|}
$$

$$
e_1 = e_{w1B}^{corrected} + \mu_{\perp}
$$

$$
e_2 = e_{w2B}^{corrected} + \mu_{\perp}
$$

``` python
def equalize(pair, bias_axis, word_to_vec_map):
    # Step 1: Select word vector representation of "word". Use word_to_vec_map. (≈ 2 lines)
    w1, w2 = pair
    e_w1, e_w2 = word_to_vec_map[w1], word_to_vec_map[w2]
    
    # Step 2: Compute the mean of e_w1 and e_w2 (≈ 1 line)
    mu = (e_w1 + e_w2) / 2.0

    # Step 3: Compute the projections of mu over the bias axis and the orthogonal axis (≈ 2 lines)
    mu_B = np.divide(np.dot(mu, bias_axis), np.linalg.norm(bias_axis)**2) * bias_axis
    mu_orth = mu - mu_B

    # Step 4: Use equations (7) and (8) to compute e_w1B and e_w2B (≈2 lines)
    e_w1B = np.divide(np.dot(e_w1, bias_axis), np.linalg.norm(bias_axis)**2) * bias_axis
    e_w2B = np.divide(np.dot(e_w2, bias_axis), np.linalg.norm(bias_axis)**2) * bias_axis
        
    # Step 5: Adjust the Bias part of e_w1B and e_w2B using the formulas (9) and (10) given above (≈2 lines)
    corrected_e_w1B = np.sqrt(np.abs(1 - np.sum(mu_orth**2))) * np.divide(e_w1B - mu_B, np.abs(e_w1 - mu_orth - mu_B))
    corrected_e_w2B = np.sqrt(np.abs(1 - np.sum(mu_orth**2))) * np.divide(e_w2B - mu_B, np.abs(e_w2 - mu_orth - mu_B))

    # Step 6: Debias by equalizing e1 and e2 to the sum of their corrected projections (≈2 lines)
    e1 = corrected_e_w1B + mu_orth
    e2 = corrected_e_w2B + mu_orth
                                                                
    return e1, e2
```

通过均衡算法，两个只有性别之分的词和性别的相似度应该大致成相反数的关系。

## 参考文献

1. 吴恩达. DeepLearning. 
2. Mikolov T, Chen K, Corrado G, et al. Efficient Estimation of Word Representations in Vector Space[J]. Computer Science, 2013.
3. Mikolov T, Sutskever I, Chen K, et al. Distributed Representations of Words and Phrases and their Compositionality[J]. 2013, 26:3111-3119.
4. Pennington J, Socher R, Manning C. Glove: Global Vectors for Word Representation[C]// Conference on Empirical Methods in Natural Language Processing. 2014:1532-1543.