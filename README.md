## 运用说明

运行机器需要安装好node.js以及hexo。
在代码clone下来之后，运行`npm install`安装好node.js的模块
然后运行如下命令，生成静态资源

'''shell
hexo clean
hexo g
hexo s
'''

最后的hexo s会启动一条服务进程，监听在localhost:4000，可以打开浏览器查看一下，如没有问题，则可以运行如下命令发布博客。
在这里，我只发布到github page

‘’‘shell
hexo d
'''
