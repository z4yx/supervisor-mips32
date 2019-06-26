#include<usb.h>
#include<usb_hid.h>
#include<sl811.h>
#include<regdef.h>


    .set noreorder
    .set noat
    .rdata
KEY_TABLE:
    .byte 0,0,0,0,'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','1','2','3','4','5','6','7','8','9','0','\r',0,'\b','\t',' ','-','=','[',']','\\',0,';','\'','`',',','.','/',0,'F','F','F','F','F','F','F','F','F','F','F','F', 0,0,0,0,0,0,0,0,0,0,0,0,0,0,'/','*','-','+','\r','1','2','3','4','5','6','7','8','9','0','.',0,0,0,'=', 'F','F','F','F','F','F','F','F','F','F','F','F', 0,0,0,0,0,0,0,0,0,0,0,0

KEY_SHIFT_TABLE:
    .byte 0,0,0,0,'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','!','@','#','$','%','^','&','*','(',')','\r',0,'\b','\t',' ','_','+','{','}','|',0,':','"','~','<','>','?',0,'F','F','F','F','F','F','F','F','F','F','F','F',0,0,0,0,0,0,0,0,0,0,0,0,0,0,'/','*','-','+','\r','1','2','3','4','5','6','7','8','9','0','.',0,0,0,'=','F','F','F','F','F','F','F','F','F','F','F','F',0,0,0,0,0,0,0,0,0,0,0,0

    .bss
    .global KEYBOARD_BUF
DEVICE_PRESENT:
    .word 0
LAST_STATUS:
    .word 0
G_BUF:
    .rept 512
    .byte 0
    .endr
PRESSED:
    .rept 128
    .byte 0
    .endr
PRESSED_NOW:
    .rept 128
    .byte 0
    .endr
KEYBOARD_BUF:
    .rept 8
    .byte 0
    .endr
KEYBOARD_BUF_CUR:
    .word 0

    .text
    .global USB_SL811_INIT
    .global READ_KEYBOARD
SL811_WRITE:            
    lui t0, %hi(SL811_PORT)
    addiu t0, t0, %lo(SL811_PORT)
    sb a0, 0(t0)
    nop
    nop
    nop
    sb a1, 4(t0)
    jr ra 
    nop

SL811_READ: 
    lui t0, %hi(SL811_PORT)
    addiu t0, t0, %lo(SL811_PORT)
    sb a0, 0(t0)
    nop
    nop
    nop
    lb v0, 4(t0)
    jr ra
    nop

SL811_WRITE_BUF:
    addi sp, sp, -0x10
    sw ra, 0x0(sp)
    sw s0, 0x4(sp)
    sw s1, 0x8(sp)
    sw s2, 0xC(sp)
    addi s0, a2, -1
    add s1, s0, a1
    add s2, zero, a0
.L0:
    add a0, s2, s0
    lb a1, 0(s1)
    jal SL811_WRITE
    nop
    addi s0, s0, -1
    addi s1, s1, -1
    bgez s0, .L0
    nop
    lw ra, 0x0(sp)                  
    lw s0, 0x4(sp)
    lw s1, 0x8(sp)
    lw s2, 0xC(sp)
    addi sp, sp, 0x10
    jr ra
    nop

SL811_READ_BUF:
    addi sp, sp, -0x10
    sw ra, 0x0(sp)
    sw s0, 0x4(sp)
    sw s1, 0x8(sp)
    sw s2, 0xC(sp)
    addi s0, a2, -1
    add s1, s0, a1
    add s2, zero, a0
.L1:
    add a0, s2, s0
    jal SL811_READ
    nop
    sb v0, 0(s1)
    addi s0, s0, -1
    addi s1, s1, -1
    bgez s0, .L1
    nop
    lw ra, 0x0(sp)                  
    lw s0, 0x4(sp)
    lw s1, 0x8(sp)
    lw s2, 0xC(sp)
    addi sp, sp, 0x10
    jr ra
    nop

