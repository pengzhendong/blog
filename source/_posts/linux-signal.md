---
title: Linux 信号处理
date: 2015-11-20 23:24:51
updated: 2015-11-20 23:59:32
tags: Linux
---

## 前言

最近真是倒霉透了，本来就已经够忙的了，跑个步还把手指摔折了，去医院看，这些实习医生让我拍了四次 X 光，他们技术不行却让病人患者为他们买单，有学校报销我倒是不怎么在意这些费用，但是你不能让我一直拍啊，辐射不说还浪费我时间。。。感觉中国体制很多地方还是不尽人意的。

<!-- more -->
​    
## 僵尸进程

在Linux进程的状态中，僵尸进程是非常特殊的一种进程，它已经放弃了几乎所有内存空间，没有任何可执行代码，也不能被调度，仅仅在进程列表中保留一个位置，记载该进程的退出状态等信息供其他进程收集，除此之外，僵尸进程不再占有任何内存空间。它需要它的父进程来为它收尸。

　　如果他的父进程没安装SIGCHLD信号处理函数调用wait或waitpid()等待子进程结束，又没有显式忽略该信号，那么它就一直保持僵尸状态，如果这时父进程结束了，那么init进程自动会接手这个子进程，为它收尸，它还是能被清除的。

　　但是如果父进程是一个循环，不会结束，那么子进程就会一直保持僵尸状态，这就是为什么系统中有时会有很多的僵尸进程。系统所能使用的进程号是有限的,如果大量的产生僵死进程,将因为没有可用的进程号而导致系统不能产生新的进程。

## 僵尸进程的避免

⒈ 父进程通过wait和waitpid等函数等待子进程结束，这会导致父进程挂起。

⒉ 如果父进程很忙，那么可以用signal函数为SIGCHLD安装handler，因为子进程结束后， 父进程会收到该信号，可以在handler中调用wait回收。

---

根据实验要求，我们来设计一个并发的多进程服务器，客户端给服务器发送文件名，服务器创建进程返回给客户端其所需文件的内容。

## 客户端

