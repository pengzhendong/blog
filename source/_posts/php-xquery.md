---
title: 使用 PHP 和 Zorba 执行 XQuery 语句
date: 2016-04-27 19:38:48
updated: 2016-04-27 20:15:10
tags: [PHP, XML]
---

## 前言

XML 这门课的课设要做一个小型论坛，要用 XML 来存储数据，在思考用 Java 还是 PHP 这个问题上我就花了好长时间，因为总感觉 Java 的包会多一些，或许会方便许多，然而最终我还是选择了 PHP，因为它有 simpleXML。作为一个强迫症患者，不达目的决不罢休，于是我继续找关于在 PHP 中执行 XQuery 语句的方法，终于发现一个没多少人用的工具 **Zorba**。

<!-- more -->

## 安装

Zorba 是一个用于一般用途的 XQuery 处理器，使用 C++ 实现，遵循 W3C 规范。Zorba 不是一个 XML 数据库，该查询处理器主要设计用于各种嵌入式环境(好吧，上一个版本是2012年出的)。

话说至今我还不知道到底哪个才是真正的官网：

1. http://www.zorba.io/
2. http://zorba.28.io/

第一个应该是要翻墙才能打开，而且资料感觉不齐全，Linux 只有 Debian 下的安装方法(为此我还多装了一个虚拟机)。

Ubuntu :

``` bash
$ sudo add-apt-repository ppa:fcavalieri/zorba
$ sudo apt-get update
$ sudo apt-get install zorba
```

安装完成后通过 `zorba -version` 就能看到版本啦~~

## 使用

在 PHP 中使用 Zorba 有两种方式：

1. 安装 PHP 扩展(然而在 pecl 中并没有找到这个扩展，作者也说他们不再放到 pecl 上了)；
2. 直接调用 Zorba。

``` php
public function searchUser($payload)
{
    $username = $payload['username'];
    $password = $payload['password'];

    $xquery = <<< EOT
        for \$x in doc("datas/User.xml")/users/user
            where \$x/username="$username"
            where \$x/password="$password"
            return data(\$x/username)
EOT;

    exec("zorba -i -q '$xquery'", $array);
    if (count($array) != 0) return $array[1];
    else return false;
```

函数首先获得 `$xquery` 字符串参数中的 XQuery 请求。然后使用 exec() 函数来运行 Zorba，exec() 函数利用来自 Zorba 的输出填充 `$array` 数组。-q 和 -i 选项分别要求运行一个查询和缩排输出。

以上代码就能够从 XML 文件中找到对应的用户，可以实现登陆的功能。

## 总结

看到 PhpStorm 和 Idea 中都有 XQuery 的插件，然而至今都还不明白如何去调用 XQuery 文件中自定义的函数。网上的资料也极少，对它的感受就到此为止吧~在 PHP 中还是用 simpleXML 吧。