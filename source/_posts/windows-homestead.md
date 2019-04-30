---
title: Windows 环境下搭建 Laravel 开发环境 Homestead
date: 2016-05-07 14:11:48
updated: 2016-05-07 14:54:49
tags: Homestead
---

## 前言

唉，一早上到现在也没吃饭，就为了折腾这 Windows 下的 Laravel 开发环境，主要是为了让组员的机器能跑这次的 XML 课设，顺便记录一下再去吃午饭吧！

<!-- more -->

## 下载

* VirtualBox [官方下载链接](https://www.virtualbox.org/wiki/Downloads)，下载完毕直接安装
* Vagrant [官方下载链接](https://www.vagrantup.com/downloads.html)，下载完毕直接安装
* 封装包 Homestead.box [百度网盘](https://pan.baidu.com/s/1hrN55w4#list/path=%2FHomesteadBoxes)
* Git [官方下载链接](https://git-scm.com/downloads)，下载完毕直接安装，使用教程看前几篇博客

## 添加封装包

``` bash
$ vagrant box add laravel/homestead https://atlas.hashicorp.com/laravel/boxes/homestead
```

由于国内的网实在是太慢，而且经常下一半就卡掉，所以只好单独将它下载下来再添加，一开始用迅雷下的时候，文件名显示 **vitrualbox.box** ，后来才发现并不能用，网上有人说不能用迅雷下，然而答案并不是这样，正确的做法是这样的(以下载 `v0.4.4` 为例)：

官网下载链接：https://atlas.hashicorp.com/laravel/boxes/homestead/versions/0.4.4/providers/virtualbox.box

1. 如果直接用迅雷下载就会发现下载的文件是 `virtualbox.box`
2. 将下载链接粘贴到浏览器中下载，显示下载文件名 `hc-download`，可以发现链接变成了下面所示，这时候就可以复制到迅雷中去了：

```
https://binstore-test.hashicorp.com/7b0beed8-f399-4f35-90b0-03ad6da64e40
```

这个方法还是很恶心，下载一大半的时候，网速正常，进度条不动~

所以还是直接用我提供的封装包吧，那是我辛辛苦苦下载好改名传到360云盘中的，下载完毕后执行以下命令：

``` bash
$ vagrant box add laravel/homestead /Path/to/Homestead.box
```

## 安装 Homestead

``` bash
$ git clone https://github.com/laravel/homestead.git Homestead
```

Homestead 已经帮你写好了配置文件，只需要修改以下就好了，在 Homestead 目录中执行下面命令在根目录下的 `.homestead` 文件夹中生成配置文件 `Homestead.yaml`：

``` bash
$ bash init.sh
```

### 生成 SSH 密钥

``` bash
$ ssh-keygen -t rsa -C "you@homestead"
```

### 修改配置文件

#### 配置密钥

```
authoriza: /C/Users/Path/to/.ssh/id_rsa.pub
```

#### 配置共享文件夹

```
folders:
	- map: /Path/to/Code
	  to: /home/vagrant/Code
```

## 启动封装包

``` bash
$ vagrant up
```

一开始我在 `Homestead` 文件夹中使用这个命令的时候命令行又重新下载封装包，我猜可能是版本不对，于是到根目录下的 `.vagrant.d/boxes/laravel-VAGRANTSLASH-homestead` 中将 `0` 这个文件夹改成 `0.4.4`，然后再次启动，提示手动添加的封装包不能改版本，于是改回来，再试一次居然成功了。

(原因：原来是 Homestead 对 box 的版本号有要求 >= 0.4.0，手动添加的版本号默认是0，所以它会以为这个不是最新版，然后尝试去下载最新版本，至于为什么改了两次文件夹名之后就好了，等我发现答案再说吧)

**其他解决方法**

创建 `metadata.json` 文件指明 box 的版本号([Stackoverflow](http://stackoverflow.com/questions/34946837/box-laravel-homestead-could-not-be-found))，这个文件放在 box 同一目录下.

```
{
    "name": "laravel/homestead",
    "versions": [{
        "version": "0.4.4",
        "providers": [{
            "name": "virtualbox",
            "url": "file://homestead.box"
        }]
    }]
}
```

执行以下命令后再启动封装包：

``` bash
$ vagrant box add metadata.json
```

### 连接虚拟机

``` bash
$ vagrant ssh
```

进去之后可以看到该目录下就有刚刚配置的共享文件夹 `Code`。

## Zsh

如果觉得界面不好看，我们可以通过安装 Zsh 来替换默认的 shell：

### 安装

``` bash
$ sudo apt-get install zsh
```

### 修改默认 Shell

``` bash
$ chsh -s /bin/zsh
```

该命令需要输入当前用户密码，vagrant 用户默认当前密码为 `vagrant`。

### 安装 oh-my-zsh

oh-my-zsh 是一个开源的用来管理 Zsh 配置的社区驱动框架。

``` bash
$ git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
$ cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
```

以上命令下载 oh-my-zsh 并将配置文件复制一份到根目录下，修改 `.zshrc` 文件的默认主题为 `ys`：

``` bash
ZSH-THEME="robbyrussell"
```

``` bash
ZSH-THEME="ys"
```

重启虚拟机，进入后就可以看见新世界啦~~

![](https://s1.ax2x.com/2018/03/14/L1Hj9.jpg)

## 修改系统时区

``` bash
$ cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

## 使用 homestead 和 serve 命令

``` bash
$ composer global require "laravel/homestead=~2.0"
```

安装 `homestead` 命令后，编辑根目录下的 `.zshrc` 文件，加入以下脚本代码：

``` 
export PATH="~/.composer/vendor/bin:$PATH"
source ~/.bashrc
```

执行：

``` bash
$ source .zshrc
```

就可以使用 `serve` 和 `homestead` 命令了。