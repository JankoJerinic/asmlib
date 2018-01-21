;=====================================================================================
; This program takes a decimal number and a base, and converts it to a representation
; in that, given base.
;=====================================================================================
%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif

; Make addresses RIP-relative: http://www.nasm.us/doc/nasmdoc6.html#section-6.2
default rel
global _start

%include "../lib/syscall.asm"
%include "../lib/io.asm"

section .text
_start:
	pop rcx			; Get our argument count off the stack
	pop rdi			; Get our executable name off the stack
	dec rcx			; We have n-1 arguments to sum up
	cmp rcx, 2
	jnz .wrong_argc

	pop rdi			; Fetch argv[0], this is our number
	call read_i64

	pop rdi			; Fetch argv[1], this is our base
	push rax		; Preserve our number on stack
	call read_i64
	cmp rax, 2
	jl .wrong_base
	cmp rax, 16
	jg .wrong_base

	mov rbx, rax	; Base goes to rbx
	pop rax			; Number goes to rax
	call print_i64
	println
	jmp .exit

.wrong_argc:
	sys_write wrong_argc_msg, wrong_argc_msg_len
	jmp .exit
.wrong_base:
	sys_write wrong_base_msg, wrong_base_msg_len
.exit:
	; Exit to OS using a system call (defined in lib/syscall.asm)
	sys_exit 0

	; This is equivalent to:
	;
	; mov rax, SYS_EXIT		; SYS_EXIT == 60
	; mov rdi, 0			; This is the exit code
	; syscall

section .data

wrong_argc_msg db "Invalid argument count! You must specify a number and a base (2 <= base <= 16).", 13, 10, "Usage: print_base [number] [base]", 13, 10
wrong_argc_msg_len equ $-wrong_argc_msg 

wrong_base_msg db "Invalid number base! Base should be >= 2 and <= 16.", 13, 10
wrong_base_msg_len equ $-wrong_base_msg

