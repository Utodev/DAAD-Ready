@echo off

REM ---- VARIABLES ---- 
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

REM ---- GET RESOURCES ---- 
tools\cecho\cecho {06}Copying required files...{07}
echo.
COPY TOOLS\MALUVA\*.BIN > nul 2>&1
tools\cecho\cecho {02}[OK]{07}
ECHO.

tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Frontend]{07}
echo.
TOOLS\DRC\DRF zx uno %GAME%.DSF %SPLITSCR%
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Backend]{07}
echo.
PHP\PHP TOOLS\DRC\DRB.PHP zx uno %LANG% %GAME%.json %GAME%.DDB 
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.

REM  ---- PREPARE IMAGES ----
tools\cecho\cecho {06}Preparing images (if any){07}
ECHO.
CD IMAGES
for /L %%i in (0, 1, 9) do IF exist 00%%i.MLT ..\TOOLS\MALUVA\SC2DAAD uno 00%%i.MLT 00%%i.UNO %IMGLINES% auto 0 > nul 2>&1
for /L %%i in (10, 1, 99) do IF exist 0%%i.MLT  ..\TOOLS\MALUVA\SC2DAAD uno 0%%i.MLT 0%%i.UNO %IMGLINES% auto 0 > nul 2>&1
for /L %%i in (100, 1, 256) do IF exist %%i.MLT  ..\TOOLS\MALUVA\SC2DAAD uno %%i.MLT %%i.UNO %IMGLINES% auto 0 > nul 2>&1
CD ..
tools\cecho\cecho {02}[OK]{07}
ECHO.


REM  ---- COPY FILES ---- 
tools\cecho\cecho {06}Preparing release files{07}
ECHO.
IF exist 0.XMB copy 0.XMB RELEASE\UNO > nul 2>&1
for /L %%i in (0, 1, 9) do IF exist IMAGES\00%%i.UNO COPY IMAGES\00%%i.UNO  RELEASE\UNO > nul 2>&1
for /L %%i in (10, 1, 99) do IF exist IMAGES\0%%i.UNO COPY IMAGES\0%%i.UNO  RELEASE\UNO > nul 2>&1
for /L %%i in (100, 1, 255) do IF exist IMAGES\%%i.UNO COPY IMAGES\%%i.UNO  RELEASE\UNO > nul 2>&1

REM --- PREPARE SD COMPILATION ----
SET INTERPRETER=ASSETS\ZX\DS48IE.P3F
IF "%BASELANG%" == "ES" SET INTERPRETER=ASSETS\ZX\DS48IS.P3F
COPY %INTERPRETER% RELEASE\UNO\DAAD.BIN  > nul 2>&1
MKDIR RELEASE\UNO\SYS  > nul 2>&1
COPY ASSETS\ZX\SYS\*.* RELEASE\UNO\SYS  > nul 2>&1
COPY %GAME%.DDB RELEASE\UNO\DAAD.DDB  > nul 2>&1
COPY ASSETS\ZX\DAAD.SDG RELEASE\UNO  > nul 2>&1
COPY ASSETS\ZX\DAAD.VAR RELEASE\UNO  > nul 2>&1
COPY ASSETS\CHARSET\%FONT6% RELEASE\UNO\DAAD.CHR  > nul 2>&1
tools\cecho\cecho {02}[OK]{07}
ECHO.

REM ----  CLEANING ---- 
DEL %GAME%.DDB > nul 2>&1
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1


REM ---- TESTER ---- 
tools\cecho\cecho {03}
ECHO "Press any key to run emulator, or Ctrl+C to cancel." 
ECHO "To exit ZEsarUX emulator, press F5, then F10." 
tools\cecho\cecho {07}

PAUSE
cd TOOLS\ZESARUX
zesarux --noconfigfile --quickexit  --zxunospi-persistent-writes --machine zxuno --enabletimexvideo --enableulaplus --no-detect-realvideo --zoom 2 --enable-esxdos-handler --esxdos-root-dir "..\..\RELEASE\UNO"  --nosplash --forcevisiblehotkeys --forceconfirmyes  --nowelcomemessage   --cpuspeed 100
CD ..\..
GOTO END

:ERROR
tools\cecho\cecho {04}
ECHO "Compile error, please check"
tools\cecho\cecho {07}
PAUSE
:END

REM ----  CLEANING ---- 
DEL %GAME%.DDB > nul 2>&1
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
