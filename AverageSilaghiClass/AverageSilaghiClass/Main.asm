; Main file to control execution

INCLUDE Irvine32.inc

menu PROTO; runs the menu

.code

main PROC
	call menu
	exit
main ENDP

END main