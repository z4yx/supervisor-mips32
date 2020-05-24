# supervisor-32： 32位监控程序（“龙芯杯”个人赛）

[查看最新版本](https://github.com/z4yx/supervisor-mips32/tree/simplified)

## 介绍

本监控程序能够接受用户命令，支持输入汇编指令并运行，查看寄存器及内存状态等功能。监控程序可在学生实现的 32 位 MIPS CPU 上运行，一方面可以帮助学生理解、掌握 MIPS 指令系统及其软件开发，另一方面可以作为验证学生 CPU 功能正确性的标准。

监控程序分为两个部分，Kernel 和 Term。其中 Kernel 使用 MIPS32 汇编语言编写，运行在 FPGA 上学生实现的 CPU 中，用于管理硬件资源；Term 是上位机程序，使用 Python 语言编写，有基于命令行的用户界面，达到与用户交互的目的。Kernel 和 Term 直接通过串口通信，即用户在 Term 界面中输入的命令、代码经过 Term 处理后，通过串口传输给 Kernel 程序；反过来，Kernel 输出的信息也会通过串口传输到 Term，并展示给用户。

## Kernel 使用说明

Kernel 使用汇编语言编写，使用到的指令有20余条，均符合 MIPS32 Release2 规范。为了在硬件上运行 Kernel 程序，我们首先要对 Kernel 的汇编代码进行编译。

Linux环境在编译时须使用MTI Bare Metal工具链：[Linux版下载](https://cloud.tsinghua.edu.cn/f/16dde018b00749a4a4de/) 。将下载的压缩包解压到任意目录后，设置环境变量 `GCCPREFIX` 以便 make 工具找到编译器，例如压缩包解压到`/opt`：

`export GCCPREFIX=/opt/mips-mti-elf/2016.05-06/bin/mips-mti-elf-`

下面是编译监控程序的过程。在`kernel`文件夹下面，有汇编代码和 Makefile 文件，我们可以使用 make 工具编译 Kernel 程序。假设当前目录为 `kernel` ，目标版本为基础版本，我们在终端中运行命令

`make ON_FPGA=n`

即可开始编译流程。如果顺利结束，将生成 `kernel.elf` 和 `kernel.bin` 文件，即可执行文件。要在模拟器中运行它，可以使用命令

`make sim`

它会在 QEMU 中启动监控程序，并等待 Term 程序连接。本文后续章节介绍了如何使用 Term 连接模拟器。

若要在编译硬件上运行的 kernel（与 QEMU 版本的区别是串口外设不同），首先用 `make clean` 清除之前编译的结果，最后用命令

`make ON_FPGA=y`

编译用于硬件的 `kernel.bin`。使用开发板提供的工具，将 `kernel.bin` 写入内存 0 地址（物理地址）位置，并让处理器复位从 0x8000000 地址（MIPS32中对应物理地址为0的虚地址）处开始执行，Kernel 就运行起来了。

Kernel 运行后会先通过串口输出版本号，该功能可作为检验其正常运行的标志。之后 Kernel 将等待 Term 从串口发来的命令，关于 Term 的使用将在后续章节描述。

接下来我们分别说明三个档次的监控程序对于硬件的要求，及简要的设计思想。

### 指令集

基础版本的 Kernel 共使用了22条不同的指令，它们是：

1. `ADDIU` 001001ssssstttttiiiiiiiiiiiiiiii
1. `ADDU` 000000ssssstttttddddd00000100001
1. `AND` 000000ssssstttttddddd00000100100
1. `ANDI` 001100ssssstttttiiiiiiiiiiiiiiii
1. `BEQ` 000100ssssstttttoooooooooooooooo
1. `BGTZ` 000111sssss00000oooooooooooooooo
1. `BNE` 000101ssssstttttoooooooooooooooo
1. `J` 000010iiiiiiiiiiiiiiiiiiiiiiiiii
1. `JAL` 000011iiiiiiiiiiiiiiiiiiiiiiiiii
1. `JR` 000000sssss0000000000hhhhh001000
1. `LB` 100000bbbbbtttttoooooooooooooooo
1. `LUI` 00111100000tttttiiiiiiiiiiiiiiii
1. `LW` 100011bbbbbtttttoooooooooooooooo
1. `MUL` 011100ssssstttttddddd00000000010
1. `OR` 000000ssssstttttddddd00000100101
1. `ORI` 001101ssssstttttiiiiiiiiiiiiiiii
1. `SB` 101000bbbbbtttttoooooooooooooooo
1. `SLL` 00000000000tttttdddddaaaaa000000
1. `SRL` 00000000000tttttdddddaaaaa000010
1. `SW` 101011bbbbbtttttoooooooooooooooo
1. `XOR` 000000ssssstttttddddd00000100110
1. `XORI` 001110ssssstttttiiiiiiiiiiiiiiii

根据 MIPS32 规范（在参考文献中）正确实现这些指令后，程序才能正常工作。

CPU 须支持延迟槽，不需要实现CP0、HI、LO寄存器，不需要实现异常、中断，不需要实现TLB。

### 内存映射

监控程序使用了 8 MB 的内存空间，其中约 1 MB 由 Kernel 使用，剩下的空间留给用户程序。此外，为了支持串口通信，还设置了一个内存以外的地址区域，用于串口收发。具体内存地址的分配方法如下表所示：


| 虚地址区间 | 说明 |
| --- | --- |
| 0x80000000-0x800FFFFF | 监控程序代码 |
| 0x80100000-0x803FFFFF | 用户代码空间 |
| 0x80400000-0x807EFFFF | 用户数据空间 |
| 0x807F0000-0x807FFFFF | 监控程序数据 |
| 0xBFD003F8-0xBFD003FD | 串口数据及状态|

串口控制器访问的代码位于`kern/utils.S`，其数据格式为：

| 地址 | 位 | 说明 |
| --- | --- |--- |
| 0xBFD003F8| [7:0] | 串口数据，读、写地址分别表示串口接收、发送一个字节|
| 0xBFD003FC| [0] | 只读，为1时表示串口空闲，可发送数据|
| 0xBFD003FC| [1] | 只读，为1时表示串口收到数据|

Kernel 的入口地址为 0x80000000，对应汇编代码`kern/evec.S`中的 `INITLOCATE:`标签。在完成必要的初始化流程后，Kernel 输出版本信息，随后进入 shell 线程，与用户交互。shell 线程会等待串口输入，执行输入的命令，并通过串口返回结果，如此往复运行。

当收到启动用户程序的命令后，用户线程代替 shell 线程的活动。用户程序的寄存器，保存在从 0x807F0000 到 0x807F0077 的连续120字节中，依次对应 \$1 到 \$30 用户寄存器，每次启动用户程序时从上述地址装载寄存器值，用户程序运行结束后保存到上述地址。


## Term 使用说明

Term 程序运行在实验者的电脑上，提供监控程序和人交互的界面。Term 支持7种命令，它们分别是

- R：按照\$1至\$30的顺序返回用户程序寄存器值。
- D：显示从指定地址开始的一段内存区域中的数据。
- A：用户输入汇编指令或者数据，并放置到指定地址上。输入行只有数值时视为数据，否则为指令。
- F：从文件读入汇编指令或者数据，并放置到指定地址上，格式与 A 命令相同。
- U：从指定地址读取一定长度的数据，并显示反汇编结果。
- G：执行指定地址的用户程序。
- Q：退出 Term

利用这些命令，实验者可以输入一段汇编程序，检查数据是否正确写入，并让程序在处理器上运行验证。

Term 程序位于`term`文件夹中，可执行文件为`term.py`，运行前需要安装Python程序。

由于Term程序会调用汇编器，如果是Linux环境，在使用时须设置环境变量 `GCCPREFIX`，设置方法与编译 Kernel 时的配置相同，例如：

`export GCCPREFIX=/opt/mips-mti-elf/2016.05-06/bin/mips-mti-elf-`

设置好环境后，即可连接远程实验平台串口或者 QEMU 模拟器。启动时使用 `-t` 选项指定 IP 和端口。例如连接模拟器时：

`python term.py -t 127.0.0.1:6666`

### 测试程序

监控程序附带了几个测试程序，代码见`kern/test.S`。Kernel在编译时会显示测试程序入口地址。

记下这些地址，并在 Term 中使用G命令运行它们。

### 用户程序编写

根据监控程序设计，用户程序的代码区为0x80100000-0x803FFFFF，实验时需要把用户程序写入这一区域。用户程序的最后需要以`jr $31`结束，从而保证正确返回监控程序。

在输入用户程序的过程中，既可以用汇编指令，也可以直接写16进制的数据（机器码）。空行表示输入结束。

以下是一次输入用户程序并运行的过程演示：

	MONITOR for MIPS32 - initialized.
	>> a
	>>addr: 0x80100000
	one instruction per line, empty line to end.
	[0x80100000] ori $v0,$0,5
	[0x80100004] xor $t0,$t0,$t0
	[0x80100008] xor $t1,$t1,$t1
	[0x8010000c] loop:
	[0x8010000c] addu $t1,$t1,$t0
	[0x80100010] addiu $t0,$t0,1
	[0x80100014] bne $v0,$t0,loop
	[0x80100018] nop
	[0x8010001c] jr $ra
	[0x80100020] nop
	[0x80100024] 
	>> u
	>>addr: 0x80100000
	>>num: 64
	0x80100000: li	v0,0x5
	0x80100004: xor	t0,t0,t0
	0x80100008: xor	t1,t1,t1
	0x8010000c: addu	t1,t1,t0
	0x80100010: addiu	t0,t0,1
	0x80100014: bne	v0,t0,0x8010000c
	0x80100018: nop
	0x8010001c: jr	ra
	0x80100020: nop
	0x80100024: nop
	0x80100028: nop
	0x8010002c: nop
	0x80100030: nop
	0x80100034: nop
	0x80100038: nop
	0x8010003c: nop
	>> g
	>>addr: 0x80100000

	elapsed time: 0.000s
	>> r
	R1 (AT)    = 0x00000000
	R2 (v0)    = 0x00000005
	R3 (v1)    = 0x00000000
	R4 (a0)    = 0x00000000
	R5 (a1)    = 0x00000000
	R6 (a2)    = 0x00000000
	R7 (a3)    = 0x00000000
	R8 (t0)    = 0x00000005
	R9 (t1)    = 0x0000000a
	R10(t2)    = 0x00000000
	R11(t3)    = 0x00000000
	R12(t4)    = 0x00000000
	R13(t5)    = 0x00000000
	R14(t6)    = 0x00000000
	R15(t7)    = 0x00000000
	R16(s0)    = 0x00000000
	R17(s1)    = 0x00000000
	R18(s2)    = 0x00000000
	R19(s3)    = 0x00000000
	R20(s4)    = 0x00000000
	R21(s5)    = 0x00000000
	R22(s6)    = 0x00000000
	R23(s7)    = 0x00000000
	R24(t8)    = 0x00000000
	R25(t9/jp) = 0x00000000
	R26(k0)    = 0x00000000
	R27(k1)    = 0x00000000
	R28(gp)    = 0x00000000
	R29(sp)    = 0x807f0000
	R30(fp/s8) = 0x807f0000
	>> q

## 参考文献

- CPU采用的MIPS32指令集标准：MIPS32® Architecture For Programmers Volume II: The MIPS32® Instruction Set
- MIPS32中断及TLB等特权态资源：MIPS32® Architecture For Programmers Volume III: The MIPS32® Privileged Resource Architecture

## 项目作者

- 初始版本：韦毅龙，李成杰，孟子焯
- 后续维护：张宇翔，董豪宇
