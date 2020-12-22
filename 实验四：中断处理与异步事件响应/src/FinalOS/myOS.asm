BITS 16

client_seg_addr equ 0x1800
int09h_seg_addr equ 0xf000
int09h_offset_addr equ 0xe987

extern _ker
global _char_askii
global _char_kb

section .text

global _start
_start:
	mov ax, 0
	mov gs, ax
	mov word [gs:0x20], HotWheel		; reset int 08h
	mov word [gs:0x22], cs
	sti
	push 0
	call _ker
	ret

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
	
	cli						; reset int 09h
	mov ax, 0
	mov gs, ax
	mov word [gs:0x24], Kbhit_OUCH
	mov word [gs:0x26], cs
	sti
	mov ax, client_seg_addr	; jmp to client
	mov ds, ax
	mov ss, ax
	mov byte [ds:0], 0xcb
	push cs
	push end_client
	push byte 0
	jmp client_seg_addr: 0x100
end_client:
	cli						; recover int 09h
	mov ax, 0
	mov gs, ax
	mov word [gs:0x24], int09h_offset_addr
	mov word [gs:0x26], int09h_seg_addr
	sti
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	o32 ret

HotWheel:
	push ds							; protection
	push es
	push ax
	push bx
	mov ax, cs						; reset ds=cs, es=0xb800
	mov ds, ax
	mov ax, 0xb800
	mov es, ax
	inc word [delaycnt]
	cmp word [delaycnt], 100
	jnz End
	mov word [delaycnt], 0			; reset delaycnt
	inc byte [wheelcnt]
	and byte [wheelcnt], 3			; wheelcnt = wheelcnt mod 4
	movzx bx, byte [wheelcnt]		; cl = wheel[wheelcnt]
	mov byte al, [wheel+bx]
	mov byte [es:(23*80+79)*2], al	; print wheel
	mov byte [es:(23*80+79)*2+1], 0x7
End:
	mov al, 0x20					; tell 8259 that we finished
	out 0x20, al
	pop bx
	pop ax
	pop es
	pop ds
	iret							; interrupt return

Kbhit_OUCH:
	push ds							; protection
	push es
	push ax
	push bx
	push edi
	pushf							; to clear buffle
	call int09h_seg_addr:int09h_offset_addr
	mov ax, cs						; reset ds=cs, es=0xb800
	mov ds, ax
	mov ax, 0xb800
	mov es, ax
	mov bx, 10
	For1:							; print ouch
		mov al, byte [ouch+bx-1]
		mov di, bx
		imul di, 2
		mov byte [es:(10*80+34)*2+di], al
		mov byte [es:(10*80+34)*2+di+1], 0x40
		dec bx
		jnz For1
	call delay
	mov bx, 10
	For2:
		mov di, bx
		imul di, 2
		mov byte [es:(10*80+34)*2+di], 0
		mov byte [es:(10*80+34)*2+di+1], 0x7
		dec bx
		jnz For2
	mov al, 0x20
	out 0x20, al
	pop edi
	pop bx
	pop ax
	pop es
	pop ds
	iret
	delay:
		mov edi, 10000007
		FOR_1: dec edi
		jnz FOR_1
		ret

section .data
	_char_askii db 0
	_char_kb db 0
hotwheel_data:
	wheel db '-\|/'
	wheelcnt db 0
	delaycnt dw 0
kbhit_OUCH_data:
	ouch db 'ouch!ouch!'