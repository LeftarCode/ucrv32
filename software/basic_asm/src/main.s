    .section .text
    .globl _start
_start:
    lw   x1, 0(x0)
    lw   x1, 0(x0)
    lw   x1, 0(x0)
    sw x1, 0(x0)
    lw   x1, 0(x0)
    lw   x1, 0(x0)
    lw   x1, 0(x0)
loop:
    jal x1, loop      # Loop infinitely