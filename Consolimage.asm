;; File Consolimage.asm for Linux O.S.
;; Copyright (c) Revas, 2020.
;; I, the author, hereby grant everyone the right to use this
;; file for any purpose, in any manner, in it's original or
;; modified form, provided that any modified versions are
;; clearly marked as such.

;nasm -f elf Consolimage.asm && ld -melf_i386 -o Consolimage Consolimage.o


%include "Consolib.inc"

section .data
helpmsg			db "Usage: Consolimage <file name>", 10
helpmsgln 		equ $-helpmsg
err_file_i 		db "Problem with openning file", 10
err_file_iln	equ $-err_file_i


section .bss
argc 	resd 1
argvp	resd 1

fdfile 	resd 1

chr		resb 2
chrln	equ $-chr

i 		resb 1
w_i		resb 2
h_i 	resb 2

section .text
	global	_start 
_start:

	pop dword [argc] ; get argc
	mov [argvp], esp ; get argvp
	cmp dword [argc], 2
	je .argc_count_ok
	PRINTVAR helpmsg, helpmsgln
	RETURN 1

.argc_count_ok:
	;filename
	mov 	esi, [argvp]
	mov 	edi, [esi+4]
	syscall 5, edi, 0
	cmp 	eax, 0
	jge 	.file_open_ok
	PRINTVAR err_file_i, err_file_iln
	RETURN 	1

.file_open_ok:
	mov 	[fdfile], eax ; 
	mov	word[i], 0
	mov word[w_i], 0
	mov word[h_i], 0
.again:
	syscall 	3, [fdfile], chr, chrln

	;skip head of tiff
	inc	word[i] 
	cmp	word[i], 4
	jl .again

	;resolution
	inc	word[w_i]
	cmp word[w_i], 75 ; width/2+width
	je .endl
	jmp .black_or_white

.endl:
	PRINTTXT 10
	mov word[w_i], 0

	;skip tiff end
	inc	word[h_i]
	cmp word[h_i], 50 ; height
	je .eof

.black_or_white:
	cmp word[chr], word 0x0000 ; ERROR
	jl .black_color
	PRINTTXT " "
	jmp .illbeback
.black_color:
	PRINTTXT "/"


.illbeback:
	cmp eax, 0
	jle .eof
	jmp .again

.eof:
	syscall 6, [fdfile] ; close file
	RETURN 0