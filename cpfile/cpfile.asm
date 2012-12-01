section .data
    file_source_prompt db "enter a source file name: ", 0
    file_source_prompt_length equ $-file_source_prompt
    file_destination_prompt db "enter a destanation file name: ", 0
    file_destination_prompt_length equ $-file_destination_prompt

section .text
    extern ask_and_open
    extern copy_file

    global _start

_start:
    sub esp, 4*2+4*3 
    
    mov dword [esp+4*0], 0 ; O_RDONLY 
    mov dword [esp+4*1], file_source_prompt
    mov dword [esp+4*2], file_source_prompt_length
    call ask_and_open 

    mov dword [esp+4*3], eax 

    mov dword [esp+4*0], 577 ; O_WRONLY | O_TRUNC | O_CREAT 
    mov dword [esp+4*1], file_destination_prompt
    mov dword [esp+4*2], file_destination_prompt_length
    call ask_and_open

    mov dword [esp+4*4], eax
    
    mov eax, dword [esp+4*3]
    mov ebx, dword [esp+4*4]
    mov dword [esp+4], ebx
    mov dword [esp], eax
    call copy_file

    mov eax, 6 
    mov ebx, [esp+4*3]
    int 0x80

    mov eax, 6
    mov ebx, [esp+4*4]
    int 0x80
    
    mov eax, 1 
    mov ebx, 0 
    int 0x80

