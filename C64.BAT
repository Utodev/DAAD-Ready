@echo off
SET DAADSCRIPT=C64

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



IF NOT exist %GAME%.DSF COPY TOOLS\DRC\BLANK_%LANG%.DSF %GAME%.DSF

REM ---- OBTENER RECURSOS ---- 
tools\cecho\cecho {06}Copying required files...{07}
COPY TOOLS\MALUVA\*.BIN > nul 2>&1
COPY ASSETS\C64\C64_%BASELANG%.D64 %GAME%.D64 > nul 2>&1
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
PHP\PHP TOOLS\DRC\DRB.PHP c64 %LANG% %GAME%.json %GAME%.DDB -ch
IF ERRORLEVEL 1 GOTO ERROR
MOVE %GAME%.DDB DAAD.DDB > nul 2>&1
MOVE %GAME%.DDB DAAD.DDB > nul 2>&1
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.

REM  ---- PREPARE IMAGES ----
tools\cecho\cecho {06}Preparing images (if any){07}
ECHO.
CD IMAGES
for /L %%i in (0, 1, 9) do IF exist 00%%i.KOA ..\TOOLS\MALUVA\SC2DAAD c64 00%%i.KOA 00%%i64 96
for /L %%i in (10, 1, 99) do IF exist 0%%i.KOA  ..\TOOLS\MALUVA\SC2DAAD c64 0%%i.KOA 0%%i64 96
for /L %%i in (100, 1, 255) do IF exist %%i.KOA  ..\TOOLS\MALUVA\SC2DAAD c64 %%i.KOA %%i64 96 
for /L %%i in (0, 1, 9) do IF exist 00%%i.KLA ..\TOOLS\MALUVA\SC2DAAD c64 00%%i.KLA 00%%i64 96
for /L %%i in (10, 1, 99) do IF exist 0%%i.KLA  ..\TOOLS\MALUVA\SC2DAAD c64 0%%i.KLA 0%%i64 96
for /L %%i in (100, 1, 255) do IF exist %%i.KLA  ..\TOOLS\MALUVA\SC2DAAD c64 %%i.KLA %%i64 96 
for /L %%i in (0, 1, 9) do IF exist 00%%i.ART ..\TOOLS\MALUVA\SC2DAAD c64 00%%i.ART 00%%i64 96
for /L %%i in (10, 1, 99) do IF exist 0%%i.ART  ..\TOOLS\MALUVA\SC2DAAD c64 0%%i.ART 0%%i64 96
for /L %%i in (100, 1, 255) do IF exist %%i.ART  ..\TOOLS\MALUVA\SC2DAAD c64 %%i.ART %%i64 96 
CD ..
tools\cecho\cecho {02}[OK]{07}
ECHO.


tools\cecho\cecho {06}Preparing release files{07}
ECHO.
REM  ---- PREPARE THE FONT -----
COPY ASSETS\C64\apart1.prg 
TOOLS\DD\DD count=16 bs=1 if=apart1.prg of=apart1.HEAD 
TOOLS\DD\DD skip=2064 count=36 bs=1 if=apart1.prg of=apart1.TAIL 
COPY /B apart1.HEAD + ASSETS\CHARSET\%FONTB% + apart1.TAIL APART1.TMP
DEL apart1.HEAD > nul 2>&1
DEL apart1.TAIL > nul 2>&1
DEL apart1.prg > nul 2>&1


REM  ---- COPY FILES ---- 
tools\c1541\c1541.exe -attach %GAME%.D64 -write APART1.TMP apart1
tools\c1541\c1541.exe -attach %GAME%.D64 -write DAAD.DDB bpart1
for /L %%i in (0, 1, 9) do IF exist IMAGES\00%%i64 tools\c1541\c1541.exe -attach %GAME%.D64 -write IMAGES\00%%i64 00%%i64
for /L %%i in (10, 1, 99) do IF exist IMAGES\0%%i64 tools\c1541\c1541.exe -attach %GAME%.D64 -write IMAGES\0%%i64 0%%i64
for /L %%i in (100, 1, 256) do IF exist IMAGES\%%i64  tools\c1541\c1541.exe -attach %GAME%.D64 -write IMAGES\%%i64 %%i64
for /L %%i in (0, 1, 32) do IF exist 0%%i.XMB tools\c1541\c1541.exe -attach %GAME%.D64 -write 0%%i.XMB 0%%i
for /L %%i in (10, 1, 32) do IF exist %%i.XMB tools\c1541\c1541.exe -attach %GAME%.D64 -write %%i.XMB 0%%i
tools\cecho\cecho {02}[OK]{07}
ECHO.

IF exist CUSTOM1.BAT CALL CUSTOM1.BAT
REM ----  CLEANING ---- 
DEL DAAD.DDB > nul 2>&1
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
DEL *.TMP > nul 2>&1

IF exist CUSTOM2.BAT CALL CUSTOM2.BAT
IF ERRORLEVEL  1 GOTO CUSTOM
REM ---- TESTER ---- 
ECHO.
MOVE %GAME%.D64 RELEASE\c64 > nul 2>&1
tools\cecho\cecho {03}
IF "%BASELANG%" == "EN" (
ECHO "Game ready, press any key to test, or CTRL+C to stop"
echo "--------------------------------------------------------------------"
echo "| Type    LOAD "*",8,1   lo load the game                          |"
echo "| Loading from disk is slow in C64, it will take some time. To     |"
echo "| speed it up a bit press Ctrl+P (warp), but it still will be slow.|"
echo "| To see game Full Screen, press Ctrl+F1                           |"
echo "| Please notice C64DEbugger is beerware, you can send some beer to |"
echo "| slajerek@gmail.com, or some money to                             |"
echo "| http://tinyurl.com/C64Debugger-PayPal                            |"                  
echo "--------------------------------------------------------------------"
)
IF "%BASELANG%" == "ES" (
ECHO "Juego preparado, pulsa una tecla para probar, o Ctrl+C para parar."
echo "--------------------------------------------------------------------"
echo "| Teclea    LOAD "*",8,1    para cargar el juego                   |"
echo "| En C64Debugger '*' esta en la tecla justo a la izq. de borrar <- |"
echo "| La emulacion de disquetera es lenta, tardara en cargar, se puede |"
echo "| acelerar un poco pulsando Ctrl+P (warp) pero aun sera lenta.     |"
echo "| Para ver el juego en pantalla grande, pulsar Ctrl+F1             |"
echo "| Por favor ten en cuenta que C64DEbugger es beerware, puedes      |"
echo "| cerveza a slajerek@gmail.com, o dinero para comprarla a          |"
echo "| http://tinyurl.com/C64Debugger-PayPal                            |"                  
echo "--------------------------------------------------------------------"
)
tools\cecho\cecho {07}
PAUSE
TOOLS\C64DEBUGGER\C64DEBUGGER -d64 RELEASE\C64\%GAME%.D64 -autorundisk
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

REM  --- CUSTOM AREA ---
:CUSTOM
IF exist CUSTOM3.BAT CALL CUSTOM3.BAT 