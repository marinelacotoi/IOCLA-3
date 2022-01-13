%include "../../printf32.asm"

section .text
	global par

extern printf
;; int par(int str_length, char* str)
; check for balanced brackets in an expression

par:
	xor edi, edi
	push dword 1

	loop:
		add eax, edi
		cmp [eax], byte '('
		jnz next
		push eax
		jmp continue

	next:
		pop ecx
		cmp ecx, 1
		jz fail
	
	continue:
		sub eax, edi
		inc edi
		cmp edi, edx
		jnz loop
	
	emptyStack:
		pop ecx
		cmp ecx, 1
		jz succes

	fail:
		push dword 0
		pop eax
		jmp end
	
	succes:
		push dword 1
		pop eax
		jmp end

	end:	
		ret
