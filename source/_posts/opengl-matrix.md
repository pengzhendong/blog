---
title: glPushMatrix() 和 glPopMatrix() 函数的使用
date: 2016-01-22 16:43:37
updated: 2016-01-22 17:38:39
tags: OpenGL
---

## 前言

回家已经呆了三天了，正好将上学期学习的知识点巩固一下，记录一下自己在编程过程中遇到的问题，**glPushMatrix()** 和 **glPopMatrix()** 在 OpenGL 中的作用这个问题已经困扰了我好久了，由于一直没有得到解决也就没记录，今天动手尝试着了解一下，果然豁然开朗。

<!-- more -->

## 基础知识

* 马尔科夫性：过程(或系统)在时刻 t<sub>0</sub> 所处的状态为已知的条件下，过程在时刻 t > t<sub>0</sub> 所处状态的条件分布与过程在时刻 t<sub>0</sub> 之前所处的状态无关的特性称为马尔科夫性。
* 马尔科夫过程：具有马尔科夫性的随机过程称为马尔科夫过程。
* **glMatrixMode()** 设置当前矩阵模式。

	> void glMatrixMode（GLenum mode） 

	* GL_MODELVIEW, 对模型视景矩阵堆栈应用随后的矩阵操作
	* GL_PROJECTION, 对投影矩阵应用随后的矩阵操作
	* GL_TEXTURE, 对纹理矩阵堆栈应用随后的矩阵操作
* **glLoadIdentity()** 重置当前指定的矩阵为单位矩阵，一般选择完矩阵模式之后都要将矩阵初始化为单位矩阵。

## 建模

OpenGL 物体建模：

* 在世界坐标系的原点位置绘制出该物体；
* 通过 modelview(上次modelview变换后物体在世界坐标系下的位置是本次modelview变换的起点) 变换矩阵对世界坐标系原点处的物体进行仿射变换，将该物体移动到世界坐标系的目标位置处。
* 凡是使用glPushMatrix()和glPopMatrix()的程序一般可以判定是采用世界坐标系建模。既世界坐标系固定，modelview矩阵移动物体。

### glPushMatrix()

> void glPushMatrix(void)

把当前堆栈中的所有矩阵都下压一级。当前矩阵堆栈是由 glMatrixMode() 函数指定的。这个函数复制当前的顶部矩阵，并把它压入栈中。因此，堆栈最顶部的两个矩阵的内容相同。如果压入的矩阵太多，这个函数会导致出错。

### glPopMatrix()

> void glPopMatrix(void)

把堆栈顶部的那个矩阵弹出堆栈，销毁被弹出的矩阵内容。堆栈原先的第二个矩阵成为顶部矩阵。当前矩阵是由 glMatrixMode() 函数指定的。如果堆栈只包含了一个矩阵，调用 glPopMatrix() 将会导致错误。

## 运行结果

``` c
void Display(void)
{
    glClear(GL_COLOR_BUFFER_BIT);
    glColor3f(0.0f, 1.0f, 0.0f);
    
    glPushMatrix();
    	glTranslatef(0.5f,0.0f,0.0f);
    	glRectf(-0.2f, 0.2f, 0.2f, -0.2f);
    glPopMatrix();
    
    glRectf(-0.2f, 0.2f, 0.2f, -0.2f);

    glFlush();
}
```

通过 glPushMatrix() 和 glPopMatrix() 对前一个矩形进行变换，所以画第二个矩形的时候，前一个变换并不会影响第二个矩形。

<img src="https://s1.ax2x.com/2018/03/14/LAseu.png" width="300">

``` c
void Display(void)
{
    glClear(GL_COLOR_BUFFER_BIT);
    glColor3f(0.0f, 1.0f, 0.0f);
    
    glTranslatef(0.5f,0.0f,0.0f);
    glRectf(-0.2f, 0.2f, 0.2f, -0.2f);
    
    glRectf(-0.2f, 0.2f, 0.2f, -0.2f);

    glFlush();
}
```

不使用 glPushMatrix() 和 glPopMatrix() 函数，所以第二个矩形是在第一个矩形变换之后的矩阵上画的，两个矩形重合。

<img src="https://s1.ax2x.com/2018/03/14/LAJ0A.png" width="300">