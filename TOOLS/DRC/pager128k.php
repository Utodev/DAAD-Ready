<?php

// The parameters could be -v to set $verbose true, -s to show page summary, -v dumps a copy of the pages / images index as  INDEX.BCK

$verbose = false;
$summary = false;
$dumpIndexBackup = false;
foreach ($argv as $arg) 
{
    if ($arg == '-v') {
        $verbose = true;
    } elseif ($arg == '-s') {
        $summary = true;
    }
     elseif ($arg == '-b') {
        $dumpIndexBackup = true;
    }
}

function dechexplus($value) 
{
    $hex = dechex($value);
    if (strlen($hex) < 4) $hex = '0' . $hex; // Pad with zero if needed
    return strtoupper($hex);
}


function getFileFromFile($inputFilename, $outpuFilename, $start, $length) 
{
    $inputFile = fopen($inputFilename, "rb");
    fseek($inputFile, $start);
    $data = fread($inputFile, $length); 
    fclose($inputFile);
    
    $outputFile = fopen($outpuFilename, "wb");
    fwrite($outputFile, $data);
    fclose($outputFile); 
}

function error($message) 
{
    echo "Error: $message\n";
    exit(1);
}

// ************************************************ main() ***************************************

$pages = array(3,4,6,7);  // Pages available
$offsets= array(0,0,0,0); // Offset where to write the files in each page
$pagesizes = array(16384, 16384, 16384, 16384); // Size of each page
$pagecontent = array(array(),array(),array(),array()); // files already assigned to each page

// First, we need to put the content of the 0.XMB file
// All the parts must be at offset 0, in their pages so we add them first 
$xmb_file= '0.XMB';
if (!file_exists($xmb_file)) 
{
    file_put_contents($xmb_file, ''); // Create empty file if it does not exist
}
if ($xmb_file)
{
    $xmb_parts = array();
    $xmb_filesize = filesize($xmb_file);
    for ($i=0;$i<=3;$i++)    
    if ($xmb_filesize > 16384 * $i) 
    {
        $partFilename = "{$i}.PT";
        getFileFromFile($xmb_file, $partFilename, 16384*$i, 16384);
        $obj = new stdClass();
        $obj->filename = $partFilename;
        $obj->offset = $offsets[$i];
        $obj->page = $pages[$i];
        $obj->size = filesize($partFilename);
        $offsets[$i] = $obj->size; // Signal that that page has some content now
        $pagecontent[$i][] = $obj;
    }
}



// Now, we finnd all files with the 128 extension in IMAGES folder
// and generate the $imagefileNames and $imagefileSizes arrays
$imageFiles = glob('IMAGES/*.128');
$numImages = count($imageFiles);
$imagefileSizes = array();
$imageHashes = array();
foreach ($imageFiles as $imageFile) 
{
    $basename = basename($imageFile);
    $filesize = filesize("IMAGES/" . $basename);
    $imagefileSizes[$basename] = $filesize;
    $hash = sha1_file("IMAGES/" . $basename); 
    $repeated = false;
    foreach ($imageHashes as $filename=>$oldhash)
    {
        if ($oldhash == $hash) 
        {
            echo "WARNING: Images {$basename} and {$filename} seem to be the same image. You can save space by removing one of them and using DAAD code to do the replacement.\n";
            $repeated = true;
        }
    }
    if (!$repeated) $imageHashes[$basename] = $hash;
}

// Now we put page 1 in game. We couldn't put it before because 
// page 1 is not empty, and we neededed empty pages for the
// XMB data.

// Append a new value 1 to the $pages array
$pages[] =  1;
// Prepend a new value 6912+512 to the $offsets array
$offsets[] = 6912 + 512; // space after the PictureBuffer and the RAMSAVE
// Append a new empty array to the $pagecontent array
$pagecontent[] = array();
// Append new page size
$pagesizes[]= 16384; // Page size is full size, although default offset is not 0



// Find the file with DDB extension in the folder
$ddbFile = glob('*.DDB');
if (count($ddbFile) != 1) 
{
    error("There is not a DDB file in the folder, or there are more than one.");
}
$ddbsize = filesize($ddbFile[0]);
$ddbEnd = $ddbsize + 0x8400; // The DDB file ends at 0x8400 bytes, so we need to reserve space for it
if ($ddbEnd >= 0xC000) $spareOffset = $ddbEnd - 0xC000  + 1; else $spareOffset = 0;

// Append a new value 0 to the $pages array
$pages[] =  0;
// The spare offset is the space we have reserved for the DDB file
$offsets[] = $spareOffset; 
// Append a new empty array to the $pagecontent array
$pagecontent[] = array();
// Append new page size

$page0UsedSpace = 2099; // The SDG is 2099 bytes long, 
$page0UsedSpace += $numImages * 6 + 1; // the table of image/page/offset of each image, plus the end marker
$page0UsedSpace += 4; // Add 4 bytes for the page 0 size and offset
$page0UsedSpace += sizeof($pages) + 2; // Add the size of the pages array and the end marker (worst case, all pages used)
$pagesizes[]= (16384 - $page0UsedSpace); 


arsort($imagefileSizes);

// Now we iterate over the $imagefileSizes array, which is alreadu sorted so the
// largest files are first, and we try to assign them to the pages. Ww use the same
// page until there is no room for the file, then we try the next page. Once file
// is assigned, we update the offset of the page and continue with the next file.



