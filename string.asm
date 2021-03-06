; string.asm -- String manipulation functions
; - getNum(): converts string to integer
; - operator(): validates and returns operator sign
; - prints(): prints given string on the screen
; - int2str(): converts integer into string form

section .data

NULL                        equ 0
STDOUT                      equ 1
SYS_write                   equ 1
STR_MAX                     equ 20

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
    push rdx

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
    pop rdx
    pop rbx
    ret

; -----
; operator() -- function gets and validates few math operators
; HLL call: char op = operator(string);
; Returns:
;   * math operator ASCII code (success)
;   * -1 (failure)
global operator
operator:
    push rbx

    mov rbx, rdi                        ; set the string pointer
    mov r10, 0                          ; counter

; -----
; Stage I - count the characters
; If there are more than 1 character, we can assume
; that operator is invalid
cntChrLoop:
    cmp byte [rbx], NULL
    je VerifyOp
    inc rbx
    inc r10
    cmp r10, 1
    ja InvalidOp
    jmp cntChrLoop

; -----
; Stage II - operator verification
; If we have one of the below characters
; we can return it to the callee
VerifyOp:
    mov rbx, rdi
    cmp byte [rbx], "+"
    je ReturnOp
    cmp byte [rbx], "-"
    je ReturnOp
    cmp byte [rbx], "*"
    je ReturnOp
    cmp byte [rbx], "/"
    je ReturnOp

; -----
; Stage IV - return a char.
; Now we can return a valid math operator
; or -1 code in case of an error
InvalidOp:
    xor rax, rax
    mov rax, -1
    jmp operatorDone

ReturnOp:
    xor rax, rax
    mov al, byte [rbx]

operatorDone:
    pop rbx
    ret

; -----
; int2str() -- function transforms integer into string
; HLL call: int2str(number, string);
; Returns:
;   nothing
global int2str
int2str:
    push rbx
    push r12
    push rdx

    mov r10, 10                         ; divisior
    mov r12, 0                          ; stack items count
    mov r11, 0                          ; items popped from stack
    mov rbx, rsi                        ; string pointer

; -----
; Detect if given number is less than 0

    mov rax, rdi
    cmp rax, 0
    jl Negative
    jmp PushRemLoop

; -----
; If number is less than 0, convert it to positive
; and put '-' sign as the first element of array

Negative:
    cqo
    imul rax, -1
    mov byte [rbx], "-"
    inc rbx

; -----
; Push every digit on the stack
; To achieve this, implement a simple agorithm:
;   1. divide number by 10
;   2. push remainder on the stack
;   3. repeat untill result is greater than 0
PushRemLoop:
    cmp rax, 0
    je PopRemLoop

    mov rdx, 0
    div r10
    push rdx
    inc r12                             ; increment stack items count
    jmp PushRemLoop

; -----
; Get every digit from stack, convert it into character
; and save in the following char array fields
PopRemLoop:
    cmp r11, r12                        ; check if we've reached end of stack
    je int2strEND

    pop rax
    add rax, 48                         ; char. conversion

; -----
; If number of items exceed char limit for 64-bit value, just pop item from stack
; and skip updating array. This prevents buffer overflow.
    cmp r11, STR_MAX+1
    jae PopRemLoop

    mov byte [rbx], al
    inc rbx                             ; next array field
    inc r11                             ; items popped from stack
    jmp PopRemLoop

int2strEND:
    mov byte [rbx], NULL
    pop rdx
    pop r12
    pop rbx
    ret