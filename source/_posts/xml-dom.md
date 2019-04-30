---
title: XML 解析之 DOM 解析
date: 2016-02-29 10:39:48
updated: 2016-02-29 12:10:06
tags: XML
---

## 前言

上学期末接触了点 XML ，用它编写了 Ant 的 build 文件，当时对 XML 并不怎么了解，也就按照网上的教程，东拼西凑改出了自己所要的结果，这学期正好系统地了解一下，从解析开始。

<!-- more -->

## XML

XML(e**X**tensible **M**arkup **L**anguage)，可扩展标记语言，被设计用来传输和存储数据。个人感觉 XML 冗余信息太多，所以现在大多数人都喜欢用 Json 来存储数据而不使用 XML。

## DOM

XML DOM (Document Object Model) 定义了访问和操作 XML 文档的标准方法，DOM 把 XML 文档视为一种树结构。

通过这个 DOM 树，可以访问所有的元素。可以修改它们的内容（文本以及属性），而且可以创建新的元素。元素，以及它们的文本和属性，均被视为节点。

### 节点
根据 DOM，XML 文档中的每个成分都是一个节点。

* 整个文档是一个文档节点
* 每个 XML 标签是一个元素节点
* 包含在 XML 元素中的文本是文本节点
* 每一个 XML 属性是一个属性节点
* 注释属于注释节点

节点属性：

* x.nodeName - x 的名称
* x.nodeValue - x 的值
* x.parentNode - x 的父节点
* x.childNodes - x 的子节点
* x.attributes - x 的属性节点

节点方法：

* x.getElementsByTagName(name) - 获取带有指定标签名称的所有元素
* x.appendChild(node) - 向 x 插入子节点
* x.removeChild(node) - 从 x 删除子节点

### 解析

在这里我使用了 Java 对其进行解析，为了更好体验其文件结构，我将其解析出来后又按照原来的格式输出。

example.xml：

``` xml
<note>
	<to>George</to>
	<from>John</from>
	<heading>Reminder</heading>
	<body>Don't forget the meeting!</body>
</note>
```

例如在这个 XML 文件中，我通过 DOM 解析器能够得到这个文件的 DOM 节点树，然后能够得到该文件的任何值，这时候我就可以将它存到数组或者别的数据结构里了。这里只是单纯地将它按照原来的格式输出。

``` java
public static void main(String args[])
{
    try{
        //新建一个 Dom 解析器工厂（想了解设计模式可以看前几篇博客）
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        //通过工厂的工厂方法新建一个 Dom 解析器
        DocumentBuilder builder = dbf.newDocumentBuilder();
        //创建 DOM 节点树，文件对象位于该项目根目录下
        Document document = builder.parse(new File("example.xml"));

        //获取根节点
        Node root = document.getDocumentElement();
        //调用解析函数
        ReadByDom(root);
        //输出根节点的结束标签
        System.out.print("</"+root.getNodeName()+">");
    }catch(Exception e){
        System.out.println(e);
    }
}
        
 /**
 * 获取节点属性,分别打印属性
 * @param node
 */
public static void printAttr(Node node)
{
    NamedNodeMap nnm = node.getAttributes();
    String attr = "";

    for (int i = 0; i < nnm.getLength(); i++) {
        attr += " " + nnm.item(i).getNodeName() + "=\"" + nnm.item(i).getNodeValue() + "\"";
        System.out.print(attr);
    }
}

/**
 * 根据节点类型 ELEMENT_NODE 或者 TEXT_NODE 打印节点内容
 * @param node
 */
public static void ReadByDom(Node node)
{
    //如果是元素节点
    if (node.getNodeType() == Node.ELEMENT_NODE) {
        //打印左括号和节点名称
        System.out.print("<" + node.getNodeName());
        //如果有属性则打印属性
        if (node.hasAttributes()) {
            printAttr(node);
        }
        
        //如果还有子节点则打印右括号，开始标签打印完成
        if (node.hasChildNodes()) {
            System.out.print(">");
        } else {
            //没有子节点则为自闭标签
            System.out.print("/>");
        }

    }

    //文本节点,直接打印文本内容
    if (node.getNodeType() == Node.TEXT_NODE) {
        System.out.print(((Text)node).getWholeText());
    }

    //获取所有子节点，存到 NodeList 中
    NodeList nodes = node.getChildNodes();

    //遍历子节点,通过递归打印子节点的值
    for (int j = 0; j < nodes.getLength(); j++) {
        Node childNode = nodes.item(j);
        ReadByDom(childNode);

        //如果有子节点为元素节点并且还有子节点,输出闭合标签（因为没有子节点的已经自闭，文本节点没有闭合标签）
        if (childNode.hasChildNodes() && childNode.getNodeType() == Node.ELEMENT_NODE) {
            System.out.print("</" + childNode.getNodeName() + ">");
        }
    }
}
```

最后运行结果应该输出和原来文本一样的内容，如果文件内容较大，可以写一个单元测试来测试输出内容和文件内容是否一致。

### 单元测试

``` java
public class MainTest {
    PrintStream console = null;          // 输出流 (字符设备) console
    ByteArrayOutputStream bytes = null;  // bytes 用于缓存 console 重定向过来的字符流

    @Before
    public void setUp() throws Exception {
        bytes = new ByteArrayOutputStream();    // 分配空间
        console = System.out;                   // 获取 System.out 输出流的句柄
        System.setOut(new PrintStream(bytes));  // 将原本输出到控制台 Console 的字符流 重定向 到 bytes
    }

    @Test
    public void testMain() throws Exception {
        String args[] = {};
        Main.main(args);
        
        File file = new File("example.xml");

        //读取文件内容，存到 StringBuffer 中
        StringBuffer sb = new StringBuffer();
        try {
            InputStreamReader read = new InputStreamReader(new FileInputStream(file),"UTF-8");
            BufferedReader bufferedReader = new BufferedReader(read);
            String lineTxt = null;
            while ((lineTxt = bufferedReader.readLine()) != null) {
                sb.append(lineTxt);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        //去掉空格和换行，避免解析出来的格式和读取文件的内容不一致
        String need = sb.toString().replace(" ", "").replace("\n", "");
        String result = bytes.toString().replace(" ", "").replace("\n", ""); // bytes.toString() 作用是将 bytes 内容 转换为字符流

        assertEquals(need, result);  
    }

    @After
    public void tearDown() throws Exception {
        System.setOut(console);
    }
}
```
