;=====================================================================================
; This program prints information about its arguments.
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

	; 1) First value on the stack is the argument count
.print_argc:
	sys_write arg_count_msg, arg_count_msg_len

	pop rcx			; Get our argument count off the stack
	mov rax, rcx	; Set it up for printing
	call print_i64
	println

	xor rax, rax	; RAX will store argv counter
.print_argv:
	cmp rax, rcx
	jz .exit

	sys_write argv_msg1, argv_msg1_len	; print out 'Argument['
	call print_i64						; print out the counter
	sys_write argv_msg2, argv_msg2_len	; print out '] = '

	pop rdi			; Fetch argv[i]
	push rcx		
	call strlen		; strlen preserves RDI, but destroys RCX
	sys_write rdi, rcx	; print argv[i]
	println

	pop rcx			; restore RCX
	inc rax
	jmp .print_argv

.exit:
	; Exit to OS using a system call (defined in lib/syscall.asm)
	sys_exit 0

	; This is equivalent to:
	;
	; mov rax, SYS_EXIT		; SYS_EXIT == 60
	; mov rdi, 0			; This is the exit code
	; syscall

section .data

arg_count_msg db "Argument count: "
arg_count_msg_len equ $-arg_count_msg

argv_msg1 db "Argument ["
argv_msg1_len equ $-argv_msg1

argv_msg2 db "] = "
argv_msg2_len equ $-argv_msg2

