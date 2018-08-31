%macro print 3
	mov rdi, %3
	mov rax, 1
	mov rsi, %1
	mov rdx, %2
	syscall
%endmacro
%macro read 3
	mov rdi, %3
	mov rax, 0
	mov rsi, %1
	mov rdx, %2
	syscall
%endmacro
%macro borrarReg 0
	xor rax, rax
	xor rdi, rdi
	xor rsi, rsi
	xor rdx, rdx
	xor r10, r10
	xor r9, r9
	xor r8, r8
%endmacro
%macro open 1
	mov rax, 2			;2 = codigo de syscall para open() 
	mov rdi, %1		; le decimos que archivo estamos leyendo
	mov rsi, 66		; le decimos si queremos leer y escribir
	mov rdx, 0777o	; le decimos cuales son los permisos que le otorgamos en caso de que tenga que crearlo
	syscall
%endmacro
%macro ASCII2INT 1 	;recibe una direccion de memoria donde
	xor r10,r10	;esta la primera unidad del dato
	mov r10,%1	;cargamos r10 con la dir de las centenas
	xor r11,r11
	mov r11,r10
	add r11,1	;cargamos r11 con la dir de las decenas
	xor r12,r12
	mov r12,r10
	add r12,2	;cargamos r12 con la dir de las unidades
	xor rax,rax
	mov al,[r10]
	add al,-48
	mull 100
	mov rbx, rax	;cargamos rbx con el valor de las centenas
	mov al, [r11]
	add al, -48
	mul 10
	add rbx,rax	;cargamos rbx con el valor de las centenas + decenas
	mov al, [r12]
	add al, -48
	add rbx, rax	;cargamos rbx con el valor total
	mov rax, rbx	;el resultado se da tanto en rax como en rbx
%endmacro
section .data
	text0 db 10,10,"Instituto Tecnologico de Costa Rica", 10
	text1 db "Gerardo Esteban Gonzalez Gutierrez", 10
	text2 db "Carnet: 201209371", 10
	text3 db "Informacion del archivo de datos:", 10,10
	text4 db "Esta mal escrito el archivo de configuracion para el ordenamiento",10
	tamt4 equ $-text4	
	text5 db "Se va a ordenar de modo Alfabetico",10
	tamt5 equ $-text5
	text6 db "Se va a ordenar por nota",10
	tamt6 equ $-text6
	text7 db 65
	dirConf	db "configuracion.txt", 0
	dirDato db "datos.txt", 0
	dirTemp db "tmp.txt", 0
section .bss
	variableDato resb 800 ; Debe quedar al final siempre
	variableConf resb 600 ; O usar distintas varibles para cada cosa
section .text
	global _start
_start:
	print text0, 38, 1
	print text1, 35, 1
	print text2, 18, 1
	borrarReg		
	; abrimos el archivo
	open dirDato	
	; leemos el archivo
	push rax		; guardamos el identificador en rax
	read variableDato,800, rax
;escribimos lo que tiene el archivo
	print text3, 35,1
	print variableDato, 800, 1
	print text0,1,1         ; solo un salto de renglon
; exit fileg
	mov rax, 3
	pop rdi			; utilizamos el identificador del rax que guardamos para cerrarel doc
	syscall
;abrimos el archivo de configuracio
;------------------------------
	open dirConf
	push rax	; abrimos el archivo de conf e guardamos 
	read variableConf,600, rax
	mov rax,3	; ya esta el archivo en la variable asi que se cierra, a menos que se 
	pop rdi		; quiera escribir en el, que no es el caso xq es el de conf
	syscall
Ordenar1:
	add rsi, 1				; agrego 1 al rsi, que tiene el puntero de la memoria del texto 
	mov al, [rsi]			; muevo a al,  la letra que estoy analizando
	cmp rax, 4fh ;724fh	; me fijo a ver si es una 'O' para ver si la que viene es Ordenamiento, por nombre o nota 
	jne Ordenar1
;------------------------------	
Ordenar2:
	add rsi, 1		; sigo analizando el doc
	mov al, [rsi]
	cmp rax, 32		;primero busco un espacio, la letra siguiente dicta el orden
	jne Ordenar2
;------------------------------
Ordenar3:			; ahora se ve si la letra es a o n 
	add rsi, 1
	mov al, [rsi]
	cmp rax, 97 		; 97= a por lo tanto orden alfabetico
	je OrdAlf
	cmp rax, 110		; 110= n por lo tanto otden por nota
	je OrdNot
	print text4,tamt4 ,1	; aca deberia entrar si ninguna de las condiciones arriba se cumplen
	jmp finOrd
