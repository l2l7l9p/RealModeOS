nasm -f elf32 %1.asm -o %1ASM.o
gcc -c -m32 -march=i386 -mpreferred-stack-boundary=2 -static %1.c -o %1C.o
ld3 --entry=_start -T ld.lds -o %1.tmp %1ASM.o %1C.o
objcopy -O binary %1.tmp %1.img