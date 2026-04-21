<?php

$verbose = false;
$dumpIndexBackup= true;
// Ah, yes, this is not actually a "pager" as you cannot change pages in Spectrum 48k
// it's named like this as it does more or less the same pager128K does, but at a minor level

if ($argc != 2) {
    echo "Usage: php pager48k.php <ddbFile>\n";
    exit(1);
}


$offsets = array();

if ($verbose) echo "Processing DDB file: {$argv[1]}\n";
$ddbsize = filesize($argv[1]);
$ddbEnd = $ddbsize + 0x8400; // The DDB file ends at 0x8400 bytes, so we need to reserve space for it
if ($ddbEnd >= 0xC000) $starAddress = $ddbEnd + 1; else $starAddress = 0xC000;
$page0MaxSize = 65536 - $starAddress -  2099 ; //2099 SDG size
$page0MaxSize -=6 ; // The page 0 offset and size, the pages table end mark and the images table end mark;

if (!is_numeric($starAddress) || $starAddress < 0xC000 || $starAddress > 0xFFFF) {
    die("Invalid start address: {$argv[1]}\n");
}


if ($verbose) echo "Remaining space for page 0 data: $page0MaxSize bytes\n";


$pagefile = "";

$currentAddress = $starAddress;

// STEP 1 ******* take the image parts as .zx0 , and create the page 0 file with the image data. Note down offsets for each image. ****

$folder = '.';
for ($imagenumber=0; $imagenumber <= 255; $imagenumber++) 
{
    $filename  =$imagenumber;
    while (strlen($filename) < 3) $filename = '0' . $filename;

    if (file_exists("$folder/$filename.SCR")) 
    {
        $imageData = "";

        // Join pieces of the file
        foreach (glob("$folder/" . $filename . "_*.zx0") as $blockFile) 
        {
            $blockData = file_get_contents($blockFile);
            $blockSize = strlen($blockData);
            $blockOffset = (int)explode('_', pathinfo($blockFile, PATHINFO_FILENAME))[1];
            $imageData .= pack('v', $blockOffset) . pack('v', $blockSize) . $blockData;
        }

        if (strlen($imageData) > $page0MaxSize + 3)  // +3 as we need 3 bytes in the table per image added
        {   
            echo "Warning: Image $imagenumber is too big to fit. Size: " . strlen($imageData) . " bytes, remaining bytes: " . ($page0MaxSize - 3) . " bytes\n";
            continue;
        }
        else
        {
            // add a word 0 at the end of the file to mark the end of the blocks
            $imageData .= pack('v', 0);
            $offsets[$imagenumber] = new stdClass();
            $offsets[$imagenumber]->offset = $currentAddress;
            $offsets[$imagenumber]->size = strlen($imageData);
            $pagefile .= $imageData;
            //if ($verbose) echo "Added image $imagenumber to page 0 data, size: " . strlen($imageData) . " bytes\n";
            $currentAddress += strlen($imageData);
            $page0MaxSize -= (strlen($imageData) + 3); // 3 bytes per image in the table
        }
    }
}

file_put_contents('PAGE0.TMP', $pagefile);

// STEP 2 *********** create the index file *****************

if (file_exists('INDEX.BIN')) unlink('INDEX.BIN');

$indexFile = [];

$page0Size = strlen($pagefile);
$spareOffset = $starAddress; // The load address for page 0

if ($verbose) echo "Page0 load address : " . strtoupper(dechex($spareOffset)) . " bytes\n";
if ($verbose) echo "Page0 data size    : " . strtoupper(dechex($page0Size)) . " bytes\n";

//We stack these two word values with bytes reversed as they will be dumped backwars to the file

$indexFile[] = ($spareOffset >> 8) & 0xFF; // Add the offset MSB for page 0
$indexFile[] = $spareOffset & 0xFF; // Add the offset LSB for page 0

$indexFile[] = ($page0Size >> 8) & 0xFF; // Add the size MSB for page 0
$indexFile[] = $page0Size & 0xFF; // Add the size LSB for page 0

$indexFile[] = 0xFF; // Mark of no more pages for the pages table

for ($imagenumber=0; $imagenumber <= 255; $imagenumber++) 
{
    $filename  =$imagenumber;
    while (strlen($filename) < 3) $filename = '0' . $filename;

    if (file_exists("$folder/$filename.SCR")) 
        {
            if (!array_key_exists($imagenumber, $offsets)) continue; // There was no room for this image in page 0

            $indexFile[] = $imagenumber;
            if ($verbose) echo "Indexing image $imagenumber at offset " . strtoupper(dechex($offsets[$imagenumber]->offset)) . "\n";
            // Again, we dump the offset with bytes reversed as they will be dumped backwars to the file
            $indexFile[] = ($offsets[$imagenumber]->offset >> 8) & 0xFF; // Add the offset MSB
            $indexFile[] = $offsets[$imagenumber]->offset  & 0xFF; // Add the offset LSB                       
        }
}

$indexFile[] = 0xFF; // mark of no more images

$indexFile = array_reverse($indexFile);
$indexFileName = 'INDEX.BIN';
$outputFile = fopen($indexFileName, 'wb');

foreach ($indexFile as $value) 
{
    fwrite($outputFile, pack('C', $value));
}
fclose($outputFile);


if ($dumpIndexBackup)
{
    $indexFile = array_reverse($indexFile);
    $indexFileName = 'INDEX.BCK';
    $outputFile = fopen($indexFileName, 'wb');
    foreach ($indexFile as $value) 
    {
        fwrite($outputFile, pack('C', $value));
    }
    fclose($outputFile);
}
