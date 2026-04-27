; Dino game rendering

INCLUDE Irvine32.inc
BufGotoxy PROTO
BufSetTextColor PROTO
BufWriteString PROTO
BufWriteDec PROTO

.data

; External dino game data
EXTERN dinoY:SDWORD
EXTERN cactusX:SDWORD
EXTERN dinoScore:DWORD
EXTERN dinoGameOver:BYTE
EXTERN cactusType:BYTE
EXTERN cactusHeight:BYTE
EXTERN birdFrame:BYTE
EXTERN dinoDuck:BYTE
EXTERN controlsX:SDWORD
EXTERN controlsDone:BYTE
EXTERN dinoRunFrame:BYTE

; Simple ASCII representations
dinoSprite1 BYTE "    ",219,219,219,219,0
dinoSprite2 BYTE "   ",219,"  ",219,219,219,219,219,0
dinoSprite3 BYTE "   ",219,219,219,219,219,219,219,219,219,0
dinoSprite4 BYTE " ",219,219,219,219,219,219,219,219,0
dinoSprite5 BYTE 219,219,219,219,219,219,219,219,219,219," ",0
dinoSprite6 BYTE "  ",219,219,219,219,219,219,219,"  ",0
dinoSprite7 BYTE "  ",219,219," ",219,219,"    ",0
dinoSprite8 BYTE "  ",219,"  ",219,"     ",0
dinoLegsRun1 BYTE " ",219,219,"   ",219,"    ",0
dinoLegsRun2 BYTE "   ",219,"   ",219,219,"  ",0

duckSprite1 BYTE "       ",219,219,219,219,0
duckSprite2 BYTE "      ",219,"o",219,219,219,219,0
duckSprite3 BYTE 219,219,219,219,219,219,219,219,219,219,"  ",0
duckSprite4 BYTE "  ",219,219,219,219,219,219,"    ",0
duckSprite5 BYTE "   ",219,219,"    ",219,219,0

cactusSmall1 BYTE "  #",0
cactusSmall2 BYTE " # #",0
cactusSmall3 BYTE " # #",0
cactusSmall4 BYTE " ###",0
cactusSmall5 BYTE "  #",0

cactusLarge1 BYTE "   ##",0
cactusLarge2 BYTE " # ## #",0
cactusLarge3 BYTE " # ## #",0
cactusLarge4 BYTE " # ## #",0
cactusLarge5 BYTE " #####",0
cactusLarge6 BYTE "   ##",0

birdSprite BYTE "  __",0
birdSprite2 BYTE "<(o )___",0

; Animated bird frames
birdA1 BYTE "  \\_",0
birdA2 BYTE "<(o )\\_",0

birdB1 BYTE "  /_",0
birdB2 BYTE "<(o )/",0

scoreText BYTE "Score: ",0
gameOverText BYTE "GAME OVER - press any key",0
controlsText BYTE "Space/Up = Jump   Down = Duck",0

grassLine BYTE 37 DUP(219),0

.code
PUBLIC DrawDinoGame

DrawDinoGame PROC
	; Draw score
	mov dh, 1
	mov dl, 2
	call BufGotoxy
	mov edx, OFFSET scoreText
	call BufWriteString

	mov eax, dinoScore
	call BufWriteDec

	; Draw scrolling controls text once on score row
	cmp controlsDone, 1
	je skip_controls_text

	mov eax, lightMagenta + (black * 16)
	call BufSetTextColor
	mov dh, 1
	mov eax, controlsX
	mov eax, 14
	mov dl, al
	call BufGotoxy
	mov edx, OFFSET controlsText
	call BufWriteString

	mov eax, white + (black * 16)
	call BufSetTextColor

skip_controls_text:

	; Draw green grass line
	mov eax, green + (black * 16)
	call BufSetTextColor
	mov dh, 21
	mov dl, 1
	call BufGotoxy
	mov edx, OFFSET grassLine
	call BufWriteString

	mov eax, white + (black * 16)
	call BufSetTextColor

	; If game over show message
	cmp dinoGameOver, 1
	jne draw_objects

	mov dh, 10
	mov dl, 5
	call BufGotoxy
	mov edx, OFFSET gameOverText
	call BufWriteString
	ret

draw_objects:
	; Draw cactus or flying enemy
	movzx eax, cactusType
	cmp eax, 2
	je draw_bird
	cmp eax, 0
	je draw_small_cactus

	; large cactus
	mov eax, cactusX
	mov dl, al
	movzx ebx, cactusHeight
	mov dh, 18
	sub dh, bl
	call BufGotoxy
	mov edx, OFFSET cactusLarge1
	call BufWriteString

	mov eax, cactusX
	mov dl, al
	movzx ebx, cactusHeight
	mov dh, 19
	sub dh, bl
	call BufGotoxy
	mov edx, OFFSET cactusLarge2
	call BufWriteString

	mov eax, cactusX
	mov dl, al
	movzx ebx, cactusHeight
	mov dh, 20
	sub dh, bl
	call BufGotoxy
	mov edx, OFFSET cactusLarge3
	call BufWriteString

	jmp cactus_done

draw_bird:
    movzx eax, birdFrame
    cmp eax, 0
    je draw_bird_A

