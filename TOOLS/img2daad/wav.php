<?php 


define('DMG_5KHZ', 0);
define('DMG_7KHZ', 1);
define('DMG_9_5KHZ', 2);
define('DMG_15KHZ', 3);
define('DMG_20KHZ', 4);
define('DMG_30KHZ', 5);

class wavFileReader
{

    var $fileContent;
    var $wavfileContent;
    var $frequency;
    var $sampleSize;

    function loadFile($filename)
    {

        $this->wavfileContent = array();
        $filesize = filesize($filename);

        $fp = fopen($filename, 'rb');
        for ($i=0;$i<$filesize;$i++)
            $this->wavfileContent[] = ord(fread($fp, 1));
        fclose($fp);


        // Check if the file is a valid WAV file
        // Size
        if (sizeof($this->wavfileContent) < 44) return "File too small to be a valid WAV file"; // WAV files must have at least 44 bytes
        if (sizeof($this->wavfileContent) > 32768) return "WAV file too big for DAAD"; 
        // Check for 'RIFF' signature
        if (($this->wavfileContent[0]!=82) || ($this->wavfileContent[1]!=73) || ($this->wavfileContent[2]!=70) || ($this->wavfileContent[3]!=70))  return('Invalid WAV file (bad signature)'); 
        // Check for 'WAVE' in the header
        if (($this->wavfileContent[8]!=87) || ($this->wavfileContent[9]!=65) || ($this->wavfileContent[10]!=86) || ($this->wavfileContent[11]!=69))  return('Invalid WAV file (bad header)'); 
        // Check for 'fmt ' in the header
        if (($this->wavfileContent[12]!=102) || ($this->wavfileContent[13]!=109) || ($this->wavfileContent[14]!=116) || ($this->wavfileContent[15]!=32))  return('Invalid WAV file (bad fmt header)'); 
        // Check for PCM format
        if (($this->wavfileContent[20]!=1) || ($this->wavfileContent[21]!=0))  return('Only PCM WAV files are supported'); // Check for PCM format
        // Check for mono channel
        if (($this->wavfileContent[22]!=1) || ($this->wavfileContent[23]!=0))  return('Only mono WAV files are supported'); // Check for mono channel
        // Check for 8 bit samples
        if (($this->wavfileContent[34]!=8) || ($this->wavfileContent[35]!=0))  return('Only 8 bit WAV files are supported'); // Check for 8 bit samples
        // Check for 'data' chunk at the right place
        if (($this->wavfileContent[36]!=100) || ($this->wavfileContent[37]!=97) || ($this->wavfileContent[38]!=116) || ($this->wavfileContent[39]!=97))  return('Invalid WAV file (bad data header)'); 
        
        
        return $this->convert();

    }

    function convert()
    {
        $sampleLength = $this->wavfileContent[40] + ($this->wavfileContent[41] << 8) + ($this->wavfileContent[42] << 16) + ($this->wavfileContent[43] << 24)    ;
        if ($sampleLength > 32768) return('Sample too long for DAAD');

        $sampleRate = ($this->wavfileContent[24]) + ($this->wavfileContent[25] << 8) + ($this->wavfileContent[26] << 16) + ($this->wavfileContent[27] << 24);
        $this->frequency = $this->getFrequency($sampleRate);
        $this->fileContent = array();
        for($i=44;$i<44+$sampleLength;$i++)  
            {
                $this->fileContent[] = $this->wavfileContent[$i];
            }
        $this->sampleSize = count($this->fileContent);
        return "";
    }


    

    function getFrequency($sampleRate)
    {
            if ($sampleRate == 0) return 0;
            if ($sampleRate < 5000) return DMG_5KHZ;
            else if ($sampleRate < 7000) return DMG_7KHZ;
            else if ($sampleRate < 9500) return DMG_9_5KHZ;
            else if ($sampleRate < 15000) return DMG_15KHZ;
            else if ($sampleRate < 20000) return DMG_20KHZ;
            else return DMG_30KHZ;
    }

}
