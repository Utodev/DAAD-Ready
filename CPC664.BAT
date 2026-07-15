@echo off
SET DAADSCRIPT=%~n0

REM ----  VARIABLES ---- 
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
tools\cecho\cecho {06}Copying required files...{07}
echo.
COPY ASSETS\CPC\BLANK.DSK %GAME%.DSK > nul 2>&1
tools\cecho\cecho {02}[OK]{07}
echo.


if %SPLITSCR%==splitModeOn (
    tools\cecho\cecho {06}Split screen mode enabled{07}
    SET SPLITFOLDER=\SPLITMODE
    SET SPLITFOLDERBACK=..\
    SET INT_SUFFIX=_SPLIT
    echo.
) else (
    tools\cecho\cecho {06}Split screen mode disabled{07}
    SET SPLITFOLDER=
    SET SPLITFOLDERBACK=
    SET INT_SUFFIX=
    echo.
)

ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
TOOLS\DRC\DRF cpc %GAME%.DSF %SPLITSCR% -v3
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Backend]{07}
ECHO.
PHP\PHP TOOLS\DRC\DRB.PHP cpc %LANG% %GAME%.json %GAME%.DDB
IF ERRORLEVEL 1 GOTO ERROR
MOVE %GAME%.DDB DAAD.DDB > nul 2>&1
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.

SET INTERPRETER=ASSETS\CPC\DCPCIEF3%INT_SUFFIX%.BIN
IF "%BASELANG%" == "ES" SET INTERPRETER=ASSETS\CPC\DCPCISF3%INT_SUFFIX%.BIN
echo Interpreter used: %INTERPRETER%
TOOLS\DRC\MCRF.EXE DAAD.BIN %INTERPRETER% DAAD.DDB ASSETS\CPC\BLANK.GRA  ASSETS\CHARSET\%FONT8%

REM  ---- PREPARE IMAGES ----
tools\cecho\cecho {06}Preparing images (if any){07}
ECHO.
CD IMAGES\CPC\%SPLITFOLDER%
for /L %%i in (0, 1, 9) do IF exist 00%%i.SCR %SPLITFOLDERBACK%..\..\TOOLS\MALUVA\SC2DAAD cpc 00%%i.SCR 00%%i.CPC %IMGLINES%
for /L %%i in (10, 1, 99) do IF exist 0%%i.SCR  %SPLITFOLDERBACK%..\..\TOOLS\MALUVA\SC2DAAD cpc 0%%i.SCR 0%%i.CPC %IMGLINES%
for /L %%i in (100, 1, 256) do IF exist %%i.SCR  %SPLITFOLDERBACK%..\..\TOOLS\MALUVA\SC2DAAD cpc %%i.SCR %%i.CPC %IMGLINES% 
CD %SPLITFOLDERBACK%..\..
tools\cecho\cecho {02}[OK]{07}
ECHO.

REM  ---- COPY FILES ---- 
tools\cecho\cecho {06}Preparing release files{07}
ECHO.
TOOLS\CPCDiskXP\CPCDiskXP -File DAAD.BIN -AddToExistingDsk %GAME%.DSK
for /L %%i in (0, 1, 9) do IF exist IMAGES\CPC%SPLITFOLDER%\00%%i.CPC TOOLS\CPCDiskXP\CPCDiskXP -File IMAGES\CPC%SPLITFOLDER%\00%%i.CPC -AddToExistingDsk %GAME%.DSK
for /L %%i in (10, 1, 99) do IF exist IMAGES\CPC%SPLITFOLDER%\0%%i.CPC TOOLS\CPCDiskXP\CPCDiskXP -File IMAGES\CPC%SPLITFOLDER%\0%%i.CPC -AddToExistingDsk %GAME%.DSK
for /L %%i in (100, 1, 255) do IF exist IMAGES\CPC%SPLITFOLDER%\%%i.CPC TOOLS\CPCDiskXP\CPCDiskXP -File IMAGES\CPC%SPLITFOLDER%\%%i.CPC -AddToExistingDsk %GAME%.DSK
for /L %%i in (0, 1, 9) do IF exist 0%%i.XMB TOOLS\CPCDiskXP\CPCDiskXP -File 0%%i.XMB -AddToExistingDsk %GAME%.DSK
for /L %%i in (10, 1, 32) do IF exist %%i.XMB TOOLS\CPCDiskXP\CPCDiskXP -File %%i.XMB -AddToExistingDsk %GAME%.DSK
tools\cecho\cecho {02}[OK]{07}
ECHO.


IF exist CUSTOM1.BAT CALL CUSTOM1.BAT
REM ----  CLEAN ---- 
DEL DAAD.DDB > nul 2>&1
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1

IF exist CUSTOM2.BAT CALL CUSTOM2.BAT
IF ERRORLEVEL  1 GOTO CUSTOM
REM ---- TESTER ---- 
ECHO.
tools\cecho\cecho {03}
MOVE %GAME%.DSK RELEASE\CPC664 > nul 2>&1
IF "%BASELANG%" == "EN" (
ECHO Game ready,press any key to test or  CTRL+C to stop
)
IF "%BASELANG%" == "ES" (
ECHO Juego preparado, pulsa una tecla para probar, o Ctrl+C para parar.
)
tools\cecho\cecho {07}
PAUSE
cd TOOLS\CPCE
CPCE95 -v+ ..\..\RELEASE\CPC664\%GAME%.DSK
CD ..\..
GOTO FIN

:ERROR
ECHO Compile error, please check
PAUSE
:FIN


REM ----  CLEAN ---- 
DEL DAAD.DDB > nul 2>&1
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1

REM  --- CUSTOM AREA ---
:CUSTOM
IF exist CUSTOM3.BAT CALL CUSTOM3.BAT 