draw_bird_B:
    ; Frame B line 1
    mov eax, cactusX
    mov dl, al
    movzx ebx, cactusHeight
    mov dh, 18
    sub dh, bl
    call BufGotoxy
    mov edx, OFFSET birdB1
    call BufWriteString

    ; Frame B line 2
    mov eax, cactusX
    mov dl, al
    movzx ebx, cactusHeight
    mov dh, 19
    sub dh, bl
    call BufGotoxy
    mov edx, OFFSET birdB2
    call BufWriteString

    jmp cactus_done

draw_bird_A:
    ; Frame A line 1
    mov eax, cactusX
    mov dl, al
    movzx ebx, cactusHeight
    mov dh, 18
    sub dh, bl
    call BufGotoxy
    mov edx, OFFSET birdA1
    call BufWriteString

    ; Frame A line 2
    mov eax, cactusX
    mov dl, al
    movzx ebx, cactusHeight
    mov dh, 19
    sub dh, bl
    call BufGotoxy
    mov edx, OFFSET birdA2
    call BufWriteString

    jmp cactus_done


draw_small_cactus:
	; Line 1
	mov eax, cactusX
	mov dl, al
	movzx ebx, cactusHeight
	mov dh, 16
	sub dh, bl
	call BufGotoxy
	mov edx, OFFSET cactusSmall1
	call BufWriteString

	; Line 2
	mov eax, cactusX
	mov dl, al
	movzx ebx, cactusHeight
	mov dh, 17
	sub dh, bl
	call BufGotoxy
	mov edx, OFFSET cactusSmall2
	call BufWriteString

	; Line 3
	mov eax, cactusX
	mov dl, al
	movzx ebx, cactusHeight
	mov dh, 18
	sub dh, bl
	call BufGotoxy
	mov edx, OFFSET cactusSmall3
	call BufWriteString

	; Line 4
	mov eax, cactusX
	mov dl, al
	movzx ebx, cactusHeight
	mov dh, 19
	sub dh, bl
	call BufGotoxy
	mov edx, OFFSET cactusSmall3
	call BufWriteString

	; Line 5
	mov eax, cactusX
	mov dl, al
	movzx ebx, cactusHeight
	mov dh, 20
	sub dh, bl
	call BufGotoxy
	mov edx, OFFSET cactusSmall3
	call BufWriteString

	jmp cactus_done

cactus_done:

	; Draw dinosaur
	cmp dinoDuck, 1
	je draw_duck_dino

	mov eax, dinoY
	mov ebx, 20
	sub ebx, eax

	mov dh, bl
	sub dh, 7
	mov dl, 5
	call BufGotoxy
	mov edx, OFFSET dinoSprite1
	call BufWriteString

	mov dh, bl
	sub dh, 6
	mov dl, 5
	call BufGotoxy
	mov edx, OFFSET dinoSprite2
	call BufWriteString

	mov dh, bl
	sub dh, 5
	mov dl, 5
	call BufGotoxy
	mov edx, OFFSET dinoSprite3
	call BufWriteString

	mov dh, bl
	sub dh, 4
	mov dl, 5
	call BufGotoxy
	mov edx, OFFSET dinoSprite4
	call BufWriteString

	mov dh, bl
	sub dh, 3
	mov dl, 5
	call BufGotoxy
	mov edx, OFFSET dinoSprite5
	call BufWriteString

	mov dh, bl
	sub dh, 2
	mov dl, 5
	call BufGotoxy
	mov edx, OFFSET dinoSprite6
	call BufWriteString

	mov dh, bl
	sub dh, 1
	mov dl, 5
	call BufGotoxy
	mov edx, OFFSET dinoSprite7
	call BufWriteString

	mov dh, bl
	mov dl, 5
	call BufGotoxy

	cmp dinoY, 0
	jne draw_normal_feet

	movzx eax, dinoRunFrame
	cmp eax, 0
	je draw_run_feet_1

	mov edx, OFFSET dinoLegsRun2
	call BufWriteString
	ret

draw_run_feet_1:
	mov edx, OFFSET dinoLegsRun1
	call BufWriteString
	ret

draw_normal_feet:
	mov edx, OFFSET dinoSprite8
	call BufWriteString

	ret

draw_duck_dino:
	mov eax, dinoY
	mov ebx, 20
	sub ebx, eax

	mov dh, bl
	sub dh, 4
	mov dl, 5
	call BufGotoxy
	mov edx, OFFSET duckSprite1
	call BufWriteString

	mov dh, bl
	sub dh, 3
	mov dl, 5
	call BufGotoxy
	mov edx, OFFSET duckSprite2
	call BufWriteString

	mov dh, bl
	sub dh, 2
	mov dl, 5
	call BufGotoxy
	mov edx, OFFSET duckSprite3
	call BufWriteString

	mov dh, bl
	sub dh, 1
	mov dl, 5
	call BufGotoxy
	mov edx, OFFSET duckSprite4
	call BufWriteString

	mov dh, bl
	mov dl, 5
	call BufGotoxy
	mov edx, OFFSET duckSprite5
	call BufWriteString

	ret

DrawDinoGame ENDP

END