RESET_SL811:
    addi sp, sp, -0xc
    sw ra, 0x0(sp)
    sw s0, 0x4(sp)
    sw s1, 0x8(sp)

    addi a0, zero, 0xf
    addi a1, zero, 0xae
    jal SL811_WRITE
    nop
    addi a0, zero, 0x5
    addi a1, zero, 0x8
    jal SL811_WRITE
    nop
    addi a0, zero, 50
    jal SLEEP
    nop
    addi a0, zero, 0x5
    addi a1, zero, 0x0
    jal SL811_WRITE
    nop
    addi a0, zero, 0xd
    addi a1, zero, 0xff
    jal SL811_WRITE
    nop
    addi a0, zero, 0xd
    jal SL811_READ
    nop
    lui s0, %hi(DEVICE_PRESENT)
    addiu s0, s0, %lo(DEVICE_PRESENT)
    sw zero, 0(s0)
    addi v0, v0, -64
    bnez v0, .OUT1 
    nop
    addi s1, zero, 1
    sw s1, 0(s0)
.OUT1:
    addi a0, zero, 0xa
    addi a1, zero, 0x0
    jal SL811_WRITE
    nop
    addi a0, zero, 0xb
    addi a1, zero, 0x50
    jal SL811_WRITE
    nop
    addi a0, zero, 0xc
    addi a1, zero, 0x0
    jal SL811_WRITE
    nop
    addi a0, zero, 0xe
    addi a1, zero, 0xe0
    jal SL811_WRITE
    nop
    addi a0, zero, 0x5
    addi a1, zero, 0x8
    jal SL811_WRITE
    nop
    addi a0, zero, 50
    jal SLEEP
    nop
    addi a0, zero, 0xf
    addi a1, zero, 0xae
    jal SL811_WRITE
    nop
    addi a0, zero, 0x5
    addi a1, zero, 0x1
    jal SL811_WRITE
    nop
    addi a0, zero, 0x8
    addi a1, zero, 0x1
    jal SL811_WRITE
    nop
    addi a0, zero, 0xd
    addi a1, zero, 0xff
    jal SL811_WRITE
    nop
    lw ra, 0x0(sp)
    lw s0, 0x4(sp)
    lw s1, 0x8(sp)
    addi sp, sp, 0xc
    jr ra
    nop

WAIT_TRANSFER: 
    addi sp, sp, -0xc
    sw ra, 0x0(sp)
    sw s0, 0x4(sp)
    sw s1, 0x8(sp)
    addi s0, zero, 100
.L3:
    addi a0, zero, SL11H_IRQ_STATUS
    jal SL811_READ
    nop
    andi v0, v0, 1
    beq v0, zero, .OUT2
    nop
    addi a0, zero, SL11H_IRQ_STATUS
    addi a1, zero, 0xff
    jal SL811_WRITE
    nop
    addi a0, zero, SL11H_PKTSTATREG
    jal SL811_READ
    nop
    lui s1, %hi(LAST_STATUS)
    addiu s1, %lo(LAST_STATUS)
    sw v0, 0(s1)
    addi v0, zero, 0
    j .RET1
    nop     
.OUT2:
    addi s0, s0, -1
    bgtz s0, .L3
    nop
    addi v0, zero, -2
.RET1:
    lw ra, 0x0(sp)
    lw s0, 0x4(sp)
    lw s1, 0x8(sp)
    addi sp, sp, 0xc
    jr ra
    nop

SETUP_PACKET:
    addi sp, sp, -0x10
    sw ra, 0x0(sp)
    sw s0, 0x4(sp)
    sw s1, 0x8(sp)
    sw s2, 0xc(sp)
    add s0, zero, a0
    add s1, zero, a1
    add s2, zero, a2
    addi a0, zero, 0x10
    add a1, zero, s0
    addi a2, zero, 8
    jal SL811_WRITE_BUF
    nop
    addi a0, zero, SL11H_BUFADDRREG
    addi a1, zero, 0x10
    jal SL811_WRITE 
    nop
    addi a0, zero, SL11H_BUFLNTHREG
    addi a1, zero, 8
    jal SL811_WRITE
    nop
    addi a0, zero, SL11H_PIDEPREG
    ori a1, s1, SL_SETUP
    jal SL811_WRITE 
    nop
    addi a0, zero, SL11H_DEVADDRREG
    add a1, zero, s2
    jal SL811_WRITE
    nop
    addi a0, zero, SL11H_HOSTCTLREG
    addi a1, zero, SL11H_HCTLMASK_ARM
    ori a1, a1, SL11H_HCTLMASK_ENABLE 
    ori a1, a1, SL11H_HCTLMASK_OUT
    ori a1, a1, SL11H_HCTLMASK_AFTERSOF
    jal SL811_WRITE
    nop
    jal WAIT_TRANSFER
    nop
    beq v0, zero, .OUT3
    nop
    addi v0, zero, -1
    j .RET2
    nop
