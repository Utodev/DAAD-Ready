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
IF NOT EXIST "ASSETS\ATARIST.warning" (
    if "%BASELANG%" == "ES" (
        tools\cecho\cecho "{06}AVISO: ESTA BAT GENERA UNA DISTRIBUCI{\u00D3}N PARA ATARI ST UTILIZANDO EL NUEVO INT{\u00C9}RPRETE ADP. {07}"
        tools\cecho\cecho "{06}ADP est{\u00E1} en una etapa inicial de pruebas, y aunque en general ha sido ya probado, podr{\u00ED}an aparecer problemas o incompatibilidades inesperadas. {07}"
        tools\cecho\cecho "{06}Por favor, antes de reportar un error comprueba que el comportamiento es diferente a otros targets.{07}"
        echo.
        PAUSE
        echo "OK" > ASSETS\ATARIST.warning
    )
    if "%BASELANG%" == "EN" (
        tools\cecho\cecho "{06}WARNING: THIS BAT GENERATES A DISTRIBUTION FOR ATARI ST USING NEW ADP INTERPRETER{07}"
        tools\cecho\cecho "{06}ADP is in early stages of development, and although it has been tested quite a lot, unexpected problems or incompatibilities could appear. {07}"
        echo.
        tools\cecho\cecho "{06}Before reporting a bug, please check that the behaviour is different to other targets.{07}"
        PAUSE
        echo "OK" > ASSETS\ATARIST.warning
    )
)

