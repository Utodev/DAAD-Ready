<?php
/**
 * CPCsplitter.php — Trims an Amstrad CPC .SCR file down to the first X
 * lines (X a multiple of 8) and splits the output into the resulting
 * contiguous RAM blocks.
 *
 * Usage:
 *   php CPCsplitter.php <name>.SCR <X>
 *
 * Output:
 *   <name>_<offset>.PRT   (one per contiguous RAM block)
 *   offset = real address in the CPC's RAM (decimal), assuming the
 *            .SCR starts at &C000.
 *
 * Background:
 * The CPC screen (16K, modes 0/1/2) is not laid out linearly: each
 * 2048-byte "band" holds one of the 8 pixel lines of every character
 * row, with 80 useful bytes per row and 25 rows max (200 lines).
 * Layout of a byte in the full screen:
 *     offset = row*80 + line*2048 + column      (0<=row<25, 0<=line<8)
 * If we only keep the first X lines (X a multiple of 8), we keep
 * N = X/8 full rows. Within each 2048-byte band we only keep the first
 * N*80 bytes: the rest of the band is discarded, and since normally
 * N*80 < 2048, each band becomes an independent contiguous RAM block
 * (8 blocks total, unless a block ends up empty).
 */

const BYTES_PER_LINE = 80;    // bytes per pixel line (fixed width, constant across all modes)
const LINES_PER_BAND = 8;     // pixel lines per memory band
const BAND_SIZE = 2048;       // byte spacing between bands
const MAX_ROWS = 25;          // max character rows (25*8 = 200 lines)
const RAM_BASE = 0xC000;      // start address of the SCR in the CPC's RAM
const AMSDOS_HEADER_SIZE = 128; // bytes

function fail($msg) {
    fwrite(STDERR, "Error: $msg\n");
    exit(1);
}

if ($argc < 3) {
    fail("usage: php {$argv[0]} <name>.SCR <X>\n" .
         "  X = number of lines to keep, a multiple of 8 (max " . (MAX_ROWS * LINES_PER_BAND) . ")");
}

$inputPath = $argv[1];
$x = (int)$argv[2];

if (!is_file($inputPath)) {
    fail("file '$inputPath' does not exist");
}
if ($x <= 0 || $x % LINES_PER_BAND !== 0) {
    fail("X must be a multiple of 8 (got: $x)");
}

$rows = intdiv($x, LINES_PER_BAND); // N character rows to keep
if ($rows > MAX_ROWS) {
    fail("X=$x exceeds the maximum of " . (MAX_ROWS * LINES_PER_BAND) . " lines");
}

$data = file_get_contents($inputPath);
if ($data === false) {
    fail("could not read '$inputPath'");
}

if (strlen($data) < AMSDOS_HEADER_SIZE) {
    fail("file is smaller than an AMSDOS header");
}

// Skip the 128-byte AMSDOS header.
$data = substr($data, AMSDOS_HEADER_SIZE);

$usefulBytesPerBand = $rows * BYTES_PER_LINE;

// output base name: strip the .scr extension (case-insensitive)
$directory = dirname($inputPath);
$base = basename($inputPath);
$base = preg_replace('/\.scr$/i', '', $base);

$generatedFiles = [];

for ($band = 0; $band < LINES_PER_BAND; $band++) {
    $bandStart = $band * BAND_SIZE;

    if ($bandStart >= strlen($data)) {
        // input file is shorter than a full screen
        break;
    }

    $chunk = substr($data, $bandStart, $usefulBytesPerBand);
    if ($chunk === '' || $chunk === false) {
        continue; // empty band, skip
    }

    $offset = RAM_BASE + $bandStart; // real address in the CPC's RAM (decimal)
    $outputPath = ($directory !== '.' ? $directory . DIRECTORY_SEPARATOR : '') . "{$base}_{$offset}.PRT";

    if (file_put_contents($outputPath, $chunk) === false) {
        fail("could not write '$outputPath'");
    }

    $generatedFiles[] = [$outputPath, $offset, strlen($chunk)];
}

if (empty($generatedFiles)) {
    fail("no block was generated (input file empty or too short?)");
}

echo "Generated " . count($generatedFiles) . " files:\n";
foreach ($generatedFiles as [$path, $offset, $size]) {
    printf("  %-40s offset=%-6d (0x%04X) size=%d bytes\n", $path, $offset, $offset, $size);
}
