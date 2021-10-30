@echo off

REM ---- ZONA DE VARIABLES ---- 
CALL CONFIG.BAT
IF exist CUSTOM.BAT CALL CUSTOM.BAT

REM ----  CHECK IF LANG IS SET ---- 
IF  NOT DEFINED LANG (
        ECHO.
        ECHO.
        setlocal EnableDelayedExpansion
        CHOICE /C ESGPF /N /M "--- Please select (E)nglish, (S)panish, (G)erman, (F)rench or (P)ortuguese"
        SET LANG=EN
        SET BASELANG=EN
        IF ERRORLEVEL 2 (
            SET LANG=ES
            SET BASELANG=ES
        )
        IF ERRORLEVEL 3 (
            SET LANG=DE
            SET BASELANG=EN
        )
       IF ERRORLEVEL 4 (
            SET LANG=PT
            SET BASELANG=ES
        )
        IF ERRORLEVEL 5 (
            SET LANG=FR
            SET BASELANG=EN
        )
   
        ECHO SET LANG=!LANG!>>CONFIG.BAT
        ECHO SET BASELANG=!BASELANG!>>CONFIG.BAT
    )
echo Language: %LANG% %BASELANG%



IF NOT exist %GAME%.DSF COPY TOOLS\DRC\BLANK_%LANG%.DSF %GAME%.DSF

REM ---- RESOURCES  ---- 
XCOPY ASSETS\MSDOS\*.* RELEASE\MSDOS /s /y > nul 2>&1
REM ----  CREATE FAKE EXTERN ----
ECHO "1">MALUVA 


ECHO.
ECHO ---------------------------------------------------------
ECHO Compiling [Front End]...
TOOLS\DRC\DRF pc vga256 %GAME%.DSF
IF ERRORLEVEL 1 GOTO ERROR
ECHO.
ECHO ---------------------------------------------------------
ECHO Compiling [Back End]...
PHP\PHP TOOLS\DRC\DRB.PHP pc vga256 %LANG% %GAME%.json %GAME%.DDB 
IF ERRORLEVEL 1 GOTO ERROR


REM  ---- COPY FILES  ---- 
COPY  %GAME%.DDB RELEASE\MSDOS\GAME\DAAD.DDB > nul 2>&1
ECHO @dosbox.exe -noconsole > RELEASE/MSDOS/%GAME%.BAT

echo PCDAAD  >> RELEASE\MSDOS\dosbox.conf
echo exit >> RELEASE\MSDOS\dosbox.conf
echo @PCDAAD   > RELEASE\MSDOS\GAME\%GAME%.BAT

REM  ---- PREPARE IMAGES ----
CD IMAGES\PC
echo Wait while preparing images (if any)...
for /L %%i in (0, 1, 9) do IF exist 00%%i.PCX ..\..\TOOLS\PCXFIXER\pcxfixer 00%%i.PCX 00%%i.VGA  > nul 2>&1
for /L %%i in (10, 1, 99) do IF exist 0%%i.PCX  ..\..\TOOLS\PCXFIXER\pcxfixer 0%%i.PCX 0%%i.VGA > nul 2>&1
for /L %%i in (100, 1, 256) do IF exist %%i.PCX  ..\..\TOOLS\PCXFIXER\pcxfixer %%i.PCX %%i.VGA > nul 2>&1
IF exist DAAD.PCX ..\..\TOOLS\PCXFIXER\pcxfixer DAAD.PCX DAAD.VGA
CD ..\..

REM  ---- COPY FILES ---- 
IF exist 0.XMB copy 0.XMB RELEASE\MSDOS\GAME > nul 2>&1
IF exist IMAGES\PC\DAAD.VGA copy IMAGES\PC\DAAD.VGA RELEASE\MSDOS\GAME > nul 2>&1
for /L %%i in (0, 1, 9) do IF exist IMAGES\PC\00%%i.VGA COPY IMAGES\PC\00%%i.VGA  RELEASE\MSDOS\GAME > nul 2>&1
for /L %%i in (10, 1, 99) do IF exist IMAGES\PC\0%%i.VGA COPY IMAGES\PC\0%%i.VGA  RELEASE\MSDOS\GAME > nul 2>&1
for /L %%i in (100, 1, 255) do IF exist IMAGES\PC\%%i.VGA COPY IMAGES\PC\%%i.VGA  RELEASE\MSDOS\GAME > nul 2>&1

REM ----  CLEANING ---- 
DEL %GAME%.DDB > nul 2>&1
DEL MALUVA   > nul 2>&1
DEL %GAME%.json > nul 2>&1

REM ---- TESTER ---- 
ECHO.
IF "%BASELANG%" == "EN" (
ECHO "Game ready,press any key to test or  CTRL+C to stop"
ECHO "NOTE: game is located at RELEASE\MSDOS\GAME. At RELEASE\MSDOS there is the DOSBOX that launches te game from Windows"
)
IF "%BASELANG%" == "ES" (
ECHO "Juego preparado, pulsa una tecla para probar, o Ctrl+C para parar."
ECHO "NOTA: El juego  en si ha quedado en RELEASE\MSDOS\GAME. En RELEASE\MSDOS está el dosbox que lo lanza en Windows"
)
PAUSE
CD RELEASE\MSDOS 
CALL %GAME%.BAT
CD ..\..
GOTO FIN

:ERROR
ECHO "Compile error, please check"
PAUSE
:FIN

REM ----  CLEANING ---- 
DEL %GAME%.DDB > nul 2>&1
DEL MALUVA   > nul 2>&1
DEL %GAME%.json > nul 2>&1
