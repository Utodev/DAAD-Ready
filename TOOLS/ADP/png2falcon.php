<?php

function fail($message)
{
    echo $message . "\n";
    exit(1);
}

function build_falcon_planar_row($image, $y, $width)
{
    $row = '';
    for ($x = 0; $x < $width; $x += 16)
    {
        $planes = array_fill(0, 8, 0);
        for ($bit = 0; $bit < 16; $bit++)
        {
            $color = imagecolorat($image, $x + $bit, $y) & 0xFF;
            $mask = 0x8000 >> $bit;
            for ($plane = 0; $plane < 8; $plane++)
            {
                if (($color & (1 << $plane)) !== 0)
                {
                    $planes[$plane] |= $mask;
                }
            }
        }

        for ($plane = 0; $plane < 8; $plane++)
        {
            $row .= chr(($planes[$plane] >> 8) & 0xFF);
            $row .= chr($planes[$plane] & 0xFF);
        }
    }

    return $row;
}

function write_falcon_file($image, $outputFile)
{
    $width = imagesx($image);
    $height = imagesy($image);
    if ($width !== 320 || $height !== 200)
    {
        fail("Unsupported PNG size {$width}x{$height}; expected 320x200");
    }

    $handle = fopen($outputFile, 'wb');
    if ($handle === false)
    {
        return false;
    }

    if (fwrite($handle, "FCR1") !== 4)
    {
        fclose($handle);
        return false;
    }

    $paletteCount = imagecolorstotal($image);
    for ($index = 0; $index < 256; $index++)
    {
        if ($index < $paletteCount)
        {
            $color = imagecolorsforindex($image, $index);
            $chunk = chr($color['red']) . chr($color['green']) . chr($color['blue']);
        }
        else
        {
            $chunk = "\0\0\0";
        }

        if (fwrite($handle, $chunk) !== 3)
        {
            fclose($handle);
            return false;
        }
    }

    for ($y = 0; $y < $height; $y++)
    {
        $row = build_falcon_planar_row($image, $y, $width);
        if (fwrite($handle, $row) !== strlen($row))
        {
            fclose($handle);
            return false;
        }
    }

    fclose($handle);
    return true;
}

if ($argc < 3)
{
    fail("Usage: php png2falcon.php <input.png> <output.fcr>");
}

if (!function_exists('imagecreatefrompng'))
{
    fail("This script requires PHP GD support with PNG reading enabled");
}

$inputFile = $argv[1];
$outputFile = $argv[2];

if (!file_exists($inputFile))
{
    fail("Input file not found: " . $inputFile);
}

$image = @imagecreatefrompng($inputFile);
if ($image === false)
{
    fail("Unable to read PNG file: " . $inputFile);
}

if (imagesx($image) !== 320 || imagesy($image) !== 200)
{
    imagedestroy($image);
    fail("Unsupported PNG size " . imagesx($image) . "x" . imagesy($image) . "; expected 320x200");
}

if (imageistruecolor($image))
{
    if (!imagetruecolortopalette($image, false, 256))
    {
        imagedestroy($image);
        fail("Unable to convert truecolor PNG to indexed palette");
    }
}

$dir = dirname($outputFile);
if ($dir != '.' && !is_dir($dir) && !mkdir($dir, 0777, true))
{
    imagedestroy($image);
    fail("Unable to create output directory: " . $dir);
}

if (!write_falcon_file($image, $outputFile))
{
    imagedestroy($image);
    fail("Unable to write Falcon raw file: " . $outputFile);
}

imagedestroy($image);