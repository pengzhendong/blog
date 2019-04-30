---
title: 升级 PHP 和在 Apache 中配置 Laravel 应用
date: 2016-05-05 10:39:48
updated: 2016-05-05 11:42:44
tags: Laravel
---

## 前言

一直在用 Nginx 部署 Laravel 应用，感觉比较简单，今天在网上看到一篇关于在 apache 中配置的教程，就总结一下，顺便记录一下升级 php 版本的方法。

<!-- more -->

## 升级 PHP 到 5.6

``` bash
$ sudo apt-get install software-properties-common
$ sudo add-apt-repository ppa:ondrej/php5-5.6
$ sudo apt-get update
$ sudo apt-get upgrade
$ sudo apt-get install php5
```

升级过程中如果出现选项就直接选择第一个。升级完毕后可以通过`php -v` 查看版本:

``` bash
$ php -v
PHP 5.6.21-1+donate.sury.org~trusty+1 (cli)
Copyright (c) 1997-2016 The PHP Group
Zend Engine v2.6.0, Copyright (c) 1998-2016 Zend Technologies
    with Zend OPcache v7.0.6-dev, Copyright (c) 1999-2016, by Zend Technologies
```

## 在 Apache 中配置 Laravel 应用

首先默认已经安装好一般 web 所需环境，然后使用下面命令安装 laravel 所需的 php 扩展：

``` bash
$ sudo apt-get install php5-mcrypt php5-json
$ sudo php5enmod mcrypt
$ sudo php5enmod json
$ sudo service apache2 restart
```

如果没开启重写模块的话还需要开启：

``` bash
$ sudo a2enmod rewrite
$ sudo service apache2 restart
```

最后给 `Laravel` 应用写的权限：

``` bash
$ sudo chown -R www-data:www-data /var/www/xxx/storage
```
