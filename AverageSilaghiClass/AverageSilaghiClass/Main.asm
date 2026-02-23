; Main file to control execution

INCLUDE Irvine32.inc

MainMenu PROTO; runs the menu

.code

Main PROC
	call MainMenu
	exit
Main ENDP

END Main