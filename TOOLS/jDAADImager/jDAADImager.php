<?php

function syntax()
{
    echo "jDAADImager 1.0 - Creates images for jDAAD from PNG files\n\n";
    echo "SYNTAX: jDAADImager <inputfile> <outputfile> <width> <height> [x,y]\n\n";
    echo "Examples: jDAADImager image.png images.js 320 96-> Generates floating image from image.png\n";
    echo "          jDAADImager image.png images.js 320 96 8,8-> Generates fixed image at 8x8, 320 wide, 96 high from image.png\n";

    
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
$width = $argv[3];
$height = $argv[4];

if (isset($argv[5]))
{
    $parts = explode(',', $argv[5]);
    if (sizeof($parts) != 2) error("Invalid x,y coordinates [".$argv[5]."]");
    $basex = intval($parts[0]);
    $basey = intval($parts[1]);
    if (($basex < 0) || ($basey < 0)) error("Invalid x,y coordinates [$basex,$basey].");
    if (!is_numeric($basex)) error("X coordinate is not a number [$basex]");
    if (!is_numeric($basey)) error("Y coordinate is not a number [$basey]");
    if (floor($basex) != $basex) error("X coordinate is not an integer [$basex]");
    if (floor($basey) != $basey) error("Y coordinate is not an integer [$basey]");
}
else
{
    $basex = -1; // For floating images
    $basey = -1;
}

if (!is_numeric($width)) error("Width is not a number [".$argv[3]."]");
if (!is_numeric($height)) error("Height is not a number [".$argv[4]."]");
if (floor($width) != $width) error("Width is not an integer [".$argv[3]."]");
if (floor($height) != $height) error("Height is not an integer [".$argv[4]."]");
if (($width < 0) || ($height < 0)) error("Invalid width,height dimensions [".$argv[4]."]");
if ($width>320) error("Width cannot be larger than 320");
if ($height>200) error("Height cannot be larger than 320");



if (!file_exists($inputFilename)) error('Input file not found');
$im = @imagecreatefrompng($inputFilename);
if (!$im) error('Invalid PNG file');

$parts = explode(DIRECTORY_SEPARATOR, $inputFilename);
$imageFileName = $parts[sizeof($parts)-1];
$imageNumber=explode('.',$imageFileName)[0];

if (ctype_digit($imageNumber)) $imageNumber = intval($imageNumber); 

$output = "images[$imageNumber]= [";


$imagewidth = imagesx($im);
$imageheight = imagesy($im);

if ($imagewidth<$width) error("Image width ($imagewidth) is smaller than specified width ($width)");
if ($imageheight<$height) error("Image height ($imageheight) is smaller than specified height ($height)");


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
    file_put_contents($outpuFilename, $output . "$basex, $basey, $width, $height];\n\n",FILE_APPEND);    