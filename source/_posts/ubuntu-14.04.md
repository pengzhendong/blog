---
title: Ubuntu 14.04 环境配置
date: 2017-02-22 16:24:00
updated: 2017-02-22 17:26:15
tags: Ubuntu
---

## 前言

由于论文需要，要在 Ubuntu 上编译 Android 源代码。一开始没仔细看 Android 官网要求，装了 Ubuntu 16.04，后来遇到各种依赖问题，只能重新安装 Ubuntu 14.04，记录一下过程和一些常用软件的安装。

<!-- more -->

## 系统安装

虚拟机性能太差，直接选择双系统，这里选择 U 盘安装的方式安装，首先到磁盘管理中压缩出足够大的空间用来安装 Ubuntu，由于要编译 Android 源代码，直接压出 200 GB

### 工具

* Ubuntu 14.04 [64 位镜像](http://releases.ubuntu.com/14.04/ubuntu-14.04.5-desktop-amd64.iso)
* 光盘映像文件制作工具 [UltraISO](http://cn.ultraiso.net/xiazai.html)
* 系统引导工具 [EasyBCD](https://neosmart.net/EasyBCD/)

### 制作启动盘

1. 插入 U 盘，打开 UltraISO --> 文件(F) --> 打开...
2. 选择下载的 Ubuntu 14.04 镜像文件
3. 启动(B) --> 写入硬盘映像... --> 写入

这时候 U 盘就是启动盘了，重启电脑并且设置 Boot 优先级顺序，将 USB 移到前面(下次重启的时候手动还原，以免以后插着普通 U 盘无法开机)，重启电脑

### 安装过程

1. 安装 Ubuntu，继续
2. 选中`安装中下载更新`和`安装第三方软件`，继续
3. 安装类型选为`其他选项`(手动分配磁盘空间)，继续
4. 选中压缩好的空闲磁盘，点击左下角的加号分配磁盘
	* `/`(主分区): 存放系统文件，16384 MB
	* `swap`(逻辑分区): 虚拟内存为物理内存 * 2，16384 MB
	* `/boot`(逻辑分区): 存放系统启动文件，200 MB
	* `/home`(逻辑分区): 家目录，剩下所有的空间
5. 安装启动引导器的设备选择 `/boot` 对应的盘符
6. 设置位置 `Shanghai`，也就是时区为 UTC+8，继续
7. 键盘布局默认，继续
8. 设置姓名、计算机名和密码，继续
9. 现在重启(记得把 U 盘拔出来或者把 Boot 还原回去)

### EasyBCD 设置引导

1. 打开 EasyBCD --> 添加新条目 --> Linux/BSD --> 选择驱动器为 `/boot` 对应的分区(大概 200 MB) --> 添加条目
2. 重启电脑就可以看到 Ubuntu 系统的选择了

## 软件安装

### 搜狗输入法

到搜狗输入法[官网](http://pinyin.sogou.com/linux/)下载对应版本的软件，手动安装。但是要在系统设置的语言支持设置中，`键盘输入方式系统`要选择 `fcitx` 才行，因为搜狗输入法基于 fcitx 框架，最后添加输入法。

### Shadowsocks-Qt5

想用 Chrome 同步书签就不得不装它，翻墙神器

``` bash
$ sudo add-apt-repository ppa:hzwhuang/ss-qt5
$ sudo apt-get update
$ sudo apt-get install shadowsocks-qt5
```

可手动或者导入配置，设置启动软件后自动连接，如果需要开机启动，可以在 `Startup Applications` 中添加一个条目如下：
<center><img src="https://s1.ax2x.com/2018/03/14/LUjHR.png" width="500"/></center>

### Chrome

``` bash
$ wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
$ sudo dpkg -i google-chrome-stable_current_amd64.deb
$ google-chrome --proxy-server=socks5://127.0.0.1:1080
```

安装完后以代理的方式打开 Chrome，然后才能登陆 Google 账号同步书签和插件

### tsocks

遇到墙也可以通过 tsocks 来打开软件或命令

``` bash
$ sudo apt-get install tsocks
$ sudo vi /etc/tsocks.conf
```

修改配置文件 `/etc/tscoks.conf` 中的配置信息为

``` config
server = 127.0.0.1
# Server type defaults to 4 so we need to specify it as 5 for this one
server_type = 5
# The port defaults to 1080 but I've stated it here for clarity
server_port = 1080
```

然后就可以在终端中使用 `$ tsocks xxx` 来打开 xxx 软件或者使用 xxx 命令

### indicator-sysmonitor

Ubuntu 显示网速和其他电脑状态的软件

``` bash
$ wget -c https://launchpad.net/indicator-sysmonitor/trunk/4.0/+download/indicator-sysmonitor_0.4.3_all.deb
$ sudo apt-get install python python-psutil python-appindicator
$ sudo dpkg -i indicator-sysmonitor_0.4.3_all.deb
```

由于在 Ubuntu 14.04 64 位系统中没有 sysmonitor.svg 这个默认图标，去 `/usr/share/icons/Humanity/apps/` 中找一个系统图标(例如爱心：`application-community`)，把文件名通过 `gedit` 编辑器替换掉配置文件 724 行的 `sysmonitor `

``` bash
$ sudo gedit /usr/bin/indicator-sysmonitor
```

### Remarkble

Ubuntu 下的 Markdown 编辑器 [Remarkble](http://remarkableapp.github.io/linux/download.html)

### Teamviewer

远程控制神器 [Teamviewer](https://www.teamviewer.com/zhcn/download/linux/)

### Caffiene

防止电脑进入休眠模式的工具

``` bash
$ sudo add-apt-repository ppa:caffeine-developers/ppa
$ sudo apt-get update
$ sudo apt-get install caffeine
```

### Shutter

截图工具

``` bash
$ sudo add-apt-repository ppa:shutter/ppa
$ sudo apt-get update
$ sudo apt-get install shutter
```

### Git

``` bash
$ sudo apt-get install git
$ git config --global user.name "Randy"
$ git config --global user.email "275331498@qq.com"
```

### 编辑器

vim：`$ sudo apt-get install vim`
Sublime：[官网](https://www.sublimetext.com/3)

### WPS

WPS [官网](http://wps-community.org/downloads)