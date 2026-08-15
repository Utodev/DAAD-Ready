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

REM ---- GET RESOURCES ---- 
tools\cecho\cecho {06}Copying required files...{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Frontend]{07}
ECHO.
TOOLS\DRC\DRF zx81 16k %GAME%.DSF -v3
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Backend]{07}
ECHO.
setlocal enabledelayedexpansion
REM -- Calculate DDB address ---
SET VERSNO_FILE=ASSETS\ZX81\ZX81VERSNOE.INF
IF "%BASELANG%" == "ES" SET VERSNO_FILE=ASSETS\ZX81\ZX81VERSNOS.INF
FOR /F "tokens=3" %%A IN (%VERSNO_FILE%) DO (
    set VERSNO=%%A
    goto fin
)
:fin
echo Calculated DDB address:  %VERSNO%
PHP\PHP TOOLS\DRC\DRB.PHP zx81 16k %LANG% %GAME%.json %GAME%.DDB -B=%VERSNO%
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.


REM  ---- COPY FILES ---- 
DEL /s /q RELEASE\ZX8116K\*.*   > nul 2>&1
tools\cecho\cecho {06}Preparing release files{07}

REM --- PREPARE RELEASE FILES ----
ECHO.
SET INTERPRETER=DZX81IE3.BIN
IF "%BASELANG%" == "ES" SET INTERPRETER=DZX81IS3.BIN

REM The DDB must be strictly named DAAD.DDB
COPY /B ASSETS\ZX81\%INTERPRETER% + %GAME%.DDB  DAAD.BIN >nul 2>&1
FOR %%A IN ("DAAD.BIN") DO set filesize=%%~zA
echo "File size: %filesize%"
SET /A SPARE= 32768! - 17433- %filesize%
echo "Spare bytes: %SPARE%"
REM If spare bytes are less than 0, the DDB is too big for the 16k target
IF %SPARE% LSS 0 (
    tools\cecho\cecho {04}
    ECHO DDB file is too big for the 16k target, please check
    tools\cecho\cecho {07}
    PAUSE
    GOTO END
)



REM  -- PREPARE THE .P LOADER ---
PHP\PHP.EXE TOOLS\ZX81\bin2b81.php DAAD.BIN %GAME%%.B81
COPY %GAME%.B81 RELEASE\ZX8116K\ >nul 2>&1
PHP\PHP.EXE TOOLS\ZX81\sd81mkp.php %GAME%.B81 RELEASE\ZX8116K\%GAME%.P

DEL %GAME%.B81 >nul 2>&1
DEL DAAD.BIN >nul 2>&1


IF exist CUSTOM1.BAT CALL CUSTOM1.BAT
REM ----  CLEANING ---- 
DEL %GAME%.DDB > nul 2>&1
DEL %GAME%.json > nul 2>&1
DEL *.SDG > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1

IF exist CUSTOM2.BAT CALL CUSTOM2.BAT
IF ERRORLEVEL  1 GOTO CUSTOM
REM ---- TESTER ---- 
tools\cecho\cecho {03}
ECHO Press any key to run emulator, or Ctrl+C to cancel. 
tools\cecho\cecho {07}


PAUSE
rem COPY ASSETS\ZX81\EightyOne16K.ini EightyOne.ini > nul 2>&1

cd TOOLS\Eightyone
eightyone.exe ..\..\RELEASE\ZX8116K\%GAME%.P ..\..\EightyOne.ini
CD ..\..

GOTO END

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
DEL *.INI

REM  --- CUSTOM AREA ---
:CUSTOM
IF exist CUSTOM3.BAT CALL CUSTOM3.BAT 