---
title: VirtualBox 共享文件夹中的符号链接
date: 2018-05-16 10:13:00
updated: 2018-05-16 10:21:10
tags: Linux
---

## 前言

学完了神经网络却不知道怎么写神经网络的博客，因为内容太多了，自己也不太熟，说不太清楚。那就还是先做做实验吧！毕业要紧，毕业要紧。做实验过程中遇到点小问题，记录一下，顺便补充补充 Linux 基础。

<!-- more -->

在做实验的时候需要用到 Linux 系统，懒得再安装配置一个新系统，于是就直接在 Windows 中的 `Homestead` 上搞起来。但是在初始化数据集的时候报错了。

``` bash
ln: failed to create symbolic link '/home/.../xxx': Protocol error
```

在 VirtualBox [官网](https://www.virtualbox.org/manual/ch04.html#sharedfolders)上找到的答案是：

> For security reasons the guest OS is not allowed to create symlinks by default. If you trust the guest OS to not abuse the functionality, you can enable creation of symlinks for "sharename" with:

``` bash
VBoxManage setextradata "VM name" VBoxInternal2/SharedFoldersEnableSymlinksCreate/sharename 1
```

 VirtualBox 默认关闭创建符号链接的功能，4.0 以后的版本通过以上命令可以启用；同时，在每次启动虚拟机的时候需要在 Windows 中以超级管理员的权限启动。

官网中说只有 Linux 或者 Solaris 才支持符号链接，但是 Windows 7 及以上的系统在超级管理员权限下，可以使用 `$ mklink my-link filename` 创建符号链接。官网的意思可能是在  Linux 中创建的符号链接并不是 Windows 中的那种格式！由于实验一直在 guest 中进行，所以也就没有关系。

## 链接文件

Linux 系统提供 `ln` 命令创建文件链接，文件链接主要分为**硬链接**和**符号链接**(软连接)。链接不但节省空间，而且对一个文件的更改会自动反映在所有链接的文件中，软链接类似于 Windows 系统中的 Shortcut (快捷方式)。

![](https://s1.ax2x.com/2018/05/16/xuabz.jpg)

### 硬链接

``` bash
$ ln myfile.txt my-hard-link
```

创建硬链接后，它会指向源文件的 `inode` ，它和源文件是等价的。所以所有的文件至少有一个硬链接，删除的时候只会删除链接，不会删除文件。文件的属性里还有一个计数器记录它的硬链接数，值为 0 时系统则删除该文件的 inode。硬链接和源文件必须在同一个分区中且不能引用目录。

### 符号链接

``` bash
$ ln -s myfile.txt my-soft-link
```

符号链接也叫软链接，它包含一条以绝对路径或者相对路径的形式指向其他文件或者目录的引用。如果指向的目标文件被移动、重命名或者删除，那么该目标文件的所有软连接都会指向一个不存在的文件，也成为坏链接(Ubuntu 中使用 ls -al 命令，软连接会以蓝色显示，坏链接会以红色显示)。

![](https://s1.ax2x.com/2018/05/16/xuNKd.png)

### Junction point

Junction point 是 **NTFS** 文件系统中链接目录的软链接，不能跨主机。