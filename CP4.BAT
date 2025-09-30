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

SET INTERPRETER=dcp4isf.prg
IF "%LANG%" == "EN" SET INTERPRETER=dcp4ief.prg

REM --- EL NOMBRE DEL INTERPRETER EN EL DISCO ---
SET INTERPRETER_FINAL=sdiplus4
IF "%LANG%" == "EN" SET INTERPRETER_FINAL=ediplus4


IF NOT exist %GAME%.DSF COPY ASSETS\TEMPLATES\BLANK_%LANG%.DSF %GAME%.DSF


REM ---- OBTENER RECURSOS ---- 
tools\cecho\cecho {06}Copying required files...{07}
echo.
COPY TOOLS\MALUVA\*.BIN > nul 2>&1
COPY ASSETS\CP4\CP4_%BASELANG%.D64 %GAME%.D64 > nul 2>&1
COPY ASSETS\CP4\%INTERPRETER% %INTERPRETER% > nul 2>&1
tools\cecho\cecho {02}[OK]{07}


ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
TOOLS\DRC\DRF cp4 %GAME%.DSF
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Backend]{07}
ECHO.
PHP\PHP TOOLS\DRC\DRB.PHP cp4 %LANG% %GAME%.json %GAME%.DDB -ch
IF ERRORLEVEL 1 GOTO ERROR
MOVE %GAME%.DDB DAAD.DDB > nul 2>&1
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.

REM  ---- PREPARAR LAS IM GENES ----
tools\cecho\cecho {06}Preparing images (if any){07}
ECHO.
CD IMAGES
for /L %%i in (0, 1, 9) do IF exist 00%%i.PRG ..\TOOLS\MALUVA\SC2DAAD cp4 00%%i.PRG 00%%i4 %IMGLINES%
for /L %%i in (10, 1, 99) do IF exist 0%%i.PRG  ..\TOOLS\MALUVA\SC2DAAD cp4 0%%i.PRG 0%%i4 %IMGLINES%
for /L %%i in (100, 1, 255) do IF exist %%i.PRG  ..\TOOLS\MALUVA\SC2DAAD cp4 %%i.PRG %%i4 %IMGLINES% 
CD ..
tools\cecho\cecho {02}[OK]{07}
ECHO.


tools\cecho\cecho {06}Preparing release files{07}
ECHO.
REM  ---- PREPARE THE FONT -----
COPY ASSETS\CP4\apart1.prg > nul 2>&1
TOOLS\DD\DD count=37 bs=1 if=apart1.prg of=apart1.HEAD  > nul 2>&1
TOOLS\DD\DD skip=2085 count=36 bs=1 if=apart1.prg of=apart1.TAIL  > nul 2>&1
COPY /B apart1.HEAD + ASSETS\CHARSET\%FONTB% + apart1.TAIL APART1.TMP > nul 2>&1
DEL apart1.HEAD > nul 2>&1
DEL apart1.TAIL > nul 2>&1
DEL apart1.prg > nul 2>&1


REM  ---- COPIAR FICHEROS AL DISCO ---- 
tools\c1541\c1541.exe -attach %GAME%.D64 -write APART1.TMP apart1 > nul 2>&1
tools\c1541\c1541.exe -attach %GAME%.D64 -write DAAD.DDB bpart1 > nul 2>&1
tools\c1541\c1541.exe -attach %GAME%.D64 -write %INTERPRETER% %INTERPRETER_FINAL%  > nul 2>&1
for /L %%i in (0, 1, 9) do IF exist IMAGES\00%%i4 tools\c1541\c1541.exe -attach %GAME%.D64 -write IMAGES\00%%i4 00%%i4 > nul 2>&1
for /L %%i in (10, 1, 99) do IF exist IMAGES\0%%i4 tools\c1541\c1541.exe -attach %GAME%.D64 -write IMAGES\0%%i4 0%%i4 > nul 2>&1
for /L %%i in (100, 1, 256) do IF exist IMAGES\%%i4  tools\c1541\c1541.exe -attach %GAME%.D64 -write IMAGES\0%%i4 0%%i4 > nul 2>&1
for /L %%i in (0, 1, 9) do IF exist 0%%i.XMB tools\c1541\c1541.exe -attach %GAME%.D64 -write 0%%i.XMB 0%%i > nul 2>&1
for /L %%i in (10, 1, 32) do IF exist %%i.XMB tools\c1541\c1541.exe -attach %GAME%.D64 -write %%i.XMB 0%%i > nul 2>&1
tools\cecho\cecho {02}[OK]{07}
ECHO.

IF exist CUSTOM1.BAT CALL CUSTOM1.BAT
REM ----  CLEANING---- 
DEL DAAD.DDB > nul 2>&1
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
DEL *.TMP > nul 2>&1
DEL IMAGES\*4.> nul 2>&1
DEL *.PRG > nul 2>&1

IF exist CUSTOM2.BAT CALL CUSTOM2.BAT
IF ERRORLEVEL  1 GOTO CUSTOM

REM ---- TESTER ---- 
ECHO.
MOVE %GAME%.D64 RELEASE\CPLUS4 > nul 2>&1
tools\cecho\cecho {03}
ECHO "Game ready,press any key to test or  CTRL+C to stop"
IF "%BASELANG%" == "EN" (
echo "--------------------------------------------------------------------"
echo "| The emulator will try to load the game inmediatly, but that is   |"
echo "| incorrect, so as the emulator starts please press F11 (reset).   |"
echo "| Once in the prompt type LOAD "*",8 [intro] and then type RUN     |"
echo "| Alt+W (warp) boost loading speed, but press it again once it's   |"
echo "| loaded or it would be difficult to play                          |"
echo "--------------------------------------------------------------------"
)

IF "%BASELANG%" == "ES" (
ECHO "Juego preparado, pulsa una tecla para probar, o Ctrl+C para parar."
echo "--------------------------------------------------------------------"
echo "| Teclea    LOAD "*",8  para cargar el juego, y despues RUN        |"
echo "| En Plus4Yape '*' esta en la tecla de la cedilla               <- |"
echo "| La emulacion de disquetera es lenta, tardara en cargar, se puede |"
echo "| acelerar bastante pulsando Alt+W (warp) pero aun sera lenta.     |"
echo "| El emulador tiene la mania de arrancar el disco en un modo       |"
echo "| incorrecto, por lo que nada mas arrancar, pulsad F11 (reset)     |"
echo "| y despues ya teclead el LOAD.                                    |"
echo "--------------------------------------------------------------------"
)
tools\cecho\cecho {07}
PAUSE
TOOLS\Plus4Yape\YAPE RELEASE\CPLUS4\%GAME%.D64 
GOTO FIN

:ERROR
tools\cecho\cecho {04}
ECHO "Compile error, please check"
tools\cecho\cecho {07}
PAUSE
:FIN

REM ----  CLEANING---- 
DEL IMAGES\*4.> nul 2>&1
DEL DAAD.DDB > nul 2>&1
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
DEL *.TMP > nul 2>&1
DEL *.PRG > nul 2>&1

REM  --- CUSTOM AREA ---
:CUSTOM
IF exist CUSTOM3.BAT CALL CUSTOM3.BAT 