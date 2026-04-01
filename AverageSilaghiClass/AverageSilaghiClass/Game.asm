; This will handle the game logic

INCLUDE Irvine32.inc

UpdateScreen PROTO
ClearScreen PROTO
StartTimers PROTO
UpdateTimers PROTO
SwitchTimers PROTO

DinoInit PROTO
DinoTick PROTO

LoadQuiz PROTO
DrawBase PROTO
DrawQuiz PROTO
GetNumQuestions PROTO
DifficultyMenu PROTO

GetAsyncKeyState PROTO, vKey:DWORD
VK_RETURN = 0Dh

EXTERN chosenDifficulty : BYTE

.data
PUBLIC currState
currState BYTE ?
; Possible game states :
; currState = 0: game start
; currState = 1: getting quiz
; currState = 2: solving quiz
; currState = 3: turning in quiz
; currState = 4: getting lab
; currState = 5: solving lab
; currState = 6: turning in lab
; currState = 7: game end

.code
PUBLIC Game
Game PROC
mov currState, 0

call ClearScreen
call UpdateScreen

call StartTimers

; State 0: wait at start screen until enter
press_enter_loop_1_start :
call UpdateTimers
mov eax, 50
call Delay
call ReadKey
cmp al, 13
jne press_enter_loop_1_start

; Load quiz with chosen difficulty
movzx eax, chosenDifficulty
call LoadQuiz

; State 1: getting quiz(dino game runs while quiz is fetched / displayed)
mov currState, 1
call DinoInit
getting_quiz_loop_start :
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

; State 2: solving quiz
mov currState, 2
call ClearScreen
call DrawBase
call DrawQuiz
quiz_loop_start :
call UpdateTimers
mov eax, 1000
call Delay

invoke GetAsyncKeyState, VK_RETURN
test ax, 8000h
jz quiz_loop_start

mov eax, 150
call Delay

; State 3: turning in quiz(dino)
mov currState, 3
call DinoInit
turning_in_quiz_loop_start :
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

; State 4: getting lab(dino)
mov currState, 4
call DinoInit
getting_lab_loop_start :
call DinoTick
call UpdateScreen
call UpdateTimers
mov eax, 50
call Delay

invoke GetAsyncKeyState, VK_RETURN
test ax, 8000h
jz getting_lab_loop_start

mov eax, 150
call Delay

; State 5: solving lab(reuse same quiz)
mov currState, 5
call ClearScreen
call DrawBase
call DrawQuiz
lab_loop_start :
call UpdateTimers
mov eax, 1000
call Delay

invoke GetAsyncKeyState, VK_RETURN
test ax, 8000h
jz lab_loop_start

mov eax, 150
call Delay

; State 6: turning in lab(dino)
mov currState, 6
call DinoInit
turning_in_lab_loop_start :
call DinoTick
call UpdateScreen
call UpdateTimers
mov eax, 50
call Delay

invoke GetAsyncKeyState, VK_RETURN
test ax, 8000h
jz turning_in_lab_loop_start

mov eax, 150
call Delay

; State 7: game end screen
mov currState, 7
call UpdateScreen

ret
Game ENDP

END