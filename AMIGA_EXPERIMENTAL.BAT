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


REM ---- FIRST TIME WARNING ----
IF NOT EXIST "ASSETS\AGA.warning" (
    if "%BASELANG%" == "ES" (
        tools\cecho\cecho {06}AVISO: ESTA BAT GENERA UNA DISTRIBUCI{\u00D3}N PARA AMIGA UTILIZANDO EL NUEVO INT{\u00C9}RPRETE ADP. {07}{\n}
        tools\cecho\cecho {06}ADP est{\u00E1} en una etapa inicial de pruebas, y aunque en general ha sido ya probado, podr{\u00ED}an aparecer problemas o incompatibilidades inesperadas. {07}{\n}{\n}
        tools\cecho\cecho {06}Por favor, antes de reportar un error comprueba que el comportamiento es diferente a otros targets.{07}{\n}
        echo.
        PAUSE
        echo "OK" > ASSETS\AGA.warning
    )
    if "%BASELANG%" == "EN" (
        tools\cecho\cecho {06}WARNING: THIS BAT GENERATES A DISTRIBUTION FOR AMIGA USING NEW ADP INTERPRETER{07}{\n}
        tools\cecho\cecho {06}ADP is in early stages of development, and although it has been tested quite a lot, unexpected problems or incompatibilities could appear. {07}{\n\n}
        tools\cecho\cecho {06}Before reporting a bug, please check that the behaviour is different to other targets.{07}{\n}
        PAUSE
        echo "OK" > ASSETS\AGA.warning
    )
)

