org 0x7c00

os_seg_addr equ 0x1000
fat_offset_addr equ 0x8000
dir_offset_addr equ 0xA000

jmp boot_loader				; 引导开始，跳转指令
nop							; 这个 nop 不可少，无操作，占字节位
; 下面是 FAT12 磁盘引导扇区的BPB和EBPB结构区51字节
BS_OEMName		DB 'MyOS    '	; OEM串，必须8个字节，不足补空格
BPB_BytsPerSec	DW 512		; 每扇区字节数
BPB_SecPerClus	DB 1		; 每簇扇区数
BPB_RsvdSecCnt	DW 1		; Boot记录占用扇区数
BPB_NumFATs		DB 2		; FAT表数
BPB_RootEntCnt	DW 224		; 根目录文件数最大值
BPB_TotSec16	DW 2880		; 逻辑扇区总数
BPB_Media		DB 0F0h		; 介质描述符
BPB_FATSz16		DW 9		; 每FAT扇区数
BPB_SecPerTrk	DW 18		; 每磁道扇区数
BPB_NumHeads	DW 2		; 磁头数(面数)
BPB_HiddSec		DD 	0			; 隐藏扇区数
BPB_TotSec32	DD 0		; BPB_TotSec16为0时由此值记录扇区总数
BS_DrvNum		DB 0		; 中断 13 的驱动器号（软盘）
BS_Reserved1	DB 0		; 未使用
BS_BootSig		DB 29h		; 扩展引导标记 (29h)
BS_VolID		DD 0		; 卷序列号
BS_VolLab		DB 'MyOS System'; 卷标，必须11个字节，不足补空格
BS_FileSysType	DB 'FAT12   '	; 文件系统类型，必须8个字节，不足补空格

boot_loader:
	call clear_screen
	call init_cursor
	
	; load FAT to 0x8000
	mov word [next_offset], fat_offset_addr
	mov byte [i], 1
	mbr_load_FAT:
		mov ax, 0
		mov es, ax
		mov bx, [next_offset]
		add word [next_offset], 512
		movzx cx, byte [i]
		call load
		add byte [i], 1
		cmp byte [i], 10
		jnz mbr_load_FAT
	
	; load directions to 0xA000
	mov word [next_offset], dir_offset_addr
	mov byte [i], 19
	mbr_load_dir:
		mov ax, 0
		mov es, ax
		mov bx, [next_offset]
		add word [next_offset], 512
		movzx cx, byte [i]
		call load
		add byte [i], 1
		cmp byte [i], 33
		jnz mbr_load_dir
	
	; find ker.com
	mov cx, 0
	mbr_findKer:
		mov bx, dir_offset_addr
		add bx, cx
		call isKer
		add cx, 32			; if return to here, ker.com not found
		cmp cx, 14*512
		jle mbr_findKer
	
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

load:
	mov ax, cx
	mov dx, cx
	mov ch, 36
	div ch
	mov ch, al				; ch: 柱面号 起始编号为0
	mov ax, dx
	mov dh, 18
	div dh
	mov dh, al				; dh : 磁头号 起始为0
	and dh, 1
	mov cl, ah				; cl : sector num
	add cl, 1
	mov dl, 0				;驱动器号 ; 软盘为0，硬盘和U盘为80H
	mov al, 1				; number of sectors to load
	mov ah, 0x02			; function: read
	int 13H					; interrupt

isKer:
	cmp byte [bx], 'm'
	jnz isKer_end
	cmp byte [bx+1], 'y'
	jnz isKer_end
	cmp byte [bx+2], 'O'
	jnz isKer_end
	cmp byte [bx+3], 'S'
	jnz isKer_end
	cmp byte [bx+4], 0
	jnz isKer_end
	cmp byte [bx+8], 'c'
	jnz isKer_end
	cmp byte [bx+9], 'o'
	jnz isKer_end
	cmp byte [bx+10], 'm'
	jnz isKer_end
	jz load_os
isKer_end:
	ret

load_os:
	mov cx, [bx+26]
	mov [curClu], cx
	mov word [next_offset], 100h
	load_os_while:
		mov ax, os_seg_addr			; load os
		mov es, ax
		mov bx, [next_offset]
		add word [next_offset], 512
		mov cx, [curClu]
		add cx, 31
		call load
		
		mov cx, [curClu]			; find next cluster
		mov bx, cx					; bx = &fat[curClu*3/2]
		imul bx, 3
		shr bx, 1
		add bx, fat_offset_addr
		and cx, 1
		jz cx_is_even
		cx_is_odd:
			mov dh, [bx+1]
			shr dx, 4
			mov cl, [bx]
			shr cl, 4
			or dl, cl
			jmp cx_end
		cx_is_even:
			mov dl, [bx]
			mov dh, [bx+1]
			and dh, 15
		cx_end:
		mov [curClu], dx
		cmp dx, 0xFFF
		jnz load_os_while
jmp_to_os:
	mov ax, os_seg_addr
	mov ds, ax
	mov ss, ax
	mov sp, 0xffff
	; mov byte [ds:0], 0xcb
	; push cs
	; push end_client
	; push byte 0
	jmp os_seg_addr: 0x100

data:
	i db 0
	next_offset dw 0
	curClu dw 0

times 510-($-$$) db 0	; complete with 0
dw 0xaa55				; end with boot symbol