#!/bin/bash

filepath=$(cd "$(dirname "$0")"; pwd)  
#echo "$(basename $0) $(dirname $0) -- $filepath " 

work=${1:-deploy}
case $work in
    deploy)
        cd $filepath
        hexo clean
        hexo g
        hexo d
        ;;
    push)
        cd $filepath
        git push origin hexo
        ;;
    *)
        echo "error options\n"
        echo "Usage: $0 [deploy|push]"
        echo "options: "
        echo "  deploy => 运行 hexo d 执行博客部署"
        echo "  push  => 运行 git push 执行博客源数据备份"
        ;;
esac
