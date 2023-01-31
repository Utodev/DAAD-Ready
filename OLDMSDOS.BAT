@echo off
SET DAADSCRIPT=OLDMSDOS

REM ---- ZONA DE VARIABLES ---- 
CALL CONFIG.BAT
IF exist CUSTOM.BAT CALL CUSTOM.BAT

REM ----  CHECK IF LANG IS SET ---- 
IF  NOT DEFINED LANG (
        ECHO.
        ECHO.
        setlocal EnableDelayedExpansion
        CHOICE /C ESGP /N /M "--- Please select (E)nglish, (S)panish, (G)erman or (P)ortuguese"
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
        ECHO SET LANG=!LANG!>>CONFIG.BAT
        ECHO SET BASELANG=!BASELANG!>>CONFIG.BAT
    )
echo Language: %LANG% %BASELANG%



IF NOT exist %GAME%.DSF COPY TOOLS\DRC\BLANK_%LANG%.DSF %GAME%.DSF

REM ---- RESOURCES  ---- 
XCOPY ASSETS\OLDMSDOS\*.* RELEASE\OLDMSDOS /s /y > nul 2>&1
REM ----  CREATE FAKE EXTERN ----
ECHO "1">MALUVA 


ECHO.
ECHO ---------------------------------------------------------
ECHO Compiling [Front End]...
TOOLS\DRC\DRF pc vga %GAME%.DSF
IF ERRORLEVEL 1 GOTO ERROR
ECHO.
ECHO ---------------------------------------------------------
ECHO Compiling [Back End]...
PHP\PHP TOOLS\DRC\DRB.PHP pc vga %LANG% %GAME%.json %GAME%.DDB 
IF ERRORLEVEL 1 GOTO ERROR


REM -- PREPARE FONT -
COPY ASSETS\CHARSET\%FONT6% > nul 2>&1
TOOLS\SPECFORM\SPECFORM %FONT6%


REM  ---- COPY FILES  ---- 
COPY  %GAME%.DDB RELEASE\OLDMSDOS\GAME\PART1.DDB > nul 2>&1
MOVE %FONT6%.zxb RELEASE\OLDMSDOS\GAME\PART1.CHR > nul 2>&1
ECHO @dosbox.exe -noconsole > RELEASE/OLDMSDOS/%GAME%.BAT

IF "%BASELANG%" == "EN" (
echo INTEM1 >> RELEASE\OLDMSDOS\dosbox.conf
echo exit >> RELEASE\OLDMSDOS\dosbox.conf
echo @INTEM1  >> RELEASE\OLDMSDOS\GAME\%GAME%.BAT
del  RELEASE\OLDMSDOS\GAME\INTSM1.EXE
)

IF "%BASELANG%" == "ES" (
echo INTSM1 v>> RELEASE\OLDMSDOS\dosbox.conf
echo exit >> RELEASE\OLDMSDOS\dosbox.conf
echo @INTSM1 v>> RELEASE\OLDMSDOS\GAME\%GAME%.BAT
del RELEASE\OLDMSDOS\GAME\INTEM1.EXE
)

IF exist CUSTOM1.BAT CALL CUSTOM1.BAT
REM ----  CLEANING ---- 
DEL %GAME%.DDB > nul 2>&1
DEL MALUVA   > nul 2>&1
DEL %GAME%.json > nul 2>&1

IF exist CUSTOM2.BAT CALL CUSTOM2.BAT
IF ERRORLEVEL  1 GOTO CUSTOM
REM ---- TESTER ---- 
ECHO.
IF "%BASELANG%" == "EN" (
ECHO "Game ready,press any key to test or  CTRL+C to stop"
ECHO "NOTE: game is located at RELEASE\OLDMSDOS\GAME. At RELEASE\OLDMSDOS there is the DOSBOX that launches te game from Windows"
)
IF "%BASELANG%" == "ES" (
ECHO "Juego preparado, pulsa una tecla para probar, o Ctrl+C para parar."
ECHO "NOTA: El juego  en si ha quedado en RELEASE\OLDMSDOS\GAME. En RELEASE\OLDMSDOS está el dosbox que lo lanza en Windows"
)
PAUSE
CD RELEASE\OLDMSDOS 
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

REM  --- CUSTOM AREA ---
:CUSTOM
IF exist CUSTOM3.BAT CALL CUSTOM3.BAT 