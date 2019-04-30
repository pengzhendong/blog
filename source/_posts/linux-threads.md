---
title: Linux 多线程
date: 2015-12-15 13:18:31
updated: 2015-12-15 13:47:28
tags: Linux
---

## 前言

 这篇博客又拖了一周，即将迎来考试周，一大堆课设要交，一大堆报告要写。前几天又惹亲爱的生气了，刚刚缓和过来，心情大好。最近在看一本叫《把时间当做朋友》的关于时间管理的书，感觉获益良多。我要学会控制自己的大脑。

<!-- more -->

## 多线程

多线程，是指从软件或者硬件上实现多个线程并发执行的技术。具有多线程能力的计算机因有硬件支持而能够在同一时间执行多于一个线程，进而提升整体处理性能。具有这种能力的系统包括对称多处理机、多核心处理器以及芯片级多处理或同时多线程处理器。在一个程序中，这些独立运行的程序片段叫作“线程”，利用它编程的概念就叫作“多线程处理”。--摘自《百度百科》

## 线程相关函数

`pthread_cond_init(pthread_cond_t *__cond,__const pthread_condattr_t *__cond_attr);`
​    
用来初始化一个条件变量。其中cond是一个指向结构pthread_cond_t的指针，
cond_attr是一个指向结构pthread_condattr_t的指针。
结构pthread_condattr_t是条件变量的属性结构，和互斥锁一样我们可以用它来设置条件变量是进程内可用还是进程间可用，默认值是PTHREAD_ PROCESS_PRIVATE，即此条件变量被同一进程内的各个线程使用；如果选择为PTHREAD_PROCESS_SHARED则为多个进程间各线程公用。注意初始化条件变量只有未被使用时才能重新初始化或被释放。

`pthread_mutex_init()；`
​    
以动态方式创建互斥锁的，参数attr指定了新建互斥锁的属性。如果参数attr为空，则使用默认的互斥锁属性，默认属性为快速互斥锁。

`pthread_attr_init(pthread_attr_t *attr)；`
​    
指向一个线程属性结构的指针，结构中的元素分别对应着新线程的运行属性。属性对象主要包括是否绑定、是否分离、堆栈地址和大小、优先级等。

`pthread_attr_setdetachstate(pthread_attr_t *attr, int detachstate);`
​    
设置线程分离状态的函数,第二个参数可选为PTHREAD_CREATE_DETACHED（分离线程）和 PTHREAD _CREATE_JOINABLE（非分离线程）。线程的分离状态决定一个线程以什么样的方式来终止自己。在默认情况下线程是非分离状态的，这种情况下，原有的线程等待创建的线程结束。只有当pthread_join（）函数返回时，创建的线程才算终止，才能释放自己占用的系统资源。

## Server

