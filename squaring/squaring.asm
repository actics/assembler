; Квадрат матрицы

%macro create_array 2
%assign i 0
%rep %2
dq %1 + %2 * i * 8
%assign i i+1
%endrep
%endmacro

section .data
    side_len equ 3
    
    matrix        create_array        matrix_dq, side_len
    return_matrix create_array return_matrix_dq, side_len
    
    matrix_dq dq  1, 0, 2, \
                 -1, 4, 0, \
                  3,-2, 1

section .bss
    return_matrix_dq resq side_len*side_len

section .text

global _start

extern squaring_matrix
extern print_matrix

_start:
    push side_len
    push matrix
    push return_matrix
    call squaring_matrix
    
    push side_len
    push return_matrix
    call print_matrix

    mov rax, 1
    mov rbx, 0
    int 0x80    
