[bits 64]
[default rel]

global init_module
global cleanup_module

extern printk
extern request_threaded_irq
extern synchronize_irq
extern free_irq

%define IRQ_NUM 1

section .data
    init_success_mess db "Successfully loading ISR handler on IRQ %d", 10, 0
    init_error_mess   db "Error in loading ISR handler on IRQ %d", 10, 0
    exit_mess         db "Successfully unloading ISR handler on IRQ %d. IRQ counter = %d", 10, 0
    int_mess          db "Interrupt seccessfully processed. IRQ counter = %d", 10, 0
    int_name          db "Actics_keyboard_handler", 0
    
section .bss
    my_dev_id   resd 1
    irq         resd 1
    irq_counter resd 1
    
section .text

init_module:
    mov dword [irq], IRQ_NUM
    mov dword [irq_counter], 0
    
    xor rax, rax
    mov edi, dword [irq]
    mov rsi, interrupt_handler
    mov rdx, 0
    mov rcx, 0x80
    mov r8, int_name
    mov r9,  my_dev_id
    call request_threaded_irq
    
    test rax, rax
    jne .error_exit
       
    xor rax, rax
    mov esi, dword [irq]
    mov rdi, init_success_mess
    call printk
    
    xor rax, rax
    jmp .exit
    
.error_exit:
    xor rax, rax
    mov esi, dword [irq]
    mov rdi, init_error_mess
    call printk
    
    mov rax, -1
    jmp .exit
    
.exit:
    ret

cleanup_module:
    xor rax, rax
    mov edi, dword [irq]
    call synchronize_irq
    
    xor rax, rax
    mov rsi, my_dev_id
    mov edi, dword [irq]
    call free_irq
    
    xor rax, rax
    mov edx, dword [irq_counter]
    mov esi, dword [irq]
    mov rdi, exit_mess
    call printk

    xor rax, rax
    ret

interrupt_handler:
    inc dword [irq_counter]

    xor rax, rax
    mov esi, dword [irq_counter]
    mov rdi, int_mess
    call printk

    xor rax, rax
    ret

