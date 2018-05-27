---
title: 记一次后台程序性能问题检查
categories:
  - tools
  - strace
tags:
  - strace
  - ltrace
abbrlink: a7676301
date: 2018-05-27 08:10:25
description:
---

# 序言

生产中的程序最近出现了性能问题，任务堆积量达到了10万级，而每个程序的cpu占用均没有100%，io也没有100%，于是有了这一遍文章记录性能检查过程。使用的工具为`strace`与`ltrace`，前者用于内核态调用，后者用于用户态调用。

<!-- more -->

# 性能现象

监控警告待处理任务超过10万，需要后台检查。一例高负载服务器进程top结果:
```shell
top - 08:35:02 up 422 days, 15:29, 14 users,  load average: 44.57, 42.67, 40.79
Tasks: 1108 total,   5 running, 1098 sleeping,   0 stopped,   5 zombie
Cpu0  : 46.4%us,  8.3%sy,  0.0%ni, 30.5%id, 14.9%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu1  : 54.1%us,  3.3%sy,  0.0%ni, 33.0%id,  9.6%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu2  : 55.8%us,  8.3%sy,  0.0%ni, 31.4%id,  4.6%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu3  : 41.0%us, 18.4%sy,  0.0%ni, 36.1%id,  4.6%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu4  : 55.6%us, 11.6%sy,  0.0%ni, 24.8%id,  7.9%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu5  : 50.0%us,  8.3%sy,  0.0%ni, 33.1%id,  8.6%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu6  : 54.8%us,  6.3%sy,  0.0%ni, 37.6%id,  1.3%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu7  : 49.3%us, 21.9%sy,  0.0%ni, 18.2%id, 10.3%wa,  0.0%hi,  0.3%si,  0.0%st
Mem:  132107852k total, 127553096k used,  4554756k free,  2373296k buffers
Swap: 67108856k total,  1075388k used, 66033468k free, 113083052k cached

    PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
1272836 jh_hdjh   20   0  229m  90m  18m R 92.2  0.1 312:33.79 abs_format
1273553 jh_hdjh   20   0  229m  90m  18m D 89.2  0.1 314:01.15 abs_format
1272546 jh_hdjh   20   0  229m  90m  18m D 88.3  0.1 309:45.52 abs_format
1271859 jh_hdjh   20   0  229m  90m  18m D 85.0  0.1 311:42.73 abs_format
1273090 jh_hdjh   20   0  229m  90m  18m D 84.0  0.1 308:09.31 abs_format
1271563 jh_hdjh   20   0  229m  90m  18m D 83.7  0.1 311:51.82 abs_format
```

> tips: 按`1`可以调出cpu列表，再按`shift+p`按cpu使用率排序。
>
> 上表`us`为用户态cpu占用率，`sy`为内核态cpu占用率，`id`为cpu空闲率。

从上面的结果来看，这cpu的占用率并不高，至多只有80%。内存占用也不多，还有相当多的内存空闲，也就不是swap的问题，那来看看是不是io占用过高的因素。

```shell
> iostat -x 2
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
          53.40    0.00   13.62    2.27    0.00   30.72

Device:         rrqm/s   wrqm/s     r/s     w/s   rsec/s   wsec/s avgrq-sz avgqu-sz   await  svctm  %util
dm-2              0.00     0.00    0.00 48828.50     0.00 390628.00     8.00  5206.04   25.51   0.01  61.65
dm-3              0.00     0.00    0.50    0.00     4.00     0.00     8.00     0.37    0.00 741.00  37.05
dm-4              0.00     0.00    0.00   13.50     0.00   108.00     8.00     5.54    0.04  15.81  21.35
```

从io占用率来看，最多也只有60%，到了这里可以大概率判定为程序的问题。Linux 操作系统有很多用来跟踪程序行为的工具，内核态的函数调用跟踪用`strace`，用户态的函数调用跟踪用`ltrace`，所以这里我们应该用`strace`。

# 性能跟踪

1. 首先，strace提供了一个选项`-c`，统计输出每一个系统调用的时长、次数、比率等。

```shell
$ strace -p 1160508 -c 
Process 1160508 attached - interrupt to quit
^CProcess 1160508 detached
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
 89.07    0.010488           0    200135           stat
  9.23    0.001087           2       523           write
  1.70    0.000200           2       129           read
  0.00    0.000000           0        10           open
  0.00    0.000000           0        10           close
  0.00    0.000000           0        10           fstat
  0.00    0.000000           0        10           fcntl
  0.00    0.000000           0         5           rename
  0.00    0.000000           0         4           unlink
------ ----------- ----------- --------- --------- ----------------
100.00    0.011775                200836           total
```

一目了然，90%的stat内核调用。

2. 单独跟踪一下stat的调用

```shell
$ strace -T -e stat -p 1160508
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=405, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=405, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=405, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=405, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=405, ...}) = 0
stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=405, ...}) = 0
```

这特么的一堆确定是否配置时区，直观上，系统设置完时区，程序第一次获取到时区之后，一般不用再检查时区问题了，为什么呢？

因为业务处理中每行记录都有格式化时间字符串的需求，如下代码，但系统没有TZ变量，程序也没有执行tzset，于是每行记录都需要去确定是否定义了时区。

```c++
strftime(call->date_time,DATELEN,"%Y%m%d %H%M%S",&tm_buf);
```

# 问题解决

知道了原因，解决方案就简单了，参考[How to avoid excessive stat(/etc/localtime) calls in strftime() on linux?](https://stackoverflow.com/questions/4554271/how-to-avoid-excessive-stat-etc-localtime-calls-in-strftime-on-linux)，我们只需要在启动程序的时候设置一下TZ变量，`export TZ=:/etc/localtime`，即可解决这个stat系统调用。

优化效果：

```shell
$ strace -p 1272281 -c
Process 1272281 attached - interrupt to quit
^CProcess 1272281 detached
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
 49.67    0.001125        1125         1           getdents
 44.15    0.001000           2       664           read
  6.18    0.000140           0      2599           write
  0.00    0.000000           0        50           open
  0.00    0.000000           0        50           close
  0.00    0.000000           0        50           fstat
  0.00    0.000000           0        50           fcntl
  0.00    0.000000           0        25           rename
  0.00    0.000000           0        25           unlink
------ ----------- ----------- --------- --------- ----------------
100.00    0.002265                  3514           total
```

时间长stat的调用没有了，比较多的还是目录操作和IO读写。
下一步的优化是优化IO操作，分别为目录读取和文件读写。

如果我们用 strace 跟踪一个进程，输出结果很少，是不是说明进程很空闲？其实试试 ltrace，可能会发现别有洞天。记住有内核态和用户态之分。
ltrace命令的使用方法跟strace一样，依葫芦画瓢。

# 参考资料

1. [strace-cheat-sheet](https://blog.packagecloud.io/eng/2015/11/15/strace-cheat-sheet/)
2. [How to avoid excessive stat(/etc/localtime) calls in strftime() on linux?](https://stackoverflow.com/questions/4554271/how-to-avoid-excessive-stat-etc-localtime-calls-in-strftime-on-linux)