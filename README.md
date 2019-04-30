## Git config

提交时转换为 LF，检出时不转换；允许提交包含混合换行符的文件。

``` bash
$ git config --global core.autocrlf input
$ git config --global core.safecrlf false
```

## Install

``` bash
$ npm install -g hexo-cli
$ git clone https://github.com/theme-next/hexo-theme-next themes/next
```

## Theme Config

``` bash
modified:   languages/zh-CN.yml
modified:   layout/_layout.swig
modified:   layout/_macro/post.swig
modified:   layout/_partials/share/add-this.swig
```

`languages/zh-CN.yml`:

``` yaml
   commonweal: 公益 404
+  friends: 友链
+  books: 书单
```

Move `add-this` from `layout/_layout.swig` to `layout/_macro/post.swig`, and add `<center><br>` for `add-this`.

``` yaml
{% if theme.add_this_id %}
    <div>
-        {% include '_partials/share/add-this.swig' %}
+        {% include '../_partials/share/add-this.swig' %}
    </div>
{% endif %}
```

## Plugins

### [hexo-generator-searchdb](https://github.com/theme-next/hexo-generator-searchdb)

生成搜索数据

```bash
$ npm install hexo-generator-searchdb --save
```

`_config.yml`:

```yaml
search:
  path: search.xml
  field: post
  format: html
  limit: 10000
```

### [hexo-filter-emoji](https://github.com/theme-next/hexo-filter-emoji)

支持 Emoji

``` bash
$ npm install hexo-filter-emoji --save
```

`_config.yml`:

``` yaml
githubEmojis:
  enable: true
  className: github-emoji
  inject: true
  styles:
  customEmojis:
```

### [hexo-leancloud-counter-security](https://github.com/theme-next/hexo-leancloud-counter-security)

LeanCloud 安全插件

``` bash
$ npm install hexo-leancloud-counter-security --save
```

`_config.yml`:

``` yaml
leancloud_counter_security:
  enable_sync: true
  app_id: <<your app id>>
  app_key: <<your app key>>
  username: <<your username>>
  password: <<your password>>
```

`next.yml`

``` yaml
leancloud_visitors:
  enable: true
  app_id: <<your app id>>
  app_key: <<your app key>>
  # Dependencies: https://github.com/theme-next/hexo-leancloud-counter-security
  security: true
  betterPerformance: false
```

### [hexo-filter-optimize](https://github.com/theme-next/hexo-filter-optimize)

优化页面加载速度

``` bash
$ npm install hexo-filter-optimize --save
```

`_config.yml`:

``` yaml
filter_optimize:
  enable: true
  # remove static resource query string
  #   - like `?v=1.0.0`
  remove_query_string: true
  # remove the surrounding comments in each of the bundled files
  remove_comments: false
  css:
    enable: true
    # bundle loaded css file into the one
    bundle: true
    # use a script block to load css elements dynamically
    delivery: true
    # make specific css content inline into the html page
    #   - only support the full path
    #   - default is ['css/main.css']
    inlines:
    excludes:
  js:
    # bundle loaded js file into the one
    bundle: true
    excludes:
  # set the priority of this plugin,
  # lower means it will be executed first, default is 10
  priority: 12
```

### [hexo-symbols-count-time](https://github.com/theme-next/hexo-symbols-count-time)

阅读所需时间

``` bash
$ npm install hexo-symbols-count-time --save
```

`_config.yml`

``` yaml
symbols_count_time:
  symbols: true
  time: true
  total_symbols: true
  total_time: true
```

### [theme-next-algolia-instant-search](https://github.com/theme-next/theme-next-algolia-instant-search)

Algolia 搜索

``` bash
$ git clone https://github.com/theme-next/theme-next-algolia-instant-search themes/next/source/lib/algolia-instant-search
```

`next.yml`:

``` yaml
algolia_search:
  enable: true
```

### [theme-next-three](https://github.com/theme-next/theme-next-three)

JS 3D 库

``` bash
$ git clone https://github.com/theme-next/theme-next-three themes/next/source/lib/three
```

`next.yml`:

``` yaml
three_waves: true
OR
canvas_lines: true
OR
canvas_sphere: true
```

### [theme-next-reading-progress](https://github.com/theme-next/theme-next-reading-progress)

阅读进度

``` bash
$ git clone https://github.com/theme-next/theme-next-reading-progress themes/next/source/lib/reading_progress
```

`next.yml`:

``` yaml
reading_progress:
  enable: true
  color: "#37c6c0"
  height: 2px
```

### [theme-next-bookmark](https://github.com/theme-next/theme-next-bookmark)

