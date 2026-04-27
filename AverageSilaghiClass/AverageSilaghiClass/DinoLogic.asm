; Dino game logic only

INCLUDE Irvine32.inc

GetAsyncKeyState PROTO, vKey:DWORD

VK_SPACE  = 20h
VK_UP     = 26h
VK_DOWN   = 28h

.data
PUBLIC DinoInit
PUBLIC DinoTick

EXTERN dinoY:SDWORD
EXTERN dinoVy:SDWORD
EXTERN cactusX:SDWORD
EXTERN dinoScore:DWORD
EXTERN dinoGameOver:BYTE
EXTERN cactusType:BYTE
EXTERN cactusHeight:BYTE
EXTERN cactusSpeed:SDWORD
EXTERN birdFrame:BYTE
EXTERN dinoDuck:BYTE

.code

DinoInit PROC
	mov dinoY, 0
	mov dinoVy, 0
	mov cactusX, 40
	mov dinoScore, 0
	mov dinoGameOver, 0
	mov cactusType, 0
	mov cactusHeight, 0
	mov cactusSpeed, 1
	mov birdFrame, 0
	mov dinoDuck, 0
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

	; Duck with Down Arrow only while on ground
	mov dinoDuck, 0
	invoke GetAsyncKeyState, VK_DOWN
	test ax, 8000h
	jz check_jump_input

	mov eax, dinoY
	cmp eax, 0
	jne check_jump_input

	mov dinoDuck, 1

check_jump_input:

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

	mov dinoVy, 5

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
	sub eax, cactusSpeed
	mov cactusX, eax

	; toggle bird animation frame
	mov al, birdFrame
	xor al, 1
	mov birdFrame, al

	; reset cactus and increment score
	cmp eax, 0
	jge skip_cactus_reset

	mov cactusX, 40
	inc dinoScore

	; increase speed every 5 points
	mov eax, dinoScore
	mov ebx, 10
	mov edx, 0
	div ebx
	cmp edx, 0
	jne skip_speed_increase

	cmp cactusSpeed, 5
	jge skip_speed_increase
	inc cactusSpeed

skip_speed_increase:

	; Choose obstacle type
	; Early game: 0 = small, 1 = large, 2 = flying
	; After score 5: birds become more common

	mov eax, dinoScore
	cmp eax, 5
	jl normal_obstacle_random

	; Higher score: 50% chance bird
	mov eax, 2
	call RandomRange
	cmp eax, 0
	je make_bird

	; Otherwise choose small or large cactus
	mov eax, 2
	call RandomRange
	mov cactusType, al
	jmp obstacle_type_done

make_bird:
	mov cactusType, 2
	jmp obstacle_type_done

normal_obstacle_random:
	mov eax, 3
	call RandomRange
	mov cactusType, al

obstacle_type_done:

	; Random height depends on type
	movzx eax, cactusType
	cmp eax, 2
	je set_flying_height

	; random height (0,1,2)
	mov eax, 3
	call RandomRange
	mov cactusHeight, al
	jmp done_height

set_flying_height:
	; flying enemy: height 3..5
	mov eax, 3
	call RandomRange
	add eax, 3
	mov cactusHeight, al

done_height:

skip_cactus_reset:

	; collision check
	mov eax, cactusX
	cmp eax, 8
	jl tick_end

	movzx ebx, cactusType
	cmp ebx, 2
	je bird_collision
	cmp ebx, 0
	je normal_width

	; large cactus
	cmp eax, 11
	jg tick_end
	jmp check_height

bird_collision: 
	; Bird X-range: 7-12
	mov eax, cactusX
	cmp eax, 7
	jl tick_end
	cmp eax, 12
	jg tick_end

	; If ducking on ground, dodge bird
	cmp dinoDuck, 1
	je tick_end

	; Bird Y-range: cactusHeight + 2
	movzx ebx, cactusHeight
	add ebx, 2
	mov ecx, dinoY
	cmp ecx, ebx
	jg tick_end

	mov dinoGameOver, 1
	jmp tick_end


normal_width:
	cmp eax, 10
	jg tick_end

check_height:
	movzx ebx, cactusHeight
	inc ebx
	mov eax, dinoY
	cmp eax, ebx
	jg tick_end

	mov dinoGameOver, 1

tick_end:
	ret
DinoTick ENDP

END