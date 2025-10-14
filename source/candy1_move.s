@;=                                                         	      	=
@;=== candy1_move: rutinas para contar repeticiones y bajar elementos ===
@;=                                                          			=
@;=== Programador tarea 1E:ernestode.vicente-tutor@estudiants.urv.cat ===
@;=== Programador tarea 1F:ernestode.vicente-tutor@estudiants.urv.cat ===
@;=                                                         	      	=



.include "candy1_incl.i"



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1E;
@; cuenta_repeticiones(*matriz, f, c, ori): rutina para contar el número de
@;	repeticiones del elemento situado en la posición (f,c) de la matriz, 
@;	visitando las siguientes posiciones según indique el parámetro de
@;	orientación ori.
@;	Restricciones:
@;		* solo se tendrán en cuenta los 3 bits de menor peso de los códigos
@;			almacenados en las posiciones de la matriz, de modo que se ignorarán
@;			las marcas de gelatina (+8, +16)
@;		* la primera posición también se tiene en cuenta, de modo que el número
@;			mínimo de repeticiones será 1, es decir, el propio elemento de la
@;			posición inicial
@;	Parámetros:
@;		R0 = dirección base de la matriz
@;		R1 = fila f
@;		R2 = columna c
@;		R3 = orientación ori (0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte)
@;	Resultado:
@;		R0 = número de repeticiones detectadas (mínimo 1)
	.global cuenta_repeticiones
cuenta_repeticiones:
		MÀSCARES:

		EST = 0x00
		SUD = 0x01
		OEST = 0x02
		NORD = 0x03
		ULTIMS_BITS = 0x07
		FORAT = 0XF
		
	.global cuenta_repeticiones
cuenta_repeticiones:
		    push    {r1-r8, lr}          
	
    mov     r7, #COLUMNS           @; Assignem a r7 el valor que representa el nombre de columnes de la matriu.
    mla     r6, r1, r7, r2         @; Multipliquem posY (r1) per COLUMNS (r7) i li sumem posX (r2), resultat guardat a r6.
    add     r4, r0, r6             @; r4 apunta a l'element (fila, columna) de la matriu, utilitzant r0 com a base.
    ldrb    r5, [r4]               @; Carreguem en r5 el valor de la posició inicial de la matriu.
    and     r5, #ULTIMS_BITS       @; Apliquem una màscara per obtenir només els últims 3 bits del valor.
    mov     r8, r0                 @; Guardem la direcció base de la matriu a r8.
    mov     r0, #1                 @; Inicialitzem el comptador de repeticions en 1.

    cmp     r3, #EST               @; Comprovem la direcció (0 = Est, 1 = Sud, 2 = Oest, 3 = Nord).
    beq     .Lconrep_este          @; Si la direcció és 0 (Est), saltem a la rutina de repetició cap a l'est.
    cmp     r3, #SUD
    beq     .Lconrep_sur           @; Si la direcció és 1 (Sud), saltem a la rutina cap al sud.
    cmp     r3, #OEST
    beq     .Lconrep_oeste         @; Si la direcció és 2 (Oest), saltem a la rutina cap a l'oest.
    cmp     r3, #NORD
    beq     .Lconrep_norte         @; Si la direcció és 3 (Nord), saltem a la rutina cap al nord.

    b       .Lconrep_fin           @; Si la direcció no és vàlida, saltem directament al final.

.Lconrep_este:
.Lconrep_este_Loop:
    add     r2, r2, #1             @; Incrementem l'índex de la columna per moure'ns cap a la dreta.
    cmp     r2, #COLUMNS           @; Comprovem si hem arribat al límit de les columnes.
    bge     .Lconrep_fin           @; Si hem passat el límit, sortim de la rutina.

    mla     r6, r1, r7, r2         @; Calcula la nova posició dins de la matriu.
    add     r4, r8, r6             @; Actualitzem r4 amb la nova direcció a la matriu.
    ldrb    r6, [r4]               @; Carreguem el valor de la nova posició a r6.
    and     r6, #ULTIMS_BITS       @; Apliquem la màscara als últims 3 bits.

    cmp     r5, r6                 @; Compara el valor actual amb el valor original enmascarat.
    bne     .Lconrep_fin           @; Si són diferents, sortim de la rutina.
    add     r0, r0, #1             @; Incrementem el comptador de repeticions.
    b       .Lconrep_este_Loop     @; Tornem al bucle per continuar cap a la dreta.

