; Dino game logic only

INCLUDE Irvine32.inc

GetAsyncKeyState PROTO, vKey:DWORD

VK_SPACE  = 20h
VK_UP     = 26h
VK_DOWN   = 28h

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
EXTERN birdFrame:BYTE
EXTERN dinoDuck:BYTE
EXTERN controlsX:SDWORD
EXTERN controlsDone:BYTE
EXTERN dinoRunFrame:BYTE
EXTERN dinoRunCounter:BYTE

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
	mov controlsX, 24
	mov controlsDone, 0
	mov dinoRunFrame, 0
	mov dinoRunCounter, 0
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

	; Move controls text from right to left once
	cmp controlsDone, 1
	je skip_controls_move

	mov eax, controlsX
	dec eax
	mov controlsX, eax

	cmp eax, 2
	jge skip_controls_move

	mov controlsDone, 1

skip_controls_move:
	
	; Animate running legs only on ground and not ducking
	mov eax, dinoY
	cmp eax, 0
	jne skip_run_anim

	cmp dinoDuck, 1
	je skip_run_anim

	mov al, dinoRunCounter
	inc al
	mov dinoRunCounter, al

	mov eax, cactusSpeed
	mov ebx, 6
	sub ebx, eax

	cmp ebx, 1
	jge run_delay_ok
	mov ebx, 1

run_delay_ok:
	movzx eax, dinoRunCounter
	cmp eax, ebx
	jl skip_run_anim

	mov dinoRunCounter, 0
	mov al, dinoRunFrame
	xor al, 1
	mov dinoRunFrame, al

skip_run_anim:

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

	;Spawn obstacle closer as score increases
	mov eax, dinoScore
	cmp eax, 10
	jl spawn_far

	cmp eax, 20
	jl spawn_medium

spawn_close:
	mov cactusX, 70
	jmp spawn_done

spawn_medium:
	mov cactusX, 75
	jmp spawn_done

spawn_far:
	mov cactusX, 78

spawn_done:
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

	; Higher score bird chance:
	; score 5-14  -> 50% bird
	; score 15+   -> 67% bird
	mov eax, dinoScore
	cmp eax, 15
	jl bird_chance_50

bird_chance_67:
	mov eax, 3
	call RandomRange
	cmp eax, 2
	jne make_bird
	jmp choose_cactus

bird_chance_50:
	mov eax, 2
	call RandomRange
	cmp eax, 0
	je make_bird

choose_cactus:

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
	; flying enemy: height 3..8 (within dino reach)
	mov eax, 6
	call RandomRange
	add eax, 3
	mov cactusHeight, al

done_height:

skip_cactus_reset:

	; collision check
	mov eax, cactusX
	cmp eax, 4
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
	; Bird X-range: overlap with dino area
	mov eax, cactusX
	cmp eax, 5
	jl tick_end
	cmp eax, 18
	jg tick_end

	; If ducking on ground, dodge bird
	cmp dinoDuck, 1
	je tick_end

	; Exact bird/dino vertical overlap check
	; bird rows = 18 - cactusHeight through 19 - cactusHeight
	; dino rows = 13 - dinoY through - dinoY

	; If bird bottom is above dino top, no collision
	movzx ebx, cactusHeight
	mov eax, 19
	sub eax, ebx

	mov ecx, 13
	sub ecx, dinoY

	cmp eax, ecx
	jg tick_end

	; If bird top is below dino bottom, no collision
	movzx ebx, cactusHeight
	mov eax, 18
	sub eax, ebx

	mov ecx, 20
	sub ecx, dinoY

	cmp eax, ecx
	jg tick_end

	mov dinoGameOver, 1
	jmp tick_end


normal_width:
	cmp eax, 10
	jg tick_end

check_height:
	; Cactus collision has small tolerance
	movzx ebx, cactusHeight
	add ebx, 2
	mov eax, dinoY
	cmp eax, ebx
	jg tick_end

	mov dinoGameOver, 1

tick_end:
	ret
DinoTick ENDP

DinoIsDone PROC
	mov eax, dinoScore
	cmp eax, 3
	jge dino_done

	cmp dinoGameOver, 1
	je dino_done

	mov al, 0
	ret

dino_done:
	mov al, 1
	ret
DinoIsDone ENDP

DinoWasSuccess PROC
	cmp dinoGameOver, 1
	je dino_failed

	mov al, 1
	ret

dino_failed:
	mov al, 0
	ret
DinoWasSuccess ENDP

END