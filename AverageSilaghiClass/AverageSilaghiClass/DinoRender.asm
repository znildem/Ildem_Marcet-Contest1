; Dino game rendering

INCLUDE Irvine32.inc

.data

; External dino game data
EXTERN dinoY:SDWORD
EXTERN cactusX:SDWORD
EXTERN dinoScore:DWORD
EXTERN dinoGameOver:BYTE
EXTERN cactusType:BYTE
EXTERN cactusHeight:BYTE

; Simple ASCII representations
dinoSprite1 BYTE "    ",219,219,219,219,0
dinoSprite2 BYTE "   ",219,"  ",219,219,219,219,219,0
dinoSprite3 BYTE "   ",219,219,219,219,219,219,219,219,219,0
dinoSprite4 BYTE " ",219,219,219,219,219,219,219,219,0
dinoSprite5 BYTE 219,219,219,219,219,219,219,219,219,219," ",0
dinoSprite6 BYTE "  ",219,219,219,219,219,219,219,"  ",0
dinoSprite7 BYTE "  ",219,219," ",219,219,"    ",0
dinoSprite8 BYTE "  ",219,"  ",219,"     ",0

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

scoreText BYTE "Score: ",0
gameOverText BYTE "GAME OVER - press any key",0

.code
PUBLIC DrawDinoGame

DrawDinoGame PROC
	; Draw score
	mov dh, 1
	mov dl, 2
	call Gotoxy
	mov edx, OFFSET scoreText
	call WriteString

	mov eax, dinoScore
	call WriteDec

	; If game over show message
	cmp dinoGameOver, 1
	jne draw_objects

	mov dh, 10
	mov dl, 5
	call Gotoxy
	mov edx, OFFSET gameOverText
	call WriteString
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
	call Gotoxy
	mov edx, OFFSET cactusLarge1
	call WriteString

	mov eax, cactusX
	mov dl, al
	movzx ebx, cactusHeight
	mov dh, 19
	sub dh, bl
	call Gotoxy
	mov edx, OFFSET cactusLarge2
	call WriteString

	mov eax, cactusX
	mov dl, al
	movzx ebx, cactusHeight
	mov dh, 20
	sub dh, bl
	call Gotoxy
	mov edx, OFFSET cactusLarge3
	call WriteString

	jmp cactus_done

draw_bird:
	; Line 1
	mov eax, cactusX
	mov dl, al
	movzx ebx, cactusHeight
	mov dh, 18
	sub dh, bl
	call Gotoxy
	mov edx, OFFSET birdSprite
	call WriteString
	
	; Line 2
	mov eax, cactusX
	mov dl, al
	movzx ebx, cactusHeight
	mov dh, 19
	sub dh, bl
	call Gotoxy
	mov edx, OFFSET birdSprite2
	call WriteString

	jmp cactus_done

draw_small_cactus:
	; Line 1
	mov eax, cactusX
	mov dl, al
	movzx ebx, cactusHeight
	mov dh, 18
	sub dh, bl
	call Gotoxy
	mov edx, OFFSET cactusSmall1
	call WriteString

	; Line 2
	mov eax, cactusX
	mov dl, al
	movzx ebx, cactusHeight
	mov dh, 19
	sub dh, bl
	call Gotoxy
	mov edx, OFFSET cactusSmall2
	call WriteString

	; Line 3
	mov eax, cactusX
	mov dl, al
	movzx ebx, cactusHeight
	mov dh, 20
	sub dh, bl
	call Gotoxy
	mov edx, OFFSET cactusSmall3
	call WriteString

	; Line 4
	mov eax, cactusX
	mov dl, al
	movzx ebx, cactusHeight
	mov dh, 21
	sub dh, bl
	call Gotoxy
	mov edx, OFFSET cactusSmall3
	call WriteString

	; Line 5
	mov eax, cactusX
	mov dl, al
	movzx ebx, cactusHeight
	mov dh, 22
	sub dh, bl
	call Gotoxy
	mov edx, OFFSET cactusSmall3
	call WriteString

	jmp cactus_done

cactus_done:

	; Draw dinosaur
		; Draw dinosaur
	mov eax, dinoY
	mov ebx, 20
	sub ebx, eax

	mov dh, bl
	sub dh, 7
	mov dl, 5
	call Gotoxy
	mov edx, OFFSET dinoSprite1
	call WriteString

	mov dh, bl
	sub dh, 6
	mov dl, 5
	call Gotoxy
	mov edx, OFFSET dinoSprite2
	call WriteString

	mov dh, bl
	sub dh, 5
	mov dl, 5
	call Gotoxy
	mov edx, OFFSET dinoSprite3
	call WriteString

	mov dh, bl
	sub dh, 4
	mov dl, 5
	call Gotoxy
	mov edx, OFFSET dinoSprite4
	call WriteString

	mov dh, bl
	sub dh, 3
	mov dl, 5
	call Gotoxy
	mov edx, OFFSET dinoSprite5
	call WriteString

	mov dh, bl
	sub dh, 2
	mov dl, 5
	call Gotoxy
	mov edx, OFFSET dinoSprite6
	call WriteString

	mov dh, bl
	sub dh, 1
	mov dl, 5
	call Gotoxy
	mov edx, OFFSET dinoSprite7
	call WriteString

	mov dh, bl
	mov dl, 5
	call Gotoxy
	mov edx, OFFSET dinoSprite8
	call WriteString

	ret

DrawDinoGame ENDP

END