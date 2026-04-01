; This will handle the displaying of the game window

INCLUDE Irvine32.inc

DrawDinoGame PROTO

.data
hBorder BYTE "+-------------------------------------++-------------------------------------+", 0
vBorder BYTE "|                                     ||                                     |", 0

; Start screen information
scTextFile BYTE "start_screen.txt", 0
SC_BUFFER_SIZE = 2000
scBuffer BYTE SC_BUFFER_SIZE DUP(?)

; External variables
EXTERN currState:BYTE

.code
PUBLIC UpdateScreen
PUBLIC ClearScreen
PUBLIC DrawBase

UpdateScreen PROC
	.if currState == 0
		call StartScreen
	.else
		call ClearScreen
		call DrawBase

		.if currState == 1
			call DrawDinoGame
		.elseif currState == 2
			; quiz screen
		.elseif currState == 3
			call DrawDinoGame
		.endif

	.endif

	ret
UpdateScreen ENDP

ClearScreen PROC
	mov eax, white + (black * 16)
	call SetTextColor
	call Clrscr
ClearScreen ENDP

DrawBase PROC
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

StartScreen PROC
	; Open file
	mov edx, OFFSET scTextFile
	call OpenInputFile        ; EAX = file handle

	; Read file
	mov edx, OFFSET scBuffer
	mov ecx, SC_BUFFER_SIZE - 1
	call ReadFromFile         ; EAX = bytes read

	; Null-terminate buffer
	mov BYTE PTR [scBuffer + eax], 0

	; Write start screen stuff
	mov eax, white + (black * 16)
	call SetTextColor
	call Clrscr
	mov edx, OFFSET scBuffer
	call WriteString

	ret
StartScreen ENDP

END