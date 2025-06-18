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


REM ---- GET RESOURCES ---- 
tools\cecho\cecho {06}Copying required files...{07}
echo.

COPY ASSETS\MSX\MSX1\MSX1.DSK %GAME%.DSK > nul 2>&1
COPY ASSETS\MSX\MSX1\msxdaad.com > nul 2>&1
tools\cecho\cecho {02}[OK]{07}
ECHO.

tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Frontend]{07}
ECHO.
TOOLS\DRC\DRF msx %GAME%.DSF
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Backend]{07}
ECHO.
PHP\PHP TOOLS\DRC\DRB.PHP msx %LANG% %GAME%.json %GAME%.DDB 
IF ERRORLEVEL 1 GOTO ERROR
MOVE %GAME%.DDB DAAD.DDB > nul 2>&1
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.


REM  ---- PREPARE IMAGES ----
tools\cecho\cecho {06}Preparing images (if any){07}
ECHO.
CD IMAGES
for /L %%i in (0, 1, 9) do IF exist 00%%i.SC2 ..\TOOLS\MALUVA\SC2DAAD msx 00%%i.SC2 00%%i.MS2 %IMGLINES%
for /L %%i in (10, 1, 99) do IF exist 0%%i.SC2  ..\TOOLS\MALUVA\SC2DAAD msx 0%%i.SC2 0%%i.MS2 %IMGLINES%
for /L %%i in (100, 1, 255) do IF exist %%i.SC2  ..\TOOLS\MALUVA\SC2DAAD msx %%i.SC2 %%i.MS2 %IMGLINES% 
CD ..
tools\cecho\cecho {02}[OK]{07}
ECHO.

tools\cecho\cecho {06}Preparing release files{07}
ECHO.
REM  ---- PREPARE THE FONT -----
COPY ASSETS\MSX\MSX1\DAAD.MDG > nul 2>&1

TOOLS\DD\DD  count=218 bs=1 if=DAAD.MDG of=MDG.HEAD > nul 2>&1
TOOLS\DD\DD  skip=2266 count=34 bs=1 if=DAAD.MDG of=MDG.TAIL > nul 2>&1
COPY /B MDG.HEAD + ASSETS\CHARSET\%FONT6% + MDG.TAIL DAAD.TMP > nul 2>&1
DEL MDG.HEAD > nul 2>&1
DEL MDG.TAIL > nul 2>&1
DEL DAAD.MDG > nul 2>&1
MOVE DAAD.TMP DAAD.MDG > nul 2>&1


REM  ---- COPY FILES ---- 
TOOLS\dsktool\dsktool a %GAME%.DSK DAAD.DDB > nul 2>&1
TOOLS\dsktool\dsktool a %GAME%.DSK DAAD.MDG > nul 2>&1

REM GET THE INTERPRETER
IF LANG == "EN" (
    COPY ASSETS\MSX\MSX1\DMSXIEF.BIN DAAD.Z80 > nul 2>&1
) ELSE (
    COPY ASSETS\MSX\MSX1\DMSXISF.BIN DAAD.Z80 > nul 2>&1
)

TOOLS\dsktool\dsktool a %GAME%.DSK DAAD.Z80 > nul 2>&1
DEL DAAD.Z80 > nul 2>&1

REM The loader
CD ASSETS\MSX\MSX1
..\..\..\TOOLS\dsktool\dsktool a ..\..\..\%GAME%.DSK MSXDAAD.COM > nul 2>&1
cd ..\..\..

REM The Xmessages file
IF exist 0.XMB TOOLS\dsktool\dsktool a %GAME%.DSK 0.XMB > nul 2>&1

REM The loading screen, if any
if exist IMAGES\DAAD.SC2  (
    CD IMAGES
    ..\TOOLS\dsktool\dsktool a ..\%GAME%.DSK DAAD.SC2 > nul 2>&1
    CD ..
)

CD IMAGES
for /L %%i in (0, 1, 9) do IF exist 00%%i.MS2 ..\TOOLS\dsktool\dsktool a ..\%GAME%.DSK 00%%i.MS2 > nul 2>&1
for /L %%i in (10, 1, 99) do IF exist 0%%i.MS2 ..\TOOLS\dsktool\dsktool a ..\%GAME%.DSK 0%%i.MS2 > nul 2>&1
for /L %%i in (100, 1, 256) do IF exist %%i.MS2 ..\TOOLS\dsktool\dsktool a ..\%GAME%.DSK %%i.MS2 > nul 2>&1
CD ..
tools\cecho\cecho {02}[OK]{07}
ECHO.

IF exist CUSTOM1.BAT CALL CUSTOM1.BAT
REM ----  CLEAN ---- 
DEL DAAD.DDB > nul 2>&1
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
DEL *.CHR > nul 2>&1
DEL *.MDG  > nul 2>&1
DEL msxdaad.com > nul 2>&1

IF exist CUSTOM2.BAT CALL CUSTOM2.BAT
IF ERRORLEVEL  1 GOTO CUSTOM

REM ---- TESTER ---- 
ECHO.
MOVE %GAME%.DSK RELEASE\MSX1 > nul 2>&1
tools\cecho\cecho {03}
IF "%BASELANG%" == "EN" ECHO Game ready,press any key to test or  CTRL+C to stop
IF "%BASELANG%" == "ES" ECHO Juego preparado, pulsa una tecla para probar, o Ctrl+C para parar.
tools\cecho\cecho {07}
PAUSE
cd TOOLS\openmsx
openmsx -machine Philips_NMS_8250 -script init.cfg -diska ../../RELEASE/MSX1/%GAME%.DSK
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
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
DEL *.CHR > nul 2>&1

REM  --- CUSTOM AREA ---
:CUSTOM
IF exist CUSTOM3.BAT CALL CUSTOM3.BAT 