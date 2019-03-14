; string.asm -- String manipulation functions
; - getNum(): converts string to integer
; - operator(): validates and returns operator sign


section .data

NULL                        equ 0

section .text

global getNum
getNum:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    push rbx
    push r12
    push r13
    push r14

    lea rbx, dword [rbp-16]
    mov qword [rbx], rdi
    mov r10, qword [rbx]
    mov r12, 0                              ; items on stack
    mov r13, 0                              ; items from stack
    mov r14, 0                              ; integer to return

    cmp byte [r10], "-"
    je isNeg
    cmp byte [r10], "1"
    jb NaN
    cmp byte [r10], "9"
    ja NaN
    
    inc r10
    mov r11, 1
    jmp NumVerifyLoop

isNeg:
    mov r11, -1
    inc r10

NumVerifyLoop:
    cmp byte [r10], NULL
    je IsAnumber

    cmp byte [r10], "0"
    jb NaN
    cmp byte [r10], "9"
    ja NaN
    
    inc r10
    jmp NumVerifyLoop

IsAnumber:
    mov r10, qword [rbx]
    mov rax, 0
    
    cmp byte [r10], "-"
    je SkipSign
    
    jmp PushLoop

SkipSign:
    inc r10

PushLoop:
    cmp byte [r10], NULL
    je PopLoop

    mov al, byte [r10]
    push rax
    inc r12
    inc r10
    jmp PushLoop

PopLoop:
    cmp r13, r12
    je RetNum

    pop rax
    inc r13

    sub eax, 48
    mov edx, 0
    imul r11d

    mov dword [rbx+8], eax
    mov dword [rbx+12], edx
    mov rax, qword [rbx+8]
    add r14, rax

    mov eax, r11d
    imul eax, 10
    mov r11d, eax

    jmp PopLoop

RetNum:
    mov rax, r14
    jmp getNumEnd

NaN:
    mov rax, 0

getNumEnd:
    pop r14
    pop r13
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret