; math.asm -- mathematical functions.

section .data
section .text

global calc
calc:
    cmp rsi, "+"
    je calcSum

calcSum:
    mov rax, rdi
    add rax, rdx
    
    ret