; Main file to control execution

INCLUDE Irvine32.inc

MainMenu PROTO; runs the menu
StartTimers PROTO
UpdateTimers PROTO
DrawTimer PROTO

.code

Main PROC
	call MainMenu
	call StartGame
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