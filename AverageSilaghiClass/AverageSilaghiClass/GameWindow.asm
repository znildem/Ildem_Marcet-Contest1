; This will handle the displaying of the game window

INCLUDE Irvine32.inc

DrawTimer PROTO

.data
hBorder BYTE "+-------------------------------------++-------------------------------------+", 0
vBorder BYTE "|                                     ||                                     |", 0

.code
PUBLIC UpdateScreen

UpdateScreen PROC
	call DrawBase
	call DrawTimer
	ret
UpdateScreen ENDP

DrawBase PROC
	; Clearing the screen
	mov eax, white + (black * 16)
	call SetTextColor
	call Clrscr

	; Adding borders
	mov eax, gray + (black * 16)
	call SetTextColor

	; Adding top border
	mov dh, 0
	mov dl, 0
	call Gotoxy
	mov edx, OFFSET hBorder
	call WriteString

	; Adding vertical borders
	mov cl, 0
	vBorder_loop_start:
		mov dh, cl
		add dh, 1

		mov dl, 0
		call Gotoxy
		mov edx, OFFSET vBorder
		call WriteString

		inc cl
		.if cl < 22
			jmp vBorder_loop_start
		.endif

	; Adding bottom border
	mov dh, 23
	mov dl, 0
	call Gotoxy
	mov edx, OFFSET hBorder
	call WriteString

	ret
DrawBase ENDP
END