.Lconrep_oeste:
.Lconrep_oeste_Loop:
    sub     r2, r2, #1             @; Decrementem l'índex de la columna per moure'ns cap a l'esquerra.
    cmp     r2, #0                 @; Comprovem si hem arribat al límit inferior de les columnes.
    blt     .Lconrep_fin           @; Si hem superat el límit, sortim de la rutina.

    mla     r6, r1, r7, r2         @; Calcula la nova posició dins de la matriu.
    add     r4, r8, r6             @; Actualitzem r4 amb la nova direcció a la matriu.
    ldrb    r6, [r4]               @; Carreguem el valor de la nova posició a r6.
    and     r6, #ULTIMS_BITS       @; Apliquem la màscara als últims 3 bits.

    cmp     r5, r6                 @; Compara el valor actual amb el valor original enmascarat.
    bne     .Lconrep_fin           @; Si són diferents, sortim de la rutina.
    add     r0, r0, #1             @; Incrementem el comptador de repeticions.
    b       .Lconrep_oeste_Loop    @; Tornem al bucle per continuar cap a l'esquerra.

.Lconrep_sur:
.Lconrep_sur_Loop:
    add     r1, r1, #1             @; Incrementem la posició Y per moure'ns cap avall.
    cmp     r1, #ROWS              @; Comprovem si hem arribat al límit de les files.
    bge     .Lconrep_fin           @; Si hem passat el límit, sortim de la rutina.

    mla     r6, r1, r7, r2         @; Calcula la nova posició dins de la matriu.
    add     r4, r8, r6             @; Actualitzem r4 amb la nova direcció a la matriu.
    ldrb    r6, [r4]               @; Carreguem el valor de la nova posició a r6.
    and     r6, #ULTIMS_BITS       @; Apliquem la màscara als últims 3 bits.

    cmp     r5, r6                 @; Compara el valor actual amb el valor original enmascarat.
    bne     .Lconrep_fin           @; Si són diferents, sortim de la rutina.
    add     r0, r0, #1             @; Incrementem el comptador de repeticions.
    b       .Lconrep_sur_Loop      @; Tornem al bucle per continuar cap avall.

.Lconrep_norte:
.Lconrep_norte_Loop:
    sub     r1, r1, #1             @; Decrementem la posició Y per moure'ns cap amunt.
    cmp     r1, #0                 @; Comprovem si hem arribat al límit inferior de les files.
    blt     .Lconrep_fin           @; Si hem superat el límit, sortim de la rutina.

    mla     r6, r1, r7, r2         @; Calcula la nova posició dins de la matriu.
    add     r4, r8, r6             @; Actualitzem r4 amb la nova direcció a la matriu.
    ldrb    r6, [r4]               @; Carreguem el valor de la nova posició a r6.
    and     r6, #ULTIMS_BITS       @; Apliquem la màscara als últims 3 bits.

    cmp     r5, r6                 @; Compara el valor actual amb el valor original enmascarat.
    bne     .Lconrep_fin           @; Si són diferents, sortim de la rutina.
    add     r0, r0, #1             @; Incrementem el comptador de repeticions.
    b       .Lconrep_norte_Loop    @; Tornem al bucle per continuar cap amunt.

.Lconrep_fin:
    pop     {r1-r8, pc}    

@;TAREA 1F;
@; baja_elementos(*matriz): rutina para bajar elementos hacia las posiciones
@;	vacías, primero en vertical y después en diagonal; cada llamada a la función
@;	baja múltiples elementos una posición y devuelve cierto (1) si se ha
@;	realizado algún movimiento, o falso (0) si no se ha movido ningún elemento.
@;	Restricciones:
@;		* para las casillas vacías de la primera fila se generarán nuevos
@;			elementos, invocando la rutina mod_random() (ver fichero
@;			'candy1_init.s')
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica se ha realizado algún movimiento, de modo que pueden
@;				quedar movimientos pendientes; 0 indica que no ha movido nada 
	.global baja_elementos
baja_elementos:
		push {r4,lr}
		mov r4, r0
		bl baja_verticales
		cmp r0, #1
		blne baja_laterales
		pop {r4,pc}



