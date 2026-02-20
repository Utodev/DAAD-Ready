<?php

    // This DAT generator is meant to be used with Amiga and Atari ST targets only (or any compatible as ADP)

    /* 
    
    JSON file format
    ================

    img2daad allows parameters for specific images to be provided using a JSON file with the same name as the image, but with .JSON extension.

    Posible properties:

    float:0-1   -> 0 = fixed image, 1 = float image , defaults to float: 0
    buffer:0-1  -> 0 = no buffer, 1 = buffer , defaults to buffer: 0

    X:0-319 -> Fixed image X position, ignored by classic interpreters if float=1
    Y:0-199 -> Fixed image Y position, ignored by classic interpreters if float=1

    PCS:0-15 -> Palette Start Color, palette for colours below this one are not apllied. Ignored by classic interpreters if float=1. Defaults to 0
    PCE:PCS-15 -> Palette End Color, ignored by classic interpreters if float=1. Defaults to 15

    clone: 0-1 -> Clones image from another location, if 1, location must be specified, defaults to 0
    location: 0-255 -> mandatory if clone=1, this is the location to clone from
    
    Example:
    {"X":24,"Y":180,"PCS":0,"PCE":15}
    {"float":1,"buffer":1, "width":120, "height":96}
    {"float":1}
    {"clone":1,"location":8} // Clones location 0, which must be already loaded


    Notes: 
    
    - Notice that in order for a JSON to be read, there should be a picture with the same number (i.e. 007.PNG  for 007.JPG, so even if 
      you are going to clone, there should be a picture that won't be loaded into de graphics file anyway, so it may be any dummy picture)
    - If float, neither X, Y nor PCS, PCE are used, so their values doesn't matter. They will be added to the DAT file though, but original interpreters
      ignore them (maybe new interpreters will use them, who knows?).
    - There are obnvious incompatibilities using some parameters with others (i.e. use clone and float together makes no sense), but no checks are done, 
      so be careful when using them.

   

   DAT/DMG file format
   ===================

    First there is a global header:

    2 bytes     Signature (0x0300 for the Amiga and ST versions)
    2 bytes     Screen mode (0=low res 320x200, 1=medium res 640x200, 2=high res 640x400)
    2 bytes     Number of pictures
    4 bytes     File size

    Then, there is a locations table, with 256 entries of 48 bytes each (12288 bytes). This stores general about the picture, plus the offset to the pixel data.
    The locations table has entries for 256 elements, no matter how many pictures are in the file, unused entries are just zeroed.

    4 bytes     Offset to pixels data
    2 bytes     Flags (defined somewhere below in this same file)
    2 bytes     X position (or sample frequency for SFX)
    2 bytes     Y position
    1 byte      Palette start color
    1 byte      Palette end color
    32 bytes    Palette (16 words)
    4 bytes     CGA palette signature (0xDAADDAAD) for Amiga 12 bit palette files

    Finally at the location pixels data:

    2 bytes     Width (bit 15 = compressed flag)
    2 bytes     Height (bit 15 = audio mode flag)
    2 bytes     Data size
    n bytes     Pixel data

    If compressed flag is set, data is compressed with a RLE algorithm, first 16 bits of the Pixel data are the mask (a bitwise map of which colours 0-15 are compressed or not).
    Then the compressed data follows. Please notice if a color is compressed, then all pixels of that color are compressed, not just those where compression is effective. DMG
    was precalculating if compression would be globally effective or not for each color before applying it.

    If not compressed, the pixel data is just the planar representation of the image.
*/ 

define('CLIPWIDTH',320); // whole width
define('NUM_PLANES',4);
define('BYTES_PER_LINE',160);
define('VERSION','2.0');

$verbose = false;

include_once('png.php');
include_once('degas.php');
include_once('wav.php');

function error($errorMsg)
{
    echo "$errorMsg\n";
    exit(1);
}

