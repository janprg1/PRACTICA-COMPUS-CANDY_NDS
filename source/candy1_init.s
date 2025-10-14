@;=                                                          	     	=
@;=== candy1_init.s: rutinas para inicializar la matriz de juego	  ===
@;=                                                           	    	=
@;=== Programador tarea 1A: xxx.xxx@estudiants.urv.cat				  ===
@;=== Programador tarea 1B: yyy.yyy@estudiants.urv.cat				  ===
@;=                                                       	        	=



.include "candy1_incl.i"



@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
@; matrices de recombinación: matrices de soporte para generar una nueva matriz
@;	de juego recombinando los elementos de la matriz original.
	mat_recomb1:	.space ROWS*COLUMNS
	mat_recomb2:	.space ROWS*COLUMNS



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1A;
@; inicializa_matriz(*matriz, num_mapa): rutina para inicializar la matriz de
@;	juego, primero cargando el mapa de configuración indicado por parámetro (a
@;	obtener de la variable global mapas[][][]) y después cargando las posiciones
@;	libres (valor 0) o las posiciones de gelatina (valores 8 o 16) con valores
@;	aleatorios entre 1 y 6 (+8 o +16, para gelatinas)
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocará la rutina
@;			mod_random()
@;		* para evitar generar secuencias se invocará la rutina
@;			cuenta_repeticiones() (ver fichero 'candy1_move.s')
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = número de mapa de configuración
@;		MÀSCARES:

		CASELLA_BUIDA = 0x00 @; 0
		EST = 0x00
		SUD = 0x01
		OEST = 0x02
		NORD = 0x03
		
	.global inicializa_matriz
inicializa_matriz:
		push {r0-r11, lr}              @; Guardar registres i LR

    ldr r11, =mapas                @; Adreça base de 'mapas'
    mov r9, #(ROWS*COLUMNS)        @; 81 elements per mapa
    mul r3, r1, r9                 @; Multiplicar l'índex del mapa (r1) per 81 per trobar posició del mapa corresponent
	add r11, r11, r3               @; Obtenir l'adreça del mapa corresponent usant r1 (num_mapa)

    mov r10, #0                    @; Índex de fila
    mov r4, #COLUMNS               @; Nombre de columnes
    mov r5, #ROWS                  @; Nombre de files
	mov r9, r0                     @; Punter a la matriu destí

bucle_files:
    cmp r10, r5                    @; Comprovar si hem acabat les files
    bhs fi

    mov r6, #0                     @; Índex de columna

bucle_columnes:
    cmp r6, r4                     @; Comprovar si hem acabat les columnes
    bhs seguent_fila

    @; Calcular l'offset dins de la matriu
    mul r7, r10, r4                @; Multiplicar la fila pel nombre de columnes 
	add r7, r7, r6                 @; Sumar la columna a l'índex (posició a la matriu)

    ldrb r8, [r11, r7]             @; Llegir valor del mapa en aquesta posició
	
    tst r8, #0x07                  @; Comprovar si els 3 últims bits = 0 (casella buida)
    beq generar_aleatori           @; Si està buida, generar un número

    strb r8, [r9, r7]              @; Copiar directament el valor a la matriu destí
    b seguent_casella

generar_aleatori:
    mov r0, #7                     @; Ajustar rang per a generar número
    bl mod_random
	cmp r0, #CASELLA_BUIDA         @; Comprovar si el número és 0 
	beq generar_aleatori
    orr r8, r8, r0                 @; Afegir possible màscara de gelatina
    strb r0, [r9, r7]              @; Guardar valor aleatori a la matriu destí

    @; Comprovació de repeticions (OEST)
    mov r0, r9
    mov r1, r10
    mov r2, r6
    mov r3, #OEST
    bl cuenta_repeticiones
    cmp r0, #3
    bhs generar_aleatori

    @; Comprovació de repeticions (NORD)
    mov r0, r9
    mov r1, r10
    mov r2, r6
    mov r3, #NORD
    bl cuenta_repeticiones
    cmp r0, #3
    bhs generar_aleatori

    b seguent_casella

