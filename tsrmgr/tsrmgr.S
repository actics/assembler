.code16

# уникальный номер программы
.set PROCESS_NUMBER, 0x88

.section .text
    jmp start_manager


# начало резидента
start_resident:

    # проверка на необходимость обработки прерывания
    cmpb  $PROCESS_NUMBER, %ah
    jne   next_handler

    movw  $0xdead, %ax
    movw  $0xbeef, %bx
    
    iret

next_handler:
    jmp *%cs:(0x80)
    ret # ЗАЧЕМ???


# начало менеджера резидента
start_manager:

    # устанавливаем значения необходимые для работы автомата
    movb  $0x00, %dl        # dl - состояние автомата
    movw  $0x81, %si        # si - указатель на текущеее положение в строке аргеументов
    movw  $letter_map, %bx  # bx - указатель на таблицу отображения символов
    movw  %es:(0x80),  %cx  # cl - длина строки аргументов

    # проверка на существование строки аргументов
    xorb  %ch,  %ch
    testb %cl,  %cl
    je    end_automato_loop

# основной цикл. Здесь работает алгоритм автомата
automato_loop:

    # берем символ из строки аргументов и сохраняем его номер из таблицы паереходов
    movb  %es:(%si), %al
    xlat
    push  %ax

    # рассчитываем строку в таблице переходов
    mov   $ALPHABET_CARDINALITY, %al
    mulb  %dl
    movw  %ax,   %di

    # получаем новое состояние
    pop   %ax
    addw  %ax,   %di
    movb  automato(%di), %dl

    # переходим на следующий символ в строке и залупливаемся
    incw  %si
    loop  automato_loop
end_automato_loop:

    # условный переход от конечного состояния
    cmp   $0x00,  %dl
    je    help_argumet_label

    cmp   $0x01,  %dl
    je    invalid_argumet_label

    cmp   $0x02,  %dl
    je    help_argumet_label

    cmp   $0x03,  %dl
    je    install_argumet_label

    cmp   $0x04,  %dl
    je    check_argumet_label

    cmp   $0x05,  %dl
    je    remove_argumet_label

    cmp   $0x06,  %dl
    je    invalid_argumet_label


# вывод ошибки: "передано более одного аргумента"
    movw  $more_one_argument_message, %dx
    movb  $0x09, %ah
    int   $0x21
    jmp   exit


# вывод ошибки: "неизвестный аргумент"
invalid_argumet_label:
    movw  $invalid_argument_message, %dx
    movb  $0x09, %ah
    int   $0x21
    jmp   exit


# вывод справки
help_argumet_label:
    movw  $help_message, %dx
    movb  $0x09, %ah
    int   $0x21

    jmp   exit


# установка резидента
install_argumet_label:

    # проверяем, есть ли уже резидент в системе
    call  check_resident
    je    install_fail
    
    # вывод сообщения о успешной установке резидента
    movb  $0x09,  %ah
    movw  $install_true_message, %dx
    int   $0x21

    call  install_resident

install_fail:

    # вывод сообщения о сбое установки резидента
    movb  $0x09,  %ah
    movw  $install_false_message, %dx
    int   $0x21

    jmp   exit


# проверка наличия резидента в системе
check_argumet_label:
    call check_resident
    jmp exit


# удаление резидента
remove_argumet_label:
    jmp   exit


# основная метка выхода
exit:
    movb  $0x4c,  %ah
    int   $0x21


# установить резидента на прерывание
# void install_resident();
install_resident:

    # записываем адрес резидента в таблицу прерываний
    movb  $0x25, %ah
    movb  $0x2f, %al
    movw  $start_resident, %dx
    int   $0x21

    # завершает программу и остается резидентом
    movb  $0x31, %ah
    movb  $0x00, %al
    movw  $0x30, %dx # количество параграфов под резидент
    int   $0x21