function syntax()
{
    echo "IMG2DAAD ".VERSION." - Creates DAAD Graphic Databases for Atari ST and Amiga\n\n";
    echo "SYNTAX: IMG2DAAD <folder>{;folder} [outputfile] [-c] [-a] [-v] [-<lines>]\n\n";
    echo "<folder>     : folder where to look for .PI1 or .PNG images. You can add several folders, just concatenate with semicolon as separator \n";
    echo "[outputfile] : file name for the output database, if absent, PART1.DAT will be used.\n";
    echo "-c           : compress images\n\n";
    echo "-a           : generate Amiga 12 bit palette file. Requires patched interpreter, if you are no using 12 bit palette you can use same DAT file for Amiga, and use original interpreters.";
    echo "-v           : verbose mode, shows more information about what is being done.\n\n";
    echo "-<lines>     : img2daad defaults to create pictures 96 pixel height, but you can change that with this parameter, just write -100 to create 100 pixel height pictures, for example.\n\n";
    echo "Please notice PNG images can have any format, but must be 320x200, and use a maximum of 16 colours.\n";
    echo "Specific details can be given to each image using a JSON file with the same name as the image, but with .JSON extension. The details of the JSON file are explained in the php file itself, read the comment on top.\n";
    
    exit(0);
}

function dumpDatabase($outputFile, $outputFilename)
{
    $fp  = fopen($outputFilename, 'w');
    if ($fp) 
    {
        for ($i=0;$i<sizeof($outputFile);$i++)
        fwrite($fp, chr($outputFile[$i]), 1);
    }
    fclose($fp);
}

/* Notes about the 12 bit and 9 bit palettes:

The DAAD interpreters for Amiga and ST were made to use the standard Atari ST mode, 16 colors from a palette of 512 (3 bits
per component). When img2daad was created, someone noticed in a game (Los Elfos de Maroland), the ST version graphics were 
better than the Amiga. That was because of some reasons:

1) He was actually testing in an Atari STe, which uses still 16 colors, but from a palette of 4096 (4 bits per component)
2) The Degas .PI1 files used to create the DAT file were also for STe (4 bits)
3) img2DAAD just passes the palette to the DAT file as it was coming (that is, 4 bits, so 4 bits remained in the DAT file)
3) The Atari interpreter takes the 4 bits in the palette and sends them to the graphic chip, without deleting the 4th

Sadly, the Amiga interpreter was cropping the 4th bit before sending it to the graphic chip, so despite the DAT file had
4 bits, only 3 went to the screen, and as a result, the Amiga graphics looked poorer.

To fix that, the Amiga interpreter had to be patched. After some debugging, the code that removed the 4th bit was found:

lsl.w #1, d0
and.w #$0eee, d0

A fast way to avoid that to happen was replacing that code with 

nop
and.w #$0fff, d0

That code, in the binary, was easy to find by looking for this hex string:

3010 e348 0240 0eee 30c0

The e348 is the lsl, and the 0240 0eee is the and. 3010 and 30c0 are added to avoid matching something else. What we need to do is
replacing  e348 with 4e71 (NOP) and 0eee with  0fff. When that is done, the interpreter is patched an the 4 bit palette goes through.
This has been succesfuly patched on EDI1 and SDI1, not tested in the other multipart interpreters, but same code would probably be found.

Is that all? Sadly not. When the 4 bit palette went trough, the Amiga interpreter was showing a chaos of colors in the screen. After 
analyzing it, there are historical reason why a Degas file comes with a nibble per RGB component for the palettte, like xRGB, but inside
each component, one would expect this at bit level:

x x x x R3 R2 R1 R0 - G3 G2 G1 G0 - B3 B2 B1 B0

but you find this:

x x x x R0 R3 R2 R1 - G0 G3 G2 G1 - B0 B3 B2 B1

This is to allow software made for ST to work fine in STe, but it's affecting us when trying to work with the Amiga.

The solution for that is adding a new parameter "-a" (a for Amiga) to img2DAAD, that ensures that when Degas file, with its "twisted" palette data
is read, img2daad rearranges data so it's as Amiga would expect it. That means if you use 4 bit colours, then the Amiga and Atari ST DAT files
cannot be the same. Not that much of a problem, as now with img2daad that is automated.
*/


