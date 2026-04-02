; Handles player input for the quiz panel

INCLUDE Irvine32.inc

GetNumQuestions PROTO
GetBlankLen PROTO
GetAnswerBuf PROTO
DrawBase PROTO
DrawQuiz PROTO

EXTERN currQuestion:BYTE

.data
saved_key BYTE 0

.code
PUBLIC HandleInput

; Non-blocking. Call every loop iteration alongside timers etc.
; OUT: al = character key pressed (0 if nothing, or special key)
;      arrow keys update currQuestion directly
HandleInput PROC
    push ebx
    push ecx
    push edx
    push esi

    call ReadKey            ; non-blocking: ah=0 if no key pressed
    cmp ah, 0
    je no_key_pressed       ; nothing in buffer, return 0

    ; Something was pressed
    mov saved_key, al

    cmp al, 0              ; special key: scan code is in ah
    je check_special

    cmp al, 08h            ; backspace
    je do_backspace

    cmp al, 0Dh            ; enter
    je handle_input_done

    ; Regular printable character
    mov al, currQuestion
    call GetBlankLen        ; al = blank length for current question
    mov bl, al              ; bl = max length

    mov al, currQuestion
    call GetAnswerBuf       ; edx = answer buffer for current question

    ; Scan for first null (end of current answer)
    mov ecx, 0
    find_answer_end:
        cmp BYTE PTR [edx + ecx], 0
        je found_answer_end
        inc ecx
        cmp cl, bl
        jge no_key_pressed  ; blank is full, ignore keypress
        jmp find_answer_end
    found_answer_end:

    mov al, saved_key
    mov BYTE PTR [edx + ecx], al
    jmp redraw

    do_backspace:
    mov al, currQuestion
    call GetAnswerBuf       ; edx = answer buffer

    mov ecx, 0
    find_back_end:
        cmp BYTE PTR [edx + ecx], 0
        je found_back_end
        inc ecx
        jmp find_back_end
    found_back_end:

    cmp ecx, 0
    je no_key_pressed       ; nothing to delete

    dec ecx
    mov BYTE PTR [edx + ecx], 0
    jmp redraw

    check_special:
    cmp ah, 72             ; up arrow scan code
    je do_up
    cmp ah, 80             ; down arrow scan code
    je do_down
    jmp no_key_pressed

    do_up:
    cmp currQuestion, 0
    je no_key_pressed
    dec currQuestion
    jmp redraw

    do_down:
    call GetNumQuestions    ; al = numQuestions
    mov bl, al
    dec bl                  ; bl = max index
    cmp currQuestion, bl
    jge no_key_pressed
    inc currQuestion

    redraw:
    call DrawBase
    call DrawQuiz
    mov al, saved_key
    jmp handle_input_done

    no_key_pressed:
    mov al, 0

    handle_input_done:
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
HandleInput ENDP

END