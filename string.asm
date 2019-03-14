; string.asm -- String manipulation functions
; - getNum(): converts string to integer
; - operator(): validates and returns operator sign
; - prints(): prints given string on the screen

section .data

NULL                        equ 0
STDOUT                      equ 1
SYS_write                   equ 1

section .text
; -----
; getNum() -- gets number from user
; HLL call: int num = getNum(str);
; Returns:
;   * integer on success
;   * 0 - when str is not a number
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
    mov qword [rbx], rdi                    ; save string address
    mov r10, qword [rbx]                    ; set pointer to the string
    mov r12, 0                              ; items on stack
    mov r13, 0                              ; items from stack
    mov r14, 0                              ; integer to return

; -----
; Stage I - String validation: 1'st step
;  - check if first character is proper number
;    or it is a negative sign
    cmp byte [r10], "-"
    je isNeg
    cmp byte [r10], "1"
    jb NaN
    cmp byte [r10], "9"
    ja NaN

; if first character was valid we can increase pointer address
; and set multiplication factor to the value of 1 and start
; to verify following characters
    inc r10
    mov r11, 1
    jmp NumVerifyLoop

; When given string represents negative number we need to set
; multiplication factor to the value od -1, incresae pointer
; adress and start to verify following characters 
isNeg:
    mov r11, -1
    inc r10

; -----
; Stage I - String validation: 2'nd step
; - validate following characters
NumVerifyLoop:
    cmp byte [r10], NULL                ; when we've reached null character
    je IsAnumber                        ; we can assume that number is correct

; valid number should be in 0-9 range
    cmp byte [r10], "0"
    jb NaN
    cmp byte [r10], "9"
    ja NaN
    
    inc r10                             ; next character in string
    jmp NumVerifyLoop

; -----
; Stage II - Push values on the stack (reversing order)

IsAnumber:
    mov r10, qword [rbx]                ; move back to the first char
    mov rax, 0
    
    cmp byte [r10], "-"                 ; skip '-' sign
    je SkipSign

    jmp PushLoop

SkipSign:
    inc r10

; Push string on the stack
; This technique will reverse numbers. It's necessary to make the conversion.
PushLoop:
    cmp byte [r10], NULL
    je PopLoop                          ; when done, we can convert every character
                                        ; to integer
    mov al, byte [r10]
    push rax
    inc r12                             ; increment values count
    inc r10                             ; next character
    jmp PushLoop

; -----
; Stage III - Convert values to integer

PopLoop:
    cmp r13, r12                        ; if stack counter is equal to character counter
    je RetNum                           ; we can assemble and return integer

    pop rax                             ; get next value from stack
    inc r13                             ; increment character counter

; To get a integer value of a character you have to subtract 48 and multiply by curent factor
    sub eax, 48
    mov edx, 0
    imul r11d

; assemble multiplication result and save a sum in R14 register.
    mov dword [rbx+8], eax
    mov dword [rbx+12], edx
    mov rax, qword [rbx+8]
    add r14, rax

; calculate the current multiplication factor.
; factor = factor * 10
    mov eax, r11d
    imul eax, 10
    mov r11d, eax

    jmp PopLoop

; -----
; Stage IV - return integer and end the function code

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

; -----
; prints() -- prints given string on the screen
; HLL call: prints(str);
; Returns:
;   * nothing
global prints
prints:
    push rbx

    mov rbx, rdi                        ; save the string adress
    mov rdx, 0                          ; set character counter

; -----
; Stage I - count characters to print

CharCountLoop:
    cmp byte [rbx], NULL
    je CharCountDone

    inc rdx                             ; increment char counter
    inc rbx                             ; next char.
    jmp CharCountLoop

; -----
; Stage II - print characters

CharCountDone:
    cmp rdx, 0                          ; when there's nothing to print
    je printsDone                       ; just end a function

; Print a given numbers of characters on the screen
    mov rax, SYS_write
    mov rsi, rdi
    mov rdi, STDOUT
    syscall

; -----
; Stage III - function end

printsDone:
    pop rbx
    ret