foreach ($imagefileSizes as $filename=>$filesize)
{
    for ($i=0;$i<count($pages);$i++)
    {
        if ($offsets[$i] + $filesize <= $pagesizes[$i]) // If the file fits in the page
        {
            // Assign the file to the page
            $obj = new stdClass();
            $obj->filename = $filename;
            $obj->offset = $offsets[$i];
            $obj->page = $pages[$i];
            $obj->size = $filesize;
            $pagecontent[$i][] = $obj;
            $offsets[$i] += $filesize; // Update the offset of the page
            break; // Break the for loop, we have assigned the file
        }
    }
    if ($i == count($pages)) 
    {
        // If we have not assigned the file to any page, it means there is no room for it
        // so we stop the process and show an error message
        error("There is no room for the image {$imagefileNames[$filename]} with size $filesize in any page.");
    }
}


// Dump the content to PAGEn.TMP files
foreach ($pagecontent as $page => &$files) 
{
    if (count($files) == 0) continue; // Skip empty pages
    $outputFilename = "PAGE{$pages[$page]}.TMP";
    $outputFile = fopen($outputFilename, 'wb');
    if ($verbose) echo ">> Page {$pages[$page]} [" . count($files) . " files]\n";
    foreach ($files as $file) 
    {
        // if file has 128 extension, then prepend the filename with IMAGES/
        if (substr($file->filename, -4) == '.128') {
            $file->filename = 'IMAGES/' . $file->filename;
        }
        $fileData = file_get_contents($file->filename);
        fwrite($outputFile, $fileData);
        if ($verbose) echo "{$file->filename} size " . dechexplus(strlen($fileData)) . "h bytes at offset " .dechexplus($file->offset +0xC000) ."h\n";
    }    
    fclose($outputFile);
}

if ($summary)
{
    echo "128K RAM Summary\n";
    echo "----------------------------------\n";
    for($i=0;$i<8;$i++)
    {
        //searh i in values of $pages
        if (in_array($i, $pages)) 
        {
            $index = array_search($i, $pages);
            echo "Bank {$pages[$index]}: " . str_pad(count($pagecontent[$index]),2,' ', STR_PAD_LEFT) . " files, " . str_pad($pagesizes[$index] - $offsets[$index], 5,' ', STR_PAD_LEFT). " bytes free.\n";
        }
        else if ($i==5) 
        {
            // Bank 5 is not used, so we show it as empty
            echo "Bank 5:  0 files, " . str_pad(0, 5,' ', STR_PAD_LEFT). " bytes free. (Used by the screen and the interpreter)\n";
        }
        else if ($i==2)
        {
            if ($ddbEnd < 0xC000)
            {
                echo "Bank 2:  0 files, " . str_pad(0xC000 - $ddbEnd, 5,' ', STR_PAD_LEFT). " bytes free. Partially used by the DDB \n";
            }
            else
            {
                echo "Bank 2:  0 files, " . str_pad(0, 5,' ', STR_PAD_LEFT). " bytes free. Fully used by the DDB.\n";
            }
        }
    }
echo "----------------------------------\n";

}


// build the index file


$indexFile= array();


// First there is the page 0 offset and size, which is set to zeo if  page 0 was not used for images

// Calculate page 0 images size (find images stored at page 0, determine where thee last one ends, and substract $spareOffset)
$page0Size = 0;
foreach ($pagecontent[array_search(0,$pages)] as $file)
{
    if ($file->page == 0) 
    {
        if ($page0Size < $file->offset + $file->size) 
        {
            $page0Size = $file->offset + $file->size;
        }
    }
}

$page0Size = $page0Size - $spareOffset; // Substract the spare offset, as it is not used for images

// These two are dumped little endian, so when written upside down in the list they are in the right order
$indexFile[] = ($page0Size >> 8) & 0xFF; // Add the size MSB for page 0
$indexFile[] = $page0Size & 0xFF; // Add the size LSB for page 0
$spareOffset = $spareOffset + 0xC000; // The offset for page 0 really starts at 0xC000
$indexFile[] = ($spareOffset >> 8) & 0xFF; // Add the offset MSB for page 0
$indexFile[] = $spareOffset & 0xFF; // Add the offset LSB for page 0


if ($verbose) 
{
    echo "Page 0 offset: " . dechexplus($spareOffset) . "h bytes.\n";
    echo "Page 0 size: " . dechexplus($page0Size) . "h bytes.\n";
}


// then dump the page numbers that have been used
foreach ($pages as $index=>$page) 
{
    if (sizeof($pagecontent[$index]) > 0) 
    {
        $indexFile[] = $pages[$index];
    }
}

$indexFile[] = 255; // End of index marker

// Put all content in one single array sorted by image file name
$linearContent = array();
foreach ($pagecontent as $page => &$files) 
    foreach ($files as $file) 
        if (substr($file->filename, -4) == '.128')  $linearContent[] = $file;


for($i=0;$i<255;$i++)
{
    $filename = 'IMAGES/' . sprintf('%03d.128', $i);
    foreach ($linearContent as $file) 
    {
            if ($file->filename == $filename) 
            {
                // We have found the file, now we can add it to the index
                $indexFile[] = $i; // Add the image number
                $offset = $file->offset;
                $offset += 0xC000; 
                $size = $file->size;
                $indexFile[] = $offset  & 0xFF; // Add the offset LSB                       
                $indexFile[] = ($offset >> 8) & 0xFF; // Add the offset MSB
                $indexFile[] = $size & 0xFF; // Add the size LSB
                $indexFile[] = ($size >> 8) & 0xFF; //
                $indexFile[] = $file->page; // Add the page number
            }
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