seguent_casella:
    add r6, #1                     @; Avançar a la següent columna
    b bucle_columnes

seguent_fila:
    add r10, #1                    @; Avançar a la següent fila
    b bucle_files

fi:
    pop {r0-r11, pc}               @; Restaurar registres i tornar


@;TAREA 1B;
@; recombina_elementos(*matriz): rutina para generar una nueva matriz de juego
@;	mediante la reubicación de los elementos de la matriz original, para crear
@;	nuevas jugadas.
@;	Inicialmente se copiará la matriz original en mat_recomb1[][], para luego ir
@;	escogiendo elementos de forma aleatoria y colocándolos en mat_recomb2[][],
@;	conservando las marcas de gelatina.
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocará la rutina
@;			mod_random()
@;		* para evitar generar secuencias se invocará la rutina
@;			cuenta_repeticiones() (ver fichero 'candy1_move.s')
@;		* para determinar si existen combinaciones en la nueva matriz, se
@;			invocará la rutina hay_combinacion() (ver fichero 'candy1_comb.s')
@;		* se puede asumir que siempre existirá una recombinación sin secuencias
@;			y con posibles combinaciones
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
	.global recombina_elementos
recombina_elementos:
		push {lr}
		
		
		pop {pc}



@;:::RUTINAS DE SOPORTE:::



@; mod_random(n): rutina para obtener un número aleatorio entre 0 y n-1,
@;	utilizando la rutina random()
@;	Restricciones:
@;		* el parámetro n tiene que ser un natural entre 2 y 255, de otro modo,
@;		  la rutina lo ajustará automáticamente a estos valores mínimo y máximo
@;	Parámetros:
@;		R0 = el rango del número aleatorio (n)
@;	Resultado:
@;		R0 = el número aleatorio dentro del rango especificado (0..n-1)
	.global mod_random
mod_random:
		push {r2-r4, lr}
		
		cmp r0, #2				@;compara el rango de entrada con el mínimo
		movlo r0, #2			@;si menor, fija el rango mínimo
		cmp r0, #0xFF			@;compara el rango de entrada con el máximo
		movhi r0, #0xFF			@;si mayor, fija el rango máximo
		sub r2, r0, #1			@;R2 = R0-1 (número más alto permitido)
		mov r3, #1				@;R3 = máscara de bits
	.Lmodran_forbits:
		mov r3, r3, lsl #1
		orr r3, #1				@;inyecta otro bit
		cmp r3, r2				@;genera una máscara superior al rango requerido
		blo .Lmodran_forbits
		
	.Lmodran_loop:
		bl random				@;R0 = número aleatorio de 32 bits
		and r4, r0, r3			@;filtra los bits de menos peso según máscara
		cmp r4, r2				@;si resultado superior al permitido,
		bhi .Lmodran_loop		@; repite el proceso
		mov r0, r4
		
		pop {r2-r4, pc}




@; random(): rutina para obtener un número aleatorio de 32 bits, a partir de
@;	otro valor aleatorio almacenado en la variable global seed32 (declarada
@;	externamente)
@;	Restricciones:
@;		* el valor anterior de seed32 no puede ser 0
@;	Resultado:
@;		R0 = el nuevo valor aleatorio (también se almacena en seed32)
random:
	push {r1-r5, lr}
		
	ldr r0, =seed32				@;R0 = dirección de la variable seed32
	ldr r1, [r0]				@;R1 = valor actual de seed32
	ldr r2, =0x0019660D
	ldr r3, =0x3C6EF35F
	umull r4, r5, r1, r2
	add r4, r3					@;R5:R4 = nuevo valor aleatorio (64 bits)
	str r4, [r0]				@;guarda los 32 bits bajos en seed32
	mov r0, r5					@;devuelve los 32 bits altos como resultado
		
	pop {r1-r5, pc}	



.end
