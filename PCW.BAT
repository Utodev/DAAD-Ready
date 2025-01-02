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
SET INTERPRETER=ASSETS\PCW\PCWEDI.BIN
IF "%BASELANG%" == "ES" SET INTERPRETER=ASSETS\PCW\PCWSDI.BIN
COPY ASSETS\PCW\PCW.DSK %GAME%.DSK > nul 2>&1
COPY %INTERPRETER% DAAD.COM > nul 2>&1
tools\cecho\cecho {02}[OK]{07}
ECHO.


tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Frontend]{07}
echo.
TOOLS\DRC\DRF pcw %GAME%.DSF
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Backend]{07}
echo.
PHP\PHP TOOLS\DRC\DRB.PHP pcw %LANG% %GAME%.json %GAME%.DDB 
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.

tools\cecho\cecho {06}Preparing release files{07}
ECHO.
MOVE %GAME%.DDB PARTE001.DDB > nul 2>&1
REM -- PREPARE FONT -
COPY ASSETS\CHARSET\%FONT6% > nul 2>&1
TOOLS\SPECFORM\SPECFORM %FONT6% > nul 2>&1
MOVE %FONT6%.zxb PARTE001.CHR > nul 2>&1


REM  ---- COPY FILES  ---- 


REM  ---- COPIAR FICHEROS AL DISCO ---- 
TOOLS\CPCDiskXP\CPCDiskXP -File PARTE001.CHR -AddToExistingDsk %GAME%.DSK
TOOLS\CPCDiskXP\CPCDiskXP -File PARTE001.DDB -AddToExistingDsk %GAME%.DSK
TOOLS\CPCDiskXP\CPCDiskXP -File DAAD.COM -AddToExistingDsk %GAME%.DSK
IF exist 0.XMB TOOLS\CPCDiskXP\CPCDiskXP -File 0.XMB -AddToExistingDsk %GAME%.DSK
tools\cecho\cecho {02}[OK]{07}
ECHO.

IF exist CUSTOM1.BAT CALL CUSTOM1.BAT
REM ----  CLEAN ---- 
DEL DAAD.DDB > nul 2>&1
DEL PARTE001.DDB > nul 2>&1
DEL DAAD.COM > nul 2>&1
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
DEL *.CHR > nul 2>&1

IF exist CUSTOM2.BAT CALL CUSTOM2.BAT
IF ERRORLEVEL  1 GOTO CUSTOM
REM ---- TESTER ---- 
ECHO.
MOVE %GAME%.DSK RELEASE\PCW > nul 2>&1
tools\cecho\cecho {03}
IF "%BASELANG%" == "EN" (
ECHO Game ready,press any key to test or  CTRL+C to stop
echo When emulator starts, just press enter and then choose part 1
)
IF "%BASELANG%" == "ES" (
ECHO EL JUEGO SE HA COMPILADO CORRECTAMENTE, PULSE ENTER PARA INICIAR EL EMULADOR, O CTRL+C PARA PARAR
ECHO CUANDO ARRANQUE EL EMULADOR SIMPLEMENTE PULSA ENTER y LUEGO ELIGE LA PARTE 1
)
tools\cecho\cecho {07}
PAUSE
COPY RELEASE\PCW\%GAME%.DSK TOOLS\PCW > nul 2>&1
cd TOOLS\PCW
PCW -G 1 -A CPMv1_4.DSK -O ON -W 1000 -A %GAME%.DSK -G 0 -T "DAAD#0A" 
cd ..\..

GOTO FIN

:ERROR
tools\cecho\cecho {04}
ECHO Compile error, please check
tools\cecho\cecho {07}
PAUSE
:FIN

REM ----  CLEAN ---- 
DEL DAAD.DDB > nul 2>&1
DEL PARTE001.DDB > nul 2>&1
DEL DAAD.COM > nul 2>&1
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
DEL *.CHR > nul 2>&1
DEL TOOLS\PCW\%GAME%.DSK

REM  --- CUSTOM AREA ---
:CUSTOM
IF exist CUSTOM3.BAT CALL CUSTOM3.BAT 