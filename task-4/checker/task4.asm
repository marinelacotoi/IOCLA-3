%include "../../printf32.asm"
section .text

global expression
global term
global factor

extern printf
extern strpbrk
extern strlen
extern strchr

; `factor(char *p, int *i)`
;       Evaluates "(expression)" or "number" expressions 
; @params:
;	p -> the string to be parsed
;	i -> current position in the string
; @returns:
;	the result of the parsed expression
factor:
        push    ebp
        mov     ebp, esp

        ; ebx = the string to be parsed
        mov ebx, [ebp + 8]
        ; PRINTF32 `[EBX] : %s    \x0`, ebx
        ; ecx = current position in string
        mov ecx, [ebp + 12]
        ; PRINTF32 `[ECX] : %d    \x0`, [ecx]

        ; salvez s[*i] in edx
        xor eax, eax
        ; edx = *i
        mov edx, [ecx]
        ; dl = s[*i]
        mov dl, [ebx + edx]
        cmp dl, byte '('
        jnz else

        if_paranthesis:
                ; *i++
                add [ecx], dword 1
                
                push ecx
                push ebx
                call expression
                add esp, 8
                ; PRINTF32 `[EAX]: %d \x0`, eax
                mov edi, eax

                ; (*i)++
                add [ecx], dword 1
                jmp return 
        
        else:
                ; eax = strlen(s)
                push ecx
                push ebx
                call strlen
                add esp, 4
                pop ecx
                ; eax = strlen(s) - *i
                sub eax, [ecx]

        xor edi, edi
        xor edx, edx
        while:
                cmp eax, 0
                jle return

                ; dl = s[*i]
                mov edx, [ecx]
                mov dl, [ebx + edx]

                cmp dl, '*'
                jz return
                cmp dl, '/'
                jz return
                cmp dl, '-'
                jz return
                cmp dl, '+'
                jz return
                cmp dl, ')'
                jz return

                sub dl, 48
                imul edi, 10
                add edi, edx

                ; (*i)++
                add [ecx], dword 1

                ; while (strlen(s) - *i != 0)
                sub eax, 1
                jmp while


        return:
                ; PRINTF32 `[FACTOR]: %d \x0`, edi
                mov eax, edi
                leave
                ret

; `term(char *p, int *i)`
;       Evaluates "factor" * "factor" or "factor" / "factor" expressions 
; @params:
;	p -> the string to be parsed
;	i -> current position in the string
; @returns:
;	the result of the parsed expression
term:
        push    ebp
        mov     ebp, esp

        ; ebx = the string to be parsed
        mov ebx, [ebp + 8]
        ; PRINTF32 `[EBX] : %s    \x0`, ebx
        ; ecx = current position in string
        mov ecx, [ebp + 12]
        ; PRINTF32 `[ECX] : %d    \x0`, [ecx]

        push ecx
        push ebx
        call factor
        add esp, 8
        mov edi, eax
        ; PRINTF32 `[TERM] : %d    \x0`, edi

        
        loop_12:
                ; edx = *i
                mov edx, [ecx]
                ; dl = s[*i]
                mov dl, [ebx + edx]

                ; while (s[*i] == '*' || s[*i] == '/')
                cmp dl, '*'
                jz while_div_or_mul
                cmp dl, '/'
                jz while_div_or_mul
                jmp final

        while_div_or_mul:
                ; (*i)++
                add [ecx], dword 1

                ; call term
                push edi
                push edx
                push ecx
                push ebx
                call factor
                add esp, 8
                pop edx
                pop edi

                cmp dl, '*'
                jz multiply
                cmp dl, '/'
                jz division
                jmp loop_12

        multiply:
                imul edi, eax
                jmp loop_12

        division:
                ; EDI/EAX
                push eax
                push edi
                pop eax
                pop edi
                xor edx, edx
                div edi
                mov edi, eax
                jmp loop_12
        
        final:
                mov eax, edi
                leave
                ret

; `expression(char *p, int *i)`
;       Evaluates "term" + "term" or "term" - "term" expressions 
; @params:
;	p -> the string to be parsed
;	i -> current position in the string
; @returns:
;	the result of the parsed expression
expression:
        push    ebp
        mov     ebp, esp
        
        ; ebx = the string to be parsed
        mov ebx, [ebp + 8]
        ; PRINTF32 `[EBX] : %s    \x0`, ebx
        ; ecx = current position in string
        mov ecx, [ebp + 12]
        ; PRINTF32 `[ECX] : %d    \x0`, [ecx]

        push ecx
        push ebx
        call term
        add esp, 4
        mov edi, eax

        loop:
                ; edx = *i
                mov edx, [ecx]
                ; dl = s[*i]
                mov dl, [ebx + edx]

                cmp dl, '+'
                jz while_plus_or_minus
                cmp dl, '-'
                jz while_plus_or_minus
                jmp end

        while_plus_or_minus:
                ; (*i)++
                add [ecx], dword 1

                ; call term
                push edi
                push edx
                push ecx
                push ebx
                call term
                add esp, 8
                pop edx
                pop edi
                
                cmp dl, '+'
                jz if_plus
                cmp dl, '-'
                jz if_minus
                jmp loop

        if_plus:
                add edi, eax
                jmp loop

        if_minus:
                sub edi, eax
                jmp loop

        end:
                mov eax, edi
                leave
                ret
