<?php
echo "AMSDOS Header Creator v1.0\n";
if ($argc != 3) {
    die("Uso: php amsdosheader.php <fichero> <direccion_carga_decimal>\n");
}

$input = $argv[1];
$load  = intval($argv[2]);

if (!file_exists($input)) {
    die("No existe el fichero '$input'\n");
}

$data = file_get_contents($input);
$size = strlen($data);

if ($size == 0) {
    die("El fichero está vacío.\n");
}

if ($size > 0xFFFFFF) {
    die("El fichero supera el tamaño máximo AMSDOS (16 MB).\n");
}

$header = array_fill(0, 128, 0);

//
// Nombre CP/M (15 caracteres)
//
$base = strtoupper(basename($input));

// Eliminar ruta
$base = preg_replace('/^.*[\/\\\\]/', '', $base);

// Quitar el punto
$base = str_replace('.', '', $base);

// Máximo 15 caracteres
$base = substr($base, 0, 15);

for ($i=0; $i<strlen($base); $i++)
    $header[1+$i] = ord($base[$i]);

//
// Tipo BIN
//
$header[0x12] = 2;

//
// Dirección de carga
//
$header[0x15] = $load & 0xFF;
$header[0x16] = ($load >> 8) & 0xFF;

//
// Tamaño lógico (16 bits)
//
$header[0x18] = $size & 0xFF;
$header[0x19] = ($size >> 8) & 0xFF;

//
// Dirección de entrada (= carga)
//
$header[0x1A] = $load & 0xFF;
$header[0x1B] = ($load >> 8) & 0xFF;

//
// Tamaño real (24 bits)
//
$header[0x40] = $size & 0xFF;
$header[0x41] = ($size >> 8) & 0xFF;
$header[0x42] = ($size >> 16) & 0xFF;

//
// Checksum (bytes 00-42)
//
$checksum = 0;

for ($i=0; $i<=0x42; $i++)
    $checksum += $header[$i];

$checksum &= 0xFFFF;

$header[0x43] = $checksum & 0xFF;
$header[0x44] = ($checksum >> 8) & 0xFF;

//
// Crear fichero .AMS
//
$outfile = preg_replace('/\.[^.]+$/', '', $input) . '.612';

$fp = fopen($outfile, 'wb');

foreach ($header as $b)
    fwrite($fp, chr($b));

fwrite($fp, $data);

fclose($fp);

echo "Creado: $outfile\n";
echo "Carga : $load (0x" . strtoupper(dechex($load)) . ")\n";
echo "Tamaño: $size bytes\n";