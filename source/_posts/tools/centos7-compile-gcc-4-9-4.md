---
title: Linux之编译gcc 4.9.4
categories:
  - tools
  - gcc
tags:
  - centos
  - gcc
  - json
  - zerotier  
abbrlink: 3207f237
date: 2018-04-20 09:33:30
description:
---

为了编译zerotier-one 1.2.6版本，而这个版本所依赖的json解析库要求的gcc编译器至少要在4.9以上，而centos 7自带的编译器才4.8.5，因此有了这一篇文章。

<!-- more -->

# 源代码下载
```shell
# wget http://ftp.gnu.org/gnu/gcc/gcc-4.9.4/gcc-4.9.4.tar.gz
# tar xzf gcc-4.9.4.tar.gz 
```

# 下载编译依赖
```shell
# cd gcc-4.9.4
# ./contrib/download_prerequisites
```
> 注意：第二行命令，只能在gcc-4.9.4这个根目录执行，这样下载回来的依赖会放在这个根目录，后面编译gcc时，这几个依赖库会自动先编译，不用自动手动一个个编译。。

# 编译
作用：编译过程中的临时中间文件会存放在这个编译目录，不会污染源代码目录。
```shell
# mkdir gcc-build-4.9.4; cd gcc-build-4.9.4
# ../configure --enable-checking=release --enable-languages=c,c++ --disable-multilib
# make -j 4
```
编译参数说明

 * --enable-languages 表示你要让你的gcc支持那些语言
 * --disable-multilib 不生成编译为其他平台可执行代码的交叉编译器
 * --disable-checking 生成的编译器在编译过程中不做额外检查，也可以使用--enable-checking=xxx来增加一些检查；
 * --prefix=/opt/gcc 这个没加，默认安装到/usr/local
> 如果不知道cpu核数的话，可以用lscpu看一下，我这里的机器只有4个核心，因此使用-j 4，加快编译速度，这个编译过程很慢的。

# 安装与使用

```shell
# 安装到/usr/local，如果想安装到其他地方，需要在configure的时候指定--prefix参数
make install

# 在~/.bash_profile配置库文件和头文件路径
export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64/:$LD_LIBRARY_PATH
export C_INCLUDE_PATH=/usr/local/include/:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=/usr/local/include/:$CPLUS_INCLUDE_PATH
```
source ~/.bashrc 或者重新登陆，可以看到效果
```shell
# gcc -v
Using built-in specs.
COLLECT_GCC=gcc
COLLECT_LTO_WRAPPER=/usr/local/libexec/gcc/x86_64-unknown-linux-gnu/4.9.4/lto-wrapper
Target: x86_64-unknown-linux-gnu
Configured with: ../configure --enable-checking=release --enable-languages=c,c++ --disable-multilib
Thread model: posix
gcc version 4.9.4 (GCC) 
```
