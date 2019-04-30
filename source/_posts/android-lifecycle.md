---
title: Android Activity 的生命周期 
date: 2017-02-08 10:01:50
updated: 2017-02-08 12:10:06
tags: Android
---

## 前言

又到了出发的时间了，今年估计六七月份拿到录取通知书就会再回来吧！临走之前赶紧把前几天学习的内容总结一下。

<!-- more -->

## 回调函数

Android 的 Activity 具有各种回调，分别在不同时刻调用

| 回调 | 描述 |
| ----- | -------- |
| onCreate() | 在 Activity 被创建的时候调用 |
| onStart() | 在 Activity 变成用户可见的时候调用 |
| onResume() | 在 Activity 变成和用户可交互的时候调用 |
| onPause() | 在 Activity 被 dialog 风格的 Activity 挡住了而失去焦点的时候调用 |
| onStop() | 在 Activity 完全不可见的时候调用 |
| onDestroy() | 在 Activity 被系统销毁之前调用 |
| onRestart() | 在 Activity 被 stop 后重新打开时调用 |


<center>![](https://developer.android.com/images/activity_lifecycle.png)</center>

## 测试

在 Android Studio 中新建一个空项目，修改 `MainActivity` 中的代码，分别实现以上几个回调函数，打印事件。

``` java
public class MainActivity extends Activity {
    String msg = "Android : ";
    /** 当活动第一次被创建时调用 */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Log.d(msg, "The onCreate() event");
    }

    /** 当活动即将可见时调用 */
    @Override
    protected void onStart() {
        super.onStart();
        Log.d(msg, "The onStart() event");
    }

    /** 当活动可见时调用 */
    @Override
    protected void onResume() {
        super.onResume();
        Log.d(msg, "The onResume() event");
    }

    /** 当其他活动获得焦点时调用 */
    @Override
    protected void onPause() {
        super.onPause();
        Log.d(msg, "The onPause() event");
    }

    /** 当活动不再可见时调用 */
    @Override
    protected void onStop() {
        super.onStop();
        Log.d(msg, "The onStop() event");
    }
    
    /** 当活动新启动时调用 */
    @Override
    protected void onRestart() {
        super.onStop();
        Log.d(msg, "The onRestart() event");
    }

    /** 当活动将被销毁时调用 */
    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d(msg, "The onDestroy() event");
    }
}
```

启动程序后，在 IDE 的命令行中会输出以下内容然后进入运行状态

```
D/Android :: The onCreate() event
D/Android :: The onStart() event
D/Android :: The onResume() event
```
onCreate() --> onStart() --> The onResume() --> Activity running

如果此时回到桌面或者切换到其他程序，导致该 Activity 完全不可见时，则输出以下内容

```
D/Android :: The onPause() event
D/Android :: The onStop() event
```
Activity running --> onPause() --> onStop()


接着如果重新跳转回该 Activity，就会恢复 Activity 输出以下内容

```
D/Android :: The onRestart() event
D/Android :: The onStart() event
D/Android :: The onResume() event
```
onStop() --> onRestart() --> onStart() --> onResume() --> Activity running

如果是通过任务管理器销毁该 Activity 则输出以下内容

```
D/Android :: The onDestroy() event
```
onStop() --> onDestroy()

## onPause()

从上面几种常见状态来看，一般 onPause() 后都会调用 onStop()，根据生命周期图，我一开始在 Activity 中设置一个按钮，用来弹出一个 dialog，想体验 Activity running --> onPause() --> onResume() --> Activity running。

``` java
public void showAlterDialog(View view) {
    AlertDialog.Builder builder = new AlertDialog.Builder(this);
    builder.setTitle("Exit?");
    builder.setPositiveButton("Cancel", new DialogInterface.OnClickListener() {
        @Override
        public void onClick(DialogInterface dialog, int which) {
            dialog.dismiss();
        }
    });
    builder.create().show();
}
```

但是并没有任何反应，才知道通过 AlertDialog 弹出的对话框属于这个 Activity 的一部分，所以当前 Activity 还是全部可见的。只有弹出 Dialog 形式的 Activity 才能使当前 Activity 失去焦点。

在 layout 文件夹中新建一个 Activity `activity_dialog.xml`，里面只有一个进度条

``` xml
<ProgressBar
    style="?android:attr/progressBarStyleLarge"
    android:layout_width="226dp"
    android:layout_height="239dp"
    android:id="@+id/progressBar" />
```

在 `AndroidManifest.xml` 中声明该 Activity 并且设置主题为 DialogTheme

``` xml
<activity
    android:name=".DialogActivity"
    android:screenOrientation="portrait"
    android:theme="@style/DialogTheme" />
```

然后新建 `DialogActivity` 类，重写 onCreate() 方法，该 Activity 会运行一个进度条2秒，模拟登陆过程，然后自动结束运行

``` java
@Override
public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_dialog);
    new Handler().postDelayed(new Runnable(){
        @Override
        public void run(){
            DialogActivity.this.finish();
            Toast.makeText(getApplicationContext(), "登录成功", Toast.LENGTH_SHORT).show();
        }
    }, 2000);
}
```

在 `MainActivity` 中添加按钮和响应事件

``` java
public void showActivityDialog(View view) {
    Intent intent = new Intent(this, DialogActivity.class);
    startActivity(intent);
}
```

因此，在点击按钮后，则会跳转到 `DialogActivity`，由于它的 theme 是 DialogTheme，只能使 `MainActivity` 失去焦点和部分不可见，等 `DialogActivity` 运行结束后则又回到 `MainActivity`。

### 运行结果

```
D/Android :: The onPause() event
D/Android :: The onResume() event
```
Activity running --> onPause() --> onResume() --> Activity running

整个 Android 程序运行的生命周期就是这么多内容，由于篇幅问题，所以不想在这篇文章中总结每个回调函数都应该干什么事，例如关闭开启系统资源等。