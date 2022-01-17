%include "../../printf32.asm"

section .text
	global cmmmc

extern printf
;; int cmmmc(int a, int b)
;; calculate least common multiple fow 2 numbers, a and b
cmmmc:
	push eax
	push edx

	loop:
		pop ecx
		pop ebx
		cmp ecx, ebx
		jl else

		add ebx, eax
		push ebx
		push ecx
		jmp continue

	else:
		add ecx, edx
		push ebx
		push ecx

	continue:
		cmp ecx, ebx
		jnz loop
	
	pop edx
	pop eax
	ret