; Timers handling will be done in this file
; This does NOT handle midnight change, just dont play at midnight : P

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
T_CLASS_INITIAL = 50000; 50 seconds in ms
T_CLASS_CHAR_LENGTH = 80
T_CLASS_POS_X = 0
T_CLASS_POS_Y = 24
timer_class DWORD ?
t_class_text BYTE "QUIZ DEADLINE                                                                   ", 0
t_class_curr_length BYTE ?

; Timer for the lab duration
T_LAB_INITIAL = 50000; 50 seconds in ms
T_LAB_CHAR_LENGTH = 80
T_LAB_POS_X = 0
T_LAB_POS_Y = 24
timer_lab DWORD ?
t_lab_text BYTE "LAB DEADLINE                                                                    ", 0
t_lab_curr_length BYTE ?

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
		mov t_class_curr_length, T_CLASS_CHAR_LENGTH
	.else
		mov timer_lab, T_LAB_INITIAL
		mov t_lab_curr_length, T_LAB_CHAR_LENGTH
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
		mov timer_class, eax
		mov ebx, T_CLASS_CHAR_LENGTH
		mul ebx
		mov edx, 0
		mov ebx, T_CLASS_INITIAL
		div ebx; Now eax holds the number of spaces that should be filled for the timer
		.if eax > T_CLASS_CHAR_LENGTH
			mov eax, T_CLASS_CHAR_LENGTH
		.endif
		.if eax < 0
			mov eax, 0
		.endif
		.if al != t_class_curr_length
			mov dh, T_CLASS_POS_Y
			mov dl, al
			add dl, T_CLASS_POS_X
			call BufGotoxy

			mov edx, OFFSET t_class_text
			add edx, eax
			mov eax, white + (black * 16)
			call BufSetTextColor
			call BufWriteString

			mov t_class_curr_length, al
		.endif
	.else
		mov eax, timer_lab
		sub eax, curr_time
		add eax, prev_time
		mov timer_lab, eax
		mov ebx, T_LAB_CHAR_LENGTH
		mul ebx
		mov edx, 0
		mov ebx, T_LAB_INITIAL
		div ebx; Now eax holds the number of spaces that should be filled for the timer
		.if eax > T_LAB_CHAR_LENGTH
			mov eax, T_LAB_CHAR_LENGTH
		.endif
		.if eax < 0
			mov eax, 0
		.endif
		.if al != t_lab_curr_length
			mov dh, T_LAB_POS_Y
			mov dl, al
			add dl, T_LAB_POS_X
			call BufGotoxy

			mov edx, OFFSET t_lab_text
			add edx, eax
			mov eax, white + (black * 16)
			call BufSetTextColor
			call BufWriteString

			mov t_lab_curr_length, al
		.endif
	.endif

	mov eax, curr_time
	mov prev_time, eax
	ret
UpdateTimers ENDP

DrawTimers PROC
	.if curr_timer == 0
	mov eax, timer_class
	mov ebx, T_CLASS_CHAR_LENGTH
	mul ebx
	mov edx, 0
	mov ebx, T_CLASS_INITIAL
	div ebx
	; Now eax holds the number of spaces that should be filled for the timer

	mov dh, 24
	mov dl, 0
	call BufGotoxy

	mov eax, black + (white * 16)
	call BufSetTextColor

	mov edx, OFFSET t_class_text
	call BufWriteString
	.else
	mov eax, timer_lab
	mov ebx, T_LAB_CHAR_LENGTH
	mul ebx
	mov edx, 0
	mov ebx, T_LAB_INITIAL
	div ebx
	; Now eax holds the number of spaces that should be filled for the timer

	mov dh, 24
	mov dl, 0
	call BufGotoxy

	mov eax, black + (white * 16)
	call BufSetTextColor

	mov edx, OFFSET t_lab_text
	call BufWriteString
	.endif

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
    ; subtract 5000 ms
    cmp curr_timer, 0
    je apply_to_quiz

    ; apply to lab timer
    sub timer_lab, 5000
    cmp timer_lab, 0
    jge done
    mov timer_lab, 0
    jmp done

apply_to_quiz:
    sub timer_class, 5000
    cmp timer_class, 0
    jge done
    mov timer_class, 0

done:
    ret
ApplyDinoPenalty ENDP


END