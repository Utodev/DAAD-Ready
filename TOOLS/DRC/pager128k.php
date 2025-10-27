<?php

// The parameters could be -v to set $verbose true, -s to show page summary

$verbose = false;
$summary = false;
foreach ($argv as $arg) 
{
    if ($arg == '-v') {
        $verbose = true;
    } elseif ($arg == '-s') {
        $summary = true;
    }
}

function dexhexplus($value) 
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
// XMB data

// Prepend a new value 1 to the $pages array
array_unshift($pages, 1);
// Prepend a new value 6912+512 to the $offsets array
array_unshift($offsets, 6912 + 512);
// Prepend a new empty array to the $pagecontent array
array_unshift($pagecontent, array());
// Prepend new page size
array_unshift($pagesizes, 16384); // Page 1 is also 16384 bytes


// Find the file with DDB extension in the folder
$ddbFile = glob('*.DDB');
if (count($ddbFile) != 1) 
{
    error("There is not a DDB file in the folder, or there are more than one.");
}
$ddbsize = filesize($ddbFile[0]);
$ddbEnd = $ddbsize + 0x8400; // The DDB file ends at 0x8400 bytes, so we need to reserve space for it
if ($ddbEnd >= 0xC000) $spareOffset = $ddbEnd - 0xC000; else $spareOffset = 0;

/*
// Prepend a new value 1 to the $pages array
array_unshift($pages, 0);
// Prepend a new value 6912+512 to the $offsets array
array_unshift($offsets, $spareOffset  + 1);
// Prepend a new empty array to the $pagecontent array
array_unshift($pagecontent, array());
// Prepend new page size
array_unshift($pagesizes, 16384 - 2501); // Page 0 is a bit smaller, beause the SDG and the images/pages table are at the end.The SDG is 2099 bytes long, with 2501 there is room for the pages (7 bytes) and 79 images.


// Append a new value 0 to the $pages array
$pages[] =  0;
// Prepend a new value 6912+512 to the $offsets array
$offsets[] = $spareOffset; // The spare offset is the space we have reserved for the DDB file
// Append a new empty array to the $pagecontent array
$pagecontent[] = array();
// Append new page size
$pagesizes[]= (16384 - 2501); // Page 0 is a bit smaller, beause the SDG and the images/pages table are at the end.The SDG is 2099 bytes long, with 2501 there is room for the pages (7 bytes) and 79 images.
*/





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
        if ($verbose) echo "{$file->filename} size " . dexhexplus(strlen($fileData)) . "h bytes at offset " .dexhexplus($file->offset +0xC000) ."h\n";
    }    
    fclose($outputFile);
}

if ($summary)
{
    echo "128K RAM Summary\n";
    echo "----------------------------------\n";
    for($i=0;$i<count($pages);$i++)
    {
        echo "Bank {$pages[$i]}: " . str_pad(count($pagecontent[$i]),2,' ', STR_PAD_LEFT) . " files, " . str_pad($pagesizes[$i] - $offsets[$i], 5,' ', STR_PAD_LEFT). " bytes free.\n";
    }
    if ($ddbEnd < 0xC000)
    {
        echo "Bank 2:  0 files, " . str_pad(0xC000 - $ddbEnd, 5,' ', STR_PAD_LEFT). " bytes free. (Bank 2 is never used for images.)\n";
    }
    echo "----------------------------------\n";
}


// build the index file
$indexFile= array();
// first dump the page numbers that are used
foreach ($pages as $index=>$page) 
{
    if (sizeof($pagecontent[$index]) > 0) 
    {
        $indexFile[] = $pages[$index];
    }
}
// Now we have to move page 1 to the end of the index file
// as the index should have the pages with the XMB data first
if (sizeof($indexFile) > 0 && $indexFile[0] == 1) 
{
    // Move the first element to the end of the array
    $firstPage = array_shift($indexFile);
    $indexFile[] = $firstPage;
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
                $indexFile[] = $offset  & 0xFF; // Add the offset LSB                       
                $indexFile[] = ($offset >> 8) & 0xFF; // Add the offset MSB
                $indexFile[] = $file->size & 0xFF; // Add the size LSB
                $indexFile[] = ($file->size >> 8) & 0xFF; // Add the size MSB
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





