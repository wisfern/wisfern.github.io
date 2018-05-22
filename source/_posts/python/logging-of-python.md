---
title: python之logging
categories: [develop, python]
tags: 
  - python
  - logging
  - develop
description: 
abbrlink: 3fc2b160
date: 2018-04-10 17:36:08
---

最近开发一个python程序，使用到dict初始化loggin，也好，写遍博文记录一下。

为了了解程序运行的情况，诞生了日志，在python下做开发以来写过用过多多少少的日志模块。用来用去还是内置的logging模块用得比较爽，使用的话也比较简单。

```python
import logging
logging.basicConfig(level=logging.INFO)
# 这样就可以实现最基本的终端日志输出
```

<!-- more -->

# 机制概念

logging与log4j机制是一样的，而实现起来有一些不同，都有以下的概念

- loggers，定义日志对象，对应于代码中的logging.getLogger(name)以获取日志对象，单例模式。这里存在一个名为'root'的默认日志对象，所有不指定名字的输出都归为root日志对象处理。
- handlers，日志处理者，我们在这里定义了输出文件、输出终端、输出网络、输出syslog、输出邮件等，每个handler可以定义不同的日志级别，得以实现日志分级输出。
- fotmater，定义日志行格式，只需要两个参数：消息的格式字符串和日期字符串，这两个参数都是可选的。
- filters，为确定哪些日志记录提供更细粒度的功能输出。




# logging内部流程

