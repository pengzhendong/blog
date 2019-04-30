---
title: 创建型模式：工厂模式（二）工厂方法模式
date: 2016-02-12 12:42:48
updated: 2016-02-12 14:23:41
tags: Design Patterns
---

## 前言

简单工厂模式系统中的具体产品类不断增多时候，可能会出现要求工厂类根据不同条件创建不同实例的需求。这种对条件的判断和对具体产品类型的判断交错在一起，很难避免模块功能的蔓延，对系统的维护和扩展非常不利。而工厂方法模式在很大程度上克服这个缺点，遵守 OCP。

<!-- more -->

## 工厂方法模式（Factory Method）

又称多态工厂模式（Polymorphic Factory），定义一个创建产品对象的工厂接口，将实际创建工作放到到子类当中。实质是为创建不同对象设置不同工厂，让每个工厂专门生产某种产品。

### 角色

* 抽象产品(Product)：工厂方法模式所创建的对象的超类型，也就是产品对象的共同父类或共同拥有的接口
* 具体产品(Concrete Product)角色：这个角色实现了抽象产品角色所定义的接口。某具体产品有专门的具体工厂创建，它们之间往往一一对应
* 抽象工厂(Creator)：是工厂方法模式的核心，与应用程序无关。任何在模式中创建的对象的工厂类必须实现这个接口
* 具体工厂(Concrete Creator)：这是实现抽象工厂接口的具体工厂类，包含与应用程序密切相关的逻辑，并且受到应用程序调用以创建产品对象

工厂方法模式是简单工厂模式的延伸。在工厂方法模式中，核心工厂类不在负责产品的创建，而是将具体的创建工作交给子类去完成。也就是后所这个核心工厂仅仅只是提供创建的接口，具体实现方法交给继承它的子类去完成。当我们的系统需要增加其他新的对象时，我们只需要添加一个具体的产品和它的创建工厂即可，不需要对原工厂进行任何修改，这样很好地符合了OCP 原则。

添加具体产品：

``` php
class Cat implements Poultry {
	//balabala
}

class Dog implements Poultry {
	//balabala
}

class Pig implements Poultry {
	//balabala
}
```

添加对应的创建工厂：

``` php
<?php
require 'Poultry.php';

/**
 * Interface Factory
 * 定义接口(抽象工厂)
 */
interface Factory {
    function createPoultry();
}

/**
 * Class CatFactory
 * 实现所继承的接口所定义的方法,定义CatFactory的方法(具体工厂)
 */
class CatFactory implements Factory {

    function createPoultry()
    {
        return new Cat();
    }
}

class DogFactory implements Factory {

    function createPoultry()
    {
        return new Dog();
    }
}

class PigFactory implements Factory {

    function createPoultry()
    {
        return new Pig();
    }
}
```

这样在 index.php 中就只需要定义不同的工厂，然后就可以通过不同的工厂大批生产对象。

``` php
$catFactory = new CatFactory();
$cat = $catFactory->createPoultry();

$dogFactory = new DogFactory();
$dog = $dogFactory->createPoultry();

$snakeFactory = new SnakeFactory();
$snake = $snakeFactory->createPoultry();

$pigFactory = new PigFactory();
$pig1 = $pigFactory->createPoultry();
$pig2 = $pigFactory->createPoultry();
```

## 优点

* 在工厂方法中，用户只需要知道所要产品的具体工厂，无须关系具体的创建过程，甚至不需要具体产品类的类名。
* 在系统增加新的产品时，我们只需要添加一个具体产品类和对应的实现工厂，无需对原工厂进行任何修改，很好地符合了 OCP。

## 缺点

每次增加一个产品时，都需要增加一个具体类和对象实现工厂，使得系统中类的个数成倍增加，在一定程度上增加了系统的复杂度，同时也增加了系统具体类的依赖。