@;:::RUTINAS DE SOPORTE:::

@; baja_verticales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en vertical; cada llamada a la función sólo baja elementos una posición y
@;	devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento. 
baja_verticales:
	push {r1-r9,lr}
		mov r9, #0			@; r9 = false
		mov r1, #ROWS-1		@; r1 = i = ROWS-1
		mov r2, #COLUMNS-1 	@; r2 = j = COLUMNS-1
		mov r3, #COLUMNS	@; r3 = const
		
		@; Recorrido de la matriz sin la primera fila buscando los valores 0
		.LBucleFiles:
		@; while (i>0)
		cmp r1, #0
		ble .LFiBucleFiles
		mov r2, #COLUMNS-1
		.LBucleColumnes:
		@; while (j>=0)
		cmp r2, #0
		blt .LFiBucleColumnes
		@; r5 = matriz[i][j]
		mla r6, r1, r3, r2
		ldrb r5, [r4, r6]
		.LSiZero:
		@; if (valorFiltrado == 0)
		tst r5, #ULTIMS_BITS
		bne .LFiSiZero
		@; r8 = valorSup = matriz[i-1][j]
		sub r8, r6, #COLUMNS
		ldrb r7, [r4, r8]
		
		@; r0 = iTemp
		mov r0, r1
		@; Pasar por los huecos superiores
		.LBucleForat:
		@; while (iTemp>0 && valorSup==hueco)
		cmp r0, #0
		ble .LFiBucleForat
		cmp r7, #FORAT
		bne .LFiBucleForat
		@; Obtengo el siguiente valor superior
		sub r8, #COLUMNS
		ldrb r7, [r4, r8]
		@; iTemp--
		sub r0, #1
		b .LBucleForat
		.LFiBucleForat:
		
		@; Si hay un elemento superior válido, entonces hay una bajada vertical
		.LSiElementValid:
		@; if (es_elemento_basico(valorSup))
		and r0, r7, #ULTIMS_BITS
		cmp r0, #0      @; ¿es 0?
		beq .LFiSiElementValid
		cmp r0, #7      @; ¿es 7?
		beq .LFiSiElementValid
		@; Bajo el elemento
		and r0, r7, #ULTIMS_BITS
		bic r7, #ULTIMS_BITS
		add r5, r0
		strb r5, [r4, r6]
		strb r7, [r4, r8]
		
		@; Ya que ha habido una bajada vertical r11 = true
		mov r9, #1
		.LFiSiElementValid:
		.LFiSiZero:
		sub r2, #1
		b .LBucleColumnes
		.LFiBucleColumnes:
		
		sub r1, #1
		b .LBucleFiles
		.LFiBucleFiles:
		
		bl genera_elements
		orr r0, r9
	pop {r1-r9,pc}




