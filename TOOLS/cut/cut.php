<?php

// Implements cut binary file operation
// Syntax: cut.php <input_file> <output_file> <offset> <count>
// First byte is offset 0
// Negative offset means from the end of the file
// GPL v3 is applied to this code - (C) 2025 Uto

if ($argc != 5) {
    echo "Usage: cut.php <input_file> <output_file> <offset> <count>\n";
    exit(1);
}

$input_file = $argv[1];
$output_file = $argv[2];
$offset = (int)$argv[3];
$count = (int)$argv[4];

if (!file_exists($input_file)) {
    echo "Input file does not exist.\n";
    exit(1);
}

if (!is_readable($input_file)) {
    echo "Input file is not readable.\n";
    exit(1);
}

if (!is_writable(dirname($output_file))) {
    echo "Output file is not writable.\n";
    exit(1);
}

$file_size = filesize($input_file);

if ($offset < 0) {    
    $offset = $file_size + $offset;
}

if ($offset < 0) {
    echo "Invalid offset.\n";
}

if ($offset >= $file_size) {
    echo "Offset is beyond the end of the file.\n";
    exit(1);
}

if ($offset + $count > $file_size)
{
    echo "Lenghth goes beyond the end of the file.\n";
}

// Let's go

$input_handle = fopen($input_file, 'rb');
$output_handle = fopen($output_file, 'wb');

fseek($input_handle, $offset, SEEK_SET);
$buffer = fread($input_handle, $count);
fwrite($output_handle, $buffer);

fclose($input_handle);
fclose($output_handle);