```c
/* TCPmtechod.c - main, TCPechod, prstats */
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <pthread.h>
#include <sys/types.h>
#include <sys/signal.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <sys/wait.h>
#include <sys/errno.h>
#include <netinet/in.h>
#include <arpa/inet.h>
    
#define QLEN 32	
#define BUFSIZE 4096
    
#define INTERVAL	5	/* secs */
    
#define MAXTHREADS 10
#define MAXCLIENTS 128
    
int client_array[MAXCLIENTS];	/*socket descriptors for client connection waiting to handle*/
int iput, iget;		            /*index for main thread put and sub-thread get*/
pthread_cond_t	cli_cond;
pthread_mutex_t	cli_mutex;
    
struct {
	pthread_mutex_t	st_mutex;     // 互斥变量，防止多个线程同时访问接口体其他数据
	unsigned int	st_concount;  // 已连接通信量
	unsigned int	st_contotal;  // 已完成通信量
	unsigned long	st_contime;	  // 连接总时间
	unsigned long	st_bytecount; // 通信流量                   
} stats;                          // 监视函数变量
    
void prstats(void);               // 监控函数
int TCPechod(int fd);
int errexit(const char *format, ...);
int passiveTCP(const char *service, int qlen);
    
int thread_make(void);
void thread_main(void);
    
int main(int argc, char *argv[])
{
	pthread_t th;              //  创建线程变量   
	pthread_attr_t ta;         //  线程变量指针
	char *service = "echo";	   /* service name or port number	*/
	struct sockaddr_in fsin;
	unsigned int alen;
	int	msock;
	int	ssock;
    
	switch (argc) {
	case 1:
		break;
	case 2:
		service = argv[1];
		break;
	default:
		errexit("usage: Server [port]\n");
	}
    
	msock = passiveTCP(service, QLEN);   // 被动套接字
    
	(void) pthread_cond_init(&cli_cond,0);
	(void) pthread_mutex_init(&cli_mutex,0);
    
	(void) pthread_attr_init(&ta);      // 将ta初始化
	(void) pthread_attr_setdetachstate(&ta, PTHREAD_CREATE_DETACHED);
	(void) pthread_mutex_init(&stats.st_mutex, 0);  // 初始化互斥
    
	if (pthread_create(&th, &ta, (void * (*)(void *))prstats, 0) < 0) // 创建新线程
		printf("pthread_create error\n");
    
	int i;
	for(i=0; i<MAXTHREADS; i++){
		if(thread_make()<0) errexit("pthread_create: %s\n", strerror(errno));
	}
	iput = iget = 0;
    
	while (1) {
		alen = sizeof(fsin);
		ssock = accept(msock, (struct sockaddr *)&fsin, &alen);
		if (ssock < 0) {
			if (errno == EINTR) continue;
			errexit("accept: %s\n", strerror(errno));
		}
    
		pthread_mutex_lock(&cli_mutex);
		client_array[iput] = ssock;
    
		if( ++iput == MAXCLIENTS) iput=0;	
		printf("iput is %d\n",iput);
    
		if(iput == iget) errexit("error: iput == iget %d \n",iput);
		pthread_cond_signal(&cli_cond);
		pthread_mutex_unlock(&cli_mutex);
	}
}
    
/*------------------------------------------------------------------------
 * TCPechod – 回应数据直到终结程序
 *------------------------------------------------------------------------
 */
int TCPechod(int fd)
{
	time_t	start;
	char	buf[BUFSIZ];
	int	cc;
	struct  sockaddr_in cin;
    
	printf("I'm thread %lu\n", pthread_self());
    
	int alen = sizeof(cin);
	if(getpeername(fd, (struct sockaddr *)&cin, &alen)<0) 
		errexit("accept: %s\n", strerror(errno));
	printf("I'm serving client at address: %s : %d \n", inet_ntoa(cin.sin_addr), cin.sin_port);
    
	start = time(0);                                   // 当前时间给全局变量
	(void) pthread_mutex_lock(&stats.st_mutex);        // 讲数据锁定此进程
	stats.st_concount++;                               // 通信连接数+1
	(void) pthread_mutex_unlock(&stats.st_mutex);      // 解锁
	while (cc = read(fd, buf, sizeof buf)) {           // 接受客户请求
		if (cc < 0) printf("echo read error\n");
		if (write(fd, buf, cc) < 0) printf("echo write error\n");
		(void) pthread_mutex_lock(&stats.st_mutex);    
		stats.st_bytecount += cc;                      // 将传输字节数传给start
		(void) pthread_mutex_unlock(&stats.st_mutex);
	}
	(void) close(fd);
	(void) pthread_mutex_lock(&stats.st_mutex);
	stats.st_contime += time(0) - start;      // 将连接时间加入
	stats.st_concount--;					  // 通信数-1
	stats.st_contotal++;					  // 完成  +1
	(void) pthread_mutex_unlock(&stats.st_mutex);
	return 0;
}
    
/*------------------------------------------------------------------------
 * prstats –打印服务统计数据
 *------------------------------------------------------------------------
 */
void prstats(void)
{
	time_t	now;
	while (1) {
		(void) sleep(INTERVAL);
    
		(void) pthread_mutex_lock(&stats.st_mutex);
		now = time(0);
		(void) printf("--- %s", ctime(&now));
		(void) printf("%-32s: %u\n", "Current connections", stats.st_concount);
		(void) printf("%-32s: %u\n", "Completed connections", stats.st_contotal);
		if (stats.st_contotal) {
			(void) printf("%-32s: %.2f (secs)\n", "Average complete connection time", (float)stats.st_contime /(float)stats.st_contotal);
			(void) printf("%-32s: %.2f\n","Average byte count", (float)stats.st_bytecount /(float)(stats.st_contotal +stats.st_concount));
		}
		(void) printf("%-32s: %lu\n\n", "Total byte count", stats.st_bytecount);
		(void) pthread_mutex_unlock(&stats.st_mutex);
	}
}
    
int thread_make(void)
{
	pthread_t th;
	pthread_attr_t	ta;
	(void) pthread_attr_init(&ta);
	if(pthread_create(&th,&ta,(void*)thread_main,0)<0) return -1;
	return 0;
}

void thread_main(void)
{
    int fd;
    for(;;){
        fflush(stdout);
        printf("\nI'm thread %lu\n", pthread_self());
    
        pthread_mutex_lock(&cli_mutex);
        while(iget == iput) pthread_cond_wait(&cli_cond, &cli_mutex);
        fd = client_array[iget];
        if(++iget == MAXCLIENTS) iget=0;
        pthread_mutex_unlock(&cli_mutex);
        TCPechod(fd);
    }
}
```

## 运行结果

![](https://s1.ax2x.com/2018/03/14/LAk93.png)

![](https://s1.ax2x.com/2018/03/14/LASgn.png)
​    
