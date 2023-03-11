---
title: markdown搭配pandoc写论文
author:
  - name: wisfern
    email: wisfern@gmail.com
categories: paper
tags:
  - paper
  - markdown
abstract: '写论文工具'
fignos-cleveref: true
fignos-plus-name: 图
bibliography: 'write_paper_with_markdown\myref.bib'
abbrlink: 355d2869
date: '2019-08-01 00:00:00'
---

*[markdown]: 测试注释

# 目录
[TOC]

# 简介

写文章，以前有两个主要的工具：***MicroSoft Word***和***LaTeX***。

* Word无法分离内容与格式，无法跨平台以及所见所得写出来的格式有很多不规范的地方。
* LaTeX对我来说，学习成本蛮大的，需要记忆新的语法，而且这些东西并不常用。

经过谷歌和百度的搜索学习，接下来尝试用***Markdown***来写专业文章，用***pandoc***转换输出最终的成果。

pandoc支持21种输入格式，输出37种格式，如pdf、word、html等几乎所有的文档格式，文档转换界的瑞士军刀。

本文章用markdown编写，并用pandoc转换为html.

# 工作流

参考如下 [@fig:workflow]：

![工作流](write_paper_with_markdown/workflow-wide-tx.png)[#fig:workflow]


# 脚注

这是脚注测试 [^1]  

[^1]: 测试脚注 www.baidu.com

# 图、表和方程编号

参考如下 [@fig:workflow]：

![工作流](write_paper_with_markdown/workflow-wide-tx.png)[#fig:workflow]

|标题1|标题2|
|---|---|
| 1  |  2 |

# 数学公式

$\frac{a}{b}$

# 引用

内部引用

文献引用

#### **Citations**

```
This is a very important fact [@krishnamurthy_writing_nodate]
```

示例

This is a very important fact [@krishnamurthy_writing_nodate]

# pandoc转换

键入所有内容后，可以使用该`pandoc`命令将文档转换为所需的格式。Pandoc使用输出文件扩展名来确定输出文件格式应该是什么。顺便说一下，Pandoc只是一个命令行工具。您必须使用命令行进行任何转换。

生成PDF文件：

```
pandoc document.md -o document.pdf
```

生成HTML文件：

```
pandoc document.md -o document.html
```

pandoc的说明文档[^11]

[^11]: “Pandoc Cross References Github Issue Tracker，”nd，[https：//github.com/jgm/pandoc/issues/813](https://github.com/jgm/pandoc/issues/813)。

# 参考资料

1. [Writing Technical Papers with Markdown](https://blog.kdheepak.com/writing-papers-with-markdown.html)
2. [Academic Markdown and Citations](https://v4.chriskrycho.com/2015/academic-markdown-and-citations.html)
3. [纯文本，论文，pandoc](https://kieranhealy.org/blog/archives/2014/01/23/plain-text/)
4. [微软写的在线markdown科学写文章](https://www.madoko.net/)
