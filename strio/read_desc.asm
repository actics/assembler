section .text
    global read_desc

; int __cdecl read_desc(int descriptor, char *str);
read_desc:
    push rbp
    mov rbp, rsp
    
    xor rcx, rcx
    xor rbx, rbx
    mov rbx, [rbp + 8*3]

.read:
    mov rax, 0
    mov rdi, [rbp + 8*2]
    mov rsi, rbx
    mov rdx, 1
    syscall
    
    xor rax, rax
    mov al, [rbx]

    cmp rax, 10
    je .exit

    test rax, rax
    je .exit

    inc rbx
    inc rcx
    jmp .read
    
.exit:
    mov byte [rbx], 0
    mov rax, rcx

    mov rsp, rbp
    pop rbp
    ret

