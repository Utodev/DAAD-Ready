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
IF NOT EXIST "ASSETS\LINUX.warning" (
    if "%BASELANG%" == "ES" (
        tools\cecho\cecho {06}AVISO: ESTA BAT PREPARA UNA DISTRIBUCION PARA LINUX UTILIZANDO EL NUEVO INTERPRETE ADP. {07}
        tools\cecho\cecho {06}ADP esta en una etapa inicial de pruebas, y aunque en general ha sido ya probado, podrian aparecer problemas o incompatibilidades inesperadas. {07}
        tools\cecho\cecho {06}Por favor, antes de reportar un error comprueba que el comportamiento es diferente a otros targets.{07}
        echo.
        PAUSE
        echo "OK" > ASSETS\LINUX.warning
    )
    if "%BASELANG%" == "EN" (
        tools\cecho\cecho "{06}WARNING: THIS BAT PREPARES A DISTRIBUTION FOR LINUX USING THE NEW ADP INTERPRETER{07}"
        tools\cecho\cecho "{06}ADP is in early stages of development, and although it has been tested quite a lot, unexpected problems or incompatibilities could appear. {07}"
        echo.
        tools\cecho\cecho "{06}Before reporting a bug, please check that the behaviour is different to other targets.{07}"
        PAUSE
        echo "OK" > ASSETS\LINUX.warning
    )
)

IF NOT exist %GAME%.DSF COPY ASSETS\TEMPLATES\BLANK_%LANG%.DSF %GAME%.DSF

SET LINUXROOT=RELEASE\LINUX_EXPERIMENTAL\%GAME%-linux
SET APPDIR=%LINUXROOT%\AppDir
SET GAMEDIR=%APPDIR%\usr\share\daad-ready\game
SET PLAYER=ASSETS\LINUX_EXPERIMENTAL\player

IF NOT EXIST "%PLAYER%" (
    tools\cecho\cecho {04}
    IF "%BASELANG%" == "EN" ECHO Missing Linux runtime: %PLAYER%
    IF "%BASELANG%" == "ES" ECHO Falta el ejecutable Linux: %PLAYER%
    tools\cecho\cecho {07}
    PAUSE
    GOTO FIN
)

MKDIR RELEASE\LINUX_EXPERIMENTAL > NUL 2>&1
RMDIR /S /Q "%LINUXROOT%" > nul 2>&1
MKDIR "%APPDIR%\usr\bin" > NUL 2>&1
MKDIR "%GAMEDIR%" > NUL 2>&1

DEL /Q "%GAMEDIR%\*.DDB" > nul 2>&1
DEL /Q "%GAMEDIR%\*.DAT" > nul 2>&1
DEL /Q "%GAMEDIR%\*.CHR" > nul 2>&1
DEL /Q "%GAMEDIR%\*.FNT" > nul 2>&1
DEL /Q "%GAMEDIR%\*.VGA" > nul 2>&1
DEL /Q "%GAMEDIR%\*.PCX" > nul 2>&1
DEL /Q "%GAMEDIR%\*.SCR" > nul 2>&1

REM ---- GET RUNTIME ----
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
COPY /Y "%PLAYER%" "%APPDIR%\usr\bin\ADP" > nul 2>&1

IF exist ASSETS\CHARSET\%FONTPCDAAD% COPY /Y ASSETS\CHARSET\%FONTPCDAAD% "%GAMEDIR%\%GAME%.FNT" > nul 2>&1
IF not exist ASSETS\CHARSET\%FONTPCDAAD% COPY /Y ASSETS\CHARSET\%FONT6% "%GAMEDIR%\%GAME%.CHR" > nul 2>&1

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

REM ---- PREPARE IMAGES ----
tools\cecho\cecho {06}Preparing images{07}
echo.
IF /I "%HIRES%"=="1" (
        SET IMGPATH=IMAGES\EXPERIMENTAL\HIRES
        SET IMGWIDTH=640
        SET IMGHEIGHT=192
        SET PARAMETER=-screen=640x400 -2x=1
        ECHO Creating HIRES 640x400 GAME
    ) ELSE (
        SET IMGPATH=IMAGES\EXPERIMENTAL\256
        SET IMGWIDTH=320
        SET IMGHEIGHT=96
        SET PARAMETER=
        ECHO Creating LORES 320x200 GAME
    )

IF exist %IMGPATH%\DAAD.PNG (
    PHP\PHP TOOLS\ADP\png2pcx.php %IMGPATH%\DAAD.PNG "%GAMEDIR%\%GAME%.PCX"
    IF ERRORLEVEL 1 GOTO ERROR
)

