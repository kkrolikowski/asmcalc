; math.asm -- mathematical functions.
; - calc(): calculates and display results

section .data

NULL                        equ 0
LF                          equ 10

newLine                     db LF, NULL
remainder                   db " R: ", NULL
zero                        db "0", LF, NULL
toobig                      db "Result exceeds 64-bits", LF, NULL

extern int2str
extern prints

section .text

; -----
; calc() -- calculates and display results
; HLL call: calc(num1, operator, num2);
; Returns:
;   * nothing
global calc
calc:
    push rbp
    mov rbp, rsp
    sub rsp, 21
    push rbx

    lea rbx, byte [rbp-21]

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

    cmp rdx, 0
    ja ResTooBig

    mov rdi, rax
    mov rsi, rbx
    call int2str

    mov rdi, rbx
    call prints
    mov rdi, newLine
    call prints
    
    jmp calcEnd

ResTooBig:
    mov rdi, toobig
    call prints

    jmp calcEnd

calcSum:
    mov rax, rdi
    add rax, rdx

    cmp rax, 0
    je printZero

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
    
    cmp rax, 0
    je printZero

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

    jmp calcEnd

printZero:
    mov rdi, zero
    call prints

calcEnd:
    pop rbx
    mov rsp, rbp
    pop rbp
    ret