---
title: String VS StringBuffer
date: 2016-01-26 22:10:24
updated: 2016-01-26 22:28:28
tags: Java
---

## 前言
这两天闲的无聊，所以想趁这段时间把蓝桥杯官网的习题温习一下，毕竟不能再打无准备之战，今天写十六进制转八进制的时候代码功能完全没问题，但是测评状态一直显示运行超时，代码中循环的比较多的也就是对字符串的操作，然后上网搜了一下 String  类的相关知识，然后将代码中的 String 全部改成 StringBuffer，果然没问题了。

<!-- more -->

## String

> String类是不可改变的，所以你一旦创建了String对象，那它的值就无法改变了。 如果需要对字符串做很多修改，那么应该选择使用StringBuffer & StringBuilder 类。

所以每次对 String 类型进行改变的时候其实都相当于生成了一个新的 String 对象，然后将指针指向新的 String 对象，每次生成对象都会对系统性能产生影响，特别当内存中无引用对象多了以后， JVM 的 GC 就会开始工作，那速度是一定会特别慢。

## StringBuffer

> 和 String 类不同的是，StringBuffer 和 StringBuilder 类的对象能够被多次的修改，并且不产生新的未使用对象。

Java 5中提出 StringBuilder，它和 StringBuffer 之间的最大不同在于 StringBuilder 的方法不是线程安全的（不能同步访问）。
由于 StringBuilder 相较于 StringBuffer 有速度优势，所以多数情况下建议使用 StringBuilder 类。然而在应用程序要求线程安全的情况下，则必须使用 StringBuffer 类。

## 比较结果

``` java
public class Main {

    public static void main(String[] args) {
        double start = System.currentTimeMillis() ;

        String str = "";
        for (int i = 0; i < 1000; i++) {
            str += "pengzhendong";
        }

        double end = System.currentTimeMillis() ;
        System.out.println("Runtime is : " + (end - start) + " ms");
    }
}
```

### 运行结果

``` bash
Runtime is : 54.0 ms
```

``` java
public class Main {

    public static void main(String[] args) {
        double start = System.currentTimeMillis() ;

        StringBuffer str = new StringBuffer("");
        for (int i = 0; i < 1000; i++) {
            str.append("pengzhendong");
        }

        double end = System.currentTimeMillis() ;
        System.out.println("Runtime is : " + (end - start) + " ms");
    }
}
```

### 运行结果

``` bash
Runtime is : 1.0 ms
```

运行结果超级明显，才循环 1000 遍，运行时间就相差了 53 毫秒，面对测评系统里面上十万的数据，不运行超时才怪啊！

