@echo off
SET DAADSCRIPT=%~n0

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
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
SET INTERPRETER=ASSETS\MACOS_EXPERIMENTAL\PLAYER.EXE
MD RELEASE\MACOS_EXPERIMENTAL\%GAME%.app > nul 2>&1
XCOPY ASSETS\MACOS_EXPERIMENTAL\ADP.app\*.*  RELEASE\MACOS_EXPERIMENTAL\%GAME%.app /E /Y
COPY ASSETS\CHARSET\%FONT6% RELEASE\MACOS_EXPERIMENTAL\%GAME%.app\Contents\Resources\PART1.TMP > nul 2>&1
TOOlS\SPECFORM\SPECFORM -a 16384 RELEASE\MACOS_EXPERIMENTAL\%GAME%.app\Contents\Resources\PART1.TMP > nul 2>&1
MOVE RELEASE\MACOS_EXPERIMENTAL\%GAME%.app\Contents\Resources\PART1.TMP.zxb RELEASE\MACOS_EXPERIMENTAL\%GAME%.app\Contents\Resources\PART1.CHR > nul 2>&1
COPY RELEASE\MACOS_EXPERIMENTAL\%GAME%.app\Contents\Resources\PART1.CHR RELEASE\MACOS_EXPERIMENTAL\%GAME%.app\Contents\Resources\PART1.CH0 > nul 2>&1
DEL RELEASE\MACOS_EXPERIMENTAL\%GAME%.app\Contents\Resources\PART1.TMP > nul 2>&1
tools\cecho\cecho {02}[OK]{07}
ECHO.


tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Frontend]{07}
echo.
TOOLS\DRC\DRF st %GAME%.DSF
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Backend]{07}
echo.
PHP\PHP TOOLS\DRC\DRB.PHP st %LANG% %GAME%.json %GAME%.DDB 
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.

REM  ---- PREPARE IMAGES ----
PHP\php TOOLS\img2daad\img2daad.php IMAGES RELEASE\MACOS_EXPERIMENTAL\%GAME%.app\Contents\Resources\PART1.DAT 
IF exist IMAGES\DAAD.PNG (
    PHP\PHP TOOLS\IMG2DAAD\PNG2DEGAS.PHP IMAGES\DAAD.PNG IMAGES\DAAD.PI1
    MOVE IMAGES\DAAD.PI1 RELEASE\MACOS_EXPERIMENTAL\%GAME%.app\Contents\Resources\PART1.SCR > nul 2>&1
)
IF ERRORLEVEL 1 GOTO ERROR



tools\cecho\cecho {06}Preparing release files{07}
ECHO.
MOVE %GAME%.DDB RELEASE\MACOS_EXPERIMENTAL\%GAME%.app\Contents\Resources\PART1.DDB > nul 2>&1
ECHO.

IF exist CUSTOM1.BAT CALL CUSTOM1.BAT
REM ----  CLEAN ---- 
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
DEL *.CHR > nul 2>&1
DEL *.CH0 > nul 2>&1

IF exist CUSTOM2.BAT CALL CUSTOM2.BAT
IF ERRORLEVEL  1 GOTO CUSTOM
REM ---- TESTER ---- 


ECHO.
tools\cecho\cecho {03}
IF "%BASELANG%" == "EN" (
ECHO IMPORTANT NOTICE: This target it's in early stages of development, you may find bugs and glitches. Please report them to the author.
ECHO Also, have in mind MacOS will not trust the developer of this game, s you will have to open it manually from MacOS settings.
ECHO Finally, for obvious reasons, this game will not run on Window so you cannot test it.
)
)
IF "%BASELANG%" == "ES" (
ECHO AVISO IMPORTANTE: este target esta en fase de desarrollo, puede contener errores y fallos. Por favor, reporte cualquier error al autor.
ECHO Por otro lado, ten en cuenta que MacOS no confiara en el desarrollador de este juego, por lo que tendras que habilitarlo manualmente desde los ajustes de MacOS.
echo Finalmente, por razones obvias, este juego no se puede probar en Windows.
)
)
tools\cecho\cecho {07}
PAUSE
GOTO FIN

REM ----  CLEAN ---- 
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
DEL *.CHR > nul 2>&1
DEL *.CH0 > nul 2>&1

REM  --- CUSTOM AREA ---
:CUSTOM
IF exist CUSTOM3.BAT CALL CUSTOM3.BAT 