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


IF NOT exist %GAME%.DSF COPY ASSETS\TEMPLATES\BLANK_%LANG%.DSF %GAME%.DSF

REM ---- GET RESOURCES  ---- 
tools\cecho\cecho {06}Copying required files...{07}
echo.

SET INTERPRETER=ASSETS\ZX\128K\DS128KE.BIN
IF "%BASELANG%" == "ES" SET INTERPRETER=ASSETS\ZX\128K\DS128KS.BIN
COPY %INTERPRETER% DS128K.BIN > nul 2>&1
COPY ASSETS\ZX\DAAD.SDG > nul 2>&1
tools\cecho\cecho {02}[OK]{07}

ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Frontend]{07}
echo.
TOOLS\DRC\DRF zx 128k %GAME%.DSF 
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
PHP\PHP TOOLS\DRC\DRB.PHP zx 128k %LANG% %GAME%.json %GAME%.DDB
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.

REM  ---- PREPARE THE IMAGES ----
tools\cecho\cecho {06}Preparing images (if any){07}
ECHO.

CD IMAGES
del *.128 > nul 2>&1 ; 

SET IMGWIDTH=256

for /L %%i in (0, 1, 9) do IF exist 00%%i.SCR ..\TOOLS\DRC\scrcrop.exe 00%%i.SCR 00%%i.SCT %IMGWIDTH% %IMGLINES%  > nul 2>&1
for /L %%i in (10, 1, 99) do IF exist 0%%i.SCR ..\TOOLS\DRC\scrcrop.exe 0%%i.SCR 0%%i.SCT %IMGWIDTH% %IMGLINES%  > nul 2>&1
for /L %%i in (100, 1, 256) do IF exist %%i.SCR ..\TOOLS\DRC\scrcrop.exe %%i.SCR %%i.SCT %IMGWIDTH% %IMGLINES%  > nul 2>&1

for /L %%i in (0, 1, 9) do IF exist 00%%i.SCT   ( 
                                                    <nul set /p =*
                                                      ..\TOOLS\ZX0\zx0.exe 00%%i.SCT 00%%i.zx0  > nul 2>&1
                                                       
                                                )
for /L %%i in (10, 1, 99) do IF exist 0%%i.SCT  (
                                                    <nul set /p =*
                                                    ..\TOOLS\ZX0\zx0.exe 0%%i.SCT 0%%i.zx0 > nul 2>&1   
                                                )
for /L %%i in (100, 1, 256) do IF exist %%i.SCT (
                                                     <nul set /p =*
                                                     ..\TOOLS\ZX0\zx0.exe %%i.SCT %%i.zx0 > nul 2>&1
                                                )

del *.SCT > nul 2>&1

for /L %%i in (0, 1, 9) do IF exist 00%%i.ZX0 ..\TOOLS\SCRMAKER\SCRMAKER spectrum128 00%%i.zx0 00%%i.128 %IMGWIDTH% %IMGLINES% 0,0  > nul 2>&1
for /L %%i in (10, 1, 99) do IF exist 0%%i.ZX0  ..\TOOLS\SCRMAKER\SCRMAKER spectrum128 0%%i.zx0 0%%i.128 %IMGWIDTH% %IMGLINES% 0,0 > nul 2>&1
for /L %%i in (100, 1, 256) do IF exist %%i.ZX0  ..\TOOLS\SCRMAKER\SCRMAKER spectrum128 %%i.zx0 %%i.128 %IMGWIDTH% %IMGLINES% 0,0 > nul 2>&1
CD ..

tools\cecho\cecho {02}[OK]{07}
ECHO.

tools\cecho\cecho {06}Preparing release files{07}
REM  ---- PICK  THE FONT -----
ECHO.
COPY ASSETS\ZX\DAAD.SDG > nul 2>&1
TOOLS\DD\DD  count=13 bs=1 if=DAAD.SDG of=SDG.HEAD > nul 2>&1
TOOLS\DD\DD  skip=2061 count=28 bs=1 if=DAAD.SDG of=SDG.TAIL > nul 2>&1
COPY /B SDG.HEAD + ASSETS\CHARSET\%FONT6% + SDG.TAIL DAAD.SDG > nul 2>&1
DEL SDG.HEAD > nul 2>&1
DEL SDG.TAIL > nul 2>&1

REM ---- ADD THE IMAGES ----
COPY IMAGES\DAAD.SCR DAAD.SCR > nul 2>&1

REM  ---- PREPARE THE DATA INTO 16K PAGE FILES -------
PHP\PHP.EXE TOOLS\DRC\pager128k.php  -s
IF ERRORLEVEL  1 GOTO ERROR

REM ----- PREPARE THE TAP FILE ------
if exist DAAD.SCR TOOLS\DRC\daadmaker.exe %GAME%.TAP %INTERPRETER% %GAME%.DDB DAAD.SCR ASSETS\CHARSET\%FONT6% INDEX.BIN DAAD.SDG> nul 2>&1
if NOT exist DAAD.SCR TOOLS\DRC\daadmaker.exe %GAME%.TAP %INTERPRETER% %GAME%.DDB ASSETS\CHARSET\%FONT6% INDEX.BIN DAAD.SDG> nul 2>&1

MOVE /Y %GAME%.TAP RELEASE\ZX128K\%GAME%.TAP > nul 2>&1

IF exist CUSTOM1.BAT CALL CUSTOM1.BAT
REM ----  CLEANING ---- 
DEL %GAME%.json > nul 2>&1
DEL *.DDB > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
DEL *.SDG > nul 2>&1
DEL DAAD.SCR > nul 2>&1
DEL *.TMP> nul 2>&1
DEL *.PT > nul 2>&1

IF exist CUSTOM2.BAT CALL CUSTOM2.BAT
IF ERRORLEVEL  1 GOTO CUSTOM


tools\cecho\cecho {03}
ECHO Game is ready, press any key to test or Ctrl+C to cancel
ECHO When in emulator, select the "LOADER" option at the +3 menu
tools\cecho\cecho {07}
PAUSE
cd TOOLS\ZESARUX
zesarux --noconfigfile --load-additional-config --quickexit --zoom 2 --machine P2 --realvideo --nosplash --forcevisiblehotkeys --forceconfirmyes  --nowelcomemessage  --cpuspeed 100 "..\..\RELEASE\ZX128K\%GAME%.TAP"
CD ..\..
GOTO END

:ERROR
tools\cecho\cecho {04}
ECHO Compile error, please check
tools\cecho\cecho {07}
PAUSE
:END

REM ----  CLEANING ---- 
DEL %GAME%.json > nul 2>&1
DEL DAAD.DDB > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
DEL *.SDG > nul 2>&1
DEL *.PT > nul 2>&1
DEL DAAD.SCR > nul 2>&1
DEL *.TMP> nul 2>&1
DEL *.PT > nul 2>&1



REM  --- CUSTOM AREA ---
:CUSTOM
IF exist CUSTOM3.BAT CALL CUSTOM3.BAT 