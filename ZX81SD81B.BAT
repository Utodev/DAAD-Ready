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
TOOLS\DRC\DRF zx81 sd81b %GAME%.DSF -v3
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Backend]{07}
ECHO.
PHP\PHP TOOLS\DRC\DRB.PHP zx81 sd81b %LANG% %GAME%.json %GAME%.DDB 
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.

REM  ---- PREPARE THE IMAGES ----
tools\cecho\cecho {06}Preparing images (if any){07}
ECHO.

CD IMAGES\ZX
del *.s48 > nul 2>&1 ; 
del *.prt > nul 2>&1 ; 
del *.img > nul 2>&1 ;

SET IMGWIDTH=256

for /L %%i in (0, 1, 9) do IF exist 00%%i.SCR ..\..\php\php.exe ..\..\TOOLS\DRC\ZXsplitter.php 00%%i.SCR %IMGLINES%  > nul 2>&1
for /L %%i in (10, 1, 99) do IF exist 0%%i.SCR ..\..\php\php.exe ..\..\TOOLS\DRC\ZXsplitter.php 0%%i.SCR %IMGLINES%  > nul 2>&1
for /L %%i in (100, 1, 256) do IF exist %%i.SCR ..\..\php\php.exe ..\..\TOOLS\DRC\ZXsplitter.php %%i.SCR %IMGLINES%  > nul 2>&1

for %%f in (*.prt) do (
                     <nul set /p =*
                     ..\..\TOOLS\ZX0\zx0.exe %%f > nul 2>&1

)
ECHO.

for /L %%i in (0, 1, 9) do IF exist 00%%i.SCR ..\..\php\php.exe ..\..\TOOLS\ZX81\sd81img.php %%i.SCR .  > nul 2>&1
for /L %%i in (10, 1, 99) do IF exist 0%%i.SCR ..\..\php\php.exe ..\..\TOOLS\ZX81\sd81img.php %%i.SCR .  > nul 2>&1
for /L %%i in (100, 1, 256) do IF exist %%i.SCR ..\..\php\php.exe ..\..\TOOLS\ZX81\sd81img.php %%i.SCR .  > nul 2>&1


ECHO.

del *.prt > nul 2>&1 ; 
CD ..\..

tools\cecho\cecho {02}[OK]{07}
ECHO.


REM  ---- COPY FILES ---- 
DEL /s /q RELEASE\ZX81SD81B\*.*   > nul 2>&1
tools\cecho\cecho {06}Preparing release files{07}
ECHO.
mkdir RELEASE\ZX81SD81B\IMG > nul 2>&1
del RELEASE\ZX81SD81B\IMG\*.IMG > nul 2>&1
IF exist 0.XMB copy 0.XMB RELEASE\ZX81SD81B > nul 2>&1
for /L %%i in (0, 1, 9) do IF exist IMAGES\ZX\00%%i.IMG COPY IMAGES\ZX\00%%i.IMG  RELEASE\ZX81SD81B\IMG > nul 2>&1
for /L %%i in (10, 1, 99) do IF exist IMAGES\ZX\0%%i.IMG COPY IMAGES\ZX\0%%i.IMG  RELEASE\ZX81SD81B\IMG > nul 2>&1
for /L %%i in (100, 1, 255) do IF exist IMAGES\ZX\%%i.IMG COPY IMAGES\ZX\%%i.IMG  RELEASE\ZX81SD81B\IMG > nul 2>&1
tools\cecho\cecho {02}[OK]{07}
ECHO.

REM --- PREPARE RELEASE FILES ----
SET INTERPRETER=DSD81IE3.BIN
IF "%BASELANG%" == "ES" SET INTERPRETER=DSD81IS3.BIN 

REM Generate a SDG file with the proper charset
del SD81_TMP.TAP >nul 2>&1
TOOLS\DRC\daadmaker.exe SD81_TMP.TAP ASSETS\ZX81\%INTERPRETER% %GAME%.DDB  ASSETS\CHARSET\%FONT6%
IF ERRORLEVEL 1 GOTO ERROR
PHP\PHP.EXE TOOLS\ZX81\sd81sdgextract.php SD81_TMP.TAP DAAD.SDG
IF ERRORLEVEL 1 GOTO ERROR
del SD81_TMP.TAP >nul 2>&1

REM Copy the SDG
COPY DAAD.SDG RELEASE\ZX81SD81B > nul 2>&1
REM The DDB must be strictly named DAAD.DDB
COPY %GAME%.DDB RELEASE\ZX81SD81B\DAAD.DDB >nul 2>&1
REM The XMB if exists
IF EXIST 0.XMB COPY 0.XMB RELEASE\ZX81SD81B > nul 2>&1
REM The interpreter and ROM files
MKDIR RELEASE\ZX81SD81B\BIN > nul 2>&1
DEL /Q RELEASE\ZX81SD81B\BIN\*.* > nul 2>&1
COPY ASSETS\ZX81\%INTERPRETER% RELEASE\ZX81SD81B\BIN > nul 2>&1
COPY ASSETS\ZX81\DSD81ROM1.BIN RELEASE\ZX81SD81B\BIN > nul 2>&1
IF "%BASELANG%" == "ES" COPY ASSETS\ZX81\DSD81ROM0S.BIN RELEASE\ZX81SD81B\BIN\DSD81ROM0.BIN > nul 2>&1
IF "%BASELANG%" == "EN" COPY ASSETS\ZX81\DSD81ROM0E.BIN RELEASE\ZX81SD81B\BIN\DSD81ROM0.BIN > nul 2>&1
MKDIR RELEASE\ZX81SD81B\SYS > nul 2>&1
DEL /Q RELEASE\ZX81SD81B\SYS\*.* > nul 2>&1
COPY TOOLS\EightyOne\SD81\SYS\SDBOOST.ROM RELEASE\ZX81SD81B\SYS > nul 2>&1
COPY ASSETS\ZX81\EightyOne.ini  > nul 2>&1
ECHO AutoType=J^^F"%GAME%.P"\n@>>EightyOne.ini 
ECHO NewlineDelay=1000>>EightyOne.ini




REM  -- PREPARE THE .P LOADER ---
COPY ASSETS\ZX81\%INTERPRETER% %INTERPRETER% > nul 2>&1
PHP\PHP.EXE TOOLS\ZX81\sd81mkb81.php CARGA.B81 %INTERPRETER% DAAD.DDB DAAD.SDG
PHP\PHP.EXE TOOLS\ZX81\sd81mkp.php  CARGA.B81 RELEASE\ZX81SD81B\%GAME%.P
DEL CARGA.B81 >nul 2>&1
DEL %INTERPRETER% >nul 2>&1


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
cd TOOLS\Eightyone
Eightyone.exe ..\..\EightyOne.ini
CD ..\..
DEL EightyOne.ini > nul 2>&1
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

REM  --- CUSTOM AREA ---
:CUSTOM
IF exist CUSTOM3.BAT CALL CUSTOM3.BAT 