---
title: JavaScript 验证上传文件大小
date: 2015-10-10 19:42:42
updated: 2015-10-10 20:34:20
tags: JavaScript
---

## 前言

目前工作任务终于告一段落了，今天发现之前写的文件上传的代码有点小瑕疵，就是上传图片如果超过 2M 就会出错，因为七牛云好像限制了上传图片的大小，所以就用 JavaScript 在文件选中之后，上传之前对文件的大小进行判断，网上找了好的资料都不尽人意，我的身边就躺着一本《JavaScript 编程全解》呢，我居然忽略它。看了几眼，分分钟解决问题。

<!-- more -->

## File 对象

文件的选择:

* 通过拖动于释放功能进行选择(目前还用不上)
* 通过文件选择对话框进行选择

`<input type="file">`的属性一览

| 属性名 | 说明 |
| ----- | ---- |
| accept | 以 MIME Type 来指定允许选择的文件类型。可以通过逗号分隔符来同时指定多种文件类型 |
| multiple | 允许同时选择多个文件 |
| files | 含有所选择文件的 File 对象的数组 |
| onchange |  在文件被选择时将将被执行的事件处理程序 |

### HTML 代码

``` html
<input type="file" accept="image/*" id="file">
{{--限制只能上传图片文件--}}
<input type="submit" value="上传"/>
```

accept 的属性除了 image/\*、 还有audio/\*、video/\* 。如果需要进一步限制选择的图片文件的格式，则可以通过逗号分隔符的形式来制定，如"image/png, image/gif"来指定 accept 属性所允许的 MIME Type。

File 对象的接口

| 属性名 | 说明 |
| ----- | ---- |
| name |  文件名 |
| size | 文件尺寸(单位 byte) |
| type | 文件类型(MIME Type) |
| lastModifiedData |  文件的最后更新时间 |
| slice(start, end, contentType) |  切取文件的一部分 |

### JavaScript 代码

``` javascript
<script type="text/javascript">
    document.getElementById('file').onchange = function(event) {
        var file = event.target.files[0];
        if (file.size/1024/1024 > 2) {
            alert('图片不能大于2M');
            document.getElementById('file').value="";   //清空已选资源
        }
    }
</script>
```
    
好吧，就单纯这本书帮我解决了一个问题这一点来说，我就应该把它看完，趁着最近没什么工作~