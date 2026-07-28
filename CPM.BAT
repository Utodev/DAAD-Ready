@echo off
SET DAADSCRIPT=%~n0

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


IF NOT exist %GAME%.DSF COPY ASSETS\TEMPLATES\BLANK_%LANG%.DSF %GAME%.DSF

REM ---- OBTENER RECURSOS ---- 
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
SET INTERPRETER=ASSETS\CPM\DCPMIEF3.BIN
IF "%BASELANG%" == "ES" SET INTERPRETER=ASSETS\CPM\DCPMISF3.BIN


COPY ASSETS\CPM\CPM22.DSK %GAME%.DSK > nul 2>&1
COPY %INTERPRETER% DAAD.BIN > nul 2>&1
tools\cecho\cecho {02}[OK]{07}
ECHO.


tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Frontend]{07}
echo.
TOOLS\DRC\DRF cpm %GAME%.DSF -v3 -7
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Backend]{07}
echo.
PHP\PHP TOOLS\DRC\DRB.PHP cpm %LANG% %GAME%.json %GAME%.DDB
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.

tools\cecho\cecho {06}Preparing release files{07}
ECHO.
MOVE %GAME%.DDB DAAD.DDB > nul 2>&1

php\php.exe tools\CPM\CPMPacker.php DAAD.BIN $2000
IF ERRORLEVEL 1 GOTO ERROR

REM  ---- COPIAR FICHEROS AL DISCO ---- 
MOVE DAAD.COM %GAME%.COM > nul 2>&1
TOOLS\CPCDiskXP\CPCDiskXP -File %GAME%.COM -AddToExistingDsk %GAME%.DSK
IF exist 0.XMB TOOLS\CPCDiskXP\CPCDiskXP -File 0.XMB -AddToExistingDsk %GAME%.DSK
tools\cecho\cecho {02}[OK]{07}
ECHO.

IF exist CUSTOM1.BAT CALL CUSTOM1.BAT
REM ----  CLEAN ---- 
DEL DAAD.DDB > nul 2>&1
DEL RELEASE\CPM\%GAME%.COM > nul 2>&1
MOVE %GAME%.COM RELEASE\CPM > nul 2>&1
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1

IF exist CUSTOM2.BAT CALL CUSTOM2.BAT
IF ERRORLEVEL  1 GOTO CUSTOM
REM ---- TESTER ---- 
ECHO.
MOVE %GAME%.DSK RELEASE\CPM > nul 2>&1
tools\cecho\cecho {03}
IF "%BASELANG%" == "EN" (
ECHO Game ready,press any key to test or  CTRL+C to stop
echo When emulator starts, wait for CP/M to load, and then type %GAME% [ENTER] to start the game.
echo Note: The game in CP/M runs on an Amstrad CPC with CP/M, but in the RELEASE folder you have both
echo      the disk in Amstrad format with the game + CP/M, and the .COM file which is the game itself, 
echo      to be able to run it on any machine with CP/M 2.2.
)
IF "%BASELANG%" == "ES" (
ECHO El juego se ha compilado correctamente, pulsa una tecla para probar, o Ctrl+C para parar.
ECHO Cuando arranque el emulador espera a que cargue CP/M, y luego escribe %GAME% [ENTER] para iniciar el juego.
ECHO .
ECHO NOTA: El juego en CP/M se ejecuta sobre un Amstrad CPC con CP/M, pero en la carpeta RELEASE teneis tanto
ECHO      el disco en formato Amstrad con el juego  + CP/M, como el fichero .COM que es el juego en sí, para    
ECHO      poder ejecutarlo en cualquier maquina con CP/M 2.2.
)
tools\cecho\cecho {07}
PAUSE

cd TOOLS\CPCE
CPCE95 -v+ ..\..\RELEASE\CPM\%GAME%.DSK
REM WinApe.exe C:\Users\csanchez\MEGA\Github\DAAD-Ready\RELEASE\CPM\%GAME%.DSK /A
cd ..\..


GOTO FIN

:ERROR
tools\cecho\cecho {04}
ECHO Compile error, please check
tools\cecho\cecho {07}
PAUSE
:FIN

REM ----  CLEAN ---- 
DEL *.DDB > nul 2>&1
DEL *.COM > nul 2>&1
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
DEL *.CHR > nul 2>&1

REM  --- CUSTOM AREA ---
:CUSTOM
IF exist CUSTOM3.BAT CALL CUSTOM3.BAT 