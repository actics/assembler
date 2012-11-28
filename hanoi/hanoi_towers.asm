section .data
    ptr db "%d -> %d", 10, 0

section .text
    extern printf
    global hanoi_towers

hanoi_towers:
    push rbp
    mov rbp, rsp

    cmp qword [rbp + 8*2], 1
    je .else
    
    dec  qword [rbp+8*2]
    
    push qword [rbp+8*4]
    push qword [rbp+8*5]
    push qword [rbp+8*3]
    push qword [rbp+8*2]

    call hanoi_towers
    sub rsp, 8*4

    mov rdx, [rbp+8*4]
    mov rsi, [rbp+8*3]
    mov rdi, ptr
    xor rax, rax
    call printf

    push qword [rbp+8*3]
    push qword [rbp+8*4]
    push qword [rbp+8*5]
    push qword [rbp+8*2]

    call hanoi_towers
    sub rsp, 8*4

    jmp .exit
    
.else:
    mov rdx, [rbp+8*4]
    mov rsi, [rbp+8*3]
    mov rdi, ptr
    xor rax, rax
    call printf

.exit:
    mov rsp, rbp
    pop rbp
    ret
