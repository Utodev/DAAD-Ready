<?php
// sd81mkp.php - convierte un listado BASIC de ZX81 en texto (.b81) a un
// programa .P tokenizado, listo para copiar a la SD y cargar sin teclear
// nada.
//
// La logica (tabla de tokens, codigos de caracter, formato del .P y
// codificacion en coma flotante) es un port de la que usa EightyOne para
// cargar ficheros .b81, tomada de sus fuentes:
//   Eightyone2/src/zx81/zx81BasicLoader.cpp   (tokens, AsciiToZX, sysvars,
//                                              OutputFloatingPointEncoding)
//   Eightyone2/src/BasicLoader/IBasicLoader.cpp (numeros embebidos)
//   Eightyone2/src/tzx/tzxload.cpp            (PatchZX81AutoRun)
// No esta reinventada: EightyOne es la referencia, y el resultado se ha
// comprobado byte a byte contra un .P suyo (ver mas abajo).
//
// FORMATO .P (ZX81): el fichero es un volcado de RAM desde 16393 (4009h):
//   offset 0-115    variables del sistema
//   offset 116      programa BASIC. Cada linea es
//                     [nº de linea: 2 bytes BIG endian]
//                     [longitud: 2 bytes little endian]
//                     [tokens/caracteres...] [76h = NEWLINE]
//   despues         display file (D_FILE) y area de variables (80h)
//
// Los NUMEROS van dos veces: primero sus digitos como caracteres (que es
// lo que se ve al listar) y detras un 7Eh seguido del valor en coma
// flotante de 5 bytes (que es lo que usa el interprete). Sin eso el
// programa se lista bien pero da resultados absurdos al ejecutarse.
//
// Uso: php sd81mkp.php entrada.b81 salida.p [linea_de_autoarranque]
//   Sin tercer parametro, arranca solo por la primera linea. Con -1 se
//   carga sin autoarrancar.

if ($argc < 3) {
    fwrite(STDERR, "Uso: sd81mkp entrada.b81 salida.p [linea_autoarranque]\n");
    exit(1);
}

$entrada  = $argv[1];
$salida   = $argv[2];
$autoLine = isset($argv[3]) ? (int)$argv[3] : 0;   // 0 = primera linea, -1 = no

$texto = @file_get_contents($entrada);
if ($texto === false) {
    fwrite(STDERR, "No se puede leer " . $entrada . "\n");
    exit(1);
}

//---------------------------------------------------------------------------
// Tabla de tokens del ZX81 (zx81BasicLoader.cpp). El texto de cada token
// lleva los espacios que el ZX81 le pone al expandirlo; aqui se buscan por
// el nombre sin espacios y se consume el espacio siguiente si lo hay.
//---------------------------------------------------------------------------
$TOKENS = array(
    64=>'RND', 65=>'INKEY$', 66=>'PI',
    193=>'AT', 194=>'TAB', 196=>'CODE', 197=>'VAL', 198=>'LEN', 199=>'SIN',
    200=>'COS', 201=>'TAN', 202=>'ASN', 203=>'ACS', 204=>'ATN', 205=>'LN',
    206=>'EXP', 207=>'INT', 208=>'SQR', 209=>'SGN', 210=>'ABS', 211=>'PEEK',
    212=>'USR', 213=>'STR$', 214=>'CHR$', 215=>'NOT', 216=>'**', 217=>'OR',
    218=>'AND', 219=>'<=', 220=>'>=', 221=>'<>', 222=>'THEN', 223=>'TO',
    224=>'STEP', 225=>'LPRINT', 226=>'LLIST', 227=>'STOP', 228=>'SLOW',
    229=>'FAST', 230=>'NEW', 231=>'SCROLL', 232=>'CONT', 233=>'DIM',
    234=>'REM', 235=>'FOR', 236=>'GOTO', 237=>'GOSUB', 238=>'INPUT',
    239=>'LOAD', 240=>'LIST', 241=>'LET', 242=>'PAUSE', 243=>'NEXT',
    244=>'POKE', 245=>'PRINT', 246=>'PLOT', 247=>'RUN', 248=>'SAVE',
    249=>'RAND', 250=>'IF', 251=>'CLS', 252=>'UNPLOT', 253=>'CLEAR',
    254=>'RETURN', 255=>'COPY',
);
// Nombres mas largos primero, para que STOP no se coma el TO de dentro.
$ORDEN = array_keys($TOKENS);
usort($ORDEN, function ($a, $b) use ($TOKENS) {
    return strlen($TOKENS[$b]) - strlen($TOKENS[$a]);
});

const ZXBLANK   = 0x00;
const ZXQUOTE   = 0x0B;
const ZXNEWLINE = 0x76;
const ZXNUMBER  = 0x7E;
const TOK_REM   = 234;

