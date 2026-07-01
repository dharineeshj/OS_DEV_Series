bits 16

start:
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

halt:
    jmp halt