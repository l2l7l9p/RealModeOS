mov ax, 0xB800
mov es, ax
mov byte [es:0], '@'
mov byte [es:1], 7
jmp $

times 510-($-$$) db 0	; complete with 0

dw 0xaa55				; end with boot symbol