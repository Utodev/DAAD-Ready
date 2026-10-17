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


IF NOT exist %GAME%.DSF COPY ASSETS\TEMPLATES\BLANK_%LANG%.DSF %GAME%.DSF

REM ---- GET RESOURCES  ---- 
tools\cecho\cecho {06}Copying required files...{07}
echo.

SET INTERPRETER=ASSETS\SAM\DSAMIE.BIN
IF "%BASELANG%" == "ES" SET INTERPRETER=ASSETS\SAM\DSAMIS.BIN
COPY %INTERPRETER% DSAMI.BIN > nul 2>&1
COPY ASSETS\SAM\BLANK.MGT %GAME%.MGT > nul 2>&1
tools\cecho\cecho {02}[OK]{07}

ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Frontend]{07}
echo.
TOOLS\DRC\DRF sam %GAME%.DSF -v3
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
PHP\PHP TOOLS\DRC\DRB.PHP sam %LANG% %GAME%.json %GAME%.DDB 
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
MOVE %GAME%.DDB DAAD.DDB > nul 2>&1

REM  ---- PREPARE THE IMAGES ----
tools\cecho\cecho {06}Preparing images (if any){07}
ECHO.

move IMAGES\SAM\*.SAM . > nul 2>&1
CD IMAGES\SAM

SET IMGWIDTH=256

for /L %%i in (0, 1, 9) do IF exist 00%%i.PCX ..\..\TOOLS\SCRMAKER\SCRMAKER sam 00%%i.PCX ..\..\00%%i.SAM %IMGWIDTH% %IMGLINES% 0,0 -c -i > nul 2>&1
for /L %%i in (10, 1, 99) do IF exist 0%%i.PCX  ..\..\TOOLS\SCRMAKER\SCRMAKER sam 0%%i.PCX ..\..\0%%i.SAM %IMGWIDTH% %IMGLINES% 0,0 -c -i > nul 2>&1
for /L %%i in (100, 1, 256) do IF exist %%i.PCX  ..\..\TOOLS\SCRMAKER\SCRMAKER sam %%i.PCX ..\..\%%i.SAM %IMGWIDTH% %IMGLINES% 0,0 -c -i > nul 2>&1

CD ..\..


tools\cecho\cecho {02}[OK]{07}
ECHO.



REM  ---- ADD THE INTERPRETER ----
TOOLS\MGTMAN\mgtman_win32.exe -wc %GAME%.MGT DSAMI.BIN 98304
REM ---- ADD THE DDB ----
TOOLS\MGTMAN\mgtman_win32.exe -wc %GAME%.MGT DAAD.DDB 49408

REM  ---- GET THE FONT -----
COPY ASSETS\CHARSET\AD8x6.CHR DAAD.CHR > nul 2>&1
TOOLS\MGTMAN\mgtman_win32.exe -wc %GAME%.MGT DAAD.CHR


REM ---- ADD THE XMESSAGES ----
IF exist 0.XMB (
    TOOLS\MGTMAN\mgtman_win32.exe -wc %GAME%.MGT 0.XMB
)

REM ---- ADD THE IMAGES ----

if exist IMAGES\DAAD.SAM  (
    TOOLS\MGTMAN\mgtman_win32.exe -wc %GAME%.MGT IMAGES\DAAD.SAM
)


for /L %%i in (0, 1, 9) do IF exist 00%%i.SAM TOOLS\MGTMAN\mgtman_win32.exe -wc %GAME%.MGT 00%%i.SAM
for /L %%i in (10, 1, 99) do IF exist 0%%i.SAM TOOLS\MGTMAN\mgtman_win32.exe -wc %GAME%.MGT 0%%i.SAM  
for /L %%i in (100, 1, 255) do IF exist %%i.SAM TOOLS\MGTMAN\mgtman_win32.exe -wc %GAME%.MGT %%i.SAM
tools\cecho\cecho {02}[OK]{07}
ECHO.

MOVE %GAME%.MGT RELEASE\SAM > nul 2>&1

IF exist CUSTOM1.BAT CALL CUSTOM1.BAT
REM ----  CLEANING ---- 
DEL *.DDB > nul 2>&1
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
MV *.SAM IMAGES\SAM > nul 2>&1   (kept, so SCRMAKER -i does not regenerate them)
DEL *.XMB > nul 2>&1
DEL *.SDG > nul 2>&1
DEL *.TMP > nul 2>&1
DEL *.CHR > nul 2>&1
DEL *.GRA > nul 2>&1

IF exist CUSTOM2.BAT CALL CUSTOM2.BAT
IF ERRORLEVEL  1 GOTO CUSTOM
REM ---- TESTER ---- 
ECHO.
MOVE %GAME%.DSK RELEASE\ZXPLUS3 > nul 2>&1

tools\cecho\cecho {03}
ECHO Game is ready, press any key to test or Ctrl+C to cancel
tools\cecho\cecho {07}
PAUSE
cd TOOLS\SIMCOUPE
SIMCOUPE.EXE -DRIVE1 1 -DISK1 "..\..\RELEASE\SAM\%GAME%.MGT"  -autoboot 1 -keyin "BOOT\n"
CD ..\..
GOTO END

:ERROR
tools\cecho\cecho {04}
ECHO Compile error, please check
tools\cecho\cecho {07}
PAUSE
:END

REM ----  CLEANING ---- 
DEL DAAD.DDB > nul 2>&1
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
DEL *.TMP > nul 2>&1
DEL *.CHR > nul 2>&1
DEL *.GRA > nul 2>&1
MOVE *.SAM IMAGES\SAM > nul 2>&1

REM  --- CUSTOM AREA ---
:CUSTOM
IF exist CUSTOM3.BAT CALL CUSTOM3.BAT 