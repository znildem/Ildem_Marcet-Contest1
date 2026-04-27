; Timers handling will be done in this file
; This does NOT handle midnight change, just dont play at midnight :P

INCLUDE Irvine32.inc

FindArrString PROTO
BufGotoxy PROTO
BufSetTextColor PROTO
BufWriteString PROTO
BufWriteChar PROTO

.data
; Last call time
prev_time DWORD ?
curr_time DWORD ?

; Timer for the quiz duration
T_CLASS_INITIAL = 50000 ; 50 seconds in ms
T_CLASS_CHAR_LENGTH = 80
T_CLASS_POS_X = 0
T_CLASS_POS_Y = 24
timer_class DWORD ?
t_class_text BYTE "QUIZ DEADLINE                                                                   ", 0

; Timer for the lab duration
T_LAB_INITIAL = 50000 ; 50 seconds in ms
T_LAB_CHAR_LENGTH = 80
T_LAB_POS_X = 0
T_LAB_POS_Y = 24
timer_lab DWORD ?
t_lab_text BYTE "LAB DEADLINE                                                                    ", 0

curr_timer BYTE 0

.code
PUBLIC UpdateTimers
PUBLIC StartTimers
PUBLIC SwitchTimers
PUBLIC DrawTimers
PUBLIC GetPenalty
PUBLIC ApplyDinoPenalty

StartTimers PROC
    call GetMseconds
    mov prev_time, eax

    .if curr_timer == 0
        mov timer_class, T_CLASS_INITIAL
    .else
        mov timer_lab, T_LAB_INITIAL
    .endif

    call DrawTimers
    ret
StartTimers ENDP

UpdateTimers PROC
    call GetMseconds
    mov curr_time, eax

    .if curr_timer == 0
        mov eax, timer_class
        sub eax, curr_time
        add eax, prev_time
        .if eax < 0
            mov eax, 0
        .endif
        mov timer_class, eax
    .else
        mov eax, timer_lab
        sub eax, curr_time
        add eax, prev_time
        .if eax < 0
            mov eax, 0
        .endif
        mov timer_lab, eax
    .endif

    mov eax, curr_time
    mov prev_time, eax
    ret
UpdateTimers ENDP

; Draws the timer bar in two passes:
;   filled portion (black on white) from col 0 to fillLen
;   remaining portion (white on black) from fillLen to end
DrawTimers PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi

    ; Set text pointer and compute fill length
    .if curr_timer == 0
        mov eax, timer_class
        mov esi, OFFSET t_class_text
        mov ecx, T_CLASS_CHAR_LENGTH
        mov ebx, T_CLASS_INITIAL
    .else
        mov eax, timer_lab
        mov esi, OFFSET t_lab_text
        mov ecx, T_LAB_CHAR_LENGTH
        mov ebx, T_LAB_INITIAL
    .endif

    ; fillLen = (timer * CHAR_LENGTH) / INITIAL
    mul ecx                 ; edx:eax = timer * CHAR_LENGTH
    mov edx, 0
    div ebx                 ; eax = fillLen
    .if eax > ecx
        mov eax, ecx
    .endif

    mov ebx, eax            ; ebx = fillLen

    ; Position cursor at start of timer row
    mov dh, T_CLASS_POS_Y
    mov dl, T_CLASS_POS_X
    call BufGotoxy

    ; --- Filled portion: black on white ---
    push eax
    mov eax, black + (white * 16)
    call BufSetTextColor
    pop eax

    push ecx
    mov ecx, 0
    filled_loop:
        cmp ecx, ebx
        jge filled_done
        mov al, BYTE PTR [esi + ecx]
        call BufWriteChar
        inc ecx
        jmp filled_loop
    filled_done:
    pop ecx

    ; --- Remaining portion: white on black ---
    push eax
    mov eax, white + (black * 16)
    call BufSetTextColor
    pop eax

    ; cursor already at col ebx from BufWriteChar
    push ecx
    mov ecx, ebx
    remaining_loop:
        .if curr_timer == 0
            cmp ecx, T_CLASS_CHAR_LENGTH
        .else
            cmp ecx, T_LAB_CHAR_LENGTH
        .endif
        jge remaining_done
        mov al, BYTE PTR [esi + ecx]
        call BufWriteChar
        inc ecx
        jmp remaining_loop
    remaining_done:
    pop ecx

    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
DrawTimers ENDP

GetPenalty PROC
    .if curr_timer == 0
        mov eax, timer_class
    .else
        mov eax, timer_lab
    .endif
    cmp eax, 0
    jl penalty_applies
    mov eax, 0
    penalty_applies:
    neg eax
    mov edx, 0
    mov ebx, 1000
    div ebx
    done:
    ret
GetPenalty ENDP

SwitchTimers PROC
    mov curr_timer, 1
    call StartTimers
    ret
SwitchTimers ENDP

ApplyDinoPenalty PROC
    cmp curr_timer, 0
    je apply_to_quiz

    sub timer_lab, 5000
    cmp timer_lab, 0
    jge adp_done
    mov timer_lab, 0
    jmp adp_done

apply_to_quiz:
    sub timer_class, 5000
    cmp timer_class, 0
    jge adp_done
    mov timer_class, 0

adp_done:
    ret
ApplyDinoPenalty ENDP

END