@echo off
SET DAADSCRIPT=%~n0

GOTO START
REM ---- Check if the file to compress is already compressed or is newer
:CHECK_IF_COMPRESS
  IF not exist %1 exit /b 1
  IF not exist %2 exit /b 0
  FOR %%i IN (%1) DO SET DATE1=%%~ti
  FOR %%i IN (%2) DO SET DATE2=%%~ti
  IF "%DATE1%"=="%DATE2%" exit /b 0
  FOR /F %%i IN ('DIR /B /O:D %1 %2') DO SET NEWEST=%%i
  IF "%2"=="%NEWEST%" exit /b 1
  exit /b 0
:START

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

IF NOT EXIST "ASSETS\ZX128TAPE.warning" (
    if "%BASELANG%" == "ES" (

        tools\cecho\cecho {06}AVISO: ESTA BAT GENERA UNA DISTRIBUCION PARA SPECTRUM 128K UTILIZANDO EL NUEVO INTERPRETE ZXDAAD128, que no es un interprete original de DAAD. {07} 
        tools\cecho\cecho {06}ZXDAAD128 esta en una etapa de pruebas, y aunque en general ha sido ya probado, podrian aparecer problemas o incompatibilidades inesperadas. {07}
        tools\cecho\cecho {06}Por favor, antes de reportar un error comprueba que el comportamiento es diferente en otros targets.{07}    
        echo.
        PAUSE
        echo "OK" > ASSETS\ZX128TAPE.warning
    )
    if "%BASELANG%" == "EN" (
        tools\cecho\cecho "{06}WARNING: THIS BAT GENERATES A DISTRIBUTION FOR SPECTRUM 128K USING NEW ZXDAAD128 INTERPRETER, WHICH IS NOT AN ORIGINAL DAAD interpreter{07}" 
        tools\cecho\cecho "{06}ZXDAAD128 is in early stages of development, and although it has been tested quite a lot, unexpected problems or incompatibilities could appear. {07}"
        echo.
        tools\cecho\cecho "{06}Before reporting a bug, please check that the behaviour is different in other targets.{07}"
        PAUSE
        echo "OK" > ASSETS\ZX128TAPE.warning
    )
)

REM ----  SET CHARACTERS PER LINE ---- 
IF  NOT DEFINED CHARSLINE (
        SET CHARSLINE=42
)
echo Characters per line: %CHARSLINE%

IF NOT exist %GAME%.DSF COPY ASSETS\TEMPLATES\BLANK_%LANG%.DSF %GAME%.DSF

REM ---- GET RESOURCES ---- 
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.

REM  ---- PREPARE IMAGES ----
tools\cecho\cecho {06}Preparing images (if any){07}
ECHO.
CD IMAGES
for /L %%i in (0, 1, 9) do (CALL :CHECK_IF_COMPRESS 00%%i.SCR 00%%i.DCP && (..\TOOLS\ZXDAAD128\DCP -l=%IMGLINES% -f -o=00%%i.DCP 00%%i.SCR  > nul 2>&1))
for /L %%i in (10, 1, 99) do (CALL :CHECK_IF_COMPRESS 0%%i.SCR 0%%i.DCP && (..\TOOLS\ZXDAAD128\DCP -l=%IMGLINES% -f -o=0%%i.DCP 0%%i.SCR  > nul 2>&1))
for /L %%i in (100, 1, 256) do (CALL :CHECK_IF_COMPRESS %%i.SCR %%i.DCP && (..\TOOLS\ZXDAAD128\DCP -l=%IMGLINES% -f -o=%%i.DCP %%i.SCR  > nul 2>&1))
CD ..
tools\cecho\cecho {02}[OK]{07}
ECHO.

tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Frontend]{07}
echo.
TOOLS\DRC\DRF zx esxdos %GAME%.DSF tape,zx128
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.
tools\cecho\cecho {06}Compiling [Backend]{07}
echo.
SET IMAGEOPTION=
IF exist .\IMAGES\*.DCP SET IMAGEOPTION=-i .\IMAGES 
PHP\PHP TOOLS\ZXDAAD128\DRB128.PHP %IMAGEOPTION% -o %GAME% TAPE %LANG% %BASELANG% %CHARSLINE% %GAME%.json ASSETS\CHARSET\%FONT6%
IF ERRORLEVEL 1 GOTO ERROR
tools\cecho\cecho {02}[OK]{07}
ECHO.
tools\cecho\cecho {0B}----------------------------------------------------------------------{07}
echo.

REM --- PREPARE TAP FILE ----
tools\cecho\cecho {06}Preparing tap file{07}
ECHO.
SET BANKFILES= 
IF exist %GAME%.AD0 SET BANKFILES=%BANKFILES% %GAME%.AD0
IF exist %GAME%.AD1 SET BANKFILES=%BANKFILES% %GAME%.AD1
IF exist %GAME%.AD3 SET BANKFILES=%BANKFILES% %GAME%.AD3
IF exist %GAME%.AD4 SET BANKFILES=%BANKFILES% %GAME%.AD4
IF exist %GAME%.AD6 SET BANKFILES=%BANKFILES% %GAME%.AD6
IF exist %GAME%.AD7 SET BANKFILES=%BANKFILES% %GAME%.AD7
SET LOADING_SCREEN=
if exist IMAGES\DAAD.SCR SET LOADING_SCREEN=-s IMAGES\DAAD.SCR
PHP\PHP TOOLS\ZXDAAD128\DAADMAKER128.PHP -t %GAME%.TAP -n %GAME% %LOADING_SCREEN% %BANKFILES%
IF ERRORLEVEL 1 GOTO ERROR
MOVE %GAME%.TAP RELEASE\ZX128K_EXPERIMENTAL > nul 2>&1
tools\cecho\cecho {02}[OK]{07}
ECHO.

IF exist CUSTOM1.BAT CALL CUSTOM1.BAT
REM ----  CLEANING ---- 
DEL %GAME%.AD? > nul 2>&1
DEL %GAME%.json > nul 2>&1

IF exist CUSTOM2.BAT CALL CUSTOM2.BAT
IF ERRORLEVEL  1 GOTO CUSTOM




REM ---- TESTER ---- 





tools\cecho\cecho {0C}
IF "%BASELANG%" == "EN" (
ECHO Press any key to run emulator, or Ctrl+C to cancel.
ECHO To exit ZEsarUX emulator, press F5, then F10.
)

IF "%BASELANG%" == "ES"  (
ECHO Pulsa una tecla para ejecutar el emulador, o Ctrl+C para cancelar.
ECHO Para salir del emulador ZEsarUX, pulsa F5, luego F10.
)
tools\cecho\cecho {07}



PAUSE
cd TOOLS\ZESARUX
zesarux --noconfigfile --quickexit --fastautoload --zoom 2 --machine 128k --realvideo --nosplash --forcevisiblehotkeys --forceconfirmyes  --nowelcomemessage  --cpuspeed 100 "..\..\RELEASE\ZX128K_EXPERIMENTAL\%GAME%.tap"
CD ..\..
GOTO END


:ERROR
:ERROR
tools\cecho\cecho {04}
ECHO "Compile error, please check"
tools\cecho\cecho {07}
PAUSE
:END

REM ----  CLEANING ---- 
DEL %GAME%.AD? > nul 2>&1
DEL %GAME%.json > nul 2>&1


REM  --- CUSTOM AREA ---
:CUSTOM
IF exist CUSTOM3.BAT CALL CUSTOM3.BAT 