// Converts Degas twisted bits palette in normal one, byte per byte (as expeceted by the Amiga)
function normalPalette($aByte)
{
    //echo "(" . decbinn($aByte) . " => ";
    $aByteLowNibble = $aByte & 0xF;
    $aByteHighNibble = ($aByte & 0xF0) >> 4;
    $aByteLowNibble = (($aByteLowNibble << 1) & 0xF) + (($aByteLowNibble >> 3) & 1);
    $aByteHighNibble = (($aByteHighNibble << 1) & 0xF) + (($aByteHighNibble >> 3) & 1);
    $aByte = $aByteLowNibble + ($aByteHighNibble << 4);
    //echo decbinn($aByte) . ") ";
    return $aByte;
}



// Takes an uncompressed screeen data array (Degas style) and returns a compressed version array (or the same 
// if compression is not effective). Variable $clipdata isthe in uncompressed data, provided only so it can be
//  returned if compression is not effective
function getCompressedData($clipdata, $screen, $width, $height, $verbose)
{
    // Largely based on ADP's code for dmg_tool by José Luis Cebrián

    // First just take the pixels we need (according to width and height provided), and considering the original is 320x200
    $pixels = [];
    for ($y=0;$y<$height;$y++)
        for ($x=0;$x<$width;$x++)
            $pixels[] = $screen[$y*320 + $x];

    // let's calculate which colors are to be compressed or not
    $uncompressedColorSize = array_fill(0, 16, 0); // To store how much each color would take if compressed
    $compressedColorSize = array_fill(0, 16, 0); // To store how much each color would take if compressed

    $totalCompressedSize = 0;
    $totalUncompressedSize = (count($pixels) + 1)/2;
    

	// measure the size of the compressed stream
    $pixelCount = count($pixels);
    $n = 0;
    while ($n < $pixelCount)
    {
        $color = $pixels[$n];
        $repeat = 1;
        $n++;
        while (($repeat < 16) && ($n < $pixelCount) && ($pixels[$n] == $color))
        {
            $repeat++;
            $n++;
        }
        $compressedColorSize[$color] += 2;
        $uncompressedColorSize[$color] += $repeat;
    }

    // The compression mask, will have each bit set if that color is compressed (i.e. if color 4 is compressed, bit 4 will be 1, and if colour 7 is not compressed, bit 7 will be 0)
    $mask = 0; 
    for  ($n = 0; $n < 16; $n++)
    {
        if ($compressedColorSize[$n] < $uncompressedColorSize[$n])
        {
            $mask |= 1 << $n;
            $totalCompressedSize += $compressedColorSize[$n];
        }
        else
        {
            $totalCompressedSize += $uncompressedColorSize[$n];
        }
    }

	// Adjust sizes from nibble counts to final buffer sizes
    $totalCompressedSize = floor(($totalCompressedSize + 1)/2);
    $totalCompressedSize = 2 + (($totalCompressedSize + 3) & ~3);
    $totalUncompressedSize = sizeof($clipdata);

	// Return an uncompressed image if it's not worth to compress
    if ($totalCompressedSize >= $totalUncompressedSize) 
    {
        echo "Compression not effective, this image won't be compressed.\n";
        return $clipdata;
    }
    echo "Compression saved " . ($totalUncompressedSize - $totalCompressedSize) . " bytes.\n";

	// Return a compressed image, with the nibble stream
	// packed in 32-bit words (big endian) right to left 
    $buffer = []; // output buffer

    // write the mask
    $buffer[] = ($mask & 0xFF00) >> 8;
    $buffer[] = $mask & 0xFF; 
        
    //write the compressed data
	$nibblecount = 0;
	$value32 = 0;
	for ($pixelPtr = 0; $pixelPtr < $pixelCount; ) // for loop does not increment pixelPtr, it's done inside in different places
	{
		$color = $pixels[$pixelPtr++];

		$value32 |= $color << ($nibblecount * 4);
		if (++$nibblecount == 8) // if we already have 8 nibbles, dump the dword before proceeding
		{
            $buffer[] = ($value32 & 0xFF000000) >> 24;
            $buffer[] = ($value32 & 0x00FF0000) >> 16;
            $buffer[] = ($value32 & 0x0000FF00) >> 8;
            $buffer[] = $value32 & 0x000000FF;
			$nibblecount = $value32 = 0;
		}
		if ($mask & (1 << $color)) // If this color is compressed, we add the repeat count nibble just after the color nibble
		{
			$repeats = 0;
			while (($pixelPtr < $pixelCount) && ($pixels[$pixelPtr] == $color) && ($repeats < 15))
            {
                    $pixelPtr++;
                    $repeats++;
            }
			
			$value32 |= $repeats << ($nibblecount * 4);
			if (++$nibblecount == 8)
			{
                $buffer[] = ($value32 & 0xFF000000) >> 24;
                $buffer[] = ($value32 & 0x00FF0000) >> 16;
                $buffer[] = ($value32 & 0x0000FF00) >> 8;
                $buffer[] = $value32 & 0x000000FF;
				$nibblecount = $value32 = 0;
			}
		}
	}
	if ($nibblecount != 0)
	{
        $buffer[]= ($value32 & 0xFF000000) >> 24;
        $buffer[]= ($value32 & 0x00FF0000) >> 16;
        $buffer[]= ($value32 & 0x0000FF00) >> 8;
        $buffer[]= $value32 & 0x000000FF;
	}

    return $buffer;

}


