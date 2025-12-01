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
    mov r0, #6                     @; Ajustar rang per a generar número
    bl mod_random
	add r0, r0, #1
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
@;		MÀSCARES:

		BITBAIX = 0x07
		BITS816 = 0x18
		
	.global recombina_elementos
recombina_elementos:

    push {r0-r12, lr}          

.Linici:

@; Inicialitzacio de variables 

    mov r1, #0				 @; Inicialitzar l'índex actual de la matriu a 0
	mov r12, r0              @; Guardar el valor original de r0 obtingut per parametre
	
	ldr r7, =mat_recomb1     @; Carregar l'adreça de la matriu de recombinació 1
    ldr r8, =mat_recomb2     @; Carregar l'adreça de la matriu de recombinació 2
	
    mov r2, #ROWS*COLUMNS    @; Carregar el nombre total de posicions de la matriu
	
.Lfor:
    cmp r1, r2				 @; Comprovar si s'ha recorregut tota la matriu
    bhs .Lendfor			 @; Saltar si s'ha completat
	
    ldrb r6, [r12, r1]		 @; Carregar el valor de la posició actual de la matriu de joc sino s'ha completat

    mov r11, #0				 @; Inicialitzem variable a 0 per a posterior us
	
    tst r6, #BITBAIX		 @; Comprobem si els 3 ultims bits de r6 es una posiciio buida (0)
    beq .Lguardar0			 @; Salta si els 3 bits son 0
    beq .Lendif1			 @; Ha comprbat que son 0 els valors per tant saltem a la seguent posicio
	
    mvn r5, r6				 @; Intercanviem els 3 ultims valor de r6 amb r5 (111) --> (000) per a pposterior us del streqb

    tst r5, #BITBAIX		 @; Comprobem si els 3 ultims bits intercanviats a r5, son un bloc solid (7)
    streqb r11, [r7, r1]	 @; Si son 0 guardem el valor r11(0) a mat_recomb1
    streqb r6, [r8, r1]		 @; Si son 0 guardem el valor de r6 a mat_recomb2
    beq .Lendif1    		 @; Ha comprbat que son 1 els valors per tant saltem a la seguent posicio
	
@; Gurdem 0 si els 3 ultims bits de r6 son 0

.Lguardar0:

	strb r11, [r7, r1]	 	 @; Si son 0 guardem el valor r11(0) a mat_recomb1
    strb r6, [r8, r1]		 @; Si son 0 guardem el valor de r6 a mat_recomb2
	
@; Guardem la base del element

    and r11, r6, #BITBAIX    @; Agafar el codi bàsic de l'element (els primers 3 bits = 1-6)
    strb r11, [r7, r1]		 @; Guardar el valor en la matriu de recombinació 1 a la posició actual
	
@; Guardar només la gelatina

    and r11, r6, #BITS816	 @; Agafar la gelatina simple o doble de l'element (bits 4 i 5 = 8 i 16) (0001 1000)
    strb r11, [r8, r1]		 @; Guardar el valor en la matriu de recombinació 2 a la posició actual  

.Lendif1:
    add r1, #1               @; Incrementar l'índex de la matriu
    b .Lfor                  @; Tornar al principi del bucle per a seguir comprovant posicions

.Lendfor:
    mov r1, #0               @; Quan totes posicions son revisades, inicialitzar l'índex de files (i = 0)

.Lfor3:
    cmp r1, #ROWS            @; Comprovar si s'han recorregut totes les files
    bhs .Lendfor3            @; Si hem acabat, sortir del bucle
    mov r2, #0               @; Inicialitzar l'índex de columnes (j = 0)

.Lfor4:
    cmp r2, #COLUMNS         @; Comprovar si s'han recorregut totes les columnes
    bhs .Lendfor4            @; Si hem acabat, sortir del bucle

@; Carreguem la matriu[i][j]
    mov r5, #COLUMNS		 @; Carreguem el numero de columnes maxim 
    mla r4, r1, r5, r2       @; Calcular la posició: r4 = (i*columns) --> Et poses a la fila que vols +j per desplaçarte dins la fila
    ldrb r6, [r12, r4]       @; Carregar el valor obtingut de la posició [i][j] de la matriu
	
@; Comprobem que el valor carregat no es una posicio vuida (0) ni un bloc solid (7)

    tst r6, #BITBAIX	     @; Comprobem si els 3 ultims bits de r6 es una posiciio buida (0)
    beq .Lendif2			 @; Ha comprbat que son 0 els valors per tant saltem a la seguent posicio
	
    mvn r11, r6				 @; Intercanviem els 3 ultims valor de r6 amb r11 ex:(000) --> (111)
	
    tst r11, #BITBAIX	     @; Comprobem si els 3 ultims bits intercanviat de r5 son un bloc solid (7)
    beq .Lendif2			 @; Ha comprbat que son 1 els valors per tant saltem a la seguent posicio
	
    mov r6, #0
    b .Lwhile1 
	
	
