<?php

function fail($message)
{
    echo $message . "\n";
    exit(1);
}

function encode_pcx_scanline($bytes)
{
    $encoded = '';
    $count = count($bytes);
    $index = 0;

    while ($index < $count)
    {
        $value = $bytes[$index];
        $runLength = 1;

        while ($index + $runLength < $count && $runLength < 63 && $bytes[$index + $runLength] === $value)
        {
            $runLength++;
        }

        if ($runLength > 1 || (($value & 0xC0) === 0xC0))
        {
            $encoded .= chr(0xC0 | $runLength) . chr($value);
        }
        else
        {
            $encoded .= chr($value);
        }

        $index += $runLength;
    }

    return $encoded;
}

function set_word(&$buffer, $offset, $value)
{
    $buffer[$offset] = chr($value & 0xFF);
    $buffer[$offset + 1] = chr(($value >> 8) & 0xFF);
}

function write_pcx_file($image, $outputFile)
{
    $width = imagesx($image);
    $height = imagesy($image);
    $bytesPerLine = ($width & 1) ? $width + 1 : $width;

    $header = str_repeat("\0", 128);
    $header[0] = chr(0x0A);
    $header[1] = chr(0x05);
    $header[2] = chr(0x01);
    $header[3] = chr(0x08);
    set_word($header, 4, 0);
    set_word($header, 6, 0);
    set_word($header, 8, $width - 1);
    set_word($header, 10, $height - 1);
    set_word($header, 12, $width);
    set_word($header, 14, $height);
    $header[65] = chr(1);
    set_word($header, 66, $bytesPerLine);
    set_word($header, 68, 1);

    $handle = fopen($outputFile, 'wb');
    if ($handle === false)
    {
        return false;
    }

    if (fwrite($handle, $header) !== strlen($header))
    {
        fclose($handle);
        return false;
    }

    for ($y = 0; $y < $height; $y++)
    {
        $scanline = array();

        for ($x = 0; $x < $width; $x++)
        {
            $scanline[] = imagecolorat($image, $x, $y) & 0xFF;
        }

        while (count($scanline) < $bytesPerLine)
        {
            $scanline[] = 0;
        }

        $encoded = encode_pcx_scanline($scanline);
        if (fwrite($handle, $encoded) !== strlen($encoded))
        {
            fclose($handle);
            return false;
        }
    }

    if (fwrite($handle, chr(0x0C)) !== 1)
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

    fclose($handle);
    return true;
}

if ($argc < 3)
{
    fail("Usage: php png2pcx.php <input.png> <output.pcx>");
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

$width = imagesx($image);
$height = imagesy($image);
if (($width != 320 || $height != 200) && ($width != 640 || $height != 400))
{
    imagedestroy($image);
    fail("Unsupported PNG size " . $width . "x" . $height . "; expected 320x200 or 640x400");
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

if (!write_pcx_file($image, $outputFile))
{
    imagedestroy($image);
    fail("Unable to write PCX file: " . $outputFile);
}

imagedestroy($image);