// AsciiToZX (zx81BasicLoader.cpp)
$PUNT = array(
    ' '=>0, '"'=>11, '#'=>12, '$'=>13, ':'=>14, '?'=>15, '('=>16, ')'=>17,
    '>'=>18, '<'=>19, '='=>20, '+'=>21, '-'=>22, '*'=>23, '/'=>24, ';'=>25,
    ','=>26, '.'=>27,
);
function asciiAZX($c, $PUNT)
{
    if ($c >= 'A' && $c <= 'Z') return ord($c) - ord('A') + 38;   // LetterA
    if ($c >= '0' && $c <= '9') return ord($c) - ord('0') + 28;   // Number0
    if (isset($PUNT[$c]))       return $PUNT[$c];
    fwrite(STDERR, "Caracter no valido para el ZX81: '" . $c . "'\n");
    exit(1);
}

// OutputFloatingPointEncoding (zx81BasicLoader.cpp): 5 bytes, exponente
// sesgado en 129 y mantisa de 32 bits con el bit alto implicito a 0 (los
// numeros en BASIC son siempre positivos; el signo menos es un operador).
function fpZX81($valor)
{
    if ($valor == 0.0) return array(0, 0, 0, 0, 0);
    $exp = (int)floor(PHP_FLOAT_EPSILON + (log($valor) / log(2.0)));
    if ($exp < -129 || $exp > 126) {
        fwrite(STDERR, "Numero fuera de rango: " . $valor . "\n");
        exit(1);
    }
    $man = (float)floor((($valor / pow(2.0, $exp)) - 1) * 0x80000000);
    $exp += 129;
    $m = (int)$man;
    return array($exp & 0xFF, ($m >> 24) & 0xFF, ($m >> 16) & 0xFF,
                 ($m >> 8) & 0xFF, $m & 0xFF);
}

//---------------------------------------------------------------------------
// Tokeniza una sentencia
//---------------------------------------------------------------------------
function tokeniza($sent, $TOKENS, $ORDEN, $PUNT)
{
    $out = array();
    $n = strlen($sent);
    $i = 0;
    $enComillas = false;
    $enRem = false;
    // Ultimo caracter EMITIDO como caracter (no como token). Sirve para
    // decidir si una tirada de digitos es un numero de verdad o parte de un
    // identificador: si lo anterior fue un token o un caracter que no es
    // letra ni digito, empieza numero. Asi "*MAP 7,62" trata el 7 como
    // numero (delante lleva un espacio) y un hipotetico "A1" no.
    $ultChar = null;

    while ($i < $n) {
        $c = $sent[$i];

        if (!$enRem) {
            if ($c === '"') {
                $out[] = ZXQUOTE;
                $enComillas = !$enComillas;
                $ultChar = $c;
                $i++;
                continue;
            }
        }

        if (!$enComillas && !$enRem) {
            // Token?
            $encontrado = false;
            foreach ($ORDEN as $cod) {
                $nom = $TOKENS[$cod];
                $l = strlen($nom);
                if (substr($sent, $i, $l) !== $nom) continue;
                // Frontera de palabra: ni letra pegada delante ni detras.
                $sig = ($i + $l < $n) ? $sent[$i + $l] : '';
                if ($sig >= 'A' && $sig <= 'Z') continue;
                if ($ultChar !== null && $ultChar >= 'A' && $ultChar <= 'Z') continue;
                $out[] = $cod;
                $i += $l;
                // El token expande con un espacio detras: si el texto lo
                // trae, es parte del token y no un caracter mas.
                if ($i < $n && $sent[$i] === ' ') $i++;
                if ($cod == TOK_REM) $enRem = true;
                $ultChar = null;    // lo ultimo emitido fue un token
                $encontrado = true;
                break;
            }
            if ($encontrado) continue;

            // Numero?
            if (($c >= '0' && $c <= '9') || $c === '.') {
                $esNum = ($ultChar === null)
                      || !(($ultChar >= 'A' && $ultChar <= 'Z')
                        || ($ultChar >= '0' && $ultChar <= '9'));
                if ($esNum) {
                    $j = $i;
                    while ($j < $n && (($sent[$j] >= '0' && $sent[$j] <= '9')
                                       || $sent[$j] === '.')) {
                        $j++;
                    }
                    $lit = substr($sent, $i, $j - $i);
                    foreach (str_split($lit) as $d) {
                        $out[] = asciiAZX($d, $PUNT);
                    }
                    $out[] = ZXNUMBER;
                    foreach (fpZX81((float)$lit) as $b) $out[] = $b;
                    $i = $j;
                    $ultChar = substr($lit, -1);
                    continue;
                }
            }
        }

        $out[] = asciiAZX($c, $PUNT);
        $ultChar = $c;
        $i++;
    }

    $out[] = ZXNEWLINE;
    return $out;
}

