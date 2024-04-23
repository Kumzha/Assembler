.model small


skBufDydis	EQU 20
raBufDydis	EQU 20
.stack 100h
.data

	msgError1 db "Open/Close error.1 $ ", 0
	msgError2 db "Open/Close error.2 $ ", 0
	msgError3 db "Open/Close error.3 $ ", 0
	msgError4 db "Open/Close error.4 $ ", 0
	msgError5 db "Open/Close error.5 $ ", 0
	msgError6 db "Open/Close error.6 $ ", 0
	msgError7 db "Open/Close error.7 $ ", 0
	enteris   db  13, 10, '$'
	
	duom	db "number1.txt",0	
	duom2 	db "number2.txt",0
	rez		db "number3.txt",0		
	skBuf	db skBufDydis dup (?)
	raBuf	db raBufDydis dup (' ')
	dFail	dw ?			
	dFail2 	dw ?
	rFail	dw ? 
	num1 	dw 0
	num2 	dw 0
.code
  pradzia:
	mov	ax, @data	
	mov	ds, ax

;*****************************************************
;Duomenų failo atidarymas skaitymui
;*****************************************************

	mov	ah, 3Dh				
	mov	al, 00				
	mov	dx, offset duom			
	int	21h			
	; JC	klaidaAtidarantSkaitymui	;jei atidarant failą skaitymui įvyksta klaida, nustatomas carry flag
	mov	dFail, ax		
;*****************************************************
;Duomenų nuskaitymas iš failo
;*****************************************************

  skaityk1:
	mov	bx, dFail			
	call	SkaitykBuf			
	cmp	ax, 0				
	; JE	uzdarytiRasymui ;jei nepavyko nuskaityti

;*****************************************************
;Darbas su nuskaityta informacija
;*****************************************************

	mov cx, ax ; buffer dydis pirmo skaiciaus
	mov si, offset skBuf
	
	call atoi
	mov num1, ax
	
;*****************************************************
;Duomenų failo uždarymas
;*****************************************************
	
	uzdarytiSkaitymui:
	mov	ah, 3Eh				
	mov	bx, dFail			
	int	21h			
	; JC	klaidaUzdarantSkaitymui		;jei uždarant failą įvyksta klaida, nustatomas carry flag
		
;*****************************************************
;Duomenų failo atidarymas skaitymui
;*****************************************************

	mov	ah, 3Dh				
	mov	al, 00				
	mov	dx, offset duom2		
	int	21h				
	; JC	klaidaAtidarantSkaitymui	;jei atidarant failą skaitymui įvyksta klaida, nustatomas carry flag
	mov	dFail2, ax		


;*****************************************************
;Duomenų nuskaitymas iš failo
;*****************************************************

  skaityk2:
	mov	bx, dFail2			
	call	SkaitykBuf			
	cmp	ax, 0				;ax įrašoma, kiek baitų buvo nuskaityta, jeigu 0 - pasiekta failo pabaiga
	je	uzdarytiRasymui
	
	
	
;*****************************************************
;Darbas su nuskaityta informacija
;*****************************************************
	
	mov cx, ax ; buffer dydis
	mov si, offset skBuf
	
	call atoi   ;ANTRAS SKAICIUS I AX
		
		
	mov dx, num1 ;PIRMAS SKAICIUS I DX
		
	cmp dx, ax
	jge calc2
	jmp calc1
	
	
	
	calc1: 		;Antras didesnis, dx<ax, num2>num1
	
		sub ax, dx
		
		call Skaiciuok	
		
		jmp axToBuf
		
	calc2:      ; Pirmas didesnis dx>ax, num1>num2 arba num1=num2
	
		sub dx, ax 
		mov ax, dx
		
		call Skaiciuok	;NEREIKES
	

	axToBuf:
	
	call SkaiciuokToBuffer
	
;*****************************************************
;Rezultato failo sukūrimas ir atidarymas rašymui
;*****************************************************

	mov	ah, 3Ch			
	mov	cx, 0				
	mov	dx, offset rez			
	int	21h			
	jc	klaidaAtidarantRasymui		;jei kuriant failą skaitymui įvyksta klaida, nustatomas carry flag
	mov	rFail, ax		
		
;*****************************************************
;Rezultato įrašymas į failą
;*****************************************************
	mov	cx, 5				;cx - kiek baitų reikia įrašyti
	mov	bx, rFail		
	call	RasykBuf		
	; CMP	ax, skBufDydis			;jeigu vyko darbas su pilnu buferiu -> iš duomenų failo buvo nuskaitytas pilnas buferis ->
	; JE	skaityk1				;-> reikia skaityti toliau
  
;*****************************************************
;Rezultato failo uždarymas
;*****************************************************
  uzdarytiRasymui:
	mov	ah, 3Eh			
	mov	bx, rFail		
	int	21h			
	jc	klaidaUzdarantRasymui		;jei uždarant failą įvyksta klaida, nustatomas carry flag
	
