---
title: Junit4 使用文件输入流和获取输出流
date: 2016-07-09 14:14:48
updated: 2016-07-09 14:53:45
tags: [Java, Junit]
---

## 前言

使用 Junit 对 Java 控制台程序测试的时候，如果程序要有用户输入，很多时候会需要将输入写在文件中；并且还需要获取控制台输出的内容作为输出结果与期待的结果进行比较。

<!-- more -->

最近在为夏令营准备，所以要到 [openjudge](http://openjudge.cn) 中刷一下题，openjudge 有些题居然提供测试用例所有数据!!!刷到一道特别简单的题但就是过不去的情况下(看不出结果有什么问题)，于是想着做个单元测试，利用 Idea 的单元测试结果中下面这个功能来看看到底什么地方出了问题。

<center>![](https://s1.ax2x.com/2018/03/14/LKcme.png)</center>

## 下载 Jar 包

由于需要读取期待的运行结果作为 expected 的值与实际运行结果比较，所以可以下载 [org.apache.commons.io.jar](http://www.java2s.com/Code/Jar/o/Downloadorgapachecommonsiojar.htm) 这个Jar 包直接调用 `toString()` 函数即可。当然也可以自己实现读取文件返回字符串的函数。

## Junit 代码

几乎每行代码都已经详细说明用途，其中的还原系统输入输出流只是为了不给 Bug 提供机会，用过的环境就要给它还原。

``` java
import org.apache.commons.io.IOUtils;
import java.io.*;
import static org.junit.Assert.*;

/**
 * Created by pengzhendong on 7/8/16.
 */
public class MainTest {
    InputStream consoleIn = null;                       // 输入流 (字符设备) consoleIn, 用于还原输出入流
    PrintStream consoleOut = null;                      // 输出流 (字符设备) consoleOut, 用于还原输出流
    ByteArrayOutputStream bytes = null;                 // 用于缓存 console 重定向过来的字符流
    String excepted = null;                             // 期待的结果

    @org.junit.Before
    public void setUp() throws Exception {
        this.consoleIn = System.in;                     // 获取 System.in 输出流的句柄
        this.consoleOut = System.out;                   // 获取 System.out 输出流的句柄

        FileInputStream in = new FileInputStream("./src/in.txt");
        System.setIn(in);                               // 将文件输入流作为系统的输入

        this.bytes = new ByteArrayOutputStream();       // 实例化
        System.setOut(new PrintStream(bytes));          // 将原本输出到控制台 console 的字符流重定向到 bytes

        FileInputStream out = new FileInputStream("./src/out.txt");
        this.excepted = IOUtils.toString(out, "UTF-8"); // 调用 Jar 包中的 toString() 函数, 得到期待的结果
    }

    @org.junit.Test
    public void main() throws Exception {
        Main.main(null);                                // 运行函数, 自动读取 setUp 函数中的 in 输入流
        assertEquals(excepted, this.bytes.toString());  // 对比程序运行结果和期待的结果
    }

    @org.junit.After
    public void tearDown() throws Exception {
        System.setIn(consoleIn);                        // 还原输入流
        System.setOut(consoleOut);                      // 还原输出流
    }
}
```

如果运行失败，就能够点击 Click  to see difference 来查看到底程序的运行结果哪里不对了。

## 运行结果

![](https://s1.ax2x.com/2018/03/14/LKLDr.png)

好吧，原来是空格的格式不一致的问题，这种问题人眼当然就看不出来啦~