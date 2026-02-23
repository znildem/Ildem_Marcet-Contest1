; Useful procedures

INCLUDE Irvine32.inc


.code
PUBLIC FindArrString

; Given a string array and an index number returns the start point of the ith string
; IN
;	eax: index(in terms of string array)
;	esi: array offset
; OUT
;	eax: index(in terms of byte array)
FindArrString PROC
	push ecx

	; If input index is 0, return immediately
	.IF eax == 0
		jmp procedure_end
	.ENDIF


	mov ecx, 0
	loop_start:
		.if BYTE PTR[esi + ecx] == 0; If we found an end of string
			dec eax
			jnz loop_continue; if not done, continue
			inc ecx; off - by - one correction
			jmp loop_end
		.endif
		loop_continue :
		inc ecx
		jmp loop_start
	loop_end :

	mov eax, ecx

	procedure_end :
	pop ecx
	ret
FindArrString ENDP

END