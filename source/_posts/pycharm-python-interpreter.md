---
title: Pycharm 解释器配置
date: 2018-05-26 17:11:01
updated: 2018-05-26 18:31:58
tags: Python
---

## 前言

在做实验的时候经常会遇到一些 Python 的运行环境问题，有很多工具都可以解决这些问题，在 Pycharm 中也提供了各种配置解释器的方法，由于需要使用服务器的环境在本地开发，折腾了一个多小时终于弄好了。记录一下折腾过程的同时顺便把其他配置解释器的方法弄懂。

<!-- more -->

## Pycharm 解释器配置

Pycharm 中可以通过 `Preferences` -> `Project Interpreter` -> `Add…` 进入添加解释器的页面。

Pycharm 提供了 7 中配置解释器的方法，其实这 7 种方法中有好几个方法是重叠的，它们分别是：

* Virtualenv Enviroment
* Conda Enviroment
* System Interpreter
* SSH Interpreter
* Vagrant
* Docker
* Docker Compose

### Virtualenv Enviroment

在同时开发多个 Python 应用程序的时候，如果只安装了一个版本的 Python，那么在使用 pip 安装第三方包的时候，就会被安装到 Python 的 `site-packages` 文件夹下。如果应用之间使用的包的版本不同，那么每个应用可能需要各自拥有一套“独立”的 Python 运行环境。virtualenv 是一个 Python 的环境管理器，可以为一个应用创建一套“隔离”的 Python 运行环境的。

#### 安装 virtualenv

首先需要使用 `pip` 命令安装 virtualenv：

``` bash
$ pip install virtualenv
```

#### 创建虚拟环境

然后使用 `virtualenv` 命令在应用的根目录下创建一个独立的 Python 运行环境 `tensorflow`，创建完毕后就会再根目录下生成和环境同名的文件夹，其中包含了 Python 执行文件和 pip 库的拷贝，然后可以通过 pip 命令安装该应用所需要的包。

``` bash
$ virtualenv tensorflow
Using base prefix '/Users/Randy/anaconda3'
New python executable in /Users/Randy/Desktop/Virtualenv/tensorflow/bin/python
Installing setuptools, pip, wheel...done.
```

创建的虚拟环境默认不包含系统环境中的其他包，如果想在虚拟环境中继承系统原有的包，可以在创建环境的时候使用 `--system-site-packages` 参数。 

#### 使用/退出虚拟环境

使用 `source` 命令可以进入创建的虚拟环境，使用 `deactivate` 命令退出虚拟环境，命令行前的 `(tensorflow)` 表示目前处于 tensorflow 这个虚拟环境：

``` bash
$ source tensorflow/bin/activate
(tensorflow)$ deactivate
$
```

virtualenv 的原理就是把系统的 Python 复制一份到应用中，然后使用 `source` 命令修改环境变量，使 `python` 命令和 `pip` 命令指向虚拟环境中的 Python。

#### Pycharm

在 Pycharm 中选中 `Virtualenv Environment` 之后，可以选择刚刚创建的虚拟环境。也可以创建新的虚拟环境，Pycharm 简化了上面的流程，只需要选中应用的根目录，然后选择需要拷贝的解释器，再选择是否继承全局的 `site-packages` 即可。

### Conda Environment

