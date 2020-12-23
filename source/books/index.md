---
title: 书单
date: 2015-01-01 00:00:00
updated: 2015-01-01 00:00:00
type: "books"
comments: false
---

<style>
.post-title {
  display: none !important;
}
.posts-expand {
  padding-top: 0px !important;
  height: 0px !important;
  weight: 0px !important;
}
h2 {
  padding: 0px !important;
  margin: 0px !important;
}
div.content-wrap {
  padding-top: 0px !important;
}
div.img {
  margin: 0px 5px 25px 5px;
  display: inline-block;
}
div.img img {
  border: 1px solid black !important;
  padding: 0px !important;
  margin: 0px !important;
  width: 135px;
  height: 189px; 
  display: inline;
}
div.date {
  margin: 5px 8px 0px 8px;
  padding: 3px 3px 3px 3px;
  border-radius: 3px;
  color: #fff;
}
div.name {
  width: 119px;
  height: 56px;
  margin: 0px 5px 0px 5px;
  padding: 3px 3px 3px 3px;
}
p.image-caption {
  display: none !important;
}
</style>

<script src="https://cdn.bootcss.com/jquery/1.10.2/jquery.min.js"></script>

<div style="text-align: center"><h2 id="books">阅读书单</h2><p id="books_count"></p></div>
<div id="books_read" style="text-align: center"></div>

<script type="text/javascript">
    $(document).scroll(function (){
        if ($(document).scrollTop() > '355') {
        	$('.sidebar').offset({top:$(document).scrollTop()+10});
        }else if($(document).scrollTop() <= '355') {
        	$('.sidebar').offset({top:355});
        };
    });
</script>

<script type="text/javascript">
	jQuery(window).resize(function() { $(".content-wrap").height($(".post-body").height() + 65); });

  function sort(a, b) {
    return new Date(a.date).getTime() - new Date(b.date).getTime();
  }

	$(document).ready(function() {
		$.getJSON("books.json", function(books) {
      var count = books.length;
      $("#books_count").html(count);

      books.sort(sort).forEach(function(book) {
        appendContent(book);
      })
    })
  });

	function appendContent(book) {
    var year = book.date.substring(0, 4);
		var impression_url = '<a href="' + year + '#' + book.name + '"><img src="' + year + '/covers/' + book.name + '.jpg" title="跳转到读书感悟"></a>';
		var douban_url = '<a target="_blank" href="' + book.url + '" title="跳转到豆瓣读书"><div class="name">' + book.name + '</div></a>'
		var date_color = '<div class="date" style="background-color: #5cb85c; border-color: #4cae4c;">' + book.date + '</div>';
		var content = '<div class="img" display="inline-block">' + impression_url + douban_url + date_color + '</div>';
    
		$("#books_read").html(content + $("#books_read").html());
		$(".content-wrap").height($(".post-body").height() + 65);
	}
</script>
