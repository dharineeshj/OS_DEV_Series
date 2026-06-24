org 0x7c00
bits 16

jmp _start                 

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