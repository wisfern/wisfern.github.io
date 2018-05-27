---
title: git的submodule
categories:
  - tools
  - git
tags:
  - git
  - submodule
abbrlink: 32207f0a
date: 2018-05-24 22:32:25
description:
---

##序言

老高最近的项目用到了git的submodule，期间遇到了很多坑，比如：

> 如何增删更新submodule
> 如何修改并提交submodule
> 如何将submodule的变更在父项目中提交

在弄明白这些问题之前，首先我们需要理解git的submodule到底是个啥。

其实父项目与子模块(submodule)之间的关系很松散，父项目基本只关心子模块的地址以及版本(commit id)。

我们在子模块如何改动父项目是不需要关心的，只需要把改动的版本号告诉给父项目就行。

<!-- more -->

下面我们试着解决几个问题：

## 添加submodule

```
git submodule add https://github.com/phpgao/BaiduSubmit.git usr/plugins/BaiduSubmit
git submodule add https://github.com/phpgao/TableOfContents.git usr/plugins/TableOfContents
git submodule add https://github.com/phpgao/ExternalTool.git usr/plugins/ExternalTool
git submodule add https://github.com/phpgao/CdnHelper usr/plugins/CdnHelper
```

这个时候如果你留意一下`.gitmodules`和`.git/config`这两个文件，应该会发现相关信息已被记录下来！

## 如何更新submodule

当clone项目时有子模块存在时，第一次是不会顺便clone出子模块的，需要执行一些命令：

```
git clone xxx.git

# 初始化子模块
git submodule init

# 将子模块的文件check出来
git submodule update

# 现在所有子模块已经把被checkout到本地，是不是很棒！
```

## 如何删除submodule

但是，如何删除submodule呢？大家第一时间一定想到的是remove，但是git貌似没有提供类似`git submodule remove` 那么easy的方法，所以我们要借助[deinit](https://git-scm.com/docs/git-submodule#git-submodule-deinit)。所以如果之前你是直接编辑.gitmodules文件就以为删除了那你就错了！

```
# 我们以BaiduSubmit为例，之前我们添加在了 usr/plugins/BaiduSubmit
# 首先我们反初始化
git submodule deinit usr/plugins/BaiduSubmit

# 此时 .git/config 已被重写，BaiduSubmit的相关信息已经不存在了
git rm usr/plugins/BaiduSubmit
# 这时，子模块文件被删除，同时 .gitmodules 文件中的相关信息被删除

# 还有一种情况，就是子模块刚被add，但是还没有commit的时候，这时如果反悔了，但是还想保留工作现场，可以这样。
# 如果不想保留，看下一条
git rm --cached usr/plugins/BaiduSubmit
rm -rf .git/modules/usr/plugins/BaiduSubmit

# 或者直接全部删除
git submodule deinit --force usr/plugins/BaiduSubmit
```

## 如何修改并提交submodule

这里分两种情况，一个是本人直接在子项目修改并提交，另一种是别人的git仓库被修改。

这两种情况对于有submodule的父项目git来说，提交的只是submodule的提交版本号，并不会提交文件修改。

### 第一种情况

其实我们只需要注意一点，就是子模块的分支出于游离状态，我们在修改他的时候第一步需要执行检出对应的分支即可！

```
# 首先，我们进入子模块
cd xx/xx/sub

# 检出master分支
git checkout master

# 然后做修改
vim some-file.py

# 最后做提交
git add .
git commit -m "Get something done"
git push origin master
```

### 第二种情况

当子模块是别人维护的时候，当他更新的时候，我们需要怎么做？

```
# 首先检出master分支
git checkout master

# 然后拉取更新
git pull

# 回到父项目中更新

cd ../../

git add xx/xx/xx
git commit -m "update submodule"
```

## 如何将submodule的变更在父项目中提交

子模块被提交后父项目会检测到，正常提交即可！

```
git status

# modified:   xx/xxxx/xxxx (new commits)

# add的时候注意再最后不要加 / 斜杠，否则会出现很棘手问题

git add xx/xxxx/xxxx
git commit -m "update submodule"
git push
```

## submodule提交异常

在使用submodule的过程中，最多的是引用了一个别人维护的第三方，而刚好自己又是有修改这个第三方的需要。在这里我找来找去只找到一种方法，那就是完全fork那个第三方，然后父项目的submodule加上自己fork出来的第三方，并在这个自己fork出来的第三方中修改文件，最后提交到自己fork的仓库，以此来保存自己的修改。

- 一个常见问题是当开发者对子模块做了一个本地的变更但是并没有推送到公共服务器（比如像我，没有权限推到第三方仓库或者第三方不合并）。然后他们提交了一个指向那个非公开状态的指针然后推送上层项目。当上层项目的其他开发者试图运行`git submodule update`，那个子模块系统会找不到所引用的提交，因为它只存在于第一个开发者的系统中。如果发生那种情况，你会看到类似这样的错误：

```
$ git submodule update
fatal: reference isn’t a tree: 6c5e70b984a60b3cecd395edd5b48a7575bf58e0
Unable to checkout '6c5e70b984a60b3cecd395edd5ba7575bf58e0' in submodule path 'rack'
```

- 另一个问题是如果子模块的状态没有合并，而父项目这个时候运行了`git submodule update`，很可能这个时候子模块的未合并修改会丢失，所以使用子模块一定要非常非常地小心。

## 参考资料

1. [git-scm-submodule说明](https://git-scm.com/book/zh/v1/Git-%E5%B7%A5%E5%85%B7-%E5%AD%90%E6%A8%A1%E5%9D%97)
2. [老高的git submodule使用总结](https://blog.phpgao.com/git_submodule.html)