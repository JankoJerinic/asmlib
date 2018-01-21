; ==============================================================================
; This file contains routines that perform selection sort.
;
; C/pseudo code: 
; for (int i = 0; i < n; ++i) {
;	 min = i
;    for (int j = i + 1; j < n; ++j) {
;		if a[j] < a[min]; min = j
;	swap(i, min)
; ==============================================================================
global selection_sort_i64
global selection_sort_i32

I64_SIZE equ 8
LG_I64_SIZE equ 3

I32_SIZE equ 4
LG_I32_SIZE equ 2

section .text

selection_sort_i64:
	; /*
	; rdi = long long * array
	; rsi = length
	;*/
	push rax
	push rbx
	push rcx
	push rdx
	push rsi
	push rdi

	cmp rsi, 1
	jle .end ; length <= 1
	xchg rsi, rdi		; rsi => left pointer
	mov rcx, rdi		; rcx => length

	lea rdx, [rsi + rcx * I64_SIZE - I64_SIZE]
	;mov rdx, rcx
	;shl rdx, LG_I64_SIZE
	;add rdx, rsi
	;sub rdx, I64_SIZE	; rdx = rsi + (n-1)*LL_SIZE
.outer_loop:
	cmp rsi, rdx
	jge .end			; while (i < n - 1) {
	mov rax, [rsi]		;	min = a[i]
	mov rbx, rsi	    ;   min_i = i	
	push rax

	mov rdi, rsi
	add rdi, I64_SIZE	;	j = i + 1 // rdi => right pointer
	dec rcx				;	// rcx = n - i, inner loop counter
	push rcx
	.inner_loop:
		cmp rax, [rdi]				; if (min > a[j])
		jle .min_less_or_equal
		mov rbx, rdi				;	min_i = j
		mov rax, [rdi]				;	min = a[j]
		.min_less_or_equal:
		add rdi, I64_SIZE			; j += 1
		loop .inner_loop
	pop rcx				; // restore inner loop counter
	pop rax				; // restore a[i]

	cmp rsi, rbx
	jz .no_min			;		if (i != min_i) 
	mov rdi, [rbx]		;			temp = a[min]
	mov [rbx], rax		;			a[min] = a[i]
	mov [rsi], rdi		;			a[i] = temp
.no_min:
	add rsi, I64_SIZE	;	i += 1
	jmp .outer_loop		;	} // end outer loop
.end:
	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rbx
	pop rax
	ret


selection_sort_i32:
	; /*
	; rdi = long long * array
	; rsi = length
	;*/
	push rax
	push rbx
	push rcx
	push rdx
	push rsi
	push rdi

	cmp rsi, 1
	jle .end			; length <= 1
	xchg rsi, rdi		; rsi => left pointer
	mov rcx, rdi		; rcx => length

	lea rdx, [rsi + rcx * I32_SIZE - I32_SIZE]
	;mov rdx, rcx
	;shl rdx, LG_I32_SIZE
	;add rdx, rsi
	;sub rdx, I32_SIZE	; rdx = rsi + (n-1)*I32_SIZE
.outer_loop:
	cmp rsi, rdx
	jge .end			; while (i < n - 1) {
	mov eax, dword [rsi];	min = a[i]
	mov rbx, rsi	    ;   min_i = i	
	push rax

	mov rdi, rsi		;   // rdi => right pointer
	add rdi, I32_SIZE	;	j = i + 1 
	dec rcx				;	// rcx = n - i, inner loop counter
	push rcx
	.inner_loop:
		cmp eax, dword [rdi]		; if (min > a[j])
		jle .min_less_or_equal
		mov rbx, rdi				;	min_i = j
		mov eax, dword [rdi]		;	min = a[j]
		.min_less_or_equal:
		add rdi, I32_SIZE			; j += 1
		loop .inner_loop
	pop rcx				; // restore inner loop counter
	pop rax				; // restore a[i]

	cmp rsi, rbx
	jz .no_min			;		if (i != min_i) 
	mov edi, dword [rbx];			temp = a[min]
	mov dword [rbx], eax;			a[min] = a[i]
	mov dword [rsi], edi;			a[i] = temp
.no_min:
	add rsi, I32_SIZE	;	i += 1
	jmp .outer_loop		;	} // end outer loop
.end:
	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rbx
	pop rax
	ret

