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


REM ---- OBTENER RECURSOS ---- 
COPY TOOLS\MALUVA\*.BIN > nul 2>&1
COPY ASSETS\MSX\MSX2_%BASELANG%.DSK %GAME%.DSK > nul 2>&1
COPY ASSETS\MSX\msx2daad_1.4_%BASELANG%_SC8.com msx2daad.com > nul 2>&1

ECHO.
ECHO ---------------------------------------------------------
ECHO Compiling [Front End]...
TOOLS\DRC\DRF msx2 8_6 %GAME%.DSF
IF ERRORLEVEL 1 GOTO ERROR
ECHO.
ECHO ---------------------------------------------------------
ECHO Compiling [Back End]...
PHP\PHP TOOLS\DRC\DRB.PHP msx2 8_6 %LANG% %GAME%.json %GAME%.DDB 
IF ERRORLEVEL 1 GOTO ERROR
MOVE %GAME%.DDB DAAD.DDB > nul 2>&1

REM  ---- PREPARAR LAS IMáGENES ----
CD IMAGES
for /L %%i in (0, 1, 9) do IF exist 00%%i.SC8 IF NOT exist 00%%i.IM8 ..\php\php ..\tools\imgwizard\imgwizard.php c 00%%i.SC8  %IMGLINES% RLE  > nul 2>&1
for /L %%i in (10, 1, 99) do IF exist 0%%i.SC8 IF NOT exist 0%%i.IM8..\php\php ..\tools\imgwizard\imgwizard.php c 0%%i.SC8 %IMGLINES% RLE > nul 2>&1
for /L %%i in (100, 1, 255) do IF exist %%i.SC8 IF NOT exist %%i.IM8 ..\php\php ..\tools\imgwizard\imgwizard.php c %%i.SC8 %IMGLINES% RLE > nul 2>&1

IF exist DAAD.SC8 IF NOT exist LOADING.IM8 (
    ..\php\php ..\tools\imgwizard\imgwizard.php c DAAD.SC8 212 RLE
    MOVE DAAD.IM8 LOADING.IM8  > nul 2>&1
) 
CD ..

REM  ---- PREPARAR FONT -----
REM Generate PNGs
php TOOLS\imgwizard\chr2png.php ASSETS\CHARSET\%FONT6%
REM convert to sc8
php TOOLS\msx-screen-converter\scrconv.php font0.png TOOLS\msx-screen-converter\sc8.php  > nul 2>&1
php TOOLS\msx-screen-converter\scrconv.php font1.png TOOLS\msx-screen-converter\sc8.php  > nul 2>&1
REM convert to im8
php TOOLS\imgwizard\imgwizard.php c font0.SC8 32 RLE > nul 2>&1
php TOOLS\imgwizard\imgwizard.php d font0.IM8 1 > nul 2>&1
php TOOLS\imgwizard\imgwizard.php c font1.SC8 40 RLE > nul 2>&1
php TOOLS\imgwizard\imgwizard.php d font1.IM8 1 > nul 2>&1
php TOOLS\imgwizard\imgwizard.php j FONT.IM8 font0.IM8 ASSETS\MSX\GLUE.IM8 font1.IM8 > nul 2>&1
REM Clean
DEL font1.png > nul 2>&1
DEL font0.png > nul 2>&1
DEL font1.sc8 > nul 2>&1
DEL font0.sc8 > nul 2>&1
DEL font1.im8 > nul 2>&1
DEL font0.im8 > nul 2>&1

REM  ---- COPIAR FICHEROS AL DISCO ---- 
TOOLS\dsktool\dsktool a %GAME%.DSK DAAD.DDB  > nul 2>&1
TOOLS\dsktool\dsktool a %GAME%.DSK MSX2DAAD.COM  > nul 2>&1
TOOLS\dsktool\dsktool a %GAME%.DSK FONT.IM8  > nul 2>&1
IF exist 0.XMB (
    ren 0.XMB TEXTS.XDB
    TOOLS\dsktool\dsktool a %GAME%.DSK TEXTS.XDB  > nul 2>&1
    del TEXTS.XDB > nul 2>&1
) 

CD IMAGES
if exist LOADING.IM8 ..\TOOLS\dsktool\dsktool a ..\%GAME%.DSK LOADING.IM8

for /L %%i in (0, 1, 9) do IF exist 00%%i.IM8 ..\TOOLS\dsktool\dsktool a ..\%GAME%.DSK 00%%i.IM8  > nul 2>&1
for /L %%i in (10, 1, 99) do IF exist 0%%i.IM8 ..\TOOLS\dsktool\dsktool a ..\%GAME%.DSK 0%%i.IM8  > nul 2>&1
for /L %%i in (100, 1, 256) do IF exist %%i.IM8 ..\TOOLS\dsktool\dsktool a ..\%GAME%.DSK %%i.IM8  > nul 2>&1
CD ..


REM ----  CLEAN ---- 
DEL DAAD.DDB > nul 2>&1
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
DEL MSX2DAAD.COM > nul 2>&1
DEL FONT.IM8 > nul 2>&1

REM ---- TESTER ---- 
ECHO.
MOVE %GAME%.DSK RELEASE\MSX2 > nul 2>&1
IF "%BASELANG%" == "EN" (
ECHO "Game ready,press any key to test or  CTRL+C to stop"
ECHO "IMPORTANT: The MSX2 interpreter is tied to license obligations, check them at: https://github.com/nataliapc/msx2daad/blob/master/LICENSE"
)
IF "%BASELANG%" == "ES"  (
ECHO "Juego preparado, pulsa una tecla para probar, o Ctrl+C para parar."
ECHO "IMPORTANTE: El interprete MSX2 esta sujeto a un licencia con ciertas obligaciones, revisalas: https://github.com/nataliapc/msx2daad/blob/master/LICENSE"
)
PAUSE
cd TOOLS\openmsx
openmsx -machine Philips_NMS_8250 -script init.cfg -diska ../../RELEASE/MSX2/%GAME%.DSK
cd ..\..
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
DEL MSX2DAAD.COM > nul 2>&1
DEL FONT.IM8 > nul 2>&1