[Anaconda](https://www.anaconda.com/download) 是一个 Python 的环境管理器 + 软件包管理器 + 其他科学包。由于 Anaconda 包含了大量的科学包，所以安装文件比较大(约 500MB)。如果不需要这些科学包，可以安装 Miniconda，它只包含了 conda 和 Python。

#### 创建虚拟环境

可以在图形界面中点击 `Create` 按钮，输入虚拟环境名称创建虚拟环境，Anaconda 还支持创建 R 语言的虚拟环境。或者可以使用以下命令创建虚拟环境 tensorflow：

``` bash
$ conda create -n tensorflow
```

`python=3*` 和 `python=2*` 参数可以指定创建虚拟环境的 Python 的版本。如果想在创建虚拟环境的时候安装一些包，则可以在以上命令后输入包名，以空格隔开；或者如果想直接把 `base(root)` 环境中所有的包复制过来，可以使用以下命令克隆 `base(root)`：

``` bash
$ conda create -n tensorflow --clone root
```

创建好的虚拟环境在 Anaconda 的安装目录下的 `envs` 环境中。

#### 使用/退出虚拟环境

* 使用
  * Mac OS/Linux: `$ source activate tensorflow`
  * Windows: `$ activate tensorflow`
* 退出
  * Mac OS/Linux: `$ source deactivate`
  * Windows: `$ deactivat`

#### 其他常用命令

* 为指定虚拟环境安装 package: 

  ``` bash
  $ conda install -n $ENVIRONMENT_NAME [$PACKAGE_NAMES]
  ```

* 移除指定虚拟环境中的 package: 

  ``` bash
  $ conda remove --name $ENVIRONMENT_NAME $PACKAGE_NAME
  ```

* 移除指定虚拟环境：

  ``` bash
  $ conda remove -n ENVIRONMENT_NAME --all
  ```

#### Pycharm

同样，在 Pycharm 中可以直接添加上面创建的虚拟环境，也可以输入虚拟环境的名称，然后选择 Python 的版本创建新的虚拟环境。

### System Interpreter

直接选择系统中已有的解释器，包括上面 virtualenv 和 Anaconda 创建的虚拟环境。

### SSH Interpreter

有时候需要开发环境跟运行环境一致，那么就可以创建远程解释器，本地编写代码后，同步到服务器，然后使用服务器的解释器远程调试应用。

如果之前有使用过 `Tools` -> `Deployment` -> `Configuration` 配置过服务器信息的可以直接选择服务器的配置文件，否则就输入服务器的主机名、端口号和用户名，点击下一步如果能和服务器握手成功,则需要输入密码或者选择私钥文件进行登录，最终选择服务器中的解释器即可。

使用该解释器创建应用后，会自动生成服务器配置文件以供同步应用到服务器。在 `Mappings` 标签页中可以配置同步应用的位置；在 `Excluded Paths` 中可以配置不需要同步的内容。在运行应用的时候，Windows 用户还需要修改 `Debug Configurations` 中的 Script path 和 Working directory 成服务器中对应的路径。

#### * 环境变量

如果在 Python 代码中需要执行一些服务器的命令，而这个命令是通过 `source` 命令加载到环境变量中的，那么就无法使用 `os.system()` 函数(该函数默认使用 sh 执行命令，sh 不支持 source 命令)去执行命令。例如我在服务器中使用的是 zsh，然后安装了一些软件，在 `.profile` 中添加命令到环境变量，然后又在 `.zshrc` 中 source .profile，就只能通过以下方法执行我需要的命令：

``` python
import subprocess

def execute_command(command):
    subprocess.Popen(['/bin/zsh', '-i', '-c', command]).communicate()
```

### Vagrant

Vagrant 是一个封装工具，把环境封装进 VirtualBox 保证环境一致。如果使用 VirtualBox 和 Vagrant 管理开发环境，那么选择 Vagrant 实例所在的文件夹和 Python 解释器的路径后，Pycharm 会自动执行 `vagrant up` 启动虚拟机，启动成功后会输出 Vagrant 主机的 URL，点击 OK 即可。

### Docker

Docker 是一个开源的应用容器引擎，在操作系统层面的虚拟化，对进程进行封装隔离，由于隔离的进程独立于宿主和其它的隔离的进程，因此也称其为容器。Docker 在容器的基础上，进行了进一步的封装，从文件系统、网络互联到进程隔离等等，极大的简化了容器的创建和维护。

传统虚拟机技术是虚拟出一套硬件后，在其上运行一个完整操作系统，在该系统上再运行所需应用进程；而容器内的应用进程直接运行于宿主的内核，容器内没有自己的内核，而且也没有进行硬件虚拟。传统的虚拟机技术启动应用服务往往需要数分钟，而 Docker 容器应用，由于直接运行于宿主内核，无需启动完整的操作系统。总而言之，共享的资源越多，需要的总资源就越少，但是隔离的能力也就越弱。

| 特性       | 容器               | 虚拟机      |
| ---------- | ------------------ | ----------- |
| 启动       | 秒级               | 分钟级      |
| 硬盘使用   | 一般为 `MB`        | 一般为 `GB` |
| 性能       | 接近原生           | 弱于        |
| 系统支持量 | 单机支持上千个容器 | 一般几十个  |

Docker 包括三个基本概念

- 镜像(`Image`): 类似于虚拟机中的镜像，是一个包含有文件系统的面向 Docker 引擎的只读模板。例如一个 Ubuntu 镜像就是一个包含 Ubuntu 操作系统环境的模板。
- 容器(`Container`): 类似于一个轻量级的沙盒，可以将其看作一个极简的 Linux 系统环境(包括root权限、进程空间、用户空间和网络空间等)，以及运行在其中的应用程序。Docker 引擎利用容器来运行、隔离各个应用。容器是镜像创建的应用实例，可以创建、启动、停止、删除容器，各个容器之间是是相互隔离的，互不影响。注意：镜像本身是只读的，容器从镜像启动时，Docker在镜像的上层创建一个可写层，镜像本身不变。
- 仓库(`Repository`): 类似于代码仓库，是 Docker 用来集中存放镜像文件的地方。一般每个仓库存放一类镜像，每个镜像利用tag进行区分，比如 Ubuntu 仓库存放有多个版本（12.04、14.04等）的 Ubuntu 镜像。

#### 获取镜像

可以从 [Docker Hub](https://hub.docker.com/explore) 中获取自己想要的镜像，也可以使用以下命令查找想要的镜像，由于这里需要配置 Python 解释器，所以就直接找一下  Python 的官方镜像(也可以安装 Ubuntu 的官方镜像，然后再进入交互界面安装 Python)：

``` bash
$ docker search python
NAME                               DESCRIPTION                                     STARS               OFFICIAL            AUTOMATED
python                             Python is an interpreted, interactive, objec…   2862                [OK]
django                             Django is a free web application framework, …   671                 [OK]
...
```

发现可以找到不少 Python 相关的镜像，然后使用以下命令获取对应版本的镜像 `python:tag`，不指定 tag 则默认获取最新版本：

``` bash
$ docker pull python
```

#### 启动/停止/重启/删除容器

有了镜像后就能够以这个镜像为基础启动并运行一个容器。以上面的 `python:latest` 为例，如果想启动里面的 `bash` 并且进行交互式操作的话，可以执行下面的命令：

``` bash
$ docker run -it --rm \
    python:latest \
    bash
root@b06e8c850289:/#
```

启动、停止、重启、删除容器命令：

```
$ docker start container_name/container_id
$ docker stop container_name/container_id
$ docker restart container_name/container_id
$ docker rm container_name/container_id
```

#### 创建镜像

在容器中安装应用后，如果需要创建新的镜像，可以使用 `exit` 命令退出容器，然后使用以下命令查看 Docker 中运行的容器：

``` bash
$ docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED            STATUS                   PORTS               NAMES
07a0378e6422        b470f2d0ab43        "/bin/sh"                About an hour ago   Created                                      pycharm_helpers_PY-181.4203.547
110cc3df0d0f        ubuntu:16.04        "/bin/echo 'Hello wo…"   3 hours ago         Exited (0) 3 hours ago                       jolly_meninsky
```

然后从容器创建一个新的镜像，执行 commit 操作后可使用 docker images 查看：

``` bash
$ docker commit -m "ubuntu with python" -a "randy" 07a0378e6422 randy/ubuntu:python
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED                  SIZE
randy/ubuntu        python              3905a12fbb09        Less than a second ago   115MB
ubuntu              16.04               0b1edfbffd27        4 weeks ago              113MB
```

使用 `Dockerfile` 可以指定镜像基础和一些其他操作，更加简便地配置 Docker。

#### 列出/删除镜像

可以使用以下命令，列出已经下载的镜像：

``` bash
$ docker image ls
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
python              latest              29d2f3226daf        3 weeks ago         912MB
ubuntu              16.04               0b1edfbffd27        4 weeks ago         113MB
...
```

可以使用以下命令，删除已经下载的镜像，其中`<$IMAGE>` 可以是 `镜像短 ID`、`镜像长 ID`、`镜像名` 或者 `镜像摘要`：

``` bash
$ docker image rm <$IMAGE1> [<$IMAGE2> ...]
```

#### Pycharm

在新建页面提供了三种方式连接 Docker 的 daemon 进程，可以直接选择 `Docker for Mac` ；如果安装了 Docker Machine 的话也可以选择 `Docker Machine` 连接本地或者虚拟机中的 Docker，Docker Machine 是一个可以在虚拟机上安装 Docker 引擎的工具，并且可以通过 `docker-machine` 的指令来管理这些虚拟机。

Docker Machine 可以通过以下命令安装：

``` bash
$ base=https://github.com/docker/machine/releases/download/v0.14.0
$ curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/usr/local/bin/docker-machine
$ chmod +x /usr/local/bin/docker-machine
```

### Docker compose

Docker Compose 是一个用来定义和运行复杂应用的 Docker 工具。一个使用 Docker 容器的应用，通常由多个容器组成。使用 Docker Compose 不再需要使用 shell 脚本来启动容器。  Compose 通过一个配置文件来管理多个Docker 容器，在配置文件中，所有的容器通过 services 来定义，然后使用 docker-compose 脚本来启动，停止和重启应用，和应用中的服务以及所有依赖服务的容器，非常适合组合使用多个容器进行开发的场景。

这是 JetBrains 官网提供的关于配置 Docker Compose 的[注意事项](https://www.jetbrains.com/help/pycharm/docker-compose.html)和[教程](https://www.jetbrains.com/help/pycharm/using-docker-compose-as-a-remote-interpreter-1.html)，只需要配置好 `docker-compose.yml` 配置文件即可。 

## 参考文献

[1] Docker—从入门到实践. https://legacy.gitbook.com/book/yeasy/docker_practice/details