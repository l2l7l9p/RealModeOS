hotwheel 是简单的风火轮，直接运行虚拟机可查看右下角风火轮。

FinalOS 是最终实现的系统，命令集为：
table：输出储存的程序表格
1：shoot1
2：shoot2
3：shoot3
4：shoot4
命令输入支持退格，不支持方向键

基于int09h的设计（键盘的按下和弹起均会触发中断），可能会使用户程序开始时就ouch。