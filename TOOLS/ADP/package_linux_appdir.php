<?php

function fail($message)
{
    echo $message . "\n";
    exit(1);
}

function ensure_directory($path)
{
    if (is_dir($path))
    {
        return;
    }

    if (!mkdir($path, 0777, true) && !is_dir($path))
    {
        fail("Unable to create directory: " . $path);
    }
}

function write_file($path, $contents)
{
    $handle = fopen($path, 'wb');
    if ($handle === false)
    {
        fail("Unable to write file: " . $path);
    }
    fwrite($handle, $contents);
    fclose($handle);
}

function add_path_to_archive($archive, $sourceRoot, $relativePath)
{
    $fullPath = $sourceRoot;
    if ($relativePath !== '')
    {
        $fullPath .= DIRECTORY_SEPARATOR . $relativePath;
    }

    if (is_dir($fullPath))
    {
        if ($relativePath !== '')
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
            if ($entry === '.' || $entry === '..')
            {
                continue;
            }

            $childRelative = ($relativePath === '') ? $entry : $relativePath . DIRECTORY_SEPARATOR . $entry;
            add_path_to_archive($archive, $sourceRoot, $childRelative);
        }

        return;
    }

    $archivePath = str_replace('\\', '/', $relativePath);
    $archive->addFile($fullPath, $archivePath);

    $mode = 0644;
    $basename = basename($archivePath);
    if (substr($basename, -3) === '.sh' || $basename === 'AppRun' || $basename === 'ADP')
    {
        $mode = 0755;
    }

    $archive[$archivePath]->chmod($mode);
}

if ($argc < 3)
{
    fail("Usage: php package_linux_appdir.php <release-dir> <game-name>");
}

$releaseDir = rtrim($argv[1], "\\/");
$gameName = $argv[2];
$bundleDir = $releaseDir . DIRECTORY_SEPARATOR . $gameName . '-linux';
$appDir = $bundleDir . DIRECTORY_SEPARATOR . 'AppDir';
$gameDir = $appDir . DIRECTORY_SEPARATOR . 'usr' . DIRECTORY_SEPARATOR . 'share' . DIRECTORY_SEPARATOR . 'daad-ready' . DIRECTORY_SEPARATOR . 'game';
$playerPath = $appDir . DIRECTORY_SEPARATOR . 'usr' . DIRECTORY_SEPARATOR . 'bin' . DIRECTORY_SEPARATOR . 'ADP';

if (!is_dir($bundleDir))
{
    fail("Linux bundle not found: " . $bundleDir);
}
if (!is_dir($appDir))
{
    fail("AppDir not found: " . $appDir);
}
if (!is_dir($gameDir))
{
    fail("Game directory not found: " . $gameDir);
}
if (!is_file($playerPath))
{
    fail("Linux player not found: " . $playerPath);
}

ensure_directory($appDir);

$desktopName = $gameName . '.desktop';
$desktopPath = $appDir . DIRECTORY_SEPARATOR . $desktopName;
$desktop = "[Desktop Entry]\n";
$desktop .= "Type=Application\n";
$desktop .= "Name=" . $gameName . "\n";
$desktop .= "Exec=ADP\n";
$desktop .= "Icon=" . $gameName . "\n";
$desktop .= "Categories=Game;AdventureGame;\n";
$desktop .= "Terminal=false\n";
write_file($desktopPath, $desktop);

$appRunPath = $appDir . DIRECTORY_SEPARATOR . 'AppRun';
$appRun = "#!/bin/sh\n";
$appRun .= "set -e\n";
$appRun .= "HERE=\"\$(CDPATH= cd -- \"\$(dirname -- \"\$0\")\" && pwd)\"\n";
$appRun .= "GAME_DIR=\"\$HERE/usr/share/daad-ready/game\"\n";
$appRun .= "exec \"\$HERE/usr/bin/ADP\" \"\$GAME_DIR\" \"\$@\"\n";
write_file($appRunPath, $appRun);

