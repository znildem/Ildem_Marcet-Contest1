; This will handle most of the main menu stuff

INCLUDE Irvine32.inc

.data
space BYTE ' '
newLine BYTE 0Dh, 0Ah

gameTitle BYTE "An Average Class with Dr. Silaghi...", 0

menuOptions BYTE	"START", 0,
					"CREDITS", 0,
					"EXIT", 0
numOfMenuOptions BYTE 3
currMenuOption BYTE 0
menuOptionsStartRow BYTE 2

.code
PUBLIC MainMenu

; Main menu function
; OUT:
;	al: currMenuOption
MainMenu PROC
	main_loop_start:
		call WriteMenu
		call ReadKey
		.if al == 0Dh
			jmp procedure_end
		.elseif al == 0 ; Special Character
			.if ah == 72 ; UP ARROW
				.if currMenuOption > 0
					dec currMenuOption
				.endif
			.elseif ah == 80 ; DOWN ARROW
				mov al, numOfMenuOptions
				dec al
				.if currMenuOption < al
					inc currMenuOption
				.endif
			.endif
		.endif

		jmp main_loop_start
	procedure_end:
	mov al, currMenuOption
	ret
MainMenu ENDP

WriteMenu PROC
	; Writing title
	mov dh, 0
	mov dl, 0
	call Gotoxy
	mov eax, white + (black * 16)
	call SetTextColor
	mov edx, OFFSET gameTitle
	call WriteString

	; Writing menu options
	mov ecx, 0
	options_loop_start:

		; Setting white for selected option
		.if cl == currMenuOption
			mov eax, black + (white * 16)
		.else
			mov eax, white + (black * 16)
		.endif
		call SetTextColor
		
		mov dh, cl
		add dh, menuOptionsStartRow
		mov dl, 0
		call Gotoxy
		
		mov eax, ecx
		mov esi, OFFSET menuOptions
		call FindArrString
		
		mov edx, OFFSET menuOptions
		add edx, eax
		call WriteString
		
		inc ecx
		cmp cl, numOfMenuOptions
		jne options_loop_start

	ret
WriteMenu ENDP

; Given a string array and an index number returns the start point of the ith string
; IN
;	eax: index (in terms of string array)
;	esi: array offset
; OUT
;	eax: index (in terms of byte array)
FindArrString PROC
	push ecx
	
	; If input index is 0, return immediately
	.IF eax == 0
		jmp procedure_end
	.ENDIF
	
	
	mov ecx, 0
	loop_start:
		.if BYTE PTR [esi + ecx] == 0 ; If we found an end of string
			dec eax
			jnz loop_continue ; if not done, continue
			inc ecx ; off-by-one correction
			jmp loop_end
		.endif
	loop_continue:
		inc ecx
		jmp loop_start
	loop_end:
	
	mov eax, ecx
	
	procedure_end:
	pop ecx
	ret
FindArrString ENDP

END