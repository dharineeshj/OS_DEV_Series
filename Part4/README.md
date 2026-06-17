# NBOS - Operating System Development Series

A simple x86 operating system built from scratch as part of the **OS Development Series**.

This repository contains the source code developed throughout the series, starting from a simple 16-bit bootloader and gradually evolving into a complete operating system.

---

## Features

Current Features:

* 16-bit x86 Bootloader
* BIOS-based boot process
* FAT12 Floppy Image Support
* QEMU-based Testing Environment
* NASM Assembly Development
* Open Watcom 16-bit Toolchain Support

Planned Features:

* Kernel Development
* File System Support
* Memory Management
* Keyboard Driver
* Screen Driver
* Simple Shell
* Protected Mode
* Multitasking

---

## Development Environment

The project is developed on Linux using:

* NASM
* QEMU
* Open Watcom
* GNU Make

---

## Project Structure

```text
.
├── src
│   ├── bootloader
│   │   └── bootloader.asm
│   └── kernel
│       ├── main.asm
│       ├── main.c
│       ├── stdio
│       └── application
│
├── build
│   ├── floppy.img
│   ├── bootloader.bin
│   └── kernel.bin
│
├── MakeFile
├── run.sh
└── README.md
```

---

## Requirements

Install the required packages:

```bash
sudo apt update

sudo apt install \
    nasm \
    make \
    qemu-system-x86 \
    dosfstools \
    mtools
```

Install Open Watcom separately.

---

## Building

Build the operating system:

```bash
make
```

This will:

1. Assemble the bootloader.
2. Compile the kernel.
3. Create a FAT12 floppy image.
4. Copy the bootloader to the boot sector.
5. Copy the kernel into the floppy image.

---

## Running

Start the operating system using QEMU:

```bash
./run.sh
```

or

```bash
qemu-system-i386 -fda build/floppy.img -boot a
```

---

## Boot Process

```text
BIOS
  │
  ▼
Boot Sector (0x7C00)
  │
  ▼
Bootloader
  │
  ▼
Kernel
```

The BIOS loads the first sector of the floppy disk into memory at address:

```text
0x0000:0x7C00
```

and transfers execution to the bootloader.

---

## Series Progress

* [x] Development Environment Setup
* [x] First Bootloader
* [ ] Loading Kernel
* [ ] FAT12 Driver
* [ ] Memory Management
* [ ] Protected Mode
* [ ] Interrupt Handling
* [ ] Device Drivers
* [ ] Multitasking

---

## Learning Purpose

This project is intended for educational purposes and focuses on understanding how operating systems work internally, from the boot process to kernel development.

No frameworks.

No external operating system services.

Just the processor, memory, and our code.

---

## License

This project is licensed under the MIT License.