@echo off
SET DAADSCRIPT=%~n0

REM ---- ZONA DE VARIABLES ---- 
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

IF NOT EXIST "ASSETS\HTML.warning" (
    if "%BASELANG%" == "ES" (

        tools\cecho\cecho {06}AVISO: ESTA BAT GENERA UNA DISTRIBUCION PARA HTML UTILIZANDO EL NUEVO INTERPRETE jDAAD, que no es un interprete original de DAAD. {07} 
        tools\cecho\cecho {06}jDAAD esta en una etapa de pruebas, y aunque en general ha sido ya probado, podrian aparecer problemas o incompatibilidades inesperadas. {07}
        tools\cecho\cecho {06}Por favor, antes de reportar un error comprueba que el comportamiento es diferente en otras maquinas.{07}    
        echo.
        PAUSE
        echo "OK" > ASSETS\HTML.warning
    )
    if "%BASELANG%" == "EN" (
        tools\cecho\cecho "{06}WARNING: THIS BAT GENERATES A DISTRIBUTION FOR HTML USING NEW jDAAD INTERPRETER, WHICH IS NOT AN ORIGINAL DAAD interpreter{07}" 
        tools\cecho\cecho "{06}jDAAD is in early stages of development, and although it has been tested quite a lot, unexpected problems or incompatibilities could appear. {07}"
        echo.
        tools\cecho\cecho "{06}Before reporting a bug, please check that the behaviour is different in other machines.{07}"
        PAUSE
        echo "OK" > ASSETS\HTML.warning
    )
)



IF NOT exist %GAME%.DSF COPY ASSETS\TEMPLATES\BLANK_%LANG%.DSF %GAME%.DSF

REM ---- RESOURCES  ---- 
tools\cecho\cecho {06}Copying required files...{07}
echo.
XCOPY ASSETS\HTML\*.* RELEASE\HTML /s /y > nul 2>&1
tools\cecho\cecho {02}[OK]{07}


ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Frontend]{07}
ECHO.
TOOLS\DRC\DRF html %GAME%.DSF
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Backend]{07}
ECHO.
PHP\PHP TOOLS\DRC\DRB.PHP html  %LANG% %GAME%.json %GAME%.DDB -s
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.


REM  ---- COPY FILES  ---- 
COPY  %GAME%.JDDB RELEASE\HTML\daad.jddb > nul 2>&1
DEL RELEASE\HTML\*.mp3 > nul 2>&1
DEL RELEASE\HTML\*.ogg > nul 2>&1
for /L %%i in (0, 1, 9) do IF exist SOUNDS\00%%i.mp3 COPY SOUNDS\00%%i.mp3 RELEASE\HTML\ > nul 2>&1
for /L %%i in (10, 1, 99)do IF exist SOUNDS\0%%i.mp3 COPY SOUNDS\0%%i.mp3 RELEASE\HTML\ > nul 2>&1
for /L %%i in (100, 1, 256) do IF exist SOUNDS\%%i.mp3 COPY SOUNDS\%%i.mp3 RELEASE\HTML\ > nul 2>&1
for /L %%i in (0, 1, 9) do IF exist IMAGES\00%%i.mp4 COPY IMAGES\HTML\00%%i.mp4 RELEASE\HTML\ > nul 2>&1
for /L %%i in (10, 1, 99)do IF exist IMAGES\0%%i.mp4 COPY IMAGES\HTML\0%%i.mp4 RELEASE\HTML\ > nul 2>&1
for /L %%i in (100, 1, 256) do IF exist IMAGES\%%i.mp4 COPY IMAGES\HTML\%%i.mp4 RELEASE\HTML\ > nul 2>&1

REM ---- PREPARE FONT -----
PHP\PHP tools\jDAADFontMaker\jDAADFontMaker.php ASSETS\CHARSET\%FONT6% RELEASE\HTML\font.js 


REM  ---- PREPARE IMAGES ----
SET IMGWIDTH=320

tools\cecho\cecho {06}Preparing images (if any){07}
for /L %%i in (0, 1, 9) do IF exist IMAGES\HTML\00%%i.png PHP\PHP TOOLS/jDAADImager/jDAADImager.php IMAGES\HTML\00%%i.png RELEASE\HTML\images.js 0,0 %IMGWIDTH%,%IMGLINES%
for /L %%i in (10, 1, 99) do IF exist IMAGES\HTML\0%%i.png PHP\PHP TOOLS/jDAADImager/jDAADImager.php IMAGES\HTML\0%%i.png RELEASE\HTML\images.js 0,0 %IMGWIDTH%,%IMGLINES%
for /L %%i in (100, 1, 256) do IF exist IMAGES\HTML\%%i.png PHP\PHP TOOLS/jDAADImager/jDAADImager.php IMAGES\HTML\%%i.png RELEASE\HTML\images.js 0,0 %IMGWIDTH%,%IMGLINES%

REM  ---- PREPARE SOUNDS AND VIDEOS ----
PHP\PHP TOOLS/jDAADImager/jDAADMultimedia.php RELEASE\HTML\  0,0


IF exist CUSTOM1.BAT CALL CUSTOM1.BAT
REM ----  CLEANING ---- 
DEL %GAME%.DDB > nul 2>&1
DEL %GAME%.JDDB > nul 2>&1
DEL %GAME%.json > nul 2>&1
DEL 0.XMB > nul 2>&1

IF exist CUSTOM2.BAT CALL CUSTOM2.BAT
IF ERRORLEVEL  1 GOTO CUSTOM

REM ---- TESTER ---- 
ECHO.
tools\cecho\cecho {03}
IF "%BASELANG%" == "EN" (
ECHO Game ready,press any key to test or  CTRL+C to stop
)
IF "%BASELANG%" == "ES" (
ECHO Juego preparado, pulsa una tecla para probar, o Ctrl+C para parar.
)
PAUSE
CD RELEASE\HTML 
START index.html
CD ..\..
GOTO FIN

:ERROR
tools\cecho\cecho {04}
ECHO Compile error, please check
tools\cecho\cecho {07}
PAUSE
:FIN

REM ----  CLEANING ---- 
DEL %GAME%.DDB > nul 2>&1
DEL %GAME%.JDDB > nul 2>&1
DEL 0.XMB > nul 2>&1
DEL %GAME%.json > nul 2>&1



REM  --- CUSTOM AREA ---
:CUSTOM
IF exist CUSTOM3.BAT CALL CUSTOM3.BAT 