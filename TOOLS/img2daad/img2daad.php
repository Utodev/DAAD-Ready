<?php

define('CLIPWIDTH',320); // whole width
define('CLIPHEIGHT',96); // as a standard for DAAD Ready and Maluva, but change if you please
define('NUM_PLANES',4);
define('BYTES_PER_LINE',160);

include_once('png.php');
include_once('degas.php');

function error($errorMsg)
{
    echo "$errorMsg\n";
    exit(1);
}

function syntax()
{
    echo "IMG2DAAD 1.0 - Creates DAAD Graphic Databases for Atari ST and Amiga\n\n";
    echo "SYNTAX: IMG2DAAD <folder> [outputfile] [-c]\n\n";
    echo "<folder>     : folder where to look for .PI1 or .PNG images\n";
    echo "[outputfile] : file name for the output database, if absent, PART1.DAT will be used.\n";
    echo "-c           : compress file\n\n";
    echo "-a           : generate Amiga 12 bit palette file. Requires patched interpreter, if you are no using 12 bit palette you can use same DAT file for Amiga, and use original interpreters.";
    echo "Please notice PNG images can have any format, but must be 320x200, and use a maximum of 16 colours.\n";
    
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

The DAAD interpreters for Amiga and ST were made to use the standard Atari ST mode, 16 colors from a palette of 512 (e bits
per component). When img2daad was created, someone noticed in a game (Los Elfos de Maroland), the ST version graphics were 
better than the Amiga. That was because of some reasons:

1) He was actually testing in an Atari STe, which uses still 16 colors, but from a palette of 4096 (4 bits per component)
2) The Degas .PI1 files used to create the DAT file were also for STe (4 bits)
3) img2DAAD just passes the palette to the DAT file as it was coming (it was, 4 bits, 4 bits remained in the DAT file)
3) The Atari interpreter takes the 4 bits in the palette and sends them to the graphic chip, without deleting the 4th

Sadly, the Amiga interpreter was croppint the 4th bit before sending it to the graphic chip, so despite the DAT file had
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

This is to avoid software made for ST to work fine in STe, but it's affecting us when trying to work with the Amiga.

The solution for that is adding a new parameter "-a" (a for Amiga) to img2DAAD, that ensures that when Degas file, with its "twisted" palette data
is read, img2daad rearranges data so it's as Amiga would expect it.
*/


// Converts Degas twisted bits palette in normal one, byte per byte
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


// MAIN
echo "IMG2DAAD 1.0 - DAAD DAT Maker for Amiga and Atari ST (C) 2022\n";
if ($argc<2) syntax();

// Parse parameters
$outputFilename = 'PART1.DAT';
$compressed = false;
$amigaDAT = false;
$dir = $argv[1];
if (!is_dir($dir)) error ("Invalid folder: $dir");

for ($i=2;$i<$argc;$i++)
{
    $currentParam = $argv[$i];
    if (substr($currentParam, 0, 1) == '-')
    {
        if (strtoupper($currentParam) == '-C') $compressed = true;
        else if (strtoupper($currentParam) == '-A') $amigaDAT = true;
        else Error("Invalid param: $currentParam");
    }
    else if ($i==2) $outputFilename = $currentParam;
}

$outputFile = array();

echo "Creating $outputFilename with" . ($compressed ? '':'out') . " compression.\n";

if ($compressed) error('Compression not yet supported');

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

