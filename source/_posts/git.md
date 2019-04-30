---
title: 分布式版本控制系统：Git
date: 2016-04-29 13:06:48
updated: 2016-04-29 13:44:32
tags: Git
---

![](https://s1.ax2x.com/2018/03/14/L1Wsr.jpg)

<!-- more -->

## 前言

使用 Git 进行代码管理已经快一年了，不敢说所有的命令都已经会用，但一些常用的命令也算是比较熟练了，前段时间作为部长给部员们开讲座<del>并没有几个人来参加</del>的时候整理了一下，正好可以记录在博客中。

## 安装

* Windows: 到[官网](https://git-for-windows.github.io/)下载安装包安装
* Linux:

``` bash
$ sudo apt-get install git
```

## 配置

安装完后，打开命令行(Windows 右键 Git Bash here)，输入名字和邮箱。

``` bash
$ git config --global user.name "Your Name"
$ git config --global user.email "email@example.com"
```

## 本地操作

新建一个文件夹，使用命令行，进入到文件夹中，然后新建一个learngit.txt 文件用于管理(就是实际中的代码)。

### 初始化

``` bash
$ git init
```

初始化一个仓库(默认 master 分支)，会在当前文件夹下面生成一个隐藏文件夹 `.git` ，通过一下命令能查看隐藏文件：

``` bash
$ ls -al
```

### 添加提交

通过 `add` 命令将该目录下所有文件提交到暂存区(也可以将 `.` 换成需要单独提交的文件名)，然后通过 `commit` 命令将暂存区的所有内容提交到当前分支

``` bash
$ git add .
$ git commit -m "This is my first commit"
```

### 撤销修改

修改一下 learngit.txt 文件，然后通过 `diff` 命令查看当前文件与暂存区中的文件的不同，如果需要撤销修改，则通过 `checkout` 命令进行撤销

``` bash
$ git diff learngit.txt
$ git checkout -- learngit.txt
```

再修改一下 learngit.txt 文件或者再建一个文件，然后就可以通过 `status` 命令查看当前那个文件被修改了，新建了那个文件。

``` bash
$ git status
```

### 版本回退

然后再次添加使用 `add` 和 `commit` 命令提交一下，如果这时候想回到第一个提交那会，就可以通过 `log` 命令查看提交历史和显示提交对象的哈希值，然后通过 `reset` 命令指定哈希值(前四位就够了)回到想要回到的点。

``` bash
$ git log
$ git reset --hard xxxx
```

![](https://s1.ax2x.com/2018/03/14/L1b2l.jpg)

## 分支管理

分支的特性将 Git 从版本控制系统家族里区分出来。使用分支可以从开发主线上分离开来，然后在新的分支上解决特定问题，同时不会影响主线。其它的一些版本控制系统，创建分支需要创建整个源代码目录的副本。

在 Git 中提交时，会保存一个提交（commit）对象，该对象包含一个指向暂存内容快照的指针，包含本次提交的作者等相关附属信息，包含零个或多个指向该提交对 象的父对象指针：首次提交是没有直接祖先的，普通提交有一个祖先，由两个或多个分支合并产生的提交则有多个祖先。

### 创建合并分支

使用 `checkout` 命令切换分支，`-b` 参数表示如果该分支不存在就先创建分支然后切换。 

``` bash
$ git checkout -b zander
```

然后在 `zander` 分支下修改文件添加提交后，在再切换回主分支：

``` bash
$ git checkout master
```

可以看到主分支里的文件并没有被修改，例如在 `zander` 分支下开发完成后，在 `master` 分支下就可以使用 `merge` 命令合并分支就可以看到修改的结果了。

``` bash
$ git merge zander
```

### 解决冲突

切换到 `zander` 分支修改文件，添加提交；切换回 `master` 没有获取 `zander` 分支的修改后的提交的同时也修改文件，添加提交，然后合并。这时候系统就不知道保留谁的修改，还是都保留，就会产生冲突。

``` bash
Auto-merging learngit.txt
CONFLICT (content): Merge conflict in learngit.txt
Automatic merge failed; fix conflicts and then commit the result.
```

打开文件就会发现文件里面有一些符号：

```
<<<<<<< HEAD
From master
=======
From zander
>>>>>>> dev
```

这时候只需要删掉不需要的内容(或者都保留)重新提交，就可以解决冲突啦~

```
From master
From zander
```

<img src="https://s1.ax2x.com/2018/03/14/L1uyB.png" width="200">

## Github

一开始我一直不理解 Git 和 Github 有什么区别，现在虽然觉得当时有点幼稚，但是看到身边的人也会遇到这种问题，于是分析一下。

其实很好理解，Git是分布式版本控制系统，一个管理代码的工具。上面介绍的本地操作和分支管理都还没涉及分布式(在这里也就是不同电脑可以同时操作一份代码)，如果我们需要一个远程的仓库，就是本地提交后，把代码推送到远程仓库上，然后小伙伴就可以到远程仓库下载代码，进行开发然后推送上去。Github 就是这么一个远程仓库(就是一个网站)。

注册账号登陆之后，新建一个远程仓库，得到仓库地址，然后在本地的仓库里面添加这个远程仓库的地址：

``` bash
$ git remote add origin https://xxxx
```

如果需要下载远程仓库的代码进行开发，则可以使用 `clone` 命令：

``` bash
$ git clone http:xxxx
```

### 推送

通过 `push` 命令可以往远程仓库推送本地仓库中某个分支的内容：

``` bash
$ git push origin master
```

通过 `pull` 命令可以获取仓库中耨个分支的最新内容(例如小伙伴刚刚提交的代码)：

``` bash
$ git pull origin zander
```

需要输入 Github 的账号和密码确保拥有权限。如果不想每次都输入账号密码可以在生成公钥和私钥(一对一)，然后将公钥内容粘贴到 Github 的中，这样 Github 就能知道你有权限。

``` bash
$ ssh-keygen -t rsa -C "youremail@example.com"
```

然后一直按回车，就会在某个文件夹下面生成公钥和私钥，根据提示进入该文件夹，`cat` 一下公钥，复制内容。

```
$ cat id_rsa.pub
```

Github->Settings->SSH and GPG keys 新建一个 SSH key，把内容粘贴进去，保存， 通过下面命令就可以看是否能够连接上 Github。

```
$ ssh git@github.com
```

## 标签

Git 中海油一个标签的功能，但感觉至今还没怎么用过，先记录一下命令。

``` bash
$ git tag tag1                     //新建标签
$ git tag -a tag1 -m "blablabla"   //指定标签信息
$ git tag                          //查看所有标签
```

然后就可以通过 `push` 和 `pull` 进行推送拉取标签

<img src="https://s1.ax2x.com/2018/03/14/L1vAK.png" width="200">