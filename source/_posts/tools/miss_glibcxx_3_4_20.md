---
title: 缺失GLIBCXX_3.4.20版本问题解决
categories:
  - tools
  - gcc
tags:
  - zerotier-one
  - gcc
  - linux
abbrlink: cb3d02d8
date: 2018-04-20 12:29:52
description:
---

使用自行编译的gcc 4.9.4去编译zerotier-one 1.2.6 成功后，却运行不起来，发生了错误
```shell
[root@vc176 ZeroTierOne-1.2.6]# ./zerotier-one -h
./zerotier-one: /lib64/libstdc++.so.6: version `GLIBCXX_3.4.20' not found (required by ./zerotier-one)
```

这个错误的解决要从linux下程序的启动过程有所了解，这个过程会加载libstdc++.so库，而在这个库中没有找到GLIBCXX_3.4.20，因此失败了。
<!-- more -->
```shell
[root@vc176 ZeroTierOne-1.2.6]# strings /lib64/libstdc++.so.6 | grep GLIBCXX
GLIBCXX_3.4
GLIBCXX_3.4.1
GLIBCXX_3.4.2
GLIBCXX_3.4.3
GLIBCXX_3.4.4
GLIBCXX_3.4.5
GLIBCXX_3.4.6
GLIBCXX_3.4.7
GLIBCXX_3.4.8
GLIBCXX_3.4.9
GLIBCXX_3.4.10
GLIBCXX_3.4.11
GLIBCXX_3.4.12
GLIBCXX_3.4.13
GLIBCXX_3.4.14
GLIBCXX_3.4.15
GLIBCXX_3.4.16
GLIBCXX_3.4.17
GLIBCXX_3.4.18
GLIBCXX_3.4.19
GLIBCXX_DEBUG_MESSAGE_LENGTH
[root@vc176 ZeroTierOne-1.2.6]# yum provides libstdc++.so.6
Loaded plugins: fastestmirror
Repository HDP-UTILS-1.1.0.21 is listed more than once in the configuration
Loading mirror speeds from cached hostfile
 * base: mirrors.163.com
 * extras: mirrors.cn99.com
 * updates: mirrors.cn99.com
libstdc++-4.8.5-16.el7.i686 : GNU Standard C++ Library
Repo        : base
Matched from:
Provides    : libstdc++.so.6



libstdc++-4.8.5-16.el7_4.1.i686 : GNU Standard C++ Library
Repo        : updates
Matched from:
Provides    : libstdc++.so.6



libstdc++-4.8.5-16.el7_4.2.i686 : GNU Standard C++ Library
Repo        : updates
Matched from:
Provides    : libstdc++.so.6

[root@vc176 ZeroTierOne-1.2.6]# yum install libstdc++-4.8.5-16.el7_4.2
Loaded plugins: fastestmirror
Repository HDP-UTILS-1.1.0.21 is listed more than once in the configuration
Loading mirror speeds from cached hostfile
 * base: mirrors.163.com
 * extras: mirrors.cn99.com
 * updates: mirrors.cn99.com
Package libstdc++-4.8.5-16.el7_4.2.x86_64 already installed and latest version
Nothing to do
```
到了这里，已经说明云仓库里面的libc版本都太老了。而我们这里使用gcc 4.9.4编译的zertier-one 1.2.6，因此需要定义一下新的库。
解决方法
1. 从路径/usr/local/lib64拷贝文件libstdc++.so.6.0.20到路径/usr/lib64
2. 删除/usr/lib64原来的libstdc++.so.6 #强烈建议删除之前先备份一份
3. 重新建立软连接ln libstdc++.so.6.0.20 libstdc++.so.6
4. 重新执行strings /usr/lib64/libstdc++.so.6 | grep GLIBCXX

执行过程
```shell
# mv /usr/lib64/libstdc++.so.6 /usr/lib64/libstdc++.so.6.bak
# ln -s /usr/local/lib64/libstdc++.so.6.0.20 /usr/lib64/libstdc++.so.6
# strings /usr/lib64/libstdc++.so.6 | grep GLIBCXX
GLIBCXX_3.4
GLIBCXX_3.4.1
GLIBCXX_3.4.2
GLIBCXX_3.4.3
GLIBCXX_3.4.4
GLIBCXX_3.4.5
GLIBCXX_3.4.6
GLIBCXX_3.4.7
GLIBCXX_3.4.8
GLIBCXX_3.4.9
GLIBCXX_3.4.10
GLIBCXX_3.4.11
GLIBCXX_3.4.12
GLIBCXX_3.4.13
GLIBCXX_3.4.14
GLIBCXX_3.4.15
GLIBCXX_3.4.16
GLIBCXX_3.4.17
GLIBCXX_3.4.18
GLIBCXX_3.4.19
GLIBCXX_3.4.20
```

解决了。
```shell
[root@vc176 ZeroTierOne-1.2.6]# ./zerotier-one -h
ZeroTier One version 1.2.6
Copyright (c) 2011-2018 ZeroTier, Inc.
This is free software: you may copy, modify, and/or distribute this
work under the terms of the GNU General Public License, version 3 or
later as published by the Free Software Foundation.
No warranty expressed or implied.

Usage: ./zerotier-one [-switches] [home directory]

Available switches:
  -h                - Display this help
  -v                - Show version
  -U                - Skip privilege check and do not attempt to drop privileges
  -p<port>          - Port for UDP and TCP/HTTP (default: 9993, 0 for random)
  -d                - Fork and run as daemon (Unix-ish OSes)
  -i                - Generate and manage identities (zerotier-idtool)
  -q                - Query API (zerotier-cli)
  ```