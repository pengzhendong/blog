---
title: 友链
date: 2015-01-01 00:00:00
updated: 2015-01-01 00:00:00
type: "friends"
---

<style>
.post-title {
  display: none !important;
}
.posts-expand {
  padding-top: 0px !important;
}
</style>

## 致朋友

<blockquote class="blockquote-center">君子上交不诌，下交不渎<br><font style="font-weight:bold;font-style:italic;">《周易》</font></blockquote>

* 如果你热爱生活
* 如果你乐于分享
* 如果你广结善缘

那么就交换一个友情链接吧！只要在评论中留下站点即可~

<iframe frameborder="no" border="0" marginwidth="0" marginheight="0" width=330 height=300 src="//music.163.com/outchain/player?type=0&id=153164758&auto=1&height=4500"></iframe>

## 友情链接

<script src = "https://cdn.wilddog.com/js/client/current/wilddog.js" ></script>
<script src="https://cdn.bootcss.com/jquery/1.10.2/jquery.min.js"></script>

<div id="friend-links"></div>

<style type="text/css">
div.friend
{
	margin:5px 5px 0px 5px;
	padding:3px 3px 3px 3px;
	border-radius:3px;
	color: #fff;
}
</style>

<script type="text/javascript">
	function sort(a, b) {
		return new Date(a.date).getTime() - new Date(b.date).getTime();
	}
	
	$(document).ready(function() { 
		$.getJSON("friends.json", function(friends) {
			friends.sort(sort).forEach(function(friend) {
				appendContent(friend);
			})
		})
	}); 
	
	function appendContent(friend) {
		if (friend.sex == "man") {
			var sex = "fa-mars"
		} else if(friend.sex == "woman") {
			var sex = "fa-venus"
		}
		
		var html = '<a style="margin-left:2mm" class="btn" href="' + friend.url + '" target="_blank"><i class="fa ' + sex + '">' + friend.name + '</i></a>';
	
		$('#friend-links').append(html);
	
	}
</script>