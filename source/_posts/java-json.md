---
title: Java 中 Json 数组和 Json 对象文件的读取
date: 2016-01-15 09:36:59
updated: 2016-01-15 10:11:53
tags: Json
---

## 前言

一个学期的学习终于落下帷幕。离家一年，归期将至反倒觉得乡近情更怯，这一年真的成长了很多，虽然能力还不够强大，但我坚信那是迟早的事。这一年里我收获了爱情，爱情的酸甜苦辣真的让人流连忘返，刚刚结束小学期课设的答辩，由于回宿舍无所事事，留下来写一篇博客倒也快哉~

<i class="fa fa-map-marker fa-lg"></i> 记于  北京工业大学  软件学院  518

二零一六年一月十五日

---

<!-- more -->

## 下载 JSON 的包

到 JSON 的[官网](http://www.json.org/json-zh.html)中下载对应的包文件，JSON 的 jar 包是一个beans, collections, maps, java arrays, XML 和 JSON 互相转换的包，主要就是用来解析Json数据。

## Json 语法

JSON 语法是 JavaScript 对象表示法语法的子集。

* 数据在名称/值对中
* 数据由逗号分隔
* 花括号保存对象
* 方括号保存数组

## 读取文件

首先要将文件中的内容读取出来，即一个字符串。说白了，一个 JSON 文件存储的就是一个比较长的字符串，只不过这个字符串的格式比较特殊，我们能过通过 JSON 的包将其转换成我们所需要的格式。

``` java
public class ReadFile {
    /**
     * 读取文件,返回文件内容
     * @param path
     * @return
     * @throws IOException
     */
    public static String ReadFile(String path) throws IOException {

        File file = new File(path);

        if(!file.exists()||file.isDirectory()) {
            throw new FileNotFoundException();
        }

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
        return sb.toString();
    }
}
```

**ReadFile** 的`ReadFile`静态方法需要提供一个文件的路径的参数，然后读取文件，返回一个字符串，即文件的内容。

## Json 数组

### 简单的数组

``` json
[
  "pengzhendong",
  "randy"
]
```

``` java
JSONArray items = JSONArray.fromObject(result);

for (int i = 0; i < items.size(); i++) {
    name = items.getString(i);
    System.out.println(name);
}
```

以上代码将会遍历数组，输出数组中内容。

### 对象数组

如果数组中的内容是对象的形式，则应该根据根据 key 获取属性值。

``` json
[
  { "firstName":"Bill" , "lastName":"Gates" },
  { "firstName":"George" , "lastName":"Bush" },
  { "firstName":"Thomas" , "lastName": "Carter" }
]
```

``` java
JSONArray items = JSONArray.fromObject(result);

for (int i = 0; i < items.size(); i++) {

    firstName = items.getJSONObject(i).getString("firstName");
    lastName = items.getJSONObject(i).getString("lastName");
    System.out.println(firstName + " " +lastName);

}
```

以上代码将获取数组的长度，遍历 JSON 数组中的对象，根据 key 打印里面对象中的属性。

## Json 对象

### 简单的对象

``` json
{
  "name": "pengzhendong",
  "phone": 110
}
```

``` java
JSONObject objs = JSONObject.fromObject(result);
Iterator iterator = objs.keys();
String key = "";

while (iterator.hasNext()) {
    key = (String) iterator.next();
    result = objs.getString(key);

    System.out.println(result);
}
```

以上代码将会通过迭代查找 key，然后通过 key 获取 value。

### 对象数组

``` json
{
  "id": "0001",
  "project": [
    "math",
    "english"
  ]
}
```

``` java
JSONObject obj = JSONObject.fromObject(result);

JSONArray projects = JSONArray.fromObject(obj.getString("project"));

for (int i = 0; i < projects.size(); i++) {
    String project = projects.getString(i);
    
    System.out.println(project);
}
```

另外还有各种嵌套的形式，总之只要学会简单的数组和对象形式的，然后根据具体的文件格式具体分析就差不多能解决问题了。

