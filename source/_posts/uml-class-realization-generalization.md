---
title: UML：类的实现关系和泛化关系
date: 2016-04-04 22:26:48
updated: 2016-04-04 22:54:23
tags: UML
---

## 前言

类和类之间有几种常见的关系，刚开始接触的时候，这些关系的名字听起来十分晦涩，但是理解之后才发现，原来自己在平时写代码的时候都有意无意地用过这些关系。

<!-- more -->

## 实现关系

接口是一系列方法的声明，是一些方法特征的集合，一个接口只有方法的特征没有方法的实现，因此这些方法可以在不同的地方被不同的类实现，而这些实现可以具有不同的行为，它们的关系就叫做实现关系(Realization)。

抽象类有部分方法是自身实现了的(属于继承的关系)，实现关系指接口类和实现接口的类，一个类可以实现多个接口。

### 接口的作用

1. 接口制定了一组规范，实现接口的所有的类都必须遵守这套规则
2. 保持程序的可扩展性
3. 一个类可以实现多个接口。可以在同一个类中同时实现多个接口(单继承，多实现)

### 代码

``` java
//接口类：动物
public interface Animal {
    public void yell();
}
//实现类：猫（猫是一个动物）
public class Cat implements Animal {
    public void yell()
    {
        System.out.println("miao~I'm a cat.");
    }
}
//实现类：狗（狗是一个动物）
public class Dog implements Animal{
    public void yell() {
        System.out.println("wang~I'm a dog.");
    }
}
```

### UML 图

<img src="https://s1.ax2x.com/2018/03/14/L17tr.png" width="300">

## 泛化关系

泛化关系(Generalization)定义了一般元素和特殊元素之间的分类关系，一般元素泛化成特殊元素(建模语言)，特殊类继承一般类(开发语言)

### 代码

``` java
//一般类：动物
public class Animal {
    private int age;

    public Animal(int age)
    {
        this.age = age;
    }

    public int getAge()
    {
        return this.age;
    }

    public void yell()
    {
        System.out.println("I'm an animal.");
    }
}
//特殊类：猫
public class Cat extends Animal {
    public Cat(int age)
    {
        super(age);
    }

    public void yell()
    {
        System.out.println("miao~I'm a cat.");
    }
}
//特殊类：狗
public class Dog extends Animal{

    public Dog(int age)
    {
        super(age);
    }

    public void yell() {
        System.out.println("wang~I'm a dog.");
    }
}
```

Cat 和 Dog 类继承了 Animal 类的所有属性和方法，重写了 yell() 方法，实现了类的多态性。

### UML 图

<img src="https://s1.ax2x.com/2018/03/14/L18YO.png" width="300">