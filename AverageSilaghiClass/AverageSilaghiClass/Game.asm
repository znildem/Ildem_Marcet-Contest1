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

DinoInit PROTO
DinoTick PROTO

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
; Possible game states:
    ; currState=0: game start
    ; currState=1: getting quiz
    ; currState=2: solving quiz
    ; currState=3: turning in quiz
    ; currState=4: getting lab
    ; currState=5: solving lab
    ; currState=6: turning in lab
    ; currState=7: game end

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

    ; Quiz score at bottom of left panel interior (row 22, col 1)
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

    ; Lab score at bottom of right panel interior (row 22, col 39)
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

    ; Total score at row 24 (timer row)
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

    call ClearScreen
    call UpdateScreen
    call StartTimers

    ; State 0: wait at start screen until enter
    press_enter_loop_start:
        call UpdateTimers
        mov eax, 50
        call Delay
        call ReadKey
        cmp al, 13
        jne press_enter_loop_start

    ; Load quiz with chosen difficulty
    movzx eax, chosenDifficulty
    call LoadQuiz

    ; State 1: getting quiz (dino runs while player walks to get quiz)
    mov currState, 1
    call DinoInit
    getting_quiz_loop_start:
        call DinoTick
        call UpdateScreen
        call DrawTimers
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
    call DrawTimers
    drain_buf_2:
        call ReadKey
        cmp ah, 0
        jne drain_buf_2
    flush_keys_2:
        invoke GetAsyncKeyState, VK_RETURN
        test ax, 8000h
        jnz flush_keys_2
    quiz_loop_start:
        call HandleInput
        mov last_input, al
		call DrawBase
		call DrawQuiz
        call UpdateTimers
        mov eax, 50
        call Delay
        cmp last_input, 0Dh
        jne quiz_loop_start

        mov eax, 150
        call Delay

    ; State 3: turning in quiz (dino)
    mov currState, 3
    call DinoInit
    turning_in_quiz_loop_start:
        call DinoTick
        call UpdateScreen
        call DrawTimers
        call UpdateTimers
        mov eax, 50
        call Delay

        invoke GetAsyncKeyState, VK_RETURN
        test ax, 8000h
        jz turning_in_quiz_loop_start
		call CheckQuiz

        mov eax, 150
        call Delay

    ; State 4: getting lab (dino)
    mov currState, 4
    call SwitchTimers
    movzx eax, chosenDifficulty
    call LoadLab
    call DinoInit
    getting_lab_loop_start:
        call DinoTick
        call UpdateScreen
        call DrawTimers
        call UpdateTimers
        mov eax, 50
        call Delay

        invoke GetAsyncKeyState, VK_RETURN
        test ax, 8000h
        jz getting_lab_loop_start

        mov eax, 150
        call Delay

    ; State 5: solving lab
    mov currState, 5
    call ClearScreen
    call DrawBase
    call DrawLab
    call DrawTimers
    drain_buf_5:
        call ReadKey
        cmp ah, 0
        jne drain_buf_5
    flush_keys_5:
        invoke GetAsyncKeyState, VK_RETURN
        test ax, 8000h
        jnz flush_keys_5
    lab_loop_start:
        call HandleInput
        mov last_input, al
		call DrawBase
		Call DrawLab
        call UpdateTimers
        mov eax, 50
        call Delay
        cmp last_input, 0Dh
        jne lab_loop_start

        mov eax, 150
        call Delay

    ; State 6: turning in lab (dino)
    mov currState, 6
    call DinoInit
    turning_in_lab_loop_start:
        call DinoTick
        call UpdateScreen
        call DrawTimers
        call UpdateTimers
        mov eax, 50
        call Delay

        invoke GetAsyncKeyState, VK_RETURN
        test ax, 8000h
        jz turning_in_lab_loop_start
		call CheckLab

        mov eax, 150
        call Delay

    ; State 7: game end screen
    mov currState, 7
    call DrawEndScreen
	call ReadChar
	call ReadChar
    ret
Game ENDP

END