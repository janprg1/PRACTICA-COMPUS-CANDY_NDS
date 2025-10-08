@;=                                                               		=
@;=== candy1_comb.s: rutinas para detectar y sugerir combinaciones    ===
@;=                                                               		=
@;=== Programador tarea 1G: vladyslav.lysyy@estudiants.urv.cat		  ===
@;=== Programador tarea 1H: vladyslav.lysyy@estudiants.urv.cat		  ===
@;=                                                             	 	=



.include "candy1_incl.i"



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1G;
@; hay_combinacion(*matriz): rutina para detectar si existe, por lo menos, una
@;	combinación entre dos elementos (diferentes) consecutivos que provoquen
@;	una secuencia válida, incluyendo elementos con gelatinas simples y dobles.
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 si hay una secuencia, 0 en otro caso
@;  Valores constantes:
		MASC = 0x07					@; mascara de 0x07 para guardar ultimos 3 bits
		BUID = 0x00					@; casilla vacia
		
	.global hay_combinacion
hay_combinacion:

	push {r1-r10, lr}         
	
		mov r4, r0                	@; posicion/direccion actual de la matriz 
		mov r7, #COLUMNS          	@; numero de columnas  
		mov r1, #0                	@; indice filas
	  
	.Lfor_Rows: 
	
		mov r2, #0 					@; indice columnas

	.Lfor_Columns: 
	
		mla r8, r1, r7, r2 			@; calculamos la posicion de la fila (desplazamiento lineal de la celda actual) = (i*COLUMNS) + j 
		ldrb r9, [r4, r8] 			@; cargamos la celda = matriz[i][j] 

		and r3, r9, #MASC 			@; obtenemos 3 bits menos significativos de un elemento
		cmp r3, #BUID            	@; comprobamos si esta vacio 
		beq .Lnext_pos           	@; si es asi, saltamos a la siguente posicion 
		cmp r3, #MASC            	@; comprobamos si es el bloque solido 
		beq .Lnext_pos           	@; si es asi, saltamos a la siguiente posicion
		
		cmp r2, #COLUMNS-1       	@; comprobamos si estamos en la ultima columna 
		beq .LnextV            		@; si es asi, entonces no hay vecino a la derecha. Saltamos a la comprobacion vertical 
		
		mov r5, r8               	@; creamos un registro temporal de la casilla actual 
		add r5, #1               	@; r5 es un indice de la casilla de la derecha i*(j+1) 
		ldrb r10, [r4, r5]       	@; cargamos la celda para nuevo indice r5
		
		and r6, r10, #MASC       	@; obtenemos 3 bits menos significativos de un elemento 
		cmp r6, #BUID           	@; comprobamos si esta vacio  
		beq .LnextV            		@; si es asi, saltamos a la siguente posicion 
		cmp r6, #MASC           	@; comprobamos si es el bloque solido 
		beq .LnextV            		@; si es asi, saltamos a la siguiente posicion 
		cmp r3, r6               	@; comprobamos si los dos elementos(actual y vecina) son iguales 
		beq .LnextV            		@; si es asi, esto no creará secuencia nueva en la hora intercambiarlos. Saltamos 
		
		@; hacemos un intercambio de las posiciones
		strb r9, [r4, r5]        	@; el valor actual -> en la posición derecha 
		strb r10, [r4, r8]       	@; el valor del vecino -> en la posición actual
		 
		bl detecta_orientacion    	@; si devuelva 0..5 -> hay posibles secuencia/s, 6 -> no hay secuencia 
		cmp r0, #6               	@; comprobamos si hay secuencia 
		bne .Lyes_comb           	@; si hay comibinacion, saltamos 
		add r2, #1               	@; si no hay en la primera celda, probamos la otra intercambiada 

		bl detecta_orientacion   	@; comprobamos  para la otra celda 
		cmp r0, #6 					@; comprobamos si hay secuencia 
		bne .Lyes_comb           	@; si hay comibinacion, saltamos 
		sub r2, #1               	@; recuperamos valor original
	
		@; deshacemos el intercambio y restauramos los valores
		strb r9, [r4, r8]        	
		strb r10, [r4, r5]       	 

	.LnextV:
 
		cmp r1, #ROWS-1				@; comprobamos si estamos en la ultima fila 
		beq .Lnext_pos 				@; si es asi, entonces no hay vecino abajo. Saltamos a la siguente posicion 

		add r5, r8, #COLUMNS    	@; r5 es un indice de la celda inferior (posicion actual + COLUMNS) 
		ldrb r10, [r4, r5]      	@; cargamos la celda inferior
		
		and r6, r10, #MASC       	@; obtenemos 3 bits menos significativos de un elemento 
		cmp r6, #BUID           	@; comprobamos si esta vacio  
		beq .Lnext_pos            	@; si es asi, saltamos a la siguente posicion 
		cmp r6, #MASC           	@; comprobamos si es el bloque solido 
		beq .Lnext_pos            	@; si es asi, saltamos a la siguiente posicion 
		cmp r3, r6               	@; comprobamos si los dos elementos(actual y vecina) son iguales 
		beq .Lnext_pos         		@; si es asi, esto no creará secuencia nueva en la hora intercambiarlos. Saltamos 
		
		@; hacemos un intercambio de las posiciones
		strb r9, [r4, r5]       	 
		strb r10, [r4, r8]      	 
		
		bl detecta_orientacion    	@; si devuelva 0..5 -> hay posibles secuencia/s, 6 -> no hay secuencia 
		cmp r0, #6               	@; comprobamos si hay secuencia 
		bne .Lyes_comb           	@; si hay comibinacion, saltamos 
		add r1, #1               	@; si no hay en la primera celda, probamos la otra intercambiada 

		bl detecta_orientacion   	@; comprobamos  para la otra celda 
		cmp r0, #6 					@; comprobamos si hay secuencia 
		bne .Lyes_comb           	@; si hay comibinacion, saltamos 
		sub r1, #1               	@; recuperamos valor original
	
		@; deshacemos el intercambio y restauramos los valores
		strb r9, [r4, r8]        	
		strb r10, [r4, r5]

	.Lnext_pos: 
	
		add r2, #1 					@; avanzamos a la siguiente columna
		cmp r2, r7 					@; si r2 < COLUMNS, repetimos el bucle de columnas
		blt .Lfor_Columns 	 

		add r1, #1              	@; si se han terminado las columnas, avanzamos a la siguiente fila 
		cmp r1, #ROWS 				@; si r1 < ROWS, repetimos el bucle de filas
		blt .Lfor_Rows     

		mov r0, #0              	@; devolvemos 0, si no se ha encontrado ningina combinacion 
		b .Lend 

	.Lyes_comb: 
		
		mov r0, #1 					@; devolvemos 1, si se ha encontrado una combinacion valida
		
		@; aseguramos que la matriz se queda en el estado original 
		strb r9, [r4, r8] 			 @; el valor actual <- en la posición derecha
		strb r10, [r4, r5]			 @; el valor del vecino <- en la posición actual
	 
	.Lend: 
	
	pop {r1-r10, pc} 


