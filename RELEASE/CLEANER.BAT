@echo off
echo -- This will delete all files from release folders, leaving them empty but for the "readme.txt " file that was already in there.
choice /C NY /N /M "Are your sure? [Y/N]"
if errorlevel 2 (
    copy c64\readme.txt > nul 2>&1

    cd c64
    echo Cleaning Commodore 64...
    del /q /s *.* > nul 2>&1
    copy ..\readme.txt > nul 2>&1
    cd ..

    cd cpc
    echo Cleaning Amstrad CPC...
    del /q /s *.* > nul 2>&1
    copy ..\readme.txt > nul 2>&1
    cd ..

    cd cplus4
    echo Cleaning Commodore Plus/4...
    del /q /s *.* > nul 2>&1
    copy ..\readme.txt > nul 2>&1
    cd ..

    cd esxdos
    echo Cleaning ZX Spectrum ESXDOS...
    del /q /s *.* > nul 2>&1
    copy ..\readme.txt > nul 2>&1
    cd ..

    echo Cleaning MSX1...
    cd msx1
    del /q /s *.* > nul 2>&1
    copy ..\readme.txt > nul 2>&1
    cd ..

    cd msx2
    echo Cleaning MSX2...
    del /q /s *.* > nul 2>&1
    copy ..\readme.txt > nul 2>&1
    cd ..

    cd next
    echo Cleaning Spectrum Next...
    del /q /s *.* > nul 2>&1
    copy ..\readme.txt > nul 2>&1
    cd ..

    cd pcw
    echo Cleaning Amstrad PCW...
    del /q /s *.* > nul 2>&1
    copy ..\readme.txt > nul 2>&1
    cd ..

    cd plus3
    echo Cleaning ZX Spectrum +3...
    del /q /s *.* > nul 2>&1
    copy ..\readme.txt > nul 2>&1
    cd ..

    cd uno
    echo Cleaning ZX-Uno...
    del /q /s *.* > nul 2>&1
    copy ..\readme.txt > nul 2>&1
    rd SYS > nul 2>&1
    cd ..

    cd zxtape
    echo Cleaning ZX Spectrum tape...
    del /q /s *.* > nul 2>&1
    copy ..\readme.txt > nul 2>&1
    cd ..

    cd msdos
    echo Cleaning IBM PC MS-DOS...
    del /s /q *.* > nul 2>&1
    copy ..\readme.txt > nul 2>&1
    cd ..

    cd atarist
    echo Cleaning Atari ST...
    del /q /s *.* > nul 2>&1
    copy ..\readme.txt > nul 2>&1
    cd ..

    cd AMIGA
    echo Cleaning Amiga...
    del /q /s *.* > nul 2>&1
    copy ..\readme.txt > nul 2>&1
    cd ..

    del readme.txt > nul 2>&1
    pause

)
