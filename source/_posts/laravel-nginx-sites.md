---
title: Nginx 多站点配置
date: 2015-08-24 16:10:02
updated: 2015-08-24 16:56:21
tags: [Nginx, Laravel]
---

# 配置站点

根据[官方文档](http://www.golaravel.com/laravel/docs/5.0/homestead/)，我们有两种添加站点的方式：

<!-- more -->

1.在 **/Homestead/src/stubs/Homestead.yaml** 文件中添加站点:

``` nginx
sites:
    - map: homestead.app
       to: /home/vagrant/Code/Laravel/public
```

然后在 Homestead 目录中执行：

``` bash
$ vagrant provision
```

不过[官方文档](http://www.golaravel.com/laravel/docs/5.0/homestead/)里面提到，这个操作是具有破坏性的，当执行 **provision** 命令，现有的数据库会被摧毁并重新创建。

2.SSH 进入 Homestead 环境中，使用 **serve** 命令文件添加站点，执行以下命令：

``` bash
$ serve domain.app /home/vagrant/Code/path/to/public
```

-----
由以上任意一种方式添加站点之后，我们都应该将新的站点到本机的 **/etc/hosts** 文件中：

```
# homestead config
192.168.10.10 homestead.app
```

到这里，站点就添加完成啦！

# 修改、删除站点

(这里1和2分别对应上面添加站点的1和2两种方式)

1.在 **/Homestead/src/stubs/Homestead.yaml** 文件中修改或者删除站点，然后在 Homestead 目录中执行:

``` bash  
$ vagrant provision
```

2.你会发现由 **serve** 命令添加的站点并没有出现在 **Homestead.yaml** 文件中，根据
**/Homestead/scripts/serve.sh** 文件，可以看到 **serve** 命令会创建一个 nginx 的 site ，做些链接, 最后重启 nginx 和 php-fpm：

``` nginx
echo "$block" > "/etc/nginx/sites-available/$1"
ln -fs "/etc/nginx/sites-available/$1" "/etc/nginx/sites-enabled/$1"
service nginx restart
service php5-fpm restart
```

所以SSH 进入 Homestead 环境后，执行以下指令：

``` bash
$ cd /etc/nginx/sites-available
ls
```

这时候就能够看到所有的站点啦！然后可以通过执行以下命令删除站点：

``` bash  
$ sudo rm homestead.app
```

或者执行以下命令然后编辑文件对站点进行修改：

``` bash
$ sudo vi homestead.app
```