section .data
    file_error_message db "error: can't open file", 10, 0
    file_error_message_length equ $-file_error_message
 
section .text
    global ask_and_open

; Функция выводит приглашение prompt, затем считывает имя файла с stdin, и открывает его. В случаи ошибки завершает программу

; int __cdecl ask_and_open(int flags, char *prompt, int prompt_len);
ask_and_open:
    push ebp
    mov ebp, esp
    sub esp, 128+4+4*2 

    lea eax, [esp+4*3]
    mov dword [esp+4*2], eax
    add dword [esp], 4

    mov eax, 4
    mov ebx, 1
    mov ecx, [ebp+4*3]
    mov edx, [ebp+4*4]
    int 0x80

    lea eax, [esp+4*3]
    mov dword [esp+4], 127
    mov dword [esp], eax
    call read_name
    add esp, 4*2

    mov ebx, [esp]
    mov eax, 5 
    mov ecx, [ebp+4*2]
    mov edx, 420 ;-rw-r--r--
    int 0x80

    test eax, eax
    jl .error

.end:
    mov esp, ebp
    pop ebp
    ret

.error: 
    mov eax, 4
    mov ebx, 1
    mov ecx, file_error_message
    mov edx, file_error_message_length
    int 0x80

    mov eax, 1
    mov ebx, 1
    int 0x80


; Функция считывающая length байт с stdin в по указателю filename пока не встретит 0 или \n, и возвращает количество считанных байт. Важно заметить, что функция добавляет в конец 0. Поэтому при вызове read_name(name, 26) под name должно быть выделено > 26 байт.

; int __cdecl read_name(char * filename, int length);
read_name:
    push ebp
    mov ebp, esp
    sub esp, 4

    mov dword [esp], 0

.while:
    mov eax, 3
    mov ebx, 0
    mov ecx, [ebp+4*2]
    mov edx, 1
    int 0x80

    mov eax, dword [ebp+4*2]
    cmp byte [eax], 0
    je .end

    cmp byte [eax], 10
    je .end
    
    inc dword [esp]
    inc dword [ebp+4*2]

    mov eax, dword [ebp+4*3]
    cmp dword [esp], eax
    jl .while

.end:
    mov eax, dword [ebp +4*2]
    mov byte [eax], 0

    mov eax, dword [esp]

    mov esp, ebp
    pop ebp
    ret

