<?php

// Creates font.js file needed by jDAAD from an original DAAD CHR file


function syntax()
{
    echo "jDAADFontMaker 1.0 - Creates font.js file for jDAAD from DAAD CHR files\n\n";
    echo "SYNTAX: jDAADFontMaker [inputfile] [outputfile]\n\n";
    
    exit(0);

}

function error($msg)
{
    echo "$msg.\n";
    exit(1);
}

if ($argc<2) syntax();

$inputFilename = $argv[1];
$outpuFilename = $argv[2];


if (!file_exists($inputFilename)) error('Input file not found');
$fsize = filesize($inputFilename); 
if ($fsize != 2048) error('Invalid CHR file size (must be 2048 bytes)');

$handle = fopen($inputFilename, "rb"); 
if (!$handle) error('Invalid CHR file');
$contents = fread($handle, $fsize); 
$fontArray = unpack("C*",$contents);

if (sizeof($fontArray) != 2048) error('Invalid CHR file size (must be 2048 bytes)');
$output = "var font = [\n";
for($i=1; $i<=2048; $i++)
{
    $output .= '0x'. str_pad(dechex($fontArray[$i]),2,'0',STR_PAD_LEFT);
    if ($i!=2048) $output .= ', ';
    if (($i-1)%16 ==15) $output.="\n";
}
$output .= '];';
file_put_contents($outpuFilename, $output);
