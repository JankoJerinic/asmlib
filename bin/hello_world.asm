;=====================================================================================
; This program showcases various prints, including Hello World!
;=====================================================================================
%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif

; Make addresses RIP-relative: http://www.nasm.us/doc/nasmdoc6.html#section-6.2
default rel
global _start

%include "../lib/syscall.asm"
%include "../lib/io.asm"

section .data
	msg: db      "hello, World!!!", 0x0D, 0x0A, "I am on a new line", 0x0D, 0x0A
	msg_len:	equ $-msg

section .text
_start:
	; 0) Print an empty line (defined in lib/io.asm)
	println

	; 1) Print out 01234567 followed by CR/LF by printing from the stack
	;
	mov rbp, rsp
	mov rax, 0x0D0A				
	push rax
	mov rax, 0x3736353433323130		; These are chars '0', '1', ... '9'
	push rax						; In little Endian, low byte goes to low address

	mov rcx, rbp		; Calculate the length of the string 
	sub rcx, rsp		; by comparing RSP before and after

	mov rsi, rsp		; Store the original stack pointer
	push rcx			; Save our original string length

	sys_write rsi, rcx	; Print it!

	; 2) Then, print out 0A2B4C6D by writing to the same stack memory
	mov rcx, 4			; Now, let's mangle our string by writing to memory
	mov al, 0x44		; We'l write A,B,C,D in even positions
.mangle_string:
	mov byte [rsi + rcx * 2 - 1], al
	dec al
	loop .mangle_string

	pop rcx				; Restore our original string length
	sys_write rsi, rcx	; Print it again!

	mov rsp, rbp		; Restore stack, because we are nice

	; 3) Write a plain test message using a syscall
	sys_write msg, msg_len

	; The former is equivalent to the following:
	;
    ; mov     rax, SYS_WRITE	; SYS_WRITE == 1
    ; mov     rdi, STDOUT	; STDOUT == 1
    ; mov     rsi, msg
    ; mov     rdx, msg_len
    ; syscall


	; 4) Print all hex characters one by one, in a loop, using raw system calls
	mov rcx, 16
	mov rsi, HEX_CHARS		; These are defined in lib/io.asm
.loop:
	push rcx
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rdx, 1 ;single-char
	syscall
	pop rcx					; RCX is invalidated during syscall
	inc rsi					; Move to the next char
	loop .loop
	println					; Print out a CR/LF

	; 4a) Print the HEX_CHARS string using our function wrapper
	mov rdi, HEX_CHARS
	mov rsi, 16
	call printstr
	println

	; 4b) Print the same string using our system call macro
	sys_write HEX_CHARS, 16
	println


	; 5) Print a number
	mov rax, 1234543210
	call print_i64
	println

.exit:
	; Exit to OS using a system call (defined in lib/syscall.asm)
	sys_exit 0

	; This is equivalent to:
	;
	; mov rax, SYS_EXIT		; SYS_EXIT == 60
	; mov rdi, 0			; This is the exit code
	; syscall



