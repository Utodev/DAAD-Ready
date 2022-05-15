@echo off
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



IF NOT exist %GAME%.DSF COPY TOOLS\DRC\BLANK_%LANG%.DSF %GAME%.DSF

IF "%BASELANG%" == "EN" (
ECHO There is not a Windows build, bug the MSDOS build does actually create apackage which includes the DOS game as is, together with DOSBOX, which allows running the game in Windows trasnparently just like many GOG.COM games. You can consider what is created at RELEASE\MSDOS as the Windows build, and what is at RELEASE\MSDOS\GAME as the proper DOS game.
)
IF "%BASELANG%" == "ES" (
ECHO No existe una compilaci¢n para Windows propiamente dicha. Sin embargo la compilaci¢n para MSDOS est  realmente creando un paquete que incluye el juego DOS propiamente dicho, junto con un pack con dosbox que permite ejecutarlo directamente en Windows, al estilo de muchos juegos de GOG.COM. Puedes compilar la versi¢n de MSDOS y distribuir lo que aparece en la carpeta RELEASE\MSDOS como una aventura para Windows.
)

pause