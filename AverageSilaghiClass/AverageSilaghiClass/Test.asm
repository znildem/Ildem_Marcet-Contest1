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

questionOffsets     DWORD MAX_QUESTIONS DUP(?)
questionBlankStart  BYTE  MAX_QUESTIONS DUP(?)
questionBlankLen    BYTE  MAX_QUESTIONS DUP(?)
numQuestions        BYTE 0

PUBLIC currQuestion
currQuestion        BYTE 0

ANSWER_MAX_LEN = 20
playerAnswers   BYTE MAX_QUESTIONS * ANSWER_MAX_LEN DUP(0)

; Temporary storage for DrawQuiz blank rendering to avoid register conflicts
dq_answer_char  BYTE 0
dq_col_save     DWORD 0

.code
PUBLIC LoadQuiz
PUBLIC LoadLab
PUBLIC DrawQuiz
PUBLIC GetCurrQuestion
PUBLIC GetNumQuestions
PUBLIC GetBlankLen
PUBLIC GetAnswerBuf

LoadAndParse PROC
    mov edx, OFFSET quizBuffer
    mov ecx, QUESTION_BUF_SIZE - 1
    call ReadFromFile
    mov quizBytesRead, eax
    mov BYTE PTR [quizBuffer + eax], 0

    push ecx
    push edi
    mov ecx, MAX_QUESTIONS * ANSWER_MAX_LEN
    mov edi, OFFSET playerAnswers
    xor eax, eax
    rep stosb
    mov ecx, MAX_QUESTIONS
    mov edi, OFFSET questionBlankStart
    rep stosb
    mov ecx, MAX_QUESTIONS
    mov edi, OFFSET questionBlankLen
    rep stosb
    pop edi
    pop ecx

    mov numQuestions, 0
    mov esi, OFFSET quizBuffer
    mov edx, 0
    mov ecx, 0

    parse_loop:
        mov bl, BYTE PTR [esi + edx]
        cmp bl, 0
        je parse_done
        cmp bl, 0Ah
        je parse_newline
        cmp bl, '_'
        jne parse_next

        movzx ebx, numQuestions
        cmp BYTE PTR questionBlankLen[ebx], 0
        jne parse_count_blank
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
    cmp edx, ecx
    je last_line_skip
    movzx ebx, numQuestions
    mov questionOffsets[ebx * 4], ecx
    inc numQuestions
    last_line_skip:

    mov currQuestion, 0
    ret
LoadAndParse ENDP

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
; Uses dq_answer_char and dq_col_save as scratch to avoid register conflicts
DrawQuiz PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov ecx, 0
    draw_loop:
        mov al, numQuestions
        cmp cl, al
        jge draw_done

        mov dh, cl
        add dh, PANEL_TOP
        mov dl, PANEL_LEFT
        call Gotoxy

        movzx ebx, cl
        mov eax, questionOffsets[ebx * 4]
        mov edx, 0

        print_line_loop:
            mov esi, OFFSET quizBuffer
            mov bl, BYTE PTR [esi + eax]
            cmp bl, 0
            je print_line_done
            cmp bl, 0Dh
            je print_line_done
            cmp bl, 0Ah
            je print_line_done

            ; blank start col for this question
            movzx esi, cl
            movzx esi, BYTE PTR questionBlankStart[esi]
            cmp edx, esi
            jl print_normal_char

            movzx ebx, cl
            movzx ebx, BYTE PTR questionBlankLen[ebx]
            add ebx, esi
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

            ; save col counter so mul can't clobber it
            mov dq_col_save, edx

            ; answer index = col - blank start (esi = blank start col)
            mov ebx, edx
            sub ebx, esi                    ; ebx = index into answer buffer

            ; answer buffer = playerAnswers + (question * ANSWER_MAX_LEN)
            push eax                        ; save buf offset
            movzx eax, cl
            mov esi, ANSWER_MAX_LEN
            mul esi                         ; eax = q*ANSWER_MAX_LEN, edx = 0 (small)
            add eax, OFFSET playerAnswers
            mov al, BYTE PTR [eax + ebx]
            cmp al, 0
            jne store_answer_char
            mov al, '_'
            store_answer_char:
            mov dq_answer_char, al
            pop eax                         ; restore buf offset

            ; restore col counter
            mov edx, dq_col_save

            mov al, dq_answer_char
            call WriteChar
            jmp print_advance

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

GetCurrQuestion PROC
    mov al, currQuestion
    ret
GetCurrQuestion ENDP

GetNumQuestions PROC
    mov al, numQuestions
    ret
GetNumQuestions ENDP

GetBlankLen PROC
    movzx eax, al
    mov al, BYTE PTR questionBlankLen[eax]
    ret
GetBlankLen ENDP

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