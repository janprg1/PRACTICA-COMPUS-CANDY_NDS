@;=                                                        				=
@;=== candy1_conf.s: variables globales de configuración del juego    ===
@;=                                                       	        	=
@;=== Analista-programador: santiago.romani@urv.cat				  	  ===
@;=                                                       	        	=


@;-- .data. variables (globales) inicializadas ---
.data


@; límites de movimientos para cada nivel;
@;	los límites corresponderán a los niveles 0, 1, 2, ..., hasta MAXLEVEL-1
@;						(MAXLEVEL está definida en 'include/candy1_incl.h')
@;	cada límite debe ser un número entre 3 y 99.
		.global max_mov
	max_mov:	.byte 20, 27, 31, 45, 52, 32, 21, 90, 50 


@; objetivo de puntos para cada nivel;
@;	si el objetivo es cero, se supone que existe otro reto para superar el
@;	nivel, por ejemplo, romper todas las gelatinas.
@;	el objetivo de puntos debe ser un número menor que cero, que se irá
@;	incrementando a medida que se rompan elementos.
		.align 1
		.global pun_obj
	pun_obj:	.hword -1000, -830, -500, 0, -240, -500, -200, -900, 0



@; mapas de configuración de la matriz;
@;	cada mapa debe contener tantos números como posiciones tiene la matriz,
@;	con el siguiente significado para cada posicion:
@;		0:		posición vacía (a rellenar con valor aleatorio)
@;		1-6:	elemento concreto
@;		7:		bloque sólido (irrompible)
@;		8+:		gelatina simple (a sumarle código de elemento)
@;		16+:	gelatina doble (a sumarle código de elemento)
		.global mapas
	mapas:

	@; mapa 0: no hay combinacion
        .byte 1,2,22,13,10,9,6,7,21
        .byte 13,11,20,17,4,2,5,2,1
        .byte 9,7,7,7,7,7,19,12,11
        .byte 12,7,9,2,1,10,17,13,20
        .byte 14,7,4,19,22,7,7,7,7
        .byte 21,7,18,5,2,11,22,13,7
        .byte 19,12,21,6,20,9,11,18,7
        .byte 1,6,7,7,7,7,13,6,7
        .byte 2,11,17,5,2,12,3,17,7
		
	@; mapa 1: hay combinacion
		.byte 1,2,1,3,2,4,20,6,5
		.byte 17,9,4,7,15,2,9,3,1
		.byte 21,1,10,18,5,11,19,20,22
		.byte 3,10,21,13,1,2,9,7,6
		.byte 2,19,15,3,15,17,21,2,20
		.byte 6,10,4,7,14,1,19,5,9
		.byte 19,13,3,15,10,7,20,4,1
		.byte 2,14,4,10,19,6,11,12,5
		.byte 21,17,2,1,3,15,7,1,4
		
	@; mapa 2: 7 frena posible combinacion
		
		.byte 1,2,13,4,9,22,6,7,10
		.byte 2,15,20,15,5,11,1,13,19
		.byte 5,12,14,3,15,6,7,19,15
		.byte 6,13,7,17,9,10,4,5,20
		.byte 7,7,7,7,7,7,7,7,7
		.byte 7,1,19,22,7,9,2,15,13
		.byte 1,15,21,6,5,12,18,9,22
		.byte 1,2,5,3,4,1,3,21,5
		.byte 11,18,9,12,2,13,6,5,4

	@; mapa 3: 15 frena posible combinacion
	
		.byte 1,1,15,2,9,19,22,10,7
		.byte 4,15,1,5,11,12,14,1,15  
		.byte 6,9,18,3,13,10,21,2,11
		.byte 5,12,4,15,2,9,19,17,15
		.byte 18,3,14,11,6,4,20,15,1
		.byte 22,20,17,19,3,15,12,5,6
		.byte 1,10,21,4,2,15,9,13,20
		.byte 19,6,11,14,5,3,18,22,2
		.byte 11,2,9,12,1,20,15,4,6



	@; mapa 4: multiples combinaciones con gelatinas
		.byte 1,2,3,12,13,14,15,1,22
		.byte 7,12,20,21,19,18,14,15,17
		.byte 5,6,12,13,22,21,20,10,11
		.byte 10,19,15,18,12,14,17,3,22
		.byte 7,12,14,21,20,19,11,18,15
		.byte 4,22,12,10,17,13,14,19,12
		.byte 9,15,5,22,20,14,12,21,18
		.byte 12,17,11,13,21,19,20,15,2
		.byte 6,22,18,12,14,15,13,19,11

	@; mapa 5: secuencias en horizontal de 3, 4 y 5 elementos
		.byte 1,1,1,15,2,2,2,2,7
		.byte 3,3,3,3,3,15,7,7,15
		.byte 4,1,4,4,4,4,15,7,15
		.byte 1,4,4,2,6,3,7,0,15
		.byte 5,2,2,15,5,5,5,5,5
		.byte 6,5,5,2,5,6,6,6,15
		.byte 15,7,6,6,6,7,7,7,7
		.byte 7,7,7,15,7,7,7,15,15
		.byte 15,15,7,15,15,15,7,15,15

	@; mapa 6: secuencias en vertical de 3, 4 y 5 elementos
		.byte 1,3,4,1,5,6,2,15,15
		.byte 1,3,1,4,2,5,7,15,15
		.byte 1,3,4,4,2,5,15,7,15
		.byte 2,3,4,2,6,15,2,7,15
		.byte 2,3,4,15,6,6,5,7,15
		.byte 2,7,4,3,5,15,6,7,15
		.byte 2,7,15,6,6,5,6,7,7
		.byte 7,15,15,7,7,5,6,7,15
		.byte 15,15,7,15,15,5,7,15,15

	@; mapa 7: combinaciones cruzadas (hor/ver) de 5, 6 y 7 elementos
		.byte 15,15,7,15,15,7,15,15,15
		.byte 1,2,3,3,4,3,7,0,15
		.byte 1,2,7,5,3,7,7,0,15
		.byte 4,1,1,2,3,8,7,0,15
		.byte 1,4,4,2,6,3,7,0,15
		.byte 4,2,2,5,2,2,7,0,15
		.byte 4,5,5,2,5,5,7,0,15
		.byte 7,8,1,5,4,6,8,0,15
		.byte 8,8,8,8,8,8,8,0,15

	@; mapa 8: no hay combinaciones ni secuencias
		.byte 15,15,15,15,15,15,15,15,15
		.byte 15,15,15,15,15,15,15,15,15
		.byte 1,2,3,3,7,3,15,15,15
		.byte 1,2,7,5,3,7,15,15,15
		.byte 7,1,1,2,3,9,15,15,15
		.byte 1,4,20,10,9,6,15,15,15
		.byte 6,18,22,5,6,2,15,15,15
		.byte 12,5,4,3,11,5,15,15,15
		.byte 7,7,17,19,4,6,15,15,15



	@; etc.



.end
	
