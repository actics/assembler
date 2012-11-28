; nasm on linux 32-bit
; Alexander Lavrukov. USU, CS-302. November 2012.

section .data
    text db "i love my mommy"
    text_length equ $-text
    accumulator times 256 db 0 ; массив частот
    
section .bss
    number      resb 15  ; массив, хранящий строку вывода

section .text

global _start
_start:

; Расчет частот.
    mov  ecx, text_length ; счетчк цикла
    mov  edx, text        ; указатель на элемент массива (его будем сдвигать)
again:
    xor  ebx, ebx         ; обнуление
    mov  bl, byte [edx]   ; считываем символ в bl (сдвиг в АМ)
    add  ebx, accumulator ; теперь в ebx хранится адрес на необходимый элемент в АМ
    inc  byte [ebx]       ; увеличиваем частоту
    inc  edx              ; сдвигаемся на следующий символ в тексте
    loop again

; Подготавливаем user-friendly вывод
    mov  [number+1], byte ' '
    mov  [number+2], byte '-'
    mov  [number+3], byte ' '

    mov  edi, -1 ; счетчик обозначающий символ в массиве
    
next_symbol:
    inc  edi
    cmp  edi, 256
    je   exit

    xor  eax, eax
    mov  ebx, accumulator
    add  ebx, edi         ; ссылка на астоту символа edi
    mov  al, byte [ebx]   ; кладем делимое
    test eax, eax         ; если ноль - следующий символ
    je   next_symbol

; Разложение челого числа на массив цифр. Сохраняем в стек.    

    xor  ecx, ecx
    mov  ebx, 10  ; делитель (2х байтовое деление)
next_num:
    xor  edx, edx ; используется как начало делимого
    div  ebx      ; делим
    push edx      ; сохраняем результат в стеке
    inc  ecx      ; увеличиваем количество символов в стеке
    test eax, eax ; когда число кончается - выходим
    jne  next_num
    
; достаем цифры из стека и записываем их в память на вывод
    mov  eax, edi      ; кладем текущий символ в начало массива
    mov  [number], al
    mov  edx, number+4 ; прыгаем через " - "
reverse:
    pop  eax
    add  eax, '0'   ; приводим цифру к символу
    mov  [edx], eax ; кладем в память на вывод
    inc  edx        ; сдвигаемся на следующий элемент
    loop reverse    ; ecx был заполнен при разделении числа

    mov  [edx], byte 10

    mov  eax, 4        ; sys_write 
    mov  ebx, 1        ; stdout
    mov  ecx, number   ; указатель на начало вывода
    sub  edx, number-1 ; получаем длину из известного конца
    int  0x80

    jmp  next_symbol
    
exit:
    mov  eax, 1 ; sys_exit
    mov  ebx, 0
    int  0x80