.OUT3:
    addi a0, zero, SL11H_IRQ_STATUS
    addi a1, zero, 0xff
    addi v0, zero, 0
.RET2:
    lw ra, 0x0(sp)
    lw s0, 0x4(sp)
    lw s1, 0x8(sp)
    lw s2, 0xc(sp)
    addi sp, sp, 0x10
    jr ra
    nop

IN_PACKET:
    addi sp, sp, -0x18
    sw ra, 0x0(sp)
    sw s0, 0x4(sp)
    sw s1, 0x8(sp)
    sw s2, 0xc(sp)
    sw s3, 0x10(sp)
    sw s4, 0x14(sp)
    add s0, zero, a0
    add s1, zero, a1
    add s2, zero, a2
    add s3, zero, a3
    lw s4, 0x18(sp)
.L4:
    addi a0, zero, SL11H_BUFADDRREG
    addi a1, zero, 0x20
    jal SL811_WRITE
    nop
    addi a0, zero, SL11H_BUFLNTHREG
    add a1, zero, s1
    jal SL811_WRITE
    nop
    addi a0, zero, SL11H_PIDEPREG
    ori a1, s2, SL_IN
    jal SL811_WRITE
    nop
    addi a0, zero, SL11H_DEVADDRREG
    add a1, zero, s3
    jal SL811_WRITE
    nop
    addi a0, zero, SL11H_IRQ_STATUS
    addi a1, zero, 0xff
    jal SL811_WRITE
    nop
    addi a0, zero, SL11H_HOSTCTLREG
    ori a1, zero, SL11H_HCTLMASK_ARM
    ori a1, a1, SL11H_HCTLMASK_ENABLE
    ori a1, a1, SL11H_HCTLMASK_IN
    ori a1, a1, SL11H_HCTLMASK_AFTERSOF
    jal SL811_WRITE
    nop
    jal WAIT_TRANSFER
    nop
    addi a0, zero, SL11H_IRQ_STATUS
    addi a1, zero, 0xff
    jal SL811_WRITE
    nop
    beq v0, zero, .OUT4
    addi v0, zero, -1
    j .RET3
    nop
.OUT4:
    lui t0, %hi(LAST_STATUS)
    addiu t0, t0, %lo(LAST_STATUS)
    lw t1, 0(t0)
    andi t2, t1, SL11H_STATMASK_ACK
    beq t2, zero, .OUT5
    nop
    addi a0, zero, 0x20
    add a1, zero, s0
    add a1, zero, s1
    jal SL811_READ_BUF
    nop
    addi v0, zero, 0
    j .RET3
    nop
.OUT5:
    ori t3, zero, SL11H_STATMASK_TMOUT
    ori t3, t3, SL11H_STATMASK_STALL
    and t2, t1, t3
    beq t2, zero, .OUT6
    nop
    addi v0, zero, -1
    j .RET3
    nop
.OUT6:
    bnez s4, .L4
    nop
    andi t2, t1, SL11H_STATMASK_NAK
    beq t2, zero, .L4
    nop
    addi v0, zero, -1
.RET3:  
    lw ra, 0x0(sp)
    lw s0, 0x4(sp)
    lw s1, 0x8(sp)
    lw s2, 0xc(sp)
    lw s3, 0x10(sp)
    lw s4, 0x14(sp)
    addi sp, sp, 0x18
    jr ra
    nop

