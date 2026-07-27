<?php

function syntax(): never
{
    echo "SYNTAX: php CPMPacker.php <interpreter file> [DDB address]\n\n";
    echo "The interpreter file must be a DAAD CP/M interpreter, e.g. DCPMI.BIN\n";
    echo "The DDB address is optional, default is \$2000.\n";
    echo "The DDB file must be called DAAD.DDB and be in the current directory\n";
    exit(1);
}

function errorExit(string $msg): never
{
    fwrite(STDERR, "Error: $msg\n");
    exit(1);
}

if ($argc < 2) {
    syntax();
}

$interpreterFile = $argv[1];

if (!file_exists($interpreterFile)) {
    errorExit("Interpreter file not found: $interpreterFile");
}

if (!file_exists("DAAD.DDB")) {
    errorExit("DDB file not found: DAAD.DDB");
}

$ddbAddress = 0x2000;

if ($argc > 2) {
    $value = trim($argv[2]);

    if ($value[0] == '$') {
        $ddbAddress = hexdec(substr($value, 1));
    } elseif (ctype_digit($value)) {
        $ddbAddress = intval($value);
    } else {
        errorExit("Invalid DDB address: $value");
    }
}

if ($ddbAddress < 0x80 || $ddbAddress > 0xFFFF) {
    errorExit(sprintf(
        "Invalid DDB address: %04X",
        $ddbAddress
    ));
}

$ddb = file_get_contents("DAAD.DDB");
if ($ddb === false) {
    errorExit("Unable to read DAAD.DDB");
}

$ddbSize = strlen($ddb);


printf(
    "Packing %s with DAAD.DDB at address %d (%04X) into DAAD.COM. DDB size is %d (%04x)\n",
    $interpreterFile,
    $ddbAddress,
    $ddbAddress,
    $ddbSize,
    $ddbSize
);


if ($ddbSize + $ddbAddress > 0xE000) {
    errorExit("DDB file is too large to fit");
}




$interpreter = file_get_contents($interpreterFile);
$interpreterSize = strlen($interpreter);

if ($interpreter === false || $interpreterSize === 0) {
    errorExit("Unable to read interpreter file");
}

if ($interpreterSize + 0x100 > $ddbAddress) 
{
    errorExit("Interpreter file is too large to fit");
}

$out = fopen("DAAD.COM", "wb");
if (!$out) {
    errorExit("Cannot create DAAD.COM");
}

fwrite($out, $interpreter);

$spare = $ddbAddress - $interpreterSize - 0x100;
if ($spare > 0) {
    fwrite($out, str_repeat("\0", $spare));
}



fwrite($out, $ddb);


fclose($out);
echo "DAAD.COM created successfully.\n";