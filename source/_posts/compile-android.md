---
title: Ubuntu 14.04 编译 Android 4.3
date: 2017-02-23 13:24:20
updated: 2017-02-23 14:45:54
tags: [Linux, Android]
---

## 前言

编译 Android 源代码实在是有太多坑了，不管是 JDK 版本还是各种依赖，都让人头疼，最后按照官网推荐的配置加上报错的提示终于把虚拟机跑起来了。

<!-- more -->

## 环境要求
根据 Android 官网的 [编译要求](https://source.android.com/source/requirements.html) 知道，在编译 Android 源代码时，对硬件和软件都有要求

### 硬件要求

* 编译 Android ２.3.x　至 AOSP master　需要 64 位的机器，低版本可使用 32　位机器
* 至少需要 100 GB 的硬盘空间
* 如果使用虚拟机进行编译，需要 16 GB 的 RAM/swap

### 软件要求

#### 操作系统

在 AOSP 开源中，主分支使用 Ubuntu 长期版进行开发和测试，下面都是基于 Ubuntu 14.04 说明软件要求。

| Android版本                           | 系统最低版本 　　|
| ------------------------------------ | ----------------- |
| Android 6.0 至 AOSP master　| Ubuntu 14.04 |
| Android 2.3.x 至 Android 5.x | Ubuntu 12.04 |
| Android 1.5 至 Android 2.2.x | Ubuntu 10.04 |

### Java Development Kit (JDK)

由于 Taintdroid [官网](http://www.appanalysis.org/download.html)目前支持的 Android 最新版本是 `Android 4.3 (updated Jan 22, 2013)`，所以应该安装 Java JDK 6

| Android版本                              | JDK版本 　　   |
| -------------------------------------- | -------------- |
| AOSP master                           　| [OpenJDK 8](http://openjdk.java.net/install/) |
| Android 5.x 至 android 6.0       | [OpenJDK 7](http://openjdk.java.net/install/) |
| Android 2.3.x 至 Android 4.4.x | [Java JDK 6](http://www.oracle.com/technetwork/java/javase/archive-139210.html) |
| Android 1.5 至 Android 2.2.x    | [Java JDK 5](http://www.oracle.com/technetwork/java/javase/archive-139210.html) |

通过 ppa 方式下载并自动安装的 JDK 都会被安装到 `/usr/lib/jvm` 目录下，然后被 `update-alternatives` 软链接到 `/usr/bin/java`，所以不用单独设置环境变量也能直接使用。但是 Oracle JDK 6 只能到[官网](http://www.oracle.com/technetwork/java/javase/downloads/java-archive-downloads-javase6-419409.html#jdk-6u45-oth-JPR)下载： `jdk-6u45-linux-x64.bin`，所以推荐也放到 `/usr/lib/jvm` 中

``` bash
$ sudo chmod 777 jdk-6u45-linux-x64.bin
$ sudo ./jdk-6u45-linux-x64.bin
$ sudo mv jdk1.6.0_45 /usr/lib/jvm
```

然后可以通过设置环境变量或者 `update-alternatives` 软链接的方式切换 JDK 版本，设置环境变量的话记得 `$JAVA_HOME/bin` 要在 `/usr/bin` 前面，这里使用 `update-alternatives` 软链接的方式设置：

``` bash
$ sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk1.6.0_45/bin/java 600
$ sudo update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk1.6.0_45/bin/javac 600
$ sudo update-alternatives --install /usr/bin/jar jar /usr/lib/jvm/jdk1.6.0_45/bin/jar 600
$ sudo update-alternatives --install /usr/bin/javadoc javadoc /usr/lib/jvm/jdk1.6.0_45/bin/javadoc 600
```

最后一个参数是优先级，在自动模式下话自动选择优先级最高的，这里使用手动模式所以随便设置一个优先级，如果还有其他版本的话还需通过以下命令选择版本

``` bash
$ sudo update-alternatives --config java
$ sudo update-alternatives --config javac
$ sudo update-alternatives --config jar
$ sudo update-alternatives --config javadoc
```

最后通过查看版本信息

<center><img src="https://s1.ax2x.com/2018/03/14/LU98S.png" width="500"/></center>

#### Key Packages

* Python 2.6 - 2.7
* GUN Make 3.81 - 3.82 (Ubuntu 14.04 自带版本为3.8.1)
* Git 1.7 或者更新的版本

#### Required packages

在 Android 官网的[构建编译环境指南](https://source.android.com/source/initializing.html)中，提供了各个版本 Ubuntu 需要安装的 required packages

``` bash
$ sudo apt-get install git-core gnupg flex bison gperf build-essential \
  zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 \
  lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev ccache \
  libgl1-mesa-dev libxml2-utils xsltproc unzip libswitch-perl
```

## 下载 Android 源代码

### repo 工具下载及安装

repo 工具由一系列 Python 脚本组成，通过调用 Git 命令实现对 AOSP 项目的管理

``` bash
$ mkdir ~/bin
$ PATH=~/bin:$PATH
$ curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
$ chmod a+x ~/bin/repo
```

### 获取源代码

因为 TaintDroid 使用的是 Android 源代码的 "android-4.3_r1" 标签，所以

``` bash
$ mkdir -p ~/tdroid/tdroid-4.3_r1
$ cd ~/tdroid/tdroid-4.3_r1
$ repo init -u https://android.googlesource.com/platform/manifest -b android-4.3_r1
$ repo sync
# 防火墙的原因导致 repo sync 缓慢或者不能同步，可以使用科大的镜像
# $ curl https://storage-googleapis.proxy.ustclug.org/git-repo-downloads/repo > repo
```

`repo` 同步的源码都记录在一个清单文件 manifest.xml 中(其实它知识一个到 `.repo/manifests/default.xml` 的文件链接)，它描述了源代码的结构(各个 git 库的地址和版本)，所以同步源代码之前先用清单文件初始化仓库。

如果还是无法下载就需要修改 `～/bin/repo` 文件中的 `REPO_URL` 的值为

```
REPO_URL= 'https://gerrit-googlesource.proxy.ustclug.org/git-repo'
```

然后再执行 `$ repo sync` 命令同步代码，大概有 40+ GB。

## 编译

为了确保当前环境没有问题，对源代码进行编译

### 初始化编译环境

``` bash
$ cd ~/tdroid/tdroid-4.3_r1/build
$ chmod +x envsetup.sh
$ ./envsetup.sh
$ source envsetup.sh
```

如果使用 Ubuntu 16.04 或者使用其他 shell，这里还会出现一些别的问题，可根据提示解决

### 编译源码

#### 选择编译目标

编译目标格式： `BUILD-BUILDTYPE`

| Buildtype | Use 　　   |
| --------- | --------- |
| user      | limited access; suited for production |
| userdebug | like "user" but with root access and debuggability; preferred  for debugging |
| eng       | development configuration with additional debugging tools |

通过 lunch 命令设置编译目标，编译目标就是生成的镜像要运行在什么样的设备上，由于没有 Nexus 设备，所以选择 `1. aosp_arm-eng` 也就是 Android 模拟器

``` bash
$ cd ~/tdroid/tdroid-4.3_r1
$ lunch 1
```

#### 执行编译

通过 make 命令进行代码编译，通过 -j 参数编译的线程数以提高编译速度，一般设置为 cup 的核数的两倍(cpu 核数可通过 `$ cat /proc/cpuinfo` 查看)

``` bash
$ make -j4
```

看到以下输出就是成功编译完成了

```
Install system fs image: out/target/product/generic/system.img
```

### 运行虚拟机

如果编译完成后想立刻启动虚拟机，则直接输入以下命令，否则还要再次运行 `source` 命令初始化环境和 `lunch` 命令选择编译目标

``` bash
$ emulator
```

<center><img src="https://s1.ax2x.com/2018/03/14/LUBHh.png" width="500"/></center>