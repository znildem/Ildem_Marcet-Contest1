; Handles quiz/lab question loading and display

INCLUDE Irvine32.inc

BufGotoxy PROTO
BufSetTextColor PROTO
BufWriteString PROTO
BufWriteChar PROTO

QUIZ_PANEL_LEFT  = 1
LAB_PANEL_LEFT   = 39
PANEL_TOP        = 1

MAX_QUESTIONS    = 20
QUESTION_BUF_SIZE = 2000
ANSWER_MAX_LEN   = 20

.data

quizFileEasy BYTE "quiz_questions_easy.txt", 0
quizFileMed  BYTE "quiz_questions_medium.txt", 0
quizFileHard BYTE "quiz_questions_hard.txt", 0

labFileEasy  BYTE "lab_questions_easy.txt", 0
labFileMed   BYTE "lab_questions_medium.txt", 0
labFileHard  BYTE "lab_questions_hard.txt", 0

; Quiz data
quizBuffer       BYTE QUESTION_BUF_SIZE DUP(?)
quizBytesRead    DWORD ?
quizOffsets      DWORD MAX_QUESTIONS DUP(?)
quizBlankStart   BYTE  MAX_QUESTIONS DUP(?)
quizBlankLen     BYTE  MAX_QUESTIONS DUP(?)
numQuizQuestions BYTE 0
quizAnswers      BYTE MAX_QUESTIONS * ANSWER_MAX_LEN DUP(0)

; Lab data
labBuffer        BYTE QUESTION_BUF_SIZE DUP(?)
labBytesRead     DWORD ?
labOffsets       DWORD MAX_QUESTIONS DUP(?)
labBlankStart    BYTE  MAX_QUESTIONS DUP(?)
labBlankLen      BYTE  MAX_QUESTIONS DUP(?)
numLabQuestions  BYTE 0
labAnswers       BYTE MAX_QUESTIONS * ANSWER_MAX_LEN DUP(0)

; Which set is active for input: 0=quiz 1=lab
activeSet        BYTE 0

PUBLIC currQuestion
currQuestion     BYTE 0

; Scratch vars to avoid mul clobbering edx in draw procs
draw_col_save    DWORD 0
draw_answer_char BYTE 0

.code
PUBLIC LoadQuiz
PUBLIC LoadLab
PUBLIC DrawQuiz
PUBLIC DrawLab
PUBLIC GetCurrQuestion
PUBLIC GetNumQuestions
PUBLIC GetBlankLen
PUBLIC GetAnswerBuf

; --- ParseQuiz: parses quizBuffer into quiz arrays ---
ParseQuiz PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov ecx, MAX_QUESTIONS * ANSWER_MAX_LEN
    mov edi, OFFSET quizAnswers
    xor eax, eax
    rep stosb
    mov ecx, MAX_QUESTIONS
    mov edi, OFFSET quizBlankStart
    rep stosb
    mov ecx, MAX_QUESTIONS
    mov edi, OFFSET quizBlankLen
    rep stosb

    mov numQuizQuestions, 0
    mov esi, OFFSET quizBuffer
    mov edx, 0
    mov ecx, 0

    qp_loop:
        mov bl, BYTE PTR [esi + edx]
        cmp bl, 0
        je qp_done
        cmp bl, 0Ah
        je qp_newline
        cmp bl, '_'
        jne qp_next

        movzx ebx, numQuizQuestions
        cmp BYTE PTR quizBlankLen[ebx], 0
        jne qp_count
        mov eax, edx
        sub eax, ecx
        mov BYTE PTR quizBlankStart[ebx], al

        qp_count:
        movzx ebx, numQuizQuestions
        inc BYTE PTR quizBlankLen[ebx]
        jmp qp_next

        qp_newline:
        movzx ebx, numQuizQuestions
        mov quizOffsets[ebx * 4], ecx
        inc numQuizQuestions
        mov al, numQuizQuestions
        cmp al, MAX_QUESTIONS
        jge qp_done
        movzx ebx, numQuizQuestions
        mov BYTE PTR quizBlankStart[ebx], 0
        mov BYTE PTR quizBlankLen[ebx], 0
        mov ecx, edx
        inc ecx
        inc edx
        jmp qp_loop

        qp_next:
        inc edx
        jmp qp_loop

    qp_done:
    cmp edx, ecx
    je qp_skip
    movzx ebx, numQuizQuestions
    mov quizOffsets[ebx * 4], ecx
    inc numQuizQuestions
    qp_skip:

    mov currQuestion, 0
    mov activeSet, 0

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
ParseQuiz ENDP