//---------------------------------------------------------------------------
// Parsea el .b81 y arma el programa
//---------------------------------------------------------------------------
$prog = array();
$primeraLinea = null;
$offsetDeLinea = array();   // nº de linea -> offset dentro del programa

foreach (preg_split('/\r\n|\n|\r/', $texto) as $l) {
    if (trim($l) === '') continue;
    if (substr($l, 0, 2) === '#!') continue;          // directivas de EightyOne
    if (!preg_match('/^\s*(\d+)\s(.*)$/', $l, $m)) {
        fwrite(STDERR, "Linea sin numero: " . $l . "\n");
        exit(1);
    }
    $num  = (int)$m[1];
    $sent = rtrim($m[2], "\r");
    if ($primeraLinea === null) $primeraLinea = $num;

    $cuerpo = tokeniza(strtoupper($sent), $TOKENS, $ORDEN, $PUNT);

    $offsetDeLinea[$num] = count($prog);
    $prog[] = ($num >> 8) & 0xFF;      // nº de linea: BIG endian
    $prog[] = $num & 0xFF;
    $prog[] = count($cuerpo) & 0xFF;   // longitud: little endian
    $prog[] = (count($cuerpo) >> 8) & 0xFF;
    foreach ($cuerpo as $b) $prog[] = $b;
}

if (!$prog) {
    fwrite(STDERR, "El fichero no tiene ninguna linea BASIC\n");
    exit(1);
}

//---------------------------------------------------------------------------
// Variables del sistema (zx81BasicLoader::OutputStartOfProgramData)
//---------------------------------------------------------------------------
$sv = array_fill(0, 116, 0);
function pw(&$a, $off, $v) { $a[$off] = $v & 0xFF; $a[$off + 1] = ($v >> 8) & 0xFF; }

pw($sv, 22, 0x405D);        // MEM
$sv[25] = 0x02;             // DF_SZ
pw($sv, 28, 0xFFFF);        // LAST_K
$sv[31] = 0x37;             // MARGIN
pw($sv, 39, 0x0C8D);        // T_ADDR
pw($sv, 41, 0x4321);        // SEED
pw($sv, 43, 0xE6E0);        // FRAMES
$sv[47] = 0xBC;             // PR_CC
pw($sv, 48, 0x1821);        // S_POSN
$sv[50] = 0x40;             // CDFLAG
$sv[83] = ZXNEWLINE;        // PRBUFF

$SOR = 16393;               // 4009h: el .P es un volcado de RAM desde aqui
$PROG_OFF = 116;

// D_FILE plegado (25 NEWLINE) + area de variables, igual que EightyOne
$dfileAddr = $SOR + $PROG_OFF + count($prog);
$dfile = array_fill(0, 25, ZXNEWLINE);
$varsAddr  = $dfileAddr + 25;
$elineAddr = $varsAddr + 1;

pw($sv,  3, $dfileAddr);        // D_FILE
pw($sv,  5, $dfileAddr + 1);    // DF_CC
pw($sv,  7, $varsAddr);         // VARS
pw($sv, 11, $varsAddr + 1);     // E_LINE
pw($sv, 13, $varsAddr + 5);     // CH_ADD
pw($sv, 17, $elineAddr + 5);    // STKBOT
pw($sv, 19, $elineAddr + 5);    // STKEND
pw($sv, 32, $varsAddr);         // NXTLIN: por defecto, sin autoarranque

// Autoarranque (PatchZX81AutoRun en tzxload.cpp): NXTLIN apuntando a la
// linea por la que se quiere empezar.
if ($autoLine >= 0) {
    $destino = ($autoLine == 0) ? $primeraLinea : $autoLine;
    $off = null;
    foreach ($offsetDeLinea as $num => $o) {
        if ($num >= $destino) { $off = $o; break; }
    }
    if ($off === null) {
        fwrite(STDERR, "No existe la linea " . $destino . " para autoarrancar\n");
        exit(1);
    }
    pw($sv, 32, $SOR + $PROG_OFF + $off);
}

$bytes = array_merge($sv, $prog, $dfile, array(0x80));
$bin = '';
foreach ($bytes as $b) $bin .= chr($b & 0xFF);

if (file_put_contents($salida, $bin) === false) {
    fwrite(STDERR, "No se puede escribir " . $salida . "\n");
    exit(1);
}

echo "Generado " . $salida . " (" . strlen($bin) . " bytes, programa "
   . count($prog) . " bytes"
   . ($autoLine >= 0 ? ", autoarranque" : "") . ")\n";
