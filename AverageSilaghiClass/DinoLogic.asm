; Dino game logic only

INCLUDE Irvine32.inc

GetAsyncKeyState PROTO, vKey:DWORD
GetMseconds PROTO

VK_SPACE  = 20h
VK_UP     = 26h

.data
PUBLIC DinoInit
PUBLIC DinoTick
PUBLIC DinoIsDone
PUBLIC DinoWasSuccess

EXTERN dinoY:SDWORD
EXTERN dinoVy:SDWORD
EXTERN cactusX:SDWORD
EXTERN dinoScore:DWORD
EXTERN dinoGameOver:BYTE
EXTERN cactusType:BYTE
EXTERN cactusHeight:BYTE
EXTERN cactusSpeed:SDWORD

; NEW STATE VARIABLES
dinoStartTime     DWORD ?
dinoRoundDone     BYTE 0
dinoRoundSuccess  BYTE 0
prevCactusX       SDWORD ?

.code

; ---------------------------------------------------------
; Initialize dino round
; ---------------------------------------------------------
DinoInit PROC
    mov dinoY, 0
    mov dinoVy, 0
    mov cactusX, 40
    mov prevCactusX, 40
    mov dinoScore, 0
    mov dinoGameOver, 0
    mov cactusType, 0
    mov cactusHeight, 0
    mov cactusSpeed, 2

    mov dinoRoundDone, 0
    mov dinoRoundSuccess, 0

    call GetMseconds
    mov dinoStartTime, eax
    ret
DinoInit ENDP

; ---------------------------------------------------------
; Tick logic — runs every frame
; ---------------------------------------------------------
DinoTick PROC

    ; If already finished, do nothing
    .if dinoRoundDone == 1
        jmp tick_end
    .endif

    ; If collision happened ? fail immediately
    .if dinoGameOver == 1
        mov dinoRoundDone, 1
        mov dinoRoundSuccess, 0
        jmp tick_end
    .endif

    ; -------------------------
    ; INPUT: Jump
    ; -------------------------
    invoke GetAsyncKeyState, VK_SPACE
    test ax, 8000h
    jnz try_jump

    invoke GetAsyncKeyState, VK_UP
    test ax, 8000h
    jz skip_input

try_jump:
    mov eax, dinoY
    cmp eax, 0
    jne skip_input
    mov dinoVy, 5

skip_input:

    ; -------------------------
    ; Physics
    ; -------------------------
    mov eax, dinoY
    add eax, dinoVy
    mov dinoY, eax

    mov eax, dinoVy
    sub eax, 1
    mov dinoVy, eax

    ; Clamp to ground
    mov eax, dinoY
    cmp eax, 0
    jge skip_ground
    mov dinoY, 0
    mov dinoVy, 0
skip_ground:

    ; -------------------------
    ; Move cactus
    ; -------------------------
    mov eax, cactusX
    mov prevCactusX, eax
    sub eax, cactusSpeed
    mov cactusX, eax

    ; Reset cactus when passed
    cmp eax, 0
    jge skip_reset

    mov cactusX, 40
    inc dinoScore

    ; Increase speed every 10 points
    mov eax, dinoScore
    mov ebx, 10
    mov edx, 0
    div ebx
    cmp edx, 0
    jne skip_speed
    cmp cactusSpeed, 5
    jge skip_speed
    inc cactusSpeed
skip_speed:

    ; Random type
    mov eax, 2
    call RandomRange
    mov cactusType, al

    ; Random height
    mov eax, 3
    call RandomRange
    mov cactusHeight, al

skip_reset:

    ; -------------------------
    ; Collision detection
    ; -------------------------
    movzx ebx, cactusType
    cmp ebx, 0
    je small_cactus

    ; Large cactus hit window: x = 7..14
    mov ecx, 7
    mov edx, 14
    jmp check_x

small_cactus:
    ; Small cactus hit window: x = 7..12
    mov ecx, 7
    mov edx, 12

check_x:
    mov eax, cactusX
    cmp eax, edx
    jg check_success

    mov eax, prevCactusX
    cmp eax, ecx
    jl check_success

    ; Vertical collision
    movzx ebx, cactusHeight
    add ebx, 2
    mov eax, dinoY
    cmp eax, ebx
    jg check_success

    ; COLLISION ? FAIL
    mov dinoGameOver, 1
    mov dinoRoundDone, 1
    mov dinoRoundSuccess, 0
    jmp tick_end

; -------------------------
; SUCCESS CHECK (10 seconds)
; -------------------------
check_success:
    call GetMseconds
    sub eax, dinoStartTime
    cmp eax, 10000        ; 10 seconds
    jl tick_end

    mov dinoRoundDone, 1
    mov dinoRoundSuccess, 1

tick_end:
    ret
DinoTick ENDP

; ---------------------------------------------------------
; Query functions for Game.asm
; ---------------------------------------------------------
DinoIsDone PROC
    mov al, dinoRoundDone
    ret
DinoIsDone ENDP

DinoWasSuccess PROC
    mov al, dinoRoundSuccess
    ret
DinoWasSuccess ENDP

END