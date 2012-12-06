[bits 64]

global _start

extern printf
extern atof

section .data
    first_left   dq -10.0
    first_right  dq -1.0
    second_left  dq -1.0
    second_right dq  1.0
    third_left   dq  1.0
    third_right  dq  10.0

    first_mess  db "You argument from first domain[%lf, %lf].", 10, "Return value is %f", 10, 0
    second_mess db "You argument from second domain[%lf, %lf].", 10, "Return value is %f", 10, 0
    third_mess  db "You argument from third domain[%lf, %lf].", 10, "Return value is %f", 10, 0
    float_format db "%lf", 10, 0
    argc_error_mess db "Take x value in first argument", 10, 0
    interval_error_mess db "You argument doesn't in domains", 10, 0

    a dq 2.0
    b dq 3.0

section .bss
    ret_fl resq 1

section .text

_start:
    mov rbp, rsp
    sub rsp, 0x20

    cmp qword [rbp], 2
    jl .argc_error

    xor rax, rax
    mov rdi, [rbp+8*2]
    call atof

    movsd qword [rsp], xmm0
    fld qword [rsp]
    
    mov rbx, first_left
    mov rcx, first_right
    call in_interval
    
    test rax, rax
    jne .first

    mov rbx, second_left
    mov rcx, second_right
    call in_interval
    
    test rax, rax
    jne .second

    mov rbx, third_left
    mov rcx, third_right
    call in_interval
    
    test rax, rax
    jne .third

    mov rdi, interval_error_mess
    jmp .error_print

.first:
    call first

    mov rcx, rax
    movsd xmm0, qword [first_left]
    movsd xmm1, qword [first_right]
    movsd xmm2, qword [ret_fl]
    mov rdi, first_mess
    mov rax, 3
    call printf
    
    xor rdi, rdi
    jmp .exit

.second:
    call second

    mov rcx, rax
    movsd xmm0, qword [second_left]
    movsd xmm1, qword [second_right]
    movsd xmm2, qword [ret_fl]
    mov rdi, second_mess
    mov rax, 3
    call printf
    
    xor rdi, rdi
    jmp .exit

.third:
    call third

    mov rcx, rax
    movsd xmm0, qword [third_left]
    movsd xmm1, qword [third_right]
    movsd xmm2, qword [ret_fl]
    mov rdi, third_mess
    mov rax, 3
    call printf
    
    xor rdi, rdi
    jmp .exit


.argc_error:
    mov rdi, argc_error_mess
    jmp .error_print

.error_print:
    xor rax, rax
    call printf
    
    mov rdi, 1
    jmp .exit

.exit:
    mov rax, 60
    syscall


in_interval:
    xor rax, rax

    fld qword [rbx]
    fcomip
    ja .exit 
    
    fld qword [rcx]
    fcomip
    jb .exit

    mov rax, 1

.exit:
    ret

first:      ;sin(ax^2-b)
    fld st0
    fld st0
    fmulp
    fld qword [a]
    fmulp
    fld qword [b]
    fsubp
    fsin
    fstp qword [ret_fl]
    ret

second:     ; |x|/tg(x)
    fld st0
    fabs
    fld st1
    fptan
    fstp st0
    fdivp
    fstp qword [ret_fl]
    ret

third:      ; sin(x)*cos(x)
    fld st0
    fsincos
    fmulp
    fstp qword [ret_fl]
    ret
