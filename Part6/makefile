BOOT_SRC=src/bootloader/bootloader.asm
KER_SRC=src/kernel/main.asm

BOOT_BIN=build/bootloader.bin
KER_BIN=build/kernel.bin
FLOPPY_IMG=build/floppy.img

CC16=/usr/bin/watcom/binl/wcc
CFLAGS16=-s -ms -zl -zq
LD16=/usr/bin/watcom/binl/wlink

all: always floppy

floppy: $(BOOT_BIN) $(KER_BIN)
	dd if=/dev/zero of=$(FLOPPY_IMG) bs=512 count=2880
	mkfs.fat -F 12 -n "NBOS" $(FLOPPY_IMG)
	dd if=$(BOOT_BIN) of=$(FLOPPY_IMG) conv=notrunc
	mcopy -i $(FLOPPY_IMG) $(KER_BIN) "::KERNEL.BIN"

$(BOOT_BIN): $(BOOT_SRC)
	nasm -f bin $< -o $@

$(KER_BIN): $(KER_SRC)
	nasm -f bin $< -o $@

always:
	mkdir -p build
	mkdir -p build/kernel
	mkdir -p build/kernel/asm
	mkdir -p build/kernel/c