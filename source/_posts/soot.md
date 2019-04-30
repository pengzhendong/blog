---
title: Java 分析变换框架 Soot 的配置运行
date: 2017-03-18 19:33:48
updated: 2017-03-18 19:56:56
tags: Soot
---

## 前言

自学 Soot 也有好几个月了，确实难，没人带，自己折腾，全程靠自己 Google 和 Github。现在都不知道自己算是会几成，写点自己的体会，希望让别人少走点弯路。

<!-- more -->

## Soot

Soot  是一个 Java 程序分析和优化工具，具体的解释和使用在 Github 的[项目的 wiki](https://github.com/Sable/soot/wiki)中都有说明， 由于个人水平有限，这里只能大概说明一下一些圈内人认为很简单，但是新手一脸懵逼的东西。首先这个[生存手册](http://www.brics.dk/SootGuide/sootsurvivorsguide.pdf)不能不看, 这里面大概讲了一些 Soot 的运作过程和原理，结合着 wiki 一起看一定能事半功倍。

Soot 的 Main 函数分为好几个阶段，就像编译器一样，每个阶段进行不同的分析，最终得到结果。开发者可以直接使用 soot.Main 类；可以在这些阶段之中插入自己的分析；也可以不需要这些阶段自己使用 Soot 的一些数据结构编写分析代码。

所以 Soot 的运行方式大概有三种：

1. 设置 classpath 后通过命令行调用 soot.Main 的函数
2. 使用 Eclipse 插件，通过可视化的方式使用 Soot 的功能
3. 在 Java 项目中使用 Soot

## 命令行配置

生存手册里面的例子是 Soot `2.3.0`，版本比较旧，最新的 [release 版本](https://github.com/Sable/soot/releases) 是 `2.5.0`，只支持 Java 1.7 以下的版本。**soot-2.5.0.jar** 里面已经包括了开源的 Java 汇编器 **jasmin** 和多语言文本处理工具 **polyglot**。

如果下载的是 sootclasses 还需要像生存手册里那样下载那两个依赖工具，需要强调的是如果是使用 Windows 系统，一定要将 `:`  改成 `;`，Linux 系统的环境变量才是用冒号隔开。在命令行中使用 Soot 就是使用一个程序，并没有加入自己的分析，下面直接使用 **soot-2.5.0.jar** 演示生成 jimple 文件：

``` bash
$ java -cp soot-2.5.0.jar soot.Main -f J -cp .:/Library/Java/JavaVirtualMachines/jdk1.7.0_80.jdk/Contents/Home/jre/lib/rt.jar Main
```

从 wiki 了解到 Soot 有自己的 classpath，它只会从自己的 classpath 中加载 jar 文件和目录(经测试，它也可以从 Java 的 classpath 中加载文件)，同时 soot 运行的时候里面需要 **rt.jar**，这里面包含了 Java 常用的包，如java.lang，java.util等。

所以该命令就会将当前目录下的 `Main.java` 文件(就是一个打印 HelloWorld 的程序)转换成 `Main.jimple` 三地址代码：

``` java
public class Main extends java.lang.Object
{

    public static void main(java.lang.String[])
    {
        java.lang.String[] args;
        java.io.PrintStream temp$0;

        args := @parameter0: java.lang.String[];
        temp$0 = <java.lang.System: java.io.PrintStream out>;
        virtualinvoke temp$0.<java.io.PrintStream: void println(java.lang.String)>("Hello world");
        return;
    }

    public void <init>()
    {
        Main this;

        this := @this: Main;
        specialinvoke this.<java.lang.Object: void <init>()>();
        return;
    }
}
```

## Eclipse 配置

Github 项目的 [wiki](https://github.com/Sable/soot/wiki/Eclipse-Plugin-Installation) 讲的比较详细。Soot 插件只支持 Eclipse kepler 版本，安装了插件之后就能直接通过菜单进行操作，比较厉害的就是在空指针分析那一部分能够在结果上涂上不同的背景色，由于用的不是很深入，所以没找到其他更特别的。在 Eclipse 中也可以使用 Soot 的包进行开发编写自己的分析，但是我是 JetBrains 脑残粉。

## IDEA 配置

这应该是比较常用的方式，在 Java 项目中直接使用 Soot 的包进行开发。如果后期需要分析 Android 的代码，那么 release 版本还是不够的，需要下载 `nightly build` 版本, 也就是[每日构建版本](http://soot-build.cs.uni-paderborn.de/nightly/soot/) **soot-trunk.jar**，一上来如果有人告诉我这些我就不会走那么多弯路了。

新建一个 Java 项目，然后 `Project Structure` → `Project Settings` → `Libraries` 添加 **soot-2.5.0.jar**，配置完成，现在就可以在项目中使用 Soot 了。

``` java
public class Main {
    public static void main(String[] args) {
        soot.Main.main(new String[] {
                "tests.Main",
                "-f", "J"
        });
    }
}
```

IDEA 会自动为 Java 项目载入所有课能需要用到的包，`Project Structure` → `Platform Settings` → `SDKs` → `Classpath` 能查看详情。因为经测试 Soot 可以从 Java 的 classpath 中载入所需要的 jar 文件，所以这里并没有设置 Soot 的 classpath。这里的代码也是直接调用 soot.Main 来将程序转换成 jimple 文件。

## 总结

要学好 Soot 就必须通读文档，了解 Soot 的运作过程，特别是那几个阶段。这篇博客只是直接使用 Soot.Main 类来转换 jimple 文件。在接下来的分享中会涉及到数据流分析，就不需要运行那些阶段的分析，直接编写分析代码；生成程序 Call Graph 的分析就需要在 `cg` 阶段插入自己的分析。
