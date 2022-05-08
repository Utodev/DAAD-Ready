<?php

function replace_extension($filename, $new_extension) 
{
    $info = pathinfo($filename);
    return $info['filename'] . '.' . $new_extension;
}

	$file = $argv[1];
	$png = replace_extension($file, 'png');
	$chr = replace_extension($file, 'chr');
	

	$in = file_get_contents($file);
	$out = substr($in,16);

	$maxy = filesize($file)/32+1;

	$img = imagecreatetruecolor(256,$maxy);
	$c0 = imagecolorallocate($img, 0, 0, 0);
	$c15 = imagecolorallocate($img, 255, 255, 255);

	$pos = 0;
	$y0 = 0;
	while ($pos < strlen($in))
	{
		for ($x=0; $x<256; $x+=8) 
		{
			for ($y=0; $y<8; $y++) 
			{
				$c = ord($in[$pos]);
				$character = floor(($pos - 16) /8) ;

				if ($pos>=8*16)
				for ($b=0; $b<8; $b++) 
				{
					$realX = $x+$b;
					$realY = $y0+$y;
					if ($pos <1024)
					{
						$realX -= 8*16;
						if ($realX<0) 
						{
							$realX = 256 + $realX;
							$realY =$realY - 8;
						}
					}
					else 
					{
						$realX += 8*16;
						if ($realX>=256) 
						{
							$realX = $realX - 256;
							$realY =$realY + 8;
						}

					}


					imagesetpixel($img, $realX, $realY, $c & (1<<(7-$b)) ? $c15 : $c0);
				}
				$pos++;
			}
		}
		$y0 += 8;
	}
	

	$font0 = imagecreatetruecolor(256,212);
	$font1 = imagecreatetruecolor(256,212);

	imagecopy($font0, $img, 0, 0, 0, 0, 256, $maxy/2 );
	imagecopy($font1, $img, 0, 0, 0, $maxy/2, 256, $maxy/2 );

	imagepng($font0, "font0.png");
	imagepng($font1, "font1.png");

?>