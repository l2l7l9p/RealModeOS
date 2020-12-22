org 7c00h

resetInt08h:						; reset int 08h
	mov ax, 0
	mov es, ax
	cli
	mov word [es:0x20], HotWheel
	mov word [es:0x22], cs
	sti
initDisplay:						; initially print '-'
	mov ax, 0xb800
	mov es, ax
	mov byte [es:(23*80+79)*2], '-'
	mov byte [es:(23*80+79)*2+1], 0x7
	jmp $

HotWheel:
	inc word [delaycnt]
	cmp word [delaycnt], 100
	jnz End
	mov word [delaycnt], 0			; reset delaycnt
	inc byte [wheelcnt]
	and byte [wheelcnt], 3			; wheelcnt = wheelcnt mod 4
	movzx bx, byte [wheelcnt]		; cl = wheel[wheelcnt]
	mov byte cl, [ds:wheel+bx]
	mov ax, 0xb800					; print wheel
	mov es, ax
	mov byte [es:(23*80+79)*2], cl
End:
	mov al, 0x20					; tell 8259 that we finished
	out 0x20, al
	iret							; interrupt return

Data:
	wheel db '-\|/'
	wheelcnt db 0
	delaycnt dw 0

times 510-($-$$) db 0				; complete with 0
dw 0xaa55							; end with boot symbol