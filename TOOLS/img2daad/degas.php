<?php 

//This class provides a way to read a Degas Elite file of 320x200, 16 colors

/*
DEGAS file format:

DEGAS           *.PI1 (low resolution)
                *.PI2 (medium resolution)
                *.PI3 (high resolution)
                (PI4, PI5, PI6)

1 word          resolution (0 = low res, 1 = medium res, 2 = high res)
                Other bits may be used in the future; use a simple bit
                test rather than checking for specific word values.
16 words        palette
16000 words     picture data (screen memory)
-----------
32034 bytes     total

*/

class degasFileReader
{
    var $fileContent;
    var $fileSize;
    var $position;
    var $linearScreen;

    function loadFile($filename, $verbose = 0)
    {

        $this->fileContent = array();
        $this->fileSize = filesize($filename);
        if ( ($this->fileSize!=32066) && ($this->fileSize!=32034)) return "Invalid Degas or Degas Elite 320x200, 16 colours file size, must be 32066 or 32034 bytes"; // Degas Elite 320x200x16 is 32066 bytes long
        $fp = fopen($filename, 'rb');
        for ($i=0;$i<$this->fileSize;$i++)
            $this->fileContent[] = ord(fread($fp, 1));
        fclose($fp);
        $this->position = 0;
        if ($this->fileContent[0] + $this->fileContent[1]) return "Bad Degas Elite file signature"; // First two bytes in a Degas Elite 320x200x16 must be 00 00 signature.

        // Generate linear screen (for compression purposes)

        // first generate the planar screen
        $this->seekFile(34); // skip header (2 bytes res + 32 bytes palette)
        $stScreen = array();
        for ($i=0;$i<32000;$i++)
        {
            $stScreen[] = $this->readByte();
        }
        // Gnerate linear screen from planar screen
        $this->stPlanarToLinear($stScreen);
        if (sizeof($this->linearScreen)!=64000) throw new Exception('Error generating linear screen from Degas planar data:  size is ' . sizeof($this->linearScreen) . ' bytes instead of 32000 bytes');
        return "";

    }



    private function stPlanarToLinear($stScreen)
{
    $this->linearScreen = [];
    $offset = 0;

    // 320*200 / 16 = 4000 bloques
    for ($block = 0; $block < 4000; $block++) {

        // Leer las 4 palabras de plano (big-endian)
        $planes = [];

        for ($p = 0; $p < 4; $p++) {
            $high = $stScreen[$offset++];
            $low  = $stScreen[$offset++];
            $planes[$p] = ($high << 8) | $low;
        }

        // Reconstruir los 16 píxeles del bloque
        for ($i = 0; $i < 16; $i++) {
            $pixel = 0;

            for ($p = 0; $p < 4; $p++) {
                // Bit del plano correspondiente al píxel
                $bit = ($planes[$p] >> (15 - $i)) & 1;
                $pixel |= ($bit << $p);
            }

            $this->linearScreen[] = $pixel; // valor 0-15
        }
    }

}

    function seekFile($aPosition)
    {
        if ($aPosition < $this->fileSize) $this-> position = $aPosition;
        else throw new Exception('Seek after EOF');
    }

    function readByte()
    {
        if ($this->position<$this->fileSize) 
        {
            $aByte = $this->fileContent[$this->position];
            $this->position++;
            return $aByte;
        }
        else throw new Error('Read after EOF');
    }

    function readWord()
    {
        $msb = $this->readByte();
        $lsb = $this->readByte();
        return $lsb + 256 * $msb;
    }

}
