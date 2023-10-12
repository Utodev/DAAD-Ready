<?php


include_once('png.php');

function error($text)
{
    echo $text . "\n";
    exit;
}

if ($argc<2) syntax();

$inputFilename = $argv[1];
$outputFilename = $argv[2];

$degas = new pngFileReader();

$degas = new pngFileReader();
$result = $degas->loadFile($inputFilename);
if ($result!='') error($result);


$output = '';

for($i=0;$i<$degas->fileSize;$i++)
{
    $output .= chr($degas->readByte());
}

file_put_contents($outputFilename,$output);
