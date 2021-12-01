---
title: 集束搜索和 BLEU
date: 2018-11-26 10:43:02
updated: 2018-11-26 14:43:53
tags: Deep Learning
mathjax: true
typora-root-url: ./beam-search-and-bleu
---

## 前言

花了几天时间总结了一下滤波器，发现滤波器还分时域和频域，涨知识了。突然想起来课程中还有集束搜索和 BLEU 这部分内容，并没有出现在序列学习的实验中，所以还是先把这部分内容再学习学习。

<!-- more -->

## 集束搜索

Beam Search（集束搜索）是计算机科学中最重要的 32 个算法之一，它是一种启发式的图搜索算法，通常用在图的解空间较大的情况下，减少搜索所占用的时间和空间。

集束搜索使用广度优先策略建立搜索树，在树的每一层按照启发代价对节点进行排序，然后仅留下 B（集束宽度）个节点，仅这些节点在下一层次继续扩展。集束宽度越小，搜索速度越快，但是最终输出的序列质量越有可能不是最优的，因此集束搜索算法是不完全的。

* $B=1$，每次只挑出最可能的那一个词，相当于**贪婪算法**
* $B=\infty$，每次都保留所有可能的词，相当于**宽度优先搜索**

假设有一个法语句子：“Jane visite l'Afrique en Septembre.”，我们希望翻译成英语：“Jane is visiting Africa in September.”。不考虑大小写，假设词汇表有 10000 个单词，集束宽度为 3，第一步是给定输入法语序列 $x$，评估第一个单词为词汇表中每个单词的概率 $P(y^{\langle 1 \rangle}|x)$ 是多少。贪婪算法只挑出概率最大的单词，然后继续评估下一个单词的概率，而集束搜索则会考虑多个选择，因为概率最大的也不一定是最好的，我们需要找的是让整个句子的概率最大的单词。例如第一个单词最可能的三个选项为：**in**、**jane** 和 **september**。

即：
$$
P(y^{\langle 1 \rangle}=“\text{in}”|x)>P(y^{\langle 1 \rangle}=“\text{jane}”|x)>P(y^{\langle 1 \rangle}=“\text{september}”|x)>...
$$
第二步我们想让前第一个和第二个单词同时出现的概率最大，则在第一个词为**in**、**jane** 和 **september** 的时候，分别计算前两个词的概率，即第一个时间步的输出作为第二个时间步的输入：

![](a.png)
$$
P(y^{\langle 1 \rangle},y^{\langle 2 \rangle}|x)=P(y^{\langle 1 \rangle}|x)\times P(y^{\langle 2 \rangle}|x,y^{\langle 1 \rangle})
$$
因此一共会有 30000 个选择，我们还是选择 3 个概率最大的选项，例如可能是：**in September**、**jane is** 和 **jane visits**，即：
$$
P(“\text{in September}”|x)>P(“\text{jane is}”|x)>P(“\text{jane visits}”|x)>...
$$

这个时候第一个单词为 **september** 的选项已经不存在了，然后继续以上步骤直到输出终结符 **<EOS\>**。

### 改进集束搜索

机器翻译就是给定输入，找到一个最后可能的输出，即最大化概率 $P(y^{\langle 1 \rangle},...,y^{\langle T_y \rangle}|x)$。而集束搜索就是找到最大化这个概率（目标函数）的参数的一种非完全方法，该概率表示成：
$$
P(y^{\langle 1 \rangle}|x)P(y^{\langle 2 \rangle}|x,y^{\langle 1 \rangle})...P(y^{<T_y>}|x,y^{\langle 1 \rangle},...,y^{\langle T_y-1 \rangle})
$$
由于这些概率值通常远小于 1。连乘会造成数值下溢，即电脑的浮点表示不能精确地储存，因此我们通常对其取对数，即最大化：
$$
\sum_{t=1}^{T_y}logP(y^{\langle t \rangle}|x,y^{\langle 1 \rangle},...,y^{\langle t-1 \rangle})
$$
集束搜索还存在一个问题就是，对于一个很长的句子，那么这个概率的可能就会很小。也就是说这个目标函数比较倾向于简短的翻译结果，我们可以通过归一化，即除以翻译结果的单词数量（实践中是单词数量的 $\alpha$ 次方，这是一个超参数），来减少对输出长的结果的惩罚，这个也叫归一化的对数似然目标函数。
$$
\frac{\sum_{t=1}^{T_y}logP(y^{\langle t \rangle}|x,y^{\langle 1 \rangle},...,y^{\langle t-1 \rangle})}{T_y^\alpha}
$$

