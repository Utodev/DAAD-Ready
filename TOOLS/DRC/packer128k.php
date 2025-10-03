<?php

$verbose = false;

// This program takes a 0.XMB file (if exists) and severa .128 image files (if exists) 
// And tries to place them properly into 16K pages of a 128K ZX Spectrum
// It may use pages 3, 4, 6, 7 and part of page 1

// This program just looks in the current folder for the 0.XMB file and in the IMAGES folder 
// for the .128 files



function getFileFromFile($inputFilename, $outpuFilename, $start, $length) 
{
    $inputFile = fopen($inputFilename, "rb");
    fseek($inputFile, $start);
    $data = fread($inputFile, $length); 
    fclose($inputFile);
    
    $outputFile = fopen($outpuFilename, "wb");
    fwrite($outputFile, $data);
    fclose($outputFile); 
}


/**
 * Pack pages with two file sets:
 *   - priority files: MUST be at offset 0 (each on an empty page)
 *   - normal files  : packed tightly with ≤256B gap and as few pages as possible
 *
 * @param array $pages [pageNo => bytes_left]               // if <16384, page head already used
 * @param array $files [filename => size]                   // normal files (indivisible)
 * @param array $priority_files [filename => size]          // MUST be placed at offset 0 (one per empty page)
 * @param int   $pageSize default 16384
 * @param int   $slackCap default 256
 *
 * @return array {
 *   placement:          [filename => ['page'=>int,'offset'=>int]], // both normal + priority
 *   leftover:           [pageNo => bytes_left_after],
 *   unplaced:           [filename => size],            // normal files that didn't fit
 *   unplaced_priority:  [filename => size],            // priority files that couldn't get a clean page (shouldn't happen per your note)
 *   pages_used:         int
 * }
 */
