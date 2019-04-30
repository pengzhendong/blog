---
title: Linux xinetd 服务获取时间
date: 2015-10-27 15:00:10
updated: 2015-10-27 15:43:24
tags: Linux
---

## 前言

终于把 xinetd 服务装好了，那就在来实现一下 TCP 协议从服务器和本机获取时间吧。那么多思想汇报还没写，我也是醉了。

<!-- more -->

## 安装 xinetd

``` bash
$ apt-get install xinetd
```

## 配置开启 time 服务

``` bash
$ vi /etc/xinetd.d/time
```
把 `disable = yes` 改成 `disable = no` ，看注释很清楚 time 服务返回的是1900年1月1日到现在的秒数。如果没有写的权限，就要 chmod

``` bash
$ chmod 777 time
```

## 重启 xinetd 服务

``` bash
$ service xinetd restart
```

## 客户端

**TCPtime.c**

``` c
/* TCPtime.c - TCPtime, main */
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdio.h>
#include <time.h>
	
extern int errno;
	
int TCPtime(const char *host, const char *service);
int errexit(const char *format, ...);
int connectTCP(const char *host, const char *service);
	
#define LINELEN 128
	
/*------------------------------------------------------------------------
 * main - TCP client for DAYTIME service
 *------------------------------------------------------------------------
 */
int main(int argc, char *argv[])
{
        char *host1 = "localhost";    /* host to use if none supplied */
        char *host2 = "localhost";    /* host to use if none supplied */
	
        switch (argc) {
        case 1:
                host1 = "localhost";
                host2 = "localhost";
                break;
        case 2:
                host2 = argv[1];
                break;
        default:
                fprintf(stderr, "The number of parameter is to much! Just need the other host~\n");
                exit(1);
        }
        TCPtime(host1, host2);
        exit(0);
}
	
/*------------------------------------------------------------------------
 * TCPtime - invoke time on specified host and print results
 *------------------------------------------------------------------------
 */
int TCPtime(const char *host1, const char *host2)
{
    char buf[LINELEN+1];         /* buffer for one line of text  */
    int  s1, s2, n;              /* socket, read count           */
    
    time_t  time1, time2;
    
    s1 = connectTCP(host1, "time");
    s2 = connectTCP(host2, "time");
    
    while( (n = read(s1, (char *)&time1, sizeof(time1))) > 0) {
		time1 = ntohl((unsigned long)time1);
        time1 -= 2208988800UL;
        time1 += 4294967296UL;
        printf("time in %s is %s", host1, ctime(&time1));
    }
    
    while( (n = read(s2, (char *)&time2, sizeof(time2))) > 0) {
        time2 = ntohl((unsigned long long)time2);
        time2 -= 2208988800UL;
        time2 += 4294967296UL;
        printf("time in %s is %s", host2, ctime(&time2));
    }
    printf("the difference is %d seconds.\n", abs(time1 - time2));
    return 0;
}
```

time_t 类型的长度在32位机器下是32位，在64位机器下是64位，所以在减去 2208988800UL 秒(变成1970年到现在的秒数)后，还要加上2的32次方秒。(我觉得如果能自己实现64位数的网络序转主机序应该也是可以实现的)。


## 编译运行

![](https://s1.ax2x.com/2018/03/14/LtXZe.png)
