; Handles player input for the quiz panel

INCLUDE Irvine32.inc

GetCurrQuestion PROTO
GetNumQuestions PROTO
GetBlankLen PROTO
GetAnswerBuf PROTO
DrawBase PROTO
DrawQuiz PROTO

EXTERN currQuestion:BYTE

.data
saved_key BYTE ?

.code
PUBLIC HandleInput

; Reads one key and updates the answer buffer or switches question
; OUT: al = key pressed (caller checks for Enter to exit loop)
HandleInput PROC
    push ebx
    push ecx
    push edx
    push esi

    call ReadChar
    mov saved_key, al

    cmp al, 0              ; special key first byte
    je check_special

    cmp al, 08h            ; backspace
    je do_backspace

    cmp al, 0Dh            ; enter - pass through to caller
    je handle_input_done

    ; Regular character
    call GetCurrQuestion
    call GetBlankLen        ; al = max length for curr question
    mov bl, al              ; bl = max length

    call GetCurrQuestion
    call GetAnswerBuf       ; edx = answer buffer address

    ; Find current length of answer
    mov ecx, 0
    find_answer_end:
        cmp BYTE PTR [edx + ecx], 0
        je found_answer_end
        inc ecx
        cmp cl, bl
        jge handle_input_done   ; buffer full, ignore
        jmp find_answer_end
    found_answer_end:

    mov al, saved_key
    mov BYTE PTR [edx + ecx], al
    jmp redraw

    do_backspace:
    call GetCurrQuestion
    call GetAnswerBuf       ; edx = answer buffer address

    mov ecx, 0
    find_back_end:
        cmp BYTE PTR [edx + ecx], 0
        je found_back_end
        inc ecx
        jmp find_back_end
    found_back_end:

    cmp ecx, 0
    je handle_input_done

    dec ecx
    mov BYTE PTR [edx + ecx], 0
    jmp redraw

    check_special:
    call ReadChar           ; get scan code into al
    cmp al, 72             ; up arrow
    je do_up
    cmp al, 80             ; down arrow
    je do_down
    jmp handle_input_done

    do_up:
    cmp currQuestion, 0
    je handle_input_done
    dec currQuestion
    jmp redraw

    do_down:
    call GetNumQuestions    ; al = numQuestions
    mov bl, al
    dec bl
    cmp currQuestion, bl
    jge handle_input_done
    inc currQuestion

    redraw:
    call DrawBase
    call DrawQuiz

    handle_input_done:
    mov al, saved_key
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
HandleInput ENDP

END