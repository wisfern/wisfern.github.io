---
title: 使用ipdb调试python程序
categories:
  - tools
  - ipdb
tags:
  - python
  - ipdb
  - debug
abbrlink: '60695146'
date: 2018-05-31 09:05:58
description:
---

python的调试工具有gdb(加载python模块)、pdb、ipdb，其中pdb为python自带的模块。今天介绍一个Python的调试工具，叫做ipdb。有了这个再复杂的项目也能如抽丝剥茧般一点点揭开她的面纱。

今天介绍一个Python的调试工具，叫做ipdb。有了这个再复杂的项目也能如抽丝剥茧般一点点揭开她的面纱。

安装ipdb最简单的方法就是

```
pip install ipdb
```

调用ipdb

```
python -m ipdb script.py
```

<!-- more -->

## 功能列表

首先说明一下ipdb都有哪些功能。

![img](https://pic2.zhimg.com/80/v2-156aaaa08e29c1972050ffc90d006d07_hd.jpg)

![img](https://pic3.zhimg.com/80/v2-e57ebb114078e0d4863f0d80a3b93dca_hd.jpg)

![img](https://pic3.zhimg.com/80/v2-f3759f5578935adb1ed80296330bbc24_hd.jpg)

![img](https://pic1.zhimg.com/80/v2-8378cc34b26d468f20e0cc405c56e473_hd.jpg)

![img](https://pic1.zhimg.com/80/v2-d88a18f8a1e6dd6d6546c700db1d96b9_hd.jpg)

不仅如此，你还可以直接定义参数和函数、导入模块并且调用他们。

## 基本操作

我从github中节选了一段代码[openai/gym](https://link.zhihu.com/?target=https%3A//github.com/openai/gym/blob/master/examples/agents/cem.py)，假设左边的数字代表了代码在源文件中所处的行数。

```
77 n_elite = int(np.round(batch_size*elite_frac))
78 th_std = np.ones_like(th_mean) * initial_std
79
80 for _ in range(n_iter):
81    ths = np.array([th_mean + dth for dth in  th_std[None,:]*np.random.randn(batch_size, th_mean.size)])
82    ys = np.array([f(th) for th in ths])
83    elite_inds = ys.argsort()[::-1][:n_elite]
84    elite_ths = ths[elite_inds]
85    th_mean = elite_ths.mean(axis=0)
86    th_std = elite_ths.std(axis=0)
87    yield {'ys' : ys, 'theta_mean' : th_mean, 'y_mean' : ys.mean()}
```

### 1. 我想知道n_elite是什么变量（方框内为直接在命令提示符中输入的内容）

```
n 回车
连续按回车直到第77行执行完毕
p n_elite
```

或者

```
b 78 # 在第78行设置断点
c # 正常执行代码，在断点处停止
p n_elite # 查看n_elite的值
```

### 2. 我想知道np是干什么的

```
pdoc np # 显示np的说明文档，python自带的模块大多有文档。自制模块不一定有
```

### 3. 我想知道np的源代码在哪

```
pinfo np # File后面写的路径就是
```

### 4. 我想知道如果把batch_size的值换成其他值的计算结果

```
int(np.round(255*elite_frac)) # 直接换了数字执行计算
```

### 5. 我想知道ths每一次的迭代后的变化

```
b 83 # 在第83行设置断点
p ths
```

### 6. 每次迭代都要停顿，我想删除这个断点

```
cl bpnumber # bpnumber是断点的序号
```

### 7. 我想知道f是什么函数

```
source f # 查看f的源代码
```

### 8. 我想知道elite_ths除了mean和std以外还有哪些可以调用的参数和函数

```
pp vars(elite_ths)
pp dir(elite_ths)
```

### 9. 我想用pandas来编辑ths

```
import pandas as pd
ths_df = pd.DataFrame(ths)
```

### 10. 我想进入ones_like调试

```
j 77 # 跳到第77行，不过要注意跳转途中的代码不会被执行，所以有可能出现某参数没被定义的情况
s # 进入到下一步
```

### 11. 我当前在ones_like进行调试，我怎么调试n_elite

```
u # 回到上一层堆栈帧
p n_elite
```

### 12. 我当前在ones_like，我想结束调试返回上一层

```
r # 执行当前函数，返回值
```

### 13. 我想查看周围的代码

```
l或者ll
```

### 14. 我忘了怎么使用某个命令

```
h 某个命令
```

### 15. 我想重新调试但不想删除断点

```
run
```

### 16. 我想让程序运行，但遇到exception时开一个shell给我调试

```python
shell> ipython
In [1]: pdb                         # 打开异常时的调试终端，这样程序发生异常时就会停下来
Automatic pdb calling has been turned ON

In [2]: run order_monitor.py --config lbank.json
2018-05-31 13:16:02,202 INFO:ExchangeOrderMoniter server running ...

# 如果待执行的程序没有参数，可以直接写成`ipython -m pdb xxxx.py`
```
> ipython中的import跟正常的python程序一样，不会自动加载已经修改的py源代码，当调试的时候，遇到修改其他文件的时候，就得手工reload其他的源代码文件，这个时候，可以试试ipython的`autoreload`功能，这个功能默认没有打开。


## 最后

其实使用了gdb、pdb、ipdb，会发现这些调试器的命令都差不多，因此学习一个就基本可以通用这几些调试器。在gdb还有另外一个调试服务程序叫gdbserver，会在后台监听并执行远程客户端发过来的命令。

## 参考资料

1. [知乎专栏ipdb介绍](https://zhuanlan.zhihu.com/p/37218789?utm_source=qq&utm_medium=social&utm_oi=31253617180672)