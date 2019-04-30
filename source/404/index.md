title: 404
date: 2016-02-13 22:03:21
comments: false
permalink: /404
---

<style>
.post-title {
  display: none !important;
}
.posts-expand {
  padding-top: 0px !important;
}
div.mod_lost_child {
  max-width: none;
  width: 680px !important;
}
</style>

<script type="text/javascript" src="https://qzonestyle.gtimg.cn/qzone_v6/lostchild/data.js"></script>
<script type="text/javascript">

(function(){var CHILD_TPL='<div class="mod_lost_child"><div class="hd"><p class="wrong">404</p><p class="other_info">您访问的页面找不回来了！<span>但我们可以一起寻找失踪宝贝</span></p></div><div class="bd"><div class="child_info"><p class="child_pic"><a href="<%= url %>"><img src="https://qzonestyle.gtimg.cn/qzone_v6/lostchild/images/<%= child_pic %>" onload="window.child.resizePic(this);" alt="" title="<%= name %>" /></a></p><div class="info_person"><p><span>姓 名：</span><%= name %></p><p><span>性 别：</span><%= sex %></p><p><span>出生日期：</span><%= birth_time %></p><p><span>失踪时间：</span><%= lost_time %></p><p><span>失踪地点：</span><%= lost_place %></p><p><span>失踪人特征描述：</span><%= child_feature %></p></div></div></div><div class="ft"><p class="support_company"><a href="http://e.t.qq.com/Tencent-Volunteers" title="腾讯志愿者">腾讯志愿者</a></p><p class="baby_back"><a href="http://bbs.baobeihuijia.com/" title="宝贝回家">宝贝回家</a></p><p class="side_infos"><a href="<%= url %>" title="查看详细信息">详细</a><span class="symbol"></span><a href="/">返回首页</a></p></div></div>';CHILD=window.child={init:function(){var self=this;self.insertCss();self.showPage(jsondata);},insertCss:function(){var link=document.createElement("link");link.href='https://qzonestyle.gtimg.cn/qzone_v6/lostchild/style.css';link.rel='stylesheet';link.rev='stylesheet';link.media='screen';document.getElementsByTagName('head')[0].appendChild(link);},tmpl:function(str,data){var fn=!/\W/.test(str)?cache[str]=cache[str]||tmpl(document.getElementById(str).innerHTML):new Function("obj","var p=[],print=function(){p.push.apply(p,arguments);};"+"with(obj){p.push('"+
str.replace(/[\r\t\n]/g," ").split("<%").join("\t").replace(/((^|%>)[^\t]*)'/g,"$1\r").replace(/\t=(.*?)%>/g,"',$1,'").split("\t").join("');").split("%>").join("p.push('").split("\r").join("\\'")+"');}return p.join('');");return data?fn(data):fn;},showPage:function(datas){var self=this;self.renderTpl(CHILD_TPL,datas);},renderTpl:function(tpl,datas){var self=this;var child=self.getChild(datas);var contacts=datas.contacts;var html=self.tmpl(tpl,{name:child.name,sex:child.sex,birth_time:child.birth_time,lost_time:child.lost_time,lost_place:child.lost_place,child_feature:child.child_feature,child_pic:child.child_pic,url:child.url});document.write(html);},resizePic:function(imgD){var ele=document.getElementsByTagName('IMG')[0];_adjustSize(ele);function _adjustSize(img){var maxWidth=220;var maxHeight=330;var offsetLeft,offsetTop;if(img.width>0&&img.height>0){var widthRate=maxWidth/img.width;var heightRate=maxHeight/img.height;if(widthRate>=1){offsetTop=img.height*(heightRate-1)/2;offsetLeft=0;}
else{if(heightRate<1){if(widthRate>=heightRate){imgD.width=maxWidth;imgD.height=img.height*widthRate;offsetTop=img.height(heightRate-widthRate)/2;offsetLeft=0;}
else{imgD.width=img.width*heightRate;imgD.height=maxHeight;offsetTop=0;offsetLeft=img.width*(widthRate-heightRate)/2;}}else{offsetTop=img.height*(heightRate-1)/2;offsetLeft=img.width*(widthRate-1)/2;}}}
imgD.style.marginLeft=offsetLeft+"px";imgD.style.marginTop=offsetTop+"px";}},getChild:function(datas){var self=this;var child_data=datas['data'];var length=child_data.length;var index=Math.floor(Math.random()*length);return child_data[index];}};CHILD.init();})();/*  |xGv00|10f52e2e8d0aa485a76452df9765b55d */
</script>