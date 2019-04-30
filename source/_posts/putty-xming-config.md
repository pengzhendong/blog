---
title: PuTTY + Xming 配置
date: 2018-07-19 13:38:37
updated: 2018-07-19 14:09:33
tags: Linux
---

## 前言

最近做实验需要用到服务器，想在服务器中显示绘图结果。而服务器没有安装图形桌面环境，虽然可以保存实验数据然后在自己电脑上绘制，但是总感觉不够方便，于是了解了一下 X11，顺手做个笔记。

<!-- more -->

## PuTTY

远程连接过服务器，基本上都会了解 SSH (Secure Shell) 协议。它是建立在应用层基础上的安全协议，专为远程登录会话和其他网络服务提供安全性的协议，可以有效防止远程管理过程中的信息泄露问题。

支持 SSH 的软件有很多，Windows 平台中最出名的就是**开源**软件 PuTTY，由 Simon Tatham 开发，并且打算移植到 Mac OS 中。

![](https://s1.ax2x.com/2018/07/19/wB8ve.png)

输入服务器的 IP 地址和 SSH 端口 (默认: 22) 即可远程连接，为了避免每次都要输入用户名，可以在 `Connection` | `Data` | `Login details` 中配置自动登录的用户名。旧版本的 PuTTY 还支持配置登录密码，估计是考虑到安全性问题不再提供该功能。首次登录会出现服务器的指纹信息，点击确认按钮即可。

## 密钥登录

通过密码的方式登录服务器，容易有密码被暴力破解的问题，所以一般会将 SSH 端口设置为 22 以外的其他端口，或者禁止用超级管理员的账户登录。更加安全的做法就是通过密钥的方式登录。

首先通过 `ssh-keygen` 命令生成密钥对：私钥 id_rsa 和公钥 id_rsa.pub

``` bash
pengzhendong@251:~$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/pengzhendong/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/pengzhendong/.ssh/id_rsa.
Your public key has been saved in /home/pengzhendong/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:GACGDjacfISlSG5qpQZKsliCCq9/Dlnf/Lu+J2Nbo38 pengzhendong@251
The key's randomart image is:
+---[RSA 2048]----+
|B=*o.            |
|#X  ..           |
|^= o  .          |
|Oo+    o         |
|.o  . . S        |
|.  o . o         |
| .o   . o   o    |
|  ...    .+o..E  |
|   o.    oOX..   |
+----[SHA256]-----+
```

然后可以通过以下命令将公钥复制到服务器的 ~/.ssh/authorized_keys 文件中，或者手动复制粘贴：

``` bash
ssh-copy-id pengzhendong@219.123.169.251
```

再次使用 `ssh` 命令的时候就不再需要输入用户名和密码了 (首次使用也会提示指纹信息)。也可以使用 PuTTY 自带的 PuTTYgen 工具生成 ppk (PuTTY Private Key) 文件：

![](https://s1.ax2x.com/2018/07/19/w5iBK.png)

点击 `Generate` 按钮后需要再进度条下方的空白区域不断移动鼠标  (估计是为了获取鼠标位置作为随机数，提高安全性) 才能使进度条移动。生成结果如下图所示：

![](https://s1.ax2x.com/2018/07/19/w57qE.png)

可以保存公钥文件，也可以直接将公钥内容粘贴到 authorized_keys 文件中，一定要保存私钥且不能加密，否则登录的时候还需要提供密码。然后在 PuTTY 的 `Connection` | `SSH` | `Auth` 中选中刚刚生成的私钥 ppk 文件即可免密码登录。

## X11

一般远程登录服务器后都是命令行界面，但是少数情况下我们需要运行带有 GUI (Graphical user interface) 页面的程序 (例如使用 Python 绘图)，如果服务器安装了图形桌面环境 (例如 gnome)，那么就可以使用 VNC 或者 TeamViewer 等软件进行连接。但是大部分情况下，为了节省资源，服务器一般都不会安装图形桌面环境，我们也只是需要运行带有 GUI 页面的程序。

X11 又叫 X Window 系统，是 X 协议的第 11 版。带有 GUI 页面的程序会通过 X 协议告诉 `服务端` (即本地电脑) 需要显示什么图形，所以需要在本地电脑上安装 X11 协议的实现软件作为 X11 的服务端，解析远程服务器传过来的 GUI 页面的相关信息并反馈用户输入。

Windows 系统中可以通过 PuTTY + Xming 实现 X 协议，Mac OS 中有 XQuartz 软件。安装启动 Xming 软件后如下图所示：

![](https://s1.ax2x.com/2018/07/19/wDjfz.png)

表示开了一个 Display 端口在 `localhost:0.0`， 然后配置以下 PuTTY 的 `SSH` | `X11`，勾中 `Enable X11 forwarding` 和输入 `X display location` 为 `localhost:0` 即可。XQuartz 打开终端后则需要在 ssh 命令后加上 `-X` 参数表示打开 X11 forwarding。

目前为止`服务端`配置完毕，但是还需要检查一下服务器的 `/etc/ssh/sshd_config` 是否开启了 X11Forwarding，否则服务器都不告诉你需要显示什么图形，配置显示的偏移位置为可选项。

``` bash
X11Forwarding yes
X11DisplayOffset 10
```

最终在服务器的命令行中输入 `xclock` 则会在本地电脑中显示时钟软件的图形界面：

![](https://s1.ax2x.com/2018/07/19/wD4U9.png)

 