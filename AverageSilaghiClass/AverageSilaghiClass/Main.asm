; Main file to control execution

INCLUDE Irvine32.inc

MainMenu PROTO; runs the menu
StartTimers PROTO
UpdateTimers PROTO
DrawTimer PROTO
SetConsoleSize PROTO
UpdateScreen PROTO
Game PROTO

.code

Main PROC
	game_loop:
	call MainMenu
	.if al == 3 ; Exit option
		jmp procedure_end
	.elseif al == 0 ; Start option
		call Game
	.endif
	jmp game_loop
	procedure_end:
	exit
Main ENDP

END Main