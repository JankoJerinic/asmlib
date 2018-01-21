%ifndef syscall_included
%define syscall_included 1

; Linux syscalls
; Full list: http://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/
SYS_WRITE   equ 1
SYS_EXIT	equ 60

%macro  sys_write    2
		; Prints out a string with a given number of bytes
		push rax
		push rcx
		push rdx
		push rsi
		push rdi
		mov     rax, SYS_WRITE
        mov     rdx, %2
        mov     rsi, %1
		mov     rdi, STDOUT
        syscall
		pop rdi
		pop rsi
		pop rdx
		pop rcx
		pop rax

%endmacro

%macro sys_exit 1
	; Exits the program with the given exit code
    mov    rax, SYS_EXIT
    mov    rdi, %1
    syscall
%endmacro

section .data

foo: db "I am local data, yaaay", 13, 10
foo_len: equ $-foo

%endif
