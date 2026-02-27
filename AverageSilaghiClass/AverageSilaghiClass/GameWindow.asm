; This will handle the displaying of the game window

INCLUDE Irvine32.inc

.data
hBorder BYTE "+-------------------------------------++-------------------------------------+", 0
vBorder BYTE "|", 0

.code
PUBLIC UpdateScreen

UpdateScreen PROC
	call DrawBase
	ret
UpdateScreen ENDP

DrawBase PROC
	; Clearing the screen
	mov eax, white + (black * 16)
	call SetTextColor
	call Clrscr

	; Adding borders
	mov eax, lightGray + (gray * 16)
	call SetTextColor

	; Adding top border
	mov dh, 0
	mov dl, 0
	call Gotoxy
	mov edx, OFFSET hBorder
	call WriteString

	ret
DrawBase ENDP
END