记录阅读进度

``` bash
$ git clone https://github.com/theme-next/theme-next-bookmark themes/next/source/lib/bookmark
```

`next.yml`:

``` yaml
bookmark: true
```

### [theme-next-pdf](https://github.com/theme-next/theme-next-pdf)

PDF

``` bash
$ git clone https://github.com/theme-next/theme-next-pdf themes/next/source/lib/pdf
```

`next.yml`:

``` yaml
# PDF tag, requires two plugins: pdfObject and pdf.js
# pdfObject will try to load pdf files natively, if failed, pdf.js will be used.
# The following `cdn` setting is only for pdfObject, because cdn for pdf.js might be blocked by CORS policy.
# So, YOU MUST install the dependency of pdf.js if you want to use pdf tag and make it work on all browsers.
# See: https://github.com/theme-next/theme-next-pdf
pdf:
  enable: true
  # Default height
  height: 500px
  pdfobject:
    # Use 2.1.1 as default, jsdelivr as default CDN, works everywhere even in China
    cdn: //cdn.jsdelivr.net/npm/pdfobject@2.1.1/pdfobject.min.js
    # CDNJS, provided by cloudflare, maybe the best CDN, but not works in China
    #cdn: //cdnjs.cloudflare.com/ajax/libs/pdfobject/2.1.1/pdfobject.min.js
```

### [theme-next-fancybox3](https://github.com/theme-next/theme-next-fancybox3)

显示图像视频

``` bash
$ git clone https://github.com/theme-next/theme-next-fancybox3 themes/next/source/lib/fancybox
```

`next.yml`:

``` yaml
fancybox: true
```

### [theme-next-quicklink](https://github.com/theme-next/theme-next-quicklink)

预加载网页中的链接

``` bash
$ git clone https://github.com/theme-next/theme-next-quicklink themes/next/source/lib/quicklink
```

`_config.yml`:

``` yaml
quicklink:
  enable: true
```

### [theme-next-fastclick](https://github.com/theme-next/theme-next-fastclick)

消除点击延迟

``` bash
$ git clone https://github.com/theme-next/theme-next-fastclick themes/next/source/lib/fastclick
```

`next.yml`:

``` yaml
fastclick: true
```

### [theme-next-pangu](https://github.com/theme-next/theme-next-pangu)

空格

``` bash
$ git clone https://github.com/theme-next/theme-next-pangu themes/next/source/lib/pangu
```

`next.yml`:

``` yaml
pangu: true
```

### [theme-next-jquery-lazyload](https://github.com/theme-next/theme-next-jquery-lazyload)

长网页延迟加载图片

``` bash
$ git clone https://github.com/theme-next/theme-next-jquery-lazyload themes/next/source/lib/jquery_lazyload
```

`next.yml`:

``` yaml
lazyload: true
```

### [theme-next-pace](https://github.com/theme-next/theme-next-pace)

网页进度条

``` bash
$ git clone https://github.com/theme-next/theme-next-pace themes/next/source/lib/pace
```

`next.yml`:

``` yaml
pace: true
```

### [theme-next-canvas-ribbon](https://github.com/theme-next/theme-next-canvas-ribbon)

网页背景彩带

``` bash
$ git clone https://github.com/theme-next/theme-next-canvas-ribbon themes/next/source/lib/canvas-ribbon
```

`next.yml`:

``` yaml
canvas_ribbon:
  enable: true
```

### [theme-next-canvas-nest](https://github.com/theme-next/theme-next-canvas-nest)

网页背景绘制

``` bash
$ git clone https://github.com/theme-next/theme-next-canvas-nest themes/next/source/lib/canvas-nest
```

`next.yml`:

``` yaml
canvas_nest:
  enable: true
  onmobile: true # display on mobile or not
  color: '0,0,255' # RGB values, use ',' to separate
  opacity: 0.5 # the opacity of line: 0~1
  zIndex: -1 # z-index property of the background
  count: 99 # the number of lines
```

### [theme-next-needsharebutton2](https://github.com/theme-next/needsharebutton)

分享系统

``` bash
$ git clone https://github.com/theme-next/theme-next-needsharebutton2 themes/next/source/lib/needsharebutton
```

`next.yml`:

``` yaml
needmoreshare2:
  enable: true
  postbottom:
    enable: true
  float:
    enable: true
```

### [theme-next-han](https://github.com/theme-next/han)

汉字标准格式

``` bash
$ git clone https://github.com/theme-next/theme-next-han themes/next/source/lib/Han
```

`next.yml`:

``` yaml
han: true
```

