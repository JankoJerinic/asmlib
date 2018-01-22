;=====================================================================================
; This file is a template for a generic sorting algorithm driver program.
;
; The driver needs to define a few symbols in order for the preprocessing to work:
;   * SORT_ALGORITHM : can be 
;		- quick_sort
;		- insertion_sort
;		- selection_sort
;	* I64 or I32, in order to specify size of data
;=====================================================================================

default rel
global _start

%include "../../lib/syscall.asm"
%include "../../lib/io.asm"

%ifidn SORT_ALGORITHM,quick_sort
	%include "../../lib/sort/sort_quick.asm"
%elifidn SORT_ALGORITHM,heap_sort
	%include "../../lib/sort/sort_heap.asm"
%elifidn SORT_ALGORITHM,insertion_sort
	%include "../../lib/sort/sort_insertion.asm"
%elifidn SORT_ALGORITHM,selection_sort
	%include "../../lib/sort/sort_selection.asm"
%else
	%error Must specify a valid SORT_ALGORITHM: quick_sort, heap_sort, insertion_sort, selection_sort
%endif

%ifdef I64
	; Definitions for 64-bit ints
	%define SORT_FUNCTION	SORT_ALGORITHM %+ _i64
	%define STRIDE			8
	%define LG_STRIDE		3
	%define ELEMENTS dq

	%macro copy_element 0
	  mov rax, [rdi]
	%endmacro

%elifdef I32
	; Definitions for 32-bit ints
	%define SORT_FUNCTION	SORT_ALGORITHM %+ _i32
	%define STRIDE			4
	%define LG_STRIDE		2
	%define ELEMENTS dd

	%macro copy_element 0
	  movsx rax, dword [rdi]
	%endmacro
%else
	%error Neither I32 not I64 has been defined!
%endif

section .data
	array ELEMENTS 5,7,3,1,4,2,0,1,6
	;array ELEMENTS 4,2,3,-1,6,1,0,-2,4,2,3,5,-1,1,1,8,10,0,2,1,4
	;array ELEMENTS 7, 6, 2, 3, 5, 4, 1, 3, 4
	;array ELEMENTS 4,13,1,2,3,6,0,1,-2,2,-13,54,42
	array_len equ $-array

section .text

_start:
	mov rdi, array
	mov rsi, array_len
	shr rsi, LG_STRIDE

	call SORT_FUNCTION
	
	mov rcx, rsi
	call print_elements
 .exit:
	sys_exit 0

print_elements:
.print_element:
	copy_element
	call print_i64
	println
	add rdi, STRIDE
	loop .print_element
	ret

