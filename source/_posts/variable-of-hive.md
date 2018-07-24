---
title: Hive之变量
categories:
  - docs
  - hive
tags:
  - hive
  - sql
  - variable
  - beeline
  - set
abbrlink: 7ad6afeb
date: 2018-07-23 11:14:04
description:
---

这一个月一直在忙碌公司的稽核项目，基层组件为Hive，大量使用着Hive各种变量，shell变量、JVM变量、配置变量等，这些变量会分布在几大命名空间中。此文仅仅记录这些变量的分类与使用总结，大概会涉及如下的命令和SQL语句：
```
hive/beeline --define --hivevar --hiveconf
set语句;
```
<!-- more -->
#命名空间

##hivevar命名空间

用户自定义变量

```
hive -d name=zhangsanhive --define name=zhangsanhive -d a=1 -d b=2
```

效果跟hivevar是一样的

```
hive --hivevar a=1 --hivevar b=2
```

引用hivevar命名空间的变量时，变量名前面可以加hivevar:也可以不加

```
set name;
set name=zhangsan;
set hivevar:name;
set hivevar:name=zhangsan;
```

在代码中使用${}引用，变量名前面可以加hivevar:也可以不加

```
create table ${a} ($(b) int);
create table $a ($b int);
```

## hiveconf命名空间

hive的配置参数，覆盖hive-site.xml（hive-default.xml）中的参数值

```
hive --hiveconf hive.cli.print.current.db=true --hiveconf hive.cli.print.header=true
```

```
hive --hiveconf hive.root.logger=INFO,console
```

启动时指定用户目录，不同的用户不同的目录

```
hive --hiveconf hive.metastore.warehouse.dir=/hive/$USER
```

引用hiveconf命名空间的变量时，变量名前面可以加hiveconf:也可以不加

```
set hive.cli.print.header;
set hive.cli.print.header=false;
```

## sytem命名空间

JVM的参数，不能通过hive设置，只能读取

引用时，前面必须加system:

```
set sytem:user.name;
```

```
create table ${system:user.name} (a int);
```

## env命名空间

shell环境变量，引用时必须加env:

```
set env:USER;set env:HADOOP_HOME;
```

```
create table ${env:USER} (${env:USER} string);
```

# 附录：常用的设置

- *在会话里输出日志信息*

```
hive --hiveconf hive.root.logger=DEBUG,console
```

也可以修改$HIVE_HOME/conf/hive-log4j.properties的hive.root.logger属性，但是用set命令是不行的。

- *显示当前数据库*

```
set hive.cli.print.current.db=true;
```

- *显示列名称*

```
set hive.cli.print.header=true;
```

- *向桶表中插入数据前，需要启用桶*

```
create table t1 (id int) clustered by (id) into 4 buckets;set hive.enforce.bucketing=true;insert into table t1 select * from t2;
```

向桶表insert数据时，hive自动根据桶表的桶数设置reduce的个数。否则需要手动设置reduce的个数：set mapreduce.job.reduces=N（桶表定义的桶数）或者mapred.reduce.tasks，然后在select语句后加clustered by 

- *动态分区相关*

```
set hive.exec.dynamic.partition=true #开启动态分区
set hive.exec.dynamic.partition.mode=nostrict #动态分区模式：strict至少要有个静态分区，nostrict不限制
set hive.exec.max.dynamic.partitions.pernode=100 #每个mapper节点最多创建100个分区set hive.exec.max.dynamic.partitions=1000 #总共可以创建的分区数
```

from t insert overwrite table p  partition(country, dt) select ... cuntry, dt

上面的查询在执行过程中，单个map里的数量不受控制，可能会超过hive.exec.max.dynamic.partition.pernode配置的数量，可以通过对分区字段分区解决，上面的sql改成：

from t insert overwrite table p  partition(country, dt) select ... cuntry, dt **distributed by** country, dt;

- *hive操作的执行模式*

```
set hive.mapred.mode=strict
```

strict：不执行有风险（巨大的mapreduce任务）的操作，比如：**笛卡尔积、没有指定分区的查询、bigint和string比较、bigint和double比较、没有limit的orderby**

nostrict：不限制

- *压缩mapreduce中间数据*

```
set hive.exec.compress.intermediate=true;
```

```
setmapreduce.map.output.compress.codec=org.apache.hadoop.io.compress.SnappyCodec; #设置中间数据的压缩算法，默认是org.apache.hadoop.io.compress.DefaultCodec
```

- *压缩mapreduce输出结果*

```
set hive.exec.compress.output=true;
```

```
set mapreduce.output.fileoutputformat.compress.codec=org.apache.hadoop.io.compress.GzipCodec #设置输出数据的压缩算法，使用GZip可以获得更好的压缩率，但对mapreduce而言是不可分隔的
```

```
set mapreduce.output.fileoutputformat.compress.type=BLOCK; #如果输出的是SequenceFile，则使用块级压缩
```

- 启用对分区归档

```
set hive.archive.enabled=true;
```
- *设置任务名*

```
set mapred.job.name=app_name;    # 此app_name会显示在yarn前台上面
```

- *开并行*

```
set hive.exec.parallel=true;
set hive.exec.parallel.thread.number=16;
```

- *任务优先级*

```
set yarn.app.priority=VERY_HIGH;
set mapreduce.job.priority=VERY_HIGH;
```

- *当有多个运行队列可选时，指定运行队列*

```
set mapred.job.queuename=queue_name;
```

- *设置reduce数*

```
set mapred.reduce.tasks=20;
```

- *设置map分片参数，可以借此控制map数*

```
set mapred.min.split.size=1000000;
set mapred.max.split.size=1000000;
set mapred.min.split.size.per.node=1000000;
set mapred.min.split.size.per.rack=1000000;
```