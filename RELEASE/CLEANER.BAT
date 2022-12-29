@echo off
echo -- This will delete all files from release folders, leaving them empty but for the "readme.txt " file that was already in there.
choice /C NY /N /M "Are your sure? [Y/N]"
if errorlevel 2 (
    echo "DAAD-Ready" > readme.txt

    echo Cleaning Commodore 64...
    md C64 > nul 2>&1
    del /q /s C64\*.* > nul 2>&1
    copy readme.txt C64 > nul 2>&1
    

    
    echo Cleaning HTML...
    md HTML > nul 2>&1
    del /q /s HTML\*.* > nul 2>&1
    copy readme.txt  HTML > nul 2>&1


    echo Cleaning Amstrad CPC...
    md CPC > nul 2>&1
    del /q /s CPC\*.* > nul 2>&1
    copy readme.txt CPC > nul 2>&1
    
    echo Cleaning Commodore Plus/4...
    md PLUS4 > nul 2>&1
    del /q /s PLUS4\*.* > nul 2>&1
    copy readme.txt PLUS4 > nul 2>&1

    echo Cleaning ZX Spectrum ESXDOS...
    md ESXDOS > nul 2>&1
    del /q /s ESXDOS\*.* > nul 2>&1
    copy readme.txt ESXDOS > nul 2>&1

    echo Cleaning MSX1...
    md MSX1> nul 2>&1
    del /q /s MSX1\*.* > nul 2>&1
    copy readme.txt MSX1 > nul 2>&1

    echo Cleaning MSX2...
    md MSX2> nul 2>&1
    del /q /s MSX2\*.* > nul 2>&1
    copy readme.txt MSX2 > nul 2>&1

    echo Cleaning Spectrum Next...
    md NEXT> nul 2>&1
    del /q /s NEXT\*.* > nul 2>&1
    copy readme.txt NEXT > nul 2>&1

    echo Cleaning Amstrad PCW...
    md PCW> nul 2>&1
    del /q /s PCW\*.* > nul 2>&1
    copy readme.txt PCW > nul 2>&1

    echo Cleaning ZX Spectrum +3...
    md PLUS3> nul 2>&1
    del /q /s PLUS3\*.* > nul 2>&1
    copy readme.txt PLUS3 > nul 2>&1

    
    echo Cleaning ZX-Uno...
    md UNO> nul 2>&1
    del /q /s UNO\*.* > nul 2>&1
    del /q /s UNO\SYS\*.* > nul 2>&1
    rd UNO\SYS > nul 2>&1
    copy readme.txt UNO > nul 2>&1

    echo Cleaning ZX Spectrum tape...
    md ZXTAPE> nul 2>&1
    del /q /s ZXTAPE\*.* > nul 2>&1
    copy readme.txt ZXTAPE > nul 2>&1

    echo Cleaning IBM PC MS-DOS...
    md MSDOS> nul 2>&1
    del /s /q MSDOS\*.* > nul 2>&1
    del /s /q MSDOS\GAME\*.* > nul 2>&1
    rd MSDOS\GAME> nul 2>&1
    copy readme.txt MSDOS > nul 2>&1

    echo Cleaning OLD IBM PC MS-DOS...
    md OLDMSDOS> nul 2>&1
    del /s /q OLDMSDOS\*.* > nul 2>&1
    del /s /q OLDMSDOS\GAME\*.* > nul 2>&1
    rd OLDMSDOS\GAME> nul 2>&1
    copy readme.txt OLDMSDOS > nul 2>&1


    echo Cleaning Atari ST...
    md ATARIST> nul 2>&1
    del /q /s ATARIST\*.* > nul 2>&1
    copy readme.txt ATARIST > nul 2>&1

    echo Cleaning Amiga...
    md AMIGA> nul 2>&1
    del /q /s AMIGA\*.* > nul 2>&1
    del /q /s AMIGA\s\*.* > nul 2>&1
    rd AMIGA\s > nul 2>&1
    copy readme.txt AMIGA > nul 2>&1 
    
    echo Cleaning ZX Spectrum 128K tape...
    md ZX128TAPE> nul 2>&1
    del /q /s ZX128TAPE\*.* > nul 2>&1
    copy readme.txt ZX128TAPE > nul 2>&1
    
    
    echo Cleaning ZX Spectrum 128K disk...
    md ZX128PLUS3> nul 2>&1
    del /q /s ZX128PLUS3\*.* > nul 2>&1
    copy readme.txt ZX128PLUS3 > nul 2>&1
    
    del readme.txt > nul 2>&1
    pause   

)
