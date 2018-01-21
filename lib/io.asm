; File descriptor IDs
STDOUT	equ 1

section .data

; Character constants
CHAR_CRLF db 0x0D, 0X0A
CHAR_0 equ '0'
CHAR_MINUS equ '-'

section .text

%macro println 0
	;/*
	; Prints a newline character (CR/LF)
	; Modifies:
	;   RAX, RDX, RSI, RDI
	;*/
	sys_write CHAR_CRLF, 2
%endmacro

printstr:
	;/*
	; Prints out a string;
	; Input:
	;  RDI - Address of the string
	;  RSI - Length of the string
	; Modifies:
	;  RAX, RSI, RDI
	;*/
	sys_write rdi, rsi
	ret

strlen:
	;/*
	; Input:
	;  RDI - Adress of the null-terminated string
	; Output:
	;  RCX - The length of the string, without the null terminator
	; Modifies:
    ;  RDI 
	; Useful link:
	;  https://stackoverflow.com/questions/27594297/how-to-print-a-string-to-the-terminal-in-x86-64-assembly-nasm-without-syscall
	;*/ 
	push rax
	push rdi
	mov		rcx, -1
	xor     rax, rax            ; Zero the AL register for comparison
	cld                         ; Make sure we're going forward
	repnz   scasb               ; Decrease RCX until we hit null byte
.loop_end:
	not     rcx                 ; Convert to absolute value
	dec     rcx                 ; Skip the terminator
	pop rdi
	pop rax
	ret

read_i64:
	;/*
	; Reads a null-terminated string from a specified location and converts it to a number.
	;
	; Input:
	;  RDI - Address of a null-terminated string
	; Output:
	;  RAX - Parsed 64-bit integer
	; Modifies:
	;  RAX, RBX, RDX
	;*/
	push rbx				; Preserve RBX
	xor rax, rax			; RAX is our accumulator
.loop:
	xor rdx, rdx			; DL will store our characters
	mov dl, byte [rdi]
	or dl, dl
	jz .end_loop			; We've encountered a null char
	sub dl, CHAR_0			; TODO: Allow numeric chars only, parse HEX
	mov rbx, rax
	shl rbx, 1				; RBX = RAX * 2
	shl rax, 3				; RAX *= 8
	add rax, rbx			; RAX = RAX << 3 + RAX << 1 // RAX * 10
	add rax, rdx			; Add the digit into the accumulator
	inc rdi
	jmp .loop
.end_loop:
	pop rbx
	ret
	
print_i64:
	;/*
	;* Prints out the representation of an Int64 number.
	;* Input: 
	;*	RAX - Number to convert
	;*	RBX - Base (optional, default is 10)
	;* Modifies:
	;*  RAX, RBX, RCX, RDI, RSI
	;*/
	push rbp
	push rax
	push rbx
	push rcx
	push rdx
	push rsi
	push rdi
	mov rbp, rsp		; Stash our stack pointer

	; we start by having a number in rax
	; Base should be in EBX. Otherwise, assume 10.
	or ebx, ebx		; if ebx < 0, set default base
	jle .set_base
	cmp ebx, 16		; if ebx > 16, set default base
	jg .set_base
	jmp .base_valid
.set_base:
	mov ebx, 10
.base_valid:
	xor rcx, rcx ; we're counting digits in rcx
	xor rdi, rdi
	mov rsi, rsp ; we're storing digits in [rsi]

	cmp rax, 0			; Handle zero and negative values
	jg .digit_loop
	jl .is_negative
.is_zero:
	push qword CHAR_0	; Put a single '0' char on the stack
	mov rdx, 1			; RDX contains the digit count
	jmp .end_aligning
.is_negative:
	mov rdi, -1			; We'll use RDI to signal negative value
	neg rax
