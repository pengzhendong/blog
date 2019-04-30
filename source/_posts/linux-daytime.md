---
title: Linux daytime 服务
date: 2015-10-26 22:00:53
updated: 2015-10-26 22:40:16
tags: Linux
---

## 前言

如果你这段时间过得很舒服，那就证明你荒废了一段时间。如果你这段时间过得很辛苦，那么恭喜，你又进步了。最近入党的事情忙得焦头烂额，博客也拖了好久没写，主要也是因为要装 xinetd 服务一直没装好，Mac 上也无法编译多个文件，于是我还特意租了一个月服务器。OK，现在来实现客户端连接主机，从主机获取时间。

<!-- more -->

## Server

**passiveTCP.c**

``` c
/* passiveTCP.c - passiveTCP */
	
int passivesock(const char *service, const char *transport, int qlen);
	
/*------------------------------------------------------------------------
 * passiveTCP - create a passive socket for use in a TCP server
 *------------------------------------------------------------------------
 */
int passiveTCP(const char *service, int qlen)
/*
 * Arguments:
 *      service - service associated with the desired port
 *      qlen    - maximum server request queue length
 */
{
	return passivesock(service, "tcp", qlen);
}
```

**passivesock.c**

``` c
/* passivesock.c - passivesock */

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <string.h>
#include <netdb.h>
#include <errno.h>
extern int errno;
int errexit(const char *format, ...);

unsigned short portbase = 0;	/* port base, for non-root servers	*/

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
	if (strcmp(transport, "udp") == 0) type = SOCK_DGRAM;
	else type = SOCK_STREAM;

    /* Allocate a socket */
	s = socket(PF_INET, type, ppe->p_proto);
	if (s < 0) errexit("can't create socket: %s\n", strerror(errno));

    /* Bind the socket */
	if (bind(s, (struct sockaddr *)&sin, sizeof(sin)) < 0)
		errexit("can't bind to %s port: %s\n", service, strerror(errno));
		
	if (type ==  SOCK_STREAM)
		if (listen(s, qlen) < 0)
			errexit("can't listen on %s port: %s\n", service, strerror(errno));
	return s;
}
```

**TCPdaytimed.c**

``` c
/* TCPdaytimed.c - main */
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
extern int errno;
int errexit(const char *format, ...);
void TCPdaytimed(int fd);
int passiveTCP(const char *service, int qlen);
	
#define QLEN 32
	
/*------------------------------------------------------------------------
 * main - Iterative TCP server for DAYTIME service
 *------------------------------------------------------------------------
 */
int main(int argc, char *argv[])
{
	struct sockaddr_in fsin;		/* the from address of a client	*/
	char *service = "daytime";	/* service name or port number	*/
	int msock, ssock;		/* master & slave sockets	*/
	unsigned int alen;		/* from-address length		*/
	
	switch (argc) {
	case 1:
		break;
	case 2:
		service = argv[1];
		break;
	default:
		errexit("usage: TCPdaytimed [port]\n");
	}
	
	msock = passiveTCP(service, QLEN);
	
	while (1) {
		alen = sizeof(fsin);
		ssock = accept(msock, (struct sockaddr *)&fsin, &alen);
		if (ssock < 0) errexit("accept failed: %s\n", strerror(errno));
		TCPdaytimed(ssock);
		(void) close(ssock);
	}
}
	
/*------------------------------------------------------------------------
 * TCPdaytimed - do TCP DAYTIME protocol
 *------------------------------------------------------------------------
 */
void TCPdaytimed(int fd)
{
	char *pts;			/* pointer to time string	*/
	time_t now;			/* current time			*/
	char *ctime();
	
	(void) time(&now);
	pts = ctime(&now);
	(void) write(fd, pts, strlen(pts));
}
```

客户端链接服务器时，服务器获取时间然后将获取到的秒数通过 ctime() 函数转换成标准格式返回给客户端。

## Client

**connectsock.c**

