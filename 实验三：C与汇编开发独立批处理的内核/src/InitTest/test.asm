BITS 16

extern _sum
extern _c

section .text

global _start
_start:
push dword 0x2000000	; push args, a=3, b=2
push dword 0x3000000
push 0
call _sum				; call void sum() in C
pop ecx					; pop args
pop ecx					; pop args

mov ax, 0xB800			; output result
mov es, ax
mov dword ecx, [_c]		; result in ds:[c]
shr ecx, 24				; efficient bits are at most significant two bits
xor cx, 48
mov [es:160*2], cl
mov byte [es:160*2+1], 0x7

call delay

ret

delay:
mov edi, 50000007
FOR_1: dec edi
jnz FOR_1
ret