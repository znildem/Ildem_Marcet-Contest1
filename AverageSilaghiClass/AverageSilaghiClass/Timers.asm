; Timers handling will be done in this file
; This does NOT handle midnight change, just dont play at midnight :P

INCLUDE Irvine32.inc

FindArrString PROTO

.data
; Last call time
prev_time DWORD ?
curr_time DWORD ?

; Timer for the class duration
T_CLASS_INITIAL = 100000 ; 100 seconds in ms
T_CLASS_CHAR_LENGTH = 80
T_CLASS_POS_X = 0
T_CLASS_POS_Y = 24
timer_class DWORD ?
t_class_text BYTE "QUIZ DEADLINE                                                                   ", 0
t_class_curr_length BYTE ?


.code
PUBLIC UpdateTimers
PUBLIC StartTimers

StartTimers PROC
	call GetMseconds
	mov prev_time, eax

	mov timer_class, T_CLASS_INITIAL
	mov t_class_curr_length, T_CLASS_CHAR_LENGTH

	call DrawTimers

	ret
StartTimers ENDP

UpdateTimers PROC
	call GetMseconds
	mov curr_time, eax

	mov eax, timer_class
	sub eax, curr_time
	add eax, prev_time
	mov timer_class, eax
	mov ebx, T_CLASS_CHAR_LENGTH
	mul ebx
	mov edx, 0
	mov ebx, T_CLASS_INITIAL
	div ebx; Now eax holds the number of spaces that should be filled for the timer
	.if eax < 0
		mov eax, 0
	.endif
	.if al != t_class_curr_length
		mov dh, T_CLASS_POS_Y
		mov dl, al
		add dl, T_CLASS_POS_X
		call Gotoxy

		mov edx, OFFSET t_class_text
		add edx, eax
		mov eax, white + (black * 16)
		call SetTextColor
		call WriteString

		mov t_class_curr_length, al
	.endif

		
		

	mov eax, curr_time
	mov prev_time, eax
	ret
UpdateTimers ENDP

DrawTimers PROC
	mov eax, timer_class
	mov ebx, T_CLASS_CHAR_LENGTH
	mul ebx
	mov edx, 0
	mov ebx, T_CLASS_INITIAL
	div ebx
	; Now eax holds the number of spaces that should be filled for the timer

	mov dh, 24
	mov dl, 0
	call Gotoxy

	mov eax, black + (white * 16)
	call SetTextColor

	mov edx, OFFSET t_class_text
	call WriteString

	ret
DrawTimers ENDP

END