; --- ParseLab: parses labBuffer into lab arrays ---
ParseLab PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov ecx, MAX_QUESTIONS * ANSWER_MAX_LEN
    mov edi, OFFSET labAnswers
    xor eax, eax
    rep stosb
    mov ecx, MAX_QUESTIONS
    mov edi, OFFSET labBlankStart
    rep stosb
    mov ecx, MAX_QUESTIONS
    mov edi, OFFSET labBlankLen
    rep stosb

    mov numLabQuestions, 0
    mov esi, OFFSET labBuffer
    mov edx, 0
    mov ecx, 0

    lp_loop:
        mov bl, BYTE PTR [esi + edx]
        cmp bl, 0
        je lp_done
        cmp bl, 0Ah
        je lp_newline
        cmp bl, '_'
        jne lp_next

        movzx ebx, numLabQuestions
        cmp BYTE PTR labBlankLen[ebx], 0
        jne lp_count
        mov eax, edx
        sub eax, ecx
        mov BYTE PTR labBlankStart[ebx], al

        lp_count:
        movzx ebx, numLabQuestions
        inc BYTE PTR labBlankLen[ebx]
        jmp lp_next

        lp_newline:
        movzx ebx, numLabQuestions
        mov labOffsets[ebx * 4], ecx
        inc numLabQuestions
        mov al, numLabQuestions
        cmp al, MAX_QUESTIONS
        jge lp_done
        movzx ebx, numLabQuestions
        mov BYTE PTR labBlankStart[ebx], 0
        mov BYTE PTR labBlankLen[ebx], 0
        mov ecx, edx
        inc ecx
        inc edx
        jmp lp_loop

        lp_next:
        inc edx
        jmp lp_loop

    lp_done:
    cmp edx, ecx
    je lp_skip
    movzx ebx, numLabQuestions
    mov labOffsets[ebx * 4], ecx
    inc numLabQuestions
    lp_skip:

    mov currQuestion, 0
    mov activeSet, 1

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
ParseLab ENDP

; Loads quiz questions
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

    mov edx, OFFSET quizBuffer
    mov ecx, QUESTION_BUF_SIZE - 1
    call ReadFromFile
    mov quizBytesRead, eax
    mov BYTE PTR [quizBuffer + eax], 0

    call ParseQuiz

    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
LoadQuiz ENDP

; Loads lab questions
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

    mov edx, OFFSET labBuffer
    mov ecx, QUESTION_BUF_SIZE - 1
    call ReadFromFile
    mov labBytesRead, eax
    mov BYTE PTR [labBuffer + eax], 0

    call ParseLab

    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
LoadLab ENDP

; Draws quiz questions on left panel
DrawQuiz PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov ecx, 0
    dqz_loop:
        mov al, numQuizQuestions
        cmp cl, al
        jge dqz_done

        mov dh, cl
        add dh, PANEL_TOP
        mov dl, QUIZ_PANEL_LEFT
        call BufGotoxy

        movzx ebx, cl
        mov eax, quizOffsets[ebx * 4]
        mov edx, 0

        dqz_line:
            mov esi, OFFSET quizBuffer
            mov bl, BYTE PTR [esi + eax]
            cmp bl, 0
            je dqz_line_done
            cmp bl, 0Dh
            je dqz_line_done
            cmp bl, 0Ah
            je dqz_line_done

            movzx esi, cl
            movzx esi, BYTE PTR quizBlankStart[esi]
            cmp edx, esi
            jl dqz_normal

            movzx ebx, cl
            movzx ebx, BYTE PTR quizBlankLen[ebx]
            add ebx, esi
            cmp edx, ebx
            jge dqz_normal

            ; inside blank
            .if cl == currQuestion
                push eax
                mov eax, black + (white * 16)
                call BufSetTextColor
                pop eax
            .else
                push eax
                mov eax, white + (black * 16)
                call BufSetTextColor
                pop eax
            .endif

            mov draw_col_save, edx
            mov ebx, edx
            sub ebx, esi                ; ebx = answer index

            push eax
            movzx eax, cl
            mov esi, ANSWER_MAX_LEN
            mul esi                     ; eax = q*ANSWER_MAX_LEN, edx = 0
            add eax, OFFSET quizAnswers
            mov al, BYTE PTR [eax + ebx]
            cmp al, 0
            jne dqz_got_char
            mov al, '_'
            dqz_got_char:
            mov draw_answer_char, al
            pop eax
            mov edx, draw_col_save

            mov al, draw_answer_char
            call BufWriteChar
            jmp dqz_advance

            dqz_normal:
            push eax
            mov eax, white + (black * 16)
            call BufSetTextColor
            pop eax
            mov esi, OFFSET quizBuffer
            mov al, BYTE PTR [esi + eax]
            call BufWriteChar

            dqz_advance:
            inc edx
            movzx ebx, cl
            mov eax, quizOffsets[ebx * 4]
            add eax, edx
            jmp dqz_line

        dqz_line_done:
        inc ecx
        jmp dqz_loop

    dqz_done:
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
DrawQuiz ENDP

