<?php

define('RECON_FUENTE',"JSJ SINTAC FNT3" .chr(0));

function Syntax()
{
    echo "Syntax: php ch82chr.php <inputFile> <type> \n\n";
    echo "<inputFile>: any .ch8 file from Damien Guard's repository\n";
    echo "<type>: the type of output file. Types can be '6' to generate AD8x6.CHR file, '8' to generate AD8x8.CHR file, 'C64' to generate C64bold.CHR file or 'DOSF' to generate the MSDOS.FNT file with fixed with, and 'DOSP' to generate the MSDOS.FNT file with a proportional width per character.";
    echo " Please notice the type won't change the font at all, it's used to determine output format and be able to generate warnings if input font doens't fit well in the output format.\n\n";
    echo "When generating MSDOS.FNT file, with proportional mode, the generated font will have a different width per character, which is the width of the character plus one, to leave a gap, when possible. Character 32, space, will always be 8 pixels wide, though.\n\n";
    echo "You can find Damien Guard's fonts at https://damieng.com/typography/zx-origins/. Please make sure you comply with Damien Guard's requirements to use the fonts (detailed in the website).\n\n";
    echo "If you are using CH82CHR for an English game you don't need to read the following: CH8 files only include characters from ASCII 32 to 127. Although those are enough for English, it's not the case for Spanish, French, German and Portuguese games, that require more characters. That means you will have to fix the output file yourself, using GCS or ZXPaintbrush to edit the output file. To help you with that, CH82CHR will include the standard content of the original DAAD-Ready character files into your output file, so for instance you can see 'Ñ' or 'à' in their places. Just they will have the original AD font. It's up to you to update the file to ressemble CH8 font style for those characters. In order for that to happen, you have to run ch82chr from DAAD Ready's folder TOOLS/CH82CHR, or just copy the contents of DAAD Ready charset assets folder (ASSETS\CHARSET) to the folder where ch82chr is. Otherwise, CH82CHR wonn't find the base file to copy characters, and all other characters not in the 32-127 range will be empty.\n\n";
    exit(0);
}

function Error($msg)
{
    echo "$msg\n\n";
    exit(1);
}

function getChar($code)
{
    if (($code < 32 ) || ($code>126)) return ""; else return ' (' . (chr($code)) .')';
}

function getBaseFile($type)
{
    switch($type)
    {
        case '6': return 'AD8x6.CHR';
        case '8': return 'AD8x8.CHR';
        case 'C64':  return 'C64bold.CHR';
        default: return 'MSDOS.FNT';
    }
}

function getBaseWidth($type)
{
    if ($type == '6') return 6; else return 8;
}


function getColumnWidth($byte)
{
    for ($i=0;$i<8;$i++)
    {
        if (($byte & (1<<$i))!=0) return 8 - $i;
    }
    return 0;
}


function saveDOSFile($type, $baseFile, $output, $widths)
{
    $DOSOutput = [];
    
    for ($i=0;$i<strlen(RECON_FUENTE);$i++) $DOSOutput[] = RECON_FUENTE[$i];
    for ($i=0;$i<256;$i++) $DOSOutput[] = chr(8); // Save widths for 16, because otherwise GCS fails
    for($i=0;$i<256*16;$i++) $DOSOutput[]=chr(0); // Save Empty 16 hight font
    for ($i=0;$i<256;$i++) if ($type=='DOSP') $DOSOutput[]= chr($widths[$i]); else $DOSOutput[] = chr(8); // Save widths
    for ($i=0;$i<2048;$i++) $DOSOutput[]= $output[$i]; // Save Pixels
    file_put_contents("_{$baseFile}", $DOSOutput);      
}

function saveFile($type, $baseFile, $output, $widths)
{
    if (($type=='6') || ($type=='8') ||($type=='C64')) file_put_contents("_{$baseFile}", $output);
    else saveDOSFILE($type, $baseFile, $output, $widths);
}

/* MAIN */
if ($argc<3) Syntax();
$inputFile = $argv[1];
$type =  strtoupper($argv[2]);
if (($type!='6') && ($type!='8') && ($type!='C64') && ($type!='DOSF') && ($type!='DOSP')) Error('Invalid type: ' . $type);

if (!file_exists($inputFile)) Error($inputFile . ' not found.');

$originalFont = file_get_contents($inputFile);
if (strlen($originalFont)!=768) Error('Invalid CH8 file');

$baseFile = getBaseFile(($type));
if (file_exists($baseFile)) 
{
    echo "Base file $baseFile found in local folder.\n";
    $baseFont = file_get_contents($baseFile);
}
else
{
    $path = '..' . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . 'ASSETS' . DIRECTORY_SEPARATOR . 'CHARSET' . DIRECTORY_SEPARATOR ;
    if (file_exists($path . $baseFile)) 
    {
        echo "Base file $baseFile found in DAAD Ready CHARSET folder.\n";
        $baseFont = file_get_contents($path . $baseFile);
        if (($type=='DOSP') || ($type=='DOSF'))
        {
            $baseDOSFont = file_get_contents($path . $baseFile);
            $baseFont = ''; 
            for ($i=0;$i<256*8;$i++) $baseFont.=$baseDOSFont[256*18 +strlen(RECON_FUENTE)+ $i];
        } 
    }
    else
    {
        echo "Base file not found. Additional characters will be empty.\n";
        $basefont = ''; for ($i=0;$i<2048;$i++) $baseFont .= chr(0); // Create fake and empty base file
    }
}

$output=[];
for($i=0;$i<32*8;$i++) $output[] = $baseFont[$i];   // Add first 32 characters from baseFont
for ($i=0;$i<96*8;$i++) $output[] = $originalFont[$i];   // Add next 96 characters from Damien's font
for ($i=0;$i<128*8;$i++) $output[] = $baseFont[$i + 128*8]; // Add last 128 characters (the whole upper font) from baseFont

$baseWidth  =getBaseWidth($type);

$wasWarning = false;
$widths = [];
for($i=0;$i<256;$i++)
{
   $maxWidth = 0;
   for ($j=0;$j<8;$j++)
   {
        $byte = ord($output[$i*8+$j]);
        $byteWidth = getColumnWidth($byte);     
        //echo str_pad(decbin($byte), 8, '0',STR_PAD_LEFT) . "   " . $byteWidth ."\n";
        if ($byteWidth>$maxWidth) $maxWidth  =$byteWidth;
   }
   //echo "$i ==> $maxWidth\n";
   if (($maxWidth>$baseWidth-1) && ($i<127)) // Don't warn about upper charset
   {
    echo "Warning: character $i". getChar($i) ." has a width of $maxWidth pixels, which is not optimal for a $baseWidth pixels wide font.\n";
    $wasWarning = true;
   }
   $widths[$i] =  $maxWidth + 1; // For real width, keep last empty pixels column (separator)
   if ($widths[$i] > $baseWidth) $widths[$i] = $baseWidth;
   if ($i==32) $widths[$i] = $baseWidth; // Make sure the space has a proper width
}

if ($wasWarning) echo "Please notice for readability characters should have one pixel empty in the right side, so for a 8 pixels wide font the optimal width is 7, and for a 6 pixels wide font the optimal width is 5.\n";

// Save output file
saveFile($type, $baseFile, $output, $widths);

echo "Done.\n\n";