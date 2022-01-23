global get_words
global compare_func
global sort

section .data
    delim db " ,.", 0

section .text

extern strtok
extern strlen
extern qsort
extern strcmp

compare_func:
    enter 0, 0
    ; salvez cel de-al doilea cuvant
    ; dat ca parametru in ecx
    mov ecx, [ebp + 12]
    
    ; obtin lungimea celui de-al doilea cuvant
    push dword [ecx]
    call strlen
    add esp, 4

    ; o salvez in ecx si il adaug pe stiva pentru a-i pastra
    ; valoarea intacta
    mov ecx, eax
    push ecx

    ; obtin lungimea primului cuvant si o salvez in eax
    mov eax, [ebp + 8]
    push dword [eax]
    call strlen
    add esp, 4
    
    ; compar lungimile
    pop ecx
    sub eax, ecx

    ; daca lungimile sunt egale sortez lexicografic
    cmp eax, 0
    jnz end

    mov eax, [ebp + 8]
    mov ecx, [ebp + 12]

    ; apelez strcmp pentru a compara cuvintele lexicografic 
    push dword [ecx]
    push dword [eax]
    call strcmp
    add esp, 8

    end:
        leave
        ret


;; sort(char **words, int number_of_words, int size)
;  functia va trebui sa apeleze qsort pentru sortarea cuvintelor 
;  dupa lungime si apoi lexicografix
sort:
    enter 0, 0
    ; eax = words 
    mov eax, [ebp + 8]
    ; ebx = number_of_words
    mov ebx, [ebp + 12]
    ; ecx = size
    mov ecx, [ebp + 16]

    ; apelez functia qsort, pasand ca parametru 
    ; functia de compare implementata anterior
    push compare_func
    push ecx
    push ebx
    push eax
    call qsort
    add esp, 16

    leave
    ret

;; get_words(char *s, char **words, int number_of_words)
;  separa stringul s in cuvinte si salveaza cuvintele in words
;  number_of_words reprezinta numarul de cuvinte
get_words:
    enter 0, 0

    ; eax = string-ul s
    mov eax, [ebp + 8]
    ; ebx = words
    mov ebx, [ebp + 12]
    ; ecx = number_of_words
    mov ecx, [ebp + 16]    
    xor edi, edi

    ; apelez strtok de number_of_words ori
    ; salvand de fiecare data in words token-ul returnat
    ; de apelul functiei
    loop:
        push ecx
        push delim
        push eax
        call strtok
        add esp, 8

        mov [ebx], eax
        add ebx, 4

        mov eax, 0
        inc edi
        pop ecx
        cmp edi, ecx
        jnz loop

    leave
    ret
