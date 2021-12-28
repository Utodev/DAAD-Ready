@echo off
echo -- This will delete all files from release folders, leaving them empty but for the "readme.txt " file that was already in there.
choice /C NY /N /M "Are your sure? [Y/N]"
if errorlevel 2 (
    copy c64\readme.txt > nul 2>&1

    cd c64
    del /q /s *.*
    copy ..\readme.txt > nul 2>&1
    cd ..

    cd cpc
    del /q /s *.*
    copy ..\readme.txt > nul 2>&1
    cd ..

    cd cplus4
    del /q /s *.*
    copy ..\readme.txt > nul 2>&1
    cd ..

    cd esxdos
    del /q /s *.*
    copy ..\readme.txt > nul 2>&1
    cd ..

    cd msx1
    del /q /s *.*
    copy ..\readme.txt > nul 2>&1
    cd ..

    cd msx2
    del /q /s *.*
    copy ..\readme.txt > nul 2>&1
    cd ..

    cd next
    del /q /s *.*
    copy ..\readme.txt > nul 2>&1
    cd ..

    cd pcw
    del /q /s *.*
    copy ..\readme.txt > nul 2>&1
    cd ..

    cd plus3
    del /q /s *.*
    copy ..\readme.txt > nul 2>&1
    cd ..

    cd uno
    del /q /s *.*
    copy ..\readme.txt > nul 2>&1
    rd SYS
    cd ..

    cd zxtape
    del /q /s *.*
    copy ..\readme.txt > nul 2>&1
    cd ..

    cd msdos
    del /s /q *.*
    copy ..\readme.txt > nul 2>&1
    cd ..

    del readme.txt > nul 2>&1
    pause

)