function fastPack(array $pages, $files, $priority_files, $pageSize = 16384, $slackCap = 256)
{
    // ---- Build page state ----
    // initial_offset lets us know if a page had head content (cannot be "closed")
    $state = []; // pageNo => ['offset'=>int,'free'=>int,'files'=>[name=>size],'initial_offset'=>int,'has_priority'=>bool]
    $activePages = []; // pages we can/should pack into before opening new ones
    $idlePages   = []; // pages that are truly empty at start (offset==0, free==pageSize)

    foreach ($pages as $p => $free) {
        $offset = $pageSize - $free; // head already used if > 0
        if ($offset < 0 || $offset > $pageSize) {
            throw new RuntimeException("Page $p has inconsistent bytes_left=$free");
        }
        $state[$p] = [
            'offset'         => $offset,
            'free'           => $free,
            'files'          => [],
            'initial_offset' => $offset,
            'has_priority'   => false,
        ];
        if ($offset > 0) {
            $activePages[$p] = true;         // page already has head data: consider it active
        } else {
            $idlePages[$p] = true;           // pristine page (eligible for priority@offset0)
        }
    }

    $placement = [];
    $unplaced = [];
    $unplaced_priority = [];

    // ---- STEP 1: Place PRIORITY files at offset 0 on empty pages ----
    // You guaranteed #priority_files <= #pages; we still keep a guard if not enough empty pages exist.
    arsort($priority_files); // big ones first

    foreach ($priority_files as $name => $size) {
        if ($size > $pageSize) { // impossible to place
            $unplaced_priority[$name] = $size;
            continue;
        }
        // Find an idle page (offset==0)
        $chosen = null;
        foreach ($idlePages as $p => $_) {
            // pristine page: free==pageSize, offset==0
            $chosen = $p;
            break;
        }
        if ($chosen === null) {
            // No clean pages left (shouldn't happen per your note, but handled)
            $unplaced_priority[$name] = $size;
            continue;
        }

        // Place priority file at offset 0
        $placement[$name] = ['page' => $chosen, 'offset' => 0];
        $state[$chosen]['files'][$name] = $size;
        $state[$chosen]['offset'] = $size;
        $state[$chosen]['free']   = $pageSize - $size;
        $state[$chosen]['has_priority'] = true;

        // Page is no longer idle
        unset($idlePages[$chosen]);
        $activePages[$chosen] = true;
    }

    // ---- STEP 2: Pack NORMAL files (active-first, ≤slackCap, minimal pages) ----
    arsort($files); // largest-first

    // helper to place on a page tail
    $placeOnPage = function (int $page, string $name, int $size) use (&$state, &$placement, &$activePages) {
        $off = $state[$page]['offset'];
        $placement[$name] = ['page' => $page, 'offset' => $off];
        $state[$page]['offset'] += $size;
        $state[$page]['free']   -= $size;
        $state[$page]['files'][$name] = $size;
        $activePages[$page] = true;
    };

    foreach ($files as $name => $size) {
        if ($size > $pageSize) { $unplaced[$name] = $size; continue; }

        // Try ACTIVE pages first (prefer slack <= slackCap, minimize slack)
        $bestActive = null; $bestSlack = PHP_INT_MAX;
        $fallbackActive = null; $fallbackFree = -1;

        foreach ($activePages as $p => $_) {
            if ($state[$p]['free'] < $size) continue;
            $slack = $state[$p]['free'] - $size;
            if ($slack <= $slackCap && $slack < $bestSlack) {
                $bestSlack = $slack;
                $bestActive = $p;
                if ($slack === 0) break;
            }
            if ($state[$p]['free'] > $fallbackFree) {
                $fallbackFree = $state[$p]['free'];
                $fallbackActive = $p;
            }
        }

        if ($bestActive !== null) { $placeOnPage($bestActive, $name, $size); continue; }
        if ($fallbackActive !== null && $state[$fallbackActive]['free'] >= $size) { $placeOnPage($fallbackActive, $name, $size); continue; }

        // No active page fits: open a new (idle) page only if needed
        $bestIdle = null; $bestIdleSlack = PHP_INT_MAX;
        $fallbackIdle = null; $fallbackIdleFree = -1;

        foreach ($idlePages as $p => $_) {
            if ($state[$p]['free'] < $size) continue; // (file > page size)
            $slack = $state[$p]['free'] - $size;
            if ($slack <= $slackCap && $slack < $bestIdleSlack) {
                $bestIdleSlack = $slack;
                $bestIdle = $p;
                if ($slack === 0) break;
            }
            if ($state[$p]['free'] > $fallbackIdleFree) {
                $fallbackIdleFree = $state[$p]['free'];
                $fallbackIdle = $p;
            }
        }

        $chosen = ($bestIdle !== null) ? $bestIdle : $fallbackIdle;
        if ($chosen !== null) {
            unset($idlePages[$chosen]);
            $placeOnPage($chosen, $name, $size);
        } else {
            $unplaced[$name] = $size;
        }
    }

    // ---- STEP 3 (quick polish): tuck tiny files (<= slackCap) into tiny gaps (<= slackCap) ----
    // This is optional but cheap and often improves leftovers without opening pages.
    $smallFiles = [];
    foreach ($placement as $fn => $_) {
        if (isset($files[$fn]) && $files[$fn] <= $slackCap) {
            $smallFiles[$fn] = $files[$fn];
        }
    }
    asort($smallFiles);

    $moves = 0; $moveLimit = 200;
    foreach ($state as $target => $st) {
        if ($st['free'] <= 0 || $st['free'] > $slackCap) continue;
        $gap = $st['free'];

        foreach ($smallFiles as $fn => $sz) {
            if ($moves >= $moveLimit) break 2;
            if (!isset($placement[$fn])) continue;
            $src = $placement[$fn]['page'];
            if ($src === $target) continue;
            if ($sz > $gap) continue;

            // move fn from src -> target (append-at-tail model)
            unset($state[$src]['files'][$fn]);
            $state[$src]['offset'] -= $sz;
            $state[$src]['free']   += $sz;

            $off = $state[$target]['offset'];
            $state[$target]['files'][$fn] = $sz;
            $state[$target]['offset'] += $sz;
            $state[$target]['free']   -= $sz;
            $placement[$fn] = ['page' => $target, 'offset' => $off];

            $gap = $state[$target]['free'];
            $moves++;
            if ($gap <= 0) break;
        }
    }

    // ---- STEP 4: Drain & close lightly-used pages (but NEVER pages with head or priority) ----
    // Candidate pages to try to empty = active pages that:
    //   - have NO priority file, and
    //   - had initial_offset == 0 (no unavoidable head)
    $candidates = [];
    foreach ($activePages as $p => $_) {
        if ($state[$p]['has_priority']) continue;
        if ($state[$p]['initial_offset'] > 0) continue; // had head -> cannot close
        $usedByFiles = array_sum($state[$p]['files']);
        if ($usedByFiles > 0) $candidates[$p] = $usedByFiles;
    }
    asort($candidates); // drain least-filled first

    foreach ($candidates as $src => $usedByFiles) {
        $filesOnSrc = $state[$src]['files'];
        if (empty($filesOnSrc)) continue;

        arsort($filesOnSrc); // move larger first
        $migratedAll = true;

        foreach ($filesOnSrc as $fn => $sz) {
            // pick best destination among active pages (excluding src)
            $dest = null; $bestSlack = PHP_INT_MAX;

            foreach ($activePages as $p => $_) {
                if ($p === $src) continue;
                if ($state[$p]['free'] < $sz) continue;
                $slack = $state[$p]['free'] - $sz;
                if ($slack <= $slackCap && $slack < $bestSlack) {
                    $bestSlack = $slack;
                    $dest = $p;
                    if ($slack === 0) break;
                }
            }
            if ($dest === null) {
                // fallback: most-free active page (excluding src)
                $maxFree = -1; $maxP = null;
                foreach ($activePages as $p => $_) {
                    if ($p === $src) continue;
                    if ($state[$p]['free'] >= $sz && $state[$p]['free'] > $maxFree) {
                        $maxFree = $state[$p]['free']; $maxP = $p;
                    }
                }
                $dest = $maxP;
            }
            if ($dest === null) { $migratedAll = false; break; }

            // move fn
            unset($state[$src]['files'][$fn]);
            $state[$src]['offset'] -= $sz;
            $state[$src]['free']   += $sz;

            $off = $state[$dest]['offset'];
            $state[$dest]['files'][$fn] = $sz;
            $state[$dest]['offset'] += $sz;
            $state[$dest]['free']   -= $sz;
            $placement[$fn] = ['page' => $dest, 'offset' => $off];
        }

        // If emptied, mark page idle (completely free) again
        if ($migratedAll && array_sum($state[$src]['files']) === 0 && $state[$src]['offset'] === 0) {
            unset($activePages[$src]);
            $idlePages[$src] = true;
            $state[$src]['free'] = $pageSize;
        }
    }

    // ---- Outputs ----
    $leftover = [];
    foreach ($state as $p => $st) $leftover[$p] = $st['free'];

    $pagesUsed = 0;
    foreach ($state as $p => $st) {
        $hasHead   = ($st['initial_offset'] > 0);     // page had unavoidable head
        $hasFiles  = !empty($st['files']);            // we placed something
        if ($hasHead || $hasFiles) $pagesUsed++;
    }

    return [
        'placement'          => $placement,
        'leftover'           => $leftover,
        'unplaced'           => $unplaced,
        'unplaced_priority'  => $unplaced_priority,
        'pages_used'         => $pagesUsed,
    ];
}

