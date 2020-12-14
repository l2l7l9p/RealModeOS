mov ax, 0xB800
mov es, ax

mov bh, 0				; vertical coordinate
mov bl, 0				; horizontal coordinate
mov dh, 1				; vertical direction
mov dl, 1				; horizontal direction
mov byte ch, 'A'		; current char
mov byte cl, 'Z'

main:
mov byte [es:(10*80+20)*2], '1'			; student id
mov byte [es:(10*80+21)*2], '8'
mov byte [es:(10*80+22)*2], '3'
mov byte [es:(10*80+23)*2], '4'
mov byte [es:(10*80+24)*2], '0'
mov byte [es:(10*80+25)*2], '0'
mov byte [es:(10*80+26)*2], '8'
mov byte [es:(10*80+27)*2], '3'
mov byte [es:(10*80+28)*2], ' '
mov byte [es:(10*80+29)*2], ' '
mov byte [es:(10*80+30)*2], 'K'			; name
mov byte [es:(10*80+31)*2], 'Q'
mov byte [es:(10*80+32)*2], 'P'
mov ax, 20
FOR_2:									; background & color
mov di, ax
add di, 800
imul di, 2
mov byte [es:di+1], 0xA1
inc ax
cmp ax, 32
jle FOR_2
call foo

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
IF_0: cmp bh, 22		; downmost
jne IF_1
mov dh, -1
IF_1: cmp bh, 0			; upmost
jne IF_2
mov dh, 1
IF_2: cmp bl, 79		; rightmost
jne IF_3
mov dl, -1
IF_3: cmp bl, 0			; leftmost
jne IF_4
mov dl, 1
IF_4: cmp ch, 'Z'
jne END_IF
sub ch, 26
END_IF: add ch, 1
jmp foo

times 510-($-$$) db 0	; complete with 0

dw 0xaa55				; end with boot symbol