``` c
/* TCPdaytime.c - TCPdaytime, main */
    
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <stdarg.h>
    
#ifndef	INADDR_NONE
#define	INADDR_NONE 0xffffffff
#endif	/* INADDR_NONE */
    
extern int errno;
    
int TCPecho(const char *host, const char *service);
int errexit(const char *format, ...);
int connectTCP(const char *host, const char *service);
int connectsock(const char *host, const char *service, const char *transport);
    
#define LINELEN 8102
    
/*------------------------------------------------------------------------
 * main - TCP client for DAYTIME service
 *------------------------------------------------------------------------
 */
int main(int argc, char *argv[])
{
	char *host = "localhost";	/* host to use if none supplied	*/
	char *service = "echo";	/* default service port		*/
	    
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
		fprintf(stderr, "usage: TCPecho [host [port]]\n");
		exit(1);
	}                                                           
	TCPecho(host, service);
	exit(0);
}
    
/*------------------------------------------------------------------------
    * TCPdaytime - invoke Daytime on specified host and print results
 *------------------------------------------------------------------------
 */
int TCPecho(const char *host, const char *service)
{
	char buf[LINELEN+1]; /* buffer for one line of text	*/
	int s;			/* socket, read count		*/
    
	s = connectsock( host, service, "tcp"); printf("file:");
    	if (fgets(buf, sizeof buf, stdin)) {
	        //从命令行读入用户输入的字符
	        buf[LINELEN] = '\0';    /* insure null-terminated */
	        
	        (void) write(s, buf, sizeof buf);
	        //向网络中发送用户所输入的字符
	        memset(buf, 0, sizeof buf);
	    
	        if (read(s, buf, LINELEN) < 0) {
	            //从网络中读取服务器所返回的的字符
	            errexit("socket read failed: %s\n", strerror(errno));
	        }
	        printf("%s\n", buf);
    	}
    	close(s);
}
    
    
    
/*------------------------------------------------------------------------
 * connectsock - allocate & connect a socket using TCP or UDP
 *------------------------------------------------------------------------
 */
int connectsock(const char *host, const char *service, const char *transport )
/*
 * Arguments:
 *      host      - name of host to which connection is desired
 *      service   - service associated with the desired port
 *      transport - name of transport protocol to use ("tcp" or "udp")
 */
{
	struct hostent	*phe;	/* pointer to host information entry	*/
	struct servent	*pse;	/* pointer to service information entry	*/
	struct protoent *ppe;	/* pointer to protocol information entry*/
	struct sockaddr_in sin;	/* an Internet endpoint address		*/
	int	s, type;	/* socket descriptor and socket type	*/
    
    
	memset(&sin, 0, sizeof(sin));
	sin.sin_family = AF_INET;
	    
	/* Map service name to port number */
	if ( pse = getservbyname(service, transport) )
		sin.sin_port = pse->s_port;
	else if ((sin.sin_port=htons((unsigned short)atoi(service))) == 0)
		errexit("can't get \"%s\" service entry\n", service);
	
	/* Map host name to IP address, allowing for dotted decimal */
	if ( phe = gethostbyname(host) )
		memcpy(&sin.sin_addr, phe->h_addr, phe->h_length);
	else if ( (sin.sin_addr.s_addr = inet_addr(host)) == INADDR_NONE )
		errexit("can't get \"%s\" host entry\n", host);
	    
	/* Map transport protocol name to protocol number */
	if ( (ppe = getprotobyname(transport)) == 0)
		errexit("can't get \"%s\" protocol entry\n", transport);
	    
	/* Use protocol to choose a socket type */
	if (strcmp(transport, "udp") == 0) type = SOCK_DGRAM;
	else type = SOCK_STREAM;
	    
	/* Allocate a socket */
	s = socket(PF_INET, type, ppe->p_proto);
	if (s < 0) errexit("can't create socket: %s\n", strerror(errno));
	    
	/* Connect the socket */
	if (connect(s, (struct sockaddr *)&sin, sizeof(sin)) < 0)
		errexit("can't connect to %s.%s: %s\n", host, service, strerror(errno));                                    
		return s;
}
	    
int errexit(const char *format, ...)
{
	va_list	args;
	    
	va_start(args, format);
	vfprintf(stderr, format, args);
	va_end(args);
	exit(1);
}
```

## 并发的多进程服务器

