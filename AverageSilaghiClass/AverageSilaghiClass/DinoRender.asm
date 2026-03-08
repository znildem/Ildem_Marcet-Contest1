; Dino game rendering

INCLUDE Irvine32.inc

.data

; External dino game data
EXTERN dinoY:SDWORD
EXTERN cactusX:SDWORD
EXTERN dinoScore:DWORD
EXTERN dinoGameOver:BYTE

; Simple ASCII representations
dinoSprite1 BYTE "  __",0
dinoSprite2 BYTE " (oo)",0
dinoSprite3 BYTE " /||\",0

cactusSprite1 BYTE " |",0
cactusSprite2 BYTE " |",0
cactusSprite3 BYTE "/ \",0

groundLine BYTE "_____________________________________",0

scoreText BYTE "Score: ",0
gameOverText BYTE "GAME OVER - press any key",0

.code
PUBLIC DrawDinoGame

DrawDinoGame PROC
	; Draw ground
	mov dh, 21
	mov dl, 1
	call Gotoxy
	mov edx, OFFSET groundLine
	call WriteString

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
	; Draw cactus
	mov eax, cactusX
	mov dl, al

	mov dh, 18
	call Gotoxy
	mov edx, OFFSET cactusSprite1
	call WriteString

	mov dh, 19
	call Gotoxy
	mov edx, OFFSET cactusSprite2
	call WriteString

	mov dh, 20
	call Gotoxy
	mov edx, OFFSET cactusSprite3
	call WriteString

	; Draw dinosaur
	mov eax, dinoY
	mov ebx, 20
	sub ebx, eax

	mov dh, bl
	sub dh, 2
	mov dl, 5
	call Gotoxy
	mov edx, OFFSET dinoSprite1
	call WriteString

	mov dh, bl
	sub dh, 1
	mov dl, 5
	call Gotoxy
	mov edx, OFFSET dinoSprite2
	call WriteString

	mov dh, bl
	mov dl, 5
	call Gotoxy
	mov edx, OFFSET dinoSprite3
	call WriteString

	ret

DrawDinoGame ENDP

END