// MAIN

if ($argc<2) syntax();

// Parse parameters
$outputFilename = 'PART1.DAT';
$compressed = false;
$verbose = false; // Verbose mode
$amigaDAT = false;
$dir = $argv[1];
$dirs = explode(';', $dir);
foreach($dirs as $dir)
    if (!is_dir($dir)) error ("Invalid folder: $dir");

for ($i=2;$i<$argc;$i++)
{
    $currentParam = $argv[$i];
    if (substr($currentParam, 0, 1) == '-')
    {
        if (strtoupper($currentParam) == '-C') $compressed = true;
        else if (strtoupper($currentParam) == '-A') $amigaDAT = true;
        else if (strtoupper($currentParam) == '-V') $verbose = true;
        else if (is_numeric(substr($currentParam, 1))) 
        {
            define('CLIPHEIGHT',intval(substr($currentParam, 1)));
            if ($verbose) echo "Setting clip height to " . CLIPHEIGHT . " pixels.\n";
        }
        else Error("Invalid param: $currentParam");
    }
    else if ($i==2) $outputFilename = $currentParam;
}

if (!defined('CLIPHEIGHT')) define('CLIPHEIGHT',96); // default clip height

if ($verbose) echo "IMG2DAAD ".VERSION." - DAAD DAT Maker for Amiga and Atari ST (C) 2026\n";

$outputFile = array();

if ($verbose) echo "Creating $outputFilename with" . ($compressed ? '':'out') . " compression.\n";


// The DAT file header

$outputFile[] = 0x03;
$outputFile[] = 0x00;  // Output signature 0x0300

$outputFile[] = 0x00;  
$outputFile[] = 0x00;  // Output screen mode (low res, 320x200)

$outputFile[] = 0x00;  
$outputFile[] = 0x00;  // Dummy for number of pictures

$outputFile[] = 0x00;  
$outputFile[] = 0x00;  
$outputFile[] = 0x00;  
$outputFile[] = 0x00;   // Dummy for filesize

// Fill the locations table with dummy

for ($i=0;$i<256;$i++)
    for ($j=0;$j<48;$j++)
        $outputFile[] = 0x00;

$files = array();
foreach ($dirs as $dir)
{
    $tempfiles = scandir($dir);
    foreach($tempfiles as $file)
    {
        $files[] = $dir . DIRECTORY_SEPARATOR . $file;
    }
}

