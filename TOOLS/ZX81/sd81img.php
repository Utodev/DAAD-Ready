<?php
// sd81img.php - empaqueta los .zx0 de UNA imagen (ya generados con
// ZXsplitter.php + zx0.exe de DAAD-Ready a partir de un NNN.SCR) en un
// unico fichero listo para copiar a la SD del SD81 Booster, con el nombre
// de 3 digitos que espera S48KPICTURE (ver ZX/SD81.ASM en este repo).
//
// A diferencia de pager48k.php (que consolida TODAS las imagenes de un
// juego en un unico blob de "pagina 0" + una tabla de indice, pensado
// para precargar todo de golpe desde cinta), este script solo empaqueta
// UNA imagen, porque el SD81 Booster carga cada imagen bajo demanda
// directamente por su nombre de fichero - no hace falta ninguna tabla de
// indice ni precarga.
//
// Uso: php sd81img.php <numero_imagen 0-255> [carpeta] [ficherosalida]
//
//   <numero_imagen>  0-255. Se buscan los ficheros "<numero>_*.zx0" (mismo
//                    formato de nombre que produce ZXsplitter.php) dentro
//                    de <carpeta>.
//   [carpeta]        donde buscar los "<numero>_*.zx0". Por defecto, la
//                    carpeta actual.
//   [ficherosalida]  nombre del fichero de salida. Por defecto, el numero
//                    de imagen en 3 digitos mas ".IMG" (p.ej. "001.IMG"),
//                    que es el nombre que hay que copiar tal cual a la SD.
//
// Flujo completo, para una imagen NNN.SCR:
//   php ZXsplitter.php NNN.SCR <IMGLINES>      (de DAAD-Ready\TOOLS\DRC)
//   zx0.exe NNN_*.prt                          (de DAAD-Ready\TOOLS\ZX0,
//                                                una vez por cada .prt)
//   php sd81img.php <NNN sin ceros> .          (este script)
//   -> copiar el fichero "NNN.IMG" resultante a la SD tal cual
//
// Formato de salida (igual que el que ya entiende ChunkLoop en SD81.ASM,
// heredado del que generaba pager48k.php para su blob de pagina 0):
//   [offset:2 LE][tamano comprimido:2 LE][datos ZX0] ... repetido por cada
//   trozo, terminado con dos bytes 0x00 0x00 (offset con MSB=0, imposible
//   para pantalla real, sirve de marca de fin).

if ($argc < 2) {
    echo "Uso: php sd81img.php <numero_imagen 0-255> [carpeta] [ficherosalida]\n";
    exit(1);
}

$imagenumber = (int)$argv[1];
if ($imagenumber < 0 || $imagenumber > 255) {
    die("Numero de imagen fuera de rango (0-255): {$argv[1]}\n");
}

$folder = $argv[2] ?? '.';
$filename = sprintf('%03d', $imagenumber);
// La extension .IMG es OBLIGATORIA, no cosmetica: el firmware del SD81
// trata cualquier fichero SIN extension como un programa ZX81 .P y calcula
// su tamano leyendo los bytes 11-12 del propio fichero (E_LINE-16393, ver
// cmd_load en COMMANDS.cpp), lo que con datos de imagen da un tamano
// disparatado y cuelga al MCU. Debe coincidir con SD81_PICNAME en SD81.ASM.
$outputfile = $argv[3] ?? ($filename . '.IMG');

$blockFiles = glob("$folder/{$filename}_*.zx0");
if (!$blockFiles) {
    die("No se ha encontrado ningun {$filename}_*.zx0 en '$folder' " .
        "(¿has ejecutado antes ZXsplitter.php + zx0.exe sobre {$filename}.SCR?)\n");
}

$imageData = '';
foreach ($blockFiles as $blockFile) {
    $blockData = file_get_contents($blockFile);
    $blockSize = strlen($blockData);
    $parts = explode('_', pathinfo($blockFile, PATHINFO_FILENAME));
    $blockOffset = (int)$parts[1];

    if ($blockOffset < 0x4000 || $blockOffset > 0xFFFF) {
        die("Offset invalido en '$blockFile': $blockOffset\n");
    }
    if ($blockSize > 0xFFFF) {
        die("Trozo demasiado grande (>65535 bytes comprimidos) en '$blockFile'\n");
    }

    $imageData .= pack('v', $blockOffset) . pack('v', $blockSize) . $blockData;
    echo "Anadido trozo: $blockFile (offset: $blockOffset, tamano comprimido: $blockSize)\n";
}

$imageData .= pack('v', 0); // marca de fin

$totalSize = strlen($imageData);
if ($totalSize > 6912) {
    // PictureBuffer en SD81.ASM tiene 6912 bytes; S48KPICTURE trunca por
    // seguridad (y drena el resto), pero un fichero mayor que eso
    // perderia datos de la imagen.
    echo "AVISO: '$outputfile' pesa $totalSize bytes, mas de los 6912 que " .
         "caben en PictureBuffer - la imagen se veria incompleta.\n";
}

file_put_contents($outputfile, $imageData);
echo "Generado '$outputfile' ($totalSize bytes). Copialo a la SD con ese mismo nombre.\n";
