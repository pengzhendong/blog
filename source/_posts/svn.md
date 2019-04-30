---
title: 集中式版本控制系统：SVN
date: 2016-04-29 22:16:48
updated: 2016-04-29 23:29:45
tags: SVN
---

<center>![](https://s1.ax2x.com/2018/03/14/L1Vve.png)</center>

## 前言

Git 之所以是分布式的，是因为每个人的身份地位都相等(每人都有一份完整的代码)，没有服务器和客户端的定义，远程仓库也不过是为了方便大家同步代码。而 Svn 则是集中式的，有服务器和客户端，服务器是 Boss ，它让不让你这个用户读写文件都得听它的。这两个软件最大的区别应该就是分支吧~

<!-- more -->

## 服务器

对 Windows Server 没什么好感，所以没有了解过 Windows 下如何搭建 SVN 服务器，只讨论一下 Linux 环境下的步骤。

### 安装

``` bash
$ sudo apt-get install subversion
$ svnadmin create myProject
$ cd myProject/conf
```

在 `passwd` 文件中添加一个用户(为了方便分配权限，可分组): 

```
[users]
zander = 123

[groups]
dev_group = zander, randy
```

在 `authz` 文件中指定用户权限([/]表示所有资源):

```
[/] 
zander = rw
@ dev_group = rw
```

在 `svnserve.conf` 文件中初始化配置: 

```
anon-access = read #匿名用户可读
auth-access = write #授权用户可写
password-db = passwd #使用哪个文件作为账号文件
authz-db = authz #使用哪个文件作为权限文件
```

### 启动

``` bash
$ cd ~
$ svnserve -d -r myProject
```

``` bash
$ ps -ef | grep svn
```

查看是否服务已经启动，到此为止服务器就配置完成了(如果想通过浏览器 http:// 的方式访问还可以搭配着 Apache 使用)，现在就可以通过客户端进行操作了。

### 配置 Apache

```
$ apt-get install apache2-utils
$ sudo apt-get install libapache2-svn
```

上面第一个命令是安装 `htpasswd` 这个命令，由于我的 Apache2 没有自带所以才需要安装，第二个是通过 http 访问所需要的包。

``` bash
$ cd /etc/apache2
$ mkdir conf-svn
```

在 apache2 中新建一个文件夹用来保存 SVN 配置文件，由于这个不是使用 SVN 的服务器，所以还需要弄一份权限配置：

``` bash
$ sudo touch authz
```

文件内容和之前的一样，然后再建 `password` 文件，这个和之前的方式就不一样了，这次试用的是刚才安装的 `htpasswd` 命令来建，这样建立的文件是加密后的，所以不能直接 `cat`：

``` bash
$ sudo htpasswd -cm password zander
```

按照提示输入两次密码~

#### 参数说明

> -c 创建password文件，如果password文件已经存在,那么它会重新写入并删去原有内容
> -n 不更新password文件，直接显示密码
> -m 使用MD5加密（默认）
> -d 使用CRYPT加密（默认）
> -p 使用普通文本格式的密码
> -s 使用SHA加密
> -b 命令行中一并输入用户名和密码而不是根据提示输入密码，可以看见明文，不需要交互
> -D 删除指定的用户

#### 修改配置文件

在 `apache2-conf` 文件中加入以下内容：

```
<Location /svn>
	DAV svn
	SVNParentPath /home/ubuntu
	AuthzSVNAccessFile /etc/apache2/conf-svn/authz
	AuthType Basic
	AuthName "Subversion"
	AuthUserFile /etc/apache2/conf-svn/password
	Require valid-user
</Location>
```

#### 重启 Apache2

``` bash
$ sudo /etc/init.d/apache2 restart
```

这时候就可以打开浏览器，在地址栏输入 `http://115.159.144.42/svn/myProject/` 就可以看到文件内容了。

![](https://s1.ax2x.com/2018/03/14/L1Yld.png)

## 客户端

### Windows 

Windows 下的客户端 [TortoiseSVN](https://tortoisesvn.net/downloads.html) 比较不错，图形界面操作，没有深入了解。

### Linux

``` bash
$ sudo apt-get install subversion
```

其实装好这个软件后，机器就具有服务器和客户端的潜力了，服务器和客户端的区别的体现应该不是软件，而是使用这个软件时让它执行的命令。

``` bash
$ svn import myProject svn://115.159.144.42/myProject --username=zander --password=123 -m "初始化导入"
```

先将本地初始化的项目 `myProject` 导入到服务器中，写一些提交的信息，提交成功后就可以在别的机器使用下面的命令从 SVN 库中取出已有的文件，目标地址为当前路径下的 `temp` 文件夹下。

``` bash
$ svn checkout svn://115.159.144.42/myProject --username=zander --password=123 temp
```

#### 提交

类似于 Git 中的 `commit` 命令，不过 SVN 中的是直接就提交到服务器，进入 `temp` 文件夹中，修改 checkout 下来的文件，然后使用一下命令提交：

``` bash
$ svn commit -m "first commit"
```

然后通过网页访问服务器就能发现该文件已经被修改~

#### 添加

如果在文件夹中新建了一个文件，那么就应该使用 `add` 命令添加后再进行提交：

``` bash
$ svn add newfile.txt
$ svn commit -m "add a new file"
```

**参数**(下面其他命令同样)

1. "filename" 添加该文件
2. "*" 添加当前目录下所有文件
3. "."或者空 添加当前目录以及子目录下的所有文件

#### 获取最新文件

多人协同开发时，别人提交了新的代码，要怎么去获取呢？Git 中可以通过 `pull` 命令拉去最新代码，SVN 提供了 `update` 命令来更新某个文件的最新状态：

``` bash
$ svn update .
```

在文件名前面添加参数 `-r revision号` 可以更新到指定版本。

#### 删除

如果提交了不需要的文件，可以通过 `delete` 命令将其删除，例如上面的 `newfile.txt` 文件：

``` bash
$ svn delete newfile.txt
$ svn commit -m "remove newfile.txt"
```

#### 查看日志

查看某一目录或某一文件的历史记录可以使用 `log` 命令，Git 中这个命令可以连使用，SVN 只能联网情况下使用：

``` bash
$ svn log learnsvn.txt
```

如果提示 `svn: E220001: Item is not readable` 去配置文件中把以下内容改一下就好了：

```
anon-access = none
```

```
------------------------------------------------------------------------
r4 | zander | 2016-04-30 16:09:23 +0800 (六, 30  4 2016) | 1 line

modify by temp2
------------------------------------------------------------------------
r2 | zander | 2016-04-30 16:01:03 +0800 (六, 30  4 2016) | 1 line

first change
------------------------------------------------------------------------
r1 | zander | 2016-04-30 15:34:47 +0800 (六, 30  4 2016) | 1 line

初始化导入
------------------------------------------------------------------------
```

#### 比较文件

比较 SVN 库中某一文件在不同版本中的修改情况可以使用 `diff` 命令：

``` bash
$ svn diff learnsvn.txt
```

可以通过在文件名前面添加 `–r m:n` 参数查看任意两个版本 n 和 m 的区别。

```
Index: learnsvn.txt
===================================================================
--- learnsvn.txt	(revision 9)
+++ learnsvn.txt	(working copy)
@@ -1,8 +1,2 @@
-ansdaisdafirst change
-
-hello
-
-add by 2
+delete by temp1
 modify by temp2
-add by 1
-modify by temp2
```

#### 加锁/解锁

为了避免多人同时修改某个文件，负责该文件的人可以对该文件进行加锁，这样的话对于这个文件，其他任何人的权限都是只读的。

**加锁**

``` bash
$ svn lock learnsvn.txt -m "locked by temp1"
```

其他人修改文件，然后提交的时候就会提示：

```
svn: E160037: Commit failed (details follow):
svn: E160037: Cannot verify lock on path '/myProject/learnsvn.txt'; no matching lock-token available
```

**解锁**


``` bash
$ svn unlock learnsvn.txt
```

解锁完之后别人就可以进行提交了~

#### 查看状态

通过 `status` 命令可以查看文件的状态：

``` bash
$ svn status *
```

**状态类型**

* ?：不在svn的控制中
* M：内容被修改
* C：发生冲突
* A：预定加入到版本库
* K：被锁定

#### 查看文件详情

``` bash
$ svn info learnsvn.txt
```

```
Path: learnsvn.txt
Name: learnsvn.txt
Working Copy Root Path: /Users/pengzhendong/Desktop/tem1
URL: svn://115.159.144.42/myProject/learnsvn.txt
Relative URL: ^/myProject/learnsvn.txt
Repository Root: svn://115.159.144.42
Repository UUID: 3b5fd81b-e1b8-4f0d-af3c-93b89d048487
Revision: 9
Node Kind: file
Schedule: normal
Last Changed Author: zander
Last Changed Rev: 9
Last Changed Date: 2016-04-30 18:05:24 +0800 (六, 30  4 2016)
Text Last Updated: 2016-04-30 18:05:18 +0800 (六, 30  4 2016)
Checksum: ec19087458669484fb37835a7f85700e7f525e42
```

#### 恢复本地修改 

``` bash
$ svn revert learnsvn.txt
```

这个命令会放弃指定文件本地修改，让文件恢复到上次 `update` 之后的状态。如果想放弃所有文件的修改：

``` bash
$ svn revert --recursive .
```

#### 解决冲突

当两个人一起修改文件，一起提交时，最后一个人提交的时候会出现过期提示：

```
svn: E160028: Commit failed (details follow):
svn: E160028: File '/myProject/learnsvn.txt' is out of date
```

然后使用 `update` 命令进行更新，接着就会出现以下内容：

```
Conflict discovered in file 'learnsvn.txt'.
Select: (p) postpone, (df) show diff, (e) edit file, (m) merge,
        (mc) my side of conflict, (tc) their side of conflict,
        (s) show all options: 
```

选 m 进行合并：

```
Merging 'learnsvn.txt'.
Conflicting section found during merge:
(1) their version (at line 6)                    |(2) your version (at line 6)
-------------------------------------------------+-------------------------------------------------
add by 2                                         |add by 1
modify by temp2                                  |modify by temp2
-------------------------------------------------+-------------------------------------------------
Select: (1) use their version, (2) use your version,
        (12) their version first, then yours,
        (21) your version first, then theirs,
        (e1) edit their version and use the result,
        (e2) edit your version and use the result,
        (eb) edit both versions and use the result,
        (p) postpone this conflicting section leaving conflict markers,
        (a) abort file merge and return to main menu: 
```

选择保留内容的方式，既可以完成冲突的解决。

#### 分支

标准的 SVN 布局是:

* trunk    //主干文件夹
* branches //分支文件夹
* tags     //标签文件夹

分支在 SVN 中一点不特别，就是版本库中的另外的一个目录。先将在项目根目录新建一个文件夹叫 trunk 代表主分支，branches 存放其他分支，然后将 learnsvn.txt 移到该文件夹中，添加提交。使用 `copy` 命令创建一个分支，其实说白了就是复制一份代码到另一个文件夹中。。。

``` bash
$ svn copy trunk branches/dev
```

修改主分支内容，然后提交，在进入 dev 分支中进行合并，先查看 dev 分支的最新版本：

``` bash
$ svn log --verbose --stop-on-copy svn://115.159.144.42/myProject/branches/dev
```

```
------------------------------------------------------------------------
r22 | zander | 2016-04-30 23:11:24 +0800 (六, 30  4 2016) | 1 line
Changed paths:
   A /myProject/branches/zander/zander.txt

add new file
------------------------------------------------------------------------
```

将主分支合并到当前分支的最新版本(有可能需要先更新一下当前分支的代码)：

``` bash
$ svn merge -r r22:HEAD /Users/pengzhendong/Desktop/tem1/trunk
```

如果两个分支同时修改了代码，则需要进行冲突解决，同上。

合并后可以通过一下命令删除服务器中的 zander 分支：

``` bash
$ svn rm -m "delete zander branch" svn://115.159.144.42/myProject/branches/zander
```

#### 标签

tag 的操作感觉有点类似于分支。

## 总结

哎，整理完才发现 Git 的方便之处，多了解一门技术也是好事吧~也算是对 Git 的再一次复习了。