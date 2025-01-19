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

    echo Cleaning Amstrad CPC...
    md CPC > nul 2>&1
    del /q /s CPC\*.* > nul 2>&1
    copy readme.txt CPC > nul 2>&1

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

    echo Cleaning ZX Spectrum tape...
    md ZXTAPE> nul 2>&1
    del /q /s ZXTAPE\*.* > nul 2>&1
    copy readme.txt ZXTAPE > nul 2>&1

    echo Cleaning ZX Spectrum +3...
    md PLUS3> nul 2>&1
    del /q /s PLUS3\*.* > nul 2>&1
    copy readme.txt PLUS3 > nul 2>&1

    echo Cleaning ZX Spectrum 128K tape...
    md ZX128TAPE> nul 2>&1
    del /q /s ZX128TAPE\*.* > nul 2>&1
    copy readme.txt ZX128TAPE > nul 2>&1

    echo Cleaning ZX Spectrum 128K disk...
    md ZX128PLUS3> nul 2>&1
    del /q /s ZX128PLUS3\*.* > nul 2>&1
    copy readme.txt ZX128PLUS3 > nul 2>&1

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
    md MSDOS> nul 2>&1
    del /s /q MSDOS\*.* > nul 2>&1
    del /s /q MSDOS\GAME\*.* > nul 2>&1
    rd MSDOS\GAME> nul 2>&1
    copy readme.txt MSDOS > nul 2>&1

    echo Cleaning legacy IBM PC MS-DOS ...
    md OLDMSDOS> nul 2>&1
    del /s /q OLDMSDOS\*.* > nul 2>&1
    del /s /q OLDMSDOS\GAME\*.* > nul 2>&1
    rd OLDMSDOS\GAME> nul 2>&1
    copy readme.txt OLDMSDOS > nul 2>&1

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

