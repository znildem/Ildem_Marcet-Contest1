; This will handle the game logic

INCLUDE Irvine32.inc

UpdateScreen PROTO
StartTimers PROTO
UpdateTimers PROTO

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

	call StartTimers

	; Wait for enter key
	press_enter_loop_1_start:
		call UpdateScreen
		call UpdateTimers
		mov eax, 1000
		call Delay
		call ReadKey
		cmp al, 13
		jne press_enter_loop_1_start

	mov currState, 1

	; Getting quiz code here

	mov currState, 2

	; Quiz loop
	quiz_loop_start:
		call UpdateScreen
		call UpdateTimers
		mov eax, 1000
		call Delay
		call ReadKey
		cmp al, 13
		jne press_enter_loop_1_start


	ret
Game ENDP

END