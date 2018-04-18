---
title: Linux之route
categories:
  - system
  - route
tags:
  - route
  - linux
typora-root-url: ./route-of-linux/
abbrlink: d34856fa
date: 2018-04-18 17:31:48
description:
---

`route`，顾名思义，指的就是路由，用于标示系统中每一个网络包传递的下一个目标。route`命令在Linux/windows系统中，就是为了管理路由信息而存在，自定义路由得以让多网卡终端的计算机实现访问不同网络以及转发网络数据包（路由器）。

route命令在Linux和Windows知识原理一样，但命令参数有小差异，在运用的时候，要注意多看一下help。特别的，route在Windows下可以加个-p实现永久静态路由，而Linux没有此方法，解决方法要么写在网络启动配置文件，要么写在`/etc/rc.local`，让系统在启动过程中自动设置静态路由，以此实现永久路由。

<!-- more -->

更多的路由知识，请自行上网搜索学习，这是网络工程的基础知识。



# 路由

## 静态路由

```shell
# 手工指定192.168.1.1的数据包目的地为192.168.1.254，实现数据包转发
route add -net 192.168.1.1/32 gw 192.168.1.254
```

## 默认路由

```shell
# 指定0.0.0.0地址的跳转目的，这个路由就为默认路由，作用是当一个数据包找不到匹配的路由时，会匹配到这一条默认的路由信息
route add -net 0.0.0.0/32 192.168.1.1

# 或者
route add default gw 192.168.1.1
```

## 动态路由

这个基本在核心网络设置才会明显感觉，自治路由信息。



# 实例

## 查看路由

```shell
$ route -n
# 在windows下，会有很多的不同参数，更详细的还请阅读route help
$ route print -4 
```

## 添加/屏蔽/删除一条路由

```shell
route add -net 172.16.0.0 netmask 255.255.0.0 dev eth0
route add -net 172.16.0.0 netmask 255.255.0.0 reject
route del -net 172.16.0.0 netmask 255.255.0.0
```

## 添加/删除默认路由

```shell
route add default gw 192.168.1.1
route del default gw 192.168.1.1
```



# route命令详解

```shell
route命令输出的路由表字段含义如下：
    Destination 目标
          The destination network or destination host. 目标网络或目标主机。

    Gateway 网关
          The gateway address or '*' if none set. 网关地址，如果没有就显示星号。

    Genmask 网络掩码
          The  netmask  for  the  destination net; '255.255.255.255' for a
          host destination and '0.0.0.0' for the default route.

    Flags：总共有多个旗标，代表的意义如下：                        
          o U (route is up)：该路由是启动的；                       
          o H (target is a host)：目标是一部主机 (IP) 而非网域；                       
          o G (use gateway)：需要透过外部的主机 (gateway) 来转递封包；                       
          o R (reinstate route for dynamic routing)：使用动态路由时，恢复路由资讯的旗标；                     o D (dynamically installed by daemon or redirect)：已经由服务或转 port 功能设定为动态路由           o M (modified from routing daemon or redirect)：路由已经被修改了；                               o !  (reject route)：这个路由将不会被接受(用来抵挡不安全的网域！)
          o A (installed by addrconf)
          o C (cache entry)

     Metric 距离、跳数。暂无用。
           The 'distance' to the target (usually counted in  hops).  It  is
           not  used  by  recent kernels, but may be needed by routing dae-
           mons.

     Ref   不用管，恒为0。
           Number of references to this route. (Not used in the Linux  ker-nel.)

     Use   该路由被使用的次数，可以粗略估计通向指定网络地址的网络流量。
           Count  of lookups for the route.  Depending on the use of -F and
           -C this will be either route cache misses (-F) or hits (-C).

     Iface 接口，即eth0,eth0等网络接口名
           Interface to which packets for this route will be sent.
```



# 参考资料

1. [Linux Route](http://www.cnblogs.com/274914765qq/p/5246863.html)
2. [路由转发与诊断](https://linux.cn/article-3931-1.html)