``` c
/* connectsock.c - connectsock */
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <string.h>
#include <stdlib.h>
	
#ifndef INADDR_NONE
#define INADDR_NONE 0xffffffff
#endif	/* INADDR_NONE */
	
extern int errno;
	
int errexit(const char *format, ...);
	
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
```

**connectTCP.c**

``` c
/* connectTCP.c - connectTCP */
	
int connectsock(const char *host, const char *service,
		const char *transport);
	
/*------------------------------------------------------------------------
 * connectTCP - connect to a specified TCP service on a specified host
 *------------------------------------------------------------------------
 */
int connectTCP(const char *host, const char *service )
/*
 * Arguments:
 *      host    - name of host to which connection is desired
 *      service - service associated with the desired port
 */
{
	return connectsock( host, service, "tcp");
}
```

**TCPdaytime.c**

``` c
/* TCPdaytime.c - TCPdaytime, main */
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdio.h>
#include <time.h>
	
extern int errno;
	
int TCPdaytime(const char *host, const char *service);
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
        TCPdaytime(host1, host2);
        exit(0);
}
	
/*------------------------------------------------------------------------
 * TCPdaytime - invoke Daytime on specified host and print results
 *------------------------------------------------------------------------
 */
int TCPdaytime(const char *host1, const char *host2)
{
    char    buf[LINELEN+1];         /* buffer for one line of text  */
    int     s1, s2, n;              /* socket, read count           */
    struct  tm time1, time2;
    long    second1, second2;
	
    s1 = connectTCP(host1, "daytime");
    s2 = connectTCP(host2, "daytime");
    
    while( (n = read(s1, buf, LINELEN)) > 0) {
        buf[n] = '\0';          /* ensure null-terminated       */
        strptime(buf, "%a %b %d %H:%M:%S %Y", &time1);
        printf("time in localhost is\t");
        (void) fputs( buf, stdout );
    }
    
    while( (n = read(s2, buf, LINELEN)) > 0) {
        buf[n] = '\0';          /* ensure null-terminated       */
        strptime(buf, "%a %b %d %H:%M:%S %Y", &time2);
        printf("time in %s is\t", host2);
        (void) fputs( buf, stdout ); 
        /*stdout是一个文件指针,C己经在头文件中定义好的了，可以直接使用，把它
          赋给另一个文件指针。只是方便操作输出，比如传给一个函数等等。这时函数
          的输出就不是输出到文件，而是传进来的stdout文件指针，即标准输出。*/
    }
    
    second1 = mktime(&time1);
    second2 = mktime(&time2);
    
    printf("time difference is %d seconds.\n", abs(second1-second2));
    
    return 0;
}
```

默认连接的两个主机都是 localhost ，如果输入主机地址，则同时连接 localhost 和目标主机，获取到两台主机的时间。为了比较两台主机之间的时间差，一开始我想着服务器直接返回秒数，但是要转换成字符串才能返回就放弃了。通过 [strptime()](http://baike.baidu.com/link?url=VnCL79nfxbvSDjIzxGAjSS-BHLyoofMhwRmHllxBJ5G4W9K9pLJuXiToATVgDmneyNk_8NcKjbonp_fPJaCW0_)按照特定时间格式将字符串转换为时间类型，然后通过 [mktime()](http://baike.baidu.com/link?url=sOcU4l9vSeU7v7j1ZRFr6qjOeG1kS4BYfQvIFrY7FJuHo6ZJhZqO-PxMPsn6hwN2qgkeDbW0LLDdSm5VOYZOVa)将时间转换为自1970年1月1日以来持续时间的秒数，这样就可以进行运算了。

## 编译运行

编译运行 server：

![](https://s1.ax2x.com/2018/03/14/LtYbr.png)

将 server 上传到服务器：

``` bash
$ scp /Users/pengzhendong/Code/Lab3/client root@114.215.101.30:/root
```

连接服务器开启服务：

![](https://s1.ax2x.com/2018/03/14/LtjrX.png)

开启客户端，分别只连接 localhost 和同时连接两台服务器：

![](https://s1.ax2x.com/2018/03/14/LtGil.png)