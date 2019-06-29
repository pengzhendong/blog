---
title: Java 基础总结
date: 2019-04-08 10:36:03
updated: 2019-04-08 11:23:21
tags: Java
---

## 前言

五月份就该去实习了，趁着这一个多月无所事事，正好学者刷一下 LeetCode。一直以来算法相关内容都是弱点，本科的《数据结构与算法》学得也不是很好。大三暑假为了保研曾经刷过一段时间 poj，不太会总结，纯粹就是瞎刷。由于没有什么方向保研后就又放弃了，最近在慕课网上找了一套视频学习，发现效果很好。

<!-- more -->

视频链接：[玩转算法面试](https://coding.imooc.com/class/82.html)，刚刷完数组、查找表和链表，就在阿里巴巴的实习面试中排上用场了。由于 LeetCode 题目太多，无法每道题都写一篇博客，视频中推荐的题目就直接丢 [Github](https://github.com/pengzhendong/LeetCode) 了。在刷题过程中对 Java 的传值有些疑惑，顺便记录一下。

## 基础类型

Java 一共有八种基础类型：`byte`/8、`char`/16、`short`/16、`int`/32、`float`/32、`long`/64、`double`/64 和 boolean/~。前七种类型的占用的**位数**明确给出，而 boolean 类型没有给出精确的定义，因为其在编译之后都使用 int 数据类型来代替，而 boolean 数组将会被编码成 byte 数组，因此 boolean 单独使用占 32 位，在数组中占 8 位。

Java 的八种基础类型对应八种包裹类型：`Byte`、 `Character`、`Short`、`Integer`、`Float`、`Long`、 `Double` 和 `Boolean`。这些包裹类型内部有一个对应类型的变量 `value` 用于保存数值。包裹类型会自动拆箱和装箱，即在计算数值时包裹类型会自动拆箱转为基础类型进行计算，当基础类型传入包裹类型时，又会自动包装成包裹类型。

``` java
Integer num = 1;     // 装箱
int x = num;         // 拆箱
```

## 存储区域

Java 有六大存储区域：

* 寄存器：在处理器内部而不是内存中，速度最快，但是在 Java 中无法直接控制，也感受不到。

* 栈：存放八种基本类型、数组的引用和对象的引用（即数组和对象在堆内存中的首地址）。当在一段代码块定义一个变量时，就在栈中为这个变量分配内存空间，当该变量退出该作用域后，会自动释放掉为该变量所分配的内存空间。

* 堆：存放由 `new` 创建的数组和对象。在堆中产生了一个数组或对象后，在栈中定义一个特殊的变量，让栈中这个变量的取值等于数组或对象在堆内存中的首地址，栈中的这个变量就成了数组或对象的引用变量。引用变量就相当于是为数组或对象起的一个名称，以后就可以在程序中使用栈中的引用变量来访问堆中的数组或对象。其示意图大致如下图所示，`new` 一个数组则会返回其在堆中的首地址，将其赋值给栈中的变量 `nums`：

  ``` java
  int num = 1;
  int[] nums = new int[] {1, 2};
  ```

* 静态存储区：又叫方法区，顾名思义包含的是 `static` 修饰的静态变量，即程序运行时一直存在的数据。

* 常量存储区：`static final` 修饰的常量值通常直接存放在程序代码内部，即在编译时被确定，并被保存在已编译的 .class 文件中的一些数据。

* 非 RAM 存储区：硬盘等。

## 缓存池

包裹类型的 value 被声明为 `final`，表示 value 初始化后无法重新赋值，即包裹类型内部没有改变 value 的方法。因此在自增等操作的时候，变量会指向新的对象：

``` java
Integer num = 1;
num += 1;
```

以上代码会被编译成：

``` java
Integer localInteger = Integer.valueOf(1);
localInteger = Integer.valueOf(localInteger.intValue() + 1);
```

即会取出 num 的值加一，然后再返回一个新的对象。可是 `Integer.valueOf()` 和 `new Integer()` 有什么关系呢？通过查看其源代码可知：

``` java
public static Integer valueOf(int i) {
    if (i >= IntegerCache.low && i <= IntegerCache.high)
        return IntegerCache.cache[i + (-IntegerCache.low)];
    return new Integer(i);
}
```

原来除了 `Float` 和 `Double`，Java 为其他包裹类型提供了缓存池。 `Integer` 内部维护了一个 `IntegerCache` 静态类，这个类又维护了一个 `static final Integer` 数组（默认范围为：[-128, 127]，可配置），如果缓存池中有这个值对于的对象则直接返回，否则 `new` 一个返回（不会加入缓存池）。例如：

``` java
Integer num1 = Integer.valueOf(1);
Integer num2 = new Integer(1);
Integer num3 = Integer.valueOf(128);
```



![](https://s1.ax2x.com/2019/04/08/5GQyMy.png)

如果通过反射机制修改对象的 value，那么指向这个对象的其它变量也会改变。下面代码中初始化了两个变量，编译后它们会通过 `valueOf()` 去缓存池中获取对应的对象，通过反射机制修改了 value 的值，缓存池中对象的值也会改变，最后导致 val 的值改变：

```java
import java.lang.reflect.Field;

public class Main {
    public static void main(String[] args) throws Exception {
        Integer num = 1;
        Integer val = 1;
        try {
            Field field = Integer.class.getDeclaredField("value");
            field.setAccessible(true);
            field.set(num, 2);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        System.out.println(val);
    }
}
```

其他类型对应的缓冲池如下：

* Boolean: true & false
* Byte: 所有 byte 值
* Short: [-128, 127]
* Character: [\u0000, \u007F]

## String

除了上述类型，`String` 类型也被声明为 `final`，因此它也不可继承。在 Java 8 中，`String` 内部使用 `char` 存储数据，在 Java 9 之后则改用 `byte` 数组，同时使用变量 `coder` 来标记使用了哪种编码。

``` java
public final class String implements java.io.Serializable, Comparable<String>, CharSequence {
    /** The value is used for character storage. */
    private final byte[] value;
    /** The identifier of the encoding used to encode the bytes in {@code value}. */
    private final byte coder;
}
```

value 被声明为 `final`，因此 value 数组初始化以后就不能再指向其他数组，即 `String` 类的内部没有改变 value 数组的方法。同样可以使用反射机制修改 `String` 的值，需要注意的是，当调用 `hashCode()` 一次以后就会保存哈希值，再次调用则不会重新计算：

``` java
public int hashCode() {
    int h = hash;
    if (h == 0 && value.lenght > 0) {
        hash = h = isLatin1() ? StringLatin1.hashCode(value)
        					  : StringUTF16.hashCode(value);
    }
    return h;
}
```

下面代码中 `addressOf(Object o)` 会将对象的引用转化成一个长整型地址；在主函数中定义了一个字符串 "Hello"，输出其地址和哈希值，用反射机制修改其内容为 "World" 后再次输出地址和哈希值：

``` java
import java.lang.reflect.Field;
import sun.misc.Unsafe;

public class Main {
    private static Unsafe unsafe;
    static {
        try {
            Field field = Unsafe.class.getDeclaredField("theUnsafe");
            field.setAccessible(true);
            unsafe = (Unsafe) field.get(null);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    public static long addressOf(Object o) throws Exception {
        Object[] array = new Object[] { o };
        long baseOffset = unsafe.arrayBaseOffset(Object[].class);
        int addressSize = unsafe.addressSize();
        long objectAddress;
        switch (addressSize) {
            case 4:
                objectAddress = unsafe.getInt(array, baseOffset);
                break;
            case 8:
                objectAddress = unsafe.getLong(array, baseOffset);
                break;
            default:
                throw new Error("Unsupported address size: " + addressSize);
        }
        return (objectAddress);
    }

    public static void main(String[] args) throws Exception {
        String str = "Hello";
        System.out.println("Address: " + addressOf(str) + " Value: " + str + " HashCode: " + str.hashCode());

        try {
            Field field = String.class.getDeclaredField("value");
            field.setAccessible(true);
            field.set(str, "World".getBytes());
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        System.out.println("Address: " + addressOf(str) + " Value: " + str + " HashCode: " + str.hashCode());
    }
}
```

最终输出结果为：

```
Address: 2353254184 Value: Hello HashCode: 69609650
Address: 2353254184 Value: World HashCode: 69609650
```

可以看到只有字符串内容发生改变，而地址和哈希值都有发生变化。大部分情况下都是根据哈希值来识别一个字符串，所以反射修改字符串内容属于非常危险的操作！

### String 常量池

String 常量池保存着所有字符串字面量 (literal strings)，即在编译时期就确定的字面量，还可以使用 `intern()` 方法将字符串添加到常量池中。

> When the intern method is invoked, if the pool already contains a string equal to this {@code String} object as determined by the {@link #equals(Object)} method, then the string from the pool is returned. Otherwise, this {@code String} is added to the pool and a reference to this {@code String} object is returned. 

``` java
String str1 = "Hello";			// 字面量赋值，"Hello" 为字面量
String str2 = "Hel" + "lo";		// 在编译阶段优化成 String str2 = "Hello";
String str3 = new String("World");	// new 创建对象，"World" 为字面量
String str4 = str2.intern();		// 将 str2 的内容加入常量池，并且返回其在常量池中的引用
```

在类加载阶段会将所有字面量加入常量池，即常量池中有 "Hello" 和 "World"。编译阶段 "Hel" + "lo" 会被优化成 "Hello"，因此 str1 和 str2 指向常量池中同一个字符串；str3 会根据字面量 "World" 的内容在堆中重新创建一个对象，`String` 的构造函数如下所示：

``` java
public String(String original) {
    this.val = original.value;
    this.hash = original.hash;
}
```

虽然在堆中重新构造了一个对象，但是并没有复制 value 数组的内容，而是指向同一个 `byte` 数组；将 str3 的内容加入常量池，常量池中有 "World"，所以直接返回其在常量池中的引用给 str4。

![](https://s1.ax2x.com/2019/04/08/5GQK6K.png)

## 传值

Java 与 C/C++ 最大的不同就是 Java 无法操作指针，上面的 `addressOf(Object o)` 函数也只能将一个对象的地址转化成长整型地址，并不能获取基本类型的地址。因此 Java Pass By Value，即传的都是值，只不过这个值有可能是对象的引用。

### 基础类型

``` java
public static void changeInt(int value) { value += 1; }
public static void main(String[] args) {
    int num = 1;
    changInt(num);
    System.out.println(num);
}
```

调用 `changeInt()` 的时候会将参数 num 拷贝一份，因此不会影响主函数中的 num 变量，即为值传递。

### 包裹类型 & String

``` java
public static void changeStr(String value) { value += "World"; }
public static void main(String[] args) {
    String str = "Hello";
    changStr(str);
    System.out.println(str);
}
```

调用 `changeStr()` 的时候会将参数 str （即常量池中 "Hello" 的地址）拷贝一份，因此 value 变量和 str 变量同样指向常量池中的 "Hello"。由于 `String` 不可变，对字符串进行拼接不会对原有字符串产生变动，而是直接生成一个新的字符串 "HelloWorld"，返回其地址给 value 变量。因此不会影响主函数中的 str 变量，所以也是值传递。

### 容器类型

``` java
public static void changeList(List<Integer> value) { value.add(1); }
public static void main(String[] args) {
    List<Integer> list = new LinkedList<>();
    changeList(list);
    System.out.println(str);
}
```

调用 `changeList()` 的时候会将参数 list （即堆中新建的 `LinkedList` 的地址）拷贝一份，因此 value 变量和 list 变量同样指向堆中的 `LinkedList`。因此在 `changeList()` 函数中对 value 的操作会影响主函数中的 list 变量，所以虽然是值传递（传的是 `LinkedList` 的地址），也可以认为传递的是引用。