@;TAREA 1H;
@; sugiere_combinacion(*matriz, *psug): rutina para detectar una combinación
@;	entre dos elementos (diferentes) consecutivos que provoquen una secuencia
@;	válida, incluyendo elementos con gelatinas simples y dobles, y devolver
@;	las coordenadas de las tres posiciones de la combinación (por referencia).
@;	Restricciones:
@;		* se asume que existe por lo menos una combinación en la matriz
@;			 (se puede verificar con la rutina hay_combinacion() antes de
@;			  llamar a esta rutina)
@;		* la combinación sugerida tiene que ser escogida aleatoriamente de
@;			 entre todas las posibles, es decir, no tiene que ser siempre
@;			 la primera empezando por el principio de la matriz (o por el final)
@;		* para obtener posiciones aleatorias, se invocará la rutina mod_random()
@;			 (ver fichero 'candy1_init.s')
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección del vector de posiciones (unsigned char *), donde se
@;				guardarán las coordenadas (x1,y1,x2,y2,x3,y3), consecutivamente.
	.global sugiere_combinacion
sugiere_combinacion:
		push {lr}
		
		
		pop {pc}




@;:::RUTINAS DE SOPORTE:::

@; genera_posiciones(vect_pos, f, c, ori, cpi): genera las posiciones de 
@;	sugerencia de combinación, a partir de la posición inicial (f,c), el código
@;	de orientación ori y el código de posición inicial cpi, dejando las
@;	coordenadas en el vector vect_pos[].
@;	Restricciones:
@;		* se asume que la posición y orientación pasadas por parámetro se
@;			corresponden con una disposición de posiciones dentro de los
@;			límites de la matriz de juego
@;	Parámetros:
@;		R0 = dirección del vector de posiciones vect_pos[]
@;		R1 = fila inicial f
@;		R2 = columna inicial c
@;		R3 = código de orientación ori:
@;				inicio de secuencia: 0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte
@;				en medio de secuencia: 4 -> horizontal, 5 -> vertical
@;		R4 = código de posición inicial cpi:
@;				0 -> izquierda, 1 -> derecha, 2 -> arriba, 3 -> abajo
@;	Resultado:
@;		vector de posiciones (x1,y1,x2,y2,x3,y3), devuelto por referencia
genera_posiciones:
		push {lr}
		
		
		pop {pc}



