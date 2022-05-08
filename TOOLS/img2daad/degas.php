<?php 

//This class provides a way to read a Degas Elite file of 320x200, 16 colors

class degasFileReader
{

    var $fileContent;
    var $fileSize;
    var $position;

    function loadFile($filename)
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

}
