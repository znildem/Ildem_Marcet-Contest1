; Timers handling will be done in this file
; This does NOT handle midnight change, just dont play at midnight :P

INCLUDE Irvine32.inc

FindArrString PROTO

.data
; Last call time
prev_time DWORD ?
curr_time DWORD ?

; Timer 1 information
T1_INITIAL = 100000 ; 100 seconds in ms
t1_remaining DWORD ?


; Drawing information
lineBuffer BYTE 80 DUP(' '), 0

.code
PUBLIC UpdateTimers
PUBLIC StartTimers

StartTimers PROC
	call GetMseconds
	mov prev_time, eax

	mov t1_remaining, T1_INITIAL

	ret
StartTimers ENDP

UpdateTimers PROC
	call GetMseconds
	mov curr_time, eax

	mov eax, t1_remaining
	sub eax, curr_time
	add eax, prev_time
	mov t1_remaining, eax

	mov eax, curr_time
	mov prev_time, eax
	ret
UpdateTimers ENDP

DrawTimer PROC
	mov eax, t1_remaining
	mov ebx, 80
	mul ebx
	mov edx, 0
	mov ebx, T1_INITIAL
	div ebx
	; Now eax holds the number of spaces that should be filled for the timer

	mov dh, 24
	mov dl, 0
	call Gotoxy

	push eax
	mov eax, (black * 16)
	call SetTextColor
	pop eax

	mov edx, OFFSET lineBuffer
	call WriteString

	mov dh, 24
	mov dl, 0
	call Gotoxy

	push eax
	mov eax, (white * 16)
	call SetTextColor
	pop eax

	.if eax == 80
		mov edx, OFFSET lineBuffer
		call WriteString
	.elseif eax < 80
		mov edx, OFFSET lineBuffer
		mov [(OFFSET lineBuffer)+eax], 0
		call WriteString
		mov [(OFFSET lineBuffer)+eax], ' '
	.endif

	ret
DrawTimer ENDP

END