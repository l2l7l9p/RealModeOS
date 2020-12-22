nasm -f elf32 %2.asm -o %2ASM.o
gcc -c -m32 -march=i386 -mpreferred-stack-boundary=2 -static %2.c -o %2C.o
gcc -c -m32 -march=i386 -mpreferred-stack-boundary=2 -static %1.c -o %1.o
ld3 --entry=_start -T ld.lds -o %1.tmp %1.o %2ASM.o %2C.o
objcopy -O binary %1.tmp %1.com