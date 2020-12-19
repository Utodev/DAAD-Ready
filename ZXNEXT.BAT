@echo off

REM ----  VARIABLES ---- 
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

REM ---- GET RESOURCES ---- 
COPY TOOLS\MALUVA\*.BIN > nul 2>&1

ECHO.
ECHO ---------------------------------------------------------
ECHO Compiling [Front End]...
TOOLS\DRC\DRF zx next %GAME%.DSF
IF ERRORLEVEL 1 GOTO ERROR
ECHO.
ECHO ---------------------------------------------------------
ECHO Compiling [Back End]...
PHP\PHP TOOLS\DRC\DRB.PHP zx next %LANG% %GAME%.json %GAME%.DDB 
IF ERRORLEVEL 1 GOTO ERROR

REM  ---- PREPARE IMAGES ----
CD IMAGES
echo Wait while preparing images (if any)...
for /L %%i in (0, 1, 9) do IF exist 00%%i.PCX ..\TOOLS\MALUVA\SC2DAAD next 00%%i.PCX 00%%i.NXT %IMGLINES% > nul 2>&1
for /L %%i in (10, 1, 99) do IF exist 0%%i.PCX  ..\TOOLS\MALUVA\SC2DAAD next 0%%i.PCX 0%%i.NXT %IMGLINES% > nul 2>&1
for /L %%i in (100, 1, 256) do IF exist %%i.PCX  ..\TOOLS\MALUVA\SC2DAAD next %%i.PCX %%i.NXT %IMGLINES% > nul 2>&1
CD ..


REM  ---- COPY FILES ---- 
IF exist 0.XMB copy 0.XMB RELEASE\NEXT > nul 2>&1
for /L %%i in (0, 1, 9) do IF exist IMAGES\00%%i.NXT COPY IMAGES\00%%i.NXT  RELEASE\NEXT > nul 2>&1
for /L %%i in (10, 1, 99) do IF exist IMAGES\0%%i.NXT COPY IMAGES\0%%i.NXT  RELEASE\NEXT > nul 2>&1
for /L %%i in (100, 1, 255) do IF exist IMAGES\%%i.NXT COPY IMAGES\%%i.NXT  RELEASE\NEXT > nul 2>&1

REM --- PREPARE TAP FILE ----
SET INTERPRETER=ASSETS\ZX\DS48IE.P3F
IF "%BASELANG%" == "ES" SET INTERPRETER=ASSETS\ZX\DS48IS.P3F 
TOOLS\DRC\daadmaker.exe %GAME%.TAP %INTERPRETER% %GAME%.DDB ASSETS\CHARSET\%FONT6%
MOVE %GAME%.TAP RELEASE\NEXT > nul 2>&1

REM ----  CLEANING ---- 
DEL %GAME%.DDB > nul 2>&1
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1

REM ---- TESTER ---- 
ECHO.
ECHO "Press any key to run emulator, or Ctrl+C to cancel." 
ECHO "To exit ZEsarUX emulator, press F5, then F10." 


PAUSE
cd TOOLS\ZESARUX
zesarux  --noconfigfile --zoom 1 --machine tbblue --realvideo --tbblue-fast-boot-mode --enable-esxdos-handler --esxdos-root-dir "..\..\RELEASE\NEXT" --nosplash --forcevisiblehotkeys --forceconfirmyes  --nowelcomemessage  --cpuspeed 100 "..\..\RELEASE\NEXT\%GAME%.tap"
CD ..\..
GOTO END

:ERROR
ECHO "Something went wrong, please check errors"
PAUSE
:END

REM ----  CLEANING ---- 
DEL %GAME%.DDB > nul 2>&1
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1

