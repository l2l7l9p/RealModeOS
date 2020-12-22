BITS 16

extern _count
global _st

section .text

global _start
_start:
push 0
call _count				; call void () in C

mov dword ecx, eax		; output result,  result is in eax
xor cx, 48
mov ax, 0xB800
mov es, ax
mov [es:160*2], cl
mov byte [es:160*2+1], 0x7

call delay

ret

delay:
mov edi, 50000007
FOR_1: dec edi
jnz FOR_1
ret

section .data
st_content db 'asdjaklfafdsa\0'
_st dd st_content