// ****************** MAIN *****************************
// each page and its free space
$pages = array(1=>16384-6912-512, 3=>16384, 4=>16384, 6=>16384, 7=>16384);

$files_to_process = array();
$priority_files_to_process = array();

$xmb_file= '0.XMB';
$xmb_filesize = filesize($xmb_file);
if (file_exists($xmb_file)) 
{
    $xmb_filesize = filesize($xmb_file);
    for ($i=0;$i<=3;$i++)    
        if ($xmb_filesize > 16384 * $i) 
        {
            $partFilename = "{$i}.PT";
            getFileFromFile($xmb_file, $partFilename, 16384*$i, 16384);
            $priority_files_to_process[$partFilename]=filesize($partFilename);
        }
}
// Find all .128 in the IMAGES folder
$images_folder = 'IMAGES';
if (is_dir($images_folder)) 
{
    $dir = opendir($images_folder);
    while (($file = readdir($dir)) !== false) 
    {
        if (preg_match('/^([0-9]{1,3})\.128$/', $file, $matches)) 
        {
            $filename = $images_folder . '/' . $file;
            $files_to_process[$matches[1]] = filesize($filename);
        }
    }
    closedir($dir);
}




$result = fastPack($pages, $files_to_process, $priority_files_to_process, 16384, 56);

    

// Build the indexes
$imageIndex = [];
$xmessageIndex =[];
foreach ($result['placement'] as $filename => $placement) 
{
    $page = $placement['page'];
    $offset = $placement['offset'];
    if (isset($files_to_process[$filename])) 
    {
        $size = $files_to_process[$filename];
    }
    else
    {
        $size = $priority_files_to_process[$filename];
    }   

    if (preg_match('/^([0-9]{1,3})\.PT$/', $filename)) 
    {
        // XMB file
        $xmessageIndex[$filename] = ['page' => $page, 'offset' => $offset, 'size' => $size];
    } 
    else 
    {
        // Image file
        $imageIndex[$filename] = ['page' => $page, 'offset' => $offset, 'size' => $size];
    }
}



if ($result['unplaced']) 
{
    echo "The following files could not be placed (no enough RAM or cannot fit in RAM):\n";
    foreach ($result['unplaced'] as $filename => $size) 
    {
        echo "$filename (size $size)\n\n";
    }
    echo "Consider reducing the size of some images by making them simpler so they compress better, or shorten the length of some MESSAGE/MES/XMESSAGE.\n";
    exit(1);
} 

// Prepare the pages
// No lets create a new index for the images, where image are listed sorted by filename
$sortedImageIndex = [];
foreach ($imageIndex as $filename => $index) 
{
    $sortedImageIndex[$filename] = $index;
}
ksort($sortedImageIndex);


