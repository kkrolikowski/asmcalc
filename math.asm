; math.asm -- mathematical functions.

section .data

NULL                        equ 0
LF                          equ 10

newLine                     db LF, NULL
remainder                   db " R: ", NULL

extern int2str
extern prints

section .text

global calc
calc:
    push rbp
    mov rbp, rsp
    sub rsp, 11
    push rbx

    lea rbx, byte [rbp-11]

    cmp sil, "+"
    je calcSum
    cmp sil, "-"
    je calcSub
    cmp sil, "*"
    je calcMul
    cmp sil, "/"
    je calcDiv

    jmp calcEnd

calcMul:
    mov rax, rdi
    imul rdx

    mov rdi, rax
    mov rsi, rbx
    call int2str

    mov rdi, rbx
    call prints
    mov rdi, newLine
    call prints

    jmp calcEnd

calcSum:
    mov rax, rdi
    add rax, rdx

    mov rdi, rax
    mov rsi, rbx
    call int2str

    mov rdi, rbx
    call prints
    mov rdi, newLine
    call prints

    jmp calcEnd

calcSub:
    mov rax, rdi
    sub rax, rdx
    
    mov rdi, rax
    mov rsi, rbx
    call int2str

    mov rdi, rbx
    call prints
    mov rdi, newLine
    call prints

    jmp calcEnd

calcDiv:
    mov rax, rdi
    mov r10, rdx
    cqo
    idiv r10

    mov rdi, rax
    mov rsi, rbx
    call int2str

    mov rdi, rbx
    call prints
    mov rdi, remainder
    call prints

    mov rdi, rdx
    mov rsi, rbx
    call int2str

    mov rdi, rbx
    call prints
    mov rdi, newLine
    call prints

calcEnd:
    pop rbx
    mov rsp, rbp
    pop rbp
    ret