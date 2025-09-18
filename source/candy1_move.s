@;=                                                         	      	=
@;=== candy1_move: rutinas para contar repeticiones y bajar elementos ===
@;=                                                          			=
@;=== Programador tarea 1E: xxx.xxx@estudiants.urv.cat				  ===
@;=== Programador tarea 1F: yyy.yyy@estudiants.urv.cat				  ===
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
		push {lr}
		
		
		pop {pc}



@;:::RUTINAS DE SOPORTE:::



@; baja_verticales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en vertical; cada llamada a la función baja múltiples elementos una posición
@;	y devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento; 0 indica que no ha
@;				movido nada  
baja_verticales:
		push {lr}
		
		
		pop {pc}


@; baja_laterales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en diagonal; cada llamada a la función baja múltiples elementos una posición
@;	y devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento; 0 indica que no ha
@;				movido nada 
baja_laterales:
		push {lr}
		
		
		pop {pc}


.end
