; Dino game logic only

INCLUDE Irvine32.inc

GetAsyncKeyState PROTO, vKey:DWORD

VK_SPACE  = 20h
VK_UP     = 26h

.data
PUBLIC DinoInit
PUBLIC DinoTick

EXTERN dinoY:SDWORD
EXTERN dinoVy:SDWORD
EXTERN cactusX:SDWORD
EXTERN dinoScore:DWORD
EXTERN dinoGameOver:BYTE

.code

DinoInit PROC
	mov dinoY, 0
	mov dinoVy, 0
	mov cactusX, 30
	mov dinoScore, 0
	mov dinoGameOver, 0
	ret
DinoInit ENDP

DinoTick PROC
	; If game over, press Space to reset
	.if dinoGameOver == 1
		invoke GetAsyncKeyState, VK_SPACE
		test ax, 8000h
		jz tick_end

		call DinoInit
		jmp tick_end
	.endif

	; Jump on Space or Up Arrow only if on ground
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

	mov dinoVy, 4

skip_input:

	; dinoY += dinoVy
	mov eax, dinoY
	add eax, dinoVy
	mov dinoY, eax

	; dinoVy -= 1
	mov eax, dinoVy
	sub eax, 1
	mov dinoVy, eax

	; clamp to ground
	mov eax, dinoY
	cmp eax, 0
	jge skip_ground_clamp

	mov dinoY, 0
	mov dinoVy, 0

skip_ground_clamp:

	; move cactus left
	mov eax, cactusX
	dec eax
	mov cactusX, eax

	; reset cactus and increment score
	cmp eax, 0
	jge skip_cactus_reset

	mov cactusX, 30
	inc dinoScore

skip_cactus_reset:

	; collision if cactus near dino and dino is on ground
	mov eax, cactusX
	cmp eax, 5
	jl tick_end
	cmp eax, 7
	jg tick_end

	mov eax, dinoY
	cmp eax, 0
	jne tick_end

	mov dinoGameOver, 1

tick_end:
	ret
DinoTick ENDP

END