$files = scandir($dir);
$fileList = array();
foreach ($files as $file)
{
    $extension = strtoupper(explode('.',"$file.")[1]);
    if (($extension != 'PI1') && ($extension != 'PNG') && ($extension != 'JSON')) continue;
    $location = explode('.',"$file.")[0];
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

foreach ($fileList as $location=>$fileData)
{

    if ( ((property_exists($fileData, 'hasPI1')) &&  ($fileData->hasPI1)) || ((property_exists($fileData, 'hasPNG')) &&  ($fileData->hasPNG)) ) 
    {
        echo ">> Processing image $location ";
        $imgsLoaded[]=$location;

        if ((property_exists($fileData, 'hasPNG')) &&  ($fileData->hasPNG)) // PNG over PI1
        {
            $file = $fileData->PNGfilename;
            echo " ($file).\n";
            $degas = new pngFileReader();
            $result = $degas->loadFile($dir . DIRECTORY_SEPARATOR . $file);
            if ($result!='') error($result);
        }
        else
        {
            $file = $fileData->PI1filename;
            echo " ($file).\n";
            $degas = new degasFileReader(); 
            $result = $degas->loadFile($dir . DIRECTORY_SEPARATOR . $file);
            if ($result!='') error($result);
        }

        
        // *** Fill the location data ***

        $locationPrt = 0x0A + 48 * $location;
        $currentOffset  = sizeof($outputFile);

        // Offset to location pixels data
        $outputFile[$locationPrt] = ($currentOffset & 0xFF000000) >> 24;  
        $outputFile[$locationPrt+1] = ($currentOffset & 0x00FF0000) >> 16;  
        $outputFile[$locationPrt+2] = ($currentOffset & 0x0000FF00) >> 8;
        $outputFile[$locationPrt+3] = $currentOffset & 0x000000FF;


        $outputFile[$locationPrt+4] = 0x00;  
        $outputFile[$locationPrt+5] = 0x04;  // Flags (no buffer, fixed)

        /*
        This part has been commented as values are already 0x00, so
        code is just ketp so what we do is understood.

        $outputFile[$locationPrt+6] = 0x00;  
        $outputFile[$locationPrt+7] = 0x00;   // X coord

        $outputFile[$locationPrt+8] = 0x00;  
        $outputFile[$locationPrt+9] = 0x00;   // Y coord

        $outputFile[$locationPrt+10] = 0x00;   // First palette color,filler as it's float
        */

        $outputFile[$locationPrt+11] = 0x0F;   // Last palette color,filler as it's float

        // Now the palette
        $degas->seekFile(2);  // point to palette

        for($i=0;$i<32;$i++) 
        {

            $val = $degas->readByte(); // read palette
            if ($amigaDAT)  $val = normalPalette($val);
            $outputFile[$locationPrt+12+$i] = $val;

            //$outputFile[$locationPrt+12+$i] = $degas->readByte(); // read palette
            //echo str_pad(dechex($outputFile[$locationPrt+12+$i]),2,'0',STR_PAD_LEFT);           
            //if ($i%2!=0) echo ' ';
        }
        echo "\n";


        /*
        Again, this part has been commented as values are already
        0x00, so code is just ketp so what we do is understood.

        $outputFile[$locationPrt+44] = 0x00;  
        $outputFile[$locationPrt+45] = 0x00;   
        $outputFile[$locationPrt+46] = 0x00;  
        $outputFile[$locationPrt+47] = 0x00;   // CGA palette pointer, filler as there is no CGA palette
        */

        if ($amigaDAT) 
        {
            $outputFile[$locationPrt+44] = 0xDA;  
            $outputFile[$locationPrt+45] = 0xAD;   
            $outputFile[$locationPrt+46] = 0xDA;  
            $outputFile[$locationPrt+47] = 0xAD;   
        }


        $screen = array();
        for ($i=0;$i<32000;$i++) $screen[] = $degas->readByte(); // read 32.000 bytes of image data


        // we will be getting only the window (0,0,320,96)

        $xs = 0;
        $ys = 0;
        $width = CLIPWIDTH;
        $height= CLIPHEIGHT; 

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
            $lo+=BYTES_PER_LINE;
        }
        // Tim Gilbert's code ends here

        // Let's dump the pixels data now
        // Fist the mini header at the pixels area
        $outputFile[] = CLIPWIDTH  >> 8; //MSB
        $outputFile[] = CLIPWIDTH & 0x00FF ; //LSB

        $outputFile[] = CLIPHEIGHT  >> 8; //MSB
        $outputFile[] = CLIPHEIGHT & 0x00FF ; //LSB

        $datasize = sizeof($clipdata);

        $outputFile[] = $datasize  >> 8; //MSB
        $outputFile[] = $datasize & 0x00FF ; //LSB

        // And now, data itself
        for ($i=0;$i<$datasize;$i++) $outputFile[] = $clipdata[$i];
    }

    // Now check if there is JSON to apply
    if (property_exists($fileData, 'hasJSON') && ($fileData->hasJSON))
    {
        // A JSON can only be applied if a image has been loaded in that slot, or if the JSON is to clone a image
        $json = json_decode(file_get_contents($dir . DIRECTORY_SEPARATOR . $fileData->JSONfilename));
        if (!$json) error ('Invalid JSON file: ' .$fileData->JSONfilename);
        echo "Processing JSON file $fileData->JSONfilename ...\n";
        if ((in_array($location, $imgsLoaded))|| ($json->clone == 1))
        {
            // First check if we have to clone
            if ((property_exists($json, 'clone')) && ($json->clone==1))
            {
                if (!property_exists($json, 'location')) error($fileData->JSONfilename . " requests to clone a location but location is missing");
                if (!is_numeric($json->location))  error($fileData->JSONfilename . " requests to clone a location but location is not valid");
                if ($json->location>=$location)  error($fileData->JSONfilename . " asks to clone a location not yet loaded (". $json_location . ')');
                // Clone location header
                echo "Location $location is now a clone of location $json->location...\n";
                for ($i=0;$i<48;$i++)
                {
                    $outputFile[0x0a + 48 * $location + $i] = $outputFile[0x0a + 48 * $json->location + $i];
                }
            }
            // Now, just apply JSON settings

            
            $float =  (property_exists($json, 'float') && ($json->float==1));
            $buffer =  (property_exists($json, 'buffer') && ($json->buffer==1));
            if (!property_exists($json, 'fixedX')) $fixedX = 0; else $fixedX = $json->fixedX;
            if (!property_exists($json, 'fixedY')) $fixedY = 0; else $fixedY = $json->fixedY;
            if (!property_exists($json, 'firstPAL')) $firstPAL = 0; else $firstPAL = $json->firstPAL;
            if (!property_exists($json, 'lastPAL')) $lastPAL = 0x0F; else $lastPAL = $json->lastPAL;

            if (!is_numeric($lastPAL)) error("Invalid lastPAL value in ".  $fileData->JSONfilename);
            if (!is_numeric($firstPAL)) error("Invalid firstPAL value in ".  $fileData->JSONfilename);
            if (!is_numeric($fixedX)) error("Invalid fixedX value in ".  $fileData->JSONfilename);
            if (!is_numeric($fixedY)) error("Invalid fixedY value in ".  $fileData->JSONfilename);

            $flags = 4 + 2 * $buffer + $float;
            $fixedX  =intval($fixedX);
            $fixedY = intval($fixedY);

            $outputFile[0x0a + $location * 48 + 5] = $flags;
            $outputFile[0x0a + $location * 48 + 6] = ($fixedX & 0xFF00)>>8;
            $outputFile[0x0a + $location * 48 + 7] = $fixedX & 0xFF;
            $outputFile[0x0a + $location * 48 + 8] = ($fixedY & 0xFF00)>>8;
            $outputFile[0x0a + $location * 48 + 9] = $fixedY & 0xFF;
            $outputFile[0x0a + $location * 48 + 0x0A] = $firstPAL;
            $outputFile[0x0a + $location * 48 + 0x0B] = $lastPAL;
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

echo "Writing file $outputFilename...";
dumpDatabase($outputFile, $outputFilename);
echo "OK.\n";


