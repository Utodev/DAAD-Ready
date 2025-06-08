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


IF NOT EXIST "ASSETS\MSX2.warning" (
    if "%BASELANG%" == "ES" (

        tools\cecho\cecho {06}AVISO: ESTA BAT GENERA UNA DISTRIBUCION PARA MSX2 UTILIZANDO EL NUEVO INTERPRETE MSX2DAAD, que no es un intérprete original de DAAD. {07} 
        tools\cecho\cecho {06}MSX2DAAD esta en una etapa de pruebas, y aunque en general ha sido ya probado, podrian aparecer problemas o incompatibilidades inesperadas. {07}
        tools\cecho\cecho {06}Por favor, antes de reportar un error comprueba que el comportamiento es diferente en otros targets.{07}    
        echo.
        PAUSE
        echo "OK" > ASSETS\MSX2.warning
    )
    if "%BASELANG%" == "EN" (
        tools\cecho\cecho "{06}WARNING: THIS BAT GENERATES A DISTRIBUTION FOR MSX2 USING NEW MSX2DAAD INTERPRETER, WHICH IS NOT AN ORIGINAL DAAD interpreter{07}" 
        tools\cecho\cecho "{06}MSX2DAAD is in early stages of development, and although it has been tested quite a lot, unexpected problems or incompatibilities could appear. {07}"
        echo.
        tools\cecho\cecho "{06}Before reporting a bug, please check that the behaviour is different in other targets.{07}"
        PAUSE
        echo "OK" > ASSETS\MSX2.warning
    )
)


IF NOT exist %GAME%.DSF COPY ASSETS\TEMPLATES\BLANK_%LANG%.DSF %GAME%.DSF


REM ---- OBTENER RECURSOS ---- 
tools\cecho\cecho {06}Copying required files...{07}
echo.
COPY TOOLS\MALUVA\*.BIN > nul 2>&1
COPY ASSETS\MSX\MSX2\MSX2.DSK %GAME%.DSK > nul 2>&1
COPY ASSETS\MSX\MSX2\msx2daad_1.5.1_%BASELANG%_SC8.com msx2daad.com > nul 2>&1
tools\cecho\cecho {02}[OK]{07}

ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Frontend]{07}
ECHO.
TOOLS\DRC\DRF msx2 8_6 %GAME%.DSF
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Backend]{07}
ECHO.
PHP\PHP TOOLS\DRC\DRB.PHP msx2 8_6 %LANG% %GAME%.json %GAME%.DDB 
IF ERRORLEVEL 1 GOTO ERROR
MOVE %GAME%.DDB DAAD.DDB > nul 2>&1
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.

REM  ---- PREPARAR LAS IMáGENES ----
tools\cecho\cecho {06}Preparing images (if any){07}
ECHO.
CD IMAGES
for /L %%i in (0, 1, 9) do IF exist 00%%i.SC8 IF NOT exist 00%%i.IM8 ..\php\php ..\tools\imgwizard\imgwizard.php c 00%%i.SC8  %IMGLINES% RLE  > nul 2>&1
for /L %%i in (10, 1, 99) do IF exist 0%%i.SC8 IF NOT exist 0%%i.IM8 ..\php\php ..\tools\imgwizard\imgwizard.php c 0%%i.SC8 %IMGLINES% RLE > nul 2>&1
for /L %%i in (100, 1, 255) do IF exist %%i.SC8 IF NOT exist %%i.IM8 ..\php\php ..\tools\imgwizard\imgwizard.php c %%i.SC8 %IMGLINES% RLE > nul 2>&1

IF exist DAAD.SC8 IF NOT exist LOADING.IM8 (
    ..\php\php ..\tools\imgwizard\imgwizard.php c DAAD.SC8 212 RLE
    MOVE DAAD.IM8 LOADING.IM8  > nul 2>&1
) 
CD ..
tools\cecho\cecho {02}[OK]{07}
ECHO.

tools\cecho\cecho {06}Preparing release files{07}
ECHO.
REM  ---- PREPARAR FONT -----
REM Generate PNGs
php\php TOOLS\imgwizard\chr2png.php ASSETS\CHARSET\%FONT6%
REM convert to sc8
php\php TOOLS\msx-screen-converter\scrconv.php font0.png TOOLS\msx-screen-converter\sc8.php  > nul 2>&1
php\php TOOLS\msx-screen-converter\scrconv.php font1.png TOOLS\msx-screen-converter\sc8.php  > nul 2>&1
REM convert to im8
php\php TOOLS\imgwizard\imgwizard.php c font0.SC8 32 RLE > nul 2>&1
php\php TOOLS\imgwizard\imgwizard.php d font0.IM8 1 > nul 2>&1
php\php TOOLS\imgwizard\imgwizard.php c font1.SC8 40 RLE > nul 2>&1
php\php TOOLS\imgwizard\imgwizard.php d font1.IM8 1 > nul 2>&1
php\php TOOLS\imgwizard\imgwizard.php j FONT.IM8 font0.IM8 ASSETS\MSX\MSX2\GLUE.IM8 font1.IM8 > nul 2>&1


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
for /L %%i in (100, 1, 256) do IF exist %%i.IM8 ..\TOOLS\dsktool
\dsktool a ..\%GAME%.DSK %%i.IM8  > nul 2>&1
CD ..
tools\cecho\cecho {02}[OK]{07}
ECHO.

IF exist CUSTOM1.BAT CALL CUSTOM1.BAT
REM ----  CLEAN ---- 
;DEL DAAD.DDB > nul 2>&1
;DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
;DEL MSX2DAAD.COM > nul 2>&1
;DEL FONT.IM8 > nul 2>&1

IF exist CUSTOM2.BAT CALL CUSTOM2.BAT
IF ERRORLEVEL  1 GOTO CUSTOM

REM ---- TESTER ---- 
ECHO.
MOVE %GAME%.DSK RELEASE\MSX2 > nul 2>&1
tools\cecho\cecho {03}
IF "%BASELANG%" == "EN" (
ECHO Game ready,press any key to test or  CTRL+C to stop
tools\cecho\cecho {0C}
ECHO IMPORTANT: The MSX2 interpreter is tied to license obligations if you sell the game, check them at: https://github.com/nataliapc/msx2daad/blob/master/LICENSE
)
IF "%BASELANG%" == "ES"  (
ECHO Juego preparado, pulsa una tecla para probar, o Ctrl+C para parar.
tools\cecho\cecho {0C}
ECHO IMPORTANTE: El interprete MSX2 esta sujeto a un licencia con ciertas obligaciones si vendes el juego, revisalas: https://github.com/nataliapc/msx2daad/blob/master/LICENSE
)
tools\cecho\cecho {07}
PAUSE
cd TOOLS\openmsx
openmsx -machine Philips_NMS_8250 -script init.cfg -diska ../../RELEASE/MSX2/%GAME%.DSK
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
DEL MSX2DAAD.COM > nul 2>&1
DEL FONT.IM8 > nul 2>&1

REM  --- CUSTOM AREA ---
:CUSTOM
IF exist CUSTOM3.BAT CALL CUSTOM3.BAT 