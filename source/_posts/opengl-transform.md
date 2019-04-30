---
title: OpenGL 图元的变换
date: 2016-01-05 08:22:03
updated: 2016-01-05 08:57:00
tags: OpenGL
mathjax: true
---

## 前言
OpenGL 中图元的变换就是图元的平移、旋转和缩放，对于每一种变换，OpenGL 都有自己的函数用来生成这些变换的矩阵并应用它们，使用模型变换，就可以完成物体的旋转和移动，并产生移动观察者的效果。

<!-- more -->

## 基础概念

在 OpenGL 中，为了区别三维坐标中的点和向量，引入了一个四维的概念，也就是其次坐标系， p = [x', y', z', w] 当 w = 0 时，p 代表一个向量，否则 p 是一个点。所有的标准变换都可以用四个向量组成的 4x4 矩阵的乘法来实现，单位矩阵就像乘法中的 “1”。另外，有个 **容易混淆** 的概念就是在 OpenGL 中，Z 轴是从屏幕里面指向外面的。

**单位矩阵**

$$
	\begin{align}
		M&=\begin{bmatrix}
		1 & 0 & 0 & 0 \\\ 
		0 & 1 & 0 & 0 \\\ 
		0 & 0 & 1 & 0 \\\ 
		0 & 0 & 0 & 1
		\end{bmatrix}
	\end{align}
$$

## 平移

调用glutSolidSphere()时，会在原点绘制一个球体。如果想在点 (0, 0.5, 0) 上绘制这个球体，就必须在绘制之前将坐标系沿+Y方向平移0.5个单位，于是我们会写出这样的代码：     

``` c
balabala;       //建立一个将坐标系沿+Y方向平移0.5个单位的矩阵 
balabala;       //用当前模型视图矩阵乘以这个矩阵
glutSolidSphere(0.5, 32, 32);  //绘制一个半径为0.5的球体
```

**平移矩阵**

$$
	\begin{align}
		T\_{(d\_{x}, d\_{y}, d\_{z})}&=\begin{bmatrix}
		1 & 0 & 0 & d\_{x} \\\ 
		0 & 1 & 0 & d\_{y} \\\ 
		0 & 0 & 1 & d\_{z} \\\ 
		0 & 0 & 0 & 1
		\end{bmatrix}
	\end{align}
$$

但事实上，我们不需要这么麻烦。OpenGL为我们提供了这样一个函数： `glTranslatef(x, y, z);` 其中，x, y, z 分别表示在 X、Y、Z 轴上平移的量。调用这个函数之后，OpenGL会自动生成一个平移矩阵，然后应用这个矩阵。因此，我们可以这样写代码：

``` c
glTranslatef(0, 0.5, 0);     
glutSolidSphere(0.5, 32, 32);
```

这样就能在(0, 0.5, 0)上绘制一个球体了。

<center><img src="https://s1.ax2x.com/2018/03/14/LACOY.png" width="300"></center>

## 旋转

与平移类似，OpenGL 也为我们提供了一个高级函数用于旋转物体：      `glRotatef(Angle, x, y, z);` 这个函数将生成并应用一个将坐标系以向量(x, y, z)为轴，旋转 Angle 个角度的矩阵。如果我们想将一个正方体以 Z 轴自转45度，就可以调用： `glRotatef(45.0, 0, 0, 1);`

``` c
glRotatef(45.0, 0, 0, 1);
glutSolidCube(1);
```

**旋转矩阵**

X 轴：

$$
	\begin{align}
		R_{x}(θ)&=\begin{bmatrix}
		1 & 0 & 0 & 1 \\\ 
		0 & cosθ & -sinθ & 0 \\\ 
		0 & sinθ & cosθ & 0 \\\ 
		0 & 0 & 0 & 1
		\end{bmatrix}
	\end{align}
$$

Y 轴：
$$
	\begin{align}
		R_{y}(θ)&=\begin{bmatrix}
		cosθ & 0 & sinθ & 0 \\\ 
		0 & 1 & 0 & 0 \\\ 
		-sinθ & 0 & cosθ & 0 \\\ 
		0 & 0 & 0 & 1
		\end{bmatrix}
	\end{align}
$$

Z 轴：
$$
	\begin{align}
		R_{z}(θ)&=\begin{bmatrix}
		cosθ & -sinθ & 0 & 0 \\\ 
		sinθ & cosθ & 0 & 0 \\\ 
		0 & 0 & 1 & 0 \\\ 
		0 & 0 & 0 & 1
		\end{bmatrix}
	\end{align}
$$

<center><img src="https://s1.ax2x.com/2018/03/14/LAKal.png" width="300"></center>

## 缩放

缩放变换其实是将坐标系的 x、y、z 轴按不同的缩放因子展宽，从而实现缩放效果。函数 `glScalef(x,y,z:Single);` 把坐标系的 X、Y、Z 轴分别缩放 x、y、z 倍。例如：      

``` c
glScalef(1.5, 1.5, 1.5);
glutSolidCube(1);
```
**缩放矩阵**

$$
	\begin{align}
		S\_{(B\_{x}, B\_{y}, B\_{z})}&=\begin{bmatrix}
		B\_{x} & 0 & 0 & 0 \\\ 
		0 & B\_{y} & 0 & 0 \\\ 
		0 & 0 & B\_{z} & 0 \\\ 
		0 & 0 & 0 & 1
		\end{bmatrix}
	\end{align}
$$

<center><img src="https://s1.ax2x.com/2018/03/14/LAtXB.png" width="300"></center>