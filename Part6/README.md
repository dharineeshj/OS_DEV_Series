# Part 5 – Implementing FAT12 Boot Sector

In the previous part, we created our first bootloader and learned how the BIOS loads and executes it. In this part, we take the first step towards supporting a real file system by implementing a **FAT12-compatible boot sector**.

This boot sector is still capable of booting and printing a message, but unlike the previous version, it now contains a valid **BIOS Parameter Block (BPB)** and **Extended Boot Record (EBR)** so that the floppy image is recognized as a FAT12 formatted disk.

## What this project demonstrates

- Writing a valid FAT12 boot sector
- Understanding the BIOS Parameter Block (BPB)
- Understanding the Extended Boot Record (EBR)
- Creating a bootable FAT12 floppy image
- Printing text using BIOS interrupt `INT 10h`
- Building and running the bootloader using NASM and QEMU

## Project Structure

```
Part5/
├── build/
├── src/
│   └── bootloader/
│       └── bootloader.asm
├── makefile
├── run.sh
└── README.md
```

## Boot Sector Layout

The boot sector consists of the following components:

```
+-----------------------------+
| Jump Instruction            |
+-----------------------------+
| BIOS Parameter Block (BPB)  |
+-----------------------------+
| Extended Boot Record (EBR)  |
+-----------------------------+
| Bootloader Code             |
+-----------------------------+
| Boot Signature (0xAA55)     |
+-----------------------------+
```

### Jump Instruction

The first three bytes of every FAT boot sector must contain a jump instruction.

```asm
jmp _start
nop
```

The BIOS begins executing code from the first byte of the boot sector. Since the BIOS Parameter Block is data rather than executable instructions, we jump over it and continue execution at `_start`.

---

### BIOS Parameter Block (BPB)

The BIOS Parameter Block describes the physical layout of the FAT12 file system.

Some important fields include:

| Field | Description |
|--------|-------------|
| Bytes Per Sector | Size of each sector (512 bytes) |
| Sectors Per Cluster | Number of sectors in one cluster |
| Reserved Sectors | Reserved sectors before the FAT |
| Number of FATs | Number of FAT tables (usually 2) |
| Root Entries | Maximum entries in the root directory |
| Total Sectors | Total sectors in the floppy disk |
| Sectors Per FAT | Size of each FAT |
| Heads Per Cylinder | Number of disk heads |
| Sectors Per Track | Number of sectors in one track |

These values allow both the BIOS and operating systems to understand the disk layout.

---

### Extended Boot Record (EBR)

The Extended Boot Record stores additional information about the file system, including:

- Drive number
- Boot signature
- Volume serial number
- Volume label
- File system type

These fields are mainly informational and help operating systems identify the disk.

---

### Bootloader

After jumping over the BPB and EBR, execution reaches the bootloader.

The bootloader prints the following message using BIOS interrupt `INT 10h`:

```
Hello World
```

Each character is printed individually using BIOS teletype mode (`AH = 0x0E`).

---

### Boot Signature

Every bootable disk must end with the signature

```
0xAA55
```

This signature occupies the last two bytes of the first sector.

```asm
times 510-($-$$) db 0
dw 0xAA55
```

Without this signature, the BIOS will not recognize the sector as bootable.

---

## Building

Assemble the bootloader using

```bash
make
```

or

```bash
nasm -f bin src/bootloader/bootloader.asm -o build/bootloader.bin
```

---

## Running

Run the floppy image using QEMU

```bash
./run.sh
```

or

```bash
qemu-system-i386 -fda build/main_floppy.img
```

---

## Expected Output

```
Hello World
```

---

## What You'll Learn

- Structure of a FAT12 boot sector
- BIOS Parameter Block (BPB)
- Extended Boot Record (EBR)
- FAT12 disk metadata
- BIOS text output using `INT 10h`
- Boot sector layout
- Why every FAT12 boot sector begins with a jump instruction

---

## Next Step

In the next section, we'll start implementing the **FAT12 file system** itself.

We'll learn:

- What the File Allocation Table (FAT) is
- How clusters are chained together
- How the Root Directory stores file information
- How to locate and read files from the floppy disk
- Reading a file from the FAT12 data area using BIOS disk services

By the end of the next chapter, our bootloader will no longer just print text—it will be capable of locating and loading files from a FAT12-formatted floppy disk.