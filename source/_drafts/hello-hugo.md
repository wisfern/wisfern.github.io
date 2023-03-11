# 你好，hugo博客

## 案前

好久没编写博文了，最近弄的东西有点儿多，突然很有想写作的欲望，才想起我有一个博客，但已经把hexo相关的知识忘记得七七八八，早在查资料的过程中，发现一位大佬用的是hugo，调研下来，有了迁移的欲望，毕竟优点还是有的，既然hexo也要重新学习，那就学习新的hugo吧，人纳，就喜新厌旧！

## 优缺点对比

使用hugo当网站基础有什么优缺点？

优点：

1. 编译速度快，100篇文章，如果说hexo编译生成静态页需要20秒，那hugo可能需要3秒多完成
2. 同为开源系统，https://github.com/gohugoio/hugo
3. 使用通用markdown开源文章格式

   1. 同步、备份、版本管理方便
   2. 迁移方便
4. 生成的静态文档，随便找个git page或者一台ECS就可以跑起来
5. 有cli工具，那就可以做CI/CD全自动化

缺点：

1. 重新学习，而且不是界面那种点点点就可以发布文章的学习，需要自己做一系列的配置以及作业流程

## 快速开始

> 假设已经准备好了go的运行时环境，如果没有，自行搜索相关的文章，我是从https://dl.google.com/go/go1.17.7.windows-amd64.msi下载window安装包，然后一路next到底。
>
> 执行cmd:go version 显示版本 ：go version go1.17.7 windows/amd64

1. 下载安装hugo

   到 [Hugo Releases](https://github.com/spf13/hugo/releases) 下载对应的操作系统版本的Hugo二进制文件（hugo或者hugo.exe），当前版本`0.92.2`。

   把压缩包里面的`hugo.exe`放到go的bin目录之下(如：C:\Program Files\Go\bin)

   打开一个新的cmd，输入命令，验证是否安装正确

   ```
   > hugo version
   hugo v0.92.2-CDF6A0D6 windows/amd64 BuildDate=2022-02-11T14:17:39Z VendorInfo=gohugoio
   ```

   

   

   

## 参考资料

1. [Hugo零基础建站](https://www.kancloud.cn/yunduanio/gohugo_learning)

   
