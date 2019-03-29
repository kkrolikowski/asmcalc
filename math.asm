; math.asm -- mathematical functions.

section .data
section .text

global calc
calc:
    cmp sil, "+"
    je calcSum
    cmp sil, "-"
    je calcSub
    cmp sil, "*"
    je calcMul

    jmp calcEnd

calcMul:
    mov rax, rdi
    imul rdx
    jmp calcEnd

calcSum:
    mov rax, rdi
    add rax, rdx
    jmp calcEnd

calcSub:
    mov rax, rdi
    sub rax, rdx

calcEnd:
    ret