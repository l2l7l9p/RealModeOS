BITS 16

section .text

global _putchar
_putchar:
	mov ax, [esp+4]
	mov ah, 0
	int 21h
	o32 ret

global _getchar
_getchar:
	mov ah, 1
	int 21h
	movzx eax, al
	o32 ret

global _getch
_getch:
	mov ah, 2
	int 21h
	movzx eax, al
	o32 ret