@; baja_laterales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en diagonal; cada llamada a la función sólo baja elementos una posición y
@;	devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento. 
baja_laterales:
	push {r1-r9,lr}
		mov r9, #0			@; r9 = valor de retorno, por defecto es falso
		mov r2, #ROWS-1		@; r2 = i = ROWS-1
		
		.LBucleFiles3:
		@; while (i>0)
		cmp r2, #0
		ble .LFiBucleFiles3
		@; r3 = j = COLUMNS-1
		mov r3, #COLUMNS-1
		.LBucleColumnes3:
		@; while (j>=0)
		cmp r3, #0
		blt .LFiBucleColumnes3
		@; r5 = matriz[i][j], r6 = *matriz[i][j]
		mov r6, #COLUMNS
		mla r6, r2, r6, r3
		ldrb r5, [r4, r6]
		.LSiZero3:
		@; if (matriz[i][j] == 0)
		tst r5, #ULTIMS_BITS
		bne .LFiSiZero3
		
		@; r0 = booleano indicando si el valor izquierdo es valido
		@; r1 = booleano indicando si el valor derecho es valido
		mov r0, #0
		mov r1, #0
		.LSiEsquerraEsValid:
		@; r1 = !limDerecho 
		cmp r3, #COLUMNS-1
		bge .LSiDretaEsValid
		sub r8, r6, #COLUMNS-1
		ldrb r7, [r4, r8]
		and r0, r7, #ULTIMS_BITS
		cmp r0, #0
		beq .LNoEsBasico
		cmp r0, #7
		beq .LNoEsBasico
		mov r1, #1
		b .LSigue
		.LNoEsBasico:
		mov r1, #0
		.LSigue:
		.LSiDretaEsValid:
		@; r0 = !limIzquierdo 
		cmp r3, #0
		ble .LFiEsValid
		sub r8, r6, #COLUMNS+1
		ldrb r7, [r4, r8]
		and r0, r7, #ULTIMS_BITS       @ r0 = r7 & 7
        cmp r0, #0
        beq .LEsquerraNoBasic
        cmp r0, #7
        beq .LEsquerraNoBasic
        mov r0, #1
        b .Lesquerrafet
		.LEsquerraNoBasic:
        mov r0, #0
		.Lesquerrafet:

		.LFiEsValid:
		
		tst r0, r1
		bne .LElsdosValids
		cmp r0, #1
		beq .LEsquerraValid
		cmp r1, #1
		beq .LDretaValid
		b .LNoValids
		
		.LElsdosValids:
		mov r0, #2
		bl mod_random
		cmp r0, #0
		subeq r8, r6, #COLUMNS+1	@; si r0 = 0 -> r8 = *valorIzquierdo
		subne r8, r6, #COLUMNS-1	@; si r0 != 0 -> r8 = *valorDerecho
		b .LFiValids
		.LEsquerraValid:
		sub r8, r6, #COLUMNS+1	@; r8 = *valorIzquierdo
		b .LFiValids
		.LDretaValid:
		sub r8, r6, #COLUMNS-1	@; r8 = *valorDerecho
		b .LFiValids
		.LFiValids:
		@; r7 = elemento seleccionado (Izquierdo o derecho)
		ldrb r7, [r4, r8]
		@; Bajo el elemento
		and r1, r7, #ULTIMS_BITS
		bic r7, #ULTIMS_BITS
		add r5, r1
		strb r5, [r4, r6]
		strb r7, [r4, r8]
		@; Exito, ha habido bajada
		mov r9, #1
		.LNoValids:
		
		.LFiSiZero3:
		sub r3, #1
		b .LBucleColumnes3
		.LFiBucleColumnes3:
		sub r2, #1
		b .LBucleFiles3
		.LFiBucleFiles3:
		
		mov r0, r9
	pop {r1-r9,pc}

@; genera_elements(mat): rutina para generar aleatoriamente el valor de los
@;	elementos de las posiciones más altas de cada columna, sin tener en cuenta
@;	los huecos, siempre y cuando sea un elemento vacío
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica si ha generado algún valor. 
genera_elements:
	push {r1-r6,lr}
		mov r6, #0
		mov r1, #0
		mov r2, #0
		.LBucleColumnesGeneraElements:
		@; while (r2<COLUMNS-1)
		cmp r2, #COLUMNS
		bge .LFiBucleColumnesGeneraElements
		@; No tengo en cuenta los huecos
		mov r0, r4              @; r0 = dirección inicial (primer elemento de la columna)
        mov r1, #ROWS           @; número de filas a recorrer
.LSaltaragujeros:
        cmp r1, #0
        beq .LFinSalto
        ldrb r3, [r0]
        cmp r3, #FORAT            @; ¿es hueco ?
        bne .LFinSalto          @; si no es hueco, parar
        add r0, #COLUMNS        @; avanzar una fila hacia abajo
        sub r1, #1
        b .LSaltaragujeros
.LFinSalto:
        mov r5, r0
        ldrb r3, [r5]
		
		@; Si es un elemento vacío lo cambio por un numero aleatorio
		.LSiElementBuit:
		tst r3, #ULTIMS_BITS
		bne .LFiSiElementBuit
		@; Generar elemento random
		mov r0, #6
		bl mod_random
		add r0, #1
		@; Añado el elemento a la casilla, como es 0 solo tengo que sumarlo
		add r3, r0
		strb r3, [r5]
		@; Generado con exito
		mov r6, #1
		.LFiSiElementBuit:
		
		add r4, #1
		add r2, #1
		b .LBucleColumnesGeneraElements
		.LFiBucleColumnesGeneraElements:
		mov r0, r6
		
	pop {r1-r6,pc}

.end
