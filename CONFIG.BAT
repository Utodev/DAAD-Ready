@ECHO OFF
REM Version check
PHP\PHP.EXE TOOLS\CHECKVER\checkver.php
REM Fonts to be used
SET FONT6=AD8x6.CHR
SET FONT8=AD8x8.CHR
SET FONTB=C64bold.CHR
SET FONTPCDAAD=MSDOS.FNT
REM Name of the game,change it and change TEST.DSF if already exists to build with a new name
SET GAME=TEST
REM Change to splitModeOFF if you want to use original graphic modes in CPC and C64 targets
SET SPLITSCR=splitModeOFF
REM Height in pixels of the images. Please notice if you change this value you should disable split screen and use original graphic modes in CPC and C64 targets
SET IMGLINES=96
REM CHange to 1 if you want to use SVGA graphic modes in MSDOS/PC target
SET SVGA=0
REM Language settings
SET LANG=ES
SET BASELANG=ES
