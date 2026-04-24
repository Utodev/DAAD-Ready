<?php

function syntax()
{
    echo "png2amiga helper - Converts one PNG to HAM6 IFF when needed\n\n";
    echo "SYNTAX: png2amiga.php <input.png> <output.iff>\n";
    exit(1);
}

function fail($message)
{
    echo $message . "\n";
    exit(1);
}

function get_extension($filename)
{
    $pos = strrpos($filename, '.');
    if ($pos === false) {
        return '';
    }
    return strtolower(substr($filename, $pos + 1));
}

function is_valid_ilbm_file($filename)
{
    $handle = @fopen($filename, 'rb');
    if ($handle === false) {
        return false;
    }

    $header = fread($handle, 12);
    fclose($handle);
    if ($header === false || strlen($header) < 12) {
        return false;
    }

    return substr($header, 0, 4) === 'FORM' && substr($header, 8, 4) === 'ILBM';
}

function build_tool_output_filename($outputFilename)
{
    $pos = strrpos($outputFilename, '.');
    if ($pos === false) {
        return $outputFilename . '.generated.iff';
    }
    return substr($outputFilename, 0, $pos) . '.generated.iff';
}

if ($argc != 3) {
    syntax();
}

$inputFilename = $argv[1];
$outputFilename = $argv[2];
$toolOutputFilename = build_tool_output_filename($outputFilename);

if (!file_exists($inputFilename)) {
    fail("Input file not found: " . $inputFilename);
}

if (file_exists($outputFilename) && filemtime($outputFilename) >= filemtime($inputFilename)) {
    if (is_valid_ilbm_file($outputFilename)) {
        exit(0);
    }
    unlink($outputFilename);
}

if (file_exists($toolOutputFilename)) {
    unlink($toolOutputFilename);
}

$toolPath = dirname(__FILE__) . DIRECTORY_SEPARATOR . 'png2amiga.exe';
if (!file_exists($toolPath)) {
    fail("png2amiga executable not found: " . $toolPath);
}

$command = escapeshellarg($toolPath)
    . ' --mode ham6 '
    . escapeshellarg($inputFilename)
    . ' -o '
    . escapeshellarg($toolOutputFilename);

$exitCode = 0;
passthru($command, $exitCode);
if ($exitCode != 0) {
    if (file_exists($toolOutputFilename)) {
        unlink($toolOutputFilename);
    }
    exit($exitCode);
}

if (file_exists($outputFilename)) {
    unlink($outputFilename);
}
if (!rename($toolOutputFilename, $outputFilename)) {
    fail("Unable to rename generated IFF file to target output: " . $outputFilename);
}

exit(0);