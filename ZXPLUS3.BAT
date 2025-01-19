@echo off
SET DAADSCRIPT=%~n0

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

REM ---- GET RESOURCES  ---- 
tools\cecho\cecho {06}Copying required files...{07}
echo.
COPY TOOLS\MALUVA\*.BIN > nul 2>&1
COPY ASSETS\ZX\PLUS3%BASELANG%.DSK %GAME%.DSK > nul 2>&1
tools\cecho\cecho {02}[OK]{07}

ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Frontend]{07}
echo.
TOOLS\DRC\DRF zx plus3 %GAME%.DSF
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
PHP\PHP TOOLS\DRC\DRB.PHP zx plus3 %LANG% %GAME%.json %GAME%.DDB -3h
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
MOVE %GAME%.DDB DAAD.DDB > nul 2>&1

REM  ---- PREPARE  IMAGES ----
tools\cecho\cecho {06}Preparing images (if any){07}
ECHO.

CD IMAGES
for /L %%i in (0, 1, 9) do IF exist 00%%i.SCR ..\TOOLS\MALUVA\SC2DAAD zx 00%%i.SCR 00%%i.ZXS %IMGLINES%
for /L %%i in (10, 1, 99) do IF exist 0%%i.SCR  ..\TOOLS\MALUVA\SC2DAAD zx 0%%i.SCR 0%%i.ZXS %IMGLINES%
for /L %%i in (100, 1, 256) do IF exist %%i.SCR  ..\TOOLS\MALUVA\SC2DAAD zx %%i.SCR %%i.ZXS %IMGLINES% 
CD ..
tools\cecho\cecho {02}[OK]{07}
ECHO.

REM  ---- PREPARE THE FONT -----
tools\cecho\cecho {06}Preparing release files{07}
ECHO.
COPY ASSETS\ZX\DAAD.SDG > nul 2>&1
TOOLS\DD\DD  count=13 bs=1 if=DAAD.SDG of=SDG.HEAD > nul 2>&1
TOOLS\DD\DD  skip=2061 count=28 bs=1 if=DAAD.SDG of=SDG.TAIL > nul 2>&1
COPY /B SDG.HEAD + ASSETS\CHARSET\%FONT6% + SDG.TAIL DAAD.TMP > nul 2>&1
TOOlS\SPECFORM\SPECFORM -a 63447 DAAD.TMP > nul 2>&1
DEL SDG.HEAD > nul 2>&1
DEL SDG.TAIL > nul 2>&1
DEL DAAD.SDG > nul 2>&1
MOVE DAAD.TMP.zxb DAAD.SDG > nul 2>&1


REM  ---- COPY TO DISK  ---- 
TOOLS\CPCDiskXP\CPCDiskXP -File DAAD.DDB -AddToExistingDsk %GAME%.DSK > nul 2>&1
TOOLS\CPCDiskXP\CPCDiskXP -File DAAD.SDG -AddToExistingDsk %GAME%.DSK > nul 2>&1
IF exist 0.XMB TOOLS\CPCDiskXP\CPCDiskXP -File 0.XMB -AddToExistingDsk %GAME%.DSK
if exist IMAGES\DAAD.SCR  (
    TOOLS\SPECFORM\SPECFORM IMAGES\DAAD.SCR > nul 2>&1
    MOVE IMAGES\DAAD.SCR.zxb DAAD.SCR > nul 2>&1
    TOOLS\CPCDiskXP\CPCDiskXP -File DAAD.SCR -AddToExistingDsk %GAME%.DSK
    DEL DAAD.SCR  > nul 2>&1
)
for /L %%i in (0, 1, 9) do IF exist IMAGES\00%%i.ZXS TOOLS\CPCDiskXP\CPCDiskXP -File IMAGES\00%%i.ZXS -AddToExistingDsk %GAME%.DSK
for /L %%i in (10, 1, 99) do IF exist IMAGES\0%%i.ZXS TOOLS\CPCDiskXP\CPCDiskXP -File IMAGES\0%%i.ZXS -AddToExistingDsk %GAME%.DSK
for /L %%i in (100, 1, 255) do IF exist IMAGES\%%i.ZXS TOOLS\CPCDiskXP\CPCDiskXP -File IMAGES\%%i.ZXS -AddToExistingDsk %GAME%.DSK
tools\cecho\cecho {02}[OK]{07}
ECHO.


IF exist CUSTOM1.BAT CALL CUSTOM1.BAT
REM ----  CLEANING ---- 
DEL DAAD.DDB > nul 2>&1
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
DEL *.SDG > nul 2>&1
DEL *.TMP > nul 2>&1
DEL *.CHR > nul 2>&1

IF exist CUSTOM2.BAT CALL CUSTOM2.BAT
IF ERRORLEVEL  1 GOTO CUSTOM
REM ---- TESTER ---- 
ECHO.
MOVE %GAME%.DSK RELEASE\PLUS3 > nul 2>&1

tools\cecho\cecho {03}
ECHO Game is ready, press any key to test or Ctrl+C to cancel
ECHO When in emulator, select the "LOADER" option at the +3 menu
tools\cecho\cecho {07}
PAUSE
cd TOOLS\ZESARUX
zesarux --noconfigfile --quickexit --zoom 2 --machine P341 --realvideo --nosplash --forcevisiblehotkeys --forceconfirmyes  --nowelcomemessage  --cpuspeed 100 "..\..\RELEASE\PLUS3\%GAME%.DSK"
CD ..\..
GOTO END

:ERROR
tools\cecho\cecho {04}
ECHO Compile error, please check
tools\cecho\cecho {07}
PAUSE
:END

REM ----  CLEANING ---- 
DEL DAAD.DDB > nul 2>&1
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
DEL *.TMP > nul 2>&1
DEL *.CHR > nul 2>&1

REM  --- CUSTOM AREA ---
:CUSTOM
IF exist CUSTOM3.BAT CALL CUSTOM3.BAT 