$fileList = array();
foreach ($files as $file)
{
    $extension = strtoupper(explode('.',"$file.")[1]);
    if (($extension != 'PI1') && ($extension != 'PNG') && ($extension != 'JSON') && ($extension != 'WAV')) continue;
    $location = explode('.',"$file.")[0];
    $location = explode(DIRECTORY_SEPARATOR, $location)[sizeof(explode(DIRECTORY_SEPARATOR, $location))-1]; // Get the last part of the path
    if (strtoupper($location)=='DAAD') continue; // Skip loading screen if present
    if (!is_numeric($location)) error("Invalid location number in $file.");
    $location = intval($location);
    if (($location<0) ||($location>255)) error("Invalid location number in $file.");
    
    
    if (!array_key_exists($location, $fileList))
    {
        $obj = new stdClass();
        $fileList[$location] = $obj;
    }    

    
    if ($extension=='JSON') 
    {
        $fileList[$location]->hasJSON=true;
        $fileList[$location]->JSONfilename=$file;
        
    }
    else 
    if  ($extension=='WAV') 
    {
        $fileList[$location]->hasWAV=true;
        $fileList[$location]->WAVfilename=$file;
    }
    else
    if ($extension=='PI1') 
    {
        $fileList[$location]->hasPI1 = true;
        $fileList[$location]->PI1filename=$file;
    } 
    else 
    {
        $fileList[$location]->hasPNG = true;
        $fileList[$location]->PNGfilename=$file;
    } 
}

$imgsLoaded = array();
ksort($fileList, SORT_NUMERIC);

// Apparently, the mark of buffered images was only so DG knew which images to put first 
// in the DAT file, because the interpreter ignores it, and just loads ~96K of the DAT
// file in RAM, so only images placed first in the file are buffered.  Then, we have to
// find which images are buffered, and sort the fileList so they go first in the DAT file
// In fact, if no images are marked as buffered, still the first images in the file will 
// be buffered, something that is difficult to spot if the game runs from hard disk, but
// is obvious when running from floppy, as aside of the first buffered images, the rest
// will be loaded from disk each time they are needed.

// 1 - find buffered images
$bufferedImages = array();
foreach ($fileList as $location=>$fileData)
{
    if (property_exists($fileData, 'hasJSON') && ($fileData->hasJSON))
    {
        echo "Checking JSON for location $location ...\n";
        $json = json_decode(file_get_contents($fileData->JSONfilename));
        if (property_exists($json, 'buffer') && ($json->buffer==1))
        {
            $bufferedImages[] = $location;
        }
    }
}

