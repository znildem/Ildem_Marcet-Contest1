; Useful procedures

INCLUDE Irvine32.inc

.data
cmdSizeLimiter BYTE "mode con: cols=80 lines=25", 0

.code
PUBLIC FindArrString
PUBLIC FindChar
PUBLIC GetLineStart
PUBLIC GetLineLength

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
		jmp find_arr_end
	.ENDIF

	mov ecx, 0
	find_arr_loop:
		.if BYTE PTR [esi + ecx] == 0 ; If we found an end of string
			dec eax
			jnz find_arr_continue ; if not done, continue
			inc ecx ; off-by-one correction
			jmp find_arr_loop_end
		.endif
		find_arr_continue:
		inc ecx
		jmp find_arr_loop
	find_arr_loop_end:

	mov eax, ecx

	find_arr_end:
	pop ecx
	ret
FindArrString ENDP

; Finds the first occurrence of a character in a buffer from a given offset
; IN
;   eax: starting byte offset into buffer
;   bl:  character to search for
;   esi: buffer offset
;   ecx: max bytes to scan
; OUT
;   eax: byte offset of found character, or -1 if not found
FindChar PROC
	push edx
	find_char_loop:
		cmp ecx, 0
		je find_char_not_found
		mov dl, BYTE PTR [esi + eax]
		cmp dl, 0
		je find_char_not_found
		cmp dl, bl
		je find_char_done
		inc eax
		dec ecx
		jmp find_char_loop
	find_char_not_found:
		mov eax, -1
	find_char_done:
	pop edx
	ret
FindChar ENDP

; Returns the byte offset of the start of line N (0-based) in a buffer
; IN
;   eax: line index
;   esi: buffer offset
; OUT
;   eax: byte offset of start of that line, or -1 if line not found
GetLineStart PROC
	push ebx
	push ecx
	push edx

	mov edx, eax        ; edx = lines remaining to skip
	mov eax, 0          ; eax = current byte offset

	.if edx == 0
		jmp get_line_start_done
	.endif

	get_line_start_loop:
		mov bl, BYTE PTR [esi + eax]
		cmp bl, 0
		je get_line_start_not_found
		cmp bl, 0Ah        ; LF
		je get_line_start_found_newline
		inc eax
		jmp get_line_start_loop
	get_line_start_found_newline:
		inc eax
		dec edx
		jnz get_line_start_loop
		jmp get_line_start_done
	get_line_start_not_found:
		mov eax, -1
	get_line_start_done:
	pop edx
	pop ecx
	pop ebx
	ret
GetLineStart ENDP

; Returns the length of a line (not counting CR/LF/null) starting at a byte offset
; IN
;   eax: byte offset of line start
;   esi: buffer base address
; OUT
;   eax: length in bytes
GetLineLength PROC
	push ebx
	push ecx

	mov ecx, 0
	get_line_len_loop:
		mov bl, BYTE PTR [esi + eax + ecx]
		cmp bl, 0
		je get_line_len_done
		cmp bl, 0Dh        ; CR
		je get_line_len_done
		cmp bl, 0Ah        ; LF
		je get_line_len_done
		inc ecx
		jmp get_line_len_loop
	get_line_len_done:
	mov eax, ecx
	pop ecx
	pop ebx
	ret
GetLineLength ENDP

END