section .text
	global par

;; int par(int str_length, char* str)
; check for balanced brackets in an expression
par:
	xor edi, edi
	; adaugam pe stiva o valoare pentru a putea
	; verifica usor cand am ajuns la baza stivei
	push dword 1

	loop:
		add eax, edi
		; adaug parantezele deschise pe stiva
		cmp [eax], byte '('
		jnz next
		push eax
		jmp continue

	; toate parantezele inchise ar trebui sa aibe corespondent
	; pe stiva o paranteza deschisa
	; in caz contrar, expresia este invalida
	next:
		pop ecx
		cmp ecx, 1
		jz fail
	
	continue:
		sub eax, edi
		inc edi
		cmp edi, edx
		jnz loop
	
	; daca am parcurs tot string-ul si inca mai exista
	; elemente pe stiva, expresia este invalida
	emptyStack:
		pop ecx
		cmp ecx, 1
		jz succes

	; daca expresia este invalida, functia returneaza 0
	fail:
		push dword 0
		pop eax
		jmp end
	
	; daca expresia este valida, functia returneaza 1
	succes:
		push dword 1
		pop eax
		jmp end

	end:	
		ret
