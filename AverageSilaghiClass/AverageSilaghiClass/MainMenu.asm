; This will handle most of the main menu stuff

INCLUDE Irvine32.inc

FindArrString PROTO

.data
space BYTE ' '
newLine BYTE 0Dh, 0Ah

; Title information
gameTitle BYTE "An Average Class with Dr. Silaghi...", 0

; Menu options information
menuOptions BYTE	"START", 0,
					"CREDITS", 0,
					"EXIT", 0
numOfMenuOptions BYTE 3
currMenuOption BYTE 0
menuOptionsStartRow BYTE 2

; Credits information
creditsTextFile BYTE "credits.txt", 0
CREDITS_BUFFER_SIZE = 5000
creditsBuffer BYTE CREDITS_BUFFER_SIZE DUP(?)
creditsBytesRead DWORD ?

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
			call EnterPressed
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
	call Clrscr
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

EnterPressed PROC
	.if currMenuOption == 0
		; Here goes game start code
	.elseif currMenuOption == 1
		call Credits
	.else
		; Here goes exit game code
	.endif
	ret
EnterPressed ENDP

Credits PROC
	mov edx, OFFSET creditsTextFile
	call OpenInputFile
	mov edx, OFFSET creditsBuffer
	mov ecx, CREDITS_BUFFER_SIZE
	call ReadFromFile
	mov creditsBytesRead, eax

	call Clrscr
	mov eax, white + (black * 16)
	call SetTextColor
	mov edx, OFFSET creditsBuffer
	call WriteString
	call ReadChar
	ret
Credits ENDP

END