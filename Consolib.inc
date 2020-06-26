;; File Consolib.inc for Linux O.S.
;; Copyright (c) Revas, 2020.
;; I, the author, hereby grant everyone the right to use this
;; file for any purpose, in any manner, in it's original or
;; modified form, provided that any modified versions are
;; clearly marked as such.

;;Compile specefication: ld -melf_i386

%macro syscall 1-*
	%rep %0
	%rotate -1
		push dword %1
	%endrep
		pop eax
		%if %0 > 1
		pop ebx
		%if %0 > 2
		pop ecx
		%if %0 > 3
		pop edx
		%if %0 > 4
		pop esi
		%if %0 > 5
		pop edi
		%if %0 > 6
	%error "Too many params for Linux syscall"
		%endif
		%endif
		%endif
		%endif
		%endif
	%endif
	int 80h
%endmacro


%macro PRINTVAR 2 ; %1: String, %2: String length
	pusha
	pushf
	jmp %%astr
%%astr:	syscall 4, 1, %1, %2
	popf
	popa
%endmacro


%macro PRINTTXT 1 ; %1: String
	pusha
	pushf
	jmp %%astr
%%str	db	%1, 0
%%strln	equ	$-%%str
%%astr:	syscall 4, 1, %%str, %%strln
	popf
	popa
%endmacro


%macro RETURN 1 ; %1: return code
		mov	eax, 1 	; call _exit
		mov ebx, %1
		int 80h 
%endmacro


