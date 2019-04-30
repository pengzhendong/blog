---
title: Hexo
date: 2016-01-13 21:22:29
updated: 2016-01-13 21:52:19
tags: Hexo
---

## 前言

除了昨天那篇拖了半个月的博客，真的是很久没有记录自己的学习过程了。写日记的习惯也没了，每天只是记录一下当天发生的事情，前天和昨天花了两天时间将博客换成 Hexo，感觉整个人都萌萌哒，强迫症一下子就治好了，花点时间记录一下~

<!-- more -->

## 安装 Git 和 Node.js

首先，安装 Hexo 的前提是要安装 Git 和 Node.js。关于 Git 是什么和到底怎么学，在前面的博客中也有介绍，这里再次推荐廖雪峰前辈的[博客](http://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000/)，然后去 Node.js 的[官网](https://nodejs.org/en/)下载安装。

## 安装 Hexo

``` bash
$ npm install hexo -g
```

安装好之后，新建一个文件夹，用来存放 Hexo 的各种文件，在该文件夹下，执行一下命令：

``` bash
$ hexo init
```

Hexo随后会自动在目标文件夹建立网站所需要的文件。然后按照提示安装模块，执行：

``` bash
$ npm install
```

## 本地启动

启动本地服务，进行文章预览调试，命令：

``` bash
$ hexo server --debug
```

根据提示，在浏览器输入 `http://localhost:4000` 就能看到运行结果了，如果想推送到服务器中，则应使用 `$ scp` 命令进行上传~如果提示没安装 **hexo-server** 插件，就通过以下命令安装一下：

``` bash
$ npm install hexo-server
```

## 将博客部署到 Github 和 Coding

在保证已经将本机的公钥写到 Github 和 Coding 之后，修改 Hexo 的配置文件 `_config.yml`。将 depoly 属性修改成以下内容：

``` 
deploy:
  type: git
  repo: 
    github: https://github.com/pengzhendong/pengzhendong.git,gh-pages
    coding: https://git.coding.net/pengzhendong/pengzhendong.git,coding-pages
```

将用户名和仓库名修改成所想推送到的仓库，如果想只推送到 Github 或者 Coding 的话，那么就只需要填写一个仓库和分支名称即可。

回到命令行下，输入以下内容对 hexo 进行渲染生成 html 文件到 public 文件夹中：

``` bash
$ hexo generate
```

设置使用 git 作为部署工具：

``` bash
$ npm install hexo-deployer-git --save
```

再输入以下命令将 public 文件夹推送到远程仓库中：

``` bash
$ hexo depoly
```

值得注意的是，上面的命令不会将 hexo 全部推送到仓库中，只推送 public 中渲染后的文件，所以如果想将全部文件托管到远程仓库则还需进行自行推送。

到现在为止一个大体的 hexo 博客就大体完成了。

## 绑定域名

在 **source** 文件夹下新建一个 CNAME 文件，编辑文件，输入域名。
到解析域名的页面下，添加两条主机记录：www 和 @ 都是默认路线，记录值 `pages.coding.me` ，记录类型就是 CNAME。

如果想将海外的访问定位到 github 上的个人主页，那么就按照下图进行操作，这样的话如果国外访问，那么访问的就是 github 上的内容，国内访问就是 coding 上的内容。

![](https://s1.ax2x.com/2018/03/14/LAyTe.png)

## NexT 主题

终于把 NexT 主题更新到了 6.0.5，这个版本可以支持 Hexo 数据文件的特性(在 Hexo 3 中被引入)，所以以后更新主题再也不用折腾了，因为主题的配置文件都放在别的地方，因此几乎并没有对 NexT 进行任何修改，下次更新的时候直接使用 `git pull` 命令就可以。

### 配置

基于[参考链接](https://github.com/theme-next/hexo-theme-next/blob/master/docs/zh-CN/DATA-FILES.md)的第二种方式的第一个方法，再进行以下修改：

1. 由于想添加几个菜单项和改一下打赏功能，于是修改主题文件夹下 `languages/zh-CN.yml` 文件，添加和修改内容如下：
``` yml
menu:
  friends: 友链
  books: 书单
reward:
  donate: 赏
```
2. `next.yml` 只能用 Vim 编辑它才不会报语法错误，就用 Sublime 打开看一下都不行，不知道怎么回事。由于文件太长，大部分都没有修改，就不一一列举，修改文件补丁如下：
``` patch
diff -r next.yml _config.yml
21c21
< custom_file_path:
---
> #custom_file_path:
23,25c23,25
<   head: source/_data/head.swig
<   header: source/_data/header.swig
<   sidebar: source/_data/sidebar.swig
---
>   #head: source/_data/head.swig
>   #header: source/_data/header.swig
>   #sidebar: source/_data/sidebar.swig
66c66
<   since: 2015
---
>   #since: 2015
69c69
<   icon: heart
---
>   icon: user
75c75
<   powered: false
---
>   powered: true
79c79
<     enable: false
---
>     enable: true
84c84
<   custom_text: <a href="http://www.miitbeian.gov.cn/">粤ICP备17093976号</a>&nbsp;|&nbsp;<a href="http://tongji.baidu.com/web/welcome/ico?s=3eadd8760e61d35b88b33f4f82ba0bc9">百度统计</a>&nbsp;|&nbsp;<a href="/sitemap.xml">Google 网站地图</a>&nbsp;|&nbsp;<a href="/baidusitemap.xml">百度网站地图</a>
---
>   #custom_text: Hosted by <a target="_blank" rel="external nofollow" href="https://pages.coding.me"><b>Coding Pages</b></a>
115c115
<   tags: /tags/ || tags
---
>   #tags: /tags/ || tags
121,122d120
<   friends: /friends/ || users
<   books: /books/ || book
134c132
< #scheme: Muse
---
> scheme: Muse
136c134
< scheme: Pisces
---
> #scheme: Pisces
152,162c150,160
< social:
<   GitHub: https://github.com/pengzhendong || github
<   Twitter: https://twitter.com/pengzhendong || twitter  
<   Coding: https://coding.net/u/pengzhendong || github-alt
<   Trello: https://trello.com/pengzhendong || trello
<   E-Mail: mailto:275331498@qq.com || envelope
<   Google: https://plus.google.com/pengzhendong || google
<   FaceBook: https://www.facebook.com/pengzhendong || facebook
<   Telegram: https://t.me/pengzhendong || telegram
<   知乎: http://www.zhihu.com/people/pengzhendong || leanpub
<   关于: /about" target="_self || user
---
> #social:
>   #GitHub: https://github.com/yourname || github
>   #E-Mail: mailto:yourname@gmail.com || envelope
>   #Google: https://plus.google.com/yourname || google
>   #Twitter: https://twitter.com/yourname || twitter
>   #FB Page: https://www.facebook.com/yourname || facebook
>   #VK Group: https://vk.com/yourname || vk
>   #StackOverflow: https://stackoverflow.com/yourname || stack-overflow
>   #YouTube: https://youtube.com/yourname || youtube
>   #Instagram: https://instagram.com/yourname || instagram
>   #Skype: skype:yourname?call|chat || skype
177c175
< #github_banner: https://github.com/pengzhendong || Follow me on GitHub
---
> #github_banner: https://github.com/yourname || Follow me on GitHub
227c225
<   b2t: true
---
>   b2t: false
230c228
<   scrollpercent: true
---
>   scrollpercent: false
244c242
< save_scroll: true
---
> save_scroll: false
280,282c278,280
< reward_comment: 疏影横斜水清浅，暗香浮动月黄昏
< wechatpay: /images/WeChatPay.png
< alipay: /images/AliPay.png
---
> #reward_comment: Donate comment here
> #wechatpay: /images/wechatpay.jpg
> #alipay: /images/alipay.jpg
326c324
< highlight_theme: night eighties
---
> highlight_theme: normal
403c401
<   enable: true
---
>   enable: false
447c445
< baidu_analytics: 06c54470f22c395ef480d6fb358497d5
---
> #baidu_analytics:
457c455
< hypercomments_id: 91544
---
> #hypercomments_id:
516,517c514,515
< jiathis:
<   uid: 2159160
---
> #jiathis:
>   ##uid: Get this uid from http://www.jiathis.com/
554c552
< google_analytics: UA-92548519-1
---
> #google_analytics:
611,613c609,611
<   enable: true
<   app_id: YHMwvrTgcfDjOXmiGY3jQ2r5-gzGzoHsz
<   app_key: JRfKfM8mRPgxMB9GOSAnix9W
---
>   enable: false
>   app_id: #<app_id>
>   app_key: #<app_key>
615c613
<   security: false
---
>   security: true
671c669
<   enable: true
---
>   enable: false
```
3. 需要安装的模块有：
``` json
{
  "name": "hexo-site",
  "version": "0.0.0",
  "private": true,
  "hexo": {
    "version": "3.6.0"
  },
  "dependencies": {
    "gulp": "^3.9.1",
    "gulp-clean-css": "^3.9.3",
    "gulp-htmlclean": "^2.7.20",
    "gulp-htmlmin": "^4.0.0",
    "gulp-minify-css": "^1.2.4",
    "gulp-uglify": "^3.0.0",
    "hexo": "^3.2.0",
    "hexo-algolia": "^1.2.4",
    "hexo-deployer-git": "^0.3.1",
    "hexo-generator-archive": "^0.1.4",
    "hexo-generator-baidu-sitemap": "^0.1.2",
    "hexo-generator-category": "^0.1.3",
    "hexo-generator-feed": "^1.2.2",
    "hexo-generator-index": "^0.2.0",
    "hexo-generator-sitemap": "^1.2.0",
    "hexo-generator-tag": "^0.2.0",
    "hexo-renderer-ejs": "^0.3.0",
    "hexo-renderer-marked": "^0.3.0",
    "hexo-renderer-stylus": "^0.3.1",
    "hexo-server": "^0.2.0",
    "hexo-symbols-count-time": "^0.3.2"
  }
}
```
4. Hexo 配置文件修改项如下：
``` yam
algolia:
  applicationID: 39IHYBUVGR
  apiKey: 4287c8f8a629343c8d2212e108417ceb
  indexName: Notes
  chunkSize: 5000

symbols_count_time:
  symbols: true
  time: true
  total_symbols: true
  total_time: true
```
5. Gulp 工具的 `gulpfile.js`:
``` js
var gulp = require('gulp');
var minifycss = require('gulp-minify-css');
var uglify = require('gulp-uglify');
var htmlmin = require('gulp-htmlmin');
var htmlclean = require('gulp-htmlclean');

// 压缩 public 目录 css
gulp.task('minify-css', function() {
    return gulp.src('./public/**/*.css')
        .pipe(minifycss())
        .pipe(gulp.dest('./public'));
});
// 压缩 public 目录 html
gulp.task('minify-html', function() {
  return gulp.src('./public/**/*.html')
    .pipe(htmlclean())
    .pipe(htmlmin({
         removeComments: true,
         minifyJS: true,
         minifyCSS: true,
         minifyURLs: true,
    }))
    .pipe(gulp.dest('./public'))
});
// 压缩 public/js 目录 js
gulp.task('minify-js', function() {
    return gulp.src('./public/**/*.js')
        .pipe(uglify())
        .pipe(gulp.dest('./public'));
});
// 执行 gulp 命令时执行的任务
gulp.task('default', [
    'minify-html','minify-css','minify-js'
]);
```
6. deploy.sh 自动部署脚本
``` sh
#!/bin/sh
rm -rf .deploy_git
export HEXO_ALGOLIA_INDEXING_KEY=4287c8f8a629343c8d2212e108417ceb
hexo clean && hexo algolia && hexo g && gulp && hexo d
```
7. 其他的配置，例如在 Sidebar 中添加微博秀、书单或者网易云音乐等的配置均在 `source/_data`，`source/friends` 和 `source/friends` 文件夹中。