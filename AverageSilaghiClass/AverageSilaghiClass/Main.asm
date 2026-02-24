; Main file to control execution

INCLUDE Irvine32.inc

MainMenu PROTO; runs the menu
StartTimers PROTO
UpdateTimers PROTO
DrawTimer PROTO

.code

Main PROC
	call MainMenu
	.if al == 3 ; Exit option
		jmp procedure_end
	.elseif al == 0 ; Start option
		call StartGame
	.endif

	procedure_end:
	exit
Main ENDP

StartGame PROC
	call StartTimers
	abc:
	call UpdateTimers
	call DrawTimer
	mov eax, 1000
	call Delay
	jmp abc
StartGame ENDP

END Main