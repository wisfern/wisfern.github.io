---
title: 记一次多核cpu负载不均衡问题
categories:
  - tools
  - balance
tags:
  - cpu
  - load balance
abbrlink: 6c820c50
date: 2018-05-27 09:29:35
description:
---

之前在一次strace进程的时候，发现一台多核cpu的负载并不均衡，最后几个cpu核心基本没啥事干。

# 工具集
采样使用mpstat工具，可以`info mpstat`查看mpstat的帮助信息。
```shell
> mpstat -P ALL 1 10

CPU    %usr   %nice    %sys %iowait    %irq   %soft ... %idle
all   17.57    0.03    1.78    0.00    0.35    0.23 ... 80.04
  0   43.17    0.00    4.12    0.00    1.41    1.00 ... 50.30
  1    9.80    0.00    0.81    0.00    0.00    0.00 ... 89.39
  2    9.31    0.00    1.20    0.00    0.00    0.00 ... 89.49
  3    7.94    0.10    0.80    0.00    0.00    0.00 ... 91.16
```
如上命令的含义是每秒运行一次 mpstat，一共采样 10 次取平均值，可以明显看出 CPU0 的空闲 idle 明显小于其它 CPUx，而且大部分都消耗在了用户态 usr 上面。

程序组cpu占用于哪一个cpu的采集工具为pidstat，这个工具的使用说明请见`info pidstat`。
```shell
> pidstat | grep php-fpm | awk '{print $(NF-1)}' | sort | uniq -c

157 0
 34 1
 34 2
 32 3
```

可见分配给 CPU0 的 PHP-FPM 进程比其他三个 CPUx 总和还要多。为什么大部分进程被分配给了 CPU0？我模模糊糊有一些印象是因为操作系统偏爱使用 CPU0，但我暂时也没找到实质的线索可以佐证，如果有人知道，麻烦告诉我。

# 问题解决

问题总要解决，既然 PHP-FPM 没有类似 Nginx 那样 CPU 亲缘性（affinity）绑定的指令，那么我们可以使用 taskset 绑定 PHP-FPM 进程到固定的 CPUx 来解决问题：

```
#!/bin/bash

CPUs=$(grep -c processor /proc/cpuinfo)
PIDs=$(ps aux | grep "php-fpm[:] pool" | awk '{print $2}')

let i=0
for PID in $PIDs; do
    CPU=$(echo "$i % $CPUs" | bc)
    let i++

    taskset -pc $CPU $PID
done
```

如上脚本运行后，让我们再来看看各个 CPU 负载分配情况如何：

```
shell> mpstat -P ALL 1 10

CPU    %usr   %nice    %sys %iowait    %irq   %soft ...  %idle
all   15.73    0.03    1.61    0.00    0.20    0.23 ...  82.20
  0   16.28    0.10    1.62    0.10    0.81    0.91 ...  80.18
  1   16.16    0.10    1.51    0.00    0.00    0.10 ...  82.13
  2   14.46    0.10    1.71    0.00    0.00    0.00 ...  83.73
  3   15.95    0.00    1.71    0.00    0.00    0.00 ...  82.35
```

终于平均了，不过需要提醒的是，一旦 PHP-FPM 处理的请求数超过 max_requests 的设置，那么对应的进程将自动重启，先前的 taskset 设置也将失效，所以为了一直有效，我们需要把 taskset 脚本添加到 CRON 配置中去，例如每分钟自动设置一遍！

本文把 PHP-FPM 进程平均分配给了 0，1，2，3 四个 CPU，实际操作的时候可以更灵活一些，比如前文我们提过，操作系统总是偏爱使用 CPU0，如果 CPU0 的负载已经很高了的话，那么我们不妨把 PHP-FPM 进程平均分配给 1，2，3 三个 CPU。


# 参考资料

1. [记录一个多核CPU负载不均衡问题](https://huoding.com/2016/07/19/528)