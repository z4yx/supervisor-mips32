#include <regdef.h>
#include <mipsregs.h>
#include <unistd.h>
#include <exception.h>
#include <shell.h>

/*==============================================================
 *                        TEST for MONITOR
 *  Built-in test program
 *  Entry symbol prefix 'UTEST_'
 *==============================================================*/
    

    .set noreorder
    .set noat
    .section .text.utest
    .p2align 2

    /*  Simple test program
     *  Write integer 1 to register v0
     */
UTEST_SIMPLE:
    addiu v0, v0, 0x1
    jr ra
    nop
    /* End of test */

    /*  STREAM test program
     *  Continous memory read/write
     */
UTEST_STREAM:
    li      a0, 0x80100000
    li      a1, 0x80400000
    li      a2, 0x00300000
    addu    a2,a0,a2
stream_next:
    beq     a0,a2,stream_end
    addiu   a1,a1,4

    lw      v0,0(a0)
    sw      v0,-4(a1)
    beq     $0,$0,stream_next
    addiu   a0,a0,4

stream_end:
    jr      ra
    nop
    /* End of test */

    /*  MATRIX test program
     *  Matrix multiplication
     *  Reference C code:
        void matrix(int a[128][128],int b[128][128],int c[128][128],unsigned int n) {
            unsigned int i,j,k;
            for (k=0; k!=n; k++) {
                for (i=0; i!=n; i++) {
                    int r = a[i][k];
                    for (j=0; j!=n; j++)
                        c[i][j] += r * b[k][j];
                }
            }
        }
     */
UTEST_MATRIX:
    // set arguments
    li      a0, 0x80400000
    li      a1, 0x80410000
    li      a2, 0x80420000
    li      a3, 96
    // a0 -> a
    // a1 -> b
    // a2 -> c
    // a3 -> n
    // v1 -> k
    // t1 -> i
    // t3 -> j
    // t7 -> r
    or      v1,$0,$0
loop1:
    beq     v1,a3,loop1end
    sll     t0,v1,2

    sll     t2,v1,9
    addu    t0,a0,t0
    addu    t2,a1,t2
    or      t1,$0,$0
loop2:
    beq     t1,a3,loop2end
    sll     v0,t1,9

    lw      t7,0(t0)
    addu    v0,a2,v0
    or      t4,t2,$0
    or      t3,$0,$0
loop3:
    beq     t3,a3,loop3end
    addiu   t3,t3,1

    lw      t5,0(t4)
    lw      t6,0(v0)
    mul     t5,t7,t5
    addiu   v0,v0,4
    addiu   t4,t4,4
    addu    t5,t6,t5
    beq     $0,$0,loop3
    sw      t5,-4(v0)

loop3end:
    addiu   t1,t1,1
    beq     $0,$0,loop2
    addiu   t0,t0,512

loop2end:
    beq     $0,$0,loop1
    addiu   v1,v1,1

loop1end:
    jr ra
    nop
    /* End of test */

    /*  CryptoNight test program
     *  Run simplified CryptoNight memory-hard loop
     *  Reference C code:
        void crn(int pad[],unsigned int a,unsigned int b,unsigned int n) {
            unsigned int k;
            for (k=0; k!=0x80000; k++)
                pad[k] = k;
            for (k=0; k!=n; k++) {
                unsigned int t, addr1, addr2;
                addr1 = a & 0x7FFFF;
                t = (a >> 1) ^ (pad[addr1] << 1); // Replace the AES step
                pad[addr1] = t ^ b;
                addr2 = t & 0x7FFFF;
                b = t;
                t = pad[addr2];
                a += b * t;
                pad[addr2] = a;
                a ^= t;
            } 
        }
     */
UTEST_CRYPTONIGHT:
    // a0 -> pad
    // a1 -> a
    // a2 -> b
    // a3 -> n
    li      a0, 0x80400000
    li      a1, 0xdeadbeef
    li      a2, 0xfaceb00c
    li      a3, 0x100000
    or      v1,$0,a0
    or      v0,$0,$0
    li      t0,0x80000
fill_next:
    sw      v0,0(v1)
    addiu   v0,v0,1
    bne     v0,t0,fill_next
    addiu   v1,v1,4

    or      t1,$0,$0
    li      t2,0x7ffff
