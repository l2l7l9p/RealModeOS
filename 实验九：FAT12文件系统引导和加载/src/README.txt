os 目录下为最终的结果，包括内核源代码、mbr、最终的软盘、虚拟机。

lib 为用户库（实验五实现），users 为用户程序（4个射字母、1个系统调用测试），tools 为工具集（链接器、链接脚本、一些方便操作的脚本、映像管理程序）

命令集为：
dir：显示当前目录
用户程序名：shoot1.com、shoot2.com、shoot3.com、shoot4.com、test.com
多进程：不同的命令用“|”隔开，例如“dir|shoot1.com|shoot2.com”
命令输入支持退格，不支持方向键，不能用小键盘