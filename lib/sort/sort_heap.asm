; ==============================================================================
; This file contains routines that perform heap sort.
; It also contains general heap-building methods
;
; C/pseudo code: 
; ==============================================================================
global heap_sort_i64
global build_heap_i64
global heapify_i64

I64_SIZE equ 8
LG_I64_SIZE equ 3

I32_SIZE equ 4
LG_I32_SIZE equ 2

%define MAX_HEAP 1

%ifdef MIN_HEAP
	%macro jmp_if_heap 3
		cmp %1, %2
		jle %3
	%endmacro
%elifdef MAX_HEAP
	%macro jmp_if_heap 3
		cmp %1, %2
		jge %3
	%endmacro
%else
	%error MIN_HEAP or MAX_HEAP must be defined!
%endif

section .text

heapify_i64:
	; RSI - Address of heap's array
	; RBX - Index of heap's element from which to start heapifying
	; RCX - Number of elements in the heap
	; TODO: Destroys RDI, R8, R9, R10, R11, RAX
	push rbx
	push rsi

	lea rsi, [rsi + rbx * I64_SIZE]
	mov rax, [rsi]
.heapify:
	; RSI is the address of the current node
	; RBX is the index of the current node
	; RAX is the value of the current node
	; R8, R9 will be indices of left and right child, respectively
	mov r8, rbx
	shl r8, 1
	inc r8							; left = 2*parent + 1
	cmp r8, rcx						; Is left child in heap?
	jge .end_heapify

	mov rdx, r8						; RDX contains Min child's index

	lea rdi, [rsi + rbx * I64_SIZE + I64_SIZE]	; Left child's address	
	mov r10, [rdi]								; Left child's value

	mov r9, r8				
	inc r9							; right = left + 1
	cmp r9, rcx						; If right child in heap?
	jge .min_child_found			; No, left is min

	mov r11, [rdi + I64_SIZE]		; Right child's value

	jmp_if_heap r10, r11, .min_child_found
	;cmp r10, r11					; Compare left and right child
	;jle .min_child_found			; Left is min

	mov rdx, r9						; Min child is the right one now
	mov r10, r11
	add rdi, I64_SIZE
.min_child_found:
	; RDX contains the index of the smallest child
	; RDI contains the address of the smallest child
	; R10 contains the value of the smallest child
	
	jmp_if_heap rax, r10, .end_heapify
	;cmp rax, r10
	;jle .end_heapify				; Parent is LE, all is well

	mov [rsi], r10
	mov [rdi], rax

	mov rbx, rdx					; Move current index
	mov rsi, rdi					; Move current address
									; No need to move RAX!
	jmp .heapify
.end_heapify:
	pop rsi
	pop rbx
	ret

build_heap_i64:
	; RCX - number of elements in the heap
	; RSI - address of the heap's array
	push rbx
	mov rbx, rcx	; for (i = n/2; i >= 0; --i)
	shr rbx, 1
.build_heap:
	call heapify_i64		; heapify(i)
	dec rbx
	; cmp rbx, 0
	jl .end_build_heap
	jmp .build_heap
.end_build_heap:
	pop rbx
	ret
	

heap_sort_i64:
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

	call build_heap_i64			; Build the initial heap

	dec rcx						; 
	xor rbx, rbx				; We will always heapify from 0-th element
.sort_loop
	lea rdi, [rsi + rcx * I64_SIZE]

	mov rax, [rsi]				; Swap first and last element
	mov rdx, [rdi]
	mov [rdi], rax
	mov [rsi], rdx

	call heapify_i64			; Re-heapify the smaller heap
	loop .sort_loop				; This decreases the heap size as well (RCX)

.end:
	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rbx
	pop rax
	ret

