---
title: JavaScript 中的函数式编程
date: 2016-05-09 22:29:48
updated: 2016-05-09 23:51:42
tags: JavaScript
---

## 前言

之前接触过一些 Python，最近又频繁使用了 JavaScript，这两门语言都支持函数式编程，大学接触的几乎都是命令式编程，宣扬面向对象的思想，而函数式编程的思想更接近数学计算。

<!-- more -->

## 函数式编程(Functional Programming)

在函数式编程语言中，函数是第一类的对象，不依赖于任何其他的对象而可以独立存在。可以将函数作为参数、返回值或者一个普通的变量等。

## 作用域

JavaScript 中没有像其他强类型语言中的模块作用域：

Java：

``` java
for(int i = 0; i < 10; i++) {
	System.out.println("hello zander");
}
System.out.println(i);
```

因为在 `for` 循环中定义的 i ，而外部并没有定义，所以会报错

JavaScript：

``` javascript
for(var i = 0; i < 10; i++) {
	console.log("hello zander");
}
console.log(i);
```

上述代码不仅没有报错而且成功打印了 i 的值，这样给我们带来的麻烦比较多，当我们一个团队在开发大型项目时，不断累加的变量和方法，最后很容易出现各种冲突，所以私有变量对我们非常重要。如果想使用私有变量就可以使用匿名函数。

## 匿名函数

在函数式编程语言中，函数是可以没有名字的，因为我们有时需要用函数完成某件事，但是这个函数可能只是临时性的，那就没有理由专门为其生成一个顶层的函数对象。

### 函数定义

在 JavaScript 定义一个函数有三种方式：

``` javascript 
function foo(name) {
	console.log("hello " + name);
}
```

``` javascript 
var foo = function(name) {
	console.log("hello " + name);
}
```

``` javascript 
var foo = new Function('name', 'console.log("hello " + name);');
```

后面两种方式都是定义了一个匿名函数，然后将匿名函数赋值给 `foo` 变量

### 函数调用

* 申明一个函数然后执行

``` javascript 
(function(name) { 
	var i = 10;
	console.log("hello " + name); 
})('zander');
```

* 优先表达式，用圆括号强制执行申明的函数

``` javascript 
(function(name) { 
	var i = 10;
	console.log("hello " + name); 
}('zander'));
```

* `void` 操作符

``` javascript 
void function(name) { 
	var i = 10;
	console.log("hello " + name); 
}('zander');
```

这时候如果再在函数外部访问函数内部的局部变量的话就会提示变量未定义

``` javascript
console.log(i);
```

函数内部声明的变量，只在函数内部起作用，而且当匿名函数执行结束时，其内部定义的任何变量都会被系统销毁。这样就模拟了块级作用域，可以避免数据污染和避免内存长驻。

> 变量声明是如果不使用 var 关键字，那么它就是一个全局变量，即便它在函数内定义。

## 闭包

> 一个拥有许多变量和绑定了这些变量的环境的表达式（通常是一个函数），因而这些变量也是该表达式的一部分。

一开始看这些官方的解释我也是整个人都懵<del>逼</del>了，但是通过动手实践，理解闭包的作用之后就差不多能理解了。

闭包通常用来创建内部变量，使得这些变量不能被外部随意修改，同时又可以通过指定的函数接口来操作，就像面向对象中的 `getter` 和 `setter`。

如果我们希望

* 一个变量在内存中长驻
* 避免全局变量的污染
* 变量作为私有变量的存在

那么就可以使用闭包

就像上一个例子中的局部变量 `i` ，我想记住它的值(在内存中长驻)，并且作为一个私有变量(只能通过 get 方法获取)，但是我又不想将它作为一个全局变量(避免全局变量的污染)，这时候就可以使用闭包：

``` javascript
function foo() {
	//i j 分别作为私有变量存在
	var i = 10;
	var j = 0;
	function getI(){
		i++;            //set
		console.log(i); //get
	};
	function getJ(){
		j++;
		console.log(j);
	};
	
	//闭包
	return {
		getI: getI,
		getJ: getJ, 
	};
}
var fun = foo();
fun.getI(); //第一次调用，运行结果 11
fun.getI(); //第二次调用，运行结果 12
```

或许你有个迷惑，为什么不能直接返回这个值而是要返回一个函数？因为这样的话每次就都会对这个局部变量 i 进行初始化，不能记住 i 的值。

### 缺点：

闭包有一个非常严重的问题，那就是内存浪费问题，这个内存浪费不仅仅因为它常驻内存，更重要的是，对闭包的使用不当会造成无效内存的产生。

## 柯里化(Currying)

> 又称部分求值(Partial Evaluation)，把接受多个参数的函数变换成接受一个单一参数(最初函数的第一个参数)的函数，并且返回新函数来接受余下的参数而且返回结果。

就像在一个多元方程中，逐步消元最终得到结果，例如下面的加法求 `foo(x, y) = x^2 + y^2` ，第一步将 x = 8 代入得到 `foo(y) = 64 + y^2` 然后代入 y = 6，最终得到结果为100

``` javascript
var foo = function(x) {
  return function(y) {
    console.log(x + y);
  };
};

var tem = foo(8); //tem = function(y) { 64 + y^2; }
tem(6); //还可以继续调用 tem 函数求 64 + y^2
//或者
foo(8)(6);
```

现在对柯里化的感受就是能够使代码模块化，减少耦合增强其可维护性，例如像上面例子中，我后面要求很多 `64 + y^2` 的值(即第一个参数一样)，这时候就能够提高代码的适用性：

``` javascript
tem(3); // 64 + 9
tem(4); // 64 + 16
```