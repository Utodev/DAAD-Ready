@echo off

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

IF NOT exist %GAME%.DSF COPY TOOLS\DRC\BLANK_%LANG%.DSF %GAME%.DSF

REM ---- OBTENER RECURSOS ---- 
tools\cecho\cecho {06}Copying required files...{07}
echo.
COPY TOOLS\MALUVA\*.BIN > nul 2>&1
COPY ASSETS\CPC\CPC_%BASELANG%.DSK %GAME%.DSK > nul 2>&1
tools\cecho\cecho {02}[OK]{07}


ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
TOOLS\DRC\DRF cpc %GAME%.DSF %SPLITSCR% 
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

SET INTERPRETER=ASSETS\CPC\DCPCIE.Z80
IF "%BASELANG%" == "ES" SET INTERPRETER=ASSETS\CPC\DCPCIS.Z80
echo %INTERPRETER%
TOOLS\DRC\MCRF.EXE DAAD.BIN %INTERPRETER% DAAD.DDB ASSETS\CPC\BLANK.GRA  ASSETS\CHARSET\%FONT8%

REM  ---- PREPARE IMAGES ----
tools\cecho\cecho {06}Preparing images (if any){07}
ECHO.
CD IMAGES
for /L %%i in (0, 1, 9) do IF exist CPC\00%%i.SCR ..\TOOLS\MALUVA\SC2DAAD cpc CPC\00%%i.SCR 00%%i.CPC %IMGLINES%
for /L %%i in (10, 1, 99) do IF exist CPC\0%%i.SCR  ..\TOOLS\MALUVA\SC2DAAD cpc CPC\0%%i.SCR 0%%i.CPC %IMGLINES%
for /L %%i in (100, 1, 256) do IF exist CPC\%%i.SCR  ..\TOOLS\MALUVA\SC2DAAD cpc CPC\%%i.SCR %%i.CPC %IMGLINES% 
CD ..
tools\cecho\cecho {02}[OK]{07}
ECHO.

REM  ---- COPY FILES ---- 
tools\cecho\cecho {06}Preparing release files{07}
ECHO.
TOOLS\CPCDiskXP\CPCDiskXP -File DAAD.BIN -AddToExistingDsk %GAME%.DSK
for /L %%i in (0, 1, 9) do IF exist IMAGES\00%%i.CPC TOOLS\CPCDiskXP\CPCDiskXP -File IMAGES\00%%i.CPC -AddToExistingDsk %GAME%.DSK
for /L %%i in (10, 1, 99) do IF exist IMAGES\0%%i.CPC TOOLS\CPCDiskXP\CPCDiskXP -File IMAGES\0%%i.CPC -AddToExistingDsk %GAME%.DSK
for /L %%i in (100, 1, 255) do IF exist IMAGES\%%i.CPC TOOLS\CPCDiskXP\CPCDiskXP -File IMAGES\%%i.CPC -AddToExistingDsk %GAME%.DSK
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
MOVE %GAME%.DSK RELEASE\CPC > nul 2>&1
IF "%BASELANG%" == "EN" (
ECHO "Game ready,press any key to test or  CTRL+C to stop"
ECHO "Please notice sometimes WinAPE does not load the DSK file properly. Sometimes you will need to insert the DSK file at RELEASE/CPC yourself, at least the first time."
)
IF "%BASELANG%" == "ES" (
ECHO "Juego preparado, pulsa una tecla para probar, o Ctrl+C para parar."
ECHO "Ten en cuenta que a veces el emulador WinApe no carga correctamente el disco de pruebas, especialmente la primera vez. Lo tienes en RELEASE/CPC. Cargalo a mano si asi es."
)
tools\cecho\cecho {07}
PAUSE
TOOLS\WINAPE\WINAPE ..\..\..\RELEASE\CPC\%GAME%.DSK /A:DAAD
GOTO FIN

:ERROR
ECHO "Compile error, please check"
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