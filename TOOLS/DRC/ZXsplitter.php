<?php




  function spectrumScreenBlocks($lines)
  {
      $ranges = [];

      // --- Datos de píxeles ---
      // Cada línea y ocupa 32 bytes en la dirección calculada por el layout
      // no lineal del Spectrum.
      for ($y = 0; $y < $lines; $y++) {
          $bank     = $y >> 6;
          $pixelRow = $y & 7;
          $charRow  = ($y >> 3) & 7;
          $addr     = 16384 + $bank * 2048 + $pixelRow * 256 + $charRow * 32;
          $ranges[] = [$addr, 32];
      }

      // --- Datos de atributos ---
      // Lineales desde 22528, 32 bytes por fila de caracteres.
      $charRows = $lines >> 3;
      $ranges[] = [22528, $charRows * 32];

      // --- Ordenar por dirección de inicio ---
      usort($ranges, static fn($a, $b) => $a[0] <=> $b[0]);

      // --- Fusionar bloques adyacentes o solapados ---
      $blocks = [];
      [$start, $end] = [$ranges[0][0], $ranges[0][0] + $ranges[0][1]];

      foreach (array_slice($ranges, 1) as [$s, $l]) {
          if ($s <= $end) {
              $end = max($end, $s + $l);
          } else {
              $blocks[] = ['offset' => $start, 'length' => $end - $start];
              [$start, $end] = [$s, $s + $l];
          }
      }
      $blocks[] = ['offset' => $start, 'length' => $end - $start];

      return $blocks;
  }

    // Main

    if ($argc != 3) {
        echo "Usage: php ZXsplitter.php <file> <lines>\n";
        exit(1);
    }

    $lines = (int)$argv[2]
        ?: die("Invalid number of lines: {$argv[2]}\n");

        if ($lines < 8 || $lines > 192) {
            die("Lines must be between 8 and 192.\n");
        }
    
    if ($lines % 8) {
        die("Lines must be a multiple of 8.\n");
    }

  if (!file_exists($argv[1])) {
      die("File not found: {$argv[1]}\n");  
    }
    $scr = file_get_contents($argv[1]);
    if (strlen($scr) != 6912) {
        die("File too small to be a valid Spectrum screen.\n");
    }

    echo "Processing file: {$argv[1]}, Lines: $lines\n";
    $blocks = spectrumScreenBlocks($lines);
    
    // Dump each block using into a new file. Have in mind the $scr array has a base index of 0, but
    // the offsets are based on the Spectrum memory map, so we need to adjust them by -16384 to read the data correctly.
    // Each file will name named as the original file, but adding a suffix with the offset in the Spectrum memory map and
    // an new extension .prt (for "partial"). For instance if first block is from 16384 with a size of 512, you dump
    // 512 from offset 0 of the $scr array into a file named "originalfilename_16384.prt" 
    foreach ($blocks as ['offset' => $offset, 'length' => $length]) 
    {
        $data = substr($scr, $offset - 16384, $length);
        $filename = sprintf("%s_%05d.prt", pathinfo($argv[1], PATHINFO_FILENAME), $offset);
        file_put_contents($filename, $data);
        echo "Created block file: $filename (offset: $offset, length: $length)\n";
    }

    

