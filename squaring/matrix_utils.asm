section .data
    print_num db "%lld ", 0
    print_bn  db  10, 0

section .text

    global squaring_matrix
    global print_matrix

    extern printf

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;void __cdecl squaring_matrix(int64 **return_matrix, int64 **matrix, int64 side_len) {
;    for (int64 i=0; i<side_len; i++) {
;        for (int64 j=0; j<side_len; j++) {
;            int64 a = 0;
;            for (int64 k=0; k<side_len; k++)
;                a += matrix[i][k] * matrix[k][j];
;            return_matrix[i][j] = a;
;        }
;    }
;}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

squaring_matrix:
    push rbp
    mov rbp, rsp
    sub rsp, 0
    
    mov r15, [rbp+8*4]
    mov r14, [rbp+8*3]
    mov r13, [rbp+8*2]
    
    xor r8, r8   ; i
.for_i:
    xor r9, r9   ; j
    .for_j:
        xor r11, r11
        xor r10, r10 ; k
        .for_k:
            mov rcx, [r14+r8*8]
            mov rax, [rcx+r10*8]
            
            mov rcx, [r14+r10*8]
            mov rbx, [rcx+r9*8]
            
            imul rbx
            
            add r11, rax
            
            inc r10
            cmp r10, r15
            jl .for_k
            
        mov rbx, [r13+r8*8]
        lea rax, [rbx+r9*8]
        mov [rax], r11
        
        inc r9
        cmp r9, r15
        jl .for_j
        
    inc r8
    cmp r8, r15
    jl .for_i
    
    mov rsp, rbp
    pop rbp
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;void __cdecl print_matrix(int64 **matrix, int64 side_len) {
;    for (int64 i=0; i<side_len; ++i) {
;        for (it64 j=0; j<side_len; ++i)
;            printf("%d ", matrix[i][j]);
;        printf("\n");
;    }
;}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_matrix:
    push rbp
    mov rbp, rsp
    sub rsp, 0x10
    
    mov r15, [rbp+8*3]
    mov r14, [rbp+8*2]
    
    mov qword [rsp], 0
.for_i:
    mov qword [rsp+8], 0
    .for_j:
        mov rax, [rsp]
        mov rbx, [r14 + rax*8]
        mov rax, [rsp+8]
        mov rsi, [rbx + rax*8]
        mov rdi, print_num
        xor rax, rax
        call printf
        
        inc qword [rsp+8]
        cmp qword [rsp+8], r15
        jl .for_j
        
    mov rdi, print_bn
    xor rax, rax
    call printf
    
    inc qword [rsp]
    cmp qword [rsp], r15
    jl .for_i
    
    mov rsp, rbp
    pop rbp
    ret