IF not exist "%GAMEDIR%\%GAME%.PCX" IF exist %IMGPATH%\DAAD.PCX (
    COPY /Y %IMGPATH%\DAAD.PCX "%GAMEDIR%\%GAME%.PCX" > nul 2>&1
)

TOOLS\ADP\DMG create "%GAMEDIR%\%GAME%.DAT" %IMGPATH%;SOUNDS\EXPERIMENTAL -format=dat5 -mode=planar8 -width=%IMGWIDTH% -height=%IMGHEIGHT% -remap=16-255 %PARAMETER%
IF ERRORLEVEL 1 GOTO ERROR

tools\cecho\cecho {06}Preparing release files{07}
ECHO.
MOVE %GAME%.DDB "%GAMEDIR%\%GAME%.DDB" > nul 2>&1
PHP\PHP TOOLS\ADP\package_linux_appdir.php RELEASE\LINUX_EXPERIMENTAL %GAME%
IF ERRORLEVEL 1 GOTO ERROR
ECHO.

IF exist CUSTOM1.BAT CALL CUSTOM1.BAT
REM ---- CLEAN ----
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
DEL *.CHR > nul 2>&1
DEL *.CH0 > nul 2>&1

IF exist CUSTOM2.BAT CALL CUSTOM2.BAT
IF ERRORLEVEL  1 GOTO CUSTOM

ECHO.
tools\cecho\cecho {03}
IF "%BASELANG%" == "EN" (
tools\cecho\cecho {04}IMPORTANT NOTICE:{07} this target is in early stages of development, and may contain bugs and glitches.{\n}
tools\cecho\cecho Please report any errors to the author.{\n}{\n}
tools\cecho\cecho To change the mode in the future, edit CONFIG.BAT:{\n}
tools\cecho\cecho  - SET HIRES=1 to build the 640x400 2X mode from IMAGES\EXPERIMENTAL\HIRES{\n}
tools\cecho\cecho  - SET HIRES=0 to build the 320x200 mode from IMAGES\EXPERIMENTAL\256{\n}{\n}
tools\cecho\cecho The game has been generated in RELEASE\LINUX_EXPERIMENTAL.{\n}
tools\cecho\cecho A Linux bundle has been generated as %GAME%-linux.tar.gz.{\n}
tools\cecho\cecho Extract that archive on Linux and run: bash BUILD_APPIMAGE_ON_LINUX.sh{\n}
tools\cecho\cecho The unpacked bundle also includes RUN_ON_LINUX.sh to test without creating the AppImage first.{\n}{\n}
)
IF "%BASELANG%" == "ES" (
tools\cecho\cecho {04}AVISO IMPORTANTE:{07} este target est{\u00E1} en fase de desarrollo, puede contener errores y fallos.{\n}
tools\cecho\cecho Por favor, reporte cualquier error al autor.{\n}{\n}
tools\cecho\cecho Para cambiar de modo en el futuro, cambia CONFIG.BAT:{\n}
tools\cecho\cecho  - SET HIRES=1 para generar el modo 640x400 2X usando IMAGES\EXPERIMENTAL\HIRES{\n}
tools\cecho\cecho  - SET HIRES=0 para generar el modo 320x200 usando IMAGES\EXPERIMENTAL\256{\n}{\n}
tools\cecho\cecho El juego se ha generado en RELEASE\LINUX_EXPERIMENTAL.{\n}
tools\cecho\cecho Tambi{\u00E9}n se ha generado el archivo %GAME%-linux.tar.gz para Linux.{\n}
tools\cecho\cecho Extrae ese archivo en Linux y ejecuta: bash BUILD_APPIMAGE_ON_LINUX.sh{\n}
tools\cecho\cecho El paquete tambi{\u00E9}n incluye RUN_ON_LINUX.sh para probarlo sin crear antes el AppImage.{\n}{\n}
)
tools\cecho\cecho {07}
PAUSE
GOTO FIN

:ERROR
tools\cecho\cecho {04}
ECHO Compile error, please check
tools\cecho\cecho {07}
PAUSE
:FIN

REM ---- CLEAN ----
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
DEL *.CHR > nul 2>&1
DEL *.CH0 > nul 2>&1
DEL *.FNT > nul 2>&1
DEL *.SCR > nul 2>&1

REM --- CUSTOM AREA ---
:CUSTOM
IF exist CUSTOM3.BAT CALL CUSTOM3.BAT
