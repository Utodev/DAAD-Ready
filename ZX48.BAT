@echo off
SET DAADSCRIPT=%~n0

REM ----  VARIABLES ---- 
CALL CONFIG.BAT
IF exist CUSTOM.BAT CALL CUSTOM.BAT 0

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


IF NOT exist %GAME%.DSF COPY ASSETS\TEMPLATES\BLANK_%LANG%.DSF %GAME%.DSF





REM ---- GET RESOURCES ---- 
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Frontend]{07}
echo.
TOOLS\DRC\DRF zx 48k %GAME%.DSF -force-normal-messages -v3  tape48
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Backend]{07}
echo.
PHP\PHP TOOLS\DRC\DRB.PHP zx 48k %LANG% %GAME%.json %GAME%.DDB -v
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.

REM  ---- PREPARE THE IMAGES ----
tools\cecho\cecho {06}Preparing images (if any){07}
ECHO.

CD IMAGES
del *.s48 > nul 2>&1 ; 
del *.prt > nul 2>&1 ; 

SET IMGWIDTH=256

for /L %%i in (0, 1, 9) do IF exist 00%%i.SCR ..\php\php.exe ..\TOOLS\DRC\ZXsplitter.php 00%%i.SCR %IMGLINES%  > nul 2>&1
for /L %%i in (10, 1, 99) do IF exist 0%%i.SCR ..\php\php.exe ..\TOOLS\DRC\ZXsplitter.php 0%%i.SCR %IMGLINES%  > nul 2>&1
for /L %%i in (100, 1, 256) do IF exist %%i.SCR ..\php\php.exe ..\TOOLS\DRC\ZXsplitter.php %%i.SCR %IMGLINES%  > nul 2>&1

for %%f in (*.prt) do (
                     <nul set /p =*
                     ..\TOOLS\ZX0\zx0.exe %%f > nul 2>&1

)
ECHO.

..\php\php.exe ..\TOOLS\DRC\pager48k.php  ..\%GAME%.DDB
ECHO.

del *.prt > nul 2>&1 ; 
CD ..

tools\cecho\cecho {02}[OK]{07}
ECHO.



REM  ---- COPY FILES ---- 
IF exist 0.XMB (
    echo Tape 48K version does not accept XMESSAGES
    GOTO ERROR
)

REM --- PREPARE TAP FILE ----
COPY ASSETS\ZX\DAAD.SDG > nul 2>&1
tools\cecho\cecho {06}Preparing tap file{07}
ECHO.
SET INTERPRETER=ASSETS\ZX\ZXSPECTRUM\DS48IE3.BIN
IF "%BASELANG%" == "ES" SET INTERPRETER=ASSETS\ZX\ZXSPECTRUM\DS48IS3.BIN
IF exist images\DAAD.SCR SET %LOADING=images\DAAD.SCR
del INDEX.BIN > nul 2>&1
del PAGE0.TMP > nul 2>&1

MOVE IMAGES\INDEX.BIN . > nul 2>&1
MOVE IMAGES\PAGE0.TMP . > nul 2>&1
if exist DAAD.SCR TOOLS\DRC\daadmaker.exe %GAME%.TAP %INTERPRETER% %GAME%.DDB DAAD.SCR ASSETS\CHARSET\%FONT6% INDEX.BIN DAAD.SDG /48
rem > nul 2>&1
if NOT exist DAAD.SCR TOOLS\DRC\daadmaker.exe %GAME%.TAP %INTERPRETER% %GAME%.DDB ASSETS\CHARSET\%FONT6% INDEX.BIN DAAD.SDG /48
REM > nul 2>&1
IF ERRORLEVEL 1 GOTO ERROR
MOVE %GAME%.TAP RELEASE\ZX48K > nul 2>&1
tools\cecho\cecho {02}[OK]{07}
ECHO.

IF exist CUSTOM1.BAT CALL CUSTOM1.BAT
REM ----  CLEANING ---- 
DEL %GAME%.DDB > nul 2>&1
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
DEL PAGE0.TMP > nul 2>&1
DEL *SDG > nul 2>&1

IF exist CUSTOM2.BAT CALL CUSTOM2.BAT
IF ERRORLEVEL  1 GOTO CUSTOM
REM ---- TESTER ---- 
tools\cecho\cecho {03}
ECHO Press any key to run emulator, or Ctrl+C to cancel.
ECHO To exit ZEsarUX emulator, press F5, then F10. 
tools\cecho\cecho {07}


PAUSE
cd TOOLS\ZESARUX
zesarux --noconfigfile --load-additional-config --quickexit --fastautoload --zoom 2 --machine 48k --realvideo --nosplash --forcevisiblehotkeys --forceconfirmyes  --nowelcomemessage  --cpuspeed 100  "..\..\RELEASE\ZX48K\%GAME%.tap" 
CD ..\..
GOTO END

:ERROR
:ERROR
tools\cecho\cecho {04}
ECHO Compile error, please check
tools\cecho\cecho {07}
PAUSE
:END

REM ----  CLEANING ---- 
DEL %GAME%.DDB > nul 2>&1
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
DEL PAGE0.TMP > nul 2>&1
DEL *SDG > nul 2>&1

REM  --- CUSTOM AREA ---
:CUSTOM
IF exist CUSTOM3.BAT CALL CUSTOM3.BAT 
