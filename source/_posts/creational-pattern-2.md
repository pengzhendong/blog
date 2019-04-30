---
title: 创建型模式：单例模式
date: 2016-02-16 10:39:48
updated: 2016-02-16 11:29:13
tags: Design Patterns
---

## 前言

对于系统中的某些类来说，只有一个实例很重要，例如，在Windows中就只能打开一个任务管理器。如果不使用机制对窗口对象进行唯一化，将弹出多个窗口，如果这些窗口显示的内容完全一致，则是重复对象，浪费内存资源；如果这些窗口显示的内容不一致，则意味着在某一瞬间系统有多个状态，与实际不符，也会给用户带来误解，不知道哪一个才是真实的状态。因此有时确保系统中某个对象的唯一性即一个类只能有一个实例非常重要。

<!-- more -->

## 单例模式（Singleton pattern）

> 保证一个类仅有一个实例，并提供一个访问它的全局访问点。

单例模式用一种只允许生成对象类的唯一实例的机制，“阻止”所有想要生成对象的访问，使用工厂方法来限制实例化过程。这个方法是静态方法（类方法），因为让类的实例去生成另一个唯一实例毫无意义。

### 要点

* 一个类在整个应用中只有一个实例
* 类必须自行创建这个实例
* 必须自行向整个系统提供这个实例

### 角色

* 只提供非公有的构造函数和克隆函数（防止外部程序实例化这个类，或者克隆该类的实例）
* 提供一个保存类的唯一实例的非公有静态成员变量
* 提供一个访问这个实例的公共静态方法，从而返回唯一实例的一个引用

### 应用

虽然说 PHP 每次执行完页面都是会从内存中清理掉所有的资源，不像 Java 一样存在于应用程序的整个生命周期中，但是在实际应用中同一个页面中可能会存在多个业务逻辑，例如页面中会存在多个的数据库操作，需要 `new` 多个连接，但是因为我们只需要一个连接即可，所以 new 多个连接是对资源的浪费，这时单例模式就起到了很重要的作用，有效的避免了重复。

单例模式根据建立单例对象的时间分为**饿汉式**和**懒汉式**，即是否在类加载的时候实例化。

#### 饿汉式

“饿汉式”一开始在类加载的时候就建立这个单例对象，在获取实例的时候就返回该实例。由于 PHP 不支持在类定义时给类的成员变量赋予非基本类型的值，所以 PHP 中不支持饿汉式的单例模式。

#### 懒汉式

``` php
<?php

class Database {
    private static $instance = null;

    /**
     * Database constructor.
     * 私有的构造函数和克隆函数,防止外部程序实例化 Database 类或者克隆实例
     */
    private function __construct()
    {

    }
    private function __clone()
    {

    }

    /**
     * @return Database|null
     * $database 不存在就创建实例,然后返回
     */
    public static function getInstance()
    {
        if (self::$instance == null) {
            self::$instance = new self();
        }
        return self::$instance;
    }
}
```

在调用 getInstance 方法的时候再根据是否已存在实例而建立单例对象，而不是实例的静态成员变量在定义的时候就`new`直接建立。在 Java 中使用懒单例模式时注意线程安全问题。

### 继承

单例可以被继承，这是一个很大的好处，这便于用户 overwrite 其中的某方法，当然，继承单例的场景较少见。

``` php
<?php

class Database {
    protected static $instance = null;

    /**
     * Database constructor.
     * 私有的构造函数和克隆函数,防止外部程序实例化 Database 类或者克隆实例
     */
    private function __construct()
    {

    }
    private function __clone()
    {

    }

    /**
     * @return Database|null
     * $database 不存在就创建实例,然后返回
     */
    public static function getInstance()
    {
        if (self::$instance == null) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    public function show()
    {
        echo "我是父类\n";
    }
}

class MySQL extends Database{
    protected static $instance = null;

    public function show()
    {
        echo "我是子类\n";
    }
}
```

index.php 分别测试两个类：

``` php
<?php
require 'Database.php';

$db = Database::getInstance();
$mySql = MySQL::getInstance();

$db->show();
$mySql->show();
```

很明显测试结果并不对，因为在子类继承的 getInstance 中 `new self()` 实例化的就是父类，self::对当前类的静态引用，取决于定义当前方法所在的类(静态成员持有者是类不是对象)，使用 PHP 5.30的后期静态绑定就能解决问题。

``` php
public static function getInstance()
{
    if (static::$instance == null) {
        static::$instance = new static;
    }
    return static::$instance;
}
```

再重新运行程序就没问题了。

### 实现接口

``` php
<?php

interface Database {
    public static function getInstance();
}

class MySQL implements Database {
    protected static $instance = null;

    private function __construct()
    {

    }

    private function __clone()
    {

    }

    public static function getInstance()
    {
        if (static::$instance == null) {
            static::$instance = new static;
        }
        return static::$instance;
    }
}
```

## 静态类

一个类中所有的属性和方法都是静态的，那么这个类就是静态类。我们在使用它们的时候，直接调用它们的静态方法、访问其中的静态属性，这类所谓的“静态类”往往具备这样两个特点，一个是使用final修饰，它们往往没有子类；其二是构造器都被私有化了，不允许被构造实例。

### 区别

* 静态类可以继承类，但不能继承实例成员，不能实现接口
* 单例类可以被继承，他的方法可以被重写，而静态方法虽然可以被继承，但只能隐藏不能重写（在 Java 中）

静态类不能很好地具备面向对象封装、继承和多态中的后两点。

## 优点

* 实例控制：单例模式会阻止其他对象实例化其自己的单例对象的副本，从而确保所有对象都访问唯一实例。
* 灵活性：因为类控制了实例化过程，所以类可以灵活更改实例化过程。

## 缺点

* 开销：虽然数量很少，但如果每次对象请求引用时都要检查是否存在类的实例，将仍然需要一些开销。可以通过使用静态初始化解决此问题。
* 可能的开发混淆：使用单例对象（尤其在类库中定义的对象）时，开发人员必须记住自己不能使用new关键字实例化对象。因为可能无法访问库源代码，因此应用程序开发人员可能会意外发现自己无法直接实例化此类。
* 对象生存期：不能解决删除单个对象的问题。在提供内存管理的语言中（例如基于.NET Framework的语言），只有单例类能够导致实例被取消分配，因为它包含对该实例的私有引用。在某些语言中（如 C++），其他类可以删除对象实例，但这样会导致单例类中出现悬浮引用。