// 2 - Now sort the $fileList so buffered images/samples go first
$sortedFileList = array();
foreach ($bufferedImages as $location)
{
    $sortedFileList[$location] = $fileList[$location];
    unset($fileList[$location]);
}
$fileList = $sortedFileList + $fileList;
foreach ($fileList as $location=>$fileData)
{


    if ( ((property_exists($fileData, 'hasPI1')) &&  ($fileData->hasPI1)) || ((property_exists($fileData, 'hasPNG')) &&  ($fileData->hasPNG))  || ((property_exists($fileData, 'hasWAV')) &&  ($fileData->hasWAV))) 
    {
        echo ">> Processing image/sample $location \n";
        $imgsLoaded[]=$location;

        if ((property_exists($fileData, 'hasPNG')) &&  ($fileData->hasPNG)) // PNG over PI1
        {
            $file = $fileData->PNGfilename;
            if ($verbose) echo "($file).\n";
            $degas = new pngFileReader();
            $result = $degas->loadFile($file, $verbose);
            if ($result!='') error($result);
        }
        else
        if ((property_exists($fileData, 'hasPI1')) &&  ($fileData->hasPI1)) // PNG over PI1
        {
            $file = $fileData->PI1filename;
            if ($verbose) echo "($file).\n";
            $degas = new degasFileReader(); 
            $result = $degas->loadFile($file);
            if ($result!='') error($result);
        }
        else
        {
            $file = $fileData->WAVfilename;
            if ($verbose) echo "($file).\n";
            $degas = new wavFileReader(); 
            $result = $degas->loadFile($file);
            if ($result!='') error($result);
        }

        
        // *** Fill the location data ***

        /*
        The picture definition is as follows:
        
        offset : Long
        Flags: Word    
        X: Word                ; For a sound sample holds the sample frequency, whcis is an indexed value, not the real frequency (see wav.php)
        Y: Word
        PCS: Byte              ; Palette Start Byte
        PCE: Byte              ; Palette End Byte
        PAL[16]: Word
        CGAPAL: long;


        Flag field bits:
     
        #define PFLOAT          0x01  ; 1 = is float image, 0=isfixed. If fixed X and Y are considered
        #define RESID           0x02  ; 1 = buffered image, 0= no buffer (defined as resident by the ST/Amiga source code)
        #define CGAP01          0x04  ; No idea
        #define HOTSP           0x08  ; No idea
        #define SAMPLE          0x10  ; Is a sound sample

        */

        $locationPrt = 0x0A + 48 * $location;
        $currentOffset  = sizeof($outputFile);

        // Offset to location pixels data
        $outputFile[$locationPrt] = ($currentOffset & 0xFF000000) >> 24;  
        $outputFile[$locationPrt + 1] = ($currentOffset & 0x00FF0000) >> 16;  
        $outputFile[$locationPrt + 2] = ($currentOffset & 0x0000FF00) >> 8;
        $outputFile[$locationPrt + 3] = $currentOffset & 0x000000FF;


        // Specific data for SFX samples
        if (property_exists($fileData,'hasWAV')) 
            {
                $outputFile[$locationPrt + 5] = 0x12; // Sound sample, so we set the sample bit
                $outputFile[$locationPrt + 6] = $degas->frequency >> 8; //MSB  
                $outputFile[$locationPrt + 7] = $degas->frequency & 0x00FF; //LSB
            }
            else
            {
                $outputFile[$locationPrt + 4] = 0x00;  
                $outputFile[$locationPrt + 5] = 0x04;  // Flags (no buffer, fixed)
                $outputFile[$locationPrt+6] = 0x00;  
                $outputFile[$locationPrt+7] = 0x00;   // X coord
                $outputFile[$locationPrt+8] = 0x00;  
                $outputFile[$locationPrt+9] = 0x00;   // Y coord
                $outputFile[$locationPrt+10] = 0x00;   // First palette color,filler as it's float
                $outputFile[$locationPrt+11] = 0x0F;   // Last palette color,filler as it's float

                // Polette
                $degas->seekFile(2);  // point to palette

                for($i=0;$i<32;$i++) 
                {
                    $val = $degas->readByte(); // read palette
                    if ($amigaDAT)  $val = normalPalette($val);
                    $outputFile[$locationPrt+12+$i] = $val;
                }
            }

        
        if ($verbose) echo "\n";

        if (($amigaDAT) && (!property_exists($fileData, 'hasWAV'))) // Exception for Amiga, we have add the DAAD signature to signal the file uses 4 bit palette
        {
            $outputFile[$locationPrt+44] = 0xDA;  
            $outputFile[$locationPrt+45] = 0xAD;   
            $outputFile[$locationPrt+46] = 0xDA;  
            $outputFile[$locationPrt+47] = 0xAD;   
        }


      
        if (property_exists($fileData,'hasWAV'))
        {
            // The mini header for the sample file
            echo "Processing sound sample $fileData->WAVfilename ...\n";

            // All sample files have a header like this in the Aventura Espacial DAT file
            $outputFile[] = 0;  
            $outputFile[] = 0;
            $outputFile[] = 0x80; 
            $outputFile[] = 0 ; 
            $datasize = $degas->sampleSize;
            $outputFile[] = $datasize  >> 8; //MSB
            $outputFile[] = $datasize & 0x00FF ; //LSB
            if ($verbose) echo "Data size: $datasize bytes\n";

            // The sample itself
            foreach($degas->fileContent as $byte)
            {
                $outputFile[] = $byte;
            }
        }
        else
        {    
            
            $compressThisFile = $compressed;
            if (property_exists($fileData, 'hasJSON') && ($fileData->hasJSON))
            {
                // A JSON can only be applied if a image has been loaded in that slot, or if the JSON is to clone a image
                $json = json_decode(file_get_contents( $fileData->JSONfilename));
                if (!$json) error ('Invalid JSON file: ' .$fileData->JSONfilename);
                if (property_exists($json, 'compress'))
                {
                    $compressThisFile = ($json->compress==1);
                    if ($verbose) echo "Overriding compression from JSON file: " . ($compressThisFile ? 'compressing':'not compressing') . "\n";
                }
            }


            $screen = array();
            for ($i=0;$i<32000;$i++) $screen[] = $degas->readByte(); // read 32.000 bytes of image data

            $linearScreen = $degas->linearScreen;

            $xs = 0;
            $ys = 0;
            $width = CLIPWIDTH;
            $height= CLIPHEIGHT; 
            
            // Check for specific width and height
            if (property_exists($fileData, 'hasJSON') && ($fileData->hasJSON))
            {
                $json = json_decode(file_get_contents($fileData->JSONfilename));
                if (!$json) error ('Invalid JSON file: ' .$fileData->JSONfilename);
                if (property_exists($json, 'width')) $width = intval($json->width);
                if (property_exists($json, 'height')) $height = intval($json->height);
            }

            $originalWidth = $width;
            // Prepare the uncompressed pixel data array, planar, etc.
            // From now on, this is a copy of Tim Gilberts's code, which honestly I haven't even
            // tried to understand,  basically because it worked out of the box :-)

            $co = 0;
            $xs = $xs>>3; // Convert to a column number 
            $width = $width>>3;

            $length = $width * $height * NUM_PLANES; // 4 = number of planes
            $lo=$ys * BYTES_PER_LINE;
            $cs = ($xs>>1) * (NUM_PLANES<<1) + ($xs & 1); 

            for($l=0;$l<$height;$l++)
            {
                $cp = $cs;
                for($c=0;$c<$width;$c++)
                {
                    for($p=0;$p<NUM_PLANES;$p++)
                    $clipdata[$co++] = $screen[$lo + $cp + ($p<<1)];
                    $cp++;
                    if(($cp & 1)==0) $cp += (NUM_PLANES-1)*2; // Skip plane data 
                }
                $lo += BYTES_PER_LINE;
            }
            // Tim Gilbert's code ends here

            // Let's dump the pixels data now

            $thisImageCompressed = $compressThisFile;
            $datasize = sizeof($clipdata);
            if ($verbose) echo "Data size: $datasize bytes\n";
            if ($thisImageCompressed) 
            {
                $clipdata = getCompressedData($clipdata, $linearScreen,  $originalWidth, $height, $verbose);
                if ($verbose) echo "Compressed data size: " . sizeof($clipdata) . " bytes\n";
                if ($datasize == sizeof($clipdata))  // If we detect the returned array is the same clipdata, then compression was not effective
                    {
                        if ($verbose) echo "Compression not effective, storing uncompressed image.\n";
                        $thisImageCompressed = false;
                    }
            }
            
            // Let's dump the mini header now
            
            // Width  and compressed flag
            if ($thisImageCompressed) $finalWidth = $originalWidth | 0x8000; else $finalWidth = $originalWidth; // Mark as compressed is setting the highmost bit in the width field
            $outputFile[] = $finalWidth  >> 8; //MSB
            $outputFile[] = $finalWidth & 0x00FF ; //LSB

            // Height
            $outputFile[] = $height  >> 8; //MSB
            $outputFile[] = $height & 0x00FF ; //LSB

            // Datasize
            $datasize = sizeof($clipdata);
            $outputFile[] = $datasize  >> 8; //MSB
            $outputFile[] = $datasize & 0x00FF ; //LSB

            // And now, data itself
            for ($i=0;$i<$datasize;$i++) $outputFile[] = $clipdata[$i];
        }
    }

    // Now check if there is JSON to apply
    if (property_exists($fileData, 'hasJSON') && ($fileData->hasJSON))
    {
        // A JSON can only be applied if a image has been loaded in that slot, or if the JSON is to clone a image
        $json = json_decode(file_get_contents( $fileData->JSONfilename));
        if (!$json) error ('Invalid JSON file: ' .$fileData->JSONfilename);
        if ($verbose) echo "Processing JSON file $fileData->JSONfilename ...\n";
        if ((in_array($location, $imgsLoaded))|| ($json->clone == 1))
        {
            // First check if we have to clone
            if ((property_exists($json, 'clone')) && ($json->clone==1))
            {
                if (!property_exists($json, 'location')) error($fileData->JSONfilename . " requests to clone a location but location is missing");
                if (!is_numeric($json->location))  error($fileData->JSONfilename . " requests to clone a location but location is not valid");
                if ($json->location>=$location)  error($fileData->JSONfilename . " asks to clone a location not yet loaded (". $json_location . ')');
                // Clone location header
                if ($verbose) echo "Location $location is now a clone of location $json->location...\n";
                for ($i=0;$i<48;$i++)
                {
                    $outputFile[0x0a + 48 * $location + $i] = $outputFile[0x0a + 48 * $json->location + $i];
                }
            }
            // Now, just apply JSON settings

            
            $float =  (property_exists($json, 'float') && ($json->float==1));
            $buffer =  (property_exists($json, 'buffer') && ($json->buffer==1));
            if (!property_exists($json, 'X')) $fixedX = 0; else $fixedX = $json->X;
            if (!property_exists($json, 'Y')) $fixedY = 0; else $fixedY = $json->Y;
            if (!property_exists($json, 'PCS')) $PCS = 0; else $PCS = $json->PCS;
            if (!property_exists($json, 'PCE')) $PCE = 0x0F; else $PCE = $json->PCE;

            if (!is_numeric($PCE)) error("Invalid PCE value in ".  $fileData->JSONfilename);
            if (!is_numeric($PCS)) error("Invalid PCS value in ".  $fileData->JSONfilename);
            if (!is_numeric($fixedX)) error("Invalid X value in ".  $fileData->JSONfilename);
            if (!is_numeric($fixedY)) error("Invalid Y value in ".  $fileData->JSONfilename);
            if ($PCE<$PCS) error("PCE ($PCE) must be greater than PCS ($PCS) in ".  $fileData->JSONfilename);


            $flags = 4 + 2 * $buffer + $float;
            $fixedX  =intval($fixedX);
            $fixedY = intval($fixedY);

            $outputFile[0x0a + $location * 48 + 5] = $flags;

            $outputFile[0x0a + $location * 48 + 6] = ($fixedX & 0xFF00)>>8;
            $outputFile[0x0a + $location * 48 + 7] = $fixedX & 0xFF;

            $outputFile[0x0a + $location * 48 + 8] = ($fixedY & 0xFF00)>>8;
            $outputFile[0x0a + $location * 48 + 9] = $fixedY & 0xFF;

            $outputFile[0x0a + $location * 48 + 0x0A] = $PCS;
            $outputFile[0x0a + $location * 48 + 0x0B] = $PCE;

        }
        else error('There was no picture for location #' . $location);
    }
} // foreach file

// Update file size in the header
$filesize = sizeof($outputFile);
$outputFile[6] = ($filesize & 0xFF000000) >> 24;
$outputFile[7] = ($filesize & 0x00FF0000) >> 16;
$outputFile[8] = ($filesize & 0x0000FF00) >> 8;
$outputFile[9] = ($filesize & 0x000000FF);

// Update numer of images
$outputFile[4] = (sizeof($imgsLoaded) & 0xFF00) >> 8;
$outputFile[5] = sizeof($imgsLoaded) & 0xFF;

if ($verbose) echo "Writing file $outputFilename...";
dumpDatabase($outputFile, $outputFilename);
if ($verbose) echo "OK.\n";