STATUS_PACKET:
    addi sp, sp, -0xc
    sw ra, 0x0(sp)
    sw s0, 0x4(sp)
    sw s1, 0x8(sp)
    add s0, zero, a0
    add s1, zero, a1

    addi a0, zero, SL11H_BUFADDRREG
    addi a1, zero, 0x20
    jal SL811_WRITE
    nop
    addi a0, zero, SL11H_BUFLNTHREG
    addi a1, zero, 0
    jal SL811_WRITE
    nop
    addi a0, zero, SL11H_PIDEPREG
    ori a1, s0, SL_OUT
    jal SL811_WRITE
    nop
    addi a0, zero, SL11H_DEVADDRREG
    add a1, zero, s1
    jal SL811_WRITE
    nop
    addi a0, zero, SL11H_HOSTCTLREG
    ori a1, zero, SL11H_HCTLMASK_ARM
    ori a1, a1, SL11H_HCTLMASK_ENABLE
    ori a1, a1, SL11H_HCTLMASK_OUT
    ori a1, a1, SL11H_HCTLMASK_TOGGLE
    ori a1, a1, SL11H_HCTLMASK_AFTERSOF
    jal SL811_WRITE
    nop
    jal WAIT_TRANSFER
    nop
    beq v0, zero, .OUT7
    nop
    addi v0, zero, -1
    j .RET4
    nop
.OUT7:
    addi v0, zero, 0
.RET4: 
    lw ra, 0x0(sp)
    lw s0, 0x4(sp)
    lw s1, 0x8(sp)
    addi sp, sp, 0xc
    jr ra
    nop

USB_GET_DEV_DESC:
    addi sp, sp, -0x24
    sw ra, 0x8(sp)
    sw s0, 0xc(sp)
    sw s1, 0x10(sp)
    sw s2, 0x14(sp)
    sw s3, 0x18(sp)
    sw s4, 0x1c(sp)
    sw s5, 0x20(sp)
    add s0, zero, a0
    add s1, zero, a1
    add s2, zero, a2
    ori t0, zero, USB_REQ_TYPE_IN
    ori t0, t0, USB_REQ_TYPE_STANDARD
    ori t0, t0, USB_REQ_TYPE_DEVICE
    sb t0, 0x0(sp)
    ori t0, zero, GET_DESCRIPTOR
    sb t0, 0x1(sp)
    ori t0, zero, USB_DESC_TYPE_DEVICE
    sll t0, t0, 8
    sh t0, 0x2(sp)
    sh zero, 0x4(sp)
    addi t0, zero, 18
    sh t0, 0x6(sp)
    add a0, zero, sp
    add a1, zero, s1
    add a2, zero, s2
    jal SETUP_PACKET
    nop
    add s3, zero, v0
    addi sp, sp, -4
    addi t0, zero, 1
    sw t0, 0x0(sp)
    add a0, zero, s0
    addi a1, zero, 18
    add a2, zero, s1
    add a3, zero, s2
    jal IN_PACKET
    nop
    add s4, zero, v0
    add a0, zero, s1
    add a1, zero, s2
    jal STATUS_PACKET
    nop
    add s5, zero, v0
    bnez s3, .OUT8
    nop
    bnez s4, .OUT8
    nop
    bnez s5, .OUT8
    nop
    addi v0, zero, 0
    j .RET5
    nop
.OUT8:
    addi v0, zero, -1
.RET5:
    addi sp, sp, 4
    lw ra, 0x8(sp)
    lw s0, 0xc(sp)
    lw s1, 0x10(sp)
    lw s2, 0x14(sp)
    lw s3, 0x18(sp)
    lw s4, 0x1c(sp)
    lw s5, 0x20(sp)
    addi sp, sp, 0x24
    jr ra
    nop

