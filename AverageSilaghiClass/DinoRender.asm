; Dino game rendering

INCLUDE Irvine32.inc

BufGotoxy PROTO
BufSetTextColor PROTO
BufWriteString PROTO
BufWriteDec PROTO

.data

EXTERN dinoY:SDWORD
EXTERN cactusX:SDWORD
EXTERN dinoScore:DWORD
EXTERN dinoGameOver:BYTE
EXTERN cactusType:BYTE
EXTERN cactusHeight:BYTE

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

scoreText    BYTE "Score: ",0
gameOverText BYTE "GAME OVER - press any key",0

.code
PUBLIC DrawDinoGame

DrawDinoGame PROC
    ; Draw score
    mov eax, white + (black * 16)
    call BufSetTextColor
    mov dh, 1
    mov dl, 2
    call BufGotoxy
    mov edx, OFFSET scoreText
    call BufWriteString
    mov eax, dinoScore
    call BufWriteDec

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
    ; Draw cactus
    movzx eax, cactusType
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

draw_small_cactus:
    mov eax, cactusX
    mov dl, al
    movzx ebx, cactusHeight
    mov dh, 18
    sub dh, bl
    call BufGotoxy
    mov edx, OFFSET cactusSmall1
    call BufWriteString

    mov eax, cactusX
    mov dl, al
    movzx ebx, cactusHeight
    mov dh, 19
    sub dh, bl
    call BufGotoxy
    mov edx, OFFSET cactusSmall2
    call BufWriteString

    mov eax, cactusX
    mov dl, al
    movzx ebx, cactusHeight
    mov dh, 20
    sub dh, bl
    call BufGotoxy
    mov edx, OFFSET cactusSmall3
    call BufWriteString

cactus_done:
    ; Draw dinosaur
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
    mov edx, OFFSET dinoSprite8
    call BufWriteString

    ret

DrawDinoGame ENDP

END