REM ---- CHECK IF ATARIMODE IS SET ----
IF NOT DEFINED ATARIMODE (
        setlocal EnableDelayedExpansion
        SET ATARICHOICE=1
        if "%BASELANG%" == "EN" (
            ECHO.
            tools\cecho\cecho {06}This version supports three Atari display modes{#}{\n}
            echo.
            tools\cecho\cecho {06}ST{#}      16-color graphics for regular Atari ST machines{\n}
            tools\cecho\cecho {\t} This mode is limited to the original 512-color Atari palette,{\n}
            tools\cecho\cecho {\t} so the results may not look very good.{\n}
            echo.
            tools\cecho\cecho {06}STE{#}     same 16-color assets as ST, tested in Atari STE mode{\n}
            echo.
            tools\cecho\cecho {06}FALCON{#}  256-color graphics for Atari Falcon machines{\n}
            ECHO.
            CHOICE /C SEF /N /M "--- Please select (S)T, ST(E) or (F)ALCON mode ---"
            SET ATARICHOICE=!ERRORLEVEL!
            ECHO.
            tools\cecho\cecho Edit {06}CONFIG.BAT{#} to change the mode in the future{\n}
        )
        if "%BASELANG%" == "ES" (
            ECHO.
            tools\cecho\cecho {06}Esta versi{\u00F3}n soporta tres modos de pantalla para Atari{#}{\n}
            echo.
            tools\cecho\cecho {06}ST{#}      gr{\u00E1}ficos de 16 colores para Atari ST normales{\n}
            tools\cecho\cecho {\t} Este modo est{\u00E1} limitado a la paleta Atari original de 512 colores,{\n}
            tools\cecho\cecho {\t} as{\u00ED} que el resultado puede no verse demasiado bien.{\n}
            echo.
            tools\cecho\cecho {06}STE{#}     ejecuta el mismo juego en modo Atari STE{\n}
            echo.
            tools\cecho\cecho {06}FALCON{#}  gr{\u00E1}ficos de 256 colores para Atari Falcon{\n}
            ECHO.
            CHOICE /C SEF /N /M "--- Selecciona modo (S)T, ST(E) o (F)ALCON ---"
            SET ATARICHOICE=!ERRORLEVEL!
            ECHO.
            tools\cecho\cecho Edita {06}CONFIG.BAT{#} para cambiar el modo en el futuro{\n}
        )

        SET ATARIMODE=ST
        IF "!ATARICHOICE!" == "2" SET ATARIMODE=STE
        IF "!ATARICHOICE!" == "3" SET ATARIMODE=FALCON
        ECHO SET ATARIMODE=!ATARIMODE! >> CONFIG.BAT
        echo.
)

echo ATARIMODE: %ATARIMODE%
SET "ATARIMODE=%ATARIMODE: =%"
IF /I "%ATARIMODE%" == "ST" (
    SET IMAGEPATH=IMAGES\EXPERIMENTAL\16
    SET INTROPATH=IMAGES\EXPERIMENTAL\16
    SET DATMODE=planar4st
    SET EXTRAS=-remap=std
    SET HATARIMACHINE=st
)
IF /I "%ATARIMODE%" == "STE" (
    SET IMAGEPATH=IMAGES\EXPERIMENTAL\16
    SET INTROPATH=IMAGES\EXPERIMENTAL\16
    SET DATMODE=planar4st
    SET EXTRAS=-remap=std
    SET HATARIMACHINE=ste
)
IF /I "%ATARIMODE%" == "FALCON" (
    SET IMAGEPATH=IMAGES\EXPERIMENTAL\256
    SET INTROPATH=IMAGES\EXPERIMENTAL\256
    SET DATMODE=planar8st
    SET EXTRAS=-remap=16-255
    SET HATARIMACHINE=falcon
)
IF /I "%DATMODE%" == "" (
    ECHO Atari mode not set
    GOTO ERROR
)

IF NOT exist %GAME%.DSF COPY ASSETS\TEMPLATES\BLANK_%LANG%.DSF %GAME%.DSF

MKDIR RELEASE\ATARIST_EXPERIMENTAL > NUL 2>&1
DEL /Q RELEASE\ATARIST_EXPERIMENTAL\*.DDB > nul 2>&1
DEL /Q RELEASE\ATARIST_EXPERIMENTAL\*.DAT > nul 2>&1
DEL /Q RELEASE\ATARIST_EXPERIMENTAL\*.CH0 > nul 2>&1
DEL /Q RELEASE\ATARIST_EXPERIMENTAL\*.CHR > nul 2>&1
DEL /Q RELEASE\ATARIST_EXPERIMENTAL\*.FNT > nul 2>&1
DEL /Q RELEASE\ATARIST_EXPERIMENTAL\*.SCR > nul 2>&1
DEL /Q RELEASE\ATARIST_EXPERIMENTAL\*.PRG > nul 2>&1

REM ---- OBTENER RECURSOS ----
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
SET INTERPRETER=ASSETS\ATARIST_EXPERIMENTAL\adp.prg
COPY %INTERPRETER% RELEASE\ATARIST_EXPERIMENTAL\%GAME%.PRG > nul 2>&1
IF exist ASSETS\CHARSET\%FONTPCDAAD% (
    COPY /Y ASSETS\CHARSET\%FONTPCDAAD% RELEASE\ATARIST_EXPERIMENTAL\PART1.FNT > nul 2>&1
) ELSE (
    COPY ASSETS\CHARSET\%FONT6% RELEASE\ATARIST_EXPERIMENTAL\PART1.TMP > nul 2>&1
    TOOlS\SPECFORM\SPECFORM -a 16384 RELEASE\ATARIST_EXPERIMENTAL\PART1.TMP > nul 2>&1
    MOVE RELEASE\ATARIST_EXPERIMENTAL\PART1.TMP.zxb RELEASE\ATARIST_EXPERIMENTAL\PART1.CH0 > nul 2>&1
    DEL RELEASE\ATARIST_EXPERIMENTAL\PART1.TMP > nul 2>&1
)

tools\cecho\cecho {02}[OK]{07}
ECHO.

tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Frontend]{07}
echo.
TOOLS\DRC\DRF st %GAME%.DSF -v3
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

REM ---- PREPARE IMAGES ----
tools\cecho\cecho {06}Preparing images{07}
echo.
IF /I "%ATARIMODE%" == "FALCON" (
    ECHO Creating Atari Falcon GAME
) ELSE IF /I "%ATARIMODE%" == "STE" (
    ECHO Creating Atari STE GAME
) ELSE (
    ECHO Creating Atari ST GAME
)

TOOLS\ADP\DMG create RELEASE\ATARIST_EXPERIMENTAL\PART1.DAT %IMAGEPATH%;SOUNDS\EXPERIMENTAL -format=dat5 -mode=%DATMODE% -height=%IMGLINES% -audio-8bit %EXTRAS%
IF ERRORLEVEL 1 GOTO ERROR

IF /I "%ATARIMODE%" == "FALCON" (
    IF exist %INTROPATH%\DAAD.PNG (
        PHP\PHP TOOLS\ADP\png2falcon.php %INTROPATH%\DAAD.PNG RELEASE\ATARIST_EXPERIMENTAL\PART1.SCR
        IF ERRORLEVEL 1 GOTO ERROR
    )

    IF not exist RELEASE\ATARIST_EXPERIMENTAL\PART1.SCR IF exist %INTROPATH%\DAAD.SCR (
        COPY /Y %INTROPATH%\DAAD.SCR RELEASE\ATARIST_EXPERIMENTAL\PART1.SCR > nul 2>&1
    )
) ELSE (
    IF exist %INTROPATH%\DAAD.PNG (
        PHP\PHP TOOLS\IMG2DAAD\PNG2DEGAS.PHP %INTROPATH%\DAAD.PNG RELEASE\ATARIST_EXPERIMENTAL\PART1.SCR
        IF ERRORLEVEL 1 GOTO ERROR
    )

    IF not exist RELEASE\ATARIST_EXPERIMENTAL\PART1.SCR IF exist %INTROPATH%\DAAD.PI1 (
        COPY /Y %INTROPATH%\DAAD.PI1 RELEASE\ATARIST_EXPERIMENTAL\PART1.SCR > nul 2>&1
    )
)

tools\cecho\cecho {06}Preparing release files{07}
ECHO.
MOVE %GAME%.DDB RELEASE\ATARIST_EXPERIMENTAL\PART1.DDB > nul 2>&1
IF exist 0.XMB MOVE 0.XMB RELEASE\ATARIST_EXPERIMENTAL\PART1.XMB > nul 2>&1
ECHO.

tools\cecho\cecho {06}Preparing .ST floppy disk image file{07}
echo.
RMDIR /S /Q RELEASE\ATARIST_EXPERIMENTAL\FLOPPY > nul 2>&1
DEL /Q RELEASE\ATARIST_EXPERIMENTAL\FLOPPY\%GAME%.ST > nul 2>&1
DEL %GAME%.ST > nul 2>&1
TOOLS\ADP\dsk.exe create -d %GAME%.ST RELEASE\ATARIST_EXPERIMENTAL
IF ERRORLEVEL 1 GOTO ERROR
MD RELEASE\ATARIST_EXPERIMENTAL\FLOPPY > nul 2>&1
MOVE %GAME%.ST RELEASE\ATARIST_EXPERIMENTAL\FLOPPY\%GAME%.ST > nul 2>&1

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
tools\cecho\cecho  - SET ATARIMODE=ST for regular Atari ST mode{\n}
tools\cecho\cecho  - SET ATARIMODE=STE for Atari STE mode{\n}
tools\cecho\cecho  - SET ATARIMODE=FALCON for Atari Falcon mode{\n}{\n}
tools\cecho\cecho THE GAME HAS BEEN COMPILED SUCCESSFULLY. PRESS ENTER TO START THE EMULATOR, OR CTRL+C TO STOP.{\n}
tools\cecho\cecho The game will be executed from RELEASE\ATARIST_EXPERIMENTAL.{\n}
tools\cecho\cecho The generated experimental .ST remains in RELEASE\ATARIST_EXPERIMENTAL\FLOPPY.{\n}{\n}
)
IF "%BASELANG%" == "ES" (
tools\cecho\cecho {04}AVISO IMPORTANTE:{07} este target est{\u00E1} en fase de desarrollo, puede contener errores y fallos.{\n}
tools\cecho\cecho Por favor, reporte cualquier error al autor.{\n}{\n}
tools\cecho\cecho Para cambiar de modo en el futuro, cambia CONFIG.BAT:{\n}
tools\cecho\cecho  - SET ATARIMODE=ST para generar el modo Atari ST normal{\n}
tools\cecho\cecho  - SET ATARIMODE=STE para generar el modo Atari STE{\n}
tools\cecho\cecho  - SET ATARIMODE=FALCON para generar el modo Atari Falcon{\n}{\n}
tools\cecho\cecho EL JUEGO SE HA COMPILADO CORRECTAMENTE, PULSE ENTER PARA INICIAR EL EMULADOR, O CTRL+C PARA PARAR.{\n}
tools\cecho\cecho El juego se ejecutar{\u00E1} desde RELEASE\ATARIST_EXPERIMENTAL.{\n}
tools\cecho\cecho El .ST experimental generado seguir{\u00E1} en RELEASE\ATARIST_EXPERIMENTAL\FLOPPY.{\n}{\n}
)
tools\cecho\cecho {07}
PAUSE
CD TOOLS\HATARI
HATARI --memsize 1 --machine %HATARIMACHINE% --harddrive ..\..\RELEASE\ATARIST_EXPERIMENTAL --confirm-quit 0 --auto C:\%GAME%.PRG --fast-boot 1
CD ..\..

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

REM --- CUSTOM AREA ---
:CUSTOM
IF exist CUSTOM3.BAT CALL CUSTOM3.BAT