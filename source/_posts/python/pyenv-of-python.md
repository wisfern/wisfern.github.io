---
title: python之多版本控制
categories:
  - develop
  - python
tags:
  - python
  - pyenv
  - virtualenv
abbrlink: 302d2a51
date: 2018-05-22 13:23:06
description:
---


# 序言

在nodejs中用过一个工具叫nvm（nodejs version manager）,可以下载安装切换删除多个版本的nodejs，很方便代码编写与测试。再加上很好用的npm或者yarn，就构成了javascript的执行器版本和包管理的全部。
那么在python的世界，是否也有同样的两个工具呢，还别说，真有。那就是pyenv和pyvenv，以及2016年出来的pipenv。
<!-- more -->

pyenv：python版本管理器

pipenv：python依赖管理器，比pip更先进

pyvenv：python虚拟环境管理器

> update1: 新增pipenv，功能类似于nodejs的`npm` & `yarn`推荐用这个工具。

# pipenv

这是python更好的包依赖管理器，功能类似于nodejs的`npm`，关于它的起源可以见[A Better Pip Workflow™](https://www.kennethreitz.org/essays/a-better-pip-workflow)。

暂时先记录如下几个命令，更多的功能等后续使用后再来更新些文。

```shell
pipenv --venv           # 查看 venv 位置
pipenv --python 3.6.5   # 使用python 3.6.5创建新的项目
pipenv --three / --two  # 使用python3或者python2创建virtualenv
pipenv install --dev    # 为项目安装所有的包，包含dev依赖
pipenv graph            # 查看本项目的依赖图
pipenv shell
exit                    #退出 pipenv shell
```

更多的功能，尽情地`pipenv -h`。

# pyenv

pyenv的作用跟nvm一样，是一个python版本管理器，可以切换不同的python版本，方便测试代码，支持下载安装PyPy/CPython/Jython/Stackless Python等不同的解释器版本。它是一个shell脚本，因此不支持在windows上运行，不排除将来可以。版本切换级别为全局、本地、本会话。

## 部署

一键安装命令，需要联网，依赖git，实际上就是从github拉取源代码并部署。
```shell
$ curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
正克隆到 '/home/devis/.pyenv'...
正克隆到 '/home/devis/.pyenv/plugins/pyenv-doctor'...
正克隆到 '/home/devis/.pyenv/plugins/pyenv-installer'...
正克隆到 '/home/devis/.pyenv/plugins/pyenv-update'...
正克隆到 '/home/devis/.pyenv/plugins/pyenv-virtualenv'...
正克隆到 '/home/devis/.pyenv/plugins/pyenv-which-ext'...

WARNING: seems you still have not added 'pyenv' to the load path.

# Load pyenv automatically by adding
# the following to ~/.zshrc:

export PATH="/home/devis/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
```

> 此安装方法会自动安装其他几个很有用的插件。

### 更新

```shell
$ pyenv update
```

###  卸载

如果你只是想禁用 pyenv，那么把 `pyenv init` 从 shell 的配置文件中移除，然后重启 shell 就行了（移除后 pyenv 命令仍然能使用，但是版本切换命令不会生效）。

完整卸载 pyenv。然后把 pyenv 的根目录删除即可全部删除 pyenv，通过 pyenv install ... 安装的 python 版本都会删除。

```shell
$  rm -rf $(pyenv root)
并且删除~/.zshrc或者~/.bashrc中如下三行
export PATH="~/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
```

## 操作命令

可以使用`pyenv help [commands]` 输出工具的帮助信息，以及所有支持的命令。

1. 查看可以安装的已支持python版本

```shell
$ pyenv install -l
Available versions:
  2.1.3
  2.2.3
  2.3.7
  2.4
  2.4.1
  ...
  3.6.5
  ...
```

2. 安装指定版本的python，如3.6.5

```shell
$ pyenv install 3.6.5                
Downloading Python-3.6.5.tar.xz...
-> https://www.python.org/ftp/python/3.6.5/Python-3.6.5.tar.xz
Installing Python-3.6.5...
WARNING: The Python bz2 extension was not compiled. Missing the bzip2 lib?
WARNING: The Python readline extension was not compiled. Missing the GNU readline lib?
WARNING: The Python sqlite3 extension was not compiled. Missing the SQLite3 lib?
Installed Python-3.6.5 to /home/devis/.pyenv/versions/3.6.5
```

3. 查看当前安装的python版本

```shell
$ pyenv versions
  system
* 3.6.5 (set by PYENV_VERSION environment variable)
$ pyenv version
3.6.5 (set by PYENV_VERSION environment variable)
```

>  注：在 pyenv 安装之前的所有 python 版本都归为 system 版本，*号表示当前激活的版本。

4. 切换python版本

```shell
$ pyenv global python版本 切换全局 python 版本
$ pyenv local python版本 切换当前文件夹下的 python 版本
$ pyenv shell python版本 切换当前 shell 中的 python 版本
```

5. 删除python版本

- 使用 pyenv uninstall ... 命令。
- 直接删除 versions 文件夹下的对应 python 版本文件夹。

## 自动切换

为目录指定相应的虚拟版本，可以在此目录的根目录上面写一个文件`.python-version` ，把versions命令显示出来的一个环境版本写进去，然后下次cd进去这个目录就会自动激活相应的版本。

```shell
# devis @ kali in ~ [13:09:26] 
$ cd Tensorflow 
(tensorflow2.7) 
# devis @ kali in ~/Tensorflow [14:55:18] 
$ cd ../Tensorflow3 
(tensorflow3.6) 
# devis @ kali in ~/Tensorflow3 [14:57:33] 
$
```

# pyvenv & virtualenv

有时候写项目的时候，会不断地安装各种各样的模块，造成了全局的模块目录会越来越大，而这些模块，并不是每个项目都会使用到。因此有了虚拟环境的概念，环境里面包含着项目所需要的模块依赖，不同的项目不会互相干扰，实现不同项目即使依赖于同一个模块，也可以实现依赖同一个模块的不同版本。

这两个都为python的模块隔离工具，可以生成隔离的包依赖虚拟环境，说白了就是每个项目的包依赖都隔离在一个特定的目录，包含python解释器、模块库、可执行脚本，不会影响全局。实现方法为定义不同的PATH变量，定义不同的模块加载路径。

*virtualenv* 是一个非常流行的虚拟环境创建工具，支持从python 2.6到python3.5，非python官方内置模块。

*pyvenv* 由python3.4的内置模块`venv`带入，这是一个标准官方内置模块，pyvenv实际是执行的就是python3 -m venv

> 上文表述中，可以看出，以后应该更多地使用pyvenv，毕竟官方已经既然不再继续支持python2了。

# pyenv-virtualenv

使用 virtualenv 管理 python 虚拟环境，每次都需要手动激活或退出。对于懒癌晚期患者，pyenv-virtualenv的自动激活和退出虚拟环境功能简直不能再赞。另外搭配 pyenv 食用效果更佳。

## 操作命令

### 创建 pyenv-virtualenv 虚拟环境

- pyenv virtualenv *指定python版本* *虚拟环境名字*

- pyenv virtualenv *虚拟环境名字*

  如果不指定 python 版本，则默认使用当前 pyenv version 的 python 版本。

  创建的虚拟环境位于 $(pyenv root)/versions/ 下的指定 python 版本的文件夹中 envs/ 文件夹下。 

### 激活虚拟环境

- 自动激活/退出
- 手动激活/退出

**自动激活环境**：

- 在 .zshrc 文件的最后添加 `eval  "$(pyenv virtualenv-init -)"`，然后在 shell 中输入 `exec "$SHELL"` 重启 shell，或者手动重启 shell。
- 在想要激活虚拟环境的文件夹中新建 `.python-version`文件，并写入虚拟环境的名字（pyenv local python版本 该命令也是通过创建该文件来达到进入该文件夹后自动使用指定 python 版本的目的）。
- 以后进入该的文件夹就会自动激活虚拟环境，离开该文件夹就会退出虚拟环境。

**手动激活环境**：

- pyenv activate *虚拟环境名字*        激活虚拟环境。
- pyenv deactivate                           退出虚拟环境。

###删除虚拟环境

有 2 种方法：

1. 删除 $(pyenv root)/versions 和$(pyenv root)/versions/{version}/envs 的相关文件夹即可。
2. 命令行运行 pyenv uninstall 虚拟环境的名字