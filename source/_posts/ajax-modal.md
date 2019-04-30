---
title: Modal 使用 Ajax 动态加载内容
date: 2016-04-03 19:47:48
updated: 2016-04-03 20:44:05
tags: Ajax
---

## 前言

最近做项目的时候需要在 Bootstrap 的 Modal(模态框)中动态加载内容，于是用了 jQuery 的 Ajax 方法来发起 HTTP 请求加载远程数据，然后插入到模态框中。

<!-- more -->

## 模态框

Demo 链接：[点击](/demo/modal)

``` html
<button class="btn btn-primary btn-lg" data-toggle="modal" data-target="#myModal">弹出模态框</button>

<!-- 模态框（Modal） -->
<div class="modal fade" id="myModal" tabindex="-1" role="dialog" 
 aria-labelledby="myModalLabel" aria-hidden="true">
 <div class="modal-dialog">
    <div class="modal-content">
       <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
          <h4 class="modal-title" id="myModalLabel">模态框标题</h4>
       </div>
       <div class="modal-body">模态框内容</div>
       <div class="modal-footer">
          <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
          <button onclick="getContent()" type="button" class="btn btn-primary">获取内容</button>
       </div>
    </div>
 </div>
</div>
```

代码中比较重要的是 `button` 标签的 target 属性，点击按钮则弹出对应 id 的模态框，在模态框中，点击**获取内容**按钮则响应 `getContent()` 函数。

## Ajax

异步 JavaScript 和 XML（Asynchronous JavaScript and XML），能够在不重载整个网页的情况下，AJAX 通过后台加载数据，并在网页上进行显示。

``` javascript
<script type="text/javascript">
	function getContent() 
	{
		$.ajax({
		     type : "get",
		     url : "https://pengzhendong.cn/demo/modal/content.html",
		     timeout:1000,
		     success:function(datas){
		         $('.modal-body').html('');
		         $('.modal-body').append(datas);
		     },
	 	});
	}
</script>
```

以上代码通过发起 HTTP 请求的 GET 方法，向后台请求 url 为 `content.html` 的数据，请求成功的数据作为参数传给 success 方法，然后将其插入到 class="modal-body" 的标签中，为了重载页面，应该在插入之前将旧的数据清除。(原本 `url: content.html` 在 github 的 pages 服务上完全没问题，丢到 Coding 上之后就显示由于权限无法加载，找了一堆方法<del>没一个有用</del>之后才解决了这个问题)

Ajax 还有各种参数，目前还用不上，慢慢来吧！喜欢这种学习新知识的感觉，ajax 真强大~
