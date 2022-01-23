section .text
	global sort

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
	; eax = numarul de elemente din vector
	mov eax, [ebp + 8]
	; ecx = adresa de inceput a vectorului
	mov ebx, [ebp + 12]

	; initializare registri
	xor edi, edi
	xor esi, esi

	exteriorLoop:
		; iterez prin elementele vectorului
		mov ecx, [ebx + 8 * edi]
		; salvez adresa pentru next a fiecarui element
		lea esi, [ebx + 8 * edi + 4]

		; daca valorea nodului curent este 1, pun nodul
		; pe stiva pentru a-l putea returna la sfarsitul
		; functiei
		cmp ecx, 1
		jnz next
		push edi

		; caut valoarea elementului curent + 1
		; caci nodul corespondent acesteia va reprezenta 
		; adresa de next a nodului curent
		next:
			push edi
			xor edi, edi
			inc ecx

		loop:
			mov edx, [ebx + 8 * edi]

			cmp edx, ecx
			jnz continue

			push edi
			; folosesc lea pentru a stoca in nodul
			; curent adresa de next a urmatorului nod
			lea edi, [ebx + 8 * edi]
			mov [esi], edi
			pop edi

			continue:
				inc edi
				cmp eax, edi
				jnz loop

		pop edi
		inc edi
		; iterez prin lista pana cand am parcurs
		; toate nodurile
		cmp eax, edi
		jnz exteriorLoop

	pop edi
	; pun in eax adresa corespunzatoare nodului 1
	lea eax, [ebx + 8 * edi]
	leave
	ret