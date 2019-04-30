---
title: Ubuntu 14.04 上使用 Nginx 部署 Laravel
date: 2015-08-24 10:15:03
updated: 2015-08-24 11:44:18
tags: Laravel
---

本教程将会涉及以下工具：

* Ubuntu 14.04 LTS
* PHP 5.5
* MySQL
* Laravel 5.0
* Nginx 

<!-- more -->

参考文章：[Ubuntu 14.04 上使用 Nginx 部署 Laravel](https://github.com/huanghua581/laravel-getting-started/wiki/Ubuntu-14.04-%E4%B8%8A%E4%BD%BF%E7%94%A8-Nginx-%E9%83%A8%E7%BD%B2-Laravel)

此文章对原文章基于 Laravel 4 有所修改添加，同样适用于服务器上部署

开发推荐[通过 Vagrant 搭建虚拟机环境](http://www.golaravel.com/laravel/docs/5.0/homestead/)进行练习。

## 简介

Laravel 是一个开源的、现代的 PHP 开发框架，他的目标是提供一个简单并且优雅的开发方式，让开发人员可以快速的开发出一个完整的 web 应用程序。

在本指南中，我们将讨论如何在 Ubuntu 14.04(LTS) 安装 Laravel 。我们将使用 Nginx 作为我们的 web 服务器和 Laravel 5.0 版本。

## 安装服务器组件

首先，我们需要更新软件包，以确保我们有一个新的可用的软件包列表。然后我们可以安装必要的组件:

``` bash
$ sudo apt-get update
$ sudo apt-get install nginx
$ sudo apt-get install php5-fpm
$ sudo apt-get install php5-cli
$ sudo apt-get install php5-mcrypt
$ sudo apt-get install php5-mysql
$ sudo apt-get install git
```

命令将安装 Nginx 作为我们的 web 服务器和 PHP 语言环境。安装 **git** 是因为 **composer** 工具的基础组件是 git，我们将使用 composer 安装 Laravel 及更新相关的包。

## 修改 PHP 配置文件

打开 PHP 配置文件。

``` bash
$ sudo vim /etc/php5/fpm/php.ini
```

找到 **cgi.fix_pathinfo** 修改为 **0** ，如下：

``` ini
cgi.fix_pathinfo=0
```

保存并退出，因为这是一个可能的安全漏洞，详情可以看[鸟哥的文章](http://www.laruence.com/2010/05/20/1495.html)！

使用 php5enmod 启用 MCrypt 扩展：

``` bash
$ sudo php5enmod mcrypt
```

现在我们需要重启下 php5-fpm 服务：

``` bash
$ sudo service php5-fpm restart
```

PHP 已经配置完成。

## 配置 Nginx 和 Web 目录

创建网站目录 ：

``` bash
$ sudo mkdir -p /var/www/laravel
```

打开 nginx 默认配置文件：

``` bash
$ sudo vim /etc/nginx/sites-available/default
```

默认配置如下：

``` nginx
server {
        listen 80 default_server;
        listen [::]:80 default_server ipv6only=on;
    
        root /usr/share/nginx/html;
        index index.html index.htm;
    
        server_name localhost;
    
        location / {
                try_files $uri $uri/ =404;
        }
}
```

修改如下：

``` nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server ipv6only=on;
    
	# 设定网站根目录
    root /var/www/laravel/public;
    # 网站默认首页
    index index.php index.html index.htm;
    
	# 服务器名称，server_domain_or_IP 请替换为自己设置的名称或者 IP 地址
    server_name server_domain_or_IP;
    
	# 修改为 Laravel 转发规则，否则PHP无法获取$_GET信息，提示404错误
    location / {
        try_files $uri $uri/ /index.php?$query_string;        
    }
    
	# PHP 支持
    location ~ \.php$ {
        try_files $uri /index.php =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

修改完成，我们需要重启下 nginx 服务：

``` bash
$ sudo service nginx restart
```

## 安装 Composer

在命令行执行：

``` bash
$ cd ~
$ curl -sS https://getcomposer.org/installer | php
```

在当前目录会发现 **composer.phar** 这个文件，这个文件就是 Compoesr 的执行文件，我们需要移到 **/usr/local/bin** , 这样全局就能调用 Composer 。

``` bash
$ sudo mv composer.phar /usr/local/bin/composer
```

Composer 安装完成。

## 安装 Laravel 

1.我们用composer来安装 Laravel 5.0 到 /var/www/laravel 。

``` bash
$ sudo composer create-project laravel/laravel laravel 5.0.22
```

2.用Git克隆远程仓库中已存在的项目可以参考[廖雪峰的文章](http://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000)，这也是一篇适合初学者学习Git的好文章

## 赋予写的权限

更改网站目录所属组：

``` bash
$ sudo chown -R :www-data /var/www/laravel
```

**/var/www/laravel** 该目录存储 Laravel 各种服务的临时文件 , 所以需要写的权限：

``` bash
$ sudo chmod -R 775 /var/www/laravel
```

## 完成

在浏览器打开服务器的 IP 地址或域名，应该看到你的网站在运行。这时候你就可以根据自己的需要完善自己的代码了，例如数据库迁移之类的操作可以参考[岁寒的文章](http://lvwenhan.com/laravel/432.html)