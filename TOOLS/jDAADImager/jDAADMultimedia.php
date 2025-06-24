<?php

function syntax()
{
    echo "jDAADSounds 1.0 - Creates sounds.js and videos.js from jDAAD release folder\n\n";
    echo "SYNTAX: jDAADSounds <folder>\n\n";    
    exit(0);

}

function error($msg)
{
    echo "$msg.\n";
    exit(1);
}

if ($argc<2) syntax();



$inputFolder = $argv[1];

// ***********************************AUDIOS *************************

$outpuFilename = $inputFolder . DIRECTORY_SEPARATOR . 'sounds.js';

// Get the list of mp3 files in the input folder
$files = glob($inputFolder . '/*.mp3');
// Create the output file
$outputFile = fopen($outpuFilename, 'w');
if (!$outputFile) {
    error("Could not open output file: $outpuFilename");
}
// Write the header for the JavaScript file
fwrite($outputFile, "var jDAADSounds = [");
// Loop through each file and write it to the output file
foreach ($files as $file) {
    $filename = basename($file);
    $nameWithoutExtension = pathinfo($filename, PATHINFO_FILENAME);
    $nameWithoutExtension = str_replace(' ', '_', $nameWithoutExtension); // Replace spaces with underscores
    $number = intval($nameWithoutExtension);
    fwrite($outputFile, " $number,");
}
// Write the footer for the JavaScript file
fwrite($outputFile, "];\n");
// Close the output file
fclose($outputFile);

// ****************** VIDEOS ******************


$outpuFilename = $inputFolder . DIRECTORY_SEPARATOR . 'videos.js';

// Get the list of mp3 files in the input folder
$files = glob($inputFolder . '/*.mp4');
// Create the output file
$outputFile = fopen($outpuFilename, 'w');
if (!$outputFile) {
    error("Could not open output file: $outpuFilename");
}
// Write the header for the JavaScript file
fwrite($outputFile, "var jDAADVideos = [");
// Loop through each file and write it to the output file
foreach ($files as $file) {
    $filename = basename($file);
    $nameWithoutExtension = pathinfo($filename, PATHINFO_FILENAME);
    $nameWithoutExtension = str_replace(' ', '_', $nameWithoutExtension); // Replace spaces with underscores
    $number = intval($nameWithoutExtension);
    fwrite($outputFile, " $number,");
}
// Write the footer for the JavaScript file
fwrite($outputFile, "];\n");
// Close the output file
fclose($outputFile);

