<?php
// sd81mkb81.php - genera el cargador BASIC del ZX81 en formato texto .b81.
//
// El .b81 es el listado BASIC en texto plano que entiende EightyOne (y que
// se puede teclear tal cual en un ZX81 real). Formato, sacado de un fichero
// exportado por el propio EightyOne:
//
//   - numero de linea alineado a la DERECHA en 4 caracteres, y un espacio
//   - todo en MAYUSCULAS (el ZX81 no tiene minusculas)
//   - cada token del ZX81 se escribe con un espacio DETRAS ("FAST ",
//     "SLOW ", "LOAD ", "RAND ", "USR "...), asi que las lineas que acaban
//     en token acaban en espacio. No es cosmetico: es como el ZX81 expande
//     los tokens, y respetarlo evita sorpresas al reimportar.
//   - finales de linea CRLF
//
// La direccion de carga del SDG NO es fija: el SDG tiene que terminar justo
// en FFFFh, asi que depende de su tamano exacto (direccion = 65536 - tamano).
// Por eso este script recibe la RUTA del SDG y la calcula, en vez de llevar
// el 63447 de siempre a fuego.
//
// Uso: php sd81mkb81.php salida.b81 INTERPRETE.BIN NOMBRE.DDB ruta/al/DAAD.SDG [titulo]

if ($argc < 5) {
    fwrite(STDERR, "Uso: sd81mkb81 salida.b81 INTERPRETE.BIN NOMBRE.DDB ruta/DAAD.SDG [titulo]\n");
    exit(1);
}

$salida      = $argv[1];
$interprete  = strtoupper($argv[2]);
$ddb         = strtoupper($argv[3]);
$sdgRuta     = $argv[4];
$titulo      = isset($argv[5]) ? strtoupper($argv[5]) : 'DAAD - SD81 BOOSTER';

$sdgNombre = strtoupper(basename($sdgRuta));
$sdgTam    = @filesize($sdgRuta);
if ($sdgTam === false || $sdgTam <= 0) {
    fwrite(STDERR, "No se puede leer el tamano de " . $sdgRuta . "\n");
    exit(1);
}

// El SDG tiene que acabar exactamente en FFFFh (ver SD81_ARRANQUE.txt).
$sdgDir = 65536 - $sdgTam;
if ($sdgDir < 57344) {
    // Por debajo de E000h se saldria del bloque 7 y pisaria el DDB.
    fwrite(STDERR, "SDG demasiado grande (" . $sdgTam . " bytes): cargaria en "
                 . $sdgDir . ", por debajo de 57344 (E000h)\n");
    exit(1);
}

$lineas = array(
    array(1,  'REM ' . $titulo),
    array(2,  'FAST '),
    array(3,  'LOAD FAST '),
    array(4,  'LOAD THEN CLEAR 24575'),
    array(5,  'LOAD *MAP 7,62'),
    array(6,  'LOAD FAST "BIN/DSD81ROM0.BIN" CODE 57344'),
    array(7,  'LOAD *MAP 7,63'),
    array(8,  'LOAD FAST "BIN/DSD81ROM1.BIN" CODE 57344'),
    array(9,  'LOAD *MAP 7,7'),
    array(15, 'LOAD FAST "BIN/' . $interprete . '" CODE 24576'),
    array(20, 'LOAD FAST "' . $ddb . '" CODE 33792'),
    array(30, 'LOAD FAST "' . $sdgNombre . '" CODE ' . $sdgDir),
    array(40, 'RAND USR 24576'),
    // Al salir del juego, SD81_EXIT devuelve el control a BASIC justo aqui,
    // en la linea siguiente al USR. Deja el generador de NMI apagado (o sea
    // FAST, coherente con el CDFLAG que acaba de restaurar), asi que es
    // este SLOW el que vuelve a encender la pantalla.
    array(50, 'SLOW '),
);

$texto = '';
foreach ($lineas as $l) {
    $texto .= str_pad($l[0], 4, ' ', STR_PAD_LEFT) . ' ' . $l[1] . "\r\n";
}

if (file_put_contents($salida, $texto) === false) {
    fwrite(STDERR, "No se puede escribir " . $salida . "\n");
    exit(1);
}

echo "Generado " . $salida . " (SDG " . $sdgTam . " bytes -> CODE " . $sdgDir . ")\n";
