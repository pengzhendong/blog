## 安装

brew 安装 node@12 和 pandoc

``` bash
brew uninstall node
brew install node@12
brew link --overwrite --force node@12
brew install pandoc
```

npm 安装 hexo, gulp 和依赖

``` bash
npm install -g hexo-cli --save
npm install -g gulp --save
npm install
```


###  安装 next 主题

``` bash
git clone https://github.com/theme-next/hexo-theme-next themes/next
```

### 安装插件

[hexo-renderer-pandoc](https://github.com/wzpan/hexo-renderer-pandoc) 支持原生 latex，不需要转义

``` bash
npm uninstall hexo-renderer-marked --save
npm install hexo-renderer-pandoc --save
```

[hexo-symbols-count-time](https://github.com/theme-next/hexo-symbols-count-time) 阅读所需时间

``` yaml
symbols_count_time:
  symbols: true
  time: true
  total_symbols: true
  total_time: true
  exclude_codeblock: false
  awl: 4
  wpm: 275
  suffix: "mins."
```

``` bash
npm install hexo-symbols-count-time --save
```

[hexo-generator-searchdb](https://github.com/theme-next/hexo-generator-searchdb) 生成搜索数据

``` yaml
search:
  path: search.xml
  field: post
  content: true
  format: html
```

``` bash
npm install hexo-generator-searchdb --save
```

[hexo-pangu](https://github.com/theme-next/hexo-pangu) 汉字与英语之间空格

``` bash
npm install theme-next/hexo-filter-pangu --save
```