### 误差分析

因为集束搜索是一种启发式（近似）搜索算法，不总能输出可能性最大的句子，那么如何才能知道束宽的设置是否合适呢？如果 Seq2Seq 模型解码结果不好，那么造成这个不好结果是 RNN 还是集束搜索算法的参数呢？

假设模型的输出 $\hat y$ 为 **Jane visited Africa last September.**，人工翻译 $y^*$ 为 **Jane visits Africa in September.**。很明显模型的翻译结果不对，我们可以计算 $P(\hat y|x)$ 和 $P(y^*|x)$：

* $P(\hat y|x) < P(y^*|x)$，表示存在更好的翻译结果 $y^*$，而模型没搜索到，即集束搜索出问题了；
* $P(\hat y|x) \geq P(y^*|x)$，表示更好的翻译结果 $y^*$ 在模型中的概率反而更小，即 RNN 编码解码出问题了。

因此可以通过遍历开发集中的所有数据，分析更有可能是集束搜索有问题还是 RNN 有问题。

## BLEU

机器翻译的一大难题是一个法语句子可以有多种英文翻译而且都同样好，所以当有多个同样好的答案时，怎样评估一个机器翻译系统呢？假如一个法语句子：**Le chat est sur le tapis**，人工翻译的参考译文为：

* **The cat is on the mat.** 
* **There is a cat on the mat.** 

这两个英语句子都准确地翻译了这个法语句子。BLEU (Bilingual Evaluation Understudy) 可以评价机器译文与参考译文的相似度，它能够自动地计算一个分数来衡量机器翻译的好坏。首先来看一种比较简单的方法：
$$
P=\frac{m}{\omega_t}
$$
其中 $m$ 表示在参考译文中出现的机器译文中的单词数，$\omega_t$ 表示机器译文词的总数，例如机器译文：**the the the the the the the.**，相似度 $P=\frac{7}{7}=1$。但是这个翻译并不好，因为参考译文中的 **the** 没那么多，所以改良一下，给它加个上限：
$$
Count_{clip}(word)=min\lbrace Count(word), MaxRefCount(word)\rbrace
$$
其中 $Count(word)$ 表示单词在机器译文中出现的次数，$MaxRefCount(word)$ 表示该单词在参考译文中出现的最大次数。**the** 在机器译文中出现了 7 次所以 $Count(word)=7$；**the** 在第一个参考译文中出现了两次，在第二个参考译文中出现了 1 次，所以 $MaxRefCount(word)=2$，进而：
$$
P=\frac{Count_{clip}(word)}{\omega_t}=\frac{2}{7}
$$
根据定义，$\omega_t$ 的计算公式如下所示：
$$
\omega_t=\sum_{word \in \hat y}Count(word)
$$
现实情况中，使用单个词衡量相似度效果往往不好，对 n-gram 求平均能够有效改善上述问题。因此，对于整个测试语料，n-gram 相似度的计算公式如下：
$$
P_n=\frac{\sum_{n-gram\in \hat y}Count_{clip}(n-gram)}{\sum_{n-gram\in \hat y}Count(n-gram)}
$$
所以 BLEU 的计算公式如下：
$$
BLEU=BP\bullet exp(\frac{1}{N}\sum_{n=1}^{N}p_n)
$$
其中 $BP$ 为简短惩罚，当机器译文的长度大于参考译文时，惩罚因子为 1，否则如下：
$$
BP=exp\Big(1-\frac{\text{机器译文长度}}{\text{参考译文长度}}\Big)
$$

## 参考文献

1. 吴恩达. DeepLearning. 
2. Papineni, K., et al. 2002. BLEU: a Method for Automatic Evaluation of Machine Translation