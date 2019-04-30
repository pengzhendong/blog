---
title: 中缀表达式求值
date: 2016-08-24 10:51:48
updated: 2016-08-24 12:13:17
tags: Algorithms
---

## 前言

OJ 真是让我又爱又恨，浪费了不少时间才解决那么一两道题，作为一名软件工程师我觉得这样效率很低，再网上看别人的解题报告的时候，都是清一色的丢一堆代码，过半天他自己都未必看得懂。。。

<!-- more -->

## 中缀表达式 

操作符以中缀形式处于操作数的中间，就是我们平时用的表达式，例如: `1 + 2 * 3`，小学我们就知道先乘除后加减，因为乘除的优先级比加减的优先级高，如果我们想先计算加减法，那么就必须用括号表示，例如: `( 1 + 2 ) * 3`

## 前缀表达式(波兰式) 

操作符以前缀形式处于操作数的前面，由波兰数学家 Jan Lukasiewicz 发明，前缀表达式是一种没有括号的算术表达式， `1 + 2 * 3` 的前缀表达式为 `+ 1 *  2 3` ，`( 1 + 2 ) * 3` 的前缀表达式为 `* + 1 2 3`

## 后缀表达式(逆波兰式) 

操作符以后缀形式处于操作数的后面，容易被计算机解析，所以比较常用， `1 + 2 * 3` 的后缀表达式为 `1 2 3 * +` ，`( 1 + 2 ) * 3` 的后缀表达式为 `1 2 + 3 * `

## 栈

对中缀表达式求值就要先把中缀表达式转化成后缀表达式，然后再解析后缀表达式求值。中缀表达式转化成后缀表达式和解析后缀表达式会用到栈这个数据结构，说白了就是一个后进先出的数组或者链表

<center>![](https://s1.ax2x.com/2018/03/14/LUKaa.png)</center>

由于 C++ `stack.h` 里面的 pop() 函数是 void 型的我用着不爽，所以自己实现了一个栈类，在出栈的时候会先返回栈顶元素。

``` c++
class myStack {
private:
    int* data;
    int Top;
public:
    myStack(int len) {
        data = new int[len];
        Top = -1;
    }
    void push(int x) {
        data[++Top] = x;
    }
    bool empty() {
    	return Top < 0;
    }
    int top() {
    	return data[Top];
    }
    int pop() {
    	return data[Top--];
    }
};
```

## 中缀->后缀

输入的中缀表达式是一个无空格的字符串，例如: `(23+34*45/(5+6+7))`，转换后的后缀表达式为: `23 34 45 * 5 6 + 7 + / +`，考虑到数字可能有多位数，所以用一个字符串数组来存储转换后的后缀表达式，转换规则:

* 读取到数字则存入后缀表达式中(注意处理是不是一个多位数)
* 读取到 `(`，入栈
* 读取到 `)`，弹出栈顶符号加入后缀表达式中，直到弹出和它匹配的 `(` ( `(` 不用加入表达式)
* 读取到 `*` 或者 `/`，因为它们优先级高，所以栈不为空且与栈顶符号优先级相同时就先弹出栈顶符号加入表达式再入栈
* 读取到 `+` 或者 `-`，因为它们优先级低，所以只要栈不为空且栈顶符号不为 `(` 时就先弹出栈顶符号加入表达式再入栈( `(` 只能在遇到匹配的 `)` 才能弹出)

一句话概括入栈规则就是: 栈为空就入栈；栈不为空 `读取到的符号优先级 > 栈顶符号优先级` 入栈， 否则栈顶符号出栈且如果栈顶符号不是 `(` 的话还要加入后缀表达式。
优先级: `(` < `➕` = `➖` < `✖️` = `➗` < `)`

``` C++
string* getSuffix(string& str) {
    int len = str.length();
    myStack ops(len);
    string* suffix = new string[len + 1];       //数组长度一定要比输入的字符串长度大，方便遍历

    int k = 0;
    if (isdigit(str[0])) suffix[k++] = str[0];  //str[0] 是数字加入后缀表达式
    else ops.push(str[0]);                      //str[0] 是左括号则入栈
    for (int i = 1; i < len; i++) {
        if (isdigit(str[i])) {                  // str[i] 是数字
    	   if (isdigit(str[i - 1])) suffix[k - 1] += str[i];  // str[i - 1] 也是数字，则它们是同一个数
    	   else suffix[k++] = str[i];
    	} else {
            if (str[i] == '(') ops.push(str[i]);// str[i] 是左括号，入栈
            else if (str[i] == ')') {           // str[i] 是右括号
                while (ops.top() != '(') suffix[k++] = ops.pop();//一直弹出栈顶符号加入表达式
                ops.pop();                      //弹出过程遇到了匹配的右括号，出栈但不用加入表达式
            } else if (str[i] == '*' || str[i] == '/') {    // str[i] 是优先级高的运算符 * /
                //栈不为空且 str[i] 优先级不大于栈顶符号优先级，一直弹出栈顶符号加入表达式
            	while (!ops.empty() && (ops.top() == '*' || ops.top() == '/')) suffix[k++] = ops.pop();
                ops.push(str[i]);               // str[i] 入栈
            } else {                            // str[i] 是优先级低的运算符 + -
                //栈不为空且 str[i] 优先级不大于栈顶符号优先级，一直弹出栈顶符号加入表达式
                while (!ops.empty() && ops.top() != '(') suffix[k++] = ops.pop();
                ops.push(str[i]);               // str[i] 入栈
            }
        }
    }
    while (!ops.empty()) suffix[k++] = ops.pop();//如果栈里还有符号则全部出栈加入表达式
    return suffix;
}
```

## 解析计算后缀表达式

``` java
string* suffix = getSuffix(str);
myStack s(str.length());                //定义一个栈用来存储计算过程结果和最终结果
for (int j = 0; suffix[j] != ""; j++) { //遍历后缀表达式，suffix 长度比较长所以肯定有空串的元素
    if (isdigit(suffix[j][0])) s.push(str2int(suffix[j]));  // suffix[j] 是数字，入栈
    else {                                                  // suffix[j] 是运算符
        int val = s.pop();                                  //出栈一个数字
        if (suffix[j] == "+") val = s.pop() + val;          //再出栈一个数字，进行运算
        else if (suffix[j] == "-") val = s.pop() - val;
        else if (suffix[j] == "*") val = s.pop() * val;
        else if (suffix[j] == "/") val = s.pop() / val;
        s.push(val);                                        //计算过程结果入栈
    }
}
cout << s.pop() << endl;                                    //输出最终结果
```