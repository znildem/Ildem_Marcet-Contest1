; This will handle most of the main menu stuff

INCLUDE Irvine32.inc

.data
space BYTE ' '
newLine BYTE 0Dh, 0Ah
rowBuffer BYTE 80 DUP(? ), 0
gameTitle BYTE "An Average Class with Dr. Silaghi..."

.code
PUBLIC menu

menu PROC
	mov edx, OFFSET gameTitle
	call WriteString
	ret
menu ENDP

END