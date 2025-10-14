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
		NO_COMB_VALID = 6			@; no hay combinacion valida
		
	.global hay_combinacion
hay_combinacion:

		push {r1-r10, lr}         
	
		mov r4, r0                	@; posicion/direccion actual de la matriz 
		mov r7, #COLUMNS          	@; numero de columnas  
		mov r1, #0                	@; indice filas
	  
	.Lfor_RowsG: 
	
		mov r2, #0 					@; indice columnas

	.Lfor_ColumnsG: 
	
		mla r8, r1, r7, r2 			@; calculamos la posicion de la fila (desplazamiento lineal de la celda actual) = (i*COLUMNS) + j 
		ldrb r9, [r4, r8] 			@; cargamos la celda = matriz[i][j] 

		and r3, r9, #MASC 			@; obtenemos 3 bits menos significativos de un elemento
		cmp r3, #BUID            	@; comprobamos si esta vacio 
		beq .Lnext_posG           	@; si es asi, saltamos a la siguente posicion 
		cmp r3, #MASC            	@; comprobamos si es el bloque solido 
		beq .Lnext_posG          	@; si es asi, saltamos a la siguiente posicion
		
		cmp r2, #COLUMNS-1       	@; comprobamos si estamos en la ultima columna 
		beq .LnextG            		@; si es asi, entonces no hay vecino a la derecha. Saltamos a la comprobacion vertical 
		
		mov r5, r8               	@; creamos un registro temporal de la casilla actual 
		add r5, #1               	@; r5 es un indice de la casilla de la derecha i*(j+1) 
		ldrb r10, [r4, r5]       	@; cargamos la celda para nuevo indice r5
		
		and r6, r10, #MASC       	@; obtenemos 3 bits menos significativos de un elemento 
		cmp r6, #BUID           	@; comprobamos si esta vacio  
		beq .LnextG            		@; si es asi, saltamos a la siguente posicion 
		cmp r6, #MASC           	@; comprobamos si es el bloque solido 
		beq .LnextG            		@; si es asi, saltamos a la siguiente posicion 
		cmp r3, r6               	@; comprobamos si los dos elementos(actual y vecina) son iguales 
		beq .LnextG            		@; si es asi, esto no creará secuencia nueva en la hora intercambiarlos. Saltamos 
		
		@; HORIZONTAL
		@; hacemos un intercambio de las posiciones
		strb r9, [r4, r5]        	@; el valor actual -> en la posición derecha 
		strb r10, [r4, r8]       	@; el valor del vecino -> en la posición actual
		 
		bl detecta_orientacion    	@; si devuelva 0..5 -> hay posibles secuencia/s, 6 -> no hay secuencia 
		cmp r0, #NO_COMB_VALID      @; comprobamos si hay secuencia 
		bne .Lyes_comb           	@; si hay comibinacion, saltamos 
		add r2, #1               	@; si no hay en la primera celda, probamos la otra intercambiada 

		bl detecta_orientacion   	@; comprobamos  para la otra celda 
		cmp r0, #NO_COMB_VALID 		@; comprobamos si hay secuencia 
		bne .Lyes_comb           	@; si hay comibinacion, saltamos 
		sub r2, #1               	@; recuperamos valor original
	
		@; deshacemos el intercambio y restauramos los valores
		strb r9, [r4, r8]        	
		strb r10, [r4, r5]       	 

	.LnextG:						@; VERTICAL
 
		cmp r1, #ROWS-1				@; comprobamos si estamos en la ultima fila 
		beq .Lnext_posG				@; si es asi, entonces no hay vecino abajo. Saltamos a la siguente posicion 

		add r5, r8, r7    			@; r5 es un indice de la celda inferior (posicion actual + COLUMNS) 
		ldrb r10, [r4, r5]      	@; cargamos la celda inferior
		
		and r6, r10, #MASC       	@; obtenemos 3 bits menos significativos de un elemento 
		cmp r6, #BUID           	@; comprobamos si esta vacio  
		beq .Lnext_posG           	@; si es asi, saltamos a la siguente posicion 
		cmp r6, #MASC           	@; comprobamos si es el bloque solido 
		beq .Lnext_posG           	@; si es asi, saltamos a la siguiente posicion 
		cmp r3, r6               	@; comprobamos si los dos elementos(actual y vecina) son iguales 
		beq .Lnext_posG         		@; si es asi, esto no creará secuencia nueva en la hora intercambiarlos. Saltamos 
		
		@; hacemos un intercambio de las posiciones
		strb r9, [r4, r5]       	 
		strb r10, [r4, r8]      	 
		
		bl detecta_orientacion    	@; si devuelva 0..5 -> hay posibles secuencia/s, 6 -> no hay secuencia 
		cmp r0, #NO_COMB_VALID      @; comprobamos si hay secuencia 
		bne .Lyes_comb           	@; si hay comibinacion, saltamos 
		add r1, #1               	@; si no hay en la primera celda, probamos la otra intercambiada 

		bl detecta_orientacion   	@; comprobamos  para la otra celda 
		cmp r0, #NO_COMB_VALID 		@; comprobamos si hay secuencia 
		bne .Lyes_comb           	@; si hay comibinacion, saltamos 
		sub r1, #1               	@; recuperamos valor original
	
		@; deshacemos el intercambio y restauramos los valores
		strb r9, [r4, r8]        	
		strb r10, [r4, r5]

	.Lnext_posG: 
	
		add r2, #1 					@; avanzamos a la siguiente columna
		cmp r2, r7 					@; si r2 < COLUMNS, repetimos el bucle de columnas
		blt .Lfor_ColumnsG 	 

		add r1, #1              	@; si se han terminado las columnas, avanzamos a la siguiente fila 
		cmp r1, #ROWS 				@; si r1 < ROWS, repetimos el bucle de filas
		blt .Lfor_RowsG     

		mov r0, #0              	@; devolvemos 0, si no se ha encontrado ningina combinacion 
		b .Lend 

	.Lyes_comb: 
		
		mov r0, #1 					@; devolvemos 1, si se ha encontrado una combinacion valida
		
		@; aseguramos que la matriz se queda en el estado original 
		strb r9, [r4, r8] 			@; el valor actual <- en la posición derecha
		strb r10, [r4, r5]			@; el valor del vecino <- en la posición actual
	 
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

		push {r0-r12, lr}
 
		mov r4, r0 					@; posicion/direccion actual de la matriz 
		mov r8, r1 					@; r8 es un puntero destino psug (lo usaremos al final) 
		mov r0, #ROWS-1 			@; preparamos para coger una fila aleatoria entre 0 y ROWS-1 
		bl mod_random 				@; devuelve número aleatorio en r0
		mov r1, r0 					@; fila inicial aleatoria
		mov r0, #COLUMNS-1 			@; preparamos para coger una columna aleatoria entre 0 y COLUMNS-1 
		bl mod_random 
		mov r2, r0 					@; columna inicial aleatoria
		mov r7, #COLUMNS 			@; numero de columnas 

	.Lfor_RowsH: 

	.Lfor_ColumnsH: 

		mla r9, r1, r7, r2 			@; calculamos la posicion de la fila (desplazamiento lineal de la celda actual) = (i*COLUMNS) + j
		ldrb r10, [r4, r9] 			@; cargamos la celda = matriz[i][j] 
		
		and r3, r10, #MASC 			@; obtenemos 3 bits menos significativos de un elemento
		cmp r3, #BUID            	@; comprobamos si esta vacio 
		beq .LnextH          		@; si es asi, saltamos a la siguente posicion 
		cmp r3, #MASC            	@; comprobamos si es el bloque solido 
		beq .LnextH           		@; si es asi, saltamos a la siguiente posicion 

		cmp r2, #COLUMNS-1       	@; comprobamos si estamos en la ultima columna 
		beq .LnextH            		@; si es asi, entonces no hay vecino a la derecha. Saltamos a la comprobacion horizontal  
		
		mov r5, r9               	@; creamos un registro temporal de la casilla actual 
		add r5, #1               	@; r5 es un indice de la casilla de la derecha i*(j+1) 
		ldrb r11, [r4, r5]       	@; cargamos la celda para nuevo indice r5
		
		and r6, r11, #MASC       	@; obtenemos 3 bits menos significativos de un elemento 
		cmp r6, #BUID           	@; comprobamos si esta vacio  
		beq .LnextH            		@; si es asi, saltamos a la siguente posicion 
		cmp r6, #MASC           	@; comprobamos si es el bloque solido 
		beq .LnextH            		@; si es asi, saltamos a la siguiente posicion 
		cmp r3, r6               	@; comprobamos si los dos elementos(actual y vecina) son iguales 
		beq .LnextH            		@; si es asi, esto no creará secuencia nueva en la hora intercambiarlos. Saltamos 
		
		@; HORIZONTAL
		@; hacemos un intercambio de las posiciones
		strb r10, [r4, r5]        	@; el valor actual -> en la posición derecha 
		strb r11, [r4, r9]       	@; el valor del vecino -> en la posición actual

		bl detecta_orientacion 		
		cmp r0, #NO_COMB_VALID 
		movne r12, r4 				@; Si detecta_orientacion devuelve !=6, entonces hay secuencia
									@; movne (only-if-not-equal) copia r4 (base matriz) a r12
									@; asi preparamos r12 como un puntero base para restaurar el swap mas tarde 
									@; preparamos el codigo posicional cpi
		movne r4, #0 				@; IZQUIERDA - movemos 0 al r4 para indicar cual de las dos celdas origina la secuencia
		bne .Lfound_combH           @; si hay comibinacion, saltamos 
		add r2, #1               	@; si no hay en la primera celda, probamos la otra intercambiada

		bl detecta_orientacion 		 
		cmp r0, #NO_COMB_VALID 
		movne r12, r4 				
		movne r4, #1 				@; DERECHA - comprobamos la segunda celda si es la que produce la secuencia 
		bne .Lfound_combH           @; si hay comibinacion, saltamos 
		sub r2, #1               	@; recuperamos valor original
	
		@; deshacemos el intercambio y restauramos los valores
		strb r10, [r4, r9] 		 
		strb r11, [r4, r5] 

	.LnextH: 						@; VERTICAL
		
		cmp r1, #ROWS-1				@; comprobamos si estamos en la ultima fila 
		beq .Lnext_posH				@; si es asi, entonces no hay vecino abajo. Saltamos a la siguente posicion 

		add r5, r9, r7	   			@; r5 es un indice de la celda inferior (posicion actual + COLUMNS) 
		ldrb r11, [r4, r5]      	@; cargamos la celda inferior
		
		and r6, r11, #MASC       	@; obtenemos 3 bits menos significativos de un elemento 
		cmp r6, #BUID           	@; comprobamos si esta vacio  
		beq .Lnext_posH           	@; si es asi, saltamos a la siguente posicion 
		cmp r6, #MASC           	@; comprobamos si es el bloque solido 
		beq .Lnext_posH           	@; si es asi, saltamos a la siguiente posicion 
		cmp r3, r6               	@; comprobamos si los dos elementos(actual y vecina) son iguales 
		beq .Lnext_posH	         		@; si es asi, esto no creará secuencia nueva en la hora intercambiarlos. Saltamos 
		
		@; hacemos un intercambio de las posiciones
		strb r10, [r4, r5]       	 
		strb r11, [r4, r9]  
		
		bl detecta_orientacion 		
		cmp r0, #NO_COMB_VALID 
		movne r12, r4 				@; Si detecta_orientacion devuelve !=6, entonces hay secuencia
									@; movne (only-if-not-equal) copia r4 (base matriz) a r12
									@; asi preparamos r12 como un puntero base para restaurar el swap mas tarde 
		movne r4, #2 				@; ARRIBA - r4 = 2 -> indica que es la celda que originó la secuencia es la superior
		bne .Lfound_combH           @; si hay comibinacion, saltamos 
		add r1, #1               	@; si no hay en la primera celda, probamos la otra intercambiada

		bl detecta_orientacion 		 
		cmp r0, #NO_COMB_VALID 
		movne r12, r4 				
		movne r4, #3 				@; ABAJO - r4 = 2 -> indica que es la celda que originó la secuencia es la inferior 
		bne .Lfound_combH          	@; si hay comibinacion, saltamos 
		sub r1, #1               	@; recuperamos valor original
	
		@; deshacemos el intercambio y restauramos los valores
		strb r10, [r4, r9] 		 
		strb r11, [r4, r5] 

	.Lnext_posH:  
		
		add r2, #1 					@; avanzamos a la siguiente columna
		cmp r2, r7 					@; si r2 < COLUMNS, repetimos el bucle de columnas
		blt .Lfor_ColumnsH 	 

		mov r2, #0					@; si se hab terminado las columnas, reiniciamos r2
		add r1, #1              	@; si se han terminado las columnas, avanzamos a la siguiente fila 
		cmp r1, #ROWS 				@; si r1 < ROWS, repetimos el bucle de filas
		blt .Lfor_RowsH     

		mov r1, #0              	@; devolvemos 0, si no se ha encontrado ningina combinacion 
		b .Lfor_RowsH 				@; volvemos a buclear, cuando llegamos al final de la matriz orta y otra vez haciendo la busqueda

	.Lfound_combH:  
		
		@; VECTOR POSICION
		@; aseguramos que la matriz se queda en el estado original 
		strb r10, [r12, r9] 		@; el valor actual <- en la posición derecha
		strb r11, [r12, r5]			@; el valor del vecino <- en la posición actual

		mov r3, r0 					@; r3 -> valor devuelto por detecta_orientacion 
		mov r0, r8 					@; r0 = puntero psug 
		bl genera_posiciones 		
		mov r1, r8 					@; restauracion local

		pop {r0-r12, pc}




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

		push {r5-r6, lr} 

		mov r5, r1 					@; r5 = fila 	
		mov r6, r2 					@; r6 = columna 

		cmp r4, #0 
		beq .LcaseLeft 			@; Si r4 == 0 -> interpretamos que el intercambio originado fue "izquierda" 
		
		cmp r4, #1 
		beq .LcaseRight 			@; Si r4 == 1 -> derecha
 
		cmp r4, #2 
		beq .LcaseUp 				@; Si r4 == 2 -> arriba 
		
		cmp r4, #3 
		beq .LcaseDown 			@; Si r4 == 3 -> abajo 
		
	.LcaseLeft: 

		add r6, #1 					@; Si el caso es 'left' (significa que la celda de la izquierda es la que debemos desplazar), 
									@; incrementamos la columna del segundo punto (ajuste interno). 
		b .LcaseEnd 

	.LcaseRight: 

		sub r6, #1 					@; Ajuste correspondiente para 'right': la otra celda estará a la izquierda relative
		b .LcaseEnd

	.LcaseUp: 

		add r5, #1 					@; Ajuste para 'up': la otra celda implicada en el par está en fila+1 
		b .LcaseEnd

	.LcaseDown: 

		sub r5, #1 					@; Ajuste para 'down': la otra celda implicada está en fila-1 
		
	.LcaseEnd: 

		strb r6, [r0] 				@; Escribe en psug[0] la columna del primer punto  
		strb r5, [r0, #1] 			@; Escribe en psug[1] la fila del primer punto  
									@; Observación: el formato psug parece ser (col1, row1, col2, row2, col3, row3)
		mov r5, r1 					@; Restauramos r5 = fila original (para las siguientes operaciones) 
		mov r6, r2 					@; Restauramos r6 = columna original
		
		cmp r3, #0 
		beq .Leste 					@; Si orientación = 0 -> Este (horizontal hacia derecha) 
		
		cmp r3, #1 
		beq .Lsur 					@; Si orientación = 1 -> Sur (vertical hacia abajo) 
		
		cmp r3, #2 
		beq .Loeste 				@; 2 -> Oeste 
		
		cmp r3, #3 
		beq .Lnord 					@; 3 -> Norte 

		cmp r3, #4 
		beq .LgenHor 					@; 4 -> Horizontal (caso especial: secuencia horizontal con centro) 

		cmp r3, #5 
		beq .LgenVert 					@; 5 -> Vertical (caso especial: secuencia vertical con centro) 

	.Leste: 

		add r6, #1 					@; Segunda posición: col+1, row 
		strb r6, [r0, #2] 			@; psug[2] = col2 
		strb r5, [r0, #3] 			@; psug[3] = row2 

		add r6, #1 					@; Tercera: col+2, row 
		strb r6, [r0, #4] 			@; psug[4] = col3 
		strb r5, [r0, #5] 			@; psug[5] = row3 
		b .LendGen 

	.Lsur: 

		add r5, #1 					@; Segunda: col, row+1 
		strb r6, [r0, #2] 
		strb r5, [r0, #3] 

		add r5, #1 					@; Tercera: col, row+2 
		strb r6, [r0, #4] 
		strb r5, [r0, #5] 
		b .LendGen

	.Loeste: 

		sub r6, #1 					@; Segunda: col-1, row 
		strb r6, [r0, #2] 
		strb r5, [r0, #3] 

		sub r6, #1 					@; Tercera: col-2, row 
		strb r6, [r0, #4] 
		strb r5, [r0, #5] 
		b .LendGen

	.Lnord: 

		sub r5, #1 					@; Segunda: col, row-1 
		strb r6, [r0, #2] 
		strb r5, [r0, #3]
		
		sub r5, #1 					@; Tercera: col, row-2 
		strb r6, [r0, #4] 
		strb r5, [r0, #5] 
		b .LendGen

	.LgenHor: 

		add r6, #1 					@; Caso "hor" (horizontal donde el intercambio genera un triple centrado en la casilla): 
		strb r6, [r0, #2] 			@; col+1, row 
		strb r5, [r0, #3] 

		sub r6, #2 					@; col-1, row -> segunda casilla a la izquierda 
		strb r6, [r0, #4] 
		strb r5, [r0, #5] 
		b .LendGen 

	.LgenVert: 

		add r5, #1 					@; Caso "vert" (vertical centrado): 
		strb r6, [r0, #2] 			@; col, row+1 
		strb r5, [r0, #3] 

		sub r5, #2 					@; col, row-1 
		strb r6, [r0, #4] 
		strb r5, [r0, #5]
 
	.LendGen: 

		pop {r5-r6, pc} 



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
		beq .Ldetori_cont			@;no hay inicio de secuencia
		cmp r0, #3
		bhs .Ldetori_fin			@;hay inicio de secuencia
		add r3, #2
		and r3, #3					@;R3 = salta dos orientaciones (módulo 4)
		mov r0, r4
		bl cuenta_repeticiones
		add r3, #2
		and r3, #3					@;restituye orientación (módulo 4)
		cmp r0, #1
		beq .Ldetori_cont			@;no hay continuación de secuencia
		tst r3, #1
		moveq r3, #4				@;detección secuencia horizontal
		beq .Ldetori_fin
	.Ldetori_vert:
		mov r3, #5					@;detección secuencia vertical
		b .Ldetori_fin
	.Ldetori_cont:
		add r3, #1
		and r3, #3					@;R3 = siguiente orientación (módulo 4)
		add r5, #1
		cmp r5, #4
		blo .Ldetori_for			@;repetir 4 veces
		
		mov r3, #6					@;marca de no encontrada
		
	.Ldetori_fin:
		mov r0, r3					@;devuelve orientación o marca de no encontrada
		
		pop {r3, r5, pc}



.end
