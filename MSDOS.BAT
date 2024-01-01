@echo off
SET DAADSCRIPT=MSDOS

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
tools\cecho\cecho {06}Copying required files...{07}
echo.
XCOPY ASSETS\MSDOS\*.* RELEASE\MSDOS /s /y > nul 2>&1
IF exist ASSETS\CHARSET\%FONTPCDAAD% COPY /Y ASSETS\CHARSET\%FONTPCDAAD% RELEASE\MSDOS\GAME\DAAD.FNT 
IF not exist ASSETS\CHARSET\%FONTPCDAAD% COPY /Y ASSETS\CHARSET\%FONT6% RELEASE\MSDOS\GAME\DAAD.CHR
REM ----  CREATE FAKE EXTERN ----
ECHO "1">MALUVA 
tools\cecho\cecho {02}[OK]{07}


ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Frontend]{07}
ECHO.
TOOLS\DRC\DRF pc vga256 %GAME%.DSF
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Backend]{07}
ECHO.
PHP\PHP TOOLS\DRC\DRB.PHP pc vga256 %LANG% %GAME%.json %GAME%.DDB 
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.

IF "%SVGA%"=="0" (
        ECHO Creating VGA GAME
        SET IMGPATH=IMAGES\PC
        SET IMGPATHBACK=..\..
    ) ELSE (
        SET IMGPATH=IMAGES\PC\SVGA
        SET IMGPATHBACK=..\..\..
        SET PARAMETER=-s
        ECHO Creating SVGA GAME
    )


REM  ---- COPY FILES  ---- 
COPY  %GAME%.DDB RELEASE\MSDOS\GAME\DAAD.DDB > nul 2>&1
ECHO @dosbox.exe -noconsole > RELEASE/MSDOS/%GAME%.BAT

echo PCDAAD %PARAMETER% >> RELEASE\MSDOS\dosbox.conf
echo exit >> RELEASE\MSDOS\dosbox.conf
echo @PCDAAD  %PARAMETER% > RELEASE\MSDOS\GAME\%GAME%.BAT

REM  ---- PREPARE IMAGES ----
tools\cecho\cecho {06}Preparing images (if any){07}

ECHO.
CD %IMGPATH%
echo Wait while preparing images (if any)...

IF exist DAAD.PCX %IMGPATHBACK%\TOOLS\PCXFIXER\pcxfixer DAAD.PCX DAAD.VGA > nul 2>&1
for /L %%i in (0, 1, 9) do IF exist 00%%i.PCX %IMGPATHBACK%\TOOLS\PCXFIXER\pcxfixer.exe 00%%i.PCX 00%%i.VGA > nul 2>&1
for /L %%i in (10, 1, 99) do IF exist 0%%i.PCX  %IMGPATHBACK%\TOOLS\PCXFIXER\pcxfixer.exe 0%%i.PCX 0%%i.VGA > nul 2>&1
for /L %%i in (100, 1, 256) do IF exist %%i.PCX  %IMGPATHBACK%\TOOLS\PCXFIXER\pcxfixer.exe %%i.PCX %%i.VGA > nul 2>&1
CD %IMGPATHBACK%
tools\cecho\cecho {02}[OK]{07}
ECHO.

tools\cecho\cecho {06}Preparing release files{07}
ECHO.
REM  ---- COPY FILES ---- 
IF exist 0.XMB copy 0.XMB RELEASE\MSDOS\GAME > nul 2>&1
IF exist %IMGPATH%\DAAD.VGA copy %IMGPATH%\DAAD.VGA RELEASE\MSDOS\GAME > nul 2>&1
for /L %%i in (0, 1, 9) do IF exist %IMGPATH%\00%%i.VGA COPY %IMGPATH%\00%%i.VGA  RELEASE\MSDOS\GAME  > nul 2>&1
for /L %%i in (10, 1, 99) do IF exist %IMGPATH%\0%%i.VGA COPY %IMGPATH%\0%%i.VGA  RELEASE\MSDOS\GAME  > nul 2>&1
for /L %%i in (100, 1, 255) do IF exist %IMGPATH%\%%i.VGA COPY %IMGPATH%\%%i.VGA  RELEASE\MSDOS\GAME  > nul 2>&1
tools\cecho\cecho {02}[OK]{07}
ECHO.

IF exist CUSTOM1.BAT CALL CUSTOM1.BAT
REM ----  CLEANING ---- 
DEL %GAME%.DDB > nul 2>&1
DEL MALUVA   > nul 2>&1
DEL %GAME%.json > nul 2>&1

IF exist CUSTOM2.BAT CALL CUSTOM2.BAT
IF ERRORLEVEL  1 GOTO CUSTOM

REM ---- TESTER ---- 
ECHO.
tools\cecho\cecho {03}
IF "%BASELANG%" == "EN" (
ECHO Game ready,press any key to test or  CTRL+C to stop
ECHO NOTES:
ECHO  - Game is located at RELEASE\MSDOS\GAME. At RELEASE\MSDOS you can find a DOSBOX launcher to test the game from Windows.
ECHO  - Game will be created for VGA by default. If you want SVGA, please add 'SET SVGA=1' in CONFIG.BAT and put images in IMAGES\PC\SVGA folder.
)
IF "%BASELANG%" == "ES" (
ECHO Juego preparado, pulsa una tecla para probar, o Ctrl+C para parar.
ECHO NOTAS:
ECHO  - El juego  en si ha quedado en RELEASE\MSDOS\GAME. En RELEASE\MSDOS está el dosbox que lo lanza en Windows.
ECHO  - El juego se creara por defecto para VGA. Si quieres SVGA, pon 'SET SVGA=1' en el fichero CONFIG.BAT y pon las imagenes en IMAGES\PC\SVGA.
)
tools\cecho\cecho {07}
PAUSE
CD RELEASE\MSDOS 
CALL %GAME%.BAT
CD ..\..
GOTO FIN

:ERROR
tools\cecho\cecho {04}
ECHO Compile error, please check
tools\cecho\cecho {07}
PAUSE
:FIN

REM ----  CLEANING ---- 
DEL %GAME%.DDB > nul 2>&1
DEL MALUVA   > nul 2>&1
DEL %GAME%.json > nul 2>&1


REM  --- CUSTOM AREA ---
:CUSTOM
IF exist CUSTOM3.BAT CALL CUSTOM3.BAT 