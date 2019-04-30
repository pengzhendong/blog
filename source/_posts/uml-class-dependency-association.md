---
title: UML：类的依赖关系和关联关系
date: 2016-04-05 10:45:48
updated: 2016-04-05 11:12:01
tags: UML
---

## 前言

泛化、依赖这种词从字面上确实不好理解，刚接触面向对象的时候听起来就好高大上。

<!-- more -->

## 依赖关系

依赖关系(Dependency)是指一个事物A是独立的，另一个事物B依赖于这个事物A(A 作为 B 方法的参数、B 方法中声明了一个局部变量 A)，当 A 发生改变时，将影响依赖于它的 B。

### 代码

``` java
//独立类：书
public class Book {
    private String name;

    public Book(String name)
    {
        this.name = name;
    }

    public String getName()
    {
        return this.name;
    }
}
//独立类：笔
public class Pen {
    private String name;

    public Pen(String name)
    {
        this.name = name;
    }

    public String getName()
    {
        return this.name;
    }
}

//依赖独立类的类：人
public class Person {
    private String name;

    public Person(String name)
    {
        this.name = name;
    }

    public void usePen(Pen pen)
    {
        System.out.println(this.name + " use " + pen.getName());
    }

    public void writeBook()
    {
        Book book = new Book("<<Romeo and Juliet>>");
        System.out.println(this.name + " write " + book.getName());
    }
}
//Main
public class Main {
    public static void main(String[] args) {
        Person person = new Person("Zander");
        Pen pen = new Pen("Fountain pen");
        person.usePen(pen);
        person.writeBook();
    }
}

```

### UML 图

<img src="https://s1.ax2x.com/2018/03/14/L1e8z.png" width="300">

## 关联关系

关联关系(Association)是一种结构化的关系，它在代码中表现为一个类以属性的形式包含对另一个类的一个或多个对象的应用。这种关系比依赖更强、不存在依赖关系的偶然性、关系也不是临时性的，一般是长期性(因为是属性不是局部变量)的，而且双方的关系一般是**平等**的。

* 二元关系：一对一的关系
* 多元关系：一对多或多对一的关系（对象数组）

``` java
public class Principal {
    public String name;
}

public class Teacher {
    public String name;
    public Principal principal;
    public Student students[] = new Student[20];
}

public class Student {
    public String name;
    public Principal principal;
    public Teacher teacher = new Teacher;
}
```

* 校长、老师、学生关系是平等的(人人平等)，所以他们是关联关系
* 一个校长对应多个老师，一个老师对应多个学生，所以他们之间的关系是多元关系
* 老师认识校长，校长不一定认识老师，所以他们是单向关联
* 老师和同学之间相互认识，所以他们是双向关联

### UML 图

<img src="https://s1.ax2x.com/2018/03/14/L1KFS.png" width="300">

```
1:      表示1个
0..1:   表示0个或1个
0..*:   表示任意多个(≥0)
*:      表示任意多个(≥0)
1..*:	表示1个或多个(≥1)
```


## 聚合关系

聚合关系(Aggregation)是关联关系的特例，比关联关系的耦合性更强，表示整体和部分的关系。关联关系和聚合关系在语法上是没办法区分的，从语义上才能区分两者的区别。

``` java
public class Class {
    public Student students[];
    public setStudents(Student students[])
    {
    	balabala... //赋值
    }
}

public class Student {
    public String name;
}
```

一群学生聚合成一个班集体，毕业后班集体解散了，但是学生还存在。

### UML 图

<img src="https://s1.ax2x.com/2018/03/14/L11uh.png" width="200">

## 组合关系

组合关系(composition)是聚合关系的特例，比聚合关系的耦合性更强，同样描述了整体与部分的关系，但是当整体被销毁时，部分同时被销毁。

``` java
public class Person {
    public Hand hands[] = new Hand[2];
}

public class Hand {
}
```

### UML 图

<img src="https://s1.ax2x.com/2018/03/14/L1NL9.png" width="200">

## 聚合关系 VS 组合关系

### 聚合关系
* 整体端的重数可以大于1
* 一般有个方法生成属性，根据传过来的参数对其进行赋值

### 组合关系

* 整体端的重数必须是1
* 一般定义属性的时候就生成属性或者在构造方法中生成属性(保证它们同生共死)