; Handles answer checking and score tracking

INCLUDE Irvine32.inc

GetAnswerBuf PROTO
GetPenalty PROTO

.data
quizAnswerFileEasy BYTE "quiz_answers_easy.txt", 0
quizAnswerFileMed  BYTE "quiz_answers_medium.txt", 0
quizAnswerFileHard BYTE "quiz_answers_hard.txt", 0

labAnswerFileEasy  BYTE "lab_answers_easy.txt", 0
labAnswerFileMed   BYTE "lab_answers_medium.txt", 0
labAnswerFileHard  BYTE "lab_answers_hard.txt", 0

ANSWER_BUF_SIZE = 200
answerBuffer    BYTE ANSWER_BUF_SIZE DUP(?)

PUBLIC quizScore
PUBLIC labScore
quizScore DWORD 0
labScore  DWORD 0

EXTERN chosenDifficulty:BYTE

POINTS_PER_QUESTION = 10
NUM_QUESTIONS = 5
ANSWER_MAX_LEN = 20

score_ptr DWORD ?       ; memory-based score pointer, avoids stack imbalance

.code
PUBLIC CheckQuiz
PUBLIC CheckLab

; Converts al to uppercase
ToUpper PROC
    cmp al, 'a'
    jl to_upper_done
    cmp al, 'z'
    jg to_upper_done
    sub al, 20h
    to_upper_done:
    ret
ToUpper ENDP

; Loads answer file and checks all 5 answers against player answers
; IN:  edx = answer file path
;      score_ptr = address of score variable to update
CheckAnswers PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi
	
	

    ; Open and read answer file
    call OpenInputFile
	push eax
    mov edx, OFFSET answerBuffer
    mov ecx, ANSWER_BUF_SIZE - 1
    call ReadFromFile
    mov BYTE PTR [answerBuffer + eax], 0
	pop eax
	call CloseFile

    ; Walk through each of the 5 questions
    mov ecx, 0                      ; question index
    mov ebx, 0                      ; byte offset into answerBuffer

    check_loop:
        cmp cl, NUM_QUESTIONS
        jge check_done

        ; Get player answer buffer for this question
        push ecx
        push ebx
        mov al, cl
        call GetAnswerBuf           ; edx = player answer buffer
        pop ebx
        pop ecx

        push ecx
        push ebx

        mov esi, edx                ; esi = player answer buffer

        mov ecx, 0                  ; char index within answer
        compare_loop:
            mov al, BYTE PTR [answerBuffer + ebx + ecx]
            cmp al, 0
            je correct_end_check
            cmp al, 0Dh
            je correct_end_check
            cmp al, 0Ah
            je correct_end_check

            call ToUpper
            mov ah, al              ; ah = correct char uppercased

            mov al, BYTE PTR [esi + ecx]
            call ToUpper

            cmp al, ah
            jne answer_wrong

            inc ecx
            jmp compare_loop

        correct_end_check:
            mov al, BYTE PTR [esi + ecx]
            cmp al, 0
            je answer_correct
            jmp answer_wrong

        answer_correct:
            mov esi, score_ptr
            add DWORD PTR [esi], POINTS_PER_QUESTION
            jmp next_question

        answer_wrong:

        next_question:
        pop ebx
        pop ecx

        ; Advance ebx past this answer line in answerBuffer
        skip_line:
            mov al, BYTE PTR [answerBuffer + ebx]
            cmp al, 0
            je check_done
            cmp al, 0Ah
            je skip_line_done
            inc ebx
            jmp skip_line
        skip_line_done:
        inc ebx

        inc ecx
        jmp check_loop

    check_done:

	; Penalty from time delay
    call GetPenalty              ; eax = penalty (seconds or points)
    mov esi, score_ptr           ; esi = &quizScore or &labScore
    sub DWORD PTR [esi], eax     ; score -= penalty

    ; clamp score to 0 if it went negative
    cmp DWORD PTR [esi], 0
    jge fully_done

    mov DWORD PTR [esi], 0

fully_done:
	
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
CheckAnswers ENDP

; Checks quiz answers and updates quizScore
CheckQuiz PROC
    push edx

    mov quizScore, 0
    mov score_ptr, OFFSET quizScore

    .if chosenDifficulty == 0
        mov edx, OFFSET quizAnswerFileEasy
    .elseif chosenDifficulty == 1
        mov edx, OFFSET quizAnswerFileMed
    .else
        mov edx, OFFSET quizAnswerFileHard
    .endif

    call CheckAnswers

    pop edx
    ret
CheckQuiz ENDP

; Checks lab answers and updates labScore
CheckLab PROC
    push edx

    mov labScore, 0
    mov score_ptr, OFFSET labScore

    .if chosenDifficulty == 0
        mov edx, OFFSET labAnswerFileEasy
    .elseif chosenDifficulty == 1
        mov edx, OFFSET labAnswerFileMed
    .else
        mov edx, OFFSET labAnswerFileHard
    .endif

    call CheckAnswers

    pop edx
    ret
CheckLab ENDP

END