crn_hext:
    and     t0,a1,t2
    sll     t0,t0,2
    addu    t0,a0,t0
    lw      v0,0(t0)
    srl     v1,a1,1
    sll     v0,v0,1
    xor     v0,v0,v1
    and     v1,v0,t2
    xor     a2,v0,a2
    sll     v1,v1,2
    sw      a2,0(t0)
    addu    v1,a0,v1
    lw      t0,0(v1)
    or      a2,$0,v0
    mul     v0,v0,t0
    addiu   t1,t1,1
    addu    a1,v0,a1
    sw      a1,0(v1)
    bne     a3,t1,crn_hext
    xor     a1,t0,a1
crn_end:
    jr      ra
    nop
    /* End of test */

    /*  系统调用测试程序
     *  该测试仅在实现异常处理时有效
     */
#ifdef ENABLE_INT
UTEST_PUTC:
    ori v0, zero, SYS_putc          // 系统调用号
    ori a0, zero, 0x4F              // 'O'
    syscall SYSCALL_BASE
    nop
    ori a0, zero, 0x4B              // 'K'
    syscall SYSCALL_BASE
    nop
    jr ra
    nop
#endif


#define TESTLOOP64  0x04000000      /*  64M约6.7千万次   */
#define TESTLOOP32  0x02000000      /*  32M约3.4千万次   */
#define TESTLOOP16  0x01000000      /*  16M约1.7千万次   */

    /*  性能标定程序(1)
     *  这段程序一般没有数据冲突和结构冲突，可作为性能标定。
     *  若执行延迟槽，执行这段程序需至少384M指令，384M/time可算得频率。
     *  不执行延迟槽，执行这段程序需至少320M指令，320M/time可算得频率。
     */
UTEST_1PTB:
    lui t0, %hi(TESTLOOP64)         // 装入64M
    nop
    nop
    nop
.LC0:
    addiu t0, t0, -1                // 滚动计数器
    ori t1, zero, 0
    ori t2, zero, 1
    ori t3, zero, 2
    bne t0, zero, .LC0
    nop
    nop
    jr ra
    nop


    /*  运算数据冲突的效率测试(2)
     *  这段程序含有大量数据冲突，可测试数据冲突对效率的影响。
     *  执行延迟槽，执行这段程序需至少192M指令。
     *  不执行延迟槽，执行这段程序需至少176M指令。
     */
UTEST_2DCT:
    lui t0, %hi(TESTLOOP16)         // 装入16M
    ori t1, zero, 1
    ori t2, zero, 2
    ori t3, zero, 3
.LC1:
    xor t2, t2, t1                  // 交换t1,t2
    xor t1, t1, t2
    xor t2, t2, t1
    xor t3, t3, t2                  // 交换t2,t3
    xor t2, t2, t3
    xor t3, t3, t2
    xor t1, t1, t3                  // 交换t3,t1
    xor t3, t3, t1
    xor t1, t1, t3
    addiu t0, t0, -1
    bne t0, zero, .LC1
    nop
    jr ra
    nop


    /*  控制指令冲突测试(3)
     *  这段程序有大量控制冲突。
     *  无延迟槽执行需要至少256M指令；
     *  有延迟槽需要224M指令。
     */
UTEST_3CCT:
    lui t0, %hi(TESTLOOP64)         // 装入64M
.LC2_0:
    bne t0, zero, .LC2_1
    nop
    jr ra
    nop
.LC2_1:
    j .LC2_2
    nop
.LC2_2:
    addiu t0, t0, -1
    j .LC2_0
    addiu t0, t0, -1
    nop


    /*  访存相关数据冲突测试(4)
     *  这段程序反复对内存进行有数据冲突的读写。
     *  不执行延迟槽需要至少192M指令。
     *  执行延迟槽，需要至少224M指令。
     */
UTEST_4MDCT:
    lui t0, %hi(TESTLOOP32)          // 装入32M
    addiu sp, sp, -4
.LC3:
    sw t0, 0(sp)
    lw t1, 0(sp)
    addiu t1, t1, -1
    sw t1, 0(sp)
    lw t0, 0(sp)
    bne t0, zero, .LC3
    nop
    addiu sp, sp, 4
    jr ra
    nop


    // 测试程序扩展



    .set reorder
    .set at
