; This will handle the displaying of the game window

INCLUDE Irvine32.inc

DrawDinoGame PROTO
WriteConsoleOutputA PROTO, \
    hConsoleOutput:DWORD, \
    lpBuffer:PTR BYTE, \
    dwBufferSize:DWORD, \
    dwBufferCoord:DWORD, \
    lpWriteRegion:PTR BYTE

.data
; Screen buffer: 80x25 cells, 2 bytes each (char + attribute)
SCREEN_WIDTH    = 80
SCREEN_HEIGHT   = 25
SCREEN_BUF_SIZE = SCREEN_WIDTH * SCREEN_HEIGHT * 4
screenBuffer    BYTE SCREEN_BUF_SIZE DUP(0)

; Current virtual cursor position and color for buffer writes
bufCursorX      BYTE 0
bufCursorY      BYTE 0
bufColor        BYTE (white + (black * 16))

; WriteConsoleOutput structures
wcoBufSize      WORD SCREEN_WIDTH
                WORD SCREEN_HEIGHT
wcoBufCoord     WORD 0
                WORD 0
wcoWriteRegion  WORD 0
                WORD 0
                WORD SCREEN_WIDTH - 1
                WORD SCREEN_HEIGHT - 1

hBorder         BYTE "+-------------------------------------++-------------------------------------+", 0
vBorder         BYTE "|                                     ||                                     |", 0
hBorderLeft     BYTE "+-------------------------------------+", 0
vBorderLeft     BYTE "|                                     |", 0

; Start screen information
scTextFile      BYTE "start_screen.txt", 0
SC_BUFFER_SIZE  = 2000
scBuffer        BYTE SC_BUFFER_SIZE DUP(?)

; Scratch buffer for BufWriteDec digit conversion (max 10 digits + null)
decScratch      BYTE 11 DUP(0)

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
PUBLIC BufWriteDec
PUBLIC BufClearScreen
PUBLIC FlushScreenBuffer

; Sets the virtual cursor position for buffer writes
; IN: dh = row, dl = col
BufGotoxy PROC
    mov bufCursorX, dl
    mov bufCursorY, dh
    ret
BufGotoxy ENDP

; Sets the current buffer write color
; IN: eax = color attribute
BufSetTextColor PROC
    mov bufColor, al
    ret
BufSetTextColor ENDP

; Writes a null-terminated string into screenBuffer at current cursor pos
; IN: edx = string address
BufWriteString PROC
    push eax
    push ebx
    push edi
    push esi

    mov esi, edx

    bws_loop:
		
		cmp bufCursorY, SCREEN_HEIGHT
        jae bws_done
        cmp bufCursorX, SCREEN_WIDTH
        jae bws_newline

		mov al, BYTE PTR [esi]
        cmp al, 0
        je bws_done
        cmp al, 0Ah         ; LF - move to next row
        je bws_newline
        cmp al, 0Dh         ; CR - ignore
        je bws_cr

        movzx edi, bufCursorY
        imul edi, SCREEN_WIDTH
        movzx ebx, bufCursorX
        add edi, ebx
        shl edi, 2

        mov BYTE PTR screenBuffer[edi], al
        mov BYTE PTR screenBuffer[edi + 1], 0
        mov bl, bufColor
        mov BYTE PTR screenBuffer[edi + 2], bl
        mov BYTE PTR screenBuffer[edi + 3], 0

        inc bufCursorX
        cmp bufCursorX, SCREEN_WIDTH
        jl bws_next
        mov bufCursorX, 0
        inc bufCursorY

        bws_next:
        inc esi
        jmp bws_loop
		
		bws_cr:
        inc esi
        jmp bws_loop

		bws_newline:
        mov bufCursorX, 0
        inc bufCursorY
        inc esi
        jmp bws_loop
    bws_done:
    pop esi
    pop edi
    pop ebx
    pop eax
    ret
BufWriteString ENDP

; Writes a single character into screenBuffer at current cursor pos
; IN: al = character
BufWriteChar PROC
    push eax
    push ebx
    push edi

    mov bl, al

    movzx edi, bufCursorY
    imul edi, SCREEN_WIDTH
    movzx eax, bufCursorX
    add edi, eax
    shl edi, 2

    mov BYTE PTR screenBuffer[edi], bl
    mov BYTE PTR screenBuffer[edi + 1], 0
    mov bl, bufColor
    mov BYTE PTR screenBuffer[edi + 2], bl
    mov BYTE PTR screenBuffer[edi + 3], 0

    inc bufCursorX
    cmp bufCursorX, SCREEN_WIDTH
    jl bwc_done
    mov bufCursorX, 0
    inc bufCursorY

    bwc_done:
    pop edi
    pop ebx
    pop eax
    ret
BufWriteChar ENDP

