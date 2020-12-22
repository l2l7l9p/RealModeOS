org 0x7c3e

client_pos equ 8100h
client_pos_seg equ 800h

mbr:
call clear_screen
call init_print
call load_client
call clear_screen
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

init_print:
mov al, 0x01			; pointer at the end of string
mov bx, 0x07			; page: bh=0,   color&background: 07h
mov dx, 0				; string position: (0,0)
mov cx, init1_len		; string length
mov ax, cs				; string address
mov es, ax
mov bp, init1
mov ah, 0x13			; function: display string
int 10H					; interrupt
ret

load_client:
mov ax, cs				; position in memory
mov es, ax
mov bx, client_pos
mov al, 1				; number of sectors to load
mov dl, 0				;驱动器号 ; 软盘为0，硬盘和U盘为80H
mov dh, 0				;磁头号 ; 起始编号为0
mov cl, 2				;起始扇区号 ; 起始编号为1
mov ch, 0				;柱面号 ; 起始编号为0
mov ah, 0x02			; function: read
int 13H					; interrupt
mov ax, client_pos_seg
mov ds, ax
mov es, ax
call client_pos
ret


datadef:
init1 db 'This is KQP_OS. Please choose program to run. (1 to 4)'
init1_len equ ($-init1)


times 510-($-$$) db 0	; complete with 0
dw 0xaa55				; end with boot symbol