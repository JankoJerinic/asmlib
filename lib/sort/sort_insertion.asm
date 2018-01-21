; ==============================================================================
; This file contains routines that perform insertion sort.
;
; C/pseudo code: 
; for (int i = 1; i < n; ++i) {
;	curr = a[i]
;	j = i - 1
;	while (a[j] > curr and j >= 0) {
;		a[j+1] = a[j]
;		--j;
;	}
;	a[j + 1] = curr
; ==============================================================================
global insertion_sort_i64
global insertion_sort_i32

I64_SIZE equ 8
LG_I64_SIZE equ 3

I32_SIZE equ 4
LG_I32_SIZE equ 2

section .text

insertion_sort_i64:
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

	add rsi, I64_SIZE	; i = 1
	lea rdx, [rsi + rcx * I64_SIZE]	; rdx == n
	xor rcx, rcx
.outer_loop:
	cmp rsi, rdx
	jge .end					; while (i < n) {
	mov rax, [rsi]				;	curr = a[i]
	lea rdi, [rsi - I64_SIZE]	;	j = i - 1
	inc rcx						;	// loop i times	
	push rcx
	.inner_loop:
		cmp rax, [rdi]				; if (curr > a[i]) break
		jg .end_loop
		mov rbx, [rdi]				
		mov [rdi + I64_SIZE], rbx	; a[j+1] = a[j]
		sub rdi, I64_SIZE			; j -= 1
		loop .inner_loop
	.end_loop:
	mov [rdi + I64_SIZE], rax
	pop rcx				; // restore inner loop counter
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

insertion_sort_i32:
	; /*
	; rdi = int * array
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

	add rsi, I32_SIZE	; i = 1
	lea rdx, [rsi + rcx * I32_SIZE]	; rdx == n
	xor rcx, rcx
.outer_loop:
	cmp rsi, rdx
	jge .end					; while (i < n) {
	mov eax, dword [rsi]		;	curr = a[i]
	lea rdi, [rsi - I32_SIZE]	;	j = i - 1
	inc rcx						;	// loop i times	
	push rcx
	.inner_loop:
		cmp eax, dword [rdi]		; if (curr > a[i]) break
		jg .end_loop
		mov ebx, dword [rdi]				
		mov dword [rdi + I32_SIZE], ebx	; a[j+1] = a[j]
		sub rdi, I32_SIZE				; j -= 1
		loop .inner_loop
	.end_loop:
	mov dword [rdi + I32_SIZE], eax
	pop rcx				; // restore inner loop counter
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

