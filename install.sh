#!/bin/sh

brew uninstall node
brew install node@12
brew link --overwrite --force node@12

npm install -g hexo-cli --save
npm install -g gulp --save
cat <<EOF > package.json
{
  "name": "hexo-site",
  "version": "0.0.0",
  "private": true,
  "scripts": {
    "build": "hexo generate",
    "clean": "hexo clean",
    "deploy": "hexo deploy",
    "server": "hexo server"
  },
  "hexo": {
    "version": "4.2.1"
  },
  "dependencies": {
    "hexo": "^4.2.1",
    "hexo-generator-archive": "^1.0.0",
    "hexo-generator-category": "^1.0.0",
    "hexo-generator-index": "^1.0.0",
    "hexo-generator-tag": "^1.0.0",
    "hexo-renderer-ejs": "^1.0.0",
    "hexo-renderer-stylus": "^1.1.0",
    "hexo-renderer-marked": "^2.0.0",
    "hexo-server": "^1.0.0"
  }
}
EOF

# 安装 next 主题
# https://github.com/theme-next/hexo-theme-next
# git clone https://github.com/theme-next/hexo-theme-next themes/next
# cd themes/next && git pull
# cp themes/next/_config.yml source/_data/next.yml

# hexo-renderer-pandoc 支持原生 latex，不需要转义
# https://github.com/wzpan/hexo-renderer-pandoc
npm uninstall hexo-renderer-marked --save
npm install hexo-renderer-pandoc --save

# hexo-symbols-count-time 阅读所需时间
# https://github.com/theme-next/hexo-symbols-count-time
# symbols_count_time:
#   symbols: true
#   time: true
#   total_symbols: true
#   total_time: true
#   exclude_codeblock: false
#   awl: 4
#   wpm: 275
#   suffix: "mins."
npm install hexo-symbols-count-time --save

# hexo-generator-searchdb 生成搜索数据
# https://github.com/theme-next/hexo-generator-searchdb
# search:
#   path: search.xml
#   field: post
#   content: true
#   format: html
npm install hexo-generator-searchdb --save

# hexo-pangu 汉字与英语之间空格
# https://github.com/theme-next/hexo-pangu
npm install theme-next/hexo-filter-pangu --save

# theme-next-pace 进度条
# https://github.com/theme-next/theme-next-pace
# pace:
#   enable: true
#   # Themes list:
#   # big-counter | bounce | barber-shop | center-atom | center-circle | center-radar | center-simple
#   # corner-indicator | fill-left | flat-top | flash | loading-bar | mac-osx | material | minimal
#   theme: minimal
git clone https://github.com/theme-next/theme-next-pace source/lib/pace
# cd themes/next/source/lib/pace && git pull

# theme-next-algolia-instant-search 搜索
# https://github.com/theme-next/theme-next-algolia-instant-search
# algolia_search:
#   enable: true
git clone https://github.com/theme-next/theme-next-algolia-instant-search source/lib/algolia-instant-search
# cd themes/next/source/lib/algolia-instant-search && git pull
# export HEXO_ALGOLIA_INDEXING_KEY=4287c8f8a629343c8d2212e108417ceb && hexo algolia

# theme-next-reading-progress 阅读进度
# https://github.com/theme-next/theme-next-reading-progress
# reading_progress:
#   enable: true
#   color: "#37c6c0"
#   height: 2px
git clone https://github.com/theme-next/theme-next-reading-progress source/lib/reading_progress
# cd themes/next/source/lib/reading_progress && git pull

# theme-next-fancybox3 视频
# https://github.com/theme-next/theme-next-fancybox3
# fancybox: true
git clone https://github.com/theme-next/theme-next-fancybox3 source/lib/fancybox
# cd themes/next/source/lib/fancybox && git pull
