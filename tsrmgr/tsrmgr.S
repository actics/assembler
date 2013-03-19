.code16

.org 0x100

.section .data
    letter_map:
        .rept 32
            .byte 6
        .endr

        .byte 5

        .rept 12
            .byte 6
        .endr

        .byte 0

        .rept 53
            .byte 6
        .endr

        .byte 3

        .rept 4
            .byte 6
        .endr

        .byte 1

        .byte 2

        .rept 8
            .byte 6
        .endr

        .byte 4

        .rept 141
            .byte 6
        .endr

    automato:
            # 0  1  2  3  4  5  6
            # -  h  i  c  r  _  *
        .byte 1, 6, 6, 6, 6, 0, 6 # 0
        .byte 6, 2, 3, 4, 5, 6, 6 # 1
        .byte 6, 6, 6, 6, 6, 7, 6 # 2 h
        .byte 6, 6, 6, 6, 6, 7, 6 # 3 i
        .byte 6, 6, 6, 6, 6, 7, 6 # 4 c
        .byte 6, 6, 6, 6, 6, 7, 6 # 5 r
        .byte 6, 6, 6, 6, 6, 6, 6 # 6 invalid argument
        .byte 7, 7, 7, 7, 7, 7, 7 # 7 more than one arguments

    help_message:
        .ascii "Usage: tsrmgr [options]\r\n" 
        .ascii "Options:\r\n"
        .ascii "  -h   print this help and exit\r\n"
        .ascii "  -i   install a tsr\r\n"
        .ascii "  -c   check presence this tsr in system\r\n"
        .ascii "  -r   remove tsr from system\r\n$" 

    invalid_argument_message:
        .ascii "tsrmgr: invalid argument$"

    more_one_argument_message:
        .ascii "tsrmgr: get one argument$"

    hex_symbol:
        .ascii "0123456789abcdef"

.section .text
    movb  %es:(0x80), %cl   # cl - string length
    
    movb  $0,    %dl        # dl - automato state
    movw  $0x81, %si        # si - string counter
    movw  $letter_map, %bx  # bx - letter map index
start_automato_loop:
    testb %cl, %cl
    je    end_automato_loop
    
    movb  %es:(%si), %al
    xlat
    push  %ax

    mov   $7,  %al
    mulb  %dl
    movw  %ax, %di

    pop   %ax
    addw  %ax, %di
    movb  automato(%di), %dl

    incw  %si
    decb  %cl
    jmp start_automato_loop

end_automato_loop:

    cmp $0,  %dl
    je  help_argumet_label

    cmp $1,  %dl
    je  invalid_argumet_label

    cmp $2,  %dl
    je  help_argumet_label

    cmp $3,  %dl
    je  install_argumet_label

    cmp $4,  %dl
    je  check_argumet_label

    cmp $5,  %dl
    je  remove_argumet_label

    cmp $6,  %dl
    je  invalid_argumet_label

    movw $more_one_argument_message, %dx
    movb $9, %ah
    int  $0x21
    jmp  exit

help_argumet_label:
    movw $help_message, %dx
    movb $9, %ah
    int  $0x21
    jmp  exit

install_argumet_label:

check_argumet_label:

remove_argumet_label:

invalid_argumet_label:
    movw $invalid_argument_message, %dx
    movb $9, %ah
    int  $0x21

exit:
    movb  $0x4c,  %ah
    int   $0x21


# void __fastcall print_char_hex(char target_char);
print_char_hex:
    push %ax
    push %bx
    push %cx
    push %dx

    movw $hex_symbol, %bx

    movb %al, %cl

    shrb $4,  %al
    xlat
    movb %al, %dl
    movb $2,    %ah
    int  $0x21

    movb %cl,   %al
    andb $0x0f, %al
    xlat
    movb %al, %dl
    movb $2,  %ah
    int  $0x21

    pop %dx
    pop %cx
    pop %bx
    pop %ax

    ret

