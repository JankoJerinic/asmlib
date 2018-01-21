;=====================================================================================
; This program accepts a number of integer arguments and prints their sum.
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
	jz .exit
	xor rbx, rbx	; RBX will accumulate values
.read_argv:
	pop rdi			; Get argv[i]
	call read_i64	; Parse it as int
	add rbx, rax	; Accumulate
	loop .read_argv

.exit:
	mov rax, rbx
	call print_i64
	println

	; Exit to OS using a system call (defined in lib/syscall.asm)
	sys_exit 0

	; This is equivalent to:
	;
	; mov rax, SYS_EXIT		; SYS_EXIT == 60
	; mov rdi, 0			; This is the exit code
	; syscall

section .data

