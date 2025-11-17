<?php

$current_version = "A1";


$lvStr = $latest_version = file_get_contents("https://www.ngpaws.com/downloads/DAAD/DAADReady/LATEST_VERSION_A_SERIES.TXT");
if ($latest_version===false) $lvStr = 'Unable to connect to server';
echo "DAAD Ready version (installed): $current_version\n";
echo "DAAD Ready version (last): $lvStr\n";

if ($latest_version===false) exit(0);

if ($latest_version!=$current_version)
{
    echo "******************************************\n";
    echo "**** NEW DAAD-READY VERSION AVAILABLE ****\n";
    echo "******************************************\n";  
    echo "\nPress enter to continue.\n";
    $handle = fopen ("php://stdin","r");
    $line = fgets($handle);
    fclose($handle);
}
