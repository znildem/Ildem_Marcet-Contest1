; This will handle the game logic

INCLUDE Irvine32.inc

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


END