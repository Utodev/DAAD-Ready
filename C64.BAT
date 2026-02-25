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
        CHOICE /C ESGPF /N /M "--- Please select (E)nglish, (S)panish, (G)erman, French(F) or (P)ortuguese"
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


SET INTERPRETER=dc64isf.prg
IF "%LANG%" == "EN" SET INTERPRETER=dc64ief.prg

REM --- EL NOMBRE DEL INTERPRETE EN EL DISCO ---
SET INTERPRETER_FINAL=sdi
IF "%LANG%" == "EN" SET INTERPRETER_FINAL=edi

IF NOT exist %GAME%.DSF COPY ASSETS\TEMPLATES\BLANK_%LANG%.DSF %GAME%.DSF

REM ---- OBTENER RECURSOS ---- 
tools\cecho\cecho {06}Copying required files...{07}
COPY TOOLS\MALUVA\*.BIN > nul 2>&1
COPY ASSETS\C64\C64_%BASELANG%.D64 %GAME%.D64 > nul 2>&1
COPY ASSETS\C64\%INTERPRETER% %INTERPRETER% > nul 2>&1
tools\cecho\cecho {02}[OK]{07}


ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
TOOLS\DRC\DRF c64 %GAME%.DSF %SPLITSCR%
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Backend]{07}
ECHO.
PHP\PHP TOOLS\DRC\DRB.PHP c64 %LANG% %GAME%.json %GAME%.DDB -ch -s
IF ERRORLEVEL 1 GOTO ERROR
MOVE %GAME%.DDB DAAD.DDB > nul 2>&1
MOVE %GAME%.DDB DAAD.DDB > nul 2>&1
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.

REM  ---- PREPARE IMAGES ----
CD IMAGES
..\tools\cecho\cecho {06}Preparing images (if any){07}
ECHO.
if NOT "%SPLITSCR%" == "splitModeOn" (
echo Processing ART files
ECHO.
for /L %%i in (0, 1, 9) do IF exist 00%%i.ART ..\TOOLS\MALUVA\SC2DAAD c64 00%%i.ART 00%%i64 %IMGLINES%
for /L %%i in (10, 1, 99) do IF exist 0%%i.ART  ..\TOOLS\MALUVA\SC2DAAD c64 0%%i.ART 0%%i64 %IMGLINES%
for /L %%i in (100, 1, 255) do IF exist %%i.ART  ..\TOOLS\MALUVA\SC2DAAD c64 %%i.ART %%i64 %IMGLINES%
)
if "%SPLITSCR%" == "splitModeOn" ( 
echo Processing KOA files
ECHO.
for /L %%i in (0, 1, 9) do IF exist 00%%i.KOA ..\TOOLS\MALUVA\SC2DAAD c64 00%%i.KOA 00%%i64 96
for /L %%i in (10, 1, 99) do IF exist 0%%i.KOA  ..\TOOLS\MALUVA\SC2DAAD c64 0%%i.KOA 0%%i64 96
for /L %%i in (100, 1, 255) do IF exist %%i.KOA  ..\TOOLS\MALUVA\SC2DAAD c64 %%i.KOA %%i64 96
for /L %%i in (0, 1, 9) do IF exist 00%%i.KLA ..\TOOLS\MALUVA\SC2DAAD c64 00%%i.KLA 00%%i64 96
for /L %%i in (10, 1, 99) do IF exist 0%%i.KLA  ..\TOOLS\MALUVA\SC2DAAD c64 0%%i.KLA 0%%i64 96
for /L %%i in (100, 1, 255) do IF exist %%i.KLA  ..\TOOLS\MALUVA\SC2DAAD c64 %%i.KLA %%i64 96
)
CD ..
tools\cecho\cecho {02}[OK]{07}
ECHO.


tools\cecho\cecho {06}Preparing release files{07}
ECHO.
REM  ---- PREPARE THE FONT -----
COPY ASSETS\C64\apart1.prg  > nul 2>&1
TOOLS\DD\DD count=16 bs=1 if=apart1.prg of=apart1.HEAD  > nul 2>&1
TOOLS\DD\DD skip=2064 count=36 bs=1 if=apart1.prg of=apart1.TAIL  > nul 2>&1
COPY /B apart1.HEAD + ASSETS\CHARSET\%FONTB% + apart1.TAIL APART1.TMP > nul 2>&1
DEL apart1.HEAD > nul 2>&1
DEL apart1.TAIL > nul 2>&1
DEL apart1.prg > nul 2>&1


