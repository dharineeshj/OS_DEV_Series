BOOT_SRC=src/bootloader/bootloader.asm
BOOT_BIN=build/bootloader.bin
FLOPPY_IMG=build/floppy.img

all: floppy boot.bin

floppy: boot.bin $(FLOPPY_IMG)
	dd if=/dev/zero of=$(FLOPPY_IMG) bs=512 count=2880
	mkfs.fat -F 12 -n "NBOS" $(FLOPPY_IMG)
	dd if=$(BOOT_BIN) of=$(FLOPPY_IMG) conv=notrunc

boot.bin: $(BOOT_SRC)
	nasm -f bin $< -o $(BOOT_BIN)