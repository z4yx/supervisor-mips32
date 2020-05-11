#include <regdef.h>
#include <mipsregs.h>
#include <unistd.h>
#include <exception.h>

    .set noreorder
    .set noat

    .section .bss
    .p2align 2
    .global TCBT                    // thread control block table
TCBT:
    .long 0
    .long 0
    .global current                 // current thread TCB address
current:
    .long 0

    .text
    .p2align 2
monitor_version:
    .asciz "MONITOR for MIPS32 - initialized."


    /* start address for the .bss section. defined in linker script */
    .word   _sbss
    /* end address for the .bss section. defined in linker script */
    .word   _ebss
    .global START
START:                              // kernel init
    lui k0, %hi(_sbss)
    addiu k0, %lo(_sbss)
    lui k1, %hi(_ebss)
    addiu k1, %lo(_ebss)
bss_init:
    beq k0, k1, bss_init_done
    nop
    sw  zero, 0(k0)
    addiu k0, k0, 4
    b   bss_init
    nop

bss_init_done:

    lui sp, %hi(KERNEL_STACK_INIT)  // 设置内核栈
    addiu sp, %lo(KERNEL_STACK_INIT)
    or fp, sp, zero
    lui t0, %hi(USER_STACK_INIT)    // 设置用户栈
    addiu t0, %lo(USER_STACK_INIT)
    lui t1, %hi(uregs_sp)           // 写入用户空间备份
    sw t0, %lo(uregs_sp)(t1)
    lui t1, %hi(uregs_fp)
    sw t0, %lo(uregs_fp)(t1)

    /* init serial */
#ifdef MACH_QEMU                    // QEMU模拟器特有的串口初始化过程
    /* see ucore/kern/driver/console.c */
    lui t0, 0xBFD0                  // NOTE: all COM_* share high 16 bits
                                    // 0xBFD0 should be %hi(COM1) but can not be used
                                    // due to a compiler bug (bugzilla/20649)
    sb zero, %lo(COM_FCR)(t0)       // console.c:54
    ori t1, zero, %lo(COM_LCR_DLAB)
    sb t1, %lo(COM_LCR)(t0)         // :57
    ori t1, zero, %lo(COM_DLL_VAL)
    sb t1, %lo(COM_DLL)(t0)         // :58
    sb zero, %lo(COM_DLM)(t0)       // :59
    ori t1, zero, %lo(COM_LCR_CONFIG)
    sb t1, %lo(COM_LCR)(t0)         // :62
    sb zero, %lo(COM_MCR)(t0)       // :65
    ori t1, zero, %lo(COM_IER_RDI)
    sb t1, %lo(COM_IER)(t0)         // :67
#endif

    ori t0, zero, TF_SIZE / 4       // 计数器
.LC0:
    addiu t0, t0, -1                // 滚动计数器
    addiu sp, sp, -4                // 移动栈指针
    sw zero, 0(sp)                  // 初始化栈空间
    bne t0, zero, .LC0              // 初始化循环
    nop
    lui t0, %hi(TCBT)
    addiu t0, %lo(TCBT)           // 载入TCBT地址
    sw sp, 0(t0)                    // thread0(idle)的中断帧地址设置
    or t6, sp, zero                 // t6保存idle中断帧位置

    ori t0, zero, TF_SIZE / 4       // 计数器
.LC1:
    addiu t0, t0, -1                // 滚动计数器
    addiu sp, sp, -4                // 移动栈指针
    sw zero, 0(sp)                  // 初始化栈空间
    bne t0, zero, .LC1              // 初始化循环
    nop
    lui t0, %hi(TCBT)
    addiu t0, %lo(TCBT)           // 载入TCBT地址
    sw sp, 4(t0)                    // thread1(shell/user)的中断帧地址设置
    sw sp, TF_sp(t6)                // 设置idle线程栈指针(调试用?)

    lui t2, %hi(TCBT + 4)
    addiu t2, %lo(TCBT + 4)
    lw t2, 0(t2)                    // 取得thread1的TCB地址
    lui t1, %hi(current)
    sw t2, %lo(current)(t1)         // 设置当前线程为thread1

    j WELCOME                       // 进入主线程
    nop



WELCOME:
    lui s0, %hi(monitor_version)    // 装入启动信息
    addiu s0, %lo(monitor_version)
    lb a0, 0(s0)
.Loop0:
    addiu s0, s0, 0x1
    jal WRITESERIAL                 // 调用串口写函数
    nop
    lb a0, 0(s0)
    bne a0, zero, .Loop0            // 打印循环至0结束符
    nop
    j SHELL                         // 开始交互
    nop



IDLELOOP:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j IDLELOOP
    nop


    .set at
    .set reorder







// vim: syntax=asm
