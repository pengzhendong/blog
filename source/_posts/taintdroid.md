---
title: 动态污点分析工具 TaintDroid 的部署
date: 2017-02-24 21:47:00
updated: 2017-02-24 22:27:25
tags: TaintDroid
---

## 前言

编译完 Android 源代码只是确保当前环境没问题，TaintDroid 是一个动态污点分析工具，所以要将 TaintDroid 编译到 Android 中去，自己定制具有 TaintDroid 功能的 Android 系统。

<!-- more -->

## 下载 TaintDroid 源代码

在进行 Android 系统开发时，通常需要对清单文件进行定制，基于 AOSP 的 default.xml 进行定制，例如去掉 AOSP 的一些 git 库、增加一些自己的 git 库。

由于直接修改 default.xml 容易造成冲突，所以 `repo` 支持 Local Manifests 的定制方式，在 `$ repo sync` 之前，会将 `default.xml` 和 `local_manifests.xml` 进行合并再同步。所以只需要将清单文件的修改项放到 `local_manifests.xml` 中， 就能完成对清单的文件的定制。

### 定制 Manifests

``` bash
$ cd ~/tdroid/tdroid-4.3_r1/.repo
$ mkdir local_manifests
$ cd local_manifests
$ touch local_manifests.xml
```

将以下内容输入到 `local_manifests.xml` 文件中，定制 TaintDroid 的源代码结构

``` xml
<manifest>
  <remote name="github" fetch="git://github.com"/>
  <remove-project name="platform/dalvik"/>
  <project path="dalvik" remote="github" name="TaintDroid/android_platform_dalvik" revision="taintdroid-4.3_r1"/>
  <remove-project name="platform/libcore"/>
  <project path="libcore" remote="github" name="TaintDroid/android_platform_libcore" revision="taintdroid-4.3_r1"/>
  <remove-project name="platform/frameworks/base"/>
  <project path="frameworks/base" remote="github" name="TaintDroid/android_platform_frameworks_base" revision="taintdroid-4.3_r1"/>
  <remove-project name="platform/frameworks/native"/>
  <project path="frameworks/native" remote="github" name="TaintDroid/android_platform_frameworks_native" revision="taintdroid-4.3_r1"/>
  <remove-project name="platform/frameworks/opt/telephony"/>
  <project path="frameworks/opt/telephony" remote="github" name="TaintDroid/android_platform_frameworks_opt_telephony" revision="taintdroid-4.3_r1"/>
  <remove-project name="platform/system/vold"/>
  <project path="system/vold" remote="github" name="TaintDroid/android_platform_system_vold" revision="taintdroid-4.3_r1"/>
  <remove-project name="platform/system/core"/>
  <project path="system/core" remote="github" name="TaintDroid/android_platform_system_core" revision="taintdroid-4.3_r1"/>
  <remove-project name="device/samsung/manta"/>
  <project path="device/samsung/manta" remote="github" name="TaintDroid/device_samsung_manta" revision="taintdroid-4.3_r1"/>
  <remove-project name="device/samsung/tuna"/>
  <project path="device/samsung/tuna" remote="github" name="TaintDroid/android_device_samsung_tuna" revision="taintdroid-4.3_r1"/>
  <project path="packages/apps/TaintDroidNotify" remote="github" name="TaintDroid/android_platform_packages_apps_TaintDroidNotify"
      revision="taintdroid-4.3_r1"/>
</manifest>
```

### 同步源代码

如果同步的时候提示无法重写，则需要加上 `--force-sync` 参数，又要同步好几个小时

``` bash
$repo sync --force-sync
$repo forall dalvik libcore frameworks/base frameworks/native frameworks/opt/telephony system/vold system/core device/samsung/manta device/samsung/tuna \
       packages/apps/TaintDroidNotify -c 'git checkout -b taintdroid-4.3_r1 --track github/taintdroid-4.3_r1 && git pull'
```

`$ repo forall` 命令会遍历后面的仓库，然后对每个仓库使用 `-c` 选项后面的命令，即对每个仓库进行 `$ git checkout` 和 `$ git pull` 命令

<center><img src="https://s1.ax2x.com/2018/03/14/Le2uK.png" width="500"/></center>

## 编译 TaintDroid

编译 TaintDroid 首先需要创建 `buildspec.mk` 文件和定义一些变量

``` bash
$ cd ~/tdroid/tdroid-4.3_r1
$ touch buildspec.mk 
```

将下面内容输入到 `buildspec.mk` 文件中

```
# Enable core taint tracking logic (always add this)
WITH_TAINT_TRACKING := true

# Enable taint tracking for ODEX files (always add this)
WITH_TAINT_ODEX := true

# Enable taint tracking in the "fast" (aka ASM) interpreter (recommended)
WITH_TAINT_FAST := true

# Enable additional output for tracking JNI usage (not recommended)
#TAINT_JNI_LOG := true

# Enable byte-granularity tracking for IPC parcels
WITH_TAINT_BYTE_PARCEL := true
```

然后需要将 TaintDroidNotify 应用添加到编译中，这样编译后的系统就有这个应用，只需要在 `build/target/product/core.mk` 文件中添加 `TaintDroidNotify` 如下

```
PRODUCT_PACKAGES += \
                    BasicDreams \
                    ...
                    voip-common \     # 这行加了个符号 "\"
                    TaintDroidNotify  # 这行是新加的
```

现在就可以开始长达好几个小时的编译了，由于之前已经编译过一次 Android 源代码，所以这次基本上是不会出现任何问题的

``` bash
$ source build/envsetup.sh
$ lunch 1
$ make clean
$ make -j4
```

## 测试

### 启动虚拟机

首先启动虚拟机，由于待会还要通过命令行执行命令，所以通过 `&` 参数让虚拟机在后台运行

``` bash
$ emulator &
```

会发现 TaintDroid Notify 已经安装在虚拟机上了，由于通过手机下载软件会提示需要 SD 卡，所以这时候就可以在命令行通过 `adb` 命令给虚拟机安装应用，这里下载安装了百度手机管家

``` bash
$ adb install ~/Downloads/appsearch_AndroidPhone_1012271b.apk
```

<center><img src="https://s1.ax2x.com/2018/03/14/Le7tG.png" width="250"/></center>

### 启动 TaintDroid

点击 TaintDroid Notify 应用图标启动应用，然后点击 `Start` 按钮，注意的是点击了按钮后，并不会有任何变化和提示，但是已经启动服务了

<center><img src="https://s1.ax2x.com/2018/03/14/LeRwn.png" width="250"/></center>

然后点开安装好的百度手机管家，就会发现 TaintDroid 弹出了好几条通知，这些就是泄露的隐私信息

<center><img src="https://s1.ax2x.com/2018/03/14/LenGE.png" width="250"/></center>

点开第一条 就会发现百度手机管家把手机的 IMEI 号，通过 SSL 协议的 POST 方法发送到了 123.125.112.192 目标地址

<center><img src="https://s1.ax2x.com/2018/03/14/LeoLQ.png" width="250"/></center>