REM  ---- COPY FILES ---- 
tools\c1541\c1541.exe -attach %GAME%.D64 -write APART1.TMP apart1 > nul 2>&1
tools\c1541\c1541.exe -attach %GAME%.D64 -write DAAD.DDB bpart1 > nul 2>&1
tools\c1541\c1541.exe -attach %GAME%.D64 -write %INTERPRETER% %INTERPRETER_FINAL%  > nul 2>&1
for /L %%i in (0, 1, 9) do IF exist IMAGES\00%%i64 tools\c1541\c1541.exe -attach %GAME%.D64 -write IMAGES\00%%i64 00%%i64 > nul 2>&1
for /L %%i in (10, 1, 99) do IF exist IMAGES\0%%i64 tools\c1541\c1541.exe -attach %GAME%.D64 -write IMAGES\0%%i64 0%%i64 > nul 2>&1
for /L %%i in (100, 1, 256) do IF exist IMAGES\%%i64  tools\c1541\c1541.exe -attach %GAME%.D64 -write IMAGES\%%i64 %%i64 > nul 2>&1
for /L %%i in (0, 1, 32) do IF exist 0%%i.XMB tools\c1541\c1541.exe -attach %GAME%.D64 -write 0%%i.XMB 0%%i > nul 2>&1
for /L %%i in (10, 1, 32) do IF exist %%i.XMB tools\c1541\c1541.exe -attach %GAME%.D64 -write %%i.XMB %%i > nul 2>&1
tools\cecho\cecho {02}[OK]{07}
ECHO.

IF exist CUSTOM1.BAT CALL CUSTOM1.BAT
REM ----  CLEANING ---- 
DEL IMAGES\*64.> nul 2>&1
DEL DAAD.DDB > nul 2>&1
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
DEL *.TMP > nul 2>&1
DEL *.PRG > nul 2>&1

IF exist CUSTOM2.BAT CALL CUSTOM2.BAT
IF ERRORLEVEL  1 GOTO CUSTOM
REM ---- TESTER ---- 
ECHO.
MOVE %GAME%.D64 RELEASE\c64 > nul 2>&1
tools\cecho\cecho {03}

IF "%BASELANG%" == "EN" (
echo Game ready, press any key to test, or CTRL+C to stop
echo ------------------------------------------------------------------
echo  IMPORTANT WARNING:
echo  The emulator starts in warp mode /fast speed so the loading from
echo  disk is much faster. That will also affect the speed of the game
echo  when loading location graphics. Real speed is much slower, so if
echo  you wan to check the real speed, enter C64 menu, then choose
echo  'Miscellaneous' and set warp mode to 'aggressive'. Now close 
echo  settings, make sure some image is loaded, then enter menu again
echo  and set warp mode to 'off'.
echo ------------------------------------------------------------------
)
IF "%BASELANG%" == "ES" (
echo Juego listo, pulsa una tecla para probar, o CTRL+C para salir
echo ------------------------------------------------------------------
echo  AVISO IMPORTANTE:
echo  El emulador arranca en modo warp -velocidad rapida- por lo que la
echo  carga desde disco es mucho mas rapida. Eso tambien afectara a la
echo  velocidad del juego al cargar los graficos de las localizaciones.
echo  La velocidad real es mucho mas lenta, asi que si quieres comprobar
echo  la velocidad real, entra en el menu C64, elige 'Miscellaneous' y 
echo  pon el modo warp en 'aggressive'. Despues cierra los ajustes,
echo  sigue usando el juego hasta que se cargue una imagen, y vuelve a 
echo  entrar en el menu y eligiendo esta vez el modo warp 'off'.
echo ------------------------------------------------------------------
)
tools\cecho\cecho {07}
PAUSE
TOOLS\DENISE\DENISE RELEASE\C64\%GAME%.D64 -aggressive-warp
GOTO FIN

:ERROR
tools\cecho\cecho {04}
ECHO "Compile error, please check"
tools\cecho\cecho {07}
PAUSE
:FIN

REM ----  CLEANING ---- 
DEL DAAD.DDB > nul 2>&1
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
DEL *.TMP > nul 2>&1
DEL IMAGES\*64.> nul 2>&1
DEL *.PRG > nul 2>&1

REM  --- CUSTOM AREA ---
:CUSTOM
IF exist CUSTOM3.BAT CALL CUSTOM3.BAT 
