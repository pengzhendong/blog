---
title: 创建型模式：工厂模式（一）简单工厂模式
date: 2016-02-12 10:42:48
updated: 2016-02-12 11:24:17
tags: Design Patterns
---

## 前言

回家前几天粗略学习了 PHP 的设计模式，突然觉得太奇妙了，其中用到的方法解决了好多我上学期 Java 期末课设时遇到的问题，这两天再巩固一下~

工厂模式：使用工厂方法或类生成对象，而不是在代码中直接 `new`。

<!-- more -->

## 普通编程

在面向对象编程中，我们可能需要创建多个实例，所以在代码中可能会有很多实例化对象的代码，例如下面有两个类 Cat 和 Dog 继承自同一个 Poultry 接口：

![](https://s1.ax2x.com/2018/03/14/LAzLn.png)

``` php
<?php

/**
 * Interface Poultry
 * 定义接口(抽象产品)
 */
interface Poultry {
    function yell();
}

/**
 * Class Cat
 * 实现所继承的接口所定义的方法,定义Cat所特有的属性,以及方法(具体产品)
 */
class Cat implements Poultry {
    private $age;

    function yell()
    {
        echo "miao~I'm a cat.";
    }

    function setAge($age) {
        $this->age = $age;
    }

    function getAge() {
        return "I'm ".$this->age." years old";
    }
}

/**
 * Class Dog
 * 实现所继承的接口所定义的方法,定义Dog所特有的属性,以及方法(具体产品)
 */
class Dog implements Poultry {
    private $age;

    function yell()
    {
        echo "wang~I'm a dog.";
    }

    function setAge($age) {
        $this->age = $age;
    }

    function getAge() {
        return "I'm ".$this->age." years old";
    }
}
```

在 index.php 中，我们要实例化两种 Poultry 对象，分别 new 对应的类名：

``` php
<?php
require 'Poultry.php';

$cat = new Cat();
$dog = new Dog();

$cat->setAge(3);
$dog->setAge(2);

echo $cat->yell();
echo $cat->getAge();
echo "\n";
echo $dog->yell();
echo $dog->getAge();
```

## 简单工厂模式（Simple Factory）

又称静态工厂方法模式（Static Factory Method），简单工厂模式是通过一个静态方法创建对象，实质是由一个工厂类根据传入的参数，动态决定应该创建哪一个产品类（这些产品类继承自一个父类或接口）的实例。(简单工厂模式)

### 角色

* 抽象产品（Product）：简单工厂模式所创建的所有对象的父类，它负责描述所有实例所共有的公共接口（Poultry）
* 具体产品（Concrete Product）：是简单工厂模式的创建目标，所有创建的对象都是充当这个角色的某个具体类的实例（Cat、Dog）
* 工厂（Creator）：简单工厂模式的核心，它负责实现创建所有实例的内部逻辑。工厂类的创建产品类的方法可以被外界直接调用，创建所需的产品对象（Factory）

``` php
<?php
require 'Poultry.php';

/**
 * Class Factory
 * 定义工厂,根据参数实例化不同对象(工厂)
 */
class Factory {
    static function createPoultry($type)
    {
        switch($type) {
            case 'cat':
                return new Cat();
                break;
            case 'dog':
                return new Dog();
                break;
            default:
                echo "Error type!\n";
                break;
        }

    }
}
```

在 index.php 文件中就可以通过不同参数调用工厂方法生成不同对象：

``` php
<?php
require 'Factory.php';

$cat = Factory::createPoultry('cat');
$dog = Factory::createPoultry('dog');

$cat->setAge(3);
$dog->setAge(2);

echo $cat->yell();
echo $cat->getAge();
echo "\n";
echo $dog->yell();
echo $dog->getAge();
```

### OCP（开闭原则，Open-Closed Principle）

一个软件的实体应当对扩展开放，对修改关闭。即对于已有的代码，不应该对代码进行修改，而是对代码进行扩展。

### 优点

工厂类是整个模式的关键，包含了必要的逻辑判断，根据外界给定的信息，决定究竟应该创建哪个具体类的对象。通过使用工厂类，外界可以从直接创建具体产品对象的尴尬局面摆脱出来，仅仅需要负责“消费”对象就可以了。而不必管这些对象究竟如何创建及如何组织的。明确了各自的职责和权利，有利于整个软件体系结构的优化。

### 缺点

由于工厂类集中了所有实例的创建逻辑，违反了高内聚责任分配原则，将全部创建逻辑集中到了一个工厂类中；它所能创建的类只能是事先考虑到的，如果需要添加新的类，则就需要改变工厂类了。
当系统中的具体产品类不断增多时候，可能会出现要求工厂类根据不同条件创建不同实例的需求。例如添加了 Pig...等各种 Poultry 类，就必须修改 Factory 类（不符合 OCP）。

``` php
class Factory {
    static function createPoultry($type)
    {
        switch($type) {
            case 'cat':
                return new Cat();
                break;
            case 'dog':
                return new Dog();
                break;
            case 'pig':
                return new Pig();
                break;
                //......
            default:
                echo "Error type!\n";
                break;
        }

    }
}
```

这种对条件的判断和对具体产品类型的判断交错在一起，很难避免模块功能的蔓延，对系统的维护和扩展非常不利；

这些缺点在工厂方法模式中得到了一定的克服。


