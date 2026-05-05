@echo off
SET DAADSCRIPT=%~n0

CALL CONFIG.BAT
IF exist CUSTOM.BAT CALL CUSTOM.BAT

REM ---- CHECK IF LANG IS SET ----
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

REM ---- FIRST TIME WARNING ----
IF NOT EXIST "ASSETS\WIN.warning" (
    if "%BASELANG%" == "ES" (

        tools\cecho\cecho {06}AVISO: ESTA BAT GENERA UNA DISTRIBUCION PARA WINDOWS UTILIZANDO EL NUEVO INTERPRETE ADP. {07}
        tools\cecho\cecho {06}ADP esta en una etapa inicial de pruebas, y aunque en general ha sido ya probado, podrian aparecer problemas o incompatibilidades inesperadas. {07}
        tools\cecho\cecho {06}Por favor, antes de reportar un error comprueba que el comportamiento es diferente a otros targets.{07}
        echo.
        PAUSE
        echo "OK" > ASSETS\WIN.warning
    )
    if "%BASELANG%" == "EN" (
        tools\cecho\cecho "{06}WARNING: THIS BAT GENERATES A DISTRIBUTION FOR WINDOWS USING NEW ADP INTERPRETER{07}"
        tools\cecho\cecho "{06}ADP is in early stages of development, and although it has been tested quite a lot, unexpected problems or incompatibilities could appear. {07}"
        echo.
        tools\cecho\cecho "{06}Before reporting a bug, please check that the behaviour is different to other targets.{07}"
        PAUSE
        echo "OK" > ASSETS\WIN.warning
    )
)

IF NOT exist %GAME%.DSF COPY ASSETS\TEMPLATES\BLANK_%LANG%.DSF %GAME%.DSF

MKDIR RELEASE\WINDOWS_EXPERIMENTAL > NUL 2>&1
DEL /Q RELEASE\WINDOWS_EXPERIMENTAL\*.DDB > nul 2>&1
DEL /Q RELEASE\WINDOWS_EXPERIMENTAL\*.DAT > nul 2>&1
DEL /Q RELEASE\WINDOWS_EXPERIMENTAL\*.CHR > nul 2>&1
DEL /Q RELEASE\WINDOWS_EXPERIMENTAL\*.FNT > nul 2>&1
DEL /Q RELEASE\WINDOWS_EXPERIMENTAL\*.VGA > nul 2>&1
DEL /Q RELEASE\WINDOWS_EXPERIMENTAL\*.PCX > nul 2>&1
DEL /Q RELEASE\WINDOWS_EXPERIMENTAL\*.SCR > nul 2>&1
DEL /Q RELEASE\WINDOWS_EXPERIMENTAL\*.EXE > nul 2>&1

REM ---- OBTENER RECURSOS ----
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
SET INTERPRETER=ASSETS\WINDOWS_EXPERIMENTAL\adp-player.exe
COPY %INTERPRETER% RELEASE\WINDOWS_EXPERIMENTAL\%GAME%.EXE > nul 2>&1

IF exist ASSETS\CHARSET\%FONTPCDAAD% COPY /Y ASSETS\CHARSET\%FONTPCDAAD% RELEASE\WINDOWS_EXPERIMENTAL\%GAME%.FNT > nul 2>&1
IF not exist ASSETS\CHARSET\%FONTPCDAAD% COPY /Y ASSETS\CHARSET\%FONT6% RELEASE\WINDOWS_EXPERIMENTAL\%GAME%.CHR > nul 2>&1

tools\cecho\cecho {02}[OK]{07}
ECHO.

tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Frontend]{07}
echo.
TOOLS\DRC\DRF pc vga256 %GAME%.DSF -v3
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Backend]{07}
echo.
PHP\PHP TOOLS\DRC\DRB.PHP pc vga256 %LANG% %GAME%.json %GAME%.DDB
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.

REM  ---- PREPARE IMAGES ----
tools\cecho\cecho {06}Preparing images{07}
echo.
IF /I "%HIRES%"=="1" (
        SET IMGPATH=IMAGES\EXPERIMENTAL\HIRES
        SET IMGPATHBACK=..\..\..
        SET IMGWIDTH=640
        SET IMGHEIGHT=192
        SET INTROSIZE=640 400
        SET PARAMETER=-screen=640x400 -2x=1
        ECHO Creating HIRES 640x400 GAME
    ) ELSE (
        SET IMGPATH=IMAGES\EXPERIMENTAL\256
        SET IMGPATHBACK=..\..
        SET IMGWIDTH=320
        SET IMGHEIGHT=96
        SET INTROSIZE=320 200
        SET PARAMETER=
        ECHO Creating LORES 320x200 GAME
    )

