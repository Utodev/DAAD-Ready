<?php

// Converts a Degas PI1 file into a 12-bit planar format suitable for Amiga screens, changing also the palette configuration

function sortPal($aByte)
{
    
    $aByte = ord($aByte);
    $aByteLowNibble = $aByte & 0xF;
    $aByteHighNibble = ($aByte & 0xF0) >> 4;
    $aByteLowNibble = (($aByteLowNibble << 1) & 0xF) + (($aByteLowNibble >> 3) & 1);
    $aByteHighNibble = (($aByteHighNibble << 1) & 0xF) + (($aByteHighNibble >> 3) & 1);
    $aByte = $aByteLowNibble + ($aByteHighNibble << 4);
    
    return $aByte;
}


$inputFile  = $argv[1];
$outputFile = $argv[2];

// Leer fichero completo
$data = file_get_contents($inputFile);
if ($data === false) {
    die("Error leyendo el fichero\n");
}

// Separar cabecera (32 bytes) y datos (32000 bytes)
$header = substr($data, 0, 34);

for ($i = 2; $i < 34; $i++) 
    {
        $header[$i] = chr(sortPal($header[$i]));
    }

$body   = substr($data, 34);

if (strlen($body) < 32000) {
    die("El tamaño de datos no es válido\n");
}

// Inicializar buffers para los 4 planos
$planes = [
    '', '', '', ''
];

// Cada bloque son 4 palabras (8 bytes): 2 bytes por plano
for ($i = 0; $i < 32000; $i += 8) {
    // Extraer cada plano (2 bytes)
    $planes[0] .= substr($body, $i,     2); // P0
    $planes[1] .= substr($body, $i + 2, 2); // P1
    $planes[2] .= substr($body, $i + 4, 2); // P2
    $planes[3] .= substr($body, $i + 6, 2); // P3
}

// Concatenar planos: P0 completo, luego P1, etc.
$newBody = $planes[0] . $planes[1] . $planes[2] . $planes[3];

// Validación final
if (strlen($newBody) !== 32000) {
    die("Error en la reconstrucción de planos\n");
}

// Guardar nuevo fichero
$result = file_put_contents($outputFile, $header . $newBody);

if ($result === false) {
    die("Error escribiendo el fichero\n");
}

echo "Conversión completada correctamente\n";