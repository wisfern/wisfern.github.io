---
title: web开发之数据交互
categories:
  - develop
  - web
tags:
  - web
  - interact
abbrlink: efecdc9a
date: 2018-05-08 21:30:33
description:
---

# Ajax

全称为XMLHttpRequest，也可以使用jquery中的$.ajax(methon, url, function)

## ajax 1.0

不能跨域。

## ajax 2.0
可以跨域，再结合origin属性和Access_*可以控制跨域权限。
与ajax1.0相比，多了如下东西

| 模块     |
| -------- |
| FormData |
| upload   |
| Buffer   |
|          |

## CORS跨域

cors本质上是为了防止非法跨域，但假如我们有多个站点，而且有跨域的需求。则可以使用Ajax2中的origin头和Access_Allow_Origin: *来控制。

## 长连接

> 注：废弃，可改用websocket来代替，这是html5新加入的功能。

# jsonp

此方式尽量不要使用，毕竟已经废弃了。
## 原生原理
使用scrpt src读取另外一处站点的js函数，数据以json形式下发到浏览器
## jquery
dataType中有个jsonp类型可以使用，并带有jsonp属性参数定义回调函数的名字。

```js
data: {不写上cb参数}
dataType: 'jsonp',
jsonp: '回调函数的名字，如:cb'
```



# Websocket

可以使用socket.io包来解决websocket，也可以使用html5中原生的websocket来解决。

## socket.io

```js
let io=request('socket.io')
io.connect(xxxx)
io.smit('type', data)
io.on('type', fn(data){})
```

## 原生

```js
let ws = new WebSocket()
let sock = ws.connect('ws://localhost:8080')
sock.on('message', function() {})
```



# Http2

未来，面向流，头压缩，多路复用，在2018这一个时间，还没有几个站点使用http2。



# HTML5新特性

1. geolocation，   定位，实用

2. vedio、audio，视频、音频，配合websocket和canvas，等可以玩直播等，实用

3. . canvas，	绘图，实用

4. WebSocket，实用

5. locatStorage，  本地存储（5M），代替cookie(4K)，实用

   sessionStorage，不实用

6. webSQL，         少，不安全，不实用

7. WebWorker，   线程执行器，可用于执行IO重，执行时间长的逻辑，但一般都放在后端，不实用

8. 文件操作，拖拽，读取，实用

9. manifest，用于离线应用，不实用，被APP代替