.Lhaysecuencia:

    strb r10, [r8, r4]       @; Guardar la recombinació en la matriu 2
    add r6, #1               
    cmp r6, #ROWS*COLUMNS    @; Comprovar si s'han recorregut totes les caselles
    bhs .Linici              
	
.Lwhile1:

    mov r0, #ROWS			 @; Carreguem el numero de files maxim	
    bl mod_random            @; Generar un valor aleatori 
    mov r9, r0               @; Guardar el valor aleatori a r9 

    mov r0, #COLUMNS         @; Carreguem el numero de columnes maxim
    bl mod_random            @; Generar un valor aleatori 
    mov r10, r0              @; Guardar el valor aleatori a r10 
    mov r0, r12              @; Restaurar l'adreça base de la matriu original

    mov r5, #COLUMNS         @; Carreguem el numero de columnes maxim
    mla r11, r9, r5, r10     @; r11 = (i*columns) --> Et poses a la fila que vols +j per desplaçarte dins la fila
    ldrb r9, [r7, r11]       @; Carregar el valor de mat_recomb1

@; Comprovar que mat_recomb1 no sigui 0

    cmp r9, #0               @; Comprovar si la posició és buida
    beq .Lwhile1             @; Si està buida, tornar a calcular 

@; Afegir mat_recomb1 a mat_recomb2 sumant els bits de gelatina

    ldrb r10, [r8, r4]       @; Carregar el valor de mat_recomb2[i][j]
    orr r5, r9, r10          @; R9--> Element basic , r10 --> gelatina o gelatina doble (junten bits i queda numero final)
    strb r5, [r8, r4]        @; Guardar el resultat a recomb2
	

@; Mirem si hi ha alguna repeticio amb la funcio cuenta repeticiones

@; Observem cap al Oest
    mov r3, #2               @; Parametre orientació Oest
    mov r0, r8               @; Parametre per passar la matriu recomb2
    bl cuenta_repeticiones   @; Cridem a la funcio
	
    cmp r0, #3               @; Comprovar si hi ha 3 o més repeticions
    bhs .Lhaysecuencia       @; Salt si hi ha sequencia
	mov r0, r12              @; Restaurar l'adreça base de la matriu original

@; Observem cap al Nord
    mov r3, #3               @; Parametre orientació Nord
    mov r0, r8               @; Passar la matriu recomb2
    bl cuenta_repeticiones   @; Cridem a la funcio
	
    cmp r0, #3               @; Comprovar si hi ha 3 o més repeticions
    bhs .Lhaysecuencia       @; Salta si hi ha sequencia
	mov r0, r12				 @; Retornem a r0 el valor de la matriu oringinal
	
    mov r5, #0
    strb r5, [r7, r11]       @; Posar a 0 el lloc de recomb1
	
.Lendif2:
    add r2, #1               @; Incrementar columna
    b .Lfor4                 @; Tornar a bucle de columnes

.Lendfor4:    
    add r1, #1               @; Incrementar fila
    b .Lfor3                 @; Tornar a bucle de files

.Lendfor3:    
@; Comprovar que hi ha combinacions a la nova matriu

    mov r0, r8               @; Parametre per passar la matriu recomb2
    bl hay_combinacion       @; Cridem a la funcio 
    cmp r0, #1               @; Comprovar si hi ha combinacions
	mov r0, r12				 @; Restaurar l'adreça base de la matriu original
    bne .Linici              @; Salta sino hi han combinacions
	

@; Guardar mat_recomb2 en la matriu de joc original

    mov r1, #0               @; Inicialitzar el comptador
    mov r2, #ROWS*COLUMNS    @; Establir el límit del bucle (posicions totals)
	
.Lfor5:
@; Bucle per a carregar i guardar els valors de met_recomb2 a la matriu original

    cmp r1, r2               @; Comprovar si hem recorregut tota la matriu
    bhs .Lendfor5            @; Salta ha recorregut tota la mtriu
    ldrb r10, [r8, r1]       @; Carregar el valor de mat_recomb2[i][j]
    strb r10, [r12, r1]      @; Guardar el valor a la matriu de joc original
    add r1, #1               @; Incrementem comptador
    b .Lfor5                 @; Tornar a bucle

.Lendfor5:

    pop {r0-r12, lr}



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
