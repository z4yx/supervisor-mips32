#include <regdef.h>
#include <mipsregs.h> 


    .set noreorder
    .set noat
    .p2align 2
    .section .text.init
    .global INITLOCATE
INITLOCATE:                         // 定位启动程序
    lui k0, %hi(START)
    addiu k0, %lo(START)
    jr k0
    nop

    .set reorder
    .set at
