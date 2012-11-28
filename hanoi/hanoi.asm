section .text
    extern hanoi_towers
    global _start

_start:
    push qword 3
    push qword 2
    push qword 1
    push qword 3
    
    call hanoi_towers
    
    mov rax, 1
    mov rbx, 0
    int 0x80