# проверяет наличие резидента в системе, выводит сообщение и изменяет регистр флагов.
# je => резидент присутствует
# check_resident();
check_resident:

    # сохраняем состояние системы
    push  %bx
    push  %dx

    # выводим вспомогательное сообщение
    movb  $0x09, %ah
    movw  $check_prefix_message, %dx
    int   $0x21

    # вызываем мультиплексное прерывание с кодом нашей программы
    movb  $PROCESS_NUMBER, %ah
    int   $0x2f

    # magic!
    cmp   $0xdead, %ax
    jne   check_false
    cmp   $0xbeef, %bx
    jne   check_false

    # выводим сообщение о успесном обнаружении резидента
    movb  $0x09, %ah
    movw  $check_true_message, %dx
    int   $0x21

    # сохраняем статуc "найдено"
    movb  $0x00, %al
    jmp   check_exit

check_false:
    # выводим сообщение о том, что резидента нет на месте
    movb  $0x09, %ah
    movw  $check_false_message, %dx
    int   $0x21

    # сохраняем статус "ненайдено"
    movb  $0x01, %al  

check_exit:
    # восстанавливаем состояние системы
    pop   %dx
    pop   %bx
    
    # устанавливаем флаги: je - найден, jne - не найден
    testb %al, %al
    ret


# функция печатающая hex представление регистра %al
# void __fastcall print_char_hex(char target_char)#
print_char_hex:

    # сохранение состояния системы
    push  %ax
    push  %bx
    push  %cx
    push  %dx
    
    # сохраняем адрес таблицы hex символов для использования с xlat
    movw  $hex_symbol, %bx

    # сохраняем обрабатываемое значение
    movb  %al,   %cl

    # совершаем сдвиг, взятие из hex-таблицы и вывод
    shrb  $0x04, %al
    xlat
    movb  %al,   %dl
    movb  $0x02, %ah
    int   $0x21

    # совершаем сопоставление с битовой маской, взятие из hex-таблицы и вывод
    movb  %cl,   %al
    andb  $0x0f, %al
    xlat
    movb  %al,   %dl
    movb  $0x02, %ah
    int   $0x21

    # восстанавливаем состояние системы
    pop   %dx
    pop   %cx
    pop   %bx
    pop   %ax

    ret


.section .data
    # мощность алфавита автомата
    .set ALPHABET_CARDINALITY, 0x07

    # таблица переходов автомата
    automato:
            # 0  1  2  3  4  5  6
            # -  h  i  c  r  _  *
        .byte 1, 6, 6, 6, 6, 0, 6 # 0
        .byte 6, 2, 3, 4, 5, 6, 6 # 1
        .byte 6, 6, 6, 6, 6, 7, 6 # 2 - h
        .byte 6, 6, 6, 6, 6, 7, 6 # 3 - i
        .byte 6, 6, 6, 6, 6, 7, 6 # 4 - c
        .byte 6, 6, 6, 6, 6, 7, 6 # 5 - r
        .byte 6, 6, 6, 6, 6, 6, 6 # 6 - invalid argument
        .byte 7, 7, 7, 7, 7, 7, 7 # 7 - more than one arguments

    help_message:
        .ascii "Usage: tsrmgr [options]\r\n" 
        .ascii "Options:\r\n"
        .ascii "  -h   print this help and exit\r\n"
        .ascii "  -i   install a tsr\r\n"
        .ascii "  -c   check presence this tsr in system\r\n"
        .ascii "  -r   remove tsr from system\r\n$" 

    install_true_message:
        .ascii "resident are installed\r\n$"

    install_false_message:
        .ascii "resident install fail\r\n$"

    check_prefix_message:
        .ascii "resident status: $"

    check_true_message:
        .ascii "installed\r\n$"

    check_false_message:
        .ascii "no found\r\n$"

    invalid_argument_message:
        .ascii "error: invalid argument$"

    more_one_argument_message:
        .ascii "error: send one argument$"

    # таблица hex-символов
    hex_symbol:
        .ascii "0123456789abcdef"

    # таблица отображающая ascii символы в номера 
    # для взятия значения в таблице переходов автомата
    letter_map:
        .rept 32
            .byte 6
        .endr

        .byte 5 # _

        .rept 12
            .byte 6
        .endr

        .byte 0 # -

        .rept 53
            .byte 6
        .endr

        .byte 3 # c

        .rept 4
            .byte 6
        .endr

        .byte 1 # h

        .byte 2 # i

        .rept 8
            .byte 6
        .endr

        .byte 4 # r

        .rept 141
            .byte 6
        .endr