; Draws lab questions on right panel
DrawLab PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov ecx, 0
    dlb_loop:
        mov al, numLabQuestions
        cmp cl, al
        jge dlb_done

        mov dh, cl
        add dh, PANEL_TOP
        mov dl, LAB_PANEL_LEFT
        call BufGotoxy

        movzx ebx, cl
        mov eax, labOffsets[ebx * 4]
        mov edx, 0

        dlb_line:
            mov esi, OFFSET labBuffer
            mov bl, BYTE PTR [esi + eax]
            cmp bl, 0
            je dlb_line_done
            cmp bl, 0Dh
            je dlb_line_done
            cmp bl, 0Ah
            je dlb_line_done

            movzx esi, cl
            movzx esi, BYTE PTR labBlankStart[esi]
            cmp edx, esi
            jl dlb_normal

            movzx ebx, cl
            movzx ebx, BYTE PTR labBlankLen[ebx]
            add ebx, esi
            cmp edx, ebx
            jge dlb_normal

            ; inside blank
            .if cl == currQuestion
                push eax
                mov eax, black + (white * 16)
                call BufSetTextColor
                pop eax
            .else
                push eax
                mov eax, white + (black * 16)
                call BufSetTextColor
                pop eax
            .endif

            mov draw_col_save, edx
            mov ebx, edx
            sub ebx, esi

            push eax
            movzx eax, cl
            mov esi, ANSWER_MAX_LEN
            mul esi
            add eax, OFFSET labAnswers
            mov al, BYTE PTR [eax + ebx]
            cmp al, 0
            jne dlb_got_char
            mov al, '_'
            dlb_got_char:
            mov draw_answer_char, al
            pop eax
            mov edx, draw_col_save

            mov al, draw_answer_char
            call BufWriteChar
            jmp dlb_advance

            dlb_normal:
            push eax
            mov eax, white + (black * 16)
            call BufSetTextColor
            pop eax
            mov esi, OFFSET labBuffer
            mov al, BYTE PTR [esi + eax]
            call BufWriteChar

            dlb_advance:
            inc edx
            movzx ebx, cl
            mov eax, labOffsets[ebx * 4]
            add eax, edx
            jmp dlb_line

        dlb_line_done:
        inc ecx
        jmp dlb_loop

    dlb_done:
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
DrawLab ENDP

; Returns currQuestion in al
GetCurrQuestion PROC
    mov al, currQuestion
    ret
GetCurrQuestion ENDP

; Returns numQuestions for active set in al
GetNumQuestions PROC
    cmp activeSet, 0
    je gnq_quiz
    mov al, numLabQuestions
    ret
    gnq_quiz:
    mov al, numQuizQuestions
    ret
GetNumQuestions ENDP

; Returns blank length for question N in active set
; IN: al = question index
GetBlankLen PROC
    movzx eax, al
    cmp activeSet, 0
    je gbl_quiz
    mov al, BYTE PTR labBlankLen[eax]
    ret
    gbl_quiz:
    mov al, BYTE PTR quizBlankLen[eax]
    ret
GetBlankLen ENDP

; Returns answer buffer address in edx for question N in active set
; IN: al = question index
; Does NOT clobber eax
GetAnswerBuf PROC
    push eax
    push ebx
    movzx eax, al
    mov ebx, ANSWER_MAX_LEN
    mul ebx
    cmp activeSet, 0
    je gab_quiz
    add eax, OFFSET labAnswers
    mov edx, eax
    pop ebx
    pop eax
    ret
    gab_quiz:
    add eax, OFFSET quizAnswers
    mov edx, eax
    pop ebx
    pop eax
    ret
GetAnswerBuf ENDP

END