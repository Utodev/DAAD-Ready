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


IF NOT exist %GAME%.DSF COPY ASSETS\TEMPLATES\BLANK_%LANG%.DSF %GAME%.DSF

REM ---- OBTENER RECURSOS ---- 
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
SET INTERPRETER=ASSETS\ATARIST\EDIP1.PRG
IF "%BASELANG%" == "ES" SET INTERPRETER=ASSETS\ATARIST\SDIP1.PRG
COPY %INTERPRETER% RELEASE\ATARIST\%GAME%.PRG 
COPY ASSETS\CHARSET\%FONT6% RELEASE\ATARIST\PART1.TMP > nul 2>&1
TOOlS\SPECFORM\SPECFORM -a 16384 RELEASE\ATARIST\PART1.TMP > nul 2>&1
MOVE RELEASE\ATARIST\PART1.TMP.zxb RELEASE\ATARIST\PART1.CH0 > nul 2>&1
DEL RELEASE\ATARIST\PART1.TMP > nul 2>&1


tools\cecho\cecho {02}[OK]{07}
ECHO.


tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Frontend]{07}
echo.
TOOLS\DRC\DRF st %GAME%.DSF -force-normal-messages 
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

REM  ---- PREPARE IMAGES ----
PHP\php TOOLS\img2daad\img2daad.php IMAGES;SOUNDS RELEASE\ATARIST\PART1.DAT -c
IF ERRORLEVEL 1 GOTO ERROR
IF exist IMAGES\DAAD.PNG (
    PHP\PHP TOOLS\IMG2DAAD\PNG2DEGAS.PHP IMAGES\DAAD.PNG IMAGES\DAAD.PI1
    MOVE IMAGES\DAAD.PI1 RELEASE\ATARIST\PART1.SCR > nul 2>&1
)
IF ERRORLEVEL 1 GOTO ERROR


tools\cecho\cecho {06}Preparing release files{07}
ECHO.
MOVE %GAME%.DDB RELEASE\ATARIST\PART1.DDB > nul 2>&1
ECHO.

IF exist CUSTOM1.BAT CALL CUSTOM1.BAT
REM ----  CLEAN ---- 
DEL %GAME%.json > nul 2>&1
DEL *.BIN > nul 2>&1
DEL *.XMB > nul 2>&1
DEL *.CHR > nul 2>&1

tools\cecho\cecho {06}Preparing .ST floppy disk image file{07}
REM ----  COMPRESS AND PREPARE .ST IMAGE----
MD RELEASE\ATARIST\FLOPPY\ > nul 2>&1
DEL RELEASE\ATARIST\%GAME%.ZIP > nul 2>&1
DEL RELEASE\ATARIST\FLOPPY\%GAME%.ST > nul 2>&1
TOOLS\ZIP\ZIP -j -9 RELEASE\ATARIST\FLOPPY\%GAME%.ZIP RELEASE\ATARIST\PART1.* RELEASE\ATARIST\%GAME%.* > nul 2>&1 
TOOLS\MSA\msa.exe convert RELEASE\ATARIST\FLOPPY\%GAME%.ZIP ST 1 exit > nul 2>&1
DEL RELEASE\ATARIST\FLOPPY\%GAME%.ZIP > nul 2>&1


IF exist CUSTOM2.BAT CALL CUSTOM2.BAT
IF ERRORLEVEL  1 GOTO CUSTOM
REM ---- TESTER ---- 
ECHO.
tools\cecho\cecho {03}
IF "%BASELANG%" == "EN" (
ECHO Game ready,press any key to test or CTRL+C to stop
ECHO The game will be executed from RELEASE\ATARIST, but you can also find it in RELEASE\ATARIST\FLOPPY,
ECHO in .ST format, as long as it fits in a 720Kb disk.
)
IF "%BASELANG%" == "ES" (  
ECHO EL JUEGO SE HA COMPILADO CORRECTAMENTE, PULSE ENTER PARA INICIAR EL EMULADOR, O CTRL+C PARA PARAR
ECHO El juego que se ejecutara esta en RELEASE\ATARIST, pero podeis encontrarlo tambien en la carpeta
ECHO RELEASE\ATARIST\FLOPPY, en formato .ST, siempre que quepa en un disco de 720Kb.
)
tools\cecho\cecho {07}
PAUSE
CD TOOLS\HATARI
HATARI --harddrive ..\..\RELEASE\ATARIST --confirm-quit 0 --auto C:\%GAME%.PRG --fast-boot 1 
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