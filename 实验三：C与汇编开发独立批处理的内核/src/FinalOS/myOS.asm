BITS 16

client_seg_addr equ 0x1800

extern _ker
global _char_askii
global _char_kb

section .text

global _start
_start:
	push 0
	call _ker
	retf

global _Put					; print a single char
_Put:
	mov word ax, [esp+4]
	mov bl, 0x07
	mov ah, 0xe
	int 10h
	o32 ret

global _Getchar				; read a single char
_Getchar:
	mov ah, 0				; function: input from keyboard
	int 16H					; interrupt
	mov [_char_askii], al
	mov [_char_kb], ah
	o32 ret

global _load_client
_load_client:
	mov ax, client_seg_addr
	mov es, ax
	mov bx, 0x100			; position : 0x1800:0x0000
	mov al, 1				; number of sectors to load
	mov dl, 0				;驱动器号 ; 软盘为0，硬盘和U盘为80H
	mov dh, 0				;磁头号 ; 起始编号为0
	mov word cx, [esp+4]	; cl : sector num
	mov ch, 0				;柱面号 ; 起始编号为0
	mov ah, 0x02			; function: read
	int 13H					; interrupt
	mov ax, client_seg_addr
	mov ds, ax
	mov ss, ax
	call 0x1800: 0x100
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	o32 ret

section .data
	_char_askii db 0
	_char_kb db 0