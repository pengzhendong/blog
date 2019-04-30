#!/bin/sh

git add . &&
git commit -m "Commit before deploy" &&
git push &&

rm -rf .deploy_git &&
export HEXO_ALGOLIA_INDEXING_KEY=4287c8f8a629343c8d2212e108417ceb &&
hexo clean && hexo algolia && hexo g && gulp && hexo d