USB_SET_ADDRESS:
    addi sp, sp, -0x2c
    sw ra, 0x14(sp)
    sw s0, 0x18(sp)
    sw s1, 0x1c(sp)
    sw s2, 0x20(sp)
    sw s3, 0x24(sp)
    sw s4, 0x28(sp)

    ori t0, zero, USB_REQ_TYPE_OUT
    ori t0, t0, USB_REQ_TYPE_STANDARD
    ori t0, t0, USB_REQ_TYPE_DEVICE
    sb t0, 0x0(sp)
    ori t0, zero, SET_ADDRESS
    sb t0, 0x1(sp)
    sh s2, 0x2(sp)
    sh zero, 0x4(sp)
    sh zero, 0x6(sp)
    add a0, zero, sp
    add a1, zero, s0
    add a2, zero, s1
    jal SETUP_PACKET
    nop
    add s3, zero, v0
    addi a0, sp, 8
    addi a1, zero, 0
    add a2, zero, s0
    add a3, zero, s1
    addi sp, sp, -4
    addi t0, zero, 1
    sw t0, 0x0(sp)
    jal IN_PACKET
    nop
    addi sp, sp, 4
    add s4, zero, v0
    bnez s3, .OUT9
    nop
    bnez s4, .OUT9
    nop
    addi v0, zero, 0
    j .RET6
    nop
.OUT9:
    addi v0, zero, -1
.RET6:
    lw ra, 0x14(sp)
    lw s0, 0x18(sp)
    lw s1, 0x1c(sp)
    lw s2, 0x20(sp)
    lw s3, 0x24(sp)
    lw s4, 0x28(sp)
    addi sp, sp, 0x2c
    jr ra
    nop

USB_GET_CONF_DESC:
    addi sp, sp, -0x2c
    sw ra, 0x8(sp)
    sw s0, 0xc(sp)
    sw s1, 0x10(sp)
    sw s2, 0x14(sp)
    sw s3, 0x18(sp)
    sw s4, 0x1c(sp)
    sw s5, 0x20(sp)
    sw s6, 0x24(sp)
    sw s7, 0x28(sp)

    add s0, zero, a0
    add s1, zero, a1
    add s2, zero, a2
    add s3, zero, a3

    ori t0, zero, USB_REQ_TYPE_IN
    ori t0, t0, USB_REQ_TYPE_STANDARD
    ori t0, t0, USB_REQ_TYPE_DEVICE
    sb t0, 0x0(sp)
    ori t0, zero, GET_DESCRIPTOR
    sb t0, 0x1(sp)
    ori t0, zero, USB_DESC_TYPE_CONF
    sll t0, t0, 8
    sh t0, 0x2(sp)
    sh zero, 0x4(sp)
    sh s1, 0x6(sp)
    add a0, zero, sp
    add a1, zero, s2
    add a2, zero, s3
    jal SETUP_PACKET
    nop
    add s4, zero, v0
    add s7, zero, s1

    addi sp, sp, -4
    addi t0, zero, 1
    sw t0, 0x0(sp)
.L5:
    blez s7, .OUT11
    nop
    sub s6, s1, s7
    addi t0, zero, 120
    sub t1, s7, t0
    bgtz t1, .OUT10
    nop
    add t0, zero, s7
.OUT10:
    sub s7, s7, t0
    add a0, s0, s6
    addi a1, zero, 1
    add a2, zero, s2
    add a3, zero, s3
    jal IN_PACKET
    nop
    add s5, zero, v0
    bnez s5, .OUT11
    nop
    j .L5
    nop
.OUT11:
    addi sp, sp, 4
    add a0, zero, s2
    add a1, zero, s3
    jal STATUS_PACKET
    nop
    add s6, zero, v0
    bnez s4, .OUT12
    nop
    bnez s5, .OUT12
    nop
    bnez s6, .OUT12
    nop
    addi v0, zero, 0
    j .RET7
    nop
.OUT12:
    addi v0, zero, -1
.RET7:
    lw ra, 0x8(sp)
    lw s0, 0xc(sp)
    lw s1, 0x10(sp)
    lw s2, 0x14(sp)
    lw s3, 0x18(sp)
    lw s4, 0x1c(sp)
    lw s5, 0x20(sp)
    lw s6, 0x24(sp)
    lw s7, 0x28(sp)
    addi sp, sp, 0x2c
    jr ra
    nop

