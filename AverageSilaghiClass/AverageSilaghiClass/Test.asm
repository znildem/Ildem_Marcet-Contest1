; Handles quiz question loading and display for the left panel

INCLUDE Irvine32.inc

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
quizFileMed  BYTE "quiz_questions_med.txt", 0
quizFileHard BYTE "quiz_questions_hard.txt", 0

labFileEasy  BYTE "lab_questions_easy.txt", 0
labFileMed   BYTE "lab_questions_med.txt", 0
labFileHard  BYTE "lab_questions_hard.txt", 0

quizBuffer      BYTE QUESTION_BUF_SIZE DUP(?)
quizBytesRead   DWORD ?

; Parallel arrays: byte offset of each question's start, and its blank start/length
questionOffsets     DWORD MAX_QUESTIONS DUP(?)
questionBlankStart  BYTE  MAX_QUESTIONS DUP(?) ; col offset of '_' run within the line
questionBlankLen    BYTE  MAX_QUESTIONS DUP(?) ; number of '_' chars
numQuestions        BYTE 0

PUBLIC currQuestion
currQuestion        BYTE 0

; Answers typed by the player (one slot per question, max 20 chars each)
ANSWER_MAX_LEN = 20
playerAnswers   BYTE MAX_QUESTIONS * ANSWER_MAX_LEN DUP(0)

.code
PUBLIC LoadQuiz
PUBLIC LoadLab
PUBLIC DrawQuiz
PUBLIC GetCurrQuestion
PUBLIC GetNumQuestions
PUBLIC GetBlankLen
PUBLIC GetAnswerBuf

; Shared parse logic - call after OpenInputFile, eax = handle
LoadAndParse PROC
    ; Read into buffer
    mov edx, OFFSET quizBuffer
    mov ecx, QUESTION_BUF_SIZE - 1
    call ReadFromFile
    mov quizBytesRead, eax
    mov BYTE PTR [quizBuffer + eax], 0

    ; Clear answer buffer
    push ecx
    push edi
    mov ecx, MAX_QUESTIONS * ANSWER_MAX_LEN
    mov edi, OFFSET playerAnswers
    xor eax, eax
    rep stosb
    pop edi
    pop ecx

    ; Clear blank arrays so question 0 starts clean
    push ecx
    push edi
    mov ecx, MAX_QUESTIONS
    mov edi, OFFSET questionBlankStart
    xor eax, eax
    rep stosb
    mov ecx, MAX_QUESTIONS
    mov edi, OFFSET questionBlankLen
    rep stosb
    pop edi
    pop ecx

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
        jne parse_count_blank

        ; First '_' on this line - record its col offset
        mov eax, edx
        sub eax, ecx
        mov BYTE PTR questionBlankStart[ebx], al

        parse_count_blank:
        movzx ebx, numQuestions
        inc BYTE PTR questionBlankLen[ebx]
        jmp parse_next

        parse_newline:
        movzx ebx, numQuestions
        mov questionOffsets[ebx * 4], ecx

        inc numQuestions
        mov al, numQuestions
        cmp al, MAX_QUESTIONS
        jge parse_done

        movzx ebx, numQuestions
        mov BYTE PTR questionBlankStart[ebx], 0
        mov BYTE PTR questionBlankLen[ebx], 0

        mov ecx, edx
        inc ecx
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
    ret
LoadAndParse ENDP

; Loads quiz questions from a difficulty file
; IN: eax = 0=easy, 1=med, 2=hard
LoadQuiz PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi

    .if eax == 0
        mov edx, OFFSET quizFileEasy
    .elseif eax == 1
        mov edx, OFFSET quizFileMed
    .else
        mov edx, OFFSET quizFileHard
    .endif
    call OpenInputFile
    call LoadAndParse

    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
LoadQuiz ENDP

; Loads lab questions from a difficulty file
; IN: eax = 0=easy, 1=med, 2=hard
LoadLab PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi

    .if eax == 0
        mov edx, OFFSET labFileEasy
    .elseif eax == 1
        mov edx, OFFSET labFileMed
    .else
        mov edx, OFFSET labFileHard
    .endif
    call OpenInputFile
    call LoadAndParse

    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
LoadLab ENDP

; Draws all questions in the left panel
DrawQuiz PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov ecx, 0                              ; question index
    draw_loop:
        mov al, numQuestions
        cmp cl, al
        jge draw_done

        mov dh, cl
        add dh, PANEL_TOP
        mov dl, PANEL_LEFT
        call Gotoxy

        movzx ebx, cl
        mov eax, questionOffsets[ebx * 4]  ; eax = buf offset of line start
        mov edx, 0                          ; edx = col counter within line

        print_line_loop:
            mov esi, OFFSET quizBuffer
            mov bl, BYTE PTR [esi + eax]
            cmp bl, 0
            je print_line_done
            cmp bl, 0Dh
            je print_line_done
            cmp bl, 0Ah
            je print_line_done

            ; Is this col inside the blank run?
            ; blank start and len are indexed by question (cl), not col (edx)
            movzx esi, cl
            movzx esi, BYTE PTR questionBlankStart[esi]  ; esi = blank start col
            cmp edx, esi
            jl print_normal_char

            movzx ebx, cl
            movzx ebx, BYTE PTR questionBlankLen[ebx]    ; ebx = blank length
            add ebx, esi                                 ; ebx = blank end col
            cmp edx, ebx
            jge print_normal_char

            ; --- Inside blank ---
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

            ; answer index = col - blank start
            ; esi still holds blank start col here
            mov ebx, edx
            sub ebx, esi                    ; ebx = index into answer buffer

            ; answer buffer = playerAnswers + (question * ANSWER_MAX_LEN)
            push eax
            movzx eax, cl                   ; eax = question index
            push edx
            mov edx, ANSWER_MAX_LEN
            mul edx                         ; eax = question * ANSWER_MAX_LEN
            pop edx
            add eax, OFFSET playerAnswers
            mov al, BYTE PTR [eax + ebx]    ; al = answer char at index
            cmp al, 0
            jne print_blank_char
            mov al, '_'
            print_blank_char:
            ; al has the char to print, but we need to restore eax after
            push eax
            pop ebx                         ; bl = char to print
            pop eax                         ; restore eax (buf offset)
            mov al, bl
            call WriteChar
            jmp print_advance

            ; --- Normal character ---
            print_normal_char:
            push eax
            mov eax, white + (black * 16)
            call SetTextColor
            pop eax

            mov esi, OFFSET quizBuffer
            mov al, BYTE PTR [esi + eax]
            call WriteChar

            print_advance:
            inc edx
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
; Does NOT clobber eax
GetAnswerBuf PROC
    push eax
    push ebx
    movzx eax, al
    mov ebx, ANSWER_MAX_LEN
    mul ebx
    add eax, OFFSET playerAnswers
    mov edx, eax
    pop ebx
    pop eax
    ret
GetAnswerBuf ENDP

END