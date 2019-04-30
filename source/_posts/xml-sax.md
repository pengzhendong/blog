---
title: XML 解析之 SAX 解析
date: 2016-02-29 15:59:48
updated: 2016-02-29 16:33:43
tags: XML
---

## 前言

SAX 是一种轻量型的方法。在处理DOM的时候，需要读入整个的 XML 文档，然后在内存中创建 DOM 树，生成 DOM 树上的每个 Node 对象。当文档比较小的时候，这不会造成什么问题，但是一旦文档大起来，处理 DOM 就会变得相当费时费力。

<!-- more -->

## SAX

SAX(Simple API for XML) 不同于DOM解析，它逐行扫描文档，一边扫描一边解析，不需要将数据存储在内存中。SAX 是一个事件驱动的“推”模型，虽然它不是W3C标准，但它却是一个得到了广泛认可的API。SAX 解析器在读取文档时激活一系列事件，这些事件被推给事件处理器，然后由事件处理器提供对文档内容的访问。

常见的事件处理器有三种基本类型：

* 用于访问 XML DTD 内容的 DTDHandler；
* 用于低级访问解析错误的 ErrorHandler；
* 用于访问文档内容的 ContentHandler，最普遍使用的事件处理器。

## ContentHandler：

ContentHandler 接口的方法：

* `void startDocument()`
* `void endDocument()`
* `void startElement(String uri, String localName, String qName, Attributes attrs)`
* `void endElement(String uri, String localName, String qName)`
* `void characters(char[] ch, int start, int length)`

当 XML 解析器开始解析XML输入文档时，它会遇到某些特殊的事件，比如文档的开头和结束、元素开头和结束、以及元素中的字符数据等事件。当遇到这些事件时，XML 解析器会调用 ContentHandler 接口中相应的方法来响应该事件。

**qName = 命名空间 + ":" + localName**

## DefaultHandler：

DefaultHandler 类是 SAX2 事件处理程序的默认基类。它继承了EntityResolver、DTDHandler、ContentHandler 和 ErrorHandler 这四个接口。包含这四个接口的所有方法，所以我们在编写事件处理程序时，可以不用直接实现这四个接口，而继承该类。

``` java
public class SaxHandler extends DefaultHandler {

    //遇到文件开头事件的响应方法，不需要重写
    public void startDocument() throws SAXException
    {
        super.startDocument();
    }

    //遇到元素开头事件的响应方法
    public void startElement(String uri, String localName, String qName, Attributes attributes) throws SAXException
    {
        super.startElement(uri, localName, qName, attributes);
        //输出左括号和元素名称
        System.out.print("<");
        System.out.print(qName);

        //如果有属性，则输出所有属性
        if (attributes != null) {
            for (int i = 0; i < attributes.getLength(); i++) {
                System.out.print(" " + attributes.getQName(i) + "=\"" + attributes.getValue(i) + "\"");
            }
        }
        
        //输出右括号（由于不知道有没有子元素，所以无法像 DOM 解析那样自闭合）
        System.out.print(">");
    }

    //遇到无法识别为标记或者指令类型字符时响应函数，如回车，\t，和内容值（所以可能一个元素中会调用多次）
    public void characters(char[] ch, int start, int length) throws SAXException
    {
        super.characters(ch, start, length);
        //直接输出遇到的内容
        System.out.print(new String(ch, start, length));
    }
    
    //遇到元素开头事件的响应方法
    public void endElement(String uri, String localName, String qName) throws SAXException
    {
        super.endElement(uri, localName, qName);
        //输出结束标签
        System.out.print("</");
        System.out.print(qName);
        System.out.print(">");
    }
    
    //遇到文件结束事件的响应方法，不需要重写
    public void endDocument() throws SAXException
    {
        super.endDocument();
    }
}
```

## 主函数

``` java
public static void main(String args[])
{
    String filename = "example.xml";
    //工厂方法模式
    SAXParserFactory spf = SAXParserFactory.newInstance();

    try {
        SAXParser saxParser = spf.newSAXParser();
        saxParser.parse(new File(filename), new SaxHandler());
    } catch (SAXException e) {
        e.printStackTrace();
    } catch (ParserConfigurationException e) {
        e.printStackTrace();
    } catch (IOException e) {
        e.printStackTrace();
    }
}
```