![logging流程图](https://docs.python.org/2/_images/logging_flow.png)



# handler说明

handler在logging中的作用是处理日志，可以有如下几类日志处理类

```python
>>> import logging.handlers
>>> [handler for handler in dir(logging.handlers) if handler.endswith('Handler')]
['BaseRotatingHandler', 'BufferingHandler', 'DatagramHandler', 'HTTPHandler', 'MemoryHandler', 'NTEventLogHandler', 'RotatingFileHandler', 'SMTPHandler', 'SocketHandler', 'SysLogHandler', 'TimedRotatingFileHandler', 'WatchedFileHandler']
```

在代码中可以自定义添加handler

```python
logging.addHandler(handlerObject)
```
[官网支持的所有Handler](https://docs.python.org/2/howto/logging.html#useful-handlers)

| Handler                                                      | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| * [`StreamHandler`](https://docs.python.org/2/library/logging.handlers.html#logging.StreamHandler) | instances send messages to streams (file-like objects).      |
| [`FileHandler`](https://docs.python.org/2/library/logging.handlers.html#logging.FileHandler) | instances send messages to disk files.                       |
| BaseRotatingHandler                                          | is the base class for handlers that rotate log files at a certain point. It is not meant to be instantiated directly. Instead, use [`RotatingFileHandler`](https://docs.python.org/2/library/logging.handlers.html#logging.handlers.RotatingFileHandler) or [`TimedRotatingFileHandler`](https://docs.python.org/2/library/logging.handlers.html#logging.handlers.TimedRotatingFileHandler). |
| * [`RotatingFileHandler`](https://docs.python.org/2/library/logging.handlers.html#logging.handlers.RotatingFileHandler) | instances send messages to disk files, with support for maximum log file sizes and log file rotation. |
| [`TimedRotatingFileHandler`](https://docs.python.org/2/library/logging.handlers.html#logging.handlers.TimedRotatingFileHandler) | instances send messages to disk files, rotating the log file at certain timed intervals. |
| [`SocketHandler`](https://docs.python.org/2/library/logging.handlers.html#logging.handlers.SocketHandler) | instances send messages to TCP/IP sockets.                   |
| [`DatagramHandler`](https://docs.python.org/2/library/logging.handlers.html#logging.handlers.DatagramHandler) | instances send messages to UDP sockets.                      |
| [`SMTPHandler`](https://docs.python.org/2/library/logging.handlers.html#logging.handlers.SMTPHandler) | instances send messages to a designated email address.       |
| [`SysLogHandler`](https://docs.python.org/2/library/logging.handlers.html#logging.handlers.SysLogHandler) | instances send messages to a Unix syslog daemon, possibly on a remote machine. |
| [`NTEventLogHandler`](https://docs.python.org/2/library/logging.handlers.html#logging.handlers.NTEventLogHandler) | instances send messages to a Windows NT/2000/XP event log.   |
| [`MemoryHandler`](https://docs.python.org/2/library/logging.handlers.html#logging.handlers.MemoryHandler) | instances send messages to a buffer in memory, which is flushed whenever specific criteria are met. |
| [`HTTPHandler`](https://docs.python.org/2/library/logging.handlers.html#logging.handlers.HTTPHandler) | instances send messages to an HTTP server using either `GET` or `POST` semantics. |
| [`WatchedFileHandler`](https://docs.python.org/2/library/logging.handlers.html#logging.handlers.WatchedFileHandler) | instances watch the file they are logging to. If the file changes, it is closed and reopened using the file name. This handler is only useful on Unix-like systems; Windows does not support the underlying mechanism used. |
| [`NullHandler`](https://docs.python.org/2/library/logging.handlers.html#logging.NullHandler) | instances do nothing with error messages. They are used by library developers who want to use logging, but want to avoid the ‘No handlers could be found for logger XXX’ message which can be displayed if the library user has not configured logging. See [Configuring Logging for a Library](https://docs.python.org/2/howto/logging.html#library-config) for more information. |

其中NullHandler，StreamHandler和FileHandler定义在logger中，而其他handler则定义在子模块*logging.handlers*.

如果上面的Handler还不能满足需求，可以自行编写Handler。

`注：上表中行头带*号为我们开发过程中最常用的Handler`



# formater说明

格式表

| Format              | Description                                                  |
| :------------------ | :----------------------------------------------------------- |
| %(name)s            | Name of the logger (logging channel).                        |
| %(levelno)s         | Numeric logging level for the message (DEBUG, INFO, WARNING, ERROR, CRITICAL). |
| %(levelname)s       | Text logging level for the message ('DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'). |
| %(pathname)s        | Full pathname of the source file where the logging call was  issued (if available). |
| %(filename)s        | Filename portion of pathname.                                |
| %(module)s          | Module (name portion of filename).                           |
| %(funcName)s        | Name of function containing the logging call.                |
| %(lineno)d          | Source line number where the logging call was issued (if  available). |
| %(created)f         | Time when the [LogRecord](http://www.python.org/doc/current/library/logging.html#logging.LogRecord) was created (as returned by [time.time()](http://www.python.org/doc/current/library/time.html#time.time)). |
| %(relativeCreated)d | Time in milliseconds when the LogRecord was created, relative  to the time the logging module was loaded. |
| %(asctime)s         | Human-readable time when the [LogRecord](http://www.python.org/doc/current/library/logging.html#logging.LogRecord) was created. By default this is of the form “2003-07-08  16:49:45,896” (the numbers after the comma are millisecond portion of the  time). |
| %(msecs)d           | Millisecond portion of the time when  the [LogRecord](http://www.python.org/doc/current/library/logging.html#logging.LogRecord) was created. |
| %(thread)d          | Thread ID (if available).                                    |
| %(threadName)s      | Thread name (if available).                                  |
| %(process)d         | Process ID (if available).                                   |
| %(message)s         | The logged message, computed as msg % args.                  |



# 配置

python的logging可以有以如下几种方式实现初始化

## 代码

```python
import logging

# create logger
logger = logging.getLogger('simple_example')
logger.setLevel(logging.DEBUG)

# create console handler and set level to debug
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)

# create formatter
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

# add formatter to ch
ch.setFormatter(formatter)

# add ch to logger
logger.addHandler(ch)

# 'application' code
logger.debug('debug message')
logger.info('info message')
logger.warn('warn message')
logger.error('error message')
logger.critical('critical message')
```
运行后结果

```python
$ python simple_logging_module.py
2018-04-10 15:10:26,618 - simple_example - DEBUG - debug message
2018-04-10 15:10:26,620 - simple_example - INFO - info message
2018-04-10 15:10:26,695 - simple_example - WARNING - warn message
2018-04-10 15:10:26,697 - simple_example - ERROR - error message
2018-04-10 15:10:26,773 - simple_example - CRITICAL - critical message
```



## dict对象

`logging.config`模块提供着[dictConfig](https://docs.python.org/2/library/logging.config.html#logging.config.dictConfig)，可以从python字典对象中加载自定义的配置。

正好，我在自行编写的程序中用到了，不过我是从json中初始化dict对象，然后再把dict对象传递给logging.config.dictConfig(dictObject)，借此函数完成logging的配置。

当然，也可以从yml中初始化这个dict对象，不过这个没有涉及，文档官网则有[例子](https://docs.python.org/2/library/logging.config.html#dictionary-schema-details)。

我的json文件：

```json
{ "logger_conf": {
    "version": 1,
    "disable_existing_loggers": false,
    "formatters": {
      "standard": {
        "format": "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
      }
    },
    "handlers": {
      "console": {
        "class": "logging.StreamHandler",
        "level": "WARN",
        "formatter": "standard",
        "stream": "ext://sys.stdout"
      },
      "RotatingFileHandler": {
        "level": "INFO",
        "class": "logging.handlers.RotatingFileHandler",
        "formatter": "standard",
        "filename": "logs/test.log",
        "maxBytes": 10485760,
        "backupCount": 5,
        "encoding": "utf8"
      },
      "ErrorFileHandler": {
        "level": "ERROR",
        "class": "logging.handlers.RotatingFileHandler",
        "formatter": "standard",
        "filename": "logs/error.log",
        "maxBytes": 10485760,
        "backupCount": 5,
        "encoding": "utf8"
      }
    },
    "loggers": {
      "": {
        "handlers": [ "console",  "RotatingFileHandler", "ErrorFileHandler" ],
        "level": "INFO",
        "propagate": "yes"
      },
      "apscheduler": {
            "handlers": ["console",  "RotatingFileHandler", "ErrorFileHandler"],
            "level": "WARN",
            "propagate": "no"
        }
    }
  }
}
```

初始化代码

```python
import logging
import logging.config
with open(filename) as json_file:
	obj = json.loads(self._strip_comment(json_file.read()))
    logging.config.dictConfig(obj)
```

使用dictConfig()函数初始化logging，可以把logging配置写进程序的json配置中而不用再单独一个日志配置json文件，洁癖比较浓，捂脸~



## ini配置文件

```python
import logging.config 
logging.config.fileConfig("logging.conf")    # 采用配置文件，此函数还有第二个参数，disable_existing_loggers，这个参数默认为True，会让这一行之前初始化的logger失效（没有在配置中明确定义的logger），如果想要让这一行代码之前的logger对象还有效，则把这个参数设置为False
```
logging.conf配置文件案例
```ini
[loggers]  
keys=root,simpleExample  
  
[handlers]  
keys=consoleHandler  
  
[formatters]  
keys=simpleFormatter  
  
[logger_root]  
level=DEBUG  
handlers=consoleHandler  
  
[logger_simpleExample]  
level=DEBUG
handlers=consoleHandler
qualname=simpleExample
propagate=0
  
[handler_consoleHandler]  
class=StreamHandler  
level=DEBUG  
formatter=simpleFormatter  
args=(sys.stdout,)  
  
[formatter_simpleFormatter]  
format=%(asctime)s - %(name)s - %(levelname)s - %(message)s  
datefmt=  
```


# 参考资料

[^1 ]: [logging食谱](https://docs.python.org/2/howto/logging-cookbook.html#logging-cookbook)
[^2]: [python-logging](https://docs.python.org/2/library/logging.html#)