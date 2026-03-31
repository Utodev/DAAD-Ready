@echo off
echo -- English: This will delete all files from RELEASE folder, leaving them empty but for the "readme.txt " files that were originally there.
echo -- Spanish: Se van a borrar todos los ficheros de la carpeta RELEASE, excepto los "readme.txt " que ya estaban originalmente.
choice /C NY /N /M "Are your sure? [Y/N]"
if errorlevel 2 (
    echo "DAAD-Ready" > readme.txt

    echo Cleaning Commodore 64...
    md C64 > nul 2>&1
    del /q /s C64\*.* > nul 2>&1
    copy readme.txt C64 > nul 2>&1

    echo Cleaning Commodore Amiga...
    md AMIGA> nul 2>&1
    del /q /s AMIGA\*.* > nul 2>&1
    del /q /s AMIGA\s\*.* > nul 2>&1
    rd AMIGA\s > nul 2>&1
    copy readme.txt AMIGA > nul 2>&1 

    echo Cleaning Commodore Plus/4...
    md CPLUS4 > nul 2>&1
    del /q /s CPLUS4\*.* > nul 2>&1
    copy readme.txt CPLUS4 > nul 2>&1

    echo Cleaning Amstrad CPC 664...
    md CPC664 > nul 2>&1
    del /q /s CPC664\*.* > nul 2>&1
    copy readme.txt CPC664 > nul 2>&1


    echo Cleaning Amstrad CPC 6128...
    md CPC6128 > nul 2>&1
    del /q /s CPC6128\*.* > nul 2>&1
    copy readme.txt CPC6128 > nul 2>&1

    echo Cleaning Amstrad PCW...
    md PCW> nul 2>&1
    del /q /s PCW\*.* > nul 2>&1
    copy readme.txt PCW > nul 2>&1

    echo Cleaning MSX1...
    md MSX1> nul 2>&1
    del /q /s MSX1\*.* > nul 2>&1
    copy readme.txt MSX1 > nul 2>&1

    echo Cleaning MSX2...
    md MSX2> nul 2>&1
    del /q /s MSX2\*.* > nul 2>&1
    copy readme.txt MSX2 > nul 2>&1

    echo Cleaning ZX Spectrum 48K...
    md ZX48K> nul 2>&1
    del /q /s ZX48K\*.* > nul 2>&1
    copy readme.txt ZX48K > nul 2>&1

    echo Cleaning ZX Spectrum +3...
    md ZXPLUS3> nul 2>&1
    del /q /s ZXPLUS3\*.* > nul 2>&1
    copy readme.txt ZXPLUS3 > nul 2>&1

    echo Cleaning ZX Spectrum +3 EXPERIMENTAL...
    md ZXPLUS3_EXPERIMENTAL> nul 2>&1
    del /q /s ZXPLUS3_EXPERIMENTAL\*.* > nul 2>&1
    copy readme.txt ZXPLUS3_EXPERIMENTAL > nul 2>&1

    echo Cleaning ZX Spectrum 128K tape experimental...
    md ZX128K_EXPERIMENTAL> nul 2>&1
    del /q /s ZX128K_EXPERIMENTAL\*.* > nul 2>&1
    copy readme.txt ZX128K_EXPERIMENTAL > nul 2>&1

    echo Cleaning ZX Spectrum 128K tape...
    md ZX128K> nul 2>&1
    del /q /s ZX128K\*.* > nul 2>&1
    copy readme.txt ZX128K   > nul 2>&1

    echo Cleaning ZX Spectrum 128K disk...
    md ZXPLUS3> nul 2>&1
    del /q /s ZXPLUS3\*.* > nul 2>&1
    copy readme.txt ZXPLUS3 > nul 2>&1

    echo Cleaning ZX Spectrum ESXDOS...
    md ZXESXDOS > nul 2>&1
    del /q /s ZXESXDOS\*.* > nul 2>&1
    copy readme.txt ZXESXDOS > nul 2>&1

    echo Cleaning ZX Spectrum Next...
    md ZXNEXT> nul 2>&1
    del /q /s ZXNEXT\*.* > nul 2>&1
    copy readme.txt ZXNEXT > nul 2>&1
   
    echo Cleaning ZX-Uno...
    md ZXUNO> nul 2>&1
    del /q /s ZXUNO\*.* > nul 2>&1
    del /q /s ZXUNO\SYS\*.* > nul 2>&1
    rd ZXUNO\SYS > nul 2>&1
    copy readme.txt ZXUNO > nul 2>&1 

    echo Cleaning Atari ST...
    md ATARIST> nul 2>&1
    del /q /s ATARIST\*.* > nul 2>&1
    copy readme.txt ATARIST > nul 2>&1

    echo Cleaning IBM PC MS-DOS...
    md PC> nul 2>&1
    del /s /q PC\*.* > nul 2>&1
    del /s /q PC\GAME\*.* > nul 2>&1
    rd PC\GAME> nul 2>&1
    copy readme.txt PC > nul 2>&1

    echo Cleaning HTML...
    md HTML > nul 2>&1
    del /q /s HTML\*.* > nul 2>&1
    copy readme.txt  HTML > nul 2>&1

    echo Cleaning WINDOWS...
    md WINDOWS > nul 2>&1
    del /q /s WINDOWS\*.* > nul 2>&1
    copy readme.txt  WINDOWS > nul 2>&1


    echo Cleaning WINDOWS_EXPERIMENTAL...
    md WINDOWS_EXPERIMENTAL > nul 2>&1
    del /q /s WINDOWS_EXPERIMENTAL\*.* > nul 2>&1
    copy readme.txt  WINDOWS_EXPERIMENTAL > nul 2>&1

    echo Cleaning MACOS_EXPERIMENTAL...
    md MACOS_EXPERIMENTAL > nul 2>&1
    del /q /s MACOS_EXPERIMENTAL\*.* > nul 2>&1
    copy readme.txt  MACOS_EXPERIMENTAL > nul 2>&1


    del readme.txt > nul 2>&1
    pause   

)

