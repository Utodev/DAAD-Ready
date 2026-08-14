<?php
// sd81sdgextract.php - extrae el ultimo bloque de datos de un fichero .TAP.
//
// daadmaker.exe (DAAD-Ready) es quien de verdad sabe fusionar un DAAD.SDG
// "plantilla" (CTABLE + cabecera de graficos) con un juego de caracteres
// .CHR (STABLE, 2048 bytes) para producir el SDG final con los glifos
// acentuados bien dibujados - pero solo lo hace como parte de construir un
// .TAP completo, no hay forma de pedirle solo el SDG resultante.
//
// Este script hace la parte que falta: parte un .TAP en sus bloques (2
// bytes de longitud + flag + datos + checksum, formato estandar) y vuelca
// el DATO (sin flag ni checksum) del ULTIMO bloque a un fichero aparte. En
// la forma en que sd81build.bat llama a daadmaker.exe (INT, DDB, SDG, CHR,
// sin SCR/loader/INDEX), el SDG fusionado es siempre el ultimo bloque.
//
// Uso: php sd81sdgextract.php entrada.tap salida.sdg

if ($argc < 3) {
    fwrite(STDERR, "Uso: sd81sdgextract entrada.tap salida.sdg\n");
    exit(1);
}

$tap = file_get_contents($argv[1]);
if ($tap === false) {
    fwrite(STDERR, "No se puede leer " . $argv[1] . "\n");
    exit(1);
}

$pos = 0;
$len = strlen($tap);
$lastBlock = null;

while ($pos < $len) {
    if ($pos + 2 > $len) break;
    $blockLen = ord($tap[$pos]) | (ord($tap[$pos + 1]) << 8);
    $pos += 2;
    if ($pos + $blockLen > $len) break;
    $block = substr($tap, $pos, $blockLen);
    // $block = [flag:1][datos...][checksum:1]
    $lastBlock = substr($block, 1, $blockLen - 2);
    $pos += $blockLen;
}

if ($lastBlock === null) {
    fwrite(STDERR, "No se ha encontrado ningun bloque en " . $argv[1] . "\n");
    exit(1);
}

if (file_put_contents($argv[2], $lastBlock) === false) {
    fwrite(STDERR, "No se puede escribir " . $argv[2] . "\n");
    exit(1);
}

echo "Extraidos " . strlen($lastBlock) . " bytes a " . $argv[2] . "\n";
