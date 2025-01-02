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


IF NOT exist %GAME%.DSF COPY TOOLS\DRC\BLANK_%LANG%.DSF %GAME%.DSF

REM ---- OBTENER RECURSOS ---- 
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
COPY TOOLS\MALUVA\*.BIN > nul 2>&1
SET INTERPRETER=ASSETS\AMIGA\EDIP1
IF "%BASELANG%" == "ES" SET INTERPRETER=ASSETS\AMIGA\SDIP1
COPY %INTERPRETER% RELEASE\AMIGA\%GAME%
COPY ASSETS\CHARSET\%FONT6% RELEASE\AMIGA\PART1.TMP > nul 2>&1
TOOlS\SPECFORM\SPECFORM -a 16384 RELEASE\AMIGA\PART1.TMP > nul 2>&1
MOVE RELEASE\AMIGA\PART1.TMP.zxb RELEASE\AMIGA\PART1.CHR > nul 2>&1
DEL RELEASE\AMIGA\PART1.TMP > nul 2>&1

tools\cecho\cecho {02}[OK]{07}
ECHO.


tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Frontend]{07}
echo.
TOOLS\DRC\DRF amiga %GAME%.DSF
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Backend]{07}
echo.
PHP\PHP TOOLS\DRC\DRB.PHP amiga %LANG% %GAME%.json %GAME%.DDB 
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.

REM  ---- PREPARE IMAGES ----
PHP\php TOOLS\img2daad\img2daad.php IMAGES RELEASE\AMIGA\PART1.DAT -a  
IF ERRORLEVEL 1 GOTO ERROR

REM --- PREPARE AMIGA STARTUP-SEQUENCE
mkdir RELEASE\AMIGA\s > nul 2>&1
echo %GAME% > RELEASE\AMIGA\s\startup-sequence


tools\cecho\cecho {06}Preparing release files{07}
ECHO.
MOVE %GAME%.DDB RELEASE\AMIGA\PART1.DDB > nul 2>&1
ECHO.

tools\cecho\cecho {06}Preparing .ADF floppy disk image file{07}
DEL RELEASE\AMIGA\FLOPPY\%GAME%.ADF > nul 2>&1
RMDIR RELEASE\AMIGA\FLOPPY\ > nul 2>&1
TOOLS\exe2adf\exe2adf.exe -d RELEASE\AMIGA\ -l %GAME% -a RELEASE\%GAME%.ADF > nul 2>&1
MD RELEASE\AMIGA\FLOPPY\ > nul 2>&1
MOVE RELEASE\%GAME%.ADF RELEASE\AMIGA\FLOPPY\%GAME%.ADF > nul 2>&1

IF exist CUSTOM1.BAT CALL CUSTOM1.BAT
REM ----  CLEAN ---- 
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
DEL *.CHR > nul 2>&1

IF exist CUSTOM2.BAT CALL CUSTOM2.BAT
IF ERRORLEVEL  1 GOTO CUSTOM
REM ---- TESTER ---- 
CD TOOLS\WINUAE
IF NOT EXIST kick13.rom (
        ..\..\tools\cecho\cecho {04}
        IF "%BASELANG%" == "EN" (
            ..\..\tools\cecho\cecho IMPORTANT: In order to test Amiga games, you have to add the file kick13.rom to the TOOLS\WINUAE folder.
            echo.
            ..\..\tools\cecho\cecho That is the Kickstater ROM version 1.3. Once added run AMIGA.BAT again
        )
        IF "%BASELANG%" == "ES" (
            ..\..\tools\cecho\cecho IMPORTANTE: Para poder probar los juegos de Amiga, tienes que poner el fichero kick13.rom en la carpeta TOOLS\WINUAE.
            echo.
            ..\..\tools\cecho\cecho Es la ROM de Kickstarter version 1.3. Una vez incluido el fichero de la ROM vuelve a ejecutar AMIGA.BAT
        )
        ..\..\tools\cecho\cecho {07}
        echo .
        PAUSE
        EXIT
)
CD ..\..

ECHO.
tools\cecho\cecho {03}
IF "%BASELANG%" == "EN" (
ECHO Game ready,press any key to test or CTRL+C to stop
ECHO The game will be executed from RELEASE\AMIGA, but you can also find it in RELEASE\AMIGA\FLOPPY,
ECHO in .ADF format, as long as it fits in a disk.

)
IF "%BASELANG%" == "ES" (
ECHO EL JUEGO SE HA COMPILADO CORRECTAMENTE, PULSE ENTER PARA INICIAR EL EMULADOR, O CTRL+C PARA PARAR
ECHO El juego que se ejecutará está en RELEASE\AMIGA, pero podéis encontrarlo también en la carpeta
ECHO RELEASE\AMIGA\FLOPPY, en formato .aDF, siempre que quepa en un disco.

)
tools\cecho\cecho {07}
PAUSE
CD TOOLS\WINUAE
WINUAE -config=DAAD.UAE -G
cd ..\..

GOTO FIN

:ERROR
tools\cecho\cecho {04}
ECHO Compile error, please check
tools\cecho\cecho {07}
PAUSE
:FIN

REM ----  CLEAN ---- 
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
DEL *.CHR > nul 2>&1

REM  --- CUSTOM AREA ---
:CUSTOM
IF exist CUSTOM3.BAT CALL CUSTOM3.BAT 