IF exist %IMGPATH%\DAAD.PNG (
    PHP\PHP TOOLS\ADP\png2pcx.php %IMGPATH%\DAAD.PNG RELEASE\WINDOWS_EXPERIMENTAL\%GAME%.PCX
    IF ERRORLEVEL 1 GOTO ERROR
)

IF not exist RELEASE\WINDOWS_EXPERIMENTAL\%GAME%.PCX IF exist %IMGPATH%\DAAD.PCX (
    COPY /Y %IMGPATH%\DAAD.PCX RELEASE\WINDOWS_EXPERIMENTAL\%GAME%.PCX > nul 2>&1
)

TOOLS\ADP\DMG create RELEASE\WINDOWS_EXPERIMENTAL\%GAME%.DAT %IMGPATH%;SOUNDS\EXPERIMENTAL -format=dat5 -mode=planar8 -width=%IMGWIDTH% -height=%IMGHEIGHT% -remap=16-255 %PARAMETER%
IF ERRORLEVEL 1 GOTO ERROR

tools\cecho\cecho {06}Preparing release files{07}
ECHO.
MOVE %GAME%.DDB RELEASE\WINDOWS_EXPERIMENTAL\%GAME%.DDB > nul 2>&1
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
    tools\cecho\cecho {04}IMPORTANT NOTICE:{07} this target is in early stages of development, and may contain bugs and glitches.{\n}
    tools\cecho\cecho Please report any errors to the author.{\n}{\n}
    tools\cecho\cecho To change the mode in the future, edit CONFIG.BAT:{\n}
    tools\cecho\cecho  - SET HIRES=1 to build the 640x400 2X mode from IMAGES\EXPERIMENTAL\HIRES{\n}
    tools\cecho\cecho  - SET HIRES=0 to build the 320x200 mode from IMAGES\EXPERIMENTAL\256{\n}{\n}
    tools\cecho\cecho THE GAME HAS BEEN COMPILED SUCCESSFULLY. PRESS ENTER TO START THE EMULATOR, OR CTRL+C TO STOP.{\n}
    tools\cecho\cecho The game will be executed from RELEASE\WINDOWS_EXPERIMENTAL.{\n}{\n}
)
IF "%BASELANG%" == "ES" (
    tools\cecho\cecho {04}AVISO IMPORTANTE:{07} este target est{\u00E1} en fase de desarrollo, puede contener errores y fallos.{\n}
    tools\cecho\cecho Por favor, reporte cualquier error al autor.{\n}{\n}
    tools\cecho\cecho Para cambiar de modo en el futuro, cambia CONFIG.BAT:{\n}
    tools\cecho\cecho  - SET HIRES=1 para generar el modo 640x400 2X desde IMAGES\EXPERIMENTAL\HIRES{\n}
    tools\cecho\cecho  - SET HIRES=0 para generar el modo 320x200 desde IMAGES\EXPERIMENTAL\256{\n}{\n}
    tools\cecho\cecho EL JUEGO SE HA COMPILADO CORRECTAMENTE, PULSE ENTER PARA INICIAR EL EMULADOR, O CTRL+C PARA PARAR{\n}
    tools\cecho\cecho El juego se ejecutar{\u00E1} desde RELEASE\WINDOWS_EXPERIMENTAL.{\n}{\n}
)
tools\cecho\cecho {07}
PAUSE
CD RELEASE\WINDOWS_EXPERIMENTAL
echo %GAME%.EXE
%GAME%.EXE
CD ..\..

GOTO FIN

:ERROR
tools\cecho\cecho {04}
ECHO Compile error, please check
tools\cecho\cecho {07}
PAUSE
:FIN

REM ----  CLEAN ----
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
DEL *.CHR > nul 2>&1
DEL *.CH0 > nul 2>&1
DEL *.FNT > nul 2>&1
DEL *.SCR > nul 2>&1

REM  --- CUSTOM AREA ---
:CUSTOM
IF exist CUSTOM3.BAT CALL CUSTOM3.BAT
