BITS 16

MAXPRO equ 10

section .text

; **************** start ***********

extern _ker
global _start
_start:
	mov ax, 0
	mov gs, ax
	mov word [gs:0x20], Timer		; reset int 08h
	mov word [gs:0x22], cs
	mov word [gs:0x80], end_client	; reset int 20h
	mov word [gs:0x82], cs
	mov word [gs:0x84], server		; reset int 21h
	mov word [gs:0x86], cs
	sti
	push 0
	call _ker
	ret

; **************** basic IO for OS ***********

global _Put						; print a single char
_Put:
	mov ax, [esp+4]
	mov bl, 0x07
	mov ah, 0xe
	int 10h
	o32 ret

global _char_askii
global _char_kb
global _Getchar					; read a single char
_Getchar:
	mov ah, 0					; function: input from keyboard
	int 16H						; interrupt
	mov [_char_askii], al
	mov [_char_kb], ah
	o32 ret

; **************** function: load_client ***********

global _load_client
_load_client:
	mov ax, [esp+4]				; memory seg_addr
	mov es, ax
	mov bx, [esp+8]				; memory offset
	mov ax, [esp+12]
	add ax, 31					; sec id = i+31
	mov dx, ax
	mov ch, 36
	div ch
	mov ch, al					; ch=id/36: 柱面号 起始编号为0
	mov ax, dx
	mov dh, 18
	div dh
	mov dh, al
	and dh, 1					; dh=(id/18)&1 : 磁头号 起始为0
	mov cl, ah					; cl=id mod 18 : sector num
	add cl, 1
	mov dl, 0					; dl : 驱动器号 ; 软盘为0，硬盘和U盘为80H
	mov al, 1					; number of sectors to load
	mov ah, 0x02				; function: read
	int 13H						; interrupt
	o32 ret

global _client_preparation
_client_preparation:
	mov ax, [esp+4]
	mov es, ax
	mov word [es:0], 0x20cd		; int 20h
	mov dword [es:0x7ffb], 0	; push dword 0
	o32 ret

; **************** function: read FAT & dir ***********

fat_offset_addr equ 0x8000
dir_offset_addr equ 0xA000

global _next_cluster
_next_cluster:
	mov cx, [esp+4]
	mov ax, 0
	mov es, ax
	mov di, cx					; di = fat[curClu*3/2]
	imul di, 3
	shr di, 1
	add di, fat_offset_addr
	and cx, 1
	jz cx_is_even
	cx_is_odd:
		mov dh, [es:di+1]
		shr dx, 4
		mov cl, [es:di]
		shr cl, 4
		or dl, cl
		jmp cx_end
	cx_is_even:
		mov dl, [es:di]
		mov dh, [es:di+1]
		and dh, 15
	cx_end:
	movzx eax, dx
	o32 ret

global _read_dir
extern _dirEnt
_read_dir:
	mov ax, 0
	mov es, ax
	mov di, [esp+4]				; di = rootDir[i]
	shl di, 5
	add di, dir_offset_addr
	mov bx, 0
	_read_dir_for:
		mov ah, [es:di+bx]
		mov [_dirEnt+bx], ah
		add bx, 1
		cmp bx, 32
		jnz _read_dir_for
	o32 ret

; **************** interrupt ***********

; *** int 20h ***

extern _ProSchedule
end_client:
	pop ax							; pop ip
	pop ax							; pop cs
	pop ax							; pop flags
	mov ax, cs						; recover OS's ds, stack
	mov ds, ax
	mov ss, ax
	mov sp, [os_sp]
	mov bp, [os_bp]
	mov ebx, [_curPid]				; bx = &proList[curPid]
	imul bx, 56
	add bx, _proList
	mov byte [ds:bx+55], 0			; set PCB state to 0--empty
	push word 0
	call _ProSchedule				; check if client processes exist
	cmp dword [_curPid], MAXPRO
	jnz _restart
	o32 ret

; *** int 08h ***

Timer:
	call save
	HotWheel:
		mov ax, 0xb800
		mov es, ax
		inc word [delaycnt]
		cmp word [delaycnt], 100
		jnz Call_ProSchedule
		mov word [delaycnt], 0			; reset delaycnt
		inc byte [wheelcnt]
		and byte [wheelcnt], 3			; wheelcnt = wheelcnt mod 4
		movzx bx, byte [wheelcnt]		; al = wheel[wheelcnt]
		mov byte al, [wheel+bx]
		mov byte [es:(23*80+79)*2], al	; print wheel
		mov byte [es:(23*80+79)*2+1], 0x7
	Call_ProSchedule:
		cmp dword [_curPid], MAXPRO		; if no client process, exit
		jz Timer_End
		push word 0
		call _ProSchedule
