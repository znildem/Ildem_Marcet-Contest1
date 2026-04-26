; This will handle the displaying of the game window

INCLUDE Irvine32.inc

DrawDinoGame PROTO

.data
; Screen buffer : 80x25 cells, 2 bytes each(char + attribute)
SCREEN_WIDTH = 80
SCREEN_HEIGHT = 25
SCREEN_BUF_SIZE = SCREEN_WIDTH * SCREEN_HEIGHT * 2
screenBuffer BYTE SCREEN_BUF_SIZE DUP(0)

; Current virtual cursor position and color for buffer writes
bufCursorX      BYTE 0
bufCursorY      BYTE 0
bufColor        BYTE(white + (black * 16))


; WriteConsoleOutput structures
wcoBufSize      WORD SCREEN_WIDTH; buffer width
WORD SCREEN_HEIGHT; buffer height
wcoBufCoord     WORD 0; top - left of buffer to read(x)
WORD 0; top - left of buffer to read(y)
wcoWriteRegion  WORD 0; left
WORD 0; top
WORD SCREEN_WIDTH - 1; right
WORD SCREEN_HEIGHT - 1; bottom



hBorder BYTE "+-------------------------------------++-------------------------------------+", 0
vBorder BYTE "|                                     ||                                     |", 0
hBorderLeft BYTE "+-------------------------------------+", 0
vBorderLeft BYTE "|                                     |", 0

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
PUBLIC DrawDinoBase
PUBLIC BufGotoxy
PUBLIC BufSetTextColor
PUBLIC BufWriteString
PUBLIC BufWriteChar

; Sets the virtual cursor position for buffer writes
; IN: dh = row, dl = col (same as Irvine Gotoxy)
BufGotoxy PROC
    mov bufCursorX, dl
    mov bufCursorY, dh
    ret
BufGotoxy ENDP
 
; Sets the current buffer write color
; IN: eax = color attribute (same as Irvine SetTextColor)
BufSetTextColor PROC
    mov bufColor, al
    ret
BufSetTextColor ENDP

; Writes a null-terminated string into screenBuffer at current cursor pos
; IN: edx = string address (same as Irvine WriteString)
; Advances bufCursorX after each char, wraps to next row on overflow
BufWriteString PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi
 
    mov esi, edx            ; esi = string pointer
    mov ecx, 0              ; char index
 
    bws_loop:
        mov al, BYTE PTR [esi + ecx]
        cmp al, 0
        je bws_done
 
        ; buffer offset = (row * SCREEN_WIDTH + col) * 2
        movzx eax, bufCursorY
        mov ebx, SCREEN_WIDTH
        mul ebx                     ; eax = row * SCREEN_WIDTH
        movzx ebx, bufCursorX
        add eax, ebx               ; eax = row * SCREEN_WIDTH + col
        shl eax, 1                 ; eax = offset in bytes (* 2)
 
        mov bl, BYTE PTR [esi + ecx]
        mov BYTE PTR screenBuffer[eax], bl      ; char byte
        mov bl, bufColor
        mov BYTE PTR screenBuffer[eax + 1], bl  ; attribute byte
 
        ; advance cursor
        inc bufCursorX
        cmp bufCursorX, SCREEN_WIDTH
        jl bws_next
        mov bufCursorX, 0
        inc bufCursorY
 
        bws_next:
        inc ecx
        jmp bws_loop
 
    bws_done:
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
BufWriteString ENDP

; Writes a single character into screenBuffer at current cursor pos
; IN: al = character (same as Irvine WriteChar)
BufWriteChar PROC
    push eax
    push ebx
 
    movzx eax, bufCursorY
    mov ebx, SCREEN_WIDTH
    mul ebx
    movzx ebx, bufCursorX
    add eax, ebx
    shl eax, 1
 
    mov bl, al
    ; al was clobbered by mul - get char back from bl after push
    ; actually al is clobbered - save char in bh first
    pop ebx                     ; restore ebx (was pushed)
    pop eax                     ; restore eax (original al = char)
    push eax
    push ebx
 
    ; recalculate offset with char saved
    push eax                    ; save char
    movzx eax, bufCursorY
    mov ebx, SCREEN_WIDTH
    mul ebx
    movzx ebx, bufCursorX
    add eax, ebx
    shl eax, 1                  ; eax = byte offset
 
    pop ebx                     ; ebx = char (was in al originally)
    mov BYTE PTR screenBuffer[eax], bl
    mov bl, bufColor
    mov BYTE PTR screenBuffer[eax + 1], bl
 
    inc bufCursorX
    cmp bufCursorX, SCREEN_WIDTH
    jl bwc_done
    mov bufCursorX, 0
    inc bufCursorY
 
    bwc_done:
    pop ebx
    pop eax
    ret
BufWriteChar ENDP


UpdateScreen PROC
	.if currState == 0
		call StartScreen

	.elseif currState == 1
		call ClearScreen
		call DrawDinoBase
		call DrawDinoGame

	.elseif currState == 3
		call ClearScreen
		call DrawDinoBase
		call DrawDinoGame

	.elseif currState == 4
		call ClearScreen
		call DrawDinoBase
		call DrawDinoGame

	.elseif currState == 6
		call ClearScreen
		call DrawDinoBase
		call DrawDinoGame

	.else
		call ClearScreen
		call DrawBase

		.if currState == 2
			; quiz screen
		.elseif currState == 5
			; lab screen
		.endif
	.endif

	ret
UpdateScreen ENDP

DrawDinoBase PROC
	mov eax, gray + (black * 16)
	call SetTextColor

	; top border
	mov dh, 0
	mov dl, 0
	call Gotoxy
	mov edx, OFFSET hBorderLeft
	call WriteString

	; side borders
	mov cl, 0
dino_border_loop_start:
	mov dh, cl
	add dh, 1
	mov dl, 0
	call Gotoxy
	mov edx, OFFSET vBorderLeft
	call WriteString

	inc cl
	.if cl < 22
		jmp dino_border_loop_start
	.endif

	; bottom border
	mov dh, 23
	mov dl, 0
	call Gotoxy
	mov edx, OFFSET hBorderLeft
	call WriteString

	ret
DrawDinoBase ENDP

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