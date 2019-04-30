---
title: Zsh + Terminus 配置
date: 2019-01-18 10:36:16
updated: 2019-01-18 11:21:22
tags: Linux
---

## 前言

一直觉得 Linux 自带的终端很难用，因此所有 *Unix 设备都用上了 Zsh。由于不具备服务器管理员权限，因此在服务器中只能通过编译源代码进行安装，同时结合 Terminus 打造一个超级酷的终端界面！

<!-- more -->

## Zsh

Zsh 的命令提示、命令补全和历史记录等功能极其强大，加上 Oh My Zsh 主题配置和插件机制等便捷操作，可以说是终端中的极品。首先使用以下命令下载和解压缩 Zsh 源代码：

``` bash
$ wget -O zsh.tar.xz https://sourceforge.net/projects/zsh/files/latest/download
$ tar -xvf zsh.tar.xz
```

进入解压缩后的目录，在 `make` 之前对其进行配置安装目录，可能需要执行的权限：

``` bash
$ chmod 777 configure
$ ./configure --prefix=$HOME/usr/
$ make
$ make install
```

源代码编译安装的 Zsh 不会自动配置环境变量，所以还需要添加环境变量，方便后续安装 oh-my-zsh 配置；同时由于不具备管理员权限，安装的 Zsh 无法添加到 `/etc/shells`，因此无法通过 `chsh` 命令切换！所以依旧使用 Bash，而在 `.bashrc` 中运行 Zsh。因此需要在 `.bashrc` 中添加以下内容：

``` bash
export PATH="$HOME/usr/bin/zsh"
exec $HOME/usr/bin/zsh
```

这里值得注意的是使用了 `exec` 命令来启动 Zsh 而不是 `source` 命令，后者会创建新的进程而前者会用新的命令替换当前进程的上下文，因而保持 PID 不变。

### Oh My Zsh

下载 Oh My Zsh 安装脚本并且使用 Bash 进行安装：

``` bash
$ sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
$ bash install.sh
```

## Terminus

之前一直使用 PuTTY 远程连接服务器，但是装完 Oh My Zsh 后发现有些符号的显示并不是很好，简直逼死强迫症。例如下图中的 <font color='green'>→</font>

![](https://s1.ax2x.com/2019/01/18/5j97pd.jpg)

于是尝试使用昨天师弟推荐的 Terminus，发现很有极客风格，与 Zsh 搭配起来效果真的太棒了！

![](https://s1.ax2x.com/2019/01/18/5j92De.jpg)

前端有点像 Atom，更强大的是还可以使用本地的终端，而且可以安装各种插件。PuTTY 再见！

![](https://s1.ax2x.com/2019/01/18/5jDLEY.jpg)