``` c
/* TCPdaytimed.c - main */
    
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <netdb.h>
#include <stdarg.h>
#include <stdlib.h>
#include <signal.h>
    
extern int errno;
int errexit(const char *format, ...);
int passiveTCP(const char *service, int qlen);
int errexit(const char *format, ...);
int passivesock(const char *service, const char *transport, int qlen);
    
void handler(int num) {
	int status;
	int pid = waitpid(-1, &status, WNOHANG);
	if (WIFEXITED(status)) {
	    printf("The child %d exit with returing %d\n", pid, WEXITSTATUS(status));
	}
}
    
unsigned short	portbase = 0;	/* port base, for non-root servers	*/
    
#define QLEN 32
#define NAMELEN 32
#define BUFSIZE 8102
    
/*------------------------------------------------------------------------
* main - Iterative TCP server for DAYTIME service
*------------------------------------------------------------------------
*/
int main(int argc, char *argv[])
{
	struct	sockaddr_in fsin;	/* the from address of a client	*/
	char	*service = "echo";	/* service name or port number	*/
	int	msock, ssock;		/* master & slave sockets	*/
	unsigned int	alen;		/* from-address length		*/
	char file[NAMELEN+1];
	char buf[BUFSIZE];
	FILE *fp = NULL;
	char *find;
	    
	switch (argc) {
	case 1:
		break;
	case 2:
		service = argv[1];
		break;
	default:
		errexit("usage: TCPecho [port]\n");
	}
	msock = passivesock(service, "tcp", QLEN);
	    
	while (1) {
	    alen = sizeof(fsin);
	    ssock = accept(msock, (struct sockaddr *)&fsin, &alen);
	    
	    signal(SIGCHLD,handler);  //处理子进程的信号
	    
	    int pid = fork();
	    
	    if (pid == 0) {
	        if (ssock < 0) errexit("accept failed: %s\n", strerror(errno));
	        if (read(ssock, file, sizeof file) > 0) {
	            
	            if (file[strlen(file)-1] == '\n') file[strlen(file)-1] = '\0';
	            
	            fp = fopen(file, "r");
	            if (NULL == fp)
	            {
	                 strcpy(buf, "file open Fail!");
	                (void) write(ssock, buf, sizeof buf);
	                memset(buf, 0, sizeof buf);
	                return -1;
	            }
	            fread(buf, 1, sizeof buf, fp);
	            fclose(fp);
	            fp = NULL;
	            
	            (void) write(ssock, buf, sizeof buf);
	            memset(buf, 0, sizeof buf);
	        }
	        (void) close(ssock);
	        return 1;
	    }
	}
}
    
/*------------------------------------------------------------------------
* passivesock - allocate & bind a server socket using TCP or UDP
*------------------------------------------------------------------------
*/
    
int passivesock(const char *service, const char *transport, int qlen)
/*
* Arguments:
*      service   - service associated with the desired port
*      transport - transport protocol to use ("tcp" or "udp")
*      qlen      - maximum server request queue length
*/
{
	struct servent	*pse;	/* pointer to service information entry	*/
	struct protoent *ppe;	/* pointer to protocol information entry*/
	struct sockaddr_in sin;	/* an Internet endpoint address		*/
	int	s, type;	/* socket descriptor and socket type	*/
	    
	memset(&sin, 0, sizeof(sin));
	sin.sin_family = AF_INET;
	sin.sin_addr.s_addr = INADDR_ANY;
	    
	/* Map service name to port number */
	if ( pse = getservbyname(service, transport) )
		sin.sin_port = htons(ntohs((unsigned short)pse->s_port) + portbase);
	else if ((sin.sin_port=htons((unsigned short)atoi(service))) == 0)
		errexit("can't get \"%s\" service entry\n", service);
	    
	/* Map protocol name to protocol number */
	if ( (ppe = getprotobyname(transport)) == 0)
		errexit("can't get \"%s\" protocol entry\n", transport);
	    
	/* Use protocol to choose a socket type */
	if (strcmp(transport, "udp") == 0)
		type = SOCK_DGRAM;
	else
		type = SOCK_STREAM;
	    
	/* Allocate a socket */
	s = socket(PF_INET, type, ppe->p_proto);
	if (s < 0)
		errexit("can't create socket: %s\n", strerror(errno));
	    
	/* Bind the socket */
	if (bind(s, (struct sockaddr *)&sin, sizeof(sin)) < 0)
		errexit("can't bind to %s port: %s\n", service,
			strerror(errno));
	if (type == SOCK_STREAM)
		if (listen(s, qlen) < 0)
			errexit("can't listen on %s port: %s\n", service, strerror(errno));
	return s;
}
    
int errexit(const char *format, ...)
{
	va_list	args;
	    
	va_start(args, format);
	vfprintf(stderr, format, args);
	va_end(args);
	exit(1);
}
```

在服务器中我们用到了这个信号处理的函数给服务器安装了 handler，`signal(SIGCHLD,handler);`这个函数能够接收到子进程退出的信号，然后将僵尸进程杀死。我们把这行代码注释掉看看运行结果：

![](https://s1.ax2x.com/2018/03/14/LAxcQ.png)

很明显，在客户端退出之后，服务器 fork 出来的子进程并没有完全退出。

去掉注释，再运行一次：

![](https://s1.ax2x.com/2018/03/14/LAgZz.png)

客户端退出后，服务器的子进程也就退出了，这样就不会一直占用着空间。随便读取个文件试试吧！

![](https://s1.ax2x.com/2018/03/14/LAnIS.png)



