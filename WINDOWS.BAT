@echo off
SET DAADSCRIPT=%~n0

REM ---- ZONA DE VARIABLES ---- 
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
IF exist CUSTOM1.BAT CALL CUSTOM1.BAT
IF exist CUSTOM2.BAT CALL CUSTOM2.BAT
IF ERRORLEVEL  1 GOTO CUSTOM
IF NOT exist %GAME%.DSF COPY ASSETS\TEMPLATES\BLANK_%LANG%.DSF %GAME%.DSF

IF "%SVGA%"=="" (
        ECHO Creating VGA GAME
    ) ELSE (
        SET PARAMETER=-s
        ECHO Creating SVGA GAME
    )


REM  Prepare InnoSetup BuildScript

echo #define MyAppName "%GAME%" > gamebuild.iss
PHP\php.exe ASSETS\WINDOWS\patcher.php
type buildScript.tmp >>  gamebuild.iss

copy ASSETS\WINDOWS\dosbox.conf  > nul 2>&1
echo PCDAAD %PARAMETER%  >>dosbox.conf
echo exit >> dosbox.conf

if not exist RELEASE\MSDOS\%GAME%.BAT (
        IF "%BASELANG%" == "EN" (
        echo Please build MSDOS version prior to create the Windows package
    )
    IF "%BASELANG%" == "ES" (
        echo Por favor genera la version MSDOS antes de crear el paquete para Windows
    )
    pause
    goto END
)

IF "%BASELANG%" == "EN" (
    TOOLS\InnoSetup\Compil32.exe /cc gamebuild.iss
    echo The Windows setup file has been created at the RELEASE\WINDOWS folder.
)
IF "%BASELANG%" == "ES" (
    TOOLS\InnoSetup\Compil32.exe /cc gamebuild.iss
    echo El paquete de instalacion para Windows se ha creado en la carpeta RELEASE\WINDOWS
)
DEL gamebuild.iss  > nul 2>&1
DEL buildScript.tmp  > nul 2>&1
DEL dosbox.conf  > nul 2>&1
pause

REM  --- CUSTOM AREA ---
:CUSTOM
IF exist CUSTOM3.BAT CALL CUSTOM3.BAT 
:END
