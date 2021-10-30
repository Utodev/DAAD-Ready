@echo off

REM ----  VARIABLES ---- 
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

REM ---- GET RESOURCES ---- 

ECHO.
ECHO ---------------------------------------------------------
ECHO Compiling [Front End]...
TOOLS\DRC\DRF zx esxdos %GAME%.DSF tape
IF ERRORLEVEL 1 GOTO ERROR
ECHO.
ECHO ---------------------------------------------------------
ECHO Compiling [Back End]...
PHP\PHP TOOLS\DRC\DRB.PHP zx esxdos %LANG% %GAME%.json %GAME%.DDB 
IF ERRORLEVEL 1 GOTO ERROR

REM  ---- COPY FILES ---- 
IF exist 0.XMB (
    echo "Tape version does not accept XMESSAGES"
    GOTO ERROR
)

REM --- PREPARE TAP FILE ----
SET INTERPRETER=ASSETS\ZX\DS48IE.P3F
IF "%BASELANG%" == "ES" SET INTERPRETER=ASSETS\ZX\DS48IS.P3F 
TOOLS\DRC\daadmaker.exe %GAME%.TAP %INTERPRETER% %GAME%.DDB ASSETS\CHARSET\%FONT6%
MOVE %GAME%.TAP RELEASE\ZXTAPE > nul 2>&1

REM ----  CLEANING ---- 
DEL %GAME%.DDB > nul 2>&1
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1

REM ---- TESTER ---- 
ECHO.
ECHO "Press any key to run emulator, or Ctrl+C to cancel." 
ECHO "To exit ZEsarUX emulator, press F5, then F10." 


PAUSE
cd TOOLS\ZESARUX
zesarux  --noconfigfile --zoom 2 --machine 48k --realvideo --nosplash --forcevisiblehotkeys --forceconfirmyes  --nowelcomemessage  --cpuspeed 100 "..\..\RELEASE\ZXTAPE\%GAME%.tap"
CD ..\..
GOTO END

:ERROR
ECHO "Something went wrong, please check errors"
PAUSE
:END

REM ----  CLEANING ---- 
DEL %GAME%.DDB > nul 2>&1
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1

