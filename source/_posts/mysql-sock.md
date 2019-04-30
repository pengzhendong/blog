---
title: MySQL 启动失败
date: 2016-02-27 11:26:18
updated: 2016-02-27 12:31:22
tags: MySQL
---

## 前言

今天算是意识到在修改程序配置文件之前要**关掉程序**的重要性了，由于想远程登录服务器上的 MySQL，我把 MySQL 的配置文件 **/etc/mysql/my.cnf** 中的 `bind-address = 127.0.0.1` 给注释掉，因为没有关掉 MySQL 然后就崩了~

<!-- more -->

## 2002 错误

``` bash
$ sudo /ect/init.d/mysql start 
* Starting MySQL database server mysqld [fail]
```

MySQL 崩了之后无法启动，使用用户名和密码连接则提示 2002 错误：

``` bash
$ mysql -u root -p
$ password: ****

ERROR 2002 (HY000): Can’t connect to local MySQL server through socket ‘/var/run/mysqld/mysqld.sock’ (2)
```

以前也遇到过好多次这种错误，但是不是这次这种原因就不知道了，以前的解决方法就是简单粗暴，我重新安装一遍 MySQL 就好了，然后里面的数据就都没了。

## 错误日志

在网上找了一堆资料，每个人的问题都不一样，解决方法也不一样，最后决定去看看错误日志 `/var/log/mysql/error.log` 然后解决自己的问题(Mac 的错误日志是 `/usr/local/mysql/data/mysqld.local.err`)。

``` bash
[ERROR] Plugin 'InnoDB' init function returned error.
[ERROR] Plugin 'InnoDB' registration as a STORAGE ENGINE failed.
[ERROR] Unknown/unsupported storage engine: InnoDB
[ERROR] Aborting
```

这是在没有正常关闭服务的情况下，对数据库参数进行改变导致的。因此重启后的服务器不支持InnoDB引擎，因为检查日志文件会导致失败。只要到 `/var/lib/mysql` 目录下把 **ib_logfile0** 和 **ib_logfile1** 这两个日志文件删除掉就好了。(千万不能删 `ibdata1` 文件。。。)。

## 端口占用

重启 MySQL 还是提示失败，好吧，继续查看错误日志，这次显示端口被占用：

``` bash
[ERROR] Do you already have another mysqld server running on port: 3306 ? 
```

看看是哪个程序占用 3306 端口，

``` bash
$ sudo lsof -i:3306
```

得到该程序的 PID 号，直接杀掉它~

``` bash
$ sudo kill PID号
```

## 不允许绑定套接字

如果重启还是提示失败并且错误日志提示不允许绑定套接字：

``` bash
[ERROR] Bind on unix socket: Permission denied
[ERROR] Do you already have another mysqld server running on socket: /var/run/mysqld/mysql.sock ?
[ERROR] Aborting
```

那么只要给这个套接字权限就好了~

``` bash
$ chown -R mysql.mysql /var/run/mysqld
$ chmod -R 775 /var/run/mysqld
```

然后终于就可以跑起来了！！！吾深感欣慰，吃早餐去咯~

## 无法远程连接

在 `/etc/mysql/my.cnf` 后面添加以下内容:

```
[mysqld]
skip-name-resolve
bind-address = 0.0.0.0
```

重启 MySQL

``` bash
$ sudo service mysql restart
```

