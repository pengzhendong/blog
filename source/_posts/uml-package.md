---
title: UML：包图(Package)
date: 2016-04-10 10:00:48
updated: 2016-04-10 10:18:19
tags: UML
---

## 前言

包图类似于 C++ 和 Php 的命名空间，Java 的包，一个复杂的程序往往包括数百个类，管理它们的有效方法就是分类，将相关的类组织在一起。包图是维护和控制系统总体结构的重要建模工具。

<!-- more -->

## 包图

包图(Package)是在 UML 中用类似于文件夹的符号表示的模型元素的组合。系统中的每个元素都只能为一个包所有，一个包可嵌套在另一个包中。使用包图可以将相关元素归入一个系统。一个包中可包含附属包、图表或单个元素。

如果有两个类A类和B类都含有一个具有相同的方法method()，即便在同一段代码中同时使用这两个方法，也不会发生冲突，原因就在于有两个不同的类名在前面作为限定名，所以两个方法即便同名也不回发生冲突。但是如果类名称相互冲突又该怎么办呢？

### Java Package

``` java
package cn.pengzhendong.Person;

public class Student {
}
```

某个类使用 `package xxx` 就是将这个类包含到 xxx 包中，为了创建独一无二的包名称，名称的第一部分是类的创建者的反顺序的Internet域名。

<img src="https://s1.ax2x.com/2018/03/14/L1ywG.png" width="400">

#### 使用

1. 使用关键字`import`导入包
2. 使用完整限定名称

``` java
import cn.pengzhendong.Person.Student;

public class Main {
    public static void main(String[] args) {
        Student student = new Student();
    }
}
```

``` java
public class Main {
    public static void main(String[] args) {
        cn.pengzhendong.Person.Student student = new Student();
    }
}
```

### 包的可见性

用来控制包外元素对包内元素的访问权限

* public +：该包中所有元素可见和
* protected #：该包中元素仅对当前包的子包可见
* private -：报包中元素仅能被同一包中元素访问

![](https://s1.ax2x.com/2018/03/14/L1EV2.png)

### 包之间的关系

* 引入（import）：是最普遍类型的包的依赖关系客户（源）包的元素能单向访问提供者（目的）包的所有公共元素
* 输出（export）：包的共有部分（“+”）

**注意**：
引用和访问是不传递的
引入关系会使得命名空间合并，出现命名冲突

![](https://s1.ax2x.com/2018/03/14/L1Lya.png)