Timer_End:
	mov al, 0x20						; tell 8259 that we finished
	out 0x20, al
	jmp _restart

extern _proList
extern _curPid

save:								; protection
	push ebx
	push eax
	push ds
	mov ax, cs						; use OS's ds
	mov ds, ax
	mov ebx, [_curPid]				; bx = &proList[curPid]
	imul bx, 56
	add bx, _proList
	pop ax							; ax=ds
	mov [ds:bx+34], ax
	pop eax
	mov [ds:bx], eax
	pop eax							; eax=ebx
	mov [ds:bx+4], eax
	mov [ds:bx+8], ecx
	mov [ds:bx+12], edx
	mov [ds:bx+16], ebp
	mov [ds:bx+20], edi
	mov [ds:bx+24], esi
	pop cx							; cx=ip after 'call save'
	pop ax							; ax=ip
	mov [ds:bx+28], ax
	pop ax							; ax=cs
	mov [ds:bx+30], ax
	pop ax							; ax=flags
	mov [ds:bx+32], ax
	mov [ds:bx+36], es
	mov [ds:bx+38], ss
	mov [ds:bx+40], sp
	mov byte [ds:bx+55], 2			; set PCB state to 2--ready
	mov ax, cs						; use OS's stack
	mov ss, ax
	mov sp, [os_sp]
	mov bp, [os_bp]
	jmp cx

global _restart
_restart:
	mov ebx, [_curPid]				; bx = &proList[curPid]
	imul bx, 56
	add bx, _proList
	mov eax, [ds:bx]
	mov ecx, [ds:bx+8]
	mov edx, [ds:bx+12]
	mov [os_bp], bp
	mov ebp, [ds:bx+16]
	mov edi, [ds:bx+20]
	mov esi, [ds:bx+24]
	mov es, [ds:bx+36]
	mov ss, [ds:bx+38]
	mov [os_sp], sp
	mov sp, [ds:bx+40]
	push word [ds:bx+32]			; flags
	push word [ds:bx+30]			; cs
	push word [ds:bx+28]			; ip
	push word [ds:bx+34]			; ds
	mov byte [ds:bx+55], 1			; set PCB state to 1--running
	mov ebx, [ds:bx+4]
	pop ds
	iret

; *** int 21h ***

extern _GetFirstOfBuf
server:
	cli
	push ds							; simple protection
	mov dx, cs
	mov ds, dx
	mov ebx, [_curPid]
	mov dword [clientPid], ebx
	mov dword [_curPid], MAXPRO		; claim that we are in OS
	imul bx, 56						; bx = &proList[curPid]
	add bx, _proList
	pop cx							; cx=ds
	mov [ds:bx+16], ebp
	mov [ds:bx+34], cx
	mov [ds:bx+36], es
	mov [ds:bx+38], ss
	mov [ds:bx+40], sp
	mov es, dx
	mov ss, dx
	mov sp, [os_sp]
	mov bp, [os_bp]
	sti
putchar:							; ah=0: putchar(al)
	cmp ah, 0
	jnz getchar
		mov bl, 0x07
		mov ah, 0xe
		int 10h
		jmp end_server
getchar:							; ah=1: getchar(al)
	cmp ah, 1
	jnz getch
		push word 0
		call _GetFirstOfBuf
		jmp end_server
getch:								; ah=2: getch(al)
	cmp ah, 2
	jnz end_server
		mov ah, 0
		int 16h
		jmp end_server
end_server:
	cli
	mov ebx, [clientPid]			; reset curPid
	mov dword [_curPid], ebx
	imul bx, 56						; bx = &proList[curPid]
	add bx, _proList
	mov [os_bp], bp
	mov ebp, [ds:bx+16]
	mov es, [ds:bx+36]
	mov ss, [ds:bx+38]
	mov [os_sp], sp
	mov sp, [ds:bx+40]
	mov ds, [ds:bx+34]
	sti
	iret

section .data
	_char_askii db 0
	_char_kb db 0
	os_sp dw 0
	os_bp dw 0
hotwheel_data:
	wheel db '-\|/'
	wheelcnt db 0
	delaycnt dw 0
server_data:
	clientPid dd 0