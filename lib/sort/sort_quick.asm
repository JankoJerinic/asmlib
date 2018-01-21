; ==============================================================================
; This file contains routines that perform quick sort
;
; C/pseudo code:

; i = l; j = r; p = a[l];
; while (i <= j) {
;	while (a[i] <= p) ++i;
;	while (a[j] >= p) --i;
;	if (i <= j) {
;		swap(a[i], a[j]);
;		++i; 
;		--j;
;	}
; }
; 
; if (l < j) recurse(l, j);
; if (i < r) recurse(i, r);
; ==============================================================================
global quick_sort_i64
global quick_sort_i32

I64_SIZE equ 8
LG_I64_SIZE equ 3

I32_SIZE equ 4
LG_I32_SIZE equ 2

section .text

quick_sort_i64:
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
	push r8
	push r9

	cmp rsi, 1
	jle .end ; length <= 1
	xchg rsi, rdi		; rsi => left pointer
	mov rcx, rdi		; rcx => length
	lea rdi, [rsi + rcx*I64_SIZE - I64_SIZE]

.start:
	; Set up our stack. We will mark having a single stack frame
	; and push our initial Left and Right boundaries
	mov rcx, 1	
	push rdi
	push rsi

.recurse:
	pop rsi				; RSI = Left
	pop rdi				; RDI = Right
	mov rax, [rsi]		; RAX = Pivot === A[Left]
	mov r8, rsi
	mov r9, rdi
.partition:

.move_left:
	cmp [rsi], rax		; while (a[i] < p) ++i;
	jge .end_move_left
	add rsi, I64_SIZE
	jmp .move_left
.end_move_left:

.move_right:
	cmp [rdi], rax		; while (a[j] > p) --j;
	jle .end_move_right
	sub rdi, I64_SIZE
	jmp .move_right
.end_move_right:
	
	cmp rsi, rdi		; if (i > j) break;
	jg .end_partition
	mov rbx, [rsi]		; swap(a[i], a[j])
	mov rdx, [rdi]
	mov [rsi], rdx
	mov [rdi], rbx
	add rsi, I64_SIZE	; ++i
	sub rdi, I64_SIZE	; --j
	jmp .partition
.end_partition:
	dec rcx				; We've completed this stack frame

.new_partition_left:
	cmp r8, rdi					; if (l < j)
	jnl .no_left_partition
	inc rcx						; Increase stack frame count
	push rdi					; Push right border (j)
	push r8						; Push left border (l)
.no_left_partition:

.new_partition_right:
	cmp rsi, r9					; if (i < r)
	jnl .no_right_partition
	inc rcx						; Increase stack frame count
	push r9						; Push right border (r)
	push rsi					; Push left border (i)
.no_right_partition:
	
.check_stack:
	or rcx, rcx			; Check if we have any new stack frames
	jz .end
	jmp .recurse
.end:
	pop r9
	pop r8
	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rbx
	pop rax
	ret

quick_sort_i32:
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
	push r8
	push r9

	cmp rsi, 1
	jle .end ; length <= 1
	xchg rsi, rdi		; rsi => left pointer
	mov rcx, rdi		; rcx => length
	lea rdi, [rsi + rcx*I32_SIZE - I32_SIZE]

.start:
	; Set up our stack. We will mark having a single stack frame
	; and push our initial Left and Right boundaries
	mov rcx, 1	
	push rdi
	push rsi

.recurse:
	pop rsi					; RSI = Left
	pop rdi					; RDI = Right
	mov eax, dword [rsi]	; RAX = Pivot === A[Left]
	mov r8, rsi
	mov r9, rdi
.partition:

.move_left:
	cmp dword [rsi], eax	; while (a[i] < p) ++i;
	jge .end_move_left
	add rsi, I32_SIZE
	jmp .move_left
.end_move_left:

.move_right:
	cmp dword [rdi], eax	; while (a[j] > p) --j;
	jle .end_move_right
	sub rdi, I32_SIZE
	jmp .move_right
.end_move_right:
	
	cmp rsi, rdi		; if (i > j) break;
	jg .end_partition
	mov ebx, dword [rsi]		; swap(a[i], a[j])
	mov edx, dword [rdi]
	mov dword [rsi], edx
	mov dword [rdi], ebx
	add rsi, I32_SIZE	; ++i
	sub rdi, I32_SIZE	; --j
	jmp .partition
.end_partition:
	dec rcx				; We've completed this stack frame

.new_partition_left:
	cmp r8, rdi					; if (l < j)
	jnl .no_left_partition
	inc rcx						; Increase stack frame count
	push rdi					; Push right border (j)
	push r8						; Push left border (l)
.no_left_partition:

.new_partition_right:
	cmp rsi, r9					; if (i < r)
	jnl .no_right_partition
	inc rcx						; Increase stack frame count
	push r9						; Push right border (r)
	push rsi					; Push left border (i)
.no_right_partition:
	
.check_stack:
	or rcx, rcx			; Check if we have any new stack frames
	jz .end
	jmp .recurse
.end:
	pop r9
	pop r8
	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rbx
	pop rax
	ret

