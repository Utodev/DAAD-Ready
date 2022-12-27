<?php

function syntax()
{
    echo "jDAADImager 1.0 - Creates images for jDAAD from PNG files\n\n";
    echo "SYNTAX: jDAADImager [inputfile] [outputfile]\n\n";
    
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
$im = imagecreatefrompng($inputFilename);
if (!$im) error('Invalid PNG file');

$parts = explode(DIRECTORY_SEPARATOR, $inputFilename);
$imageFileName = $parts[sizeof($parts)-1];
$imageNumber=explode('.',$imageFileName)[0];

if (ctype_digit($imageNumber)) $imageNumber = intval($imageNumber); 

$output = "images[$imageNumber]= [";


$width = imagesx($im);
$height = imagesy($im);

$count = 0;
for ($y=0; $y<$height; $y++)
    for ($x=0; $x<$width; $x++)
    {
        $colorIndex = imagecolorat($im, $x, $y);
        $alpha = ($colorIndex >> 24); // in php alpha channel goes is 0-127 but HTML canvas uses 0-255
        $alpha = $alpha < 127 ? 0 : 255;
        $colorIndex = ($alpha << 24) | ($colorIndex & 0xFFFFFF);
        $output .= "$colorIndex, ";
        if ($count%10 ==9) $output.="\n";
        $count ++;
    }
    file_put_contents($outpuFilename, $output . "$width, $height];\n\n",FILE_APPEND);    