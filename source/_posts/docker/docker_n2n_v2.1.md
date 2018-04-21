---
title: Docker部署之n2n
categories:
  - docker
  - n2n
tags:
  - docker
  - n2n
  - p2p
  - tools
abbrlink: b75b53c3
date: 2018-04-20 21:39:05
description:
---

n2n是在数据链路层实现的一套P2P协议，包括super node 和 edge node。之前一直使用zerotier-one进行穿透，只是最近一直穿透不成功，因此就想试试n2n如何，这个n2n跟zerotier-one一样，可以实现把分布在全球各地的计算机穿透防火墙连接成一个局域网，这样可以把家里、公司等等的设备连接起来，达到互相访问的效果（局域网的体验）。

<!-- more -->
![img](https://pic1.zhimg.com/80/v2-0e1314e129d9c529ef7e08d4b5eb147d_hd.jpg)

具体原理可以参看作者的论文[http://www.n2n.org.cn/doc/n2n.pdf](http://www.n2n.org.cn/doc/n2n.pdf)。而且最重要的是n2n是开源的，遵循GPL v3协议，可运行于Linux，Windows，Android，甚至是Openwrt之上。

在公司和家里研究了一天，编译、配置、部署，问题解决等，真是无语。

# 原生系统

- 搭建super node：搭建super node需要公网IP，但好在搭建super node 并不是必须的，我们也可以使用[公用的super node](http://www.lucktu.com/archives/749.html)，且不用担心使用公用super node 的安全性问题，因为两个edge的通信数据并不经过super node，具体原理参看论文及源码。

- 原版的n2n作者已经没有在维护，好在软件开源。全世界还有人在不断地维护着n2n，我在github上面找到一个维护得比较新的版本[[github仓库](https://github.com/meyerd/n2n.git)]，这个版本修改了V2，不同的是这里的V2为V2.1，大幅修改了n2n协议，不再与之前的n2n兼容，作者目的为了n2n v3做准备，也许不久的将来可以看到n2n v3的出现。

## n2n v2.1编译过程
实验环境为ubuntu 18.04 LTS

  ```
  $ sudo apt-get install git build-essential libssl-dev
  $ git clone https://github.com/meyerd/n2n.git
  $ cd n2n/n2n_v2
  $ mkdir build
  $ cd build
  $ cmake ..
  $ make
  $ sudo make install
  $ supernode -l 2053 -f
  ```

  然后也可以在super node的服务器上建立 edge node，命令格式如下：

  ```
  $ edge -d [tun name] -a [Local_IP] -c [net name] -k [key] -u 1000 -g 100 -l [supernode IP]:[supernode port]
  ```
  **所有同一个n2n网络的net name和key必须一样，这样才能连接在一起。**

  一个实例：

  ```
  $ edge -d edge0 -a 10.9.9.1 -c wisfern_n2n2s -k 12345 -u 1000 -g 100 -l n2n.lucktu.com:10088 -r
  ```

## 搭建启动命令

- 搭建edge node：搭建过程与super node相同，只是最后启动edge node时配置好自己的IP就行

  ```
  $ edge -d edge1 -a 10.9.9.10 -c wisfern_n2n2s -k 12345 -u 1000 -g 100 -l n2n.lucktu.com:10088 -r
  $ ifconfig
  ```

  此时在此电脑上应该会看到类似下面的信息

  ```
  edge1     Link encap:以太网  硬件地址 xx:xx:xx:xx:xx:xx  
            inet 地址:10.0.0.10  广播:10.0.0.255  掩码:255.255.255.0
            inet6 地址: xxxx::xxxx:xxxx:xxxx:xxxx/64 Scope:Link
            UP BROADCAST RUNNING MULTICAST  MTU:1400  跃点数:1
            接收数据包:0 错误:0 丢弃:0 过载:0 帧数:0
            发送数据包:38 错误:0 丢弃:0 过载:0 载波:0
            碰撞:0 发送队列长度:1000 
            接收字节:0 (0.0 B)  发送字节:6463 (6.4 KB)
  ```

  此时可以在edge所在的电脑上 ping 10.0.0.1 , 测试连通性。

  ​

- 搭建其他edge node ：方法同上，注意配置不同的ip。然后edge间就可以没羞没躁地穿透层层NAT愉快地玩耍啦。


## 服务化

为了在linux上常驻，可以借助systemd或者supervisord，记录一下systemd的服务化过程。

编译好后的edge复制到/opt/edge，然后编写n2n.service文件。

```
# cat > /opt/n2n.service
[Unit]
Description=n2n2s daemon
After=rc-local.service

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=/tmp
ExecStart=/opt/edge -d n2n0 -a 10.9.9.176 -c wisfern_n2n2s -k 12345 -l n2n.lucktu.com:10088 -r -f
Restart=always

[Install]
WantedBy=multi-user.target
```

编写完成之后，部署到`cp /opt/n2n.service /etc/systemd/system/`，然后运行命令初始化和启动

```
# systemctl daemon-reload
# systemctl start n2n
# systemctl status n2n
# systemctl logs -f n2n
```

后续有精力再弄成deb包。




# Docker容器

用docker的话，也有套路，找个位置记录下。

## Dockerfile

```dockerfile
FROM ubuntu:18.04
MAINTAINER <wisfern@qq.com>

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update \
    && apt-get -yy upgrade \
    && apt-get install -y git cmake make gcc g++ libssl-dev net-tools iproute2 \
    && git clone https://github.com/meyerd/n2n.git \
    && cd n2n/n2n_v2 \
    && mkdir build; cd build \
    && cmake .. \
    && make; make install \
    && cd ~; rm -rf n2n \
    && apt-get -yy autoremove git cmake make gcc g++ libssl-dev \
    && apt-get -yy autoclean \
    && rm -rf /var/lib/apt/lists/*
```

## 镜像构建

```
docker build -t docker_n2n:v2.1 .
```

> 注意后面的.(点)，表示当前目录。
>
> 构建完之后，可以把镜像推送到云容器镜像服务站（自行解决）。

## 启动方法

edge节点

```
# 1st edge node
docker run -d --privileged --restart=always --name=edge2s --net=host docker_n2n:v2.1 edge -d n2n0 -a 10.9.9.213 -c wisfern_n2n2s -k 12345 -l n2n.lucktu.com:10088 -f
# 2nd edge node
docker run -d --privileged --restart=always --name=edge2s --net=host docker_n2n:v2.1 edge -d n2n0 -a 10.9.9.120 -c wisfern_n2n2s -k 12345 -l n2n.lucktu.com:10088 -f

# supernode, have public ip
docker run -d --restart=always --name=supernode2s --net=host -p 2053/udp docker_n2n:v2.1 supernode -l 2053 -f
```

> 每个edge节点，-a后面的ip地址都不同，代表不同的本地网卡ip地址。-f表示前端输出。-r 表示数据转发。
>
> 超级节点必须部署在有公网的计算机上，并且放开 -l 后面指定的udp端口。

docker 容器

```
$ sudo docker ps 
[sudo] devis 的密码：
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
7170e9de9c98        docker_n2n:v2.1     "edge -d n2n0 -a 1..."   5 hours ago         Up 5 hours                              edge2s
```

网络信息

```
$ ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
55: n2n0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1400 qdisc pfifo_fast state UNKNOWN group default qlen 1000
    link/ether fa:00:e7:00:00:64 brd ff:ff:ff:ff:ff:ff
    inet 10.9.9.213/24 brd 10.9.9.255 scope global n2n0
       valid_lft forever preferred_lft forever
    inet6 fe80::0000:e7ff:0000:8364/64 scope link 
       valid_lft forever preferred_lft forever
```

# 可能问题

1. 连接后，ping得edge节点，但ping不通edge节点后面的内网机器。这里有两种可能的原因，一个是本机路由没有配置正确，第二个是防火墙和NAT转发没有配置正确。防火墙主要加入这样的两句到防火墙里面去。其中XXX是在edge后面带 -d 参数设置的网卡名。

   ```
   iptables -t nat -A POSTROUTING -j MASQUERADE &
   iptables -I INPUT -i XXX -j ACCEPT
   ```
   [Linux 路由的配置](archives/d34856fa.html)
   ```
   route add -net 192.168.11.0/24 gw 10.0.0.11 &
   帮助参考
   $ sudo route add
   Usage: inet_route [-vF] del {-host|-net} Target[/prefix] [gw Gw] [metric M] [[dev] If]
       inet_route [-vF] add {-host|-net} Target[/prefix] [gw Gw] [metric M]
                              [netmask N] [mss Mss] [window W] [irtt I]
                              [mod] [dyn] [reinstate] [[dev] If]
       inet_route [-vF] add {-host|-net} Target[/prefix] [metric M] reject
       inet_route [-FC] flush      NOT supported
   ```
   windows路由的添加有些不同，原理一样。

2. 怎么设置 supernode 为我所独用？

   假设自己使用的 n2n 是这样运行的（以n2nabc 账号）

   ```
   edge -d edge0 -c n2nabc-k pwd -a 10.10.10.1 -l ip:10082
   ```

   那么在 supernode 服务器上增加一条防火墙，监视 10082端口通过的字符串，只准账号中含有 n2nabc 字符的通过即可。

   ```
   iptables -I INPUT 1 -pudp --dport 10082 -m string ! --string "n2nabc" --algo bm -jDROP
   ```