@; detecta_orientacion(f, c, mat): devuelve el código de la primera orientación
@;	en la que detecta una secuencia de 3 o más repeticiones del elemento de la
@;	matriz situado en la posición (f,c).
@;	Restricciones:
@;		* para proporcionar aleatoriedad a la detección de orientaciones en las
@;			que se detectan secuencias, se invocará la rutina mod_random()
@;			(ver fichero 'candy1_init.s')
@;		* para detectar secuencias se invocará la rutina cuenta_repeticiones()
@;			(ver fichero 'candy1_move.s')
@;		* solo se tendrán en cuenta los 3 bits de menor peso de los códigos
@;			almacenados en las posiciones de la matriz, de modo que se ignorarán
@;			las marcas de gelatina (+8, +16)
@;	Parámetros:
@;		R1 = fila f
@;		R2 = columna c
@;		R4 = dirección base de la matriz
@;	Resultado:
@;		R0 = código de orientación;
@;				inicio de secuencia: 0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte
@;				en medio de secuencia: 4 -> horizontal, 5 -> vertical
@;				sin secuencia: 6 
detecta_orientacion:
		push {r3, r5, lr}
		
		mov r5, #0				@;R5 = índice bucle de orientaciones
		mov r0, #4
		bl mod_random
		mov r3, r0				@;R3 = orientación aleatoria (0..3)
	.Ldetori_for:
		mov r0, r4
		bl cuenta_repeticiones
		cmp r0, #1
		beq .Ldetori_cont		@;no hay inicio de secuencia
		cmp r0, #3
		bhs .Ldetori_fin		@;hay inicio de secuencia
		add r3, #2
		and r3, #3				@;R3 = salta dos orientaciones (módulo 4)
		mov r0, r4
		bl cuenta_repeticiones
		add r3, #2
		and r3, #3				@;restituye orientación (módulo 4)
		cmp r0, #1
		beq .Ldetori_cont		@;no hay continuación de secuencia
		tst r3, #1
		moveq r3, #4			@;detección secuencia horizontal
		beq .Ldetori_fin
	.Ldetori_vert:
		mov r3, #5				@;detección secuencia vertical
		b .Ldetori_fin
	.Ldetori_cont:
		add r3, #1
		and r3, #3				@;R3 = siguiente orientación (módulo 4)
		add r5, #1
		cmp r5, #4
		blo .Ldetori_for		@;repetir 4 veces
		
		mov r3, #6				@;marca de no encontrada
		
	.Ldetori_fin:
		mov r0, r3				@;devuelve orientación o marca de no encontrada
		
		pop {r3, r5, pc}



.end
