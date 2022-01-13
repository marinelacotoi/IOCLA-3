%include "../../printf32.asm"

section .text
	global sort


extern printf
; struct node {
;     	int val;
;    	struct node* next;
; };

;; struct node* sort(int n, struct node* node);
; 	The function will link the nodes in the array
;	in ascending order and will return the address
;	of the new found head of the list
; @params:
;	n -> the number of nodes in the array
;	node -> a pointer to the beginning in the array
; @returns:
;	the address of the head of the sorted list

sort:
	enter 0, 0

	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	xor edi, edi
	xor esi, esi

	; eax = numarul de elemente din vector
	mov eax, [ebp + 8]

	; ecx = adresa de inceput a vectorului
	mov ebx, [ebp + 12]

	exteriorLoop:
		; iterez prin elementele vectorului
		mov ecx, [ebx + 8 * edi]
		; salvez adresa pentru next a fiecarui element
		lea esi, [ebx + 8 * edi + 4]

		; daca elementul e 1, il pun pe stiva
		; pentru a-l putea returna la sfarsitul functiei
		cmp ecx, 1
		jnz next
		push edi

		next:
			push edi
			xor edi, edi
			inc ecx

		loop:
			mov edx, [ebx + 8 * edi]

			cmp edx, ecx
			jnz continue

			push edi
			lea edi, [ebx + 8 * edi]
			mov [esi], edi
			pop edi

			continue:
				inc edi
				cmp eax, edi
				jnz loop

		pop edi
		inc edi
		cmp eax, edi
		jnz exteriorLoop

	pop edi
	lea eax, [ebx + 8 * edi]
	leave
	ret
