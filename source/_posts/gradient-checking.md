---
title: 梯度检验
date: 2018-05-31 13:33:50
updated: 2018-05-31 14:43:23
tags: Machine Learning
typora-root-url: ./gradient-checking
mathjax: true
---

## 前言

神经网络反向传播计算各个参数的梯度，用于梯度下降更新参数。用链式法则求解各个参数的导数的过程中，梯度的计算很复杂，容易出错，而梯度检验可以帮助我们确保梯度的计算正确。

<!-- more -->

## 数值微分

在反向传播中，链式法则需要人工推导，非常耗时且容易出错。梯度检验的原理是使用[数值微分](https://zh.wikipedia.org/zh/%E6%95%B8%E5%80%BC%E5%BE%AE%E5%88%86)来估计函数的导数，然后拿估计的值和真实值相比，如果数值微分和导数相差太大，则表示导数(梯度)计算错误。在数值上计算 $f(x)$ 在 $x=x_0$ 处的导数，可以由导数的定义
$$
f'(x_0) = \lim_{h \to 0} \frac{f(x_0 + h) - f(x_0)}{h}
$$
得到。对于充分小的 $h$ 有
$$
f'(x_0) \approx \frac{f(x_0 + h) - f(x_0)}{h}
$$
这就是向前差分公式，公式右边就是 $f(x)$ 在 $x_0$ 处的步长为 $h$ 的数值微分。通过 Taylor 展开也能构造出数值微分，而且能求出其截断误差。对称差分的一次项误差相消，对于很小的 $h$ 而言这个值比单边近似还要准确。例如求 $f(x)=x^2$ 在 $x=3$ 处的导数与数值微分：

* 导数：$f'(3)=2\times 3=6$
* 向前差分：$\frac{(3+0.01)^2−3^2}{0.01}=6.1$
* 对称差分：$\frac{(3+0.01)^2−(3-0.01)^2}{0.02}=6.045$

## 梯度检验

代价函数关于参数的梯度的定义:
$$
\frac{\partial J}{\partial \boldsymbol{w}\_i} = \lim_{\varepsilon \to 0} \frac{J(\boldsymbol{w}\_i + \varepsilon) - J(\boldsymbol{w}\_i - \varepsilon)}{2 \varepsilon}
$$
我们想要确保 $\frac{\partial J}{\partial \boldsymbol{w}_i}$ 的计算是正确的，只需要取 $\varepsilon$ 为一个很小的数(例如 $10^{-7}$)，然后计算 $\frac{J(\boldsymbol{w}_i + \varepsilon) - J(\boldsymbol{w}_i - \varepsilon)}{2 \varepsilon}$ 是否约等于 $\frac{\partial J}{\partial \boldsymbol{w}_i}$，实际操作中判断两个参数**向量**的欧氏距离是否足够小。

对于每个参数 $\boldsymbol{w}_i$：

* 使用前向传播计算代价函数 $J(\boldsymbol{w}_i + \varepsilon)$
* 使用前向传播计算代价函数 $J(\boldsymbol{w}_i - \varepsilon)$
* 计算梯度的近似值(数值微分) $ gradapprox[i]=\frac{J(\boldsymbol{w}_i + \varepsilon) - J(\boldsymbol{w}_i - \varepsilon)}{2 \varepsilon}$
* 使用链式法则计算反向传播梯度，缓存到变量 $grad$ 中

使用以下公式计算梯度 $grad$ 和梯度的近似值 $gradapprox$ 的欧氏距离：
$$
difference = \frac {\mid\mid grad - gradapprox \mid\mid_2}{\mid\mid grad \mid\mid_2 + \mid\mid gradapprox \mid\mid_2}
$$
如果欧氏距离 $difference$ 小于 $10^{-7}$ 则表示反向传播梯度计算正确，否则就值得注意了，因为很有可能反向传播的时候梯度计算有误。由于梯度检验比较耗时，所以一般只用于调试，检验正确后关闭梯度检验，而且梯度检验不能与 Dropout 同时使用，因为每次迭代过程中 Dropout 会使神经元结点随机失活，难以计算 Dropout 在梯度下降上的代价函数 $J$。

``` python
def gradient_check_n(parameters, gradients, X, Y, epsilon=1e-7):
    # Set-up variables
    parameters_values, _ = dictionary_to_vector(parameters)
    grad = gradients_to_vector(gradients)
    num_parameters = parameters_values.shape[0]
    J_plus = np.zeros((num_parameters, 1))
    J_minus = np.zeros((num_parameters, 1))
    gradapprox = np.zeros((num_parameters, 1))
    
    # Compute gradapprox
    for i in range(num_parameters):
        
        # Compute J_plus[i]. Inputs: "parameters_values, epsilon". Output = "J_plus[i]".
        thetaplus =  np.copy(parameters_values)                                       # Step 1
        thetaplus[i][0] = thetaplus[i][0] + epsilon                                   # Step 2
        J_plus[i], _ =  forward_propagation_n(X, Y, vector_to_dictionary(thetaplus))  # Step 3
        
        # Compute J_minus[i]. Inputs: "parameters_values, epsilon". Output = "J_minus[i]".
        thetaminus = np.copy(parameters_values)                                       # Step 1
        thetaminus[i][0] = thetaminus[i][0] - epsilon                                 # Step 2        
        J_minus[i], _ = forward_propagation_n(X, Y, vector_to_dictionary(thetaminus)) # Step 3
        
        # Compute gradapprox[i]
        gradapprox[i] = (J_plus[i] - J_minus[i]) / (2 * epsilon)
    
    # Compare gradapprox to backward propagation gradients by computing difference.
    numerator = np.linalg.norm(grad - gradapprox)                                     # Step 1'
    denominator = np.linalg.norm(grad) + np.linalg.norm(gradapprox)                   # Step 2'
    difference = numerator / denominator                                              # Step 3'

    if difference > 1e-7:
        print("\033[93m" + "There is a mistake in the backward propagation! difference = " + str(difference) + "\033[0m")
    else:
        print("\033[92m" + "Your backward propagation works perfectly fine! difference = " + str(difference) + "\033[0m")
    
    return difference
```

## 参考文献

1. 吴恩达. DeepLearning. 
2. 关治, 陆金甫. 数值方法. 清华大学出版社. 2017.