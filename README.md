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

更改 next 主题中分享按钮的位置，调小字体:

``` bash
git clone https://github.com/theme-next/hexo-theme-next themes/next
cp -r patch/next themes/next
```

修改好的配置文件 `source/_data/next.yml` 会覆盖主题配置文件。

插件参考 `package.json`，手动安装命令:

``` bash
npm uninstall hexo-renderer-marked
npm install hexo-renderer-pandoc     # 解决 latex 公式与 markdown 的冲突，需要安装 pandoc

npm install hexo-algolia
npm install hexo-deployer-git        # git 部署 public 目录
npm install hexo-filter-mathjax      # 根据 title 中 mathjax: true 决定是否加载 mathjax
npm install hexo-generator-searchdb
npm install hexo-pangu
npm install hexo-symbols-count-time
npm install hexo-leancloud-counter-security

npm install hexo-generator-sitemap   # sitemap 为站点文件，用于提交 SEO
npm install hexo-generator-baidu-sitemap

npm install gulp
npm install gulp-clean-css
npm install gulp-terser
npm install gulp-htmlclean
npm install gulp-htmlmin-terser
```