.digit_loop:
	or rax, rax			; until we reach 0
	jz .end_digit_loop
	xor rdx, rdx		; Zero-out rdx as we are dividing rax:rdx
	div ebx				; digit is in rdx (dl)

	;add rdx, CHAR_0		; convert to char (add '0')
	movsx rdx, byte [HEX_CHARS + rdx]	; This supports HEX digits

	dec rsi				; make room for the next digit
	cmp rsp, rsi
	jle .store_digit
	push qword 0		; allocate 8 bytes on stack
.store_digit:
	mov byte [rsi], dl	; copy the digit to rsi
	inc rcx				; count it
	jmp .digit_loop
.end_digit_loop:

	; Take care of the optional minus sign
	cmp rdi, 0
	jz .after_store_sign
	dec rsi				; make room for the minus sign
	cmp rsp, rsi
	jle .store_sign
	push qword 0		; allocate 8 bytes on stack
.store_sign:
	mov byte [rsi], CHAR_MINUS	; put ths minus sign
	inc rcx				; count it
.after_store_sign:

	mov rdx, rcx		; Store the number of bytes needed for digits 
	mov rdi, rcx		; Store the number of bits needed for digits
	shl rdi, 3

	cmp rsp, rsi 
	jz .end_aligning
	; align and fix RSI to be aligned with RSP. If we encounter, say, 11 digits, we will
	; allocate 2 qwords (16 bytes) on stack, but RSI will not be properly aligned. 
	; For instance, if number is 123456789AB, in memory, that looks like:
	; Memory: RSP [0000 0123][4567 89AB]
	;		  RSI [1234 5678][9AB0 0000]
	;
	; To fix this, we will align RSI with RSP and shift some bits. Initially, we keep
	; track of the byte offset (RSI - RSP).
	; When we take the lowest QWORD from memory [0000 0123], because it's little endian,
	; we get 0x32100000. In order to shift the bytes down, we SHR by (RSI - RSP) bytes,
	; getting 0x00000321.
	; Now: 
	; Memory: RSP [1230 0000][4567 89AB] 
	;
	; From then, for every next QWORD, we take the lower (RSI - RSP) bytes, shift them up
	; by 8 - (RSI - RSP) bytes and add them to the previous QWORD.
	; For instance, memory [4567 89AB] is the following: 0xBA987654. 
	; Shifting left by 8 - (RSI - RSP) = 3 bytes, we get 0x87654000, which is represented
	; in memory as [0004 5678]. Now, adding that to the previous QWORD, we get, 
	; 0x87654000 + 0x00000321 = 0x87654321, or, in memory [1234 5678].
	; Now, our memory looks like:
	; RSP: [1234 5678][4567 89AB], and we want to fix our upper QWORD to look like
	; [9AB0 000]. Well, we get that by simply SHR-ing that value by (RSI - RSP)

	mov rcx, rsi
	sub rcx, rsp		; CL now has the delta (in bytes)

	mov rbx, 8
	sub rbx, rcx		; BL now has 8-delta (in bytes)
	
	shl rcx, 3			; Convert to bits, for shifting
	shl rbx, 3

	mov rsi, rsp		; Align RSI with RSP

	shr qword [rsi], cl ; Move overflow digits to the lower dword

	sub rdi, rbx		; Account for (8-delta) processed digits
	jz .end_aligning
.begin_aligning:
	add rsi, 8			; Move to next qword

	mov rax, [rsi]		; Take the lower 'delta' bytes and push them up
	xchg rbx, rcx
	shl rax, cl
	or qword [rsi - 8], rax

	xchg rbx, rcx		; Now, take upper (8-delta) bytes and push them down
	shr qword [rsi], cl

	sub rdi, 64			; Account for processing 8 bytes
	jz .end_aligning	
	jmp .begin_aligning
.end_aligning:
	; rdx already contains the digit count
	; string to write is on the stack (rsp)
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    mov     rsi, rsp
    syscall
	
	mov rsp, rbp		; Restore stack
	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rbx
	pop rax
	pop rbp
	ret

section .data
	HEX_CHARS: db 48,49,50,51,52,53,54,55,56,57,65,66,67,68,69,70

