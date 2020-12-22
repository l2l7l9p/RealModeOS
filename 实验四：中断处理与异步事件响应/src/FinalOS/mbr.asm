org 0x7c3e

client_seg_addr equ 800h

mbr:
	call clear_screen
	call init_cursor
	call load_os
	jmp $

clear_screen:
	mov al,0				; clear screen
	mov ch,0				; upper-left row
	mov cl,0				; upper-left column
	mov dh,23				; down-right row
	mov dl,79				; down-right column
	mov bh,0x07				; color&background
	mov ah,0x06				; function: clear screen
	int 0x10				; interrupt
	ret

init_cursor:
	mov bh, 0
	mov dh, 0
	mov dl, 0
	mov ah, 2
	int 10h
	ret

load_os:
	mov ax, client_seg_addr
	mov es, ax
	mov bx, 0x100			; position : 0x1800:0x0000
	mov al, 5				; number of sectors to load
	mov dl, 0				;驱动器号 ; 软盘为0，硬盘和U盘为80H
	mov dh, 0				;磁头号 ; 起始编号为0
	mov cl, 2
	mov ch, 0				;柱面号 ; 起始编号为0
	mov ah, 0x02			; function: read
	int 13H					; interrupt
	mov ax, client_seg_addr
	mov ds, ax
	mov ss, ax
	mov byte [ds:0], 0xcb
	push cs
	push end_client
	push byte 0
	jmp client_seg_addr: 0x100
end_client:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	ret


times 510-($-$$) db 0	; complete with 0
dw 0xaa55				; end with boot symbol