REM ----  CHECK IF AMIGAMODE IS SET ---- 
IF  NOT DEFINED AMIGAMODE (
    setlocal EnableDelayedExpansion
    SET AMIGACHOICE=1
        if "%BASELANG%" == "EN" (
            ECHO.
            tools\cecho\cecho {06}This version supports multiple Amiga graphic modes{#}{\n}
            echo.
            tools\cecho\cecho {06}OCS/ECS{#}  32-color graphics, compatible with all Amigas{\n}
            echo.
            tools\cecho\cecho {06}HAM6{#}     Up to 4096 color graphics, compatible with all Amigas.{\n}
            tools\cecho\cecho {\t} This mode can introduce some artifacts. Please{\n}
            tools\cecho\cecho {\t} refer to the manual if you want to use multiple windows.{\n}
            echo.
            tools\cecho\cecho {06}AGA{#}      256-color graphics, but require an Amiga with AGA{\n}
            tools\cecho\cecho {\t} and one megabyte of Chip RAM ^(Amiga 1200+^).{\n}
            ECHO.
            CHOICE /C EOHA /N /M "--- Please select ^(E^)CS/OCS, ^(H^)AM6 or ^(A^)GA mode ---"
            SET AMIGACHOICE=!ERRORLEVEL!
            ECHO.
            tools\cecho\cecho Edit {06}CONFIG.BAT{#} to change the mode in the future{\n}
        )
        if "%BASELANG%" == "ES" (
            ECHO.
            tools\cecho\cecho {06}Esta versi{\u00F3}n soporta los siguientes modos gr{\u00E1}ficos de Amiga:{#}{\n}
            echo.
            tools\cecho\cecho {06}OCS/ECS{#}  gr{\u00E1}ficos de 32 colores, compatible con todos los Amigas{\n}
            echo.
            tools\cecho\cecho {06}HAM6{#}     gr{\u00E1}ficos de hasta 4096 colores, compatible con todos los Amigas.{\n}
            tools\cecho\cecho {\t} Este modo puede introducir algunos artefactos. Por favor,{\n}
            tools\cecho\cecho {\t} consulta el manual antes de usar m{\u00FA}ltiples ventanas.{\n}
            echo.
            tools\cecho\cecho {06}AGA{#}      gr{\u00E1}ficos de 256 colores, pero requiere un Amiga con AGA{\n}
            tools\cecho\cecho {\t} y un megabyte de Chip RAM ^(Amiga 1200+^).{\n}
            ECHO.
            CHOICE /C EOHA /N /M "--- Selecciona (E)CS/OCS, (H)AM6 o (A)GA ---"
            SET AMIGACHOICE=!ERRORLEVEL!
            ECHO.
            tools\cecho\cecho Edita {06}CONFIG.BAT{#} para cambiar el modo en el futuro{\n}
        )

        SET AMIGAMODE=OCS
        IF "!AMIGACHOICE!" == "3" SET AMIGAMODE=HAM
        IF "!AMIGACHOICE!" == "4" SET AMIGAMODE=AGA
        ECHO SET AMIGAMODE=!AMIGAMODE! >> CONFIG.BAT
        echo.
)

echo AMIGAMODE: %AMIGAMODE%
SET "AMIGAMODE=%AMIGAMODE: =%"
if /I "%AMIGAMODE%" == "OCS" (
    SET KICKSTART=kick13.rom
    SET KICKSTARTVER=1.3
    SET UAECONFIG=DAAD-EXPERIMENTAL.UAE
    SET DATMODE=planar5
    SET INTROCMD=TOOLS\ADP\png2amiga.exe --mode lores --depth 5 --chipset ocs
    SET IMAGEPATH=IMAGES\EXPERIMENTAL\32
    SET EXTRAS=
)
if /I "%AMIGAMODE%" == "HAM" (
    SET DATMODE=ham6
    SET KICKSTART=kick13.rom
    SET KICKSTARTVER=1.3
    SET UAECONFIG=DAAD-EXPERIMENTAL.UAE
    SET INTROCMD=TOOLS\ADP\png2amiga.exe --mode ham6
    SET IMAGEPATH=IMAGES\EXPERIMENTAL\TRUECOLOR
    SET EXTRAS=
)
if /I "%AMIGAMODE%" == "AGA" (
    SET DATMODE=planar8
    SET INTROCMD=TOOLS\ADP\png2amiga.exe --mode lores --depth 8 --chipset aga
    SET IMAGEPATH=IMAGES\EXPERIMENTAL\256
    SET EXTRAS=-remap=16-255
    SET KICKSTART=kick31.rom
    SET KICKSTARTVER=3.1
    SET UAECONFIG=DAAD-AGA-EXPERIMENTAL.UAE
)
IF /I "%KICKSTART%" == "" (
    ECHO Amiga mode not set
    GOTO ERROR
)

IF NOT exist %GAME%.DSF COPY ASSETS\TEMPLATES\BLANK_%LANG%.DSF %GAME%.DSF

MKDIR RELEASE\AMIGA_EXPERIMENTAL > NUL 2>&1

REM ---- OBTENER RECURSOS ---- 
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
SET INTERPRETER=ASSETS\AMIGA_EXPERIMENTAL\ADP.EXE
COPY %INTERPRETER% RELEASE\AMIGA_EXPERIMENTAL\%GAME%
IF exist ASSETS\CHARSET\%FONTPCDAAD% (
    COPY /Y ASSETS\CHARSET\%FONTPCDAAD% RELEASE\AMIGA_EXPERIMENTAL\PART1.FNT > nul 2>&1
) ELSE (
    COPY ASSETS\CHARSET\%FONT6% RELEASE\AMIGA_EXPERIMENTAL\PART1.TMP > nul 2>&1
    TOOlS\SPECFORM\SPECFORM -a 16384 RELEASE\AMIGA_EXPERIMENTAL\PART1.TMP > nul 2>&1
    MOVE RELEASE\AMIGA_EXPERIMENTAL\PART1.TMP.zxb RELEASE\AMIGA_EXPERIMENTAL\PART1.CHR > nul 2>&1
    DEL RELEASE\AMIGA_EXPERIMENTAL\PART1.TMP > nul 2>&1
)

tools\cecho\cecho {02}[OK]{07}
ECHO.


tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Frontend]{07}
echo.
TOOLS\DRC\DRF amiga %GAME%.DSF -v3
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Backend]{07}
echo.
PHP\PHP TOOLS\DRC\DRB.PHP amiga %LANG% %GAME%.json %GAME%.DDB
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.

REM  ---- PREPARE IMAGES ----
if "%AMIGAMODE%" == "HAM" (
    IF EXIST %IMAGEPATH%\*.PNG (
        tools\cecho\cecho {06}Compiling HAM6 images{07}
        FOR %%F IN (%IMAGEPATH%\*.PNG) DO (
            PHP\PHP TOOLS\ADP\png2amiga.php "%%~fF" "%%~dpnF.IFF"
            IF ERRORLEVEL 1 GOTO ERROR
        )
    )
)

tools\cecho\cecho {06}Creating graphics file{07}
ECHO.
echo TOOLS\ADP\DMG create RELEASE\AMIGA_EXPERIMENTAL\PART1.DAT %IMAGEPATH%;SOUNDS -format=dat5 -mode=%DATMODE% -height=%IMGLINES% %EXTRAS%
TOOLS\ADP\DMG create RELEASE\AMIGA_EXPERIMENTAL\PART1.DAT %IMAGEPATH%;SOUNDS -format=dat5 -mode=%DATMODE% -height=%IMGLINES% %EXTRAS%
IF exist %IMAGEPATH%\DAAD.PNG (
    echo "Amiga special: converting DAAD.PNG to ILBM PART1.SCR"
    %INTROCMD% %IMAGEPATH%\DAAD.PNG -o RELEASE\AMIGA_EXPERIMENTAL\PART1.SCR.iff
    IF EXIST RELEASE\AMIGA_EXPERIMENTAL\PART1.SCR DEL RELEASE\AMIGA_EXPERIMENTAL\PART1.SCR > nul 2>&1
    MOVE /Y RELEASE\AMIGA_EXPERIMENTAL\PART1.SCR.iff RELEASE\AMIGA_EXPERIMENTAL\PART1.SCR > nul 2>&1
    IF ERRORLEVEL 1 GOTO ERROR
)

IF ERRORLEVEL 1 GOTO ERROR

REM --- PREPARE AMIGA STARTUP-SEQUENCE
tools\cecho\cecho {06}Preparing startup sequence{07}
ECHO.
mkdir RELEASE\AMIGA_EXPERIMENTAL\s > nul 2>&1
DEL /Q RELEASE\AMIGA_EXPERIMENTAL\s\startup-sequence > nul 2>&1
echo %GAME% > RELEASE\AMIGA_EXPERIMENTAL\s\startup-sequence

tools\cecho\cecho {06}Preparing release files{07}
ECHO.
MOVE %GAME%.DDB RELEASE\AMIGA_EXPERIMENTAL\PART1.DDB > nul 2>&1
ECHO.

tools\cecho\cecho {06}Preparing .ADF floppy disk image file{07}
echo.
DEL RELEASE\AMIGA_EXPERIMENTAL\FLOPPY\%GAME%.ADF > nul 2>&1
RMDIR /S /Q RELEASE\AMIGA_EXPERIMENTAL\FLOPPY > nul 2>&1
DEL %GAME%.ADF > nul 2>&1
TOOLS\ADP\dsk.exe create -b -r %GAME%.ADF RELEASE\AMIGA_EXPERIMENTAL
IF ERRORLEVEL 1 GOTO ERROR
MD RELEASE\AMIGA_EXPERIMENTAL\FLOPPY\ > nul 2>&1
MOVE %GAME%.ADF RELEASE\AMIGA_EXPERIMENTAL\FLOPPY\%GAME%.ADF > nul 2>&1

IF exist CUSTOM1.BAT CALL CUSTOM1.BAT
REM ----  CLEAN ---- 
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
DEL *.CHR > nul 2>&1

IF exist CUSTOM2.BAT CALL CUSTOM2.BAT
IF ERRORLEVEL  1 GOTO CUSTOM
REM ---- TESTER ---- 
CD TOOLS\WINUAE
IF NOT EXIST %KICKSTART% (
        ..\..\tools\cecho\cecho {04}
        IF "%BASELANG%" == "EN" (
            ..\..\tools\cecho\cecho IMPORTANT: In order to test Amiga games, you have to add the file %KICKSTART% to the TOOLS\WINUAE folder.
            echo.
            ..\..\tools\cecho\cecho That is the Kickstater ROM %KICKSTARTVER%. Once added run this BAT again
        )
        IF "%BASELANG%" == "ES" (
            ..\..\tools\cecho\cecho IMPORTANTE: Para poder probar los juegos de Amiga, tienes que poner el fichero %KICKSTART% en la carpeta TOOLS\WINUAE.
            echo.
            ..\..\tools\cecho\cecho Es la ROM de Kickstarter %KICKSTARTVER%. Una vez incluido el fichero de la ROM vuelve a ejecutar este BAT
        )
        ..\..\tools\cecho\cecho {07}
        echo .
        PAUSE
        EXIT
)
CD ..\..

ECHO.
tools\cecho\cecho {03}
IF "%BASELANG%" == "EN" (
tools\cecho\cecho {04}IMPORTANT NOTICE:{07} this target is in early stages of development, and may contain bugs and glitches.{\n}
tools\cecho\cecho Please report any errors to the author.{\n}{\n}
tools\cecho\cecho To change the mode in the future, edit CONFIG.BAT:{\n}
tools\cecho\cecho  - SET AMIGAMODE=OCS for 32-color OCS/ECS mode{\n}
tools\cecho\cecho  - SET AMIGAMODE=HAM for HAM6 mode{\n}
tools\cecho\cecho  - SET AMIGAMODE=AGA for 256-color AGA mode{\n}{\n}
tools\cecho\cecho THE GAME HAS BEEN COMPILED SUCCESSFULLY. PRESS ENTER TO START THE EMULATOR, OR CTRL+C TO STOP.{\n}
tools\cecho\cecho The game will be executed from RELEASE\AMIGA_EXPERIMENTAL.{\n}
tools\cecho\cecho The generated experimental .ADF remains in RELEASE\AMIGA_EXPERIMENTAL\FLOPPY.{\n}{\n}
)
IF "%BASELANG%" == "ES" (
tools\cecho\cecho {04}AVISO IMPORTANTE:{07} este target est{\u00E1} en fase de desarrollo, puede contener errores y fallos.{\n}
tools\cecho\cecho Por favor, reporte cualquier error al autor.{\n}{\n}
tools\cecho\cecho Para cambiar de modo en el futuro, cambia CONFIG.BAT:{\n}
tools\cecho\cecho  - SET AMIGAMODE=OCS para generar el modo OCS/ECS de 32 colores{\n}
tools\cecho\cecho  - SET AMIGAMODE=HAM para generar el modo HAM6{\n}
tools\cecho\cecho  - SET AMIGAMODE=AGA para generar el modo AGA de 256 colores{\n}{\n}
tools\cecho\cecho EL JUEGO SE HA COMPILADO CORRECTAMENTE, PULSE ENTER PARA INICIAR EL EMULADOR, O CTRL+C PARA PARAR.{\n}
tools\cecho\cecho El juego se ejecutar{\u00E1} desde RELEASE\AMIGA_EXPERIMENTAL.{\n}
tools\cecho\cecho El .ADF experimental generado seguir{\u00E1} en RELEASE\AMIGA_EXPERIMENTAL\FLOPPY.{\n}{\n}
)
tools\cecho\cecho {07}
PAUSE
CD TOOLS\WINUAE
WINUAE -config=%UAECONFIG% -G
cd ..\..

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

REM  --- CUSTOM AREA ---
:CUSTOM
IF exist CUSTOM3.BAT CALL CUSTOM3.BAT 
