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

sum                 dq 0

section .bss
numA                resq 1
numB                resq 1

extern getNum

section .text

global main
main:
    mov r12, rdi                        ; argc
    mov r13, rsi                        ; *argv[]

    mov rdi, qword [r13+1*8]
    call getNum
    mov qword [numA], rax

last:
    mov rax, sys_EXIT
    mov rdi, EXIT_SUCCESS
    syscall