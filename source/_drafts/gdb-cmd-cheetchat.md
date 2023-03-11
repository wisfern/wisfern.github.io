---
abbrlink: '0'
---
# gdbinit

此配置文件可以在运行中通过source <gdb_script>来加载，也可以在当前的目录上改写成.gdbinit以实现gdb自动加载。

## 案例

```shell
#filename: .gdbinit
#gdb will read it when starting
# you can source in gdb 
# cmd: source gdbinit

b efs.cpp:651
c
display dt
display file_count
display g_signal_flag
display dt->d_name
b efs.cpp:648 if dt==0
b efs.cpp:677
info locals
delete 1
c
info locals

# rbreak <rega_function>   # 通过正则表达式批量设置断点。
```

> 上例为了调试一个文件处理循环，先在循环内第一行打断点，然后继续运行，当运行到断点时，给while条件打上退出断点，并跟踪循环内外几个变量，并在循环外的第一行代码打断点，并删除循环内的第一个断点让循环可以继续运行，然后继续，当遇到条件断点满足时打印出所有的本地变量。
>
> 这个跟踪过程主要是为了看为什么目录明明几万个文件，但一个循环才处理十几个文件就跳出继续下一个目录，这个问题导致了程序大部分性能主要花在列目录这个操作上，而导致的性能不行。

# cheetchat表
| Gdb Command        | Description                                                  |
| ------------------ | ------------------------------------------------------------ |
| set listsize *n*   | Set the number of lines listed by the list command to *n* [set listsize] |
| b *function*       | Set a breakpoint at the beginning of *function* [break]      |
| b *line number*    | Set a breakpoint at *line number* of the current file. [break] |
| info b             | 列出所有的断点 [info]                                        |
| delete *n*         | 删除编号为n的断点[delete]                                    |
| r *args*           | Start the program being debugged, possibly with command line arguments *args*. [run] |
| s *count*          | Single step the next *count* statments (default is 1). Step **into** functions. [step] |
| n *count*          | Single step the next *count* statments (default is 1). Step **over** functions. [next] |
| finish             | Execute the rest of the current function. Step **out of** the current function. [finish] |
| c                  | Continue execution up to the next breakpoint or until termination if no breakpoints are encountered. [continue] |
| p *expression*     | print the value of *expression* [print]                      |
| l *optional_line*  | List next *listsize* lines. If *optional_line* is given, list the lines centered around *optional_line*. [list] |
| where              | Display the current line and function and the stack of calls that got you there. [where] |
| h *optional_topic* | help or help on *optional_topic* [help]                      |
| q                  | quit gdb [quit]                                              |
| info locals        | 列出作用域内所有的变量                                       |
| display var        | 跟踪变量var，var必须在作用域内。                             |