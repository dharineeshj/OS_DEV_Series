org 0x7c00

jmp _start


_start:
    mov si, print_text

.print_loop:
    lodsb               
    cmp al, 0
    je .halt

    mov ah, 0x0E              
    int 0x10

    jmp .print_loop

.halt:
    cli
    hlt

print_text db "Hello World", 0x0D, 0x0A, 0
times 510-($-$$) db 0
dw 0xAA55