USB_SET_CONF:
    addi sp, sp, -0x2c
    sw ra, 0x14(sp)
    sw s0, 0x18(sp)
    sw s1, 0x1c(sp)
    sw s2, 0x20(sp)
    sw s3, 0x24(sp)
    sw s4, 0x28(sp)

    add s0, zero, a0
    add s1, zero, a1
    add s2, zero, a2

    ori t0, zero, USB_REQ_TYPE_OUT
    ori t0, t0, USB_REQ_TYPE_STANDARD
    ori t0, t0, USB_REQ_TYPE_DEVICE
    sb t0, 0x0(sp)
    ori t0, zero, SET_CONF
    sb t0, 0x1(sp)
    sh s2, 0x2(sp)
    sh zero, 0x4(sp)
    sh zero, 0x6(sp)
    add a0, zero, sp
    add a1, zero, s0
    add a2, zero, s1
    jal SETUP_PACKET
    nop
    add s3, zero, v0
    addi sp, sp, -4
    addi t0, zero, 1
    sw t0, 0x0(sp)
    addi a0, sp, 12
    addi a1, zero, 0
    add a2, zero, s0
    add a3, zero, s1
    jal IN_PACKET
    nop
    addi sp, sp, 4
    add s4, zero, v0
    bnez s3, .OUT13
    nop
    bnez s4, .OUT13
    nop
    addi v0, zero, 0
    j .RET8
    nop
.OUT13:
    addi v0, zero, -1
.RET8:
    lw ra, 0x14(sp)
    lw s0, 0x18(sp)
    lw s1, 0x1c(sp)
    lw s2, 0x20(sp)
    lw s3, 0x24(sp)
    lw s4, 0x28(sp)
    addi sp, sp, 0x2c
    jr ra
    nop

USB_INT_IN:
    addi sp, sp, -0x10
    sw ra, 0x0(sp)
    sw s0, 0x4(sp)
    sw s1, 0x8(sp)
    sw s2, 0xc(sp)

    add s0, zero, a2
    add s1, zero, a3
    addi sp, sp, -4
    sw zero, 0x0(sp)
    jal IN_PACKET
    nop
    add s2, zero, v0
    addi sp, sp, 4
    add a0, zero, s0
    add a1, zero, s1
    jal STATUS_PACKET
    nop
    add v0, zero, s2
    
    lw ra, 0x0(sp)
    lw s0, 0x4(sp)
    lw s1, 0x8(sp)
    lw s2, 0xc(sp)
    addi sp, sp, 0x10
    jr ra 
    nop

USB_SL811_INIT:
    addi sp, sp, -4
    sw ra, 0x0(sp)

    lui t0, %hi(KEYBOARD_BUF)
    addiu t0, %lo(KEYBOARD_BUF)
    lui t1, %hi(KEYBOARD_BUF_CUR)
    addiu t1, %lo(KEYBOARD_BUF_CUR)
    sw t0, 0x0(t1)

    jal RESET_SL811
    nop
    lui t0, %hi(DEVICE_PRESENT)
    addiu t0, %lo(DEVICE_PRESENT)
    lw t1, 0x0(t0)
    beq t1, zero, .RET9
    nop
    add a0, zero, sp
    addi a1, zero, 0
    addi a2, zero, 0
    jal USB_GET_DEV_DESC
    nop
    bnez v0, .RET9
    nop
    addi a0, zero, 0
    addi a1, zero, 0
    addi a2, zero, 1
    jal USB_SET_ADDRESS
    nop
    bnez v0, .RET9
    nop
    addi a0, zero, 0
    addi a1, zero, 1
    addi a2, zero, 1
    jal USB_SET_CONF
    nop
.RET9:
    lw ra, 0x0(sp)
    addi sp, sp, 4
    jr ra
    nop

CHECK_KEYBOARD_INPUT:    
    addi sp, sp, -0x8
    sw ra, 0x0(sp)
    sw s0, 0x4(sp)
    addi s0, zero, 0

    lui a0, %hi(G_BUF)
    addi a0, %lo(G_BUF)
    addi a1, zero, 8
    addi a2, zero, 1
    addi a3, zero, 1
    jal USB_INT_IN
    nop
    bnez v0, .RET10
    nop
    lui t0, %hi(PRESSED_NOW)
    addi t0, %lo(PRESSED_NOW)
    addi t1, zero, 32