// Let's do the same for the XMB files
$sortedXMessageIndex = [];
foreach ($xmessageIndex as $filename => $index) 
{
    $sortedXMessageIndex[$filename] = $index;
}
ksort($sortedXMessageIndex);

// Now create a new array $pageContent, where in each page we have an array of the files matching
// that page
$pageContent = [];

foreach ($result['placement'] as $filename => $placement) 
{
    $page = $placement['page'];
    if (!isset($pageContent[$page])) 
    {
        $pageContent[$page] = [];
    }
    $pageContent[$page][] = [
        'filename' => $filename,
        'offset' => $placement['offset'],
        'size' => isset($files_to_process[$filename]) ? $files_to_process[$filename] : $priority_files_to_process[$filename]
    ];
}

//Now sort each element of $pageContent by offset
foreach ($pageContent as $page => &$files)
{
    usort($files, function($a, $b) {
        return $a['offset'] - $b['offset'];
    });
}


// Dump the files
 foreach ($pageContent as $page => $files) 
    {
        if ($verbose) echo "Dumping page $page:\n";
        $outputFile = fopen("PAGE{$page}.BIN", 'wb');
        $currentOffset = 0;
        foreach ($files as $file) 
        {
            $filename = $file['filename'];
            
            
            $offset = $file['offset'];
            $size = $file['size'];

            if ($currentOffset < $offset) 
            {
                fwrite($outputFile, str_repeat("\0", $offset - $currentOffset));
                $currentOffset = $offset;
            }

            if ($verbose) echo "  Wrote $filename at offset " . dechex($offset) . " with size " . dechex($size) . "\n";
            // If PT extension missing, it is an image file
            if (!preg_match('/\.PT$/', $filename))
            {
                $filename = "IMAGES/$filename.128";
            }

            // Write the file content
            $content = file_get_contents($filename);
            fwrite($outputFile, $content);
            $currentOffset += strlen($content);
        }
        fclose($outputFile);
    }


// And dump the indexes to a file named PAGEIDX.BIN.
//  First one byte per page used, starting by the ones that have the XMLB files in order (so first the page where P0.PT goes, then P1.PT if exists, etc.),
// then list the rest of pages used, in order of page number. Dump that as a byte per page, and then a byte 255 to indicate the end of the pages index.
//// After that, you dump the image index, where per each entry, you dump a byte with the image number (convert those 001 to 1, 022 to 22, etc.)
// then a byte with the page number, then a word with the offset, and finally a word with the size of the image. At the end you dump a byte 255 again.
// IMPORTANT: the image index must be sorted by image number, so the first entry is 1, then 2, etc.
$outputIndexFile = fopen("PAGEIDX.BIN", 'wb');
// First, write the pages used
$pagesUsed = array_keys($result['leftover']);
$usedPages = [];

// Add priority pages first
foreach ($sortedXMessageIndex as $filename => $index) {
    $usedPages[] = $index['page'];
}

// Then add the rest of pages used
foreach ($pagesUsed as $page) {
    if (!in_array($page, $usedPages)) {
        $usedPages[] = $page;
    }
}

// Write the used pages as bytes
foreach ($usedPages as $page) {
    fwrite($outputIndexFile, pack('C', $page));
}

// Write the end marker
fwrite($outputIndexFile, pack('C', 255));

// Now write the image index
foreach ($sortedImageIndex as $imageNumber => $index) {
    fwrite($outputIndexFile, pack('C', (int)$imageNumber)); // Image number as byte
    fwrite($outputIndexFile, pack('v', $index['offset'] +0xC000)); // Offset as word, already moved to the C000 area
    fwrite($outputIndexFile, pack('v', $index['size'])); // Size as word
    fwrite($outputIndexFile, pack('C', $index['page'])); // Page number as byte
    $realOffset = $index['offset'] + 0xC000; // Adjust offset to C000 area
}

// Write the end marker again
fwrite($outputIndexFile, pack('C', 255));

fclose($outputIndexFile);

// Now open the file PAGEIDX.BIN and save another file named INDEX.BIN where the bytes are in inverse 
// order, so the first byte is the last byte of PAGEIDX.BIN, the second byte is the second to last byte of PAGEIDX.BIN, etc.
$indexFile = fopen("INDEX.BIN", 'wb');
$indexContent = file_get_contents("PAGEIDX.BIN");
if ($indexContent !== false) 
    {
        $reversedContent = strrev($indexContent);
        fwrite($indexFile, $reversedContent);
        fclose($indexFile);
    }
//unlink("PAGEIDX.BIN"); // Remove the original PAGEIDX.BIN file    