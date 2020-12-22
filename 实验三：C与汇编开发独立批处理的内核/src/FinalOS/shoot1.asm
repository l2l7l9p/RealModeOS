org 0x100
;org 0x7c00

mov ax, 0xB800
mov es, ax

main:
mov ax, 0
FOR_2:									; ID & name start at (5,9)
	mov di, ax
	add di, 9
	add di, 400							; 5*80+9+ax
	imul di, 2
	mov si, ax
	add si, ID_Name
	mov byte bh, [si]
	mov [es:di], bh						; char
	mov byte [es:di+1], 0xA1			; background
	inc ax
	cmp ax, 11
	jle FOR_2
mov bh, 0				; vertical coordinate
mov bl, 0				; horizontal coordinate
mov dh, 1				; vertical direction
mov dl, 1				; horizontal direction
mov byte ch, 'A'		; current char
mov byte cl, 'Z'
call foo
call clear_screen
retf

delay:
mov edi, 10000007
FOR_1: dec edi
jnz FOR_1
ret

foo:
call delay
movzx di, bh
imul di, 80
movzx ax, bl
add di, ax
imul di, 2
mov [es:di], ch
mov byte [es:di+1], 0x74
add bh, dh
add bl, dl
IF_0: cmp bh, 11		; downmost
	jne IF_1
	mov dh, -1
IF_1: cmp bh, 0			; upmost
	jne IF_2
	mov dh, 1
IF_2: cmp bl, 39		; rightmost
	jne IF_3
	ret
IF_3: cmp bl, 0			; leftmost
	jne IF_4
	mov dl, 1
IF_4: cmp ch, 'Z'
	jne END_IF
	sub ch, 26
END_IF: add ch, 1
jmp foo

clear_screen:
mov al,0				; clear screen
mov ch,0				; upper-left row
mov cl,0				; upper-left column
mov dh,11				; down-right row
mov dl,39				; down-right column
mov bh,0x07				; color&background
mov ah,0x06				; function: clear screen
int 0x10				; interrupt
ret

datadef:
ID_Name db '18340083 KQP'


times 510-($-$$) db 0	; complete with 0
dw 0xaa55				; end with boot symbol