<?php


/* Format of .GRA file, is to be loaded aty offser C000h + 512 + 6912, from there there is

1 ) two bytes that say how long the file is minus 2, so the interpreter reads the first two bytes of the file and
knows hown many bytes to read justa after.

2) a table of 5 bytes per image:

Location : 1 byte
Offset: 2 byte (low byte first, high byte second)
DataSize: 2 byte (low byte first, high byte second). It's the size of the image data minus 7 bytes for the image file header

When location is 255, it means the end of the table, and does not have offset or size.

3) Then follows the image data.



*/ 

function syntax()
{
    echo "PLUS3CAHE 1.0 - Creates DAAD Cached Graphics File (DAAD.GRA) for Spectrum +3\n\n";
    echo "SYNTAX: PLUS3CACHE <input file name>\n\n";
    echo "The input file name must be text file with a list of files Spectrum +3 DAAD image files (one line each). Image files must be in the same folder as the input file.\n";
    echo "The output file will be created as DAAD.GRA in the current folder.\n";
    echo "Please notice the files in the input file will be deleted after the output file is created.\n";
    exit(0);
}

function error($message)
{
    echo "Error: $message\n";
    exit(1);
}


// MAin
if ($argc < 1) 
{
    syntax();
    exit(1);
}

$inputFile = $argv[1];
if (!file_exists($inputFile)) error ("Input file '$inputFile' does not exist.\n");

$lines = file($inputFile,FILE_SKIP_EMPTY_LINES);
$filenum = count($lines);
if ($filenum == 0) error("Input file '$inputFile' is empty.");
$outputFile = array(0,0); // 2 bytes for the header, we will rewrite here the remaining size of the file  (filesize - 2 ) later
// Calculate the address where the image data will be loaded, after the content table
$RAMOffset  = 0xC000 + 512 + 6912 + 5 * sizeof($lines)  + 1; // 512 bytes for RAMSAVE, 6912 bytes for PictureBuffer + 5 bytes per each fil in the table (locno, length, offset) + 1 byte for the end of the table

// Prepare the content table first
foreach ($lines as $line)
{
    $parts = explode('.', $line);
    $locno = intval(trim($parts[0]));
    if ($locno < 0 || $locno >= 255) error("Invalid locno '$locno' in line: $line. It must be between 0 and 254.");
    $line = trim($line);
    $size = filesize($line);
    if ($size === false) error("Could not get size of file '$line'.");

    $outputFile[] = $locno;

    $outputFile[] = $RAMOffset & 0xFF; // low byte of offset
    $outputFile[] = ($RAMOffset >> 8) & 0xFF; // high byte of offset

    $datasize = $size - 7; // the image file size minus 7 bytes for the header
    $outputFile[] = $datasize & 0xFF; // low byte of size
    $outputFile[] = ($datasize >> 8) & 0xFF; //

    $RAMOffset += $size; // increase the RAM offset by the size of the file
}

if ($RAMOffset > 0xFFFF) error("Total size of files exceeds available space for cached images. Please reduce the number of images to be cached or their sizes. Maximum cached size is 8960 bytes (8.75K).\n");
$outputFile[] = 255; // end of the table


// Now append the image data
foreach ($lines as $line)
 {
    //append all bytes of file $line to the otputFile array
    $fileContent = file_get_contents(trim($line));
    if ($fileContent === false) error("Could not read file '$line'.");
    foreach (str_split($fileContent) as $char)
        $outputFile[] = ord($char);
 }
 // Write the output file

$outputFileSize = count($outputFile); // subtract the 2 bytes for the header
$outputFileSizeForHeader = $outputFileSize - 2; // subtract the 2 bytes for the header
$outputFile[0] = $outputFileSizeForHeader & 0xFF; // low byte of size
$outputFile[1] = ($outputFileSizeForHeader >> 8) & 0xFF; // high byte of size
$outputFilePath = 'DAAD.GRA';
$handle = fopen($outputFilePath, 'wb');
if ($handle === false) error("Could not open output file '$outputFilePath' for writing.");
// write $outputFile array to the file, byte by byte

foreach ($outputFile as $byte) 
    {
        
        fputs($handle, chr($byte), 1);
    }

fclose($handle);



foreach ($lines as $line) unlink(trim($line)); // delete the input files
