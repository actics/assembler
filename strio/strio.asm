section .bss
    stdio_str resb 1024
    file_str  resb 1024

section .data
    file_show db "file string: %s", 10, 0
    stdin_show db "enter string to compare: ", 0
    mess db "file string o stdio string", 10, 0
    argc_error db  "take file name in first argument", 10, 0
    file_error db "can't open file", 10, 0

section .text
    extern printf
    extern fflush
    extern read_desc
    extern stringcmp

    global _start

_start:
    cmp qword [rsp], 2
    jl .argc_error

    mov rax, 2
    mov rdi, [rsp + 8*2]
    mov rsi, 0
    mov rdx, 0
    syscall

    test rax, rax
    jl .file_error

    push file_str
    push rax
    call read_desc
    add rsp, 8*2
    
    mov rax, 4
    mov rbx, [rsp - 8*2]
    syscall

    mov rdi, file_show
    mov rsi, file_str
    call print
    
    mov rdi, stdin_show
    mov rsi, stdio_str
    call print

    push stdio_str
    push qword 0
    call read_desc
    add rsp, 8*2

    push stdio_str
    push file_str
    call stringcmp
    add rsp, 8*2
    
    mov rdi, mess
    test rax, rax
    je .equal
    jg .great

.less:
    mov byte [mess+12], '<'
    call print
    jmp exit

.equal:
    mov byte [mess+12], '='
    call print
    jmp exit

.great:
    mov byte [mess+12], '>'
    call print
    jmp exit

.argc_error:
    mov rdi, argc_error
    call print
    jmp exit

.file_error:
    mov rdi, file_error
    call print
    jmp exit

exit:
    mov rax, 60
    mov rdi, 0
    syscall

print:
    xor rax, rax
    call printf
    xor rax, rax
    call fflush
    ret


