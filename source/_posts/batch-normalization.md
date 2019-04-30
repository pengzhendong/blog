---
title: 批归一化
date: 2018-06-07 10:22:09
updated: 2018-06-07 12:34:23
tags: Deep Learning
mathjax: true
---

## 前言

在深度神经网络中，有效的参数初始化和输入特征归一化等方法能够很大程度上避免梯度消失，加速网络的训练过程。但是深度神经网络由很多层网络叠加，而每一层网络的参数更新会导致下一层网络的输入数据的分布发生变化，通过层层叠加，输入的分布变化会非常剧烈，这就使得网络需要不断重新适应不同分布的输入，而批归一化能够很出色地解决隐藏层间输入分布改变问题。

<!-- more -->

## 批归一化

批归一化 (Batch normalization) 简称 BN，Google 2015 年提出。批归一化通过对**每一层**的输入进行归一化，将数据预处理的方法引入到每一个隐藏层，保持深度网络各层的输入分布不变。

在传统机器学习通常有个假设：“源空间 (source domain) 和目标空间 (target domain) 的数据分布 (distribution) 是一致的”，即训练集和测试集满足独立同分布。目的是希望训练集训练的模型可以**合理**用在测试集上，如果不太关心泛化性 (如在线学习算法) 就不需要这个假设。

迁移学习可以将训练好的模型参数迁移到新的模来帮助模型训练，虽然大部分数据存在相关性，但是它们不是独立同分布的。

### Internal Covariate Shift

 Covariate shift 指源空间和目标空间的条件概率一致，对边缘概率不同：

> $\forall x \in \mathcal{X}, P_s(Y|X=x)=P_t(Y|X=x), P_s(X) \neq P_t(X)$

神经网络的输入经过了一层网络后分布会发生改变，而且差异会随着网络深度增大而增大，但是训练集的真实标签不变，符合 Covariate Shift 的定义，Internal 表示神经网络内部。隐藏层需要重新适应新的分布的输入，因此会降低收敛速度，批归一化通过对每一层网络的输入进行缩放，保证了输入分布的统一。

### 前向传播

在深度学习文献中有一些争论关于应该批归一化 $Z$ 还是 $A$，吴恩达表示在实践中通常批归一化的是 $Z$。给定第 $l$ 层隐藏单元的值 $\mathcal{Z}=\lbrace z^{(1)}, z^{(2)}, …, z^{(m)}\rbrace$ (为了方便表示，省略其层数的上标 $[l]$)，对其进行归一化，有：
$$
\mu_\mathcal{Z}=\frac{1}{m}\sum_{i=1}^{m}z^{(i)}
$$

$$
\sigma_\mathcal{Z}^2=\frac{1}{m}\sum_{i=1}^{m}(z^{(i)}-\mu_\mathcal{Z})^2
$$

$$
z_{norm}^{(i)}=\frac{z^{(i)}-\mu_\mathcal{Z}}{\sqrt{\sigma_\mathcal{Z}^2+\varepsilon}}
$$

归一化后的 $z_{norm}^{(i)}$ 具有 0 均值和标准方差，但是这样会降低模型的灵活度，导致新的分丧失从前层传递过来的特征与知识，对于 Sigmoid 激活函数也无法有效利用其非线性功能，所以需要再次对其进行缩放和平移：
$$
\hat z^{(i)}=\gamma z_{norm}^{(i)}+\beta
$$
其中 $\gamma$ 和 $\beta$ 是需要学习的参数，在每个隐藏层中通过 $\gamma$ 和 $\beta$ 可以随意设置 $\hat z^{(i)}$ 的均值和方差。当 $\gamma=\sqrt{\sigma_\mathcal{Z}^2+\varepsilon}$ 和 $\beta=\mu_\mathcal{Z}$ 时，有 $\hat z^{(i)}=z^{(i)}$。因此在梯度下降算法中，第 $l$ 层神经网络需要更新的参数不止有 $W^{[l]}$ 和 $b^{[l]}$，还有 $\gamma^{[l]}$ 和 $\beta^{[l]}$。批归一化有轻微的正则化效果 (类似于 Dropout)，因为使用小批量训练数据给隐藏单元添加了噪声，使得后部的神经元不过分依赖任何一个隐层单元。

### 反向传播

在反向传播计算 $\gamma$ 和 $\beta$ 的梯度的时候，同样使用链式法则求导，对于最后一层神经网络，有：
$$
d\gamma=\frac{\partial{\mathscr{l}}}{\partial{\gamma}}=\frac{\partial{\mathscr{l}}}{\partial{\hat z^{(i)}}}\cdot z_{norm}^{(i)}
$$

$$
d\beta=\frac{\partial{\mathscr{l}}}{\partial{\beta}}=\frac{\partial{\mathscr{l}}}{\partial{\hat z^{(i)}}}
$$

$$
dz_{norm}^{(i)}=\frac{\partial{\mathscr{l}}}{\partial{z_{norm}^{(i)}}}=\frac{\partial{\mathscr{l}}}{\partial{\hat z^{(i)}}}\cdot \gamma
$$

$$
d\sigma_\mathcal{Z}^2=\frac{\partial{\mathscr{l}}}{\partial{\sigma_\mathcal{Z}^2}}=\sum_{i=1}^{m}dz_{norm}^{(i)}\cdot (z^{(i)}-\mu_\mathcal{Z})\cdot \frac{-1}{2}(\sigma_\mathcal{Z}^2+\varepsilon)^{\frac{-3}{2}}
$$

$$
d\mu_\mathcal{Z}=\frac{\partial{\mathscr{l}}}{\partial{\mu_\mathcal{Z}}}=\sum_{i=1}^{m}dz_{norm}^{(i)}\cdot \frac{-1}{\sqrt{\sigma_\mathcal{Z}^2+\varepsilon}}
$$

### 测试

在训练过程中，使用批归一化将数据以小批量的形式逐一处理，但是在测试的时候，每次测试只有一个数据，计算一个数据的 $\mu_\mathcal{Z}$ 和 $\sigma_\mathcal{Z}^2$ 没有意义，所以需要重新估计 $\mu$ 和 $\sigma^2$。理论上可以对整个训练集求 $\mu_\mathcal{D}$ 和 $\sigma_\mathcal{D}^2$，但在实际操作中通常使用指数加权平均来追踪训练过程中看到的所有 $\mu_\mathcal{Z}$ 和 $\sigma_\mathcal{Z}^2$，在第 $l$ 层隐藏层第 $t$ 个小批量处，有：
$$
\mu_t=\beta_1\mu_{t-1}+(1-\beta_1)\mu^{\lbrace t\rbrace[l]}
$$

$$
\sigma_t^2=\beta_2 \sigma_{t-1}^2+(1-\beta_2)\sigma^{2\lbrace t\rbrace[l]}
$$

## 参考文献

1. 吴恩达. DeepLearning. 
2. lan Goodfellow, Yoshua Bengio, Aaron Courville. Deep Learning. 人民邮电出版社. 2017.
3. [详解深度学习中的 Normalization，不只是 BN](https://zhuanlan.zhihu.com/p/33173246)
4. [Why does batch normalization help?](https://www.quora.com/Why-does-batch-normalization-help)