OrdAlf:
	print text5,tamt5,1 
	;---
	;		ordenamos el archivo de manera alfabetica
		open dirDato	;abrimos el archivo de datos
		push rax	
		read variableDato,800,rax	;leemos el archivo de datos
		mov r15, rsi
		mov rax,3	; cerramos el archivo leido
		pop rdi
		syscall

		borrarReg
		open dirTemp	; abrimos un archivo temporal
		push rax
;		print variableDato,800, rax ;guardamos lo que leimos en el archivo temporal

		
	inicioA:	
		mov rsi, r15
		;vemos la letra inicial
	eval:
		mov al, [rsi]
		cmp al, [text7] ;evaluamos la letra comenzando por la A
		je continuar1
			;si no es una letra A, o la que toque en el momento
			ent:;	buscamos el enter, o el fin del documento
				inc rsi
				mov al, [rsi]
				cmp al, 10
				je eval2
				cmp al, 0
				jne  ent
				mov rax, text7
				add byte [rax], 1
				mov bl, [rax]
				cmp bl,123
				je finCont
				jmp inicioA
			eval2:
				inc rsi
				jmp eval
		continuar1:
			push rsi
			ciclo:

				inc r14  ; evaluo el tamano del nombre
				inc rsi
				mov al, [rsi]
				cmp al, 10 ; busco un enter, donde termina el nombre
				je continuar2 
				jmp ciclo
			continuar2:
				borrarReg
				pop rsi
				pop rax         ;uso y guardo el identificador del archivo
				push rax
				push rsi
				inc r14	
				print rsi, r14, rax  ; imprimo el nombre en el doc temporal
				;borramos el nombre
				dec r14
				mov r13, r14
				mov rcx, r14
				dec r14
				pop rsi
				borrar:
		b:			mov byte [rsi+r14], 32
		c:			dec r14
		d:			loop borrar
				inc r14
				add rsi, r13
				cmp byte [rsi], 0   ;se pregunta si se acabo el documento, para buscar la proxima letra
				jne inicioA 
				mov rsi, text7
				add byte [rsi],1
				xor rax,rax
				mov al, [rsi]
				cmp al,91	;si la letra a ordenar es mayor a una Z nos pasamos y terminamos
				je finCont
				jmp inicioA
		finCont:
			mov rax, 3
			pop rdi
			syscall
	jmp finOrd
OrdNot:
	;-------------------------------------------------------------------------------
	print text5,tamt5,1 
	;---
	;		ordenamos el archivo de manera alfabetica
		open dirDato	;abrimos el archivo de datos
		push rax	
		read variableDato,800,rax	;leemos el archivo de datos
		mov r15, rsi
		mov rax,3	; cerramos el archivo leido
		pop rdi
		syscall

		borrarReg
		open dirTemp	; abrimos un archivo temporal
		push rax
;		print variableDato,800, rax ;guardamos lo que leimos en el archivo temporal

		
	inicioN:	
		mov rsi, r15
		;vemos la letra inicial
	evalN:
		mov al, [rsi]
		cmp al, [text7] ;evaluamos la letra comenzando por la A
		je continuar1
			;si no es una letra A, o la que toque en el momento
			entN:	;buscamos el enter, o el fin del documento
				inc rsi
				mov al, [rsi]
				cmp al, 10
				je eval2
				cmp al, 0
				jne  ent
				mov rax, text7
				add byte [rax], 1
				mov bl, [rax]
				cmp bl,91
				je finCont
				jmp inicioA
			evalN2:
				inc rsi
				jmp eval
		continuarN1:
			push rsi
			cicloN:
				inc r14  ; evaluo el tamano del nombre
				inc rsi
				mov al, [rsi]
				cmp al, 10 ; busco un enter, donde termina el nombre
				je continuar2 
				jmp ciclo
			continuarN2:
				borrarReg
				pop rsi
				pop rax         ;uso y guardo el identificador del archivo
				push rax
				push rsi
				inc r14	
				print rsi, r14, rax  ; imprimo el nombre en el doc temporal
				;borramos el nombre
				dec r14
				mov r13, r14
				mov rcx, r14
				dec r14
				pop rsi
				borrarN:
		bN:		mov byte [rsi+r14], 32
		cN:			dec r14
		dN			loop borrarN
				inc r14
				add rsi, r13
				cmp byte [rsi], 0   ;se pregunta si se acabo el documento, para buscar la proxima letra
				jne inicioA 
				mov rsi, text7
				add byte [rsi],1
				xor rax,rax
				mov al, [rsi]
				cmp al,123	;si la letra a ordenar es mayor a una Z nos pasamos y terminamos
				je finCont
				jmp inicioA
		finContN:
			mov rax, 3
			pop rdi
			syscall
	jmp finOrd
	;--------------------------------------------------------------------------------
	print text6,tamt6,1
finOrd:
		
	; si la letra con la que comienza la conf es a, entonces esta pidiendo un orden alfabetico
	mov rax, 60
	mov rdi, 0
	syscall
