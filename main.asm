;                       Asm calculator
;                      =================
; Calculator accepts three args. Second arg should be one of the valid
; operators: + - / *
; As the result of division calculator gives number with remainder.
;
; Examples: 
;   ./asmcalc 1 + 1
;   ./asmcalc 2 * 2
;   ./asmcalc 4 - 1

section .data

; -----
; Basic constants

NULL                equ 0
LF                  equ 10

EXIT_SUCCESS        equ 0
sys_EXIT            equ 60

; -----
; Error messages

NAN1                db "Error: First argument is not a valid number.", LF, NULL
NAN3                db "Error: Third argument is not a valid number.", LF, NULL
OperatorError       db "Error: Invalid operator. Valid operators: *,-,/,+", LF, NULL
tooFewError         db "Error: Too few arguments.", LF
                    db "Syntax: ./asmcalc a [+|-|*|/] b", LF, NULL
tooManyError        db "Error: Too many arguments.", LF
                    db "Syntax: ./asmcalc a [+|-|*|/] b", LF, NULL

; -----
; Calculation results

result              dq 0

section .bss
numA                resq 1
numB                resq 1
operation           resb 1

extern getNum
extern prints
extern operator
extern calc

section .text

global main
main:
    mov r12, rdi                        ; argc
    mov r13, rsi                        ; *argv[]

    cmp r12, 4
    jb tooFewArgs
    cmp r12, 4
    ja tooManyArgs

    mov rdi, qword [r13+1*8]
    call getNum
    cmp rax, 0
    je FirstInvalid

    mov qword [numA], rax
    
    mov rdi, qword [r13+2*8]
    call operator

    cmp rax, 0
    jl InvalidOperator
    mov byte [operation], al

    mov rdi, qword [r13+3*8]
    call getNum
    cmp rax, 0
    je ThirdInvalid

    mov qword [numB], rax

    mov rdi, qword [numA]
    mov sil, byte [operation]
    mov rdx, qword [numB]
    call calc
    
    jmp last

tooFewArgs:
    mov rdi, tooFewError
    call prints
    jmp last

tooManyArgs:
    mov rdi, tooManyError
    call prints
    jmp last

FirstInvalid:
    mov rdi, NAN1
    call prints
    jmp last

ThirdInvalid:
    mov rdi, NAN3
    call prints
    jmp last

InvalidOperator:
    mov rdi, OperatorError
    call prints

last:
    mov rax, sys_EXIT
    mov rdi, EXIT_SUCCESS
    syscall