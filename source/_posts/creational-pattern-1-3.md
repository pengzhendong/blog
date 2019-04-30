---
title: 创建型模式：工厂模式（三）抽象工厂模式
date: 2016-02-12 15:11:48
updated: 2016-02-12 16:26:54
tags: Design Patterns
---

## 前言

在工厂方法模式中具体工厂负责生产具体的产品，每一个具体工厂对应一种具体产品，工厂方法也具有唯一性，一般情况下，一个具体工厂中只有一个工厂方法或者一组重载的工厂方法。但是有时候我们需要一个工厂可以提供多个产品对象，而不是单一的产品对象。

<!-- more -->

## 概念

* 产品等级结构：产品等级结构即产品的继承结构，如一个抽象类是Poultry，其子类有Cat、Dog、Pig，则抽象家畜与具体的家畜之间构成了一个产品等级结构，Poultry 是父类，而具体的家畜是其子类。

* 产品族：在抽象工厂模式中，产品族是指由同一个工厂生产的，位于不同产品等级结构中的一组产品，如 catFactory 生产的 cat、wildCat，cat 位于 Poultry 产品等级结构中，wildCat 位于 Wildlife 产品等级结构中。 

![](https://s1.ax2x.com/2018/03/14/LAX3K.png)

## 抽象工厂模式（Factory Method）

又称工具箱（Kit或Toolkit）模式，提供一个创建一系列相关或相互依赖对象的接口，而无须指定它们具体的类。抽象工厂模式又称为Kit模式，属于对象创建型模式，包含的角色和工厂方法模式相同。抽象工厂模式是所有形式的工厂模式中最为抽象和最具一般性的一种形态。抽象工厂模式与工厂方法模式最大的区别在于，工厂方法模式针对的是一个产品等级结构，而抽象工厂模式则需要面对多个产品等级结构。

### 家畜族

``` php
<?php

/**
 * Interface Poultry
 * 定义接口
 */
interface Poultry {
    function yell();
}

/**
 * Class Dog
 * 实现所继承的接口所定义的方法,定义Dog所特有的属性,以及方法
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

/**
 * Class Pig
 * 实现所继承的接口所定义的方法,定义Pig所特有的属性,以及方法
 */
class Pig implements Poultry {
    private $age;

    function yell()
    {
        echo "yiyi~I'm a pig.";
    }

    function setAge($age) {
        $this->age = $age;
    }

    function getAge() {
        return "I'm ".$this->age." years old";
    }
}
```

### 野生动物族

``` php
<?php

/**
 * Interface Wildlife
 * 定义接口
 */
interface Wildlife {
    function yell();
}

/**
 * Class Wilddog
 * 实现所继承的接口所定义的方法,定义Wilddog所特有的属性,以及方法
 */
class Wilddog implements Wildlife {
    private $age;

    function yell()
    {
        echo "wang~wang~I'm a wilddog.";
    }

    function setAge($age) {
        $this->age = $age;
    }

    function getAge() {
        return "I'm ".$this->age." years old";
    }
}

/**
 * Class Wildpig
 * 实现所继承的接口所定义的方法,定义Wildpig所特有的属性,以及方法
 */
class Wildpig implements Wildlife {
    private $age;

    function yell()
    {
        echo "yi~yi~I'm a wildpig.";
    }

    function setAge($age) {
        $this->age = $age;
    }

    function getAge() {
        return "I'm ".$this->age." years old";
    }
}
```

### 工厂

``` php
<?php
require 'Poultry.php';
require 'Wildlife.php';

/**
 * Interface Factory
 * 定义接口(抽象工厂)
 */
interface Factory {
    function createPoultry();
    function createWildlife();
}

/**
 * Class DogFactory
 * 实现所继承的接口所定义的方法,定义DogFactory的方法(具体工厂)
 */
class DogFactory implements Factory {

    function createPoultry()
    {
        return new Dog();
    }

    function createWildlife()
    {
        return new Wilddog();
    }
}

/**
 * Class PigFactory
 * 实现所继承的接口所定义的方法,定义PigFactory的方法(具体工厂)
 */
class PigFactory implements Factory {

    function createPoultry()
    {
        return new Pig();
    }

    function createWildlife()
    {
        return new Wildpig();
    }
}
```

在`index.php`中就能够通过执行工厂中不同的方法生成同一产品族的不同产品：

``` php
<?php
require 'Factory.php';

$df = new DogFactory();
$houseDog = $df->createPoultry();
$wildDog = $df->createWildlife();

$pf = new PigFactory();
$housePig = $pf->createPoultry();
$wildPig = $pf->createWildlife();

$houseDog->yell();
echo "\n";
$wildDog->yell();
echo "\n";
$housePig->yell();
echo "\n";
$wildPig->yell();
```

* 增加产品族：对于增加新的产品族，工厂方法模式很好的支持了“开闭原则”，对于新增加的产品族，只需要对应增加一个新的具体工厂即可，对已有代码无须做任何修改。
* 增加新的产品等级结构：对于增加新的产品等级结构，需要修改所有的工厂角色，包括抽象工厂类，在所有的工厂类中都需要增加生产新产品的方法，不能很好地支持 OCP。

## 优点

* 抽象工厂模式隔离了具体类的生成，使得客户并不需要知道什么被创建。由于这种隔离，更换一个具体工厂就变得相对容易。所有的具体工厂都实现了抽象工厂中定义的那些公共接口，因此只需改变具体工厂的实例，就可以在某种程度上改变整个软件系统的行为。另外，应用抽象工厂模式可以实现高内聚低耦合的设计目的，因此抽象工厂模式得到了广泛的应用。
* 当一个产品族中的多个对象被设计成一起工作时，它能够保证客户端始终只使用同一个产品族中的对象。这对一些需要根据当前环境来决定其行为的软件系统来说，是一种非常实用的设计模式。
* 增加新的具体工厂和产品族很方便，无须修改已有系统，符合 OCP。

## 缺点

* 在添加新的产品对象时，难以扩展抽象工厂来生产新种类的产品，这是因为在抽象工厂角色中规定了所有可能被创建的产品集合，要支持新种类的产品就意味着要对该接口进行扩展，而这将涉及到对抽象工厂角色及其所有子类的修改，显然会带来较大的不便。
* OCP 的倾斜性（增加新的工厂和产品族容易，增加新的产品等级结构麻烦）

## 工厂模式的退化

**当抽象工厂模式中每一个具体工厂类只创建一个产品对象，也就是只存在一个产品等级结构时，抽象工厂模式退化成工厂方法模式；当工厂方法模式中抽象工厂与具体工厂合并，提供一个统一的工厂来创建产品对象，并将创建对象的工厂方法设计为静态方法时，工厂方法模式退化成简单工厂模式。**
