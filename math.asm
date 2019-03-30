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
    sub rsp, 21                         ; local string array char ar[21]
    push rbx

    lea rbx, byte [rbp-21]              ; array pointer

; -----
; capture valid operator

    cmp sil, "+"
    je calcSum
    cmp sil, "-"
    je calcSub
    cmp sil, "*"
    je calcMul
    cmp sil, "/"
    je calcDiv

    jmp calcEnd

; -------------------------------------------------------------------------------
;                                   Multiplication

calcMul:
    mov rax, rdi
    imul rdx

    cmp rdx, 0                          ; check if result fits in 64 bits.
    ja ResTooBig

; -----
; convert result to string

    mov rdi, rax
    mov rsi, rbx
    call int2str

; -----
; display result with following newline

    mov rdi, rbx
    call prints
    mov rdi, newLine
    call prints
    
    jmp calcEnd

; -----
; If result is over 64 bit - display an error

ResTooBig:
    mov rdi, toobig
    call prints

    jmp calcEnd

; -------------------------------------------------------------------------------
;                                   Sum

calcSum:
    mov rax, rdi
    add rax, rdx

    cmp rax, 0                          ; if result is 0, display 0 as string
    je printZero                        ; without further conversion

; -----
; convert result to string

    mov rdi, rax
    mov rsi, rbx
    call int2str

; -----
; Display result with following newline

    mov rdi, rbx
    call prints
    mov rdi, newLine
    call prints

    jmp calcEnd

; -------------------------------------------------------------------------------
;                                   Subtraction

calcSub:
    mov rax, rdi
    sub rax, rdx
    
    cmp rax, 0                          ; if result is 0, display 0 as string
    je printZero                        ; without further conversion

; -----
; convert result to string

    mov rdi, rax
    mov rsi, rbx
    call int2str

; -----
; Display result with following newline

    mov rdi, rbx
    call prints
    mov rdi, newLine
    call prints

    jmp calcEnd

; -------------------------------------------------------------------------------
;                                   Division

calcDiv:
    mov rax, rdi
    mov r10, rdx
    cqo
    idiv r10

; -----
; convert result to string

    mov rdi, rax
    mov rsi, rbx
    call int2str

; -----
; Display result with following remainder prefix

    mov rdi, rbx
    call prints
    mov rdi, remainder
    call prints

; -----
; convert remainder to string

    mov rdi, rdx
    mov rsi, rbx
    call int2str

; -----
; Display remainder with following newline

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