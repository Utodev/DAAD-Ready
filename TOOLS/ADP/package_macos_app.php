<?php

function fail($message)
{
    echo $message . "\n";
    exit(1);
}

function add_path_to_archive($archive, $sourceRoot, $relativePath, $gameName)
{
    $fullPath = $sourceRoot;
    if ($relativePath != '')
    {
        $fullPath .= DIRECTORY_SEPARATOR . $relativePath;
    }

    if (is_dir($fullPath))
    {
        if ($relativePath != '')
        {
            $archive->addEmptyDir(str_replace('\\', '/', $relativePath));
        }

        $entries = scandir($fullPath);
        if ($entries === false)
        {
            fail("Unable to scan directory: " . $fullPath);
        }

        foreach ($entries as $entry)
        {
            if ($entry == '.' || $entry == '..')
            {
                continue;
            }

            if ($relativePath == '')
            {
                $childRelative = $entry;
            }
            else
            {
                $childRelative = $relativePath . DIRECTORY_SEPARATOR . $entry;
            }

            add_path_to_archive($archive, $sourceRoot, $childRelative, $gameName);
        }

        return;
    }

    $archivePath = str_replace('\\', '/', $relativePath);
    $archive->addFile($fullPath, $archivePath);

    $mode = 0644;
    if (substr($archivePath, -8) == '.command')
    {
        $mode = 0755;
    }
    if ($archivePath == $gameName . '.app/Contents/MacOS/ADP')
    {
        $mode = 0755;
    }

    $archive[$archivePath]->chmod($mode);
}

if ($argc < 3)
{
    fail("Usage: php package_macos_app.php <release-dir> <game-name>");
}

$releaseDir = rtrim($argv[1], "\\/");
$gameName = $argv[2];

if (!is_dir($releaseDir))
{
    fail("Release directory not found: " . $releaseDir);
}

$appPath = $releaseDir . DIRECTORY_SEPARATOR . $gameName . '.app';
if (!is_dir($appPath))
{
    fail("App bundle not found: " . $appPath);
}

$helperPath = $releaseDir . DIRECTORY_SEPARATOR . 'OPEN_ON_MAC.command';
$helper = fopen($helperPath, 'wb');
if ($helper === false)
{
    fail("Unable to write helper launcher: " . $helperPath);
}
fwrite($helper, "#!/bin/sh\n");
fwrite($helper, "set -e\n");
fwrite($helper, "cd \"\$(dirname \"$0\")\"\n");
fwrite($helper, "xattr -dr com.apple.quarantine \"" . $gameName . ".app\" 2>/dev/null || true\n");
fwrite($helper, "chmod +x \"" . $gameName . ".app/Contents/MacOS/ADP\" 2>/dev/null || true\n");
fwrite($helper, "open \"" . $gameName . ".app\"\n");
fclose($helper);

$readmePath = $releaseDir . DIRECTORY_SEPARATOR . 'README-MACOS.txt';
$readme = fopen($readmePath, 'wb');
if ($readme === false)
{
    fail("Unable to write README: " . $readmePath);
}
fwrite($readme, "MacOS experimental package for " . $gameName . "\r\n\r\n");
fwrite($readme, "Recommended first run on a real Mac:\r\n");
fwrite($readme, "1. Extract this tar.gz on the Mac.\r\n");
fwrite($readme, "2. Open Terminal in the extracted folder.\r\n");
fwrite($readme, "3. Run: bash OPEN_ON_MAC.command\r\n\r\n");
fwrite($readme, "That helper removes the quarantine flag from the app bundle, restores the executable bit on the ADP binary, and opens the app.\r\n");
fclose($readme);

$tarPath = $releaseDir . DIRECTORY_SEPARATOR . $gameName . '-macos.tar';
$tgzPath = $tarPath . '.gz';
if (file_exists($tgzPath))
{
    unlink($tgzPath);
}
if (file_exists($tarPath))
{
    unlink($tarPath);
}

try
{
    $archive = new PharData($tarPath);
    add_path_to_archive($archive, $releaseDir, $gameName . '.app', $gameName);
    add_path_to_archive($archive, $releaseDir, 'OPEN_ON_MAC.command', $gameName);
    add_path_to_archive($archive, $releaseDir, 'README-MACOS.txt', $gameName);
    $archive->compress(Phar::GZ);
    unset($archive);

    if (file_exists($tarPath))
    {
        unlink($tarPath);
    }
}
catch (Exception $exception)
{
    if (file_exists($tarPath))
    {
        unlink($tarPath);
    }

    fail($exception->getMessage());
}
