; This will handle the game logic

INCLUDE Irvine32.inc

UpdateScreen PROTO
ClearScreen PROTO
DrawBase PROTO
StartTimers PROTO
UpdateTimers PROTO
DrawTimers PROTO
SwitchTimers PROTO
HandleInput PROTO

BufGotoxy PROTO
BufSetTextColor PROTO
BufWriteString PROTO
BufWriteChar PROTO
BufClearScreen PROTO
FlushScreenBuffer PROTO

DinoInit PROTO
DinoTick PROTO
DinoIsDone PROTO
DinoWasSuccess PROTO
ApplyDinoPenalty PROTO

LoadQuiz PROTO
LoadLab PROTO
DrawQuiz PROTO
DrawLab PROTO

CheckQuiz PROTO
CheckLab PROTO

GetAsyncKeyState PROTO, vKey:DWORD
VK_RETURN = 0Dh

EXTERN chosenDifficulty:BYTE
EXTERN quizScore:DWORD
EXTERN labScore:DWORD

.data
PUBLIC currState
currState BYTE ?

last_input BYTE 0

scoreQuizLabel  BYTE "Score: ", 0
scoreLabLabel   BYTE "Score: ", 0
scoreSuffix50   BYTE "/50", 0
scoreTotalLabel BYTE "Total Score: ", 0
scoreSuffix100  BYTE "/100", 0

.code
PUBLIC Game

DrawEndScreen PROC
    push eax
    push ebx
    push edx

    call ClearScreen
    call DrawBase

    ; Left panel: quiz questions
    call DrawQuiz

    mov eax, white + (black * 16)
    call SetTextColor
    mov dh, 22
    mov dl, 1
    call Gotoxy
    mov edx, OFFSET scoreQuizLabel
    call WriteString
    mov eax, quizScore
    call WriteDec
    mov edx, OFFSET scoreSuffix50
    call WriteString

    ; Right panel: lab questions
    call DrawLab

    mov eax, white + (black * 16)
    call SetTextColor
    mov dh, 22
    mov dl, 39
    call Gotoxy
    mov edx, OFFSET scoreLabLabel
    call WriteString
    mov eax, labScore
    call WriteDec
    mov edx, OFFSET scoreSuffix50
    call WriteString

    mov dh, 24
    mov dl, 0
    call Gotoxy
    mov eax, white + (black * 16)
    call SetTextColor
    mov edx, OFFSET scoreTotalLabel
    call WriteString
    mov eax, quizScore
    add eax, labScore
    call WriteDec
    mov edx, OFFSET scoreSuffix100
    call WriteString

    pop edx
    pop ebx
    pop eax
    ret
DrawEndScreen ENDP

Game PROC
    mov currState, 0

    call BufClearScreen
    call UpdateScreen
	call FlushScreenBuffer
    call StartTimers

; STATE 0: start screen
press_enter_loop_start:
    call UpdateTimers
	call FlushScreenBuffer
    mov eax, 50
    call Delay
    call ReadKey
    cmp al, 13
    jne press_enter_loop_start

    movzx eax, chosenDifficulty
    call LoadQuiz

; STATE 1: getting quiz (dino)
    mov currState, 1
    call DinoInit

getting_quiz_loop_start:
    call DinoTick
    call UpdateScreen
	call FlushScreenBuffer
    call DrawTimers
    call UpdateTimers
    mov eax, 50
    call Delay

    call DinoIsDone
    cmp al, 0
    je getting_quiz_loop_start

    call DinoWasSuccess
    cmp al, 1
    je state1_done

    call ApplyDinoPenalty

state1_done:
    mov eax, 150
    call Delay

; STATE 2: solving quiz
    mov currState, 2
    call BufClearScreen
    call DrawBase
    call DrawQuiz
    call DrawTimers

flush_keys_2:
    invoke GetAsyncKeyState, VK_RETURN
    test ax, 8000h
    jnz flush_keys_2

quiz_loop_start:
    call HandleInput
    mov last_input, al

    call BufClearScreen
    call DrawBase
    call DrawQuiz
    call UpdateTimers

    mov eax, 50
    call Delay

    cmp last_input, 0Dh
    jne quiz_loop_start

    mov eax, 150
    call Delay

; STATE 3: turning in quiz (dino)
    mov currState, 3
    call DinoInit

turning_in_quiz_loop_start:
    call DinoTick
    call UpdateScreen
	call FlushScreenBuffer
    call DrawTimers
    call UpdateTimers
    mov eax, 50
    call Delay

    call DinoIsDone
    cmp al, 0
    je turning_in_quiz_loop_start

    call DinoWasSuccess
    cmp al, 1
    je state3_done

    call ApplyDinoPenalty

state3_done:
    call CheckQuiz
    mov eax, 150
    call Delay

; STATE 4: getting lab (dino)
    mov currState, 4
    call SwitchTimers
    movzx eax, chosenDifficulty
    call LoadLab
    call DinoInit

getting_lab_loop_start:
    call DinoTick
    call UpdateScreen
	call FlushScreenBuffer
    call DrawTimers
    call UpdateTimers
    mov eax, 50
    call Delay

    call DinoIsDone
    cmp al, 0
    je getting_lab_loop_start

    call DinoWasSuccess
    cmp al, 1
    je state4_done

    call ApplyDinoPenalty

state4_done:
    mov eax, 150
    call Delay

; STATE 5: solving lab
    mov currState, 5
    call ClearScreen
    call DrawBase
    call DrawLab
    call DrawTimers

flush_keys_5:
    invoke GetAsyncKeyState, VK_RETURN
    test ax, 8000h
    jnz flush_keys_5

lab_loop_start:
    call HandleInput
    mov last_input, al

    call ClearScreen
    call DrawBase
    call DrawLab
    call UpdateTimers

    mov eax, 50
    call Delay

    cmp last_input, 0Dh
    jne lab_loop_start

    mov eax, 150
    call Delay

; STATE 6: turning in lab (dino)
    mov currState, 6
    call DinoInit

turning_in_lab_loop_start:
    call DinoTick
    call UpdateScreen
	call FlushScreenBuffer
    call DrawTimers
    call UpdateTimers
    mov eax, 50
    call Delay

    call DinoIsDone
    cmp al, 0
    je turning_in_lab_loop_start

    call DinoWasSuccess
    cmp al, 1
    je state6_done

    call ApplyDinoPenalty

state6_done:
    call CheckLab
    mov eax, 150
    call Delay

; STATE 7: end screen
    mov currState, 7
    call DrawEndScreen
    call ReadChar
    call ReadChar
    ret
Game ENDP

END