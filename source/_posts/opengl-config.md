---
title: OpenGL 的环境配置和图元的绘制
date: 2016-01-04 22:29:10
updated: 2016-01-04 22:58:46
tags: OpenGL
---

## 前言

距离上一篇博客已经过去一个半月了，这段时间过得确实充实，虽然一大段时间泡在图书馆复习，但至少也能学到点东西。跨年晚和元旦一整天，全身心投入图形学小课设的编程，终于实现了老师要求的所有功能，回想起张勇老师理论课的作业，我就上网下了一个程序，然后答辩的时候还半懂不懂，真是不该。

<!-- more -->

## 环境配置

### Visual Studio 2013
如果不想麻烦地每次都为项目链接 glut 的库和设置环境变量，到[OpenGL官网](http://www.opengl.org/resources/libraries/glut)下载对应的所需文件。

* 解压后将得到的glut.lib和glut32.lib这两个静态函数库复制到文件目录的lib文件夹下 `X:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\lib` ；
* 将glut.dll,glut32.dll这两个动态库文件放到操作系统目录下面的 `C:\Windows\system32` 文件夹内（32位系统）或 `C:\Windows\SysWOW64` (64位系统），为了兼容性考虑，最好在这两个目录下都复制相应的文件；
* 将解压得到的头文件glut.h复制到目录如下目录下：`X:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\include\GL` ，如果在incluce目录下没有GL文件夹，则需要手动创建。

### Xcode
新建 C 语言控制台程序之后，点击项目->Build Phases->Link Binary With Libraries，将 GLUT.framework 和 OpenGL.framework 连接到项目中去就可以了(感觉是不是比 VS 的方便好多~)。

## 绘制图元

``` c
#include <stdio.h>
#include <stdlib.h>
#include <GLUT/glut.h>
#include <math.h>

void display()
{
    glClear(GL_COLOR_BUFFER_BIT); //清除颜色,否则背景中会出现一些奇怪的东西
    glBegin(GL_POLYGON);
        glVertex2f(-0.5, 0.5);
        glVertex2f(0.5, 0.5);
        glVertex2f(0.5, -0.5);
        glVertex2f(-0.5, -0.5);
    glEnd();
    glFlush();

}

int main(int argc, const char * argv[]) 
{
    glutInit(&argc, argv);
    glutInitWindowPosition(100,100);    //窗口位置
    glutInitWindowSize(400,400);        //窗口大小
    glutCreateWindow("第一个OpenGL程序"); //创建窗口，设置标题
    glutDisplayFunc(display);           //当绘制窗口时调用display
    glutMainLoop();
    return 0;
}
```
  
在上面 display 函数代码中我通过制定4个顶点来画一个矩形，有个更加快捷的方法就是直接调用库里面的函数 `glRectf(-0.5f,-0.5f,0.5f,0.5f);` ，两种方法的结果一样，但是如果学到后面要对物体进行贴图的话就只能用第一种方法了，因为 glRect 函数并不会返回顶点的坐标。