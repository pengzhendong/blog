---
title: Java 回调机制
date: 2017-02-07 10:25:48
updated: 2017-02-07 11:33:37
tags: Java
---

## 前言

自从保研之后就没再写过博客，这期间倒不是全都荒废了，而已学会的东西越多，越觉得自己学会的都是皮毛，这段时间上课学了 OpenGL 的着色器编程，完善了大二的计算机图形学方面的知识；学会用 MatLab 进行一些简单的数字图像方面的处理；学会使用 Soot 框架对 Java 程序生成数据流图和控制流图；总体上过了一遍正则表达式。

<!-- more -->

2017年的第一篇博客，由于毕设《基于污点传播的 Android 软件脆弱性分析技术及实现》即将开始，因为在 Android 程序中并没有 main 函数入口，所以只能通过 activity 的生命周期来画控制流图，先从生命周期中的回调函数开始。

## 回调函数

> In computer programming, a callback is a reference to a piece of executable code that is passed as an argument to other code.

在 C 和 C++ 一些语言中，允许将函数指针作为参数传递给其它函数，而 JavaScript、Python 和 PHP等语言，允许简单的将函数名作为参数传递。由于 Java 缺少函数类型的参数，回调可以用传递抽象类或接口来模拟，即可以把该函数作为接口，然后传递实现了该接口的类的实例即可。

## 场景

1. Class A 实现接口 CallBack
2. Class A 中包含一个 Class B 的引用
3. Class B 有一个参数类型为 CallBack 的方法
4. Class A 的实例 a 调用 B 的方法 fun(CallBack callback)
5. Class B 的实例 b 在 fun(CallBack callback) 中调用 A 的实现自接口的方法

就像老板给员工一个任务，并且给他留了一个电话号码，让员工完成任务后给他打电话告知结果，然后老板好进行下一步工作。

在场景中老板是调用者，员工是被调用者。老板调用员工执行任务，员工完成任务后回调反馈执行结果。

所以 A 是 Boss，B 是 Staff

1. Boss 实现了 ICallBack 接口用于接收结果
2. Boss 包含 Staff 的引用，用于分配任务
3. Staff 有一个参数类型为 ICallBack 的方法，即 Boss 的实例，用于联系 Boss 反馈结果
4. Boss 调用 Staff 的 executeTask(ICallBack boss, String task)) 方法分配任务，同时将自己的电话号码给他
5. Staff 在 executeTask(ICallBack boss, String task)) 中执行完任务后，调用 Boss 实现自接口的方法 getStatus(String status)反馈结果


## 类

<center><img src="https://s1.ax2x.com/2018/03/14/LUpMy.png" width="500" /></center>

### interface ICallBack

``` java
public interface ICallBack {
    void getStatus(String status);
}
```

### class Boss

``` java
public class Boss implements ICallBack{
    private Staff staff;

    public Boss(Staff staff) {
        this.staff = staff;
    }

    public void sendTask(String task){
        System.out.println("Boss：发送的任务为：" + task);
        new Thread(() -> staff.executeTask(Boss.this, task)).start();
        System.out.println("Boss：异步发送成功");

        for (int i = 0; i < 3; i++) System.out.println("Boss：自己执行其他任务中...");
    }

    @Override
    public void getStatus(String status) {
        System.out.println("Boss：staff 回调状态为：" + status);
        System.out.println("Boss：Drink the coffee!");
    }
}
```

### class Staff

``` java
public class  Staff {
    public void executeTask(ICallBack boss , String task) {
        System.out.println("staff：接收到 boss 发送的任务为:" + task);

        for (int i = 0; i < 2; i++) System.out.println("staff：执行任务中...");

        System.out.println("staff：处理完毕，回复结果");
        boss.getStatus("Job done!");
    }
}

```

### class Main

``` java
public class Main {
    public static void main(String[] args) {
        Staff staff = new Staff();
        Boss boss = new Boss(staff);
        boss.sendTask("Buy a cup of coffee!");
    }
}
```

## 运行结果

```
Boss：发送的任务为：Buy a cup of coffee!
Boss：异步发送成功
Boss：自己执行其他任务中...
staff：接收到 boss 发送的任务为:Buy a cup of coffee!
staff：执行任务中...
Boss：自己执行其他任务中...
staff：执行任务中...
staff：处理完毕，回复结果
Boss：staff 回调状态为：Job done!
Boss：Drink the coffee!
Boss：自己执行其他任务中...
```

## Android 中的运用

回调机制在 Android 框架中用于监听用户界面操作中的作用。Android 框架就像 Boss，Button 就像 Staff；Boss 给 Staff 分配了一个监测被点击的任务，Button 被点击也就是任务完成后，调用 Android 框架的 OnClickListener 接口成员的 OnClick() 方法反馈结果，好进行下一步工作，即对点击进行响应。用 Java 实现即 main 函数就是 Android 框架。

### interface OnClickListener

``` java
public interface OnClickListener {
    void OnClick(Button b);
}
```

### class Button

``` java
public class Button {
    OnClickListener listener;

    public void click() {
        listener.OnClick(this);
    }

    public void setOnClickListener(OnClickListener listener) {
        this.listener = listener;
    }
}
```

### class Main

``` java
public class Main {
    public static void main(String[] args) {
        Button button = new Button();
        button.setOnClickListener(new OnClickListener() {
            @Override
            public void OnClick(Button b) {
                System.out.println(b.getClass().getName() + " was Clicked!");
            }
        });

        button.click();		//用户点击，系统自动调用 button.click();
    }
}
```

## 运行结果

```
Button was Clicked!
```

回调机制就像是主线程分一个子线程出来，让它去完成某些任务，当任务完成后给主线程一个反馈，然后主线程进行下一步工作。