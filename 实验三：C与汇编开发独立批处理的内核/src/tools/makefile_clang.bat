nasm -f elf32 %1.asm -o %1ASM.o
clang.exe -c -target i386-pc-linux-elf -fno-common -fno-zero-initialized-in-bss -m16 %1.c -o %1C.o -std=c99
ld.lld -Ttext 0x100 ld.lds -o %1.tmp %1ASM.o %1C.o
objcopy -O binary %1.tmp %1.img