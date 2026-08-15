<?php
// bin2b81.php - convierte un .bin (codigo maquina ensamblado con ORG=4082h,
// 16514 decimal) en un .b81 (listado BASIC en texto plano) cargable con el
// "Basic Loader" de EightyOne, que lo convierte a .p real.
//
// Genera:
//     1 REM \XX\XX\XX...(bytes del .bin, escape hex, byte a byte)
//     2 LET A=USR 16514
//     ...
//
// El escape \XX esta confirmado en IBasicLoader.cpp del emulador
// (ExtractEscapeCharacters, ConvertFromHexChars): escribe el byte crudo XX
// sin pasar por AsciiToZX ni por el tokenizador, asi que vale para
// cualquier valor 0x00-0xFF.
//
// Uso: php bin2b81.php entrada.bin salida.b81

define('USR_ADDRESS', 16514);   // 4082h

if ($argc != 3) {
    fwrite(STDERR, "Uso: php bin2b81.php entrada.bin salida.b81\n");
    exit(1);
}

$entrada = $argv[1];
$salida  = $argv[2];

$data = @file_get_contents($entrada);
if ($data === false) {
    fwrite(STDERR, "No se puede leer $entrada\n");
    exit(1);
}

// Escape hex byte a byte. strtoupper porque el cargador del emulador
// espera los dos digitos en mayusculas.
$escaped = '';
$n = strlen($data);
for ($i = 0; $i < $n; $i++) {
    $escaped .= sprintf('\\%02X', ord($data[$i]));
}

// El nombre de cinta sale del propio fichero de salida (10 caracteres como
// maximo, que es el limite del ZX81).
$nombre = strtoupper(pathinfo($salida, PATHINFO_FILENAME));
$nombre = substr($nombre, 0, 10);

// La linea 3 es la que graba de verdad. El condacto SAVE del juego no
// puede llamar a la SAVE de la ROM ($02F6): esa empieza con CALL $03A8
// (NAME), que evalua el nombre como expresion BASIC y necesita CH_ADD
// dentro de una linea de programa. Asi que SAVE vuelve a BASIC, la linea 3
// graba de $4009 a E_LINE -que incluye ENTERA nuestra linea 1 REM, o sea
// codigo, flags, objetos y DDB- y la 4 devuelve el control al juego.
//
// LET A=USR en vez de RAND USR: en el ZX81 USR devuelve BC, y el condacto
// SAVE deja ahi un contador de partidas. BASIC lo pega al nombre con STR$,
// asi que cada grabacion sale como NOMBRE1, NOMBRE2... y se pueden tener
// varias en la misma cinta.
//
// Y el 0 distingue las dos formas de volver a BASIC: SAVE incrementa el
// contador ANTES de volver, asi que siempre devuelve 1 o mas; el fin de
// partida (END/QUIT) devuelve 0 y la linea 3 para el programa.
//
// Al cargar la cinta, el ZX81 sigue por la linea siguiente al SAVE, o sea
// la 4, y el flag RESUMEF (grabado con todo lo demas) hace que ZX81START
// NO borre los flags: la partida continua donde estaba.
//
// Finales de linea CRLF, como los escribia la version en Python.
$listado  = "1 REM $escaped\r\n";
$listado .= "2 LET A=USR " . USR_ADDRESS . "\r\n";
$listado .= "3 IF A=0 THEN STOP\r\n";
$listado .= "4 SAVE \"$nombre\"+STR\$ A\r\n";
$listado .= "5 GOTO 2\r\n";

if (@file_put_contents($salida, $listado) === false) {
    fwrite(STDERR, "No se puede escribir $salida\n");
    exit(1);
}

printf("Generado %s (%d bytes de codigo, linea REM de %d caracteres)\n",
       $salida, $n, strlen($escaped));
