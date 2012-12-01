section .data
    read_error_message db "error: read from source", 10, 0
    read_error_message_length equ $-read_error_message

    write_error_message db "error: write to destination", 10, 0
    write_error_message_length equ $-write_error_message

    buffer_size equ 10 

section .text
    global copy_file

; void __cdecl copy_file(int file_source, int file_destination);
copy_file:
    push ebp 
    mov ebp, esp
    sub esp, buffer_size+4 

.while:
    mov eax, 3 
    mov ebx, [ebp+4*2] 
    mov ecx, esp 
    mov edx, buffer_size
    int 0x80 

    test eax, eax 
    je .end
    jl .read_error

    mov edx, eax 
    mov eax, 4 
    mov ebx, [ebp+4*3] 
    mov ecx, esp 
    int 0x80

    test eax, eax
    jl .write_error

    jmp .while

.end:
    mov esp, ebp 
    pop ebp
    ret

.read_error:
    mov ecx, read_error_message
    mov edx, read_error_message_length
    jmp .error

.write_error:
    mov ecx, write_error_message
    mov edx, write_error_message_length
    jmp .error
 
.error: 
    mov eax, 4
    mov ebx, 1
    int 0x80

    mov eax, 1
    mov ebx, 2
    int 0x80

