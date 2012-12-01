section .text
    global stringcmp

; int __cdecl stringcmp(char *str1, char *str2)
stringcmp:
    push rbp
    mov rbp, rsp
    
    mov rsi, [rbp + 8*2]
    mov rdi, [rbp + 8*3]

    xor rax, rax

    cld
.while:
    cmpsb
    jl .less
    jg .great

    cmp byte [rsi], 0
    je .exit

    jmp .while

.less:
    mov rax, -1
    jmp .exit

.great:
    mov rax, 1
    jmp .exit

.exit:
    mov rsp, rbp
    pop rbp
    ret

