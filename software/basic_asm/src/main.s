    .section .text
    .globl _start
_start:
    lw   x1, 0(x0)   # Load word from address 0x0 into x1
    lw   x2, 1(x0)   # Load word from address 0x1 into x2
    j    _start      # Loop infinitely