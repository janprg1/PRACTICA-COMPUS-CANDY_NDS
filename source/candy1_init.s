@;=                                                          	     	=
@;=== candy1_init.s: rutinas para inicializar la matriz de juego	  ===
@;=                                                           	    	=
@;=== Programador tarea 1A: jan.bofarull@estudiants.urv.cat			  ===
@;=== Programador tarea 1B: jan.bofarull@estudiants.urv.cat			  ===
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

		CASELLA_BUIDA = 0x00 
		EST = 0x00
		SUD = 0x01
		OEST = 0x02
		NORD = 0x03
		
	.global inicializa_matriz
inicializa_matriz:
	push {r0-r11, lr}              

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
    mov r0, #6                     @; Ajustar rang per a generar número
    bl mod_random
	add r0, r0, #1				   @; Sumem 1 al valor resultant de mod random 
    orr r0, r8, r0                 @; Afegir possible màscara de gelatina
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
    pop {r0-r11, pc}               


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

	BIT5 = 0x20
	VALORS = 0x07
	GELATINES = 0x18
	
   .global recombina_elementos
recombina_elementos:

	push {r0-r12, lr}                            
	
	@;Cargamos direcciones de las matricecs necesarias y las columnas
	mov r6, #COLUMNS 
	@; R1 y R2 para filas y columnas, R3 para pasar parametro para funciones, siguiente libre r4,r5.
    ldr r4, =mat_recomb1                  
    ldr r5, =mat_recomb2               
    
.LInici:     
	mov r11, #0                           @; Contador de fallos para evitar error de matrices compejas
    mov r1, #0                            @; fila actual
    mov r2, #0                            @; columna actual
   
.LBucleFilas:                             @; Recorrido por filas (fase de inicialización)
    mov r2, #0                            @; Reinicio de columna al empezar una fila
   
.LBucleCols:                              @; Recorrido por columnas (fase de inicialización)
    mul r8, r1, r6	                      @; pos=fila*COLUMNS + columna
	add r8, r8, r2
    ldrb r9, [r0, r8]                     @; r6 = matriz_original[pos]
    
    and r7, r9, #VALORS                   @; r7 = valors (0-7)
    cmp r7, #7                            @; ¿bloque especial (sólido/hueco)?
    bne .LValor                           @; Si no es 7, tratar como valor normal
   
    mov r7, #0                            
    strb r7, [r4, r8]                     @; mat_recomb1[pos] = 0
    orr r9, r9, #BIT5                     @; Señaliza el valor con el bit 5 en alto
    strb r9, [r5, r8]                     @; mat_recomb2[pos] = valor marcado
    b .LAvanza                       	  @; Siguiente celda (salto local) 

.LValor:          
	@; Gestión de valores normales
    strb r7, [r4, r8]                     @; En el auxiliar 1 guardamos solo el “simple”
    cmp r7, #0                            @; elemento simple = 0?
	orreq r9, r9, #BIT5 
	streqb r9, [r5, r8]                   @; mat_recomb2[pos] = valor marcado
    
    and r7, r9, #GELATINES                @; Extraer “gelatina” (bits 3..4)
    strb r7, [r5, r8]                     @; mat_recomb2[pos] = solo gelatina 
    
.LAvanza:                                
    add r2, #1                            @; col++
    cmp r2, #COLUMNS                      @; ¿quedan columnas?
    blt .LBucleCols                       @; Sí -> seguir en la fila
    
    add r1, #1                            @; fila++
    cmp r1, #ROWS                         @; ¿quedan filas?
    blt .LBucleFilas                      @; Sí -> siguiente fila
    
    mov r12, r0                           @; Guardar puntero a la matriz original
	mov r1, #0                            @; Reinicio de fila para la fase de recombinación
    mov r2, #0                            @; Reinicio de col para recombinación
    
.LFilas2:                                 @; Bucle flias
    mov r2, #0                            @; Reset de columna al empezar fila
   
.LCols2:                                  @; Bucle columnas
    mla r8, r1, r6, r2                    @; r8 = índice lineal actual
    ldrb r9, [r5, r8]                     @; r6 = estado en mat_recomb2
    
    and r7, r9, #BIT5                     @; ¿bit 5 activo?
    cmp r7, #0
	andne r9, r9, #0x1F                   @; r6 &= 0x1F -> borra bit 5
	strneb r9, [r5, r8]                   @; Guardar valor sin marca
	bne .LAvanza2
  
.LAleatorio:                                  
    mov r0, #COLUMNS*ROWS                 @; Límite superior del índice aleatorio
    bl mod_random                        
    mov r10, r0                           @; r10 = índice de origen
    ldrb r7, [r4, r10]                    @; r7 = contenido del origen en auxiliar 1
    cmp r7, #0                            @; ¿origen vacío?
    beq .LAleatorio                       @; Reintentar si está vacío
  
    add r7, r9                            @; Combinar origen con destino
    strb r7, [r5, r8]                     @; Escribir en mat_recomb2 en el destino
    add r11, #1                           @; Incrementar intentos
    cmp r11, #120                         @; ¿demasiados intentos?
    beq .LInici                           @; Reiniciar el proceso si se atasca
    
	@; Comprobación de secuencias (oeste)
    mov r0, r5                            @; r0 = puntero matriz de trabajo
    mov r3, #2                            @; 2 = orientación oeste
    bl cuenta_repeticiones              
    cmp r0, #3                            @; ¿genera una secuencia mínima?
    bhs .LAleatorio                       @; Si sí, probar con otro origen
	
    @; Comprobación de secuencias (norte)
    mov r0, r5                            @; r0 = puntero matriz de trabajo
    mov r3, #3                            @; 3 = orientación norte
    bl cuenta_repeticiones               
    cmp r0, #3                            @; ¿genera una secuencia mínima?
    bhs .LAleatorio                       @; Si sí, probar con otro origen
	
    mov r3, #0                            @; r7 = 0 para borrar
    strb r3, [r4, r10]                    @; mat_recomb1[origen] = 0
    
.LAvanza2:                                @; Avance en la fase de recombinación
    add r2, #1                            @; col++
    cmp r2, #COLUMNS                      @; ¿quedan columnas?
    blt .LCols2                           @; Sí -> continuar
    
    add r1, #1                            @; fila++
    cmp r1, #ROWS                         @; ¿quedan filas?
    blt .LFilas2                          @; Sí -> siguiente fila
  
    @; Mat_recomb2 a mat_original
    mov r1, #0                            @; fila = 0 para el copiado
    mov r0, r12                           @; r0 = puntero a la matriz original (destino)
    
.LCpFilas:                                
    mov r2, #0                            @; col = 0 en cada fila
.LCpCols:                                 
    mla r8, r1, r6, r2                    @; índice lineal = fila*COLUMNS + col
    ldrb r4, [r5, r8]                     @; leer byte de mat_recomb2
    strb r4, [r0, r8]                     @; escribir byte en la matriz original

    add r2, #1                            @; col++
    cmp r2, #COLUMNS                      @; ¿quedan columnas por copiar?
    blt .LCpCols                          @; Sí -> siguiente columna
  
    add r1, #1                            @; fila++
    cmp r1, #ROWS                         @; ¿quedan filas por copiar?
    blt .LCpFilas                         @; Sí -> siguiente fila
   
    pop {r0-r12, pc}  



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
