---
title: 特征缩放
date: 2018-05-31 21:04:59
updated: 2018-05-31 23:13:40
tags: Machine Learning
mathjax: true
typora-root-url: ./feature-scaling
---

## 前言

在机器学习中经常使用梯度下降算法来优化代价函数，得到局部最优解。但是梯度下降算法有时候效率并不高，有一些算法能够很大程度上提高梯度下降算法的性能。例如前面提到的小批量梯度下降，每次使用一部分样本更新参数，能够加速训练过程，还有**特征缩放**。

<!-- more -->

## 特征缩放

在实际应用中，我们得到的数据会存在缺失值、重复值等各种问题，所以数据的预处理就显得尤为重要。特征缩放是一种常用的数据处理方式，使用特征缩放能够加快梯度下降，提高收敛速度。Normalization 这个词翻译成归一化不太好理解，网上的各种资料更是滥用归一化和标准化 (Standardization)，下面只能结合着 [sklearn](http://scikit-learn.org/stable/modules/preprocessing.html#) 的官方文档给出自己的理解。

人们常说的归一化其实就是普通的特征缩放(scaling)，通过线性变换对数据进行缩放，简化计算的方式，将有量纲的输入，变换为无量纲。例如：房价预测问题中房间的大小 (30~100$m^2$) 和房间数 (3~5)，不同量纲的特征会导致在梯度下降时”步伐“ ($\alpha dw$) 不同，学习率太小收敛慢，学习率太大，有些特征(例如房间大小)的权值甚至可能不会收敛；在使用 Sigmoid 或者 Tanh 作为激活函数时也容易出现饱和现象。(详情参考：[Importance of Feature Scaling in Data Modeling (Part 2)](https://www.robertoreif.com/blog/2017/12/21/importance-of-feature-scaling-in-data-modeling-part-2))

![](https://s1.ax2x.com/2018/06/06/RWZsS.png)

归一化有不同的策略，常用的归一化方法有以下几种：

* Mean Normalization

$$
X'=\frac{X-mean(X)}{S}
$$

Mean Normalization减去均值将数据中心化 (0 均值化)，再除以 $S$ 进行缩放。$S$ 可以取 $max(X)-min(X)$，或者取标准差 $std(X)$，这时也叫做 Z-score 归一化或者标准化 (Standardization)。使用 `sklearn` 实现标准化如下所示：

``` python
scaler = sklearn.preprocessing.StandardScaler().fit(x_train)
x_train = scaler.transform(x_train)
x_test = scaler.transform(x_test)
```

或者可以直接对数据集使用 `x_train = preprocessing.scale(X_train)` 进行缩放，使用 `StandardScaler` 类是为了让测试集和训练集进行同样的缩放，缩放后的数据具有零均值和标准方差。

- Min-max Normalization

$$
X'=\frac{X-min(X)}{max(X)-min(X)}
$$

```python
scaler = preprocessing.MinMaxScaler()
X_train = scaler.fit_transform(X_train)
```

数据经过 Min-max Normalization 会被缩放到 `[0, 1]`。使用标准化还是 Min-max 归一化？这个问题没有标准答案，需要具体问题具体分析，**通常情况下使用标准化较多**。数据存在较多异常值也考虑使用标准化；Min-max 常用于归一化图像的灰度值。决策树则不需要特征缩放！吴恩达给的建议是反正使用标准化也没有坏处，就都用上。

## 归一化

在 `sklearn` 中特征缩放都被称为标准化(Standardizatoin)，Z-score 也被称为去均值和方差按比例缩放，其他的都是将特征缩放到给定的最小值和最大值之间(Rescaling，按比例缩放)。而归一化指的是缩放单个样本以具有单位范数的过程，在量化任何样本间的相似度时非常有用。

使用以下代码可以将单个样本的一范数或者二范数归一化：

``` python
preprocessing.normalize(X, norm='l1')
preprocessing.normalize(X, norm='l2')
```


## 参考文献

1. 吴恩达. DeepLearning. 
2. [Why does mean normalization help in gradient descent?](https://www.quora.com/Why-does-mean-normalization-help-in-gradient-descent3)
3. [Importance of Feature Scaling in Data Modeling (Part 1)](https://www.robertoreif.com/blog/2017/12/16/importance-of-feature-scaling-in-data-modeling-part-1-h8nla)
4. [Importance of Feature Scaling in Data Modeling (Part 2)](https://www.robertoreif.com/blog/2017/12/21/importance-of-feature-scaling-in-data-modeling-part-2)
5. [Sklearn Preprocessing data](http://sklearn.apachecn.org/cn/0.19.0/modules/preprocessing.html)