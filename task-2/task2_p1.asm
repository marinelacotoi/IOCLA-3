section .text
	global cmmmc

;; int cmmmc(int a, int b)
;; calculate least common multiple for 2 numbers, a and b
cmmmc:
	push eax
	push edx

	loop:
		; ecx = b
		pop ecx
		; ebx = a
		pop ebx
		cmp ecx, ebx
		jl else

		; daca (b < a), incrementam cu b pe a
		add ebx, eax
		push ebx
		push ecx
		jmp continue

		; daca (a < b), incrementam pe a cu b
	else:
		add ecx, edx
		push ebx
		push ecx

	continue:
		; daca a == b
		; am gasit cel mai mare multiplu comun
		cmp ecx, ebx
		jnz loop
	
	pop edx
	pop eax
	ret