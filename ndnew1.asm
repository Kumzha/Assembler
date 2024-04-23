	LOCALS @@      

	.MODEL small   

	buferioDydis EQU 121
	
	.STACK 100h     
	
	.DATA
	
	bufDydis DB  buferioDydis
	nuskaite DB  ?				
	buferis DB  buferioDydis dup (?)
	
	msg_first db "Please input a string: $ ", 0
	msg_output db "Number of upper case letters: $", 0
	counter dw 0
	enteris  DB  13, 10, '$'

    .CODE 
	
		strt:
		
			mov ax, @data
			mov ds, ax
		
			mov ah, 09h
			mov dx, offset msg_first
			int 21h

			mov ah, 0Ah
			mov dx, OFFSET bufDydis
			int 21h	
			
			MOV	ah, 09h
			MOV	dx, offset enteris
			INT	21h
			
		algoritmas:
			mov cl, nuskaite
			
			mov bx, OFFSET buferis
			
			mov dl, 'A'
			mov dh, 'Z'
		;   A - 41
		;	Z - 5A(60)
		;	0 - 30
		;   9 - 39
		looop:
		
			cmp [bx], dh
			ja lower_case
			
			cmp [bx], dl
			jb	lower_case
						
			inc counter
		
		lower_case:
			inc bx
			dec cl
			cmp cl, 0
			jne looop
				
			mov ah, 09h
			mov dx, offset msg_output
			int 21h
			
			mov	ax, counter
			call Skaiciuok
			
						
			mov ax, 04C00h
			int 21h
	
		Skaiciuok PROC
		
			push	ax
			push	cx
			push	dx
			
			mov	cx, 10		
			push	"$$"	
			Dalink:
			mov	dx, 0		
			
			div	cx		
			push	dx	
			cmp	ax, 0		
			ja	Dalink		

			
			mov	ah, 2		
			Spausdink:
			pop	dx		
			cmp	dx, "$$"	
			je	Pabaiga		
			add	dl, '0'		
			int	21h		
			jmp Spausdink	

			Pabaiga:
			pop	dx
			pop	cx
			pop	ax
			ret	
			
			Skaiciuok ENDP
			
		END Strt
				
	