.L6:
    sw zero, 0(t0)
    addi t0, t0, 4
    addi t1, t1, -1
    bnez t1, .L6
    nop

    addi t0, zero, 2
.L7:
    lui t1, %hi(G_BUF)
    addi t1, %lo(G_BUF)
    add t1, t1, t0
    lb t4, 0x0(t1)
    addi t2, t4, -128
    bgez t2, .RET10
    nop
    lui t1, %hi(G_BUF)
    addi t1, %lo(G_BUF)
    lb t2, 0x0(t1)
    ori t3, zero, KEY_MOD_LSHIFT
    ori t3, t3, KEY_MOD_RSHIFT
    and t2, t2, t3
    bnez t2, .SHIFT
    nop
.NO_SHIFT:
    lui t1, %hi(KEY_TABLE)
    addi t1, %lo(KEY_TABLE)
    j .OUT14
    nop
.SHIFT:
    lui t1, %hi(KEY_SHIFT_TABLE)
    addi t1, %lo(KEY_SHIFT_TABLE)
.OUT14:
    add t1, t1, t4
    lb t5, 0x0(t4)
    lui t1, %hi(PRESSED_NOW)
    addi t1, %lo(PRESSED_NOW)
    add t1, t1, t5
    addi t2, zero, 1
    sb t2, 0x0(t1)
    addi t0, t0, 1
    addi t4, t0, -8
    bnez t4, .L7
    nop

    addi t0, zero, 127
    lui t6, %hi(KEYBOARD_BUF)
    addiu t6, %lo(KEYBOARD_BUF)
.L8:
    lui t1, %hi(PRESSED_NOW)
    addi t1, %lo(PRESSED_NOW)
    add t1, t1, t0
    lb t3, 0x0(t1)
    lui t2, %hi(PRESSED)
    addi t2, %lo(PRESSED)
    add t2, t2, t0
    lb t4, 0x0(t2)
    beq t3, zero, .OUT15
    nop
    bnez t4, .OUT15
    nop   
    
    addi s0, zero, 1
    sb t0, 0x0(t6)
    addi t6, t6, 1
.OUT15:
    sb t3, 0x0(t2)
    addi t0, t0, -1
    bnez t0, .L8
    nop

    lui t5, %hi(KEYBOARD_BUF_CUR)
    addiu t5, %lo(KEYBOARD_BUF_CUR)
    sw t6, 0x0(t5)
.RET10:
    add v0, zero, s0
    lw ra, 0x0(sp)
    lw s0, 0x4(sp)
    addi sp, sp, 0x8
    jr ra
    nop

KEYBOARD_BUF_EMPTY:
    addi v0, zero, 1
    lui t0, %hi(KEYBOARD_BUF_CUR)
    addiu t0, %lo(KEYBOARD_BUF_CUR)
    lw t1, 0x0(t0)
    lui t0, %hi(KEYBOARD_BUF)
    addiu t0, %lo(KEYBOARD_BUF)
    beq t0, t1, .RET11
    nop
    addi v0, zero, 0
.RET11:
    jr ra 
    nop

READ_KEYBOARD:
    addi sp, sp, -8
    sw ra, 0x0(sp)
    sw s0, 0x4(sp)
    addi s0, zero, 0

    jal KEYBOARD_BUF_EMPTY
    nop
    beq v0, zero, .READBUF
    nop
    jal CHECK_KEYBOARD_INPUT
    nop
    beq v0, zero, .RET12
    nop
.READBUF:
    lui t0, %hi(KEYBOARD_BUF_CUR)
    addiu t0, %lo(KEYBOARD_BUF_CUR)
    lw t1, 0x0(t0)
    addi t1, t1, -1
    lb s0, 0x0(t1) 
.RET12:
    lw ra, 0x0(sp)
    lw s0, 0x4(sp)
    addi sp, sp, 8
    jr ra
    nop

SLEEP:
    addi t0, zero, CYCLES_PER_MS
    mult t0, a0
    mflo t0
    sra t0, t0, 2
.L2:
    nop
    addi t0, t0, -1
    bnez t0, .L2
    nop
    jr ra 
    nop

    .set at
    .set reorder
