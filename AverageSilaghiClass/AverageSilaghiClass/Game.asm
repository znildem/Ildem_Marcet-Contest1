; This will handle the game logic

INCLUDE Irvine32.inc

UpdateScreen PROTO
ClearScreen PROTO
StartTimers PROTO
UpdateTimers PROTO

DinoInit PROTO
DinoTick PROTO

GetAsyncKeyState PROTO, vKey:DWORD
VK_RETURN = 0Dh

.data
PUBLIC currState
currState BYTE ?
; Possible game states:
	; currState=0: game start
	; currState=1: getting quiz
	; currState=2: solving quiz
	; currState=3: turning in quiz
	; currState=4: getting lab
	; currState=5: solving lab
	; currState=6: turning in lab
	; currState=7: game end

.code
PUBLIC Game
Game PROC
	mov currState, 0

	call ClearScreen
	call UpdateScreen

	call StartTimers


	; Wait for enter key
	press_enter_loop_1_start:
		call UpdateTimers
		mov eax, 50
		call Delay
		call ReadKey
		cmp al, 13
		jne press_enter_loop_1_start

	mov currState, 1

	; Getting quiz code here
	; Dino game should dispay here
	call DinoInit
	getting_quiz_loop_start:
		call DinoTick
		call UpdateScreen
		call UpdateTimers
		mov eax, 50
		call Delay

		invoke GetAsyncKeyState, VK_RETURN
		test ax, 8000h
		jz getting_quiz_loop_start

		mov eax, 150
		call Delay

	mov currState, 2

	; Quiz loop
	quiz_loop_start:
		call UpdateScreen
		call UpdateTimers
		mov eax, 1000
		call Delay
		
		invoke GetAsyncKeyState, VK_RETURN
		test ax, 8000h
		jz quiz_loop_start

		mov eax, 150
		call Delay

	; State 3: turning in quiz
	; Dino game should display here
	mov currState, 3
	call DinoInit

	turning_in_quiz_loop_start:
		call DinoTick
		call UpdateScreen
		call UpdateTimers
		mov eax, 50
		call Delay

		invoke GetAsyncKeyState, VK_RETURN
		test ax, 8000h
		jz turning_in_quiz_loop_start

		mov eax, 150
		call Delay

	; End state
	mov currState, 7
	call UpdateScreen


	ret
Game ENDP

END