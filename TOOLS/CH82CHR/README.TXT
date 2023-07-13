CH82CHR is a tool to convert Damien Guard's 8 bit fonts to DAAD format, as much as possible (not always perfect). It's a PHP script so you will need PHP to run it. This software is free software and GPL3 license applies.

Syntax: php ch82chr.php <inputFile> <type>

<inputFile>: any .ch8 file from Damien Guard's repository
<type>: the type of output file. Types can be '6' to generate AD8x6.CHR file, '8' to generate AD8x8.CHR file, 'C64' to generate C64bold.CHR file or 'DOSF' to generate the MSDOS.FNT file with fixed with, and 'DOSP' to generate the MSDOS.FNT file with a proportional width per character. Please notice the type won't change the font at all, it's used to determine output format and be able to generate warnings if input font doens't fit well in the output format.

When generating MSDOS.FNT file, with proportional mode, the generated font will have a different width per character, which is the width of the character plus one, to leave a gap, when possible. Character 32, space, will always be 8 pixels wide, though.

You can find Damien Guard's fonts at https://damieng.com/typography/zx-origins/. Please make sure you comply with Damien Guard's requirements to use the fonts (detailed in the website). You will find the CH8 files in the ZXSpectrum folder for each font.

If you are using CH82CHR for an English game you don't need to read the following: CH8 files only include characters from ASCII 32 to 127. Although those are enough for English, it's not the case for Spanish, French, German and Portuguese games, that require more characters. That means you will have to fix the output file yourself, using GCS or ZXPaintbrush to edit the output file. To help you with that, CH82CHR will include the standard content of the original DAAD-Ready character files into your output file, so for instance you can see 'Ñ' or 'à' in their places. Just they will have the original AD font. It's up to you to update the file to ressemble CH8 font style for those characters. In order for that to happen, you have to run ch82chr from DAAD Ready's folder TOOLS/CH82CHR, or just copy the contents of DAAD Ready charset assets folder (ASSETS\CHARSET) to the folder where ch82chr is. Otherwise, CH82CHR wonn't find the base file to copy characters, and all other characters not in the 32-127 range will be empty.