; Writes an unsigned decimal integer into screenBuffer
; IN: eax = value to write
BufWriteDec PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi

    ; Convert eax to decimal string in decScratch
    mov ecx, 0                          ; digit count
    mov ebx, 10

    ; handle zero specially
    cmp eax, 0
    jne bwd_divide_loop
    mov BYTE PTR decScratch, '0'
    mov BYTE PTR decScratch + 1, 0
    mov edx, OFFSET decScratch
    call BufWriteString
    jmp bwd_done

    bwd_divide_loop:
        cmp eax, 0
        je bwd_build_string
        mov edx, 0
        div ebx                         ; eax = quotient, edx = remainder
        add dl, '0'
        mov BYTE PTR decScratch[ecx], dl
        inc ecx
        jmp bwd_divide_loop

    bwd_build_string:
    ; digits are in reverse order in decScratch, reverse them
    mov BYTE PTR decScratch[ecx], 0    ; null terminate
    ; reverse in place
    mov esi, 0
    mov ebx, ecx
    dec ebx                             ; ebx = last index
    bwd_reverse:
        cmp esi, ebx
        jge bwd_reversed
        mov al, BYTE PTR decScratch[esi]
        mov cl, BYTE PTR decScratch[ebx]
        mov BYTE PTR decScratch[esi], cl
        mov BYTE PTR decScratch[ebx], al
        inc esi
        dec ebx
        jmp bwd_reverse
    bwd_reversed:
    mov edx, OFFSET decScratch
    call BufWriteString

    bwd_done:
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
BufWriteDec ENDP

; Clears screenBuffer to spaces with white-on-black
BufClearScreen PROC
    push eax
    push ecx

    mov ecx, 0
    bcs_loop:
        cmp ecx, SCREEN_BUF_SIZE
        jge bcs_done
        mov BYTE PTR screenBuffer[ecx], ' '
        mov BYTE PTR screenBuffer[ecx + 1], 0
        mov BYTE PTR screenBuffer[ecx + 2], (white + (black * 16))
        mov BYTE PTR screenBuffer[ecx + 3], 0
        add ecx, 4
        jmp bcs_loop
    bcs_done:

    mov bufCursorX, 0
    mov bufCursorY, 0
    mov bufColor, (white + (black * 16))

    pop ecx
    pop eax
    ret
BufClearScreen ENDP

; Flushes screenBuffer to console in one call
FlushScreenBuffer PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi

    push -11
    call GetStdHandle

    invoke WriteConsoleOutputA, \
        eax, \
        ADDR screenBuffer, \
        DWORD PTR wcoBufSize, \
        DWORD PTR wcoBufCoord, \
        ADDR wcoWriteRegion

    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
FlushScreenBuffer ENDP

UpdateScreen PROC
    .if currState == 0
        call StartScreen

    .elseif currState == 1
        call DrawDinoBase
        call DrawDinoGame

    .elseif currState == 3
        call DrawDinoBase
        call DrawDinoGame

    .elseif currState == 4
        call DrawDinoBase
        call DrawDinoGame

    .elseif currState == 6
        call DrawDinoBase
        call DrawDinoGame

    .else
        call DrawBase
    .endif

    ret
UpdateScreen ENDP

DrawDinoBase PROC
    mov eax, gray + (black * 16)
    call BufSetTextColor

    ; Top full border
	mov dh, 0
    mov dl, 0
    call BufGotoxy
    mov edx, OFFSET hBorder
    call BufWriteString

	; Side borders full width
    mov cl, 0

dino_border_loop_start:
    mov dh, cl
    add dh, 1
    mov dl, 0
    call BufGotoxy
    mov edx, OFFSET vBorder
    call BufWriteString

    inc cl
    .if cl < 22
        jmp dino_border_loop_start
    .endif

    ; Bottom full border
	mov dh, 23
    mov dl, 0
    call BufGotoxy
    mov edx, OFFSET hBorder
    call BufWriteString

    ret
DrawDinoBase ENDP

ClearScreen PROC
    call BufClearScreen
    ret
ClearScreen ENDP

DrawBase PROC
    mov eax, gray + (black * 16)
    call BufSetTextColor

    mov dh, 0
    mov dl, 0
    call BufGotoxy
    mov edx, OFFSET hBorder
    call BufWriteString

    mov cl, 0
    vBorder_loop_start:
        mov dh, cl
        add dh, 1
        mov dl, 0
        call BufGotoxy
        mov edx, OFFSET vBorder
        call BufWriteString

        inc cl
        .if cl < 22
            jmp vBorder_loop_start
        .endif

    mov dh, 23
    mov dl, 0
    call BufGotoxy
    mov edx, OFFSET hBorder
    call BufWriteString

    ret
DrawBase ENDP

StartScreen PROC
    mov edx, OFFSET scTextFile
    call OpenInputFile

    mov edx, OFFSET scBuffer
    mov ecx, SC_BUFFER_SIZE - 1
    call ReadFromFile
    mov BYTE PTR [scBuffer + eax], 0

    mov eax, white + (black * 16)
    call BufSetTextColor
    call BufClearScreen
    mov edx, OFFSET scBuffer
    call BufWriteString

    ret
StartScreen ENDP

END