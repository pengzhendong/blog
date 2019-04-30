---
title: Linux echo 服务
date: 2015-10-31 19:34:23
updated: 2015-10-31 19:57:51
tags: Linux
---

## 前言

大病初愈，感谢某人的陪伴，感谢王乐庆同学和赵攀同学的细心照顾。原以为过了第八周就不忙了，却没想到还有明天的党章考试。还是写代码比背党章有意思~趁着服务器还没过期，赶紧把 echo 完成了。关于错误提示和连接 socket 的代码就不贴出来了。

<!-- more -->

## 服务器配置

``` bash
$ vi /etc/xinetd.d/echo
```
把 `disable = yes` 改成 `disable = no` ，类似 time 服务，如果没有写的权限，就要 chmod，然后重启 xinetd 服务。

``` bash
$ service xinetd restart
```

## Client

**UDPecho.c**

``` c   
/* UDPecho.c - main */
#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
    
#define LINELEN 128
    
extern int errno;
    
int UDPecho(const char *host, const char *service);
int connectUDP(const char *host, const char *service);
int errexit(const char *format, ...);
    
/*---------------------------------------------------------------------------
 * main - UDP client for ECHO service
 *---------------------------------------------------------------------------
 */
int main(int argc, char *argv[])
{
	char *host = "localhost";	/* host to use if none supplied	*/
	char *service = "echo";		/* default service name		*/
	int	s, n;			/* socket descriptor, read count*/
    char buf[LINELEN+1];
    int outchars, inchars;
    
	switch (argc) {
	case 1:
		host = "localhost";
		break;
	case 3:
		service = argv[2];
		/* FALL THROUGH */
	case 2:
		host = argv[1];
		break;
	default:
		fprintf(stderr, "usage: UDPecho [host [port]]\n");
		exit(1);
	}
    UDPecho(host, service);
    exit(0);
}
/*---------------------------------------------------------------------------
 * UDPecho - send input to ECHO service on specified host and print and reply
 *---------------------------------------------------------------------------
 */
int UDPecho(const char *host, const char *service)
{
    char buf[LINELEN+1];    /* buffer for one line of text */
    int s, nchars;    /* socket descriptor, read count */
    
    s = connectUDP(host, service);
    
    while (fgets(buf, sizeof(buf), stdin)) {
    //从命令行读入用户输入的字符
        buf[LINELEN] = '\0';    /* insure null-terminated */
        nchars = strlen(buf);
        (void) write(s, buf, nchars);
        //向网络中发送用户所输入的字符
        memset(buf, 0, LINELEN);
        if (read(s, buf, nchars) < 0) {
        //从网络中读取服务器所返回的的字符
            errexit("socket read failed: %s\n", strerror(errno));
        }
        
        fputs(buf, stdout);
    }
}
```

### 编译运行

![](https://s1.ax2x.com/2018/03/14/LtDW9.png)

然后不使用 xinetd 的自带服务，自己写服务器端的程序：

## Server

**UDPechod.c**

``` c
/* UDPechod.c - main */

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <string.h>
#include <errno.h>

extern int errno;
#define LINELEN 128

int UDPechod(const char *service);
int passiveUDP(const char *service);
int errexit(const char *format, ...);

/*------------------------------------------------------------------------
 * main - Iterative UDP server for ECHO service
 *------------------------------------------------------------------------
 */
int main(int argc, char *argv[])
{
	char *service = "echo";	/* service name or port number	*/

	switch (argc) {
	case 1:
		break;
	case 2:
		service = argv[1];
		break;
	default:
		errexit("usage: UDPechod [port]\n");
	}
    UDPechod(service);
    exit(0);
}

int UDPechod(const char *service)
{
    struct sockaddr_in fsin;	/* the from address of a client	*/
    unsigned int alen;		/* from-address length		*/
    char buf[LINELEN+1];		/* "input" buffer 		*/
    int sock;			/* server socket		*/
    
    sock = passiveUDP(service);
    
    while (1) {
        alen = sizeof(fsin);
        
        if (recvfrom(sock, buf, sizeof(buf), 0, (struct sockaddr *)&fsin, &alen) < 0) {
        //从已连接的 socket 中获取传递过来的信息
            errexit("recvfrom: %s\n", strerror(errno));
        }
       
        (void) sendto(sock, &buf, sizeof(buf), 0, (struct sockaddr *)&fsin, sizeof(fsin));
        //将信息返回
    }
}
```

### 编译运行

![](https://s1.ax2x.com/2018/03/14/Lt3UN.png)