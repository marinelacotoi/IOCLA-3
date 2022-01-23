section .text

global expression
global term
global factor

extern strlen

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

        ; ebx = string-ul ce urmeaza a fi parsat
        mov ebx, [ebp + 8]
        ; ecx = pozitia curenta in string
        mov ecx, [ebp + 12]

        xor eax, eax

        ; salvez caracterul curent in dl
        mov edx, [ecx]
        mov dl, [ebx + edx]

        ; verific daca trebuie calculat un (numar)
        ; sau o (expresie)
        cmp dl, byte '('
        jnz else

        ; calculez (expresie)
        if_paranthesis:
                ; obtin rezultatul expresiei dintre
                ; paranteze apeland functia expression
                add [ecx], dword 1
                
                push ecx
                push ebx
                call expression
                add esp, 8
                mov edi, eax

                add [ecx], dword 1
                jmp return 
        
        ; calculez (numar)
        else:
                ; pastrez valoarea din ecx neafectata de strlen
                push ecx
                ; eax = strlen(s)
                push ebx
                call strlen
                add esp, 4

                pop ecx
                ; eax = strlen(s) - *i
                ; salvez in eax numarul de iteratii de la
                ; pozitia curenta pana la sfarsitul string-ului
                sub eax, [ecx]

        xor edi, edi
        xor edx, edx
        
        while:
                ; dl = caracterul curent
                mov edx, [ecx]
                mov dl, [ebx + edx]

                ; ies din loop daca caracter-ul curent
                ; este operator sau paranteza
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

                ; calculez numarul cu formula
                ; numar = numar * 10 + caracter - '0';
                ; caracter - '0' transforma caracterul in int
                push ecx
                xor ecx, ecx
                mov cl, dl
                ; caracter - '0'
                sub cl, 48
                imul edi, 10
                add edi, ecx
                pop ecx

                ; trec la urmatorul caracter
                add [ecx], dword 1

                ; ies din loop daca s-a parcurs 
                ; tot string-ul
                sub eax, 1
                cmp eax, 0
                jle return
                jmp while


        return:
                ; mut in eax rezultatul functiei pentru a-l returna
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

        ; ebx = string-ul ce urmeaza a fi parsat
        mov ebx, [ebp + 8]
        ; ecx = pozitia curenta in string
        mov ecx, [ebp + 12]

        ; apelez functia factor pentru a obtine
        ; primul factor din operatiile
        ; factor * factor || factor / factor
        push ecx
        push ebx
        call factor
        add esp, 8
        mov edi, eax
        
        term_loop:
                ; salvez in dl caracterul curent
                mov edx, [ecx]
                mov dl, [ebx + edx]

                ; term_loop este echivalent cu
                ; while (s[*i] == '*' || s[*i] == '/'), unde
                ; s[*i] = caracterul curent
                cmp dl, '*'
                jz while_div_or_mul
                cmp dl, '/'
                jz while_div_or_mul
                jmp ret_term

        while_div_or_mul:
                ; incrementez pozitia curenta din string
                add [ecx], dword 1

                push edi
                push edx

                ; apelez factor pentru a obtine cel
                ; de-al doilea factor
                push ecx
                push ebx
                call factor
                add esp, 8

                ; pe langa parametrii functiei factor
                ; am salvat pe stiva si edx si edi
                ; pentru a le pastra valorile neafectate de
                ; apelul functiei factor
                pop edx
                pop edi

                cmp dl, '*'
                jz multiply
                cmp dl, '/'
                jz division
                jmp term_loop

        ; calculez factor * factor
        multiply:
                imul edi, eax
                jmp term_loop

        ; calculez factor / factor
        division:
                push eax
                push edi
                pop eax
                pop edi
                xor edx, edx
                ; folosesc cdq pentru impartirea cu semn
                cdq
                idiv edi
                mov edi, eax
                jmp term_loop
        
        ret_term:
                ; mut in eax rezultatul functiei pentru a-l returna
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
        
        ; ebx = string-ul ce urmeaza a fi parsat
        mov ebx, [ebp + 8]
        ; ecx = pozitia curenta in string
        mov ecx, [ebp + 12]

        ; apelez functia term pentru a obtine
        ; primul termen din operatiile
        ; term + term || term - term
        push ecx
        push ebx
        call term
        add esp, 4
        mov edi, eax

        loop:
                ; salvez in dl caracterul curent
                mov edx, [ecx]
                mov dl, [ebx + edx]

                ; loop este echivalent cu
                ; while (s[*i] == '+' || s[*i] == '-'), unde
                ; s[*i] = caracterul curent
                cmp dl, '+'
                jz while_plus_or_minus
                cmp dl, '-'
                jz while_plus_or_minus
                jmp ret_expression

        while_plus_or_minus:
                ; incrementez pozitia curenta din string
                add [ecx], dword 1

                push edi
                push edx

                ; apelez term pentru a obtine cel
                ; de-al doilea termen
                push ecx
                push ebx
                call term
                add esp, 8

                ; pe langa parametrii functiei term
                ; am salvat pe stiva si edx si edi
                ; pentru a le pastra valorile neafectate de
                ; apelul functiei term
                pop edx
                pop edi
                
                cmp dl, '+'
                jz plus
                cmp dl, '-'
                jz minus
                jmp loop

        ; calculez term + term
        plus:
                add edi, eax
                jmp loop

        ; calculez term - term
        minus:
                sub edi, eax
                jmp loop

        ret_expression:
                ; mut in eax rezultatul functiei pentru a-l returna
                mov eax, edi
                leave
                ret
