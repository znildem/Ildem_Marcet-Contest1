; Handles quiz question loading and display for the left panel

INCLUDE Irvine32.inc

FindChar PROTO
GetLineStart PROTO
GetLineLength PROTO

; Left panel interior bounds
PANEL_LEFT   = 1
PANEL_TOP    = 1
PANEL_WIDTH  = 37
PANEL_HEIGHT = 22

; Max questions and line buffer
MAX_QUESTIONS       = 20
QUESTION_BUF_SIZE   = 2000

.data
quizFileEasy BYTE "quiz_questions_easy.txt", 0
quizFileMed  BYTE "Quiz\questions_med.txt", 0
quizFileHard BYTE "Quiz\questions_hard.txt", 0

quizBuffer      BYTE QUESTION_BUF_SIZE DUP(?)
quizBytesRead   DWORD ?

; Parallel arrays: byte offset of each question's start, and its blank start/length
questionOffsets     DWORD MAX_QUESTIONS DUP(?)
questionBlankStart  BYTE  MAX_QUESTIONS DUP(?) ; col offset of '_' run within the line
questionBlankLen    BYTE  MAX_QUESTIONS DUP(?) ; number of '_' chars
numQuestions        BYTE 0

currQuestion        BYTE 0

; Answers typed by the player (one slot per question, max 20 chars each)
ANSWER_MAX_LEN = 20
playerAnswers   BYTE MAX_QUESTIONS * ANSWER_MAX_LEN DUP(0)

parse_line_index DWORD ?

.code
PUBLIC LoadQuiz
PUBLIC DrawQuiz
PUBLIC GetCurrQuestion
PUBLIC GetNumQuestions
PUBLIC GetBlankLen
PUBLIC GetAnswerBuf

; Loads questions from a difficulty file and parses them
; IN
;   eax: 0=easy, 1=med, 2=hard
; OUT
;   (fills quizBuffer, questionOffsets, questionBlankStart, questionBlankLen, numQuestions)
LoadQuiz PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi

    ; Open the correct file
    .if eax == 0
        mov edx, OFFSET quizFileEasy
    .elseif eax == 1
        mov edx, OFFSET quizFileMed
    .else
        mov edx, OFFSET quizFileHard
    .endif
    call OpenInputFile

    ; Read into buffer
    mov edx, OFFSET quizBuffer
    mov ecx, QUESTION_BUF_SIZE - 1
    call ReadFromFile
    mov quizBytesRead, eax
    mov BYTE PTR [quizBuffer + eax], 0

    ; Parse buffer in one pass
    mov numQuestions, 0
    mov esi, OFFSET quizBuffer
    mov edx, 0              ; current byte offset
    mov ecx, 0              ; current line start offset

    parse_loop:
        mov bl, BYTE PTR [esi + edx]
        cmp bl, 0
        je parse_done

        cmp bl, 0Ah         ; LF = end of line
        je parse_newline

        cmp bl, '_'         ; found a blank character
        jne parse_next

        ; Check if this is the first '_' on this line
        movzx ebx, numQuestions
        cmp BYTE PTR questionBlankLen[ebx], 0
        jne parse_count_blank   ; already found the start, just count

        ; First '_' on this line - record its col offset
        mov eax, edx
        sub eax, ecx            ; col = current offset - line start
        mov BYTE PTR questionBlankStart[ebx], al

        parse_count_blank:
        movzx ebx, numQuestions
        inc BYTE PTR questionBlankLen[ebx]
        jmp parse_next

        parse_newline:
        ; Store line start and move to next
        movzx ebx, numQuestions
        mov questionOffsets[ebx * 4], ecx

        inc numQuestions
        mov al, numQuestions
        cmp al, MAX_QUESTIONS
        jge parse_done

        ; Reset blank tracking for next question
        movzx ebx, numQuestions
        mov BYTE PTR questionBlankStart[ebx], 0
        mov BYTE PTR questionBlankLen[ebx], 0

        mov ecx, edx
        inc ecx             ; next line starts after the LF
        inc edx
        jmp parse_loop

        parse_next:
        inc edx
        jmp parse_loop

    parse_done:
    ; Handle last line if file doesn't end with newline
    cmp edx, ecx
    je last_line_skip
    movzx ebx, numQuestions
    mov questionOffsets[ebx * 4], ecx
    inc numQuestions
    last_line_skip:

    mov currQuestion, 0

    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
LoadQuiz ENDP

; Draws all questions in the left panel
; Highlights the blank of the currently selected question in white-on-black inverse
DrawQuiz PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov ecx, 0                          ; question index
    draw_loop:
        mov al, numQuestions
        cmp cl, al
        jge draw_done

        ; Position cursor: row = PANEL_TOP + question index, col = PANEL_LEFT
        mov dh, cl
        add dh, PANEL_TOP
        mov dl, PANEL_LEFT
        call Gotoxy

        ; Default color
        mov eax, white + (black * 16)
        call SetTextColor

        ; Print the line character by character so we can swap color on the blank
        movzx ebx, cl                   ; ebx = question index
        mov eax, questionOffsets[ebx * 4]
        mov esi, OFFSET quizBuffer
        mov edx, 0                      ; col counter within line

        print_line_loop:
            mov al, BYTE PTR [esi + eax]
            cmp al, 0
            je print_line_done
            cmp al, 0Dh
            je print_line_done
            cmp al, 0Ah
            je print_line_done

            ; Check if we're inside the blank run
            movzx ebx, cl
            movzx ebx, BYTE PTR questionBlankStart[ebx]
            cmp edx, ebx
            jl not_in_blank
            movzx ebx, cl
            movzx ebx, BYTE PTR questionBlankStart[ebx]
            movzx esi, cl
            movzx esi, BYTE PTR questionBlankLen[esi]
            add ebx, esi
            cmp edx, ebx
            jge not_in_blank

            ; Inside blank: highlight if this is the selected question
            .if cl == currQuestion
                push eax
                mov eax, black + (white * 16)
                call SetTextColor
                pop eax
            .else
                push eax
                mov eax, white + (black * 16)
                call SetTextColor
                pop eax
            .endif
            jmp do_print

            not_in_blank:
            push eax
            mov eax, white + (black * 16)
            call SetTextColor
            pop eax

            do_print:
            ; Reload esi (was clobbered above)
            push eax
            mov esi, OFFSET quizBuffer
            pop eax

            call WriteChar
            inc edx

            ; Reload line base offset for next iteration
            movzx ebx, cl
            mov eax, questionOffsets[ebx * 4]
            add eax, edx

            jmp print_line_loop

        print_line_done:
        inc ecx
        jmp draw_loop

    draw_done:
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
DrawQuiz ENDP

; Returns currQuestion in al
GetCurrQuestion PROC
    mov al, currQuestion
    ret
GetCurrQuestion ENDP

; Returns numQuestions in al
GetNumQuestions PROC
    mov al, numQuestions
    ret
GetNumQuestions ENDP

; Returns the blank length of question N in al
; IN: al = question index
GetBlankLen PROC
    movzx eax, al
    mov al, BYTE PTR questionBlankLen[eax]
    ret
GetBlankLen ENDP

; Returns in edx the address of the answer buffer for question N
; IN: al = question index
GetAnswerBuf PROC
    movzx eax, al
    mov edx, ANSWER_MAX_LEN
    mul edx
    add eax, OFFSET playerAnswers
    mov edx, eax
    ret
GetAnswerBuf ENDP

END