;*****************************************************
;Duomenų failo uždarymas
;*****************************************************
  uzdarytiSkaitymui2:
	mov	ah, 3Eh				
	mov	bx, dFail2		
	int	21h			
	jc	klaidaUzdarantSkaitymui		;jei uždarant failą įvyksta klaida, nustatomas carry flag

  pabaiga:
	mov	ah, 4Ch			
	mov	al, 0				
	int	21h				

;*****************************************************
;Klaidų apdorojimas
;*****************************************************
  klaidaAtidarantSkaitymui:
	mov ah, 09h
	mov dx, offset msgError1
	int 21h
	jmp	pabaiga
  klaidaAtidarantRasymui:
	mov ah, 09h
	mov dx, offset msgError2
	int 21h
	jmp	uzdarytiSkaitymui
  klaidaUzdarantRasymui:
	mov ah, 09h
	mov dx, offset msgError3
	int 21h
	jmp	uzdarytiSkaitymui
  klaidaUzdarantSkaitymui:
	mov ah, 09h
	mov dx, offset msgError4
	int 21h
	jmp	pabaiga




PROC SkaitykBuf
	push	cx
	push	dx
	
	mov	ah, 3Fh			
	mov	cx, skBufDydis		;cx - kiek baitų reikia nuskaityti iš failo
	mov	dx, offset skBuf	
	int	21h			
	jc	klaidaSkaitant		

  SkaitykBufPabaiga:
	pop	dx
	pop	cx
	ret 
	
  klaidaSkaitant:
	mov ah, 09h
	mov dx, offset msgError5
	int 21h
	mov ax, 0			
	jmp	SkaitykBufPabaiga
SkaitykBuf ENDP

PROC RasykBuf
	push	dx
	
	mov	ah, 40h			
	mov	dx, offset raBuf	
	int	21h			
	jc	klaidaRasant		
	cmp	cx, ax			
	jne	dalinisIrasymas

  RasykBufPabaiga:
	pop	dx
	ret

  dalinisIrasymas:
	mov ah, 09h
	mov dx, offset msgError6
	int 21h
	jmp	RasykBufPabaiga
  klaidaRasant:
	mov ah, 09h
	mov dx, offset msgError7
	int 21h
	mov	ax, 0			
	jmp	RasykBufPabaiga
RasykBuf ENDP	

PROC atoi


   push si
   push cx
   push bx

   mov ax, 0 
   mov si, 0  
   mov cx, 0
   mov di, 10
   
compare:

	cmp byte ptr [skBuf+si], 0
	je end_loop 
	
	mov cl, [skBuf+si]
	
	sub cl, '0'
	
	mul di

	add ax, cx
	
	inc si
	
	jmp compare
	
end_loop:
  
      pop cx
      pop si
      pop di
      ret

atoi endp

; NEREIKES

Proc Skaiciuok
		
			push	ax
			push	cx
			push	dx
			
			mov	cx, 10		
			push	"$$"	
			Dalink:
			mov	dx, 0		
			
			div	cx		
			push dx	
			cmp	ax, 0		
			ja	Dalink		

			
			mov	ah, 2		
			Spausdink:
			pop	dx		
			cmp	dx, "$$"	
			je	Pabaiga1		
			add	dl, '0'		
			int	21h		
			jmp Spausdink	

			Pabaiga1:
			pop	dx
			pop	cx
			pop	ax
			
			ret	
			
	Skaiciuok ENDP
	
	Proc SkaiciuokToBuffer
		
			push	ax
			push	cx
			push	dx
			
			
			
			mov si, 5
			mov di, si
			mov	cx, 10	
			
			; clearBuff:
			; mov byte ptr[raBuf+di], 0
			; dec di
			; cmp di, 0
			; ja clearBuff
				
			Dalink2:
			
			cmp si, 0
			je Pabaiga2
			
			mov	dx, 0	
			
			div	cx	
			
			add dl, '0'
			dec si
			
			; cmp dl, 48
			; jl tarpas
			; cmp dl, 57
			; jg tarpas
			
			
			
			mov byte ptr [raBuf+si], dl
			; jmp dalyba
			
			; tarpas:
			; mov byte ptr [raBuf+si], 20
			; jmp dalyba
			
			; dalyba:
			cmp	ax, 0	;dalyba	
			ja	Dalink2	
			

		
			; iBuf:
			; pop	dx		
			; cmp	dx, "$$"	
			; je	Pabaiga2		
			; add	dl, '0'		
			; mov byte ptr [raBuf+si], dl	
			; inc si
			; jmp iBuf	

			Pabaiga2:
			pop	dx
			pop	cx
			pop	ax
			
			ret	
			
	SkaiciuokToBuffer ENDP

END pradzia