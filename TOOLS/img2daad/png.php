<?php 

// Important note: I have found that if I put whitest color at palette entry 15, then the
// Atari ST interpreter shows white text if either you execute "INK 1" or do nothing  (1
// seems to be default). But if I use any other number, i.e. 7, then you have to do INK 8
// to show white, or INK 13 if I put white at 12.
define('COLOUR_BLACK_PALETTE_IDX',0 );
define('COLOUR_WHITE_PALETTE_IDX',15); 
// The following colours are the objective when looking for white or black
// You can change them if you want different text or background colours
define('WHITE',0x0777);
define('TRUECOLOR_WHITE',0xFFFFFF);
define('BLACK',0x0000);
define('TRUECOLOR_BLACK',0x000000);

//This class provides a way to read a png file of 320x200, max 16 colours

class pngFileReader
{

    var $image;
    var $fileContent;
    var $fileSize;
    var $position;
    var $verbose;

    function loadFile($filename, $verbose  = 0 )
    {

        $this->verbose = $verbose;
        $imageSizes = getimagesize($filename);
        if ($imageSizes[0]!=320) return "Invalid resolution, must be 320x200"; // Expecting 320x200 image
        if ($imageSizes[1]!=200) return "Invalid resolution, must be 320x200"; // Expecting 320x200 image

        $this->image = imagecreatefrompng ($filename);
         // If the image is indexed, convert to truecolor because we will only process truecolor images later
         if (!imageistruecolor($this->image))
           if (!imagepalettetotruecolor($this->image)) 
             return "Image is not Truecolor and canno be converted to Truecolor";

        // Check number of different colours in the image
        $differentColours = array();
        for ($x=0;$x<320;$x++)
         for ($y=0;$y<200;$y++)
         {
          $c = imagecolorat($this->image, $x, $y);
          if (!in_array($c, $differentColours)) $differentColours[] = $c;
          if (sizeof($differentColours)>16) return "Too many colours, only up to 16 colours allowed.";   
         }
         if ($this->verbose) echo "Found " .sizeof($differentColours) . " colours in this picture.\n";
   

        $this->PNG2degas($differentColours);
        return "";

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

    // Converts the PNG image into a 32066 bytes buffer to work exactly as a Degas file (PI1)
    private function PNG2degas($differentColours)
    {
        $colourBlack =$colourWhite = -1;
        // First let's calculate the palette
        $palette = array();
        for ($i = 0; $i < sizeof($differentColours);$i++)
        {
            $colour =  $differentColours[$i];
            // Get the Truecolour components
            $r = ($colour >> 16) & 0xFF;
            $g = ($colour >> 8) & 0xFF;
            $b = $colour & 0xFF;
            //if ($this->verbose) echo "Original Palete R: " .decbin($r) . " G " . decbin($g) . " B "  . decbin($b) . "\n";
            // Reduce to 3 bit
            $r = $r >> 4; $r=($r % 2)  + ($r >> 1); if ($r>7) $r= 7;  // Round up one if last bit lost is 1
            $g = $g >> 4; $g=($g % 2)  + ($g >> 1); if ($g>7) $g= 7;  // unless the result will go over 111
            $b = $b >> 4; $b=($b % 2)  + ($b >> 1); if ($b>7) $b= 7;  
            //if ($this->verbose) echo "9-bit palette R: " .decbin($r) . " G " . decbin($g) . " B "  . decbin($b) . "\n";
            // Convert to AtariST palette
            $palette[$i] = $b + ($g << 4) + ($r << 8);
            // If one of them is already recognized as black or white, we note it down
            if ($palette[$i]==BLACK) 
            {
                $colourBlack = $i;
                if ($this->verbose) echo "Pure black found at colour $colourBlack.\n";
            }
            if ($palette[$i]==WHITE) 
            {
                $colourWhite = $i;
                if ($this->verbose) echo "Pure white found at colour $colourWhite.\n";
            }
        }


        // If less than 16 colours used, we fill the palette up to 16
        // colours alternatively adding white and black colours
        
        while (sizeof($palette) < 16)
        {
            if (sizeof($palette) %  2)
            {
                $differentColours[] = TRUECOLOR_WHITE;
                $palette[] = WHITE;
                $colourWhite = sizeof($palette) -1 ;
            }
            else
            {
                $differentColours[] = TRUECOLOR_BLACK;
                $palette[] = BLACK;
                $colourBlack = sizeof($palette) -1;
            }
        }

        
        // If still not found (no pure ones and palette already full or filled without adding white)
        // we have to find the closest colour to black to use as black
        if ($colourBlack == -1)
            $colourBlack = $this->searchColour($palette, (BLACK & 0x0F00) >> 8, (BLACK & 0x00F0) >> 4, BLACK & 0x0F);

        // Same for the white, except that we make sure the previously selected colourBlack is chosen
        // even in the very rare case the same colour is at the same time the clostest to B and W
        if ($colourWhite == -1)
            $colourWhite = $this->searchColour($palette, (BLACK & 0x0F00) >> 8, (BLACK & 0x00F0) >> 4, BLACK & 0x0F, $colourBlack); 


        // Now we will be creating an alternative bitmap, where every x,y has the value of the palette
        // index, rather than the colour itself. But first, we are going to sort the palette trying to
        // make "colourBlack" be palette index 0, and colourWhite, palette index COLOUR_WHITE_PALETTE_IDX.

        // To do so, this array will tell which true colour will match which palette
        // At the start matchings are direct, at the end, we will move things so black 
        //is colour 0 and white colour COLOUR_WHITE_PALETTE_IDX. 

        $match = array();
        for ($i=0;$i<16;$i++)
        {
            $match[$i] =$i;
        }



        // If black and white are not placed at the proper place, move them
        if ($colourWhite != COLOUR_WHITE_PALETTE_IDX)
        {
            if ($this->verbose) echo "Swapping colour white from $colourWhite to ".COLOUR_WHITE_PALETTE_IDX."  \n";
                $match[COLOUR_WHITE_PALETTE_IDX] = $colourWhite; // Swap  the matchings
                $match[$colourWhite] = COLOUR_WHITE_PALETTE_IDX;

                $c = $palette[$colourWhite];       // And swap the palette
                $palette[$colourWhite] = $palette[COLOUR_WHITE_PALETTE_IDX];
                $palette[COLOUR_WHITE_PALETTE_IDX] =$c;


                // IF by any chance colourBlack was at COLOUR_WHITE_PALETTE_IDX, it is now where colourWhite was
                if ($colourBlack == COLOUR_WHITE_PALETTE_IDX) 
                {
                    $colourBlack = $colourWhite;
                }
        }
        
        if ($colourBlack != COLOUR_BLACK_PALETTE_IDX)
        {
                if ($this->verbose) echo "Swapping colour black from $colourBlack to ".COLOUR_BLACK_PALETTE_IDX."  \n";
                $match[COLOUR_BLACK_PALETTE_IDX] = $colourBlack; // Swap  the matchings
                $match[$colourBlack] = COLOUR_BLACK_PALETTE_IDX;

                $c = $palette[$colourBlack];       // And swap the palette
                $palette[$colourBlack] = $palette[COLOUR_BLACK_PALETTE_IDX];
                $palette[COLOUR_BLACK_PALETTE_IDX] =$c;
        }

        // OK, now we have a matching array and can create a fake image of 320x200, where
        // each x.y contains the palette entry


        $fakeImage =  array();

        for ($y=0;$y<200;$y++)
            for ($x=0;$x<320;$x++)
                 $fakeImage[$x + 320 * $y] = $match[array_search(imagecolorat($this->image, $x, $y), $differentColours)];


        // Now that we have the whole info, let's prepare a fake Degas file in RAM

        // The signature
        $this->fileContent[] = 0;
        $this->fileContent[] = 0; 
        
        // The palette
        for ($i=0;$i<16;$i++)
        {
            $this->fileContent[] = ($palette[$i]   &  0xFF00) >> 8; 
            $this->fileContent[] = $palette[$i] &  0xFF;
        }

        //The pixels
        $fakePtr = 0;
        $planes = array();
        while ($fakePtr<64000)
        {
            
            $planes[0] = $planes[1] = $planes[2] = $planes[3] = 0;
            for ($i=0;$i<16;$i++) 
            {
                $pixeltoCheck = $fakePtr + $i ;
                $value = $fakeImage[$pixeltoCheck];
                for ($p=0;$p<4;$p++)
                 $planes[$p]  = ($planes[$p] << 1) + (   ($value & (1 << $p) ) >> $p);
            }
            for ($p=0;$p<4;$p++)
            {
                $this->fileContent[] =  ($planes[$p] & 0xFF00)>>8;
                $this->fileContent[] =  $planes[$p] & 0xFF;
            }
            $fakePtr += 16;
        }

        //Filler (at the moment it's unclear why it should be 32066 when it's 2 signature + 32 palette + 32000 = 32034)
        while(sizeof($this->fileContent)<32066) $this->fileContent[] = 0;
        $this->fileSize = 32066;
        $this->position = 0;
    }

    // Please notice this is no the most accurate way of searching for a close colour,
    // but the fastest one. If you notice a color not expected is chosen when there
    // is no white in the picture, you may try to modifí the weights of each 
    // RGB color below (check those 0.4, 0.4, 0.2). Please notice human eye detects
    // blue tones worse.

    private function searchColour($palette, $r, $g, $b, $skipColour = -1)
    {
     $closerColour = -1;
     $betterDistance = 1000000000;
     for ($i=0;$i<16;$i++)
     {
         if ($i==$skipColour) continue;
         // Get the palette components
         $pr = ($palette[$i] & 0x0700)>>8;
         $pg = ($palette[$i] & 0x0070)>>4;
         $pb = $palette[$i] & 0x0007;
         //compare with target colour
         $distance  = sqrt(( pow(abs($pr-$r),2)*0.4) + pow(abs($pg-$g)*0.4,2) + pow(abs($pb-$b)*0.2,2));
         if ($distance<$betterDistance)
         {
             $betterDistance = $distance;
             $closerColour = $i;
         }
     }
     return $closerColour;
    }


}
