---
title: intent 的使用 
date: 2015-10-26 23:13:27
updated: 2015-10-26 23:55:55
tags: Android
---

## 前言

第一个 Android 程序，应该有些纪念的意义吧~

<!-- more -->

## 主页面布局

![](https://s1.ax2x.com/2018/03/14/LtV9R.png)

给 Button 添加响应函数：`android:onClick="login"`

```java
public void login(View view)
{
    String name;
    String password;

    EditText getname = (EditText)findViewById(R.id.editText);
    EditText getpassword = (EditText)findViewById(R.id.editText2);

    name = String.valueOf(getname.getText());
    password = String.valueOf(getpassword.getText());

    if (name.equals("pengzhendong")&&password.equals("950311")) {
        Intent intent = new Intent(this, ResultActivity.class) ;
        intent.putExtra("Name", name);
        intent.putExtra("Password", password);

        startActivity(intent) ;
    } else {
        Toast show_msg = Toast.makeText(getApplicationContext(), "用户名或者密码错误！", Toast.LENGTH_LONG);
        show_msg.setGravity(Gravity.CENTER, 0, 0);
        show_msg.show();
    }
}
```

通过 Intent 从当前页面跳转到 ResultActivity 页面，为了在登陆后的页面显示用户名和密码，通过 intent.putExtra() 将变量作为数组传过去。

## 登陆后页面

```java
public class ResultActivity extends AppCompatActivity {
	
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_result);
	
        String name = this.getIntent().getStringExtra("Name");
        String password = this.getIntent().getStringExtra("Password");
	
        TextView result = (TextView)findViewById(R.id.textView3);
        result.setText("欢迎" + name + ", 你的密码是：" + password);
    }
}
```

通过 `getIntent().getStringExtra()` 获取传过来的用户名和密码。

## Bundle

如果要传递的数据比较多的话可以考虑用 Bundle 来传值：

```java
Bundle bundle = new Bundle();  
bundle.putString("key", "value");  
intent.putExtras(bundle); 
```

获取：

```java
Bundle bundle = this.getIntent().getExtras();  
value = bundle.getString("key");
```
