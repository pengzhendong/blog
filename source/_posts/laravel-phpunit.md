---
title: Laravel 单元测试
date: 2015-11-30 19:24:44
updated: 2015-11-30 19:56:23
tags: [Laravel, PHPUnit]
---

## 前言

今天是第十三周周一，虽然接下来的时间会比较忙，比如各科的课设、考试、磨锤子。但是还是有种涅槃重生的感觉，昨晚的睡眠确实不怎么样，但是今天十分精神，已经想不起来多久没有这么早起了~让我累并快乐着吧！

<!-- more -->

## 单元测试

Laravel 中集成了PHPUnit, 测试的配置文件为根目录下的phpunit.xml，该配置文件为我们做好了所有配置工作。

### 安装

``` bash
$ wget https://phar.phpunit.de/phpunit.phar
$ chmod +x phpunit.phar
$ sudo mv phpunit.phar /usr/local/bin/phpunit
```

### 实现简单测试

``` php
public function testBasicExample()
{
    $this->visit('/')
         ->see('Laravel 5');
}
```

其中 visit 方法用于访问指定路由页面，see 方法则判断返回响应中是否包含指定字符串。到项目根目录下运行：

``` bash
$ phpunit
```

或者只测试某个文件：

``` bash
$ ./vendor/phpunit/phpunit/phpunit tests/XXXTest.php
```

### Laravel 5.1 中 Crawler 测试的方法和属性

Crawler 意为（网络）爬虫，Crawler 测试允许你在 web 应用中测试页面访问。下面是一些 Crawler 测试中常用的属性和方法：

``` php
$this->response：web应用返回的最后一个响应
$this->currentUri：当前访问的URL
visit($uri)：通过GET请求访问给定URI
get($uri, array $headers = [])：通过GET请求获取给定URI页面的内容，可以传递请求头信息（可选）
post($uri, array $data = [], array $headers = [])：提交POST请求到给定URI
put($uri, array $data = [], array $headers = [])：提交PUT请求到给定URI
patch($uri, array $data = [], array $headers = [])：提交PATCH请求到给定URI
delete($uri, array $data = [], array $headers = [])：提交DELETE请求到给定URI
followRedirects()：根据最后响应进行任意重定向
see($text, $negate = false)：断言给定文本在页面中是否出现
seeJson(array $data = null)：断言响应中是否包含JSON，如果传递了$data，还要断言包含的JSON是否与给定的匹配
seeStatusCode($status)：断言响应是否包含期望的状态码
seePageIs($uri)：断言当前页面是否与给定URI匹配
seeOnPage($uri)和landOn($uri)：seePageIs()的别名
click($name)：使用给定body、name或者id点击链接
type($text, $element)：使用给定文本填充输入框
check($element)：检查页面上的checkbox复选框
select($option, $element)：选择页面上下拉列表的某个选项
attach($absolutePath, $element)：上传文件到表单
press($buttonText)：通过使用给定文本的按钮提交表单
withoutMiddleware()：在测试中不使用中间件
dump()：输出最后一个响应返回的内容
```

### Laravel 5.1 提供给 PHPUnit 的方法和属性

下面是 Laravel 5.1 提供给 PHPUnit 使用的应用方法和属性：

``` php
$app：Laravel 5.1 应用实例
$code：Artisan命令返回的最后一个码值
refreshApplication()：刷新应用。该操作由TestCase的setup()方法自动调用
call($method, $uri, $parameters = [], $cookies = [], $files = [], $server = [], $content = null)：调用给定URI并返回响应
callSecure($method, $uri, $parameters = [], $cookies = [], $files = [], $server = [], $content = null)：调用给定HTTPS URI并返回响应
action($method, $action, $wildcards = [], $parameters = [], $cookies = [], $files = [], $server = [], $content = null)：调用控制器动作并返回响应
route($method, $name, $routeParameters = [], $parameters = [], $cookies = [], $files = [], $server = [], $content = null)：调用命名路由并返回响应
instance($abstract, $object)：在容器中注册对象实例
expectsEvents($events)：指定被给定操作触发的事件列表
withoutEvents()：无需触发事件模拟事件调度
expectsJobs($jobs)：为特定操作执行被调度的任务列表
withSession(array $data)：设置session到给定数组
flushSession()：清空当前session中的内容
startSession()：开启应用Session
actingAs($user)：为应用设置当前登录用户
be($user)：为应用设置当前登录用户
seeInDatabase($table, array $data, $connection = null)：断言给定where条件在数据库中存在
notSeeInDatabase($table, $array $data, $connection = null)：断言给定where条件在数据库中不存在
missingFromDatabase($table, array $data, $connection = null)：notSeeInDatabase()的别名
seed()：填充数据库
artisan($command, $parameters = [])：执行Artisan命令并返回码值
```

### Laravel 5.1 中 PHPUnit 的断言方法

除了标准的 PHPUnit 断言方法（如 assertEquals()、assertContains()、assertInstanceOf() 等）之外，Laravel 5.1 还提供了很多额外的断言用于帮助编写 web 应用的测试用例：

``` php
assertPageLoaded($uri, $message = null)：断言最后被加载的页面；如果加载失败抛出异常：$uri/$message
assertResponseOk()：断言客户端返回的响应状态码是否是200
assertReponseStatus($code)：断言客户端返回的响应状态码是否和给定码值相匹配
assertViewHas($key, $value = null)：断言响应视图包含给定数据片段
assertViewHasAll($bindings)：断言视图包含给定数据列表
assertViewMissing($key)：断言响应视图不包含给定数据片段
assertRedirectedTo($uri, $with = [])：断言客户端是否重定向到给定URI
assertRedirectedToRoute($name, $parameters = [], $with = [])：断言客户端是否重定向到给定路由
assertRedirectedToAction($name, $parameters = [], $with = [])：断言客户端是否重定向到给定动作
assertSessionHas($key, $value = null)：断言session包含给定键/值
assertSessionHasAll($bindings)：断言session包含给定值列表
assertSessionHasErrors($bindings = [])：断言session包含绑定错误
assertHasOldInput()：断言session中包含上一次输入
```