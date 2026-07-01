org 0x7c00
bits 16

jmp short start                 ; since the first of the disk is loaded into the memory cpu tries to execute the first line of the code if it is not an instruction the program will crash
nop

;; OEM Parameter Block ;;

bpb_oem db "MSWIN4.1"           ; OEM identifier
bpbBytesPerSector dw 512        ; size of each sector
bpbSectorsPerCluster db 1       ; number of sectors per cluster
bpbReservedSectors dw 1         ; number of reserved sectors 
bpbNumberofFATs db 2            ; number of file allocation table
bpbRootEntries dw 224           ; number of directories it can held with in the root directory
bpbTotalSectors dw 2880         ; number of sectors in the floppy disk 
bpbMedia db 0xF0                ; Byte that contains information about the disk
bpbSectorPerFat dw 9            ; number of sectors per fat
bpbSectorsPerTrack dw 18        ; number of sectors per cylinder
bpbHeadsPerCylinder dw 2        ; number of heads per cylinder
bpbHiddenSectors dd 0           ; number of hidden sectors
bpbTotalSectorsBig dd 0         ; large sector count

bsDriveNumber db 0              ; driver number
bsUnused db 0
bsExtBootSignature db 0x29      ; boot signature
bsSerialNumber dd 0xa0a1a2a3
bsVolumeLabel db "MOS FLOPPY "
bsFileSystem db "FAT12 "

;; ;;

start:
    mov [bsDriveNumber],dl

    xor ax,ax
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov sp,0x7c00
    

    ;4 segments
    ;reserved segment: 1 sector
    ;FAT:  number_of_fat * segments_of_each_fat
    ;Root: number_of_dir * 32
    ;Data

    mov ax, [bpbSectorPerFat]
    mov bl, [bpbNumberofFATs]
    xor bh,bh
    mul bx
    ADD ax,[bpbReservedSectors] ; LBA of the root directory
    push ax

    mov ax,[bpbRootEntries]
    shl ax,5 ; mul ax,32
    xor dx,dx 
    div word [bpbBytesPerSector] ; ax contains the number of sectors in root

    test dx,dx
    jz rootDirAfter
    inc ax

rootDirAfter:
    mov cl,al                   
    pop ax
    mov dl,[bsDriveNumber]
    mov bx,buffer
    call read_from_disk

    xor bx,bx
    mov di,buffer
    
searchKernel:

    mov si,file_kernal_bin ; name of the kernel code
    mov cx,11 ; len of kernel block name 
    push di
    repe cmpsb  ; assembly string function
    pop di
    je foundKernel

    add di,32
    inc bx
    cmp bx,[bpbRootEntries]
    jl searchKernel

    jmp kernelNotFound

kernelNotFound:
    mov si,msg_kernel_not_found
    call puts

    hlt 
    jmp halt

foundKernel:

    ; getting the first cluster of the kernel from the root directory
    mov ax,[di+26]
    mov [kernel_cluster],ax

loading_FAT:
    ; loading the file allocation table in the buffer
    mov ax,[bpbReservedSectors]
    mov bx,buffer
    mov cl,[bpbSectorPerFat]
    mov dl,[bsDriveNumber]

    call read_from_disk

    ; setting memory address for the kernel to load
    mov bx,kernel_load_segment
    mov es,bx
    mov bx,kernel_load_offset

loadKernelLoop:
    ; reading the sectors from the disk one by one

    mov ax,[kernel_cluster] ; loading the current cluster number
    add ax,31               ; adding 31 instead of 33 because FAT cluster starts with 2. this is to get the sector number
    mov cl,1
    mov dl,[bsDriveNumber]

    call read_from_disk   

    add bx,[bpbBytesPerSector]  ; moving next 512 bytes of address

    mov ax,[kernel_cluster] ; kernel cluster*(3/2) or 1.5 
    mov cx,3
    mul cx
    mov cx,2
    div cx

    ; reading the next cluster number of the kernel
    mov si,buffer
    add si,ax
    mov ax,[ds:si]

    or dx,dx
    jz even

odd:
    shr ax,4
    jmp nextClusterAfter

even:
    and ax,0x0fff
    jmp nextClusterAfter

nextClusterAfter:
    
    cmp ax,0x0ff8
    jae readFinish

    MOV [kernel_cluster],ax
    jmp loadKernelLoop

readFinish:
    mov dl,[bsDriveNumber]
    mov ax,kernel_load_segment
    mov ds,ax
    mov es,ax

    jmp kernel_load_segment:kernel_load_offset
    
    hlt

halt:
    jmp halt 

; input: LBA index in ax
; cx [bits 0-5]: sector number
; cx [bits 6-15]: cylinder
; dh: head
; dl: driver number

lba_to_chs:

    push ax
    push dx

    ; sector = (LBA % SPT) + 1
    xor dx,dx
    div word [bpbSectorsPerTrack]
    inc dx
    mov cx, dx                  

    ; head = (LBA / SPT) % HPC
    xor dx, dx
    div word [bpbHeadsPerCylinder]
    mov dh, dl                  

    ; cylinder = (LBA / SPT) / HPC
    mov ch, al                 
    shl ah,6
    or cl,ah

    pop ax
    mov dl,al
    pop ax

    ret

read_from_disk:
    pusha

    call lba_to_chs
    mov di,3
    
retry:
    mov ah,0x02
    stc
    int 13h
    jnc success

    call diskRest

    dec di
    cmp di,0
    jne retry

fail:
    mov si,read_error_msg
    ret

diskRest:
    pusha
    mov ah,0
    stc
    int 0x13
    jc read_Error
    popa
    ret

success:
    popa

    clc
    ret

read_Error:
    mov si,read_error_msg
    call puts
    jmp halt

;; print function
puts:
    pusha
    puts_loop:

        mov al,BYTE [si]
        cmp al,0
        je puts_end

        mov ah,0x0e
        int 0x10

        inc si

        jmp puts_loop

    puts_end:
        popa
        ret

;; data section
message db "Operating system from scratch",0dh,0ah,0
read_error_msg db "Error while reading the disk",0dh,0ah,0
read_success_message db "Read successfull",0dh,0ah,0
file_kernal_bin db "KERNEL  BIN"
msg_kernel_not_found db "Kernel.bin not found",0ah,0dh,0
kernel_cluster dw 0

kernel_load_segment equ 0x2000
kernel_load_offset equ 0

;; padding 
times 510 - ($ - $$) db 0

;; End marker for the bootloader so that the bios will identify wheather it is an bootloader or not
dw 0xAA55

;; memory area 
buffer:

    