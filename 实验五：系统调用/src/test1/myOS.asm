BITS 16

client_seg_addr equ 0x1800

extern _ker
extern _tmpCpuState
global _char_askii
global _char_kb

section .text

global _start
_start:
	mov ax, 0
	mov gs, ax
	mov word [gs:0x20], HotWheel	; reset int 08h
	mov word [gs:0x22], cs
	sti
	push 0
	call _ker
	ret

global _Put						; print a single char
_Put:
	mov ax, [esp+4]
	mov bl, 0x07
	mov ah, 0xe
	int 10h
	o32 ret

global _Getchar					; read a single char
_Getchar:
	mov ah, 0					; function: input from keyboard
	int 16H						; interrupt
	mov [_char_askii], al
	mov [_char_kb], ah
	o32 ret

global _load_client
_load_client:
	mov ax, client_seg_addr
	mov es, ax
	mov bx, 0x100				; position : 0x1800:0x0000
	mov al, 1					; number of sectors to load
	mov dl, 0					; 驱动器号 ; 软盘为0，硬盘和U盘为80H
	mov dh, 0					; 磁头号 ; 起始编号为0
	mov cx, [esp+4]				; cl : sector num
	mov ch, 0					; 柱面号 ; 起始编号为0
	mov ah, 0x02				; function: read
	int 13H						; interrupt
jmp_to_client:
	mov [os_sp], sp				; set new ds, ss, sp
	mov sp, 0xffff
	mov ax, client_seg_addr
	mov ds, ax
	mov ss, ax
	mov byte [ds:0], 0xcb		; retf
	push cs
	push end_client
	push byte 0
	jmp client_seg_addr: 0x100	; jmp to client
end_client:
	mov ax, cs
	mov ds, ax
	mov ss, ax
	mov word sp, [os_sp]
	o32 ret

HotWheel:
	call save
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
	movzx bx, byte [wheelcnt]		; al = wheel[wheelcnt]
	mov byte al, [wheel+bx]
	mov byte [es:(23*80+79)*2], al	; print wheel
	mov byte [es:(23*80+79)*2+1], 0x7
End:
	mov al, 0x20					; tell 8259 that we finished
	out 0x20, al
	jmp restart

save:								; protection
	push eax
	push ds
	mov ax, cs						; use OS's ds
	mov ds, ax
	pop ax							; ax=ds
	mov [_tmpCpuState+34], ax
	pop eax
	mov [_tmpCpuState], eax
	mov [_tmpCpuState+4], ebx
	mov [_tmpCpuState+8], ecx
	mov [_tmpCpuState+12], edx
	mov [_tmpCpuState+16], ebp
	mov [_tmpCpuState+20], edi
	mov [_tmpCpuState+24], esi
	pop bx							; bx=ip after 'call save'
	pop ax							; ax=ip
	mov [_tmpCpuState+28], ax
	pop ax							; ax=cs
	mov [_tmpCpuState+30], ax
	pop ax							; ax=flags
	mov [_tmpCpuState+32], ax
	mov [_tmpCpuState+36], es
	mov [_tmpCpuState+38], ss
	mov [_tmpCpuState+40], sp
	mov ax, cs						; use OS's stack
	mov ss, ax
	mov sp, [os_sp]
	jmp bx

restart:
	mov eax, [_tmpCpuState]
	mov ebx, [_tmpCpuState+4]
	mov ecx, [_tmpCpuState+8]
	mov edx, [_tmpCpuState+12]
	mov ebp, [_tmpCpuState+16]
	mov edi, [_tmpCpuState+20]
	mov esi, [_tmpCpuState+24]
	mov [os_sp], sp
	mov es, [_tmpCpuState+36]
	mov ss, [_tmpCpuState+38]
	mov sp, [_tmpCpuState+40]
	push word [_tmpCpuState+32]		; flags
	push word [_tmpCpuState+30]		; cs
	push word [_tmpCpuState+28]		; ip
	mov ds, [_tmpCpuState+34]
	iret

section .data
	_char_askii db 0
	_char_kb db 0
	os_sp dw 0
hotwheel_data:
	wheel db '-\|/'
	wheelcnt db 0
	delaycnt dw 0