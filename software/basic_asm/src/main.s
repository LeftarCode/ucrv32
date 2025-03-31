    .section .text
    .globl _start
_start:
    addi x1, x0, 5
    addi x1, x1, 5
    addi x1, x1, 5
    addi x2, x2, 5
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x2, x2, 5
loop:
    jal x1, loop