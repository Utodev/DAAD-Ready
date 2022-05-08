<?php


function replace_extension($filename, $new_extension) 
{
    $info = pathinfo($filename);
    return $info['filename'] . '.' . $new_extension;
}

function reverseBits($in) {
	$out = 0;
  
	if ($in & 0x01) $out |= 0x80;
	if ($in & 0x02) $out |= 0x40;
	if ($in & 0x04) $out |= 0x20;
	if ($in & 0x08) $out |= 0x10;
	if ($in & 0x10) $out |= 0x08;
	if ($in & 0x20) $out |= 0x04;
	if ($in & 0x40) $out |= 0x02;
	if ($in & 0x80) $out |= 0x01;
  
	return $out;
  }

function getScan($asciiCode, $y, $in)
{
	$aa = array(0,0x20,0x58,0x38,0,0x78,0,0);
	$openQuote = array(0,0,10,0x14,0x28,0x14,10,0);
	switch ($asciiCode)
	{
		case 16: return chr($aa[$y]); break; //ª
		case 17: return $in[(1*8) + (8 - $y)]; break; // ¡
		case 18: return chr(reverseBits(ord($in[((63-32)*8) +  (8 - $y)]))); break;// ¿
		case 19: return chr($openQuote[$y]); break; // <<
		case 20: return chr(reverseBits($openQuote[$y])); break; // >>
		case 21: return ($y != 0) ? $in[((97-32)*8) +  ($y)] : chr(0x1c); break; //á
		case 22: return ($y != 0) ? $in[((101-32)*8) +  ($y)] : chr(0x1c); break; //é
		case 23: return ($y != 0) ? $in[((105-32)*8) +  ($y)] : chr(0x1c); break; //í
		case 24: return ($y != 0) ? $in[((111-32)*8) +  ($y)] : chr(0x1c); break; //ó
		case 25: return ($y != 0) ? $in[((117-32)*8) +  ($y)] : chr(0x1c); break; //ú
		case 26: return ($y != 0) ? $in[((110-32)*8) +  ($y)] : chr(0x3c); break; //ñ
		case 27: return ($y != 0) ? $in[((78-32)*8) +  ($y)] : chr(0x7e); break; //Ñ
		case 28: return ($y != 7) ? $in[((99-32)*8) +  ($y)] : chr(0x18>>1); break; //ç
		case 29: return ($y != 7) ? $in[((67-32)*8) +  ($y)] : chr(0x18); break; //Ç
		case 30: return ($y != 0) ? $in[((117-32)*8) +  ($y)] : chr(0x36); break; //ü
		case 31: return ($y != 0) ? $in[((85-32)*8) +  ($y)] : chr(0x36<<1); break; //Ü
		default: return chr(255); 
	}
	
}

	$file = $argv[1];
	$png = replace_extension($file, 'png');
	$chr = replace_extension($file, 'chr');
	

	$in = file_get_contents($file);
	
	
	// Fill first 16 chars with blank
	$out = '';
	for ($asciiCode = 0; $asciiCode<16; $asciiCode++)
		for ($y=0;$y<8;$y++)
				$out .= chr(0);

	
	for ($asciiCode = 16; $asciiCode < 128; $asciiCode++)
	{
		for ($y=0;$y<8;$y++)
		{
			$byte = getScan($asciiCode, $y, $in);
			if ($byte == chr(255)) 
			  $out .= $in[($asciiCode-32)*8 + $y];
			   else $out .= $byte;
		}
		
	}

	$out[31*8+1] = chr(0);

	$out = "$out$out";

	file_put_contents("$chr", $out);