$runPath = $bundleDir . DIRECTORY_SEPARATOR . 'RUN_ON_LINUX.sh';
$run = "#!/bin/sh\n";
$run .= "set -e\n";
$run .= "HERE=\"\$(CDPATH= cd -- \"\$(dirname -- \"\$0\")\" && pwd)\"\n";
$run .= "chmod +x \"\$HERE/AppDir/AppRun\" \"\$HERE/AppDir/usr/bin/ADP\" 2>/dev/null || true\n";
$run .= "exec \"\$HERE/AppDir/AppRun\" \"\$@\"\n";
write_file($runPath, $run);

$buildPath = $bundleDir . DIRECTORY_SEPARATOR . 'BUILD_APPIMAGE_ON_LINUX.sh';
$build = "#!/bin/sh\n";
$build .= "set -e\n";
$build .= "HERE=\"\$(CDPATH= cd -- \"\$(dirname -- \"\$0\")\" && pwd)\"\n";
$build .= "APPDIR=\"\$HERE/AppDir\"\n";
$build .= "OUTPUT=\"" . $gameName . "-x86_64.AppImage\"\n";
$build .= "chmod +x \"\$APPDIR/AppRun\" \"\$APPDIR/usr/bin/ADP\" 2>/dev/null || true\n";
$build .= "if [ -x \"\$HERE/appimagetool-x86_64.AppImage\" ]; then\n";
$build .= "    APPIMAGETOOL=\"\$HERE/appimagetool-x86_64.AppImage\"\n";
$build .= "elif command -v appimagetool >/dev/null 2>&1; then\n";
$build .= "    APPIMAGETOOL=appimagetool\n";
$build .= "else\n";
$build .= "    echo \"appimagetool was not found. Copy appimagetool-x86_64.AppImage into this folder or install appimagetool on Linux.\" >&2\n";
$build .= "    exit 1\n";
$build .= "fi\n";
$build .= "ARCH=x86_64 \"\$APPIMAGETOOL\" \"\$APPDIR\" \"\$OUTPUT\"\n";
$build .= "echo \"Created \$OUTPUT\"\n";
write_file($buildPath, $build);

$readmePath = $bundleDir . DIRECTORY_SEPARATOR . 'README-LINUX.txt';
$readme = "Linux experimental package for " . $gameName . "\r\n\r\n";
$readme .= "Contents:\r\n";
$readme .= "- AppDir/: staged application directory containing the ADP Linux player and your game data.\r\n";
$readme .= "- RUN_ON_LINUX.sh: runs the unpacked bundle directly on Linux.\r\n";
$readme .= "- BUILD_APPIMAGE_ON_LINUX.sh: builds the AppImage on Linux when appimagetool is available.\r\n\r\n";
$readme .= "Recommended steps on Linux:\r\n";
$readme .= "1. Extract this tar.gz archive.\r\n";
$readme .= "2. Open a terminal in the extracted folder.\r\n";
$readme .= "3. Test the unpacked game with: bash RUN_ON_LINUX.sh\r\n";
$readme .= "4. Create the AppImage with: bash BUILD_APPIMAGE_ON_LINUX.sh\r\n\r\n";
$readme .= "If BUILD_APPIMAGE_ON_LINUX.sh says appimagetool is missing, copy appimagetool-x86_64.AppImage into this folder or install appimagetool on the Linux machine and run the script again.\r\n";
write_file($readmePath, $readme);

$iconData = base64_decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+kZk8AAAAASUVORK5CYII=');
if ($iconData === false)
{
    fail("Unable to decode embedded icon.");
}
$iconPath = $appDir . DIRECTORY_SEPARATOR . $gameName . '.png';
write_file($iconPath, $iconData);
$dirIconPath = $appDir . DIRECTORY_SEPARATOR . '.DirIcon';
write_file($dirIconPath, $iconData);

$tarPath = $releaseDir . DIRECTORY_SEPARATOR . $gameName . '-linux.tar';
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
    add_path_to_archive($archive, $releaseDir, $gameName . '-linux');
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
