# SD81 Booster
## User Manual

**Version 1.0**

---

> The SD81 Booster is an expansion interface for the Sinclair ZX81 computer that adds microSD card loading and saving, up to 512 KB of RAM, AY sound chip emulation, speech synthesis and many other features.

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Hardware Description](#2-hardware-description)
3. [Box Contents](#3-box-contents)
4. [Installation](#4-installation)
5. [microSD Card Preparation](#5-microsd-card-preparation)
6. [Getting Started](#6-getting-started)
7. [Loading and Saving from SD](#7-loading-and-saving-from-sd)
8. [File and Directory Management](#8-file-and-directory-management)
9. [Additional Features](#9-additional-features)
10. [Sound](#10-sound)
11. [Memory Management](#11-memory-management)
12. [Advanced BASIC Extensions](#12-advanced-basic-extensions)
13. [Program Examples](#13-program-examples)
14. [Error Codes](#14-error-codes)
15. [For Programmers](#15-for-programmers)
16. [Troubleshooting](#16-troubleshooting)
17. [Firmware Update](#17-firmware-update)
18. [Glossary](#18-glossary)
19. [Version History](#19-firmware-version-history)
20. [References](#20-references)

**Appendices**
- [Appendix A — Complete PLAY Command Reference](#appendix-a--complete-play-command-reference)
- [Appendix B — PEG Effects Generator Reference](#appendix-b--peg-effects-generator-reference)
- [Appendix C — Speech Synthesiser Dictionary](#appendix-c--speech-synthesiser-dictionary)
- [Appendix D — Memory Paging System](#appendix-d--memory-paging-system)
- [Appendix E — Chroma81 Interface Port (7FEFh)](#appendix-e--chroma81-interface-port-7fefh)
- [Appendix F — Superfast and Spectrum Modes](#appendix-f--superfast-and-spectrum-modes)
- [Appendix G — Audio Technical Reference: AY chip, VGM and allophones](#appendix-g--audio-technical-reference-ay-chip-vgm-and-allophones)

---

## Quick Start Guide

If you have just opened the box and want to get started as quickly as possible, follow these five steps:

**1. Prepare the microSD card**
- Format a microSD card in **FAT32**.
- Copy the **SYS** folder and all its contents to the root of the card. Without this folder the interface will not boot.
- Copy your `.P` files to the card, organised in folders if you wish.

**2. Connect the interface**
- Turn off the ZX81.
- Connect the SD81 Booster to the **rear expansion port** of the ZX81.
- Insert the microSD card into the interface slot.

**3. Power on and check**
- Turn on the ZX81. It should boot normally showing the `K` cursor.
- The **STAT** LED on the top panel should light up **solid green**.

**4. Load your first program**
- Type the following command and press `ENTER`:
```
LOAD FAST "NAME"
```
Replace `NAME` with the filename without the `.P` extension.

**5. Want to explore what's on the SD?**
```
LOAD *DIR
```

> For more details on any of these steps, refer to the corresponding sections of the manual.

---

## 1. Introduction

The **SD81 Booster** is an open hardware expansion interface for the Sinclair ZX81 that considerably extends the computer's original capabilities. Its main features include:

- **Loading and saving from microSD card** in `.P` format, the same used by the most popular emulators.
- **Up to 512 KB of RAM** via a memory mapper in 8 KB blocks.
- **AY-3-8910/12 sound chip emulation** with support for the `PLAY` command.
- **VGM file player** running in the background.
- **Speech synthesis** with audio samples stored in the microcontroller's internal memory.
- **Up to 128 user-definable characters**, with compatibility with the QuickSilva interface character definition mode.
- **Chroma81 interface compatibility**, providing RGB colour video output for the ZX81.
- **Full compatibility** with the original tape routines and the ZX Printer.

---

## 2. Hardware Description

The SD81 Booster is a compact enclosure that connects to the ZX81's rear expansion port. On its exterior you will find all the connectors and controls needed to make use of its features.

> **Note:** The images in this section are provisional 3D design renders and will be replaced with photographs of the final product before launch.

---

### 2.1 Right Side Panel

*(Image: right side view — RESET, QSILVA, MICRO-SD, USB)*

The right side panel presents, from left to right:

- **RESET button:** Resets the entire system (ZX81 + interface).
- **QSILVA button:** Toggles between the QuickSilva interface character set and the standard ZX81 ROM character set. Each press switches between one and the other.
- **MICRO-SD slot:** Insert the microSD card here with your programs, ROMs and system data.
- **USB-C port:** Has two uses:
  - **Firmware update:** in case a USB recovery is needed (see section 17).
  - **Debug console:** when connecting the USB-C cable to a computer, the operating system detects a serial port associated with the **CH340** chip. CH340 drivers may need to be installed if the system does not recognise it automatically. With any serial terminal program (PuTTY, Tera Term, minicom...) it is possible to monitor the interface's status and error messages in real time, which is very useful for diagnostics and development.

---

### 2.2 Left Side Panel and Rear Panel

*(Image: left side view — JOYSTICK DB9 connector)*

- **JOYSTICK connector (DB9):** Joystick port compatible with standard 9-pin joysticks (Atari/Commodore type). The mapping of joystick buttons to ZX81 keys is fully programmable via the `LOAD *JOY` command (see section 9.6).

*(Image: rear view — RGB SCART connector)*

- **RGB connector (SCART):** RGB colour video output compatible with the Chroma81 interface. Allows the ZX81 to be connected to monitors and televisions with SCART input for high quality colour image.

---

### 2.3 Top Panel — Status LEDs

*(Image: top view — STAT and SD LEDs)*

The top panel incorporates two indicator lights:

- **STAT LED** (status): indicates the general state of the interface through different colours and blink patterns (see table in section 2.4).
- **SD LED** (card access): blinks during read or write operations on the microSD card.

---

### 2.4 STAT LED Status Table

The **STAT** LED indicates the state of the interface through colour and blink combinations, organised in three phases:

**Firmware update:**

| Colour / Pattern | Meaning |
|-----------------|---------|
| Blue/Red blink | Error initialising SD card |
| Solid yellow | Updating firmware |
| White/Red blink | Update error |

**Boot:**

| Colour / Pattern | Meaning |
|-----------------|---------|
| Red blinking | Initialising serial port |
| Orange blinking | Waiting for FPGA |
| Blue/Red blink | Error initialising SD card |
| Orange/Red blink | Error writing ROM to RAM |
| Yellow blink | Initialising RTC |
| Solid green | System initialised successfully |

**Operation:**

| Colour / Pattern | Meaning |
|-----------------|---------|
| Solid green | Interface ready, Quick Silva mode off |
| Solid cyan | Interface ready, Quick Silva mode on |

---

## 3. Box Contents

When you open the SD81 Booster box you will find:

- 1× SD81 Booster interface
- 1× microSD card (pre-formatted)
- 1× CR2032 button battery (pre-installed in the interface)
- This user manual

> ⚠️ **Important:** If any of these items are missing or damaged, contact the seller before connecting the interface.

---

## 4. Installation

### 4.1 Before Connecting the Interface

- Make sure the ZX81 is **powered off** before connecting or disconnecting the interface.
- The SD81 Booster connects to the ZX81's **rear expansion port**.
- The interface is not compatible with devices that replace the ZX81's internal ROM.

### 4.2 Connection

1. Turn off the ZX81.
2. Align the SD81 Booster connector with the ZX81's rear expansion port. Make sure the pins are correctly aligned.
3. Push gently until the connector is fully inserted. Do not force the connection.
4. Insert the microSD card into the interface slot (see section 5).
5. Turn on the ZX81.

> ⚠️ **Warning:** Connecting or disconnecting the interface while the ZX81 is powered on may damage both the interface and the computer.

### 4.3 Installation Check

When powering on the ZX81 with the SD81 Booster correctly installed, the computer should boot normally showing the usual `K` cursor. The interface does not modify the system boot process.

To verify the interface is working, type the following command in BASIC and press `ENTER`:

```
LOAD *VER
```

> **Note:** The asterisk `*` is obtained by pressing `SHIFT + B`. The interface will display the installed firmware version.

If the computer freezes or does not boot correctly, disconnect the interface and make sure the connector is properly aligned.

---

## 5. microSD Card Preparation

### 5.1 Card Format

The SD81 Booster requires a microSD card formatted in **FAT32**. The card included in the box is already correctly formatted and prepared.

If you use your own card, follow these steps:

1. Format the card in FAT32:
   - **Windows:** Right-click on the card → Format → FAT32.
   - **macOS / Linux:** Use a disk formatting tool and select FAT32.
2. Copy the **SYS** folder and all its contents (included in the interface software package) to the root of the SD card. This folder contains essential files for the interface to operate.

> ⚠️ **Important:** The interface **does not support** exFAT or NTFS format. The **SYS folder is essential**: it contains the ROM files needed for the interface to boot. Without it, the interface will not work.

### 5.2 Permitted Characters in Filenames

Due to the ZX81 keyboard limitations, only the following characters may be used in file and folder names:

- Letters: `A` to `Z` (always uppercase when saving)
- Numbers: `0` to `9`
- Symbols: `. , ; $ ( ) = + -`
- The `/` character is used as a directory separator and **cannot** be used in filenames.

> **Tip:** Avoid ending a filename with a space or a period, as some operating systems may have trouble reading that file from a computer.

### 5.3 Recommended Folder Structure

The interface will search the SD card root by default. You can organise your programs in folders. The following structure is recommended:

```
/
├── AUTOEXEC.P        ← Program loaded automatically on boot
├── GAMES/
│   ├── MANIC.P
│   └── PACMAN.P
├── DEMOS/
└── SYS/              ← System folder (mandatory, do not modify)
```

### 5.4 The AUTOEXEC Program

If a file called `AUTOEXEC.P` exists in the SD root, it will be automatically loaded and executed when the `RUN` command is typed on a ZX81 with no program loaded. This is useful for creating custom startup menus.

---

## 6. Getting Started

### 6.1 Load Modes: SD or Tape

By default, the BASIC `LOAD` and `SAVE` commands work with **tape**, exactly as on a ZX81 without an interface. This ensures full compatibility with original tape software.

To use the SD card, you have two options:

**Option A — Activate SD mode permanently (until power-off):**

Type in BASIC:

```
LOAD FAST
```

> **Note:** The word `FAST` is obtained with `SHIFT + F`, not by typing the letters one by one.

From that point on, all `LOAD` and `SAVE` commands will use the SD by default, without needing to add `FAST` to each command. If in this mode you need to load from tape, use `LOAD SLOW "name"` to force audio loading for that specific operation.

To return to tape mode by default:

```
LOAD SLOW
```

> **Note:** `SLOW` is obtained with `SHIFT + D`. From that point on all `LOAD` and `SAVE` commands will use tape by default, and `FAST` must be explicitly added to load from SD.

> **Note:** The SD/tape mode can also be changed using `SAVE FAST` or `SAVE SLOW` without a filename, in the same way as `LOAD FAST` and `LOAD SLOW`. Both commands are equivalent for enabling or disabling SD mode.

**Option B — Load from SD without changing mode:**

You can force loading from SD at any time without changing the default mode by adding `FAST` to the load command (see section 7).

### 6.2 Loading Your First Program from SD

Once SD mode is active (or using `LOAD FAST`), loading a program is straightforward. Replace `NAME` with the name of your file (without the `.P` extension):

```
LOAD FAST "NAME"
```

---

## 7. Loading and Saving from SD

### 7.1 Load a Program

To load a program from the SD card:

```
LOAD FAST "NAME"
```

The interface will first try the name as given. If no file is found, it will automatically try adding the `.P` extension.

To load and run from a specific line number:

```
LOAD FAST "NAME" THEN GOTO 100
```

To load without auto-running:

```
LOAD FAST "NAME" THEN STOP
```

### 7.2 Save a Program

To save a program to the SD card:

```
SAVE FAST "NAME"
```

The interface always appends the `.P` extension to the saved file. For example, `SAVE FAST "MYPROG"` will create the file `MYPROG.P` in the current SD directory.

### 7.3 Load and Save Memory Blocks (Machine Code)

To load a block of data to a specific memory address:

```
LOAD FAST "NAME" CODE 30000
```

> Unlike the ZX Spectrum, the address after CODE is mandatory. Files on SD do not store the load address in a header.

> ⚠️ **Warning:** The FAST token is mandatory for CODE to work correctly. If `LOAD "NAME" CODE 30000` is used without FAST (even with SD mode active), the file will be loaded at the default address 16393 (4009h), ignoring the specified address. This is a firmware compatibility limitation.

To save a memory block to SD:

```
SAVE FAST "NAME" CODE 30000,2048
```

Where 30000 is the start address and 2048 is the length in bytes.

### 7.4 Always Load from Tape (Regardless of Mode)

If SD mode is active but you want to load a specific file from tape:

```
LOAD SLOW "NAME"
```

### 7.5 Game Compatibility Notes

Some games require special initialisation before loading. The most common cases are:

- **`LOAD *128C` before loading:** The game uses user-definable characters and needs 128-character mode activated.
- **`LOAD FAST` before loading:** Some games have multiple files. Running `LOAD FAST` without a name activates SD mode for all subsequent `LOAD` and `SAVE` commands, allowing the game to load its additional files automatically.

### 7.6 Recognised File Formats

The `LOAD FAST` command automatically detects the file type by extension and behaves differently accordingly:

| Extension | Behaviour |
|-----------|-----------|
| `.P` | Standard ZX81 BASIC program. The interface calculates the real program size from the system variables and discards trailing bytes at the end of the file. |
| `.81` | Same as `.P`. |
| `.P81` | Multi-program format. The interface skips the embedded filename before reading the data. |
| `.ROM` | **ROM file.** The interface loads the content at address 0 of the address space and resets the system. Control **does not return** to BASIC. See also the alternative ROM boot section. |
| `.WAV` | Uncompressed audio file (PCM). The interface plays it directly instead of loading it into memory. |
| Unknown or no extension | The file is loaded entirely into memory as-is, without any processing. |

> ⚠️ **Caution with `.ROM` files:** Loading a file with the `.ROM` extension via `LOAD FAST` causes an immediate system reset. Make sure the file contains a valid ROM before loading it, as a corrupted file could leave the system in an unrecoverable state until it is rebooted with another ROM.

---

## 8. File and Directory Management

### 8.1 View SD Contents

To list the files in the current directory:

```
LOAD *DIR
```

To list the files in a specific folder:

```
LOAD *DIR "GAMES"
```

Wildcards in Unix style can be used:
- `*` matches any number of characters (including none).
- `?` matches exactly one character.

> **Note:** `*` matches all files regardless of whether they have an extension or not. In contrast, `*.*` only matches files that contain a dot in their name. To list all files, use `*`, not `*.*`.

For example, to list only `.P` files:

```
LOAD *DIR "*.P"
```

> **Note:** If the listing does not fit on screen, `...` will appear on the bottom line. Press any key to continue, or SPACE to cancel.

### 8.2 Change Directory

To change to a subdirectory:

```
LOAD *CD "GAMES"
```

To go back to the root:

```
LOAD *CD "/"
```

To go up one level:

```
LOAD *CD ".."
```

To view the current directory:

```
LOAD *PWD
```

### 8.3 Create and Delete Folders

To create a subdirectory in the current directory:

```
LOAD *MD "FOLDER"
```

To remove an empty subdirectory:

```
LOAD *RD "FOLDER"
```

### 8.4 Delete, Rename and Copy Files

To delete a file:

```
LOAD *DEL "FILE.P"
```

To rename or move a file:

```
LOAD *MV "ORIGIN.P" TO "DEST.P"
```

To copy a file:

```
LOAD *CP "ORIGIN.P" TO "DEST.P"
```

> **Note:** `TO` is a BASIC token (`SHIFT + 4`), not typed letter by letter.

> **Note:** The date and time of the destination file is not preserved; the copied file will have the date and time of the moment of copying.

### 8.5 Free Space on SD

To view the available space on the card:

```
LOAD *FREE
```

> **Note:** This calculation may take several seconds to complete.

### 8.6 T81 Directories *(feature in alpha stage)*

> ⚠️ **Warning:** This feature is currently in **alpha stage**. It may contain bugs and its behaviour or interface could change in future versions. Not recommended for production use.

The SD81 Booster supports a special file format with the **`.T81`** extension that acts as a container for multiple ZX81 programs, similar to how a ZIP file contains several files.

To access the contents of a T81 file, use the `LOAD *CD` command as if it were a normal directory:

```
LOAD *CD "COLLECTION.T81"
```

To exit the T81 directory and return to the normal filesystem:

```
LOAD *CD "/"
```

> **Alpha stage limitations:** Write operations (`LOAD *DEL`, `LOAD *MD`, `LOAD *RD`, `LOAD *MV`, `LOAD *CP`, `SAVE`) are not supported inside a T81 directory and will return an error.

---

## 9. Additional Features

### 9.1 WAV Audio File Playback

The SD81 Booster can play uncompressed WAV audio files (PCM format, 8-bit mono, 11025 Hz) directly from the SD card. Detection is automatic by file extension:

```
LOAD FAST "SOUND.WAV"
```

This command plays the audio file synchronously (BASIC waits until playback finishes before continuing). The file must be located in the current directory of the SD card.

### 9.2 Real Time Clock — RTC Command

The SD81 Booster incorporates a real time clock that maintains the time even when the ZX81 is powered off, thanks to the CR2032 button battery.

**Read the current date and time:**

```
LOAD *RTC
```

**Store the value in a string variable:**

```
LOAD *RTC TO R$
```

**Set the date and time:**

Six input formats are supported:

| Format | Example |
|--------|---------|
| Date and time with hundredths | `LOAD *RTC="2025-11-10 13:48:00.00"` |
| Date and time | `LOAD *RTC="2025-11-10 13:48:00"` |
| Date only | `LOAD *RTC="2025-11-10"` |
| Time with hundredths | `LOAD *RTC="13:48:00.00"` |
| Time with seconds | `LOAD *RTC="13:48:00"` |
| Time (hours and minutes) | `LOAD *RTC="13:48"` |

### 9.3 RTC Battery Status — BAT Command

The SD81 Booster incorporates a **CR2032 button battery** that keeps the clock running when the ZX81 is powered off. This battery comes pre-installed from the factory and has an estimated life of several years under normal use conditions. When it runs out, it can be replaced by any standard CR2032 battery available from electronics shops.

The battery charge level can be checked from BASIC with the `LOAD *BAT` command.

**Display battery status on screen:**

```
LOAD *BAT
```

**Store the status in a string variable:**

```
LOAD *BAT TO B$
```

> **Tip:** If the clock frequently loses time when the computer is powered off, check the battery status with this command to see if it needs replacing.

### 9.4 Extended RAM Mode — RAM48 Command

The `LOAD *RAM48` command activates extended RAM mode of 48 KB, which extends the memory available for BASIC programs and data beyond the usual limits.

**Activate extended RAM mode:**

```
LOAD *RAM48
```

**Deactivate extended RAM mode:**

```
LOAD *RAM48 STOP
```

> **Note:** `STOP` is the token (`SHIFT + A`). Extended RAM mode is not compatible with video memory in the 32K–48K region while active.

### 9.5 Text File Display — THEN PRINT Command

The `LOAD THEN PRINT` command is the equivalent of the MS-DOS `TYPE` command or Linux `cat`: it displays the content of a text file directly on the ZX81 screen.

**Display a text file on screen:**

```
LOAD THEN PRINT "FILE"
```

**Send the content to the ZX Printer:**

```
LOAD THEN LPRINT "FILE"
```

**Redirect other command output to the ZX Printer:**

The `LOAD LPRINT` prefix can also be used with commands that normally display text on screen, to redirect their output directly to the ZX Printer:

```
LOAD LPRINT DIR
LOAD LPRINT DIR "*.P"
LOAD LPRINT FREE
LOAD LPRINT PWD
LOAD LPRINT VER
```

#### Built-in Help System

If an asterisk `*` is prepended to the filename, the interface automatically searches for a file with that name in the `/MAN/` folder on the SD and appends the `.TXT` extension. This allows implementing a help system similar to the Linux `man` command:

```
LOAD THEN PRINT "*PLAY"
```

This command would look for the file `/MAN/PLAY.TXT` on the SD and display its content on screen. You can create your own help files in that folder.

**Example — display game instructions:**

```
10 LOAD THEN PRINT "*INSTRUCTIONS"
```

### 9.6 Programmable Joystick — JOY Command

The SD81 Booster incorporates a DB9 joystick port whose button mapping is fully configurable. The `LOAD *JOY` command allows assigning a ZX81 key to each direction and the fire button of the joystick.

**Syntax:**

```
LOAD *JOY "up/dn/lt/rt/fire"
```

The configuration string contains exactly five characters, one for each joystick function in this order: up / down / left / right / fire.

**Example:**

```
LOAD *JOY "QAOP "
```

- Up → key Q
- Down → key A
- Left → key O
- Right → key P
- Fire → space key

---

## 10. Sound

### 10.1 PLAY Command

The SD81 Booster includes an AY-3-8910/12 sound chip emulator that supports the `PLAY` command with up to three simultaneous voices.

**Syntax:**

```
LOAD *PLAY "string1"
LOAD *PLAY "string1","string2","string3"
```

Each string controls one of the three AY channels (A, B, C). The string syntax follows the ZX Spectrum 128 `PLAY` command format.

**Examples:**

```
LOAD *PLAY "T120O45C5E5G9C"
```

For two simultaneous voices:

```
LOAD *PLAY "T1805C5E5G","O35CO45CO55C"
```

Background playback (does not block BASIC execution):

```
LOAD *PLAY "(5C5E5G)H",")"
```

For the complete reference of PLAY command parameters, see Appendix A.

### 10.2 VGM Player

The interface incorporates a VGM format file player that plays in the background while the ZX81 program continues running. Only VGMs containing AY-3-8910 or AY-3-8912 data are supported.

**Load and start playing a VGM file:**

```
LOAD *VGM "MUSIC"
LOAD *VGM THEN RUN
```

**Playback control:**

```
LOAD *VGM THEN PAUSE
LOAD *VGM THEN CONT
LOAD *VGM THEN STOP
```

**Loop mode:**

```
LOAD *VGMLOOP
LOAD *VGMLOOP STOP
```

### 10.3 PEG Effects Generator — Programmable Sound Effects

The PEG (Programmable Effects Generator) is a small virtual machine integrated in the interface that executes sound effect programs completely independently of the Z80, without consuming ZX81 CPU time.

The PEG accesses the AY chip registers directly and has up to three parallel execution threads, allowing several effects to play simultaneously.

> **Note:** The PEG is primarily aimed at developers. To create PEG programs it is recommended to use the PEG assembler included in the project repository. For a complete instruction set description, see Appendix B.

**Load a PEG program into memory:**

```
LOAD *PEG <address>,"<hexadecimal>"
```

Where `<address>` is the position in PEG memory (0–255) and `<hexadecimal>` is the instruction sequence in hexadecimal format. Each instruction occupies 4 hexadecimal characters (2 bytes).

**Start a PEG thread:**

```
LOAD *PEG THEN RUN <thread>,<address>
```

Where `<thread>` is the thread number (0, 1 or 2) and `<address>` is the start address of the PEG program.

**Stop, pause and resume a thread:**

```
LOAD *PEG THEN STOP <thread>
LOAD *PEG THEN PAUSE <thread>
LOAD *PEG THEN CONT <thread>
```

**Load a PEG program from SD (LOAD *PEB):**

In addition to inline loading with a hexadecimal string, it is possible to load a compiled PEG program directly from a binary file on the SD:

```
LOAD *PEB <address> "<name>"
```

Where `<address>` is the start position in PEG memory (0–255) and `<name>` is the filename on the SD. The file must have the `.PEB` extension (PEG binary); if no extension is specified, the interface adds it automatically.

**Example:**

```
LOAD *PEB 0 "EFECT"
LOAD *PEG THEN RUN 0,0
```

This example loads the file `EFECT.PEB` into PEG memory from position 0 and starts thread 0 from that same address.

> **Technical note:** The `.PEB` file is the result of assembling a `.PEG` source with the `peg.py` assembler, a Python script included in the `EXAMPLES/PEG/` folder of the project repository. To compile a source: `python peg.py efect.peg`

### 10.4 Speech Synthesis — SAY Command

The SD81 Booster incorporates a speech synthesiser that allows phrases to be spoken in English directly from BASIC. The synthesiser is based on the SP0256 chip phonemes, a speech synthesiser widely used at the time that formed part of classic interfaces such as the Currah MicroSpeech for the ZX Spectrum or The Voice for the Videopac G7000/Odyssey 2. The phoneme audio samples are stored in the microcontroller's internal memory, so no additional file is needed on the SD.

**Syntax:**

```
LOAD *SAY "phrase"
```

The synthesiser analyses the text string and attempts to build the pronunciation by combining English phonemes. The text should be written in English, in uppercase.

**Examples:**

```
LOAD *SAY "HELLO WORLD"
LOAD *SAY "ZX81 COMPUTER"
LOAD *SAY "ERROR 5"
```

Numbers are read in English automatically, from zero to billions.

**Background playback:**

To play speech without blocking BASIC execution, precede the text with an asterisk:

```
LOAD *SAY "*HELLO WORLD"
```

For the complete phoneme and word dictionary, see Appendix C.

---

## 11. Memory Management

### 11.1 Basic Concepts: Blocks and Pages

The SD81 Booster supports up to **512 KB of RAM**, organised as follows:

- The Z80's 64 KB address space is divided into **8 blocks** of 8 KB each (blocks 0–7).
- The interface's 512 KB RAM is divided into **64 pages** of 8 KB each (pages 0–63).
- Each block can be mapped to any page independently.

Initial page assignment:

| Block | Address range | Default page |
|-------|--------------|--------------|
| 0 | 0000–1FFF | 0 (ZX81 ROM, read only) |
| 1 | 2000–3FFF | 1 (Extension ROM) |
| 2 | 4000–5FFF | 2 (ZX81 RAM) |
| 3 | 6000–7FFF | 3 (ZX81 RAM mirror) |
| 4 | 8000–9FFF | 4 |
| 5 | A000–BFFF | 5 |
| 6 | C000–DFFF | 2 (mirror of block 2) |
| 7 | E000–FFFF | 3 (mirror of block 3) |

### 11.2 MAP Command

**Map a page to a block:**

```
LOAD *MAP <block>,<page>
```

Where `<block>` is 0–7 and `<page>` is 0–63.

**Read the current page for a block:**

```
LOAD *MAP <block> TO <variable>
```

### 11.3 MC45 Mode — Machine Code in Blocks 4 and 5

By default, the ZX81 hardware prevents executing machine code in addresses above 32767 (8000h). The MC45 mode removes this restriction for the 32768–49151 range (blocks 4 and 5).

> ⚠️ **Important:** This mode is implemented by short-circuiting a Z80 pin. The interface already includes an internal 680Ω resistor that protects the CPU. Even so, if you know your Z80 is CMOS type, it is advisable to also make the internal modification to the ZX81 for additional protection.

**Activate MC45 mode:**

```
LOAD *MC45
```

**Deactivate MC45 mode:**

```
LOAD *MC45 STOP
```

> **Limitation:** While MC45 mode is active, the display file cannot be in the 8000h–BFFFh region, which means BASIC programs larger than 16 KB cannot be loaded or written in this mode.

### 11.4 Boot with Alternative ROM

If the SD card contains files `/SYS/0.ROM`, `/SYS/1.ROM`, etc., up to `/SYS/9.ROM`, holding down the corresponding number key during boot will load that ROM and reset the machine.

The load happens when the number key is **released**.

### 11.5 User-Definable Characters (128C / 64C)

**Activate 128-character mode:**

```
LOAD *128C
```

**Return to standard 64-character mode:**

```
LOAD *64C
```

In 128-character mode, the characters are defined in the memory range 15360–16383 (3C00h–3FFFh). To modify a character, use `POKE` to write the 8 bytes that define its graphic pattern.

To restore the original ROM character set after modification:

```
LOAD *LDIR 7680,15360,512
LOAD *LDIR 7680,15872,512
```

> **Note:** Activating 128-character mode is incompatible with the HRG internal character generator (see section 10.6). Both modes cannot be active simultaneously.

---

#### Example: Spectrum-style boot screen

The following program illustrates the use of 128-character mode to load an alternative character set from the SD and display a screen in ZX Spectrum style:

```basic
   5 LOAD *128C
  20 LOAD FAST "SPEC-81-128.BIN" CODE 15360
  30 CLS
  35 POKE 16418,0
  40 PRINT AT 23,1;CHR$ 8;" 1982 S[INCLAIR] R[ESEARCH] L[TD]."
  45 POKE 16418,2
  50 IF INKEY$="" THEN GOTO 50
```

> **Note:** Texts in brackets indicate **inverse video**: `S[INCLAIR]` means the S is normal and `INCLAIR` is in inverse video; `R[ESEARCH]` means R is normal and `ESEARCH` is in inverse video; `L[TD]` means L is normal and `TD` is in inverse video. To enter characters in inverse video on the ZX81, press `SHIFT + 9` before each character. `CHR$ 8` corresponds to the ZX81 grid graphic character (character code 8, the © symbol in the Spectrum character set).

---

## 12. Advanced BASIC Extensions

This section covers additional BASIC extension commands of the SD81 Booster oriented primarily towards programming: string manipulation, memory access, input/output port communication, and directory access from a program.

### 12.1 String Manipulation

**Invert all characters in a string variable (flip bit 7):**

```
LOAD *INV A$
```

**Force characters to inverse video (set bit 7):**

```
LOAD *BOLD A$
```

String slices are supported: `LOAD *INV A$(2 TO 7)`.

**Load hexadecimal byte sequences into memory:**

```
LOAD *HEX 30000,"0A014020"
```

### 12.2 Memory Block Copy and Fill

**Copy bytes in ascending order:**

```
LOAD *LDIR <source>,<dest>,<count>
```

**Copy bytes in descending order:**

```
LOAD *LDDR <source>,<dest>,<count>
```

These are direct interfaces to their machine code counterparts and have the same caveats including overlapping source and destination behaviour.

### 12.3 Machine Code Execution

**Execute a machine code routine (LOAD USR):**

```
LOAD USR <address>
```

Equivalent to RAND USR but with three important advantages:

- Does not modify the random number generator.
- The routine is called from the top level of BASIC, leaving the alternate registers BC', DE' and HL' available and the stacks clean.
- The rest of the line is not parsed syntactically, allowing the routine to perform its own parameter parsing via RST 18h and RST 20h.

Upon entry to the routine, the BC register contains the address called.

> **Limitation with numeric literals:** If the routine uses the ROM's SCANNING routine to parse parameters, expressions with direct numeric literals (e.g. USR 40000) will not work correctly. Use `VAL "number"` or `CODE "character"` as a workaround: for example, `USR VAL "40000"` instead of `USR 40000`.

### 12.4 Input/Output Port Access

**Write to a port (*OUT):**

```
LOAD *OUT <port>,<value>
```

**Read from a port (*IN):**

```
LOAD *IN <port> TO <variable>
```

> **Note:** `TO` is the BASIC token (`SHIFT + 4`), not typed letter by letter.

### 12.5 16-bit Memory Access

**Read a 16-bit value from memory (LOAD PEEK):**

```
LOAD PEEK <address> TO <variable>
```

Reads two consecutive bytes from memory starting at `<address>` and stores them as a 16-bit value in `<variable>`.

**Write a 16-bit value to memory (LOAD THEN POKE):**

```
LOAD THEN POKE <address>,<value16>
```

Writes a 16-bit value to two consecutive bytes starting at `<address>`.

**Set the upper memory limit for BASIC (LOAD THEN CLEAR):**

```
LOAD THEN CLEAR <address>
```

Sets the last RAM address available for BASIC. Unlike the standard `CLEAR` command, this **does not clear variables**; it only clears the GOSUB stack. Use a separate `CLEAR` if you also want to clear variables.

### 12.6 Directory Access from a Program

These commands allow reading the content of an SD directory from within a BASIC program, useful for building file selection menus.

**Open a directory for reading:**

```
LOAD *OPENDIR <path>
```

The string is interpreted as a full path and/or wildcard mask. A maximum of 512 entries can be retrieved.

**Read a directory entry:**

```
LOAD *ROW <number> TO <string-variable>
```

Where `<number>` is the row number (starting at 1) and `<string-variable>` is a string variable. The first row is 1. Out-of-range rows return an empty string.

---

## 13. Program Examples

This section contains example programs that illustrate the use of the SD81 Booster's main features.

> **Note about listing format:** Texts in brackets indicate **inverse video**. For example, `S[INCLAIR]` means the `S` is a normal character and `INCLAIR` is in inverse video. To enter characters in inverse video on the ZX81, press `SHIFT + 9` before each character. `CHR$ 8` corresponds to the ZX81 grid graphic character (code 8).

---

### 13.1 Real Time Clock (RTC)

Demonstrates three clock adjustment formats: full date and time, date only and time only.

```basic
  10 LET A$="2025-11-10 13:48:00.00"
  15 LOAD *RTC
  16 PRINT
  20 LOAD *RTC=A$
  25 LOAD *RTC
  26 PRINT
  30 LOAD *RTC="2026-11-10"
  35 LOAD *RTC
  36 PRINT
  40 LOAD *RTC="12:20"
  45 LOAD *RTC
  46 PRINT
  50 LOAD *RTC="13:20:35"
  55 LOAD *RTC
  56 PRINT
```

**Explanation:** Displays the current time (line 15), then adjusts it via a string variable (line 20), then changes only the date (line 30), then only the time in short format (line 40) and finally with hours, minutes and seconds (line 50). After each adjustment it prints the result to verify it.

---

### 13.2 RTC Battery Status (BAT)

```basic
  10 LOAD *BAT TO A$
  20 PRINT A$
```

**Explanation:** Reads the real time clock battery status and displays it on screen.

---

### 13.3 MC45 Mode Check

Checks whether machine code mode in blocks 4 and 5 is active by loading a small assembly routine and executing it:

```basic
  10 LOAD *HEX 40000,"010203C9"
  20 IF USR 40000=770 THEN GOTO 100
  30 PRINT "MC45 INACTIVE"
  40 STOP
 100 PRINT "MC45 ACTIVE"
```

**Explanation:** Loads a Z80 routine at address 40000 (blocks 4-5) that returns the value of BC on exit (`C9` = RET). If MC45 is not active, the instructions in that area will not execute correctly and the value returned will not be 770. If MC45 is active, the routine executes correctly and jumps to line 100.

---

### 13.4 Superfast Mode — Speed Demonstration

Visually compares the refresh speed in standard ZX81 SLOW mode versus the SD81 Booster Superfast mode:

```basic
   4 SLOW
   5 PRINT "ZX81 SLOW MODE"
   6 PAUSE 250
   7 POKE 2045,85
   8 POKE 16418,0
   9 CLS
  10 GOSUB 1000
  15 CLS
  20 POKE 2045,170
  30 PRINT "SD81-BOOSTER SUPER FAST MODE"
  31 PAUSE 250
  35 CLS
  36 FAST
  37 GOSUB 1000
  40 GOTO 40
  75 POKE 1024,2
  76 POKE 1024,3
  77 POKE 1024,4
1000 PRINT "[CHR$ 0]123456789ABCDEFGHIJKLMNOPQRSTUV";
1010 FOR N=1 TO 22
1020 PRINT "0123456789ABCDEFGHIJKLMNOPQRSTUV";
1030 NEXT N
1040 PRINT "0123456789ABCDEFGHIJKLMNOQRSTUV[CHR$ 0]";
1050 RETURN
2000 PRINT "[CHR$ 0]123456789ABCDEFGHIJKLMNOPQRSTUV";
2010 FOR N=1 TO 22
2020 PRINT "0123456789ABCDEFGHIJKLMNOPQRSTUV";
2030 NEXT N
2040 PRINT "0123456789ABCDEFGHIJKLMNOQRSTUV[CHR$ 0]";
2050 RETURN
```

> **Note:** `[CHR$ 0]` in lines 1000, 1040, 2000 and 2040 represents character 0 in inverse video as seen in the original listing.

---

### 13.5 Spectrum Image Loading

Loads a Spectrum format image (`.SCR`) from the `/SCR/` folder on the SD and displays it using the interface's HiRes Spectrum mode:

```basic
   5 LOAD *CD "/SCR"
  15 LET HFILE=32768
  20 POKE 2044,HFILE/256
  25 POKE 2045,172
  30 LOAD *OUT 32751,39
  40 LOAD *OUT 251,6
  50 LOAD FAST "Z.SCR" CODE HFILE
 190 IF INKEY$="" THEN GOTO 15
 200 POKE 2045,85
 210 LOAD *OUT 32751,0
```

**Line by line explanation:**

- **Line 5:** Changes to the `/SCR` directory on the SD.
- **Line 15:** Defines `HFILE=32768` (8000h), start of block 4.
- **Line 20:** Writes the high byte of the screen file address to the interface register.
- **Line 25:** Activates Superfast HiRes Spectrum mode (`POKE 2045,172`).
- **Lines 30-40:** Configures border colour registers via the interface output port.
- **Line 50:** Loads the file `Z.SCR` at address `HFILE` (32768).
- **Line 190:** Waits for any key press; on press returns to line 15 to reload.
- **Line 200:** Deactivates Superfast mode.
- **Line 210:** Restores the output register to 0.

---

## 14. Error Codes

When an error occurs, the ZX81 displays a code at the bottom of the screen followed by the line number where it occurred. The error codes related to the SD81 Booster are:

| Code | Description |
|------|-------------|
| A | Invalid argument. A command has been called with an incorrect parameter. |
| D | Break. The SPACE key was pressed during a directory listing. |
| G | File or directory not found. Check the exact name with `LOAD *DIR`. |
| H | SD card access error. Check the card is correctly inserted and formatted in FAT32. |
| J | Write error. The SD card may be full (`LOAD *FREE`) or write-protected. |

> **Note:** The standard ZX81 error codes (B, C, E, F, etc.) are not affected by the SD81 Booster and retain their original meaning.

---

## 15. For Programmers

This section covers the technical details of the SD81 Booster interface for developers who want to use its features from machine code or who need to understand its internal operation.

### 15.1 Expansion ROM Map

The SD81 Booster includes an expansion ROM that starts at address 8192 (2000h). Here is a map of its initial contents:

| Address (hex) | Content |
|--------------|---------|
| 2000 | String "SD81" in ZX81 character encoding. |
| 2004 | Version byte. Top 4 bits = major version, bottom 4 bits = minor. |
| 2005 | Routine that gets the return address of the caller in HL. |
| 2006 | Routine that executes JP (HL) when called. |
| 2007 | GetMCUVersion — Input: nothing. Sets B=0 and C=MCU version. |
| 200A | WaitClkDiff — Waits for the clock bit to differ from bit 7 of C. |
| 200D | WaitClkEq — Like WaitClkDiff but waits for the clock to equal bit 7 of C. |
| 2010 | OutWaitDiff — Sends A to the data port then waits for clock change. |
| 2013 | OutWaitEq — Like OutWaitDiff but waits for clock to equal. |
| 2016 | WaitDiffBrk — Like WaitClkDiff but allows pressing BREAK to interrupt. |
| 2019 | WaitEqBrk — Like WaitDiffBrk but waits for clock to equal. |
| 201C | SendString — Waits for clock change then sends a string to the MCU prefixed by length. |
| 201F | SendStrLoop — Sends B bytes to the MCU starting at DE without waiting for clock changes. |
| 2022 | ReportStatus — Reads a byte from the MCU. If non-zero, reports a BASIC error. |
| 2025 | PrintBPaged — Prints a character; if no room, shows "..." and waits for a key. |
| 2028 | Cmd64C — Switches to normal 64-character mode. Same as `LOAD *64C`. |
| 202B | Cmd128C — Switches to 128-character mode. Same as `LOAD *128C`. |
| 202E | GetPhase — Gets the current clock status in bit 7 of C. |
| 2031 | GetData — Reads the incoming data port from the MCU. Result in A. |
| 2034 | SD81_RESET — Entry point for a RESET. |
| 2037 | SD81LOADCMD — Entry point for the extended LOAD command. |
| 203A | SD81SAVECMD — Entry point for the extended SAVE command. |
| 203D | SD81RUNCMD — Entry point for the extended RUN command. |

### 15.2 I/O Ports and MCU Protocol

The SD81 Booster uses three I/O ports:

| Port | Function |
|------|---------|
| E7h | Memory mapper |
| A7h | MCU data port (read and write). Bit 0 on read: VSYNC interrupt status (1 = vertical blanking period active, screen painted). |
| AFh | MCU control port (write=MCU reset; bit 7 on read=clock bit) |

#### VSYNC Synchronisation

The bit 0 of port A7h reflects the status of the vertical sync interrupt (VSYNC). This allows the CPU to wait for the start of screen refresh precisely, without needing interrupts or the HALT command.

On the ZX Spectrum, many games used HALT or an IM1/IM2 interrupt routine to synchronise with the vertical scan. On the SD81 Booster this mechanism replaces that functionality and is especially useful when porting Spectrum games.

**Example VSYNC wait loop in Z80 assembly:**

```asm
WAIT_VSYNC:
        in      a,(0A7h)        ; read MCU data port
        and     01h             ; isolate bit 0 (VSYNC)
        jr      nz,WAIT_VSYNC   ; wait until VSYNC = 0
WAIT_VSYNC2:
        in      a,(0A7h)
        and     01h
        jr      z,WAIT_VSYNC2   ; wait for edge (VSYNC = 1)
        ; Synchronised with the start of the frame
```

> ⚠️ **Warning:** Writing any value to port AFh causes a software reset of the MCU. This should not be done while the MCU is saving or copying a file.

The communication is synchronised via the clock bit (bit 7 of port AFh), which is toggled with each read or write on A7h. The Z80 must wait for the bit to change before the next operation.

**Example — GETBYTE command (index 16 of MCU internal memory):**

```asm
        in      a,(0AFh)        ; read initial clock bit
        ld      c,a
        ld      a,20h           ; GETBYTE code
        out     (0A7h),a        ; send command
WAIT1:  in      a,(0AFh)
        xor     c
        jp      p,WAIT1         ; wait for different clock
        ld      a,16            ; index
        out     (0A7h),a        ; send parameter
WAIT2:  in      a,(0AFh)
        xor     c
        jp      m,WAIT2         ; wait for equal clock
        in      a,(0A7h)        ; read response — result in A
```

### 15.3 Memory Mapper (port E7h)

In simple paging mode (up to 256 KB), the 8 bits written to port E7h are interpreted as follows:

| Bits | Function |
|------|---------|
| D2, D1, D0 | Block number (0–7) |
| D7, D6, D5, D4, D3 | Page number (0–31) |

To access all 64 pages of full mode (512 KB), use the `OUT (C),r` instruction with the page number in B and the block number in another register. If A contains the block number (0–7) and B the page (0–63):

```asm
        ld      c,0E7h          ; mapper port
        out     (c),a           ; select page B in block A
```

The change between simple and full mode is done via an MCU command (FULLPAGING and HALFPAGING commands, see section 15.5).

### 15.4 Debug Console (USB-C Port)

The USB-C port on the interface also works as a **serial debug port**. When connected to a computer, the operating system detects a virtual serial port associated with the **CH340G** chip. On some systems the CH340 drivers may need to be installed.

**Connection parameters:**

| Parameter | Value |
|-----------|-------|
| Speed | 115200 baud |
| Data bits | 8 |
| Parity | None |
| Stop bits | 1 |
| Flow control | None |

With any serial terminal program (PuTTY on Windows, minicom on Linux, CoolTerm on macOS) it is possible to monitor in real time the messages generated by the MCU, including: boot progress, SD access errors, firmware update progress, and debug messages from the filesystem, VGM, PEG and speech synthesis.

> **Note:** The production firmware emits basic status messages via the serial port. Recompiling the firmware with the `DEBUG` macro active produces much more detailed output, useful for advanced diagnostics and development.

### 15.5 Complete MCU Command Table

Commands are sent to the MCU by writing their code to data port A7h, following the clock bit synchronisation protocol described in section 15.2. All string parameters are preceded by a byte with the length.

#### Error codes returned by commands

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | File or directory not found |
| 2 | Not a directory |
| 3 | Operation error (could not create/delete/rename) |
| 4 | File or directory already exists |
| 5 | File too large |
| 6 | Could not create destination file |
| 7 | Write error |
| 8 | Partial read error |
| 12 | No VGM file open |
| 13 | Operation not permitted in T81 directory |
| 14 | Invalid joystick parameter |

#### System commands

| Code | Name | Parameters sent | Response | Description |
|------|------|----------------|----------|-------------|
| 0 | NOP | — | — | No operation. Only synchronises the clock. |
| 1 | VERSION | — | 1 byte: firmware version | Returns the MCU version. Same format as byte at 2004h. |
| 32 | GETBYTE | 1 byte: index (0–255) | 1 byte: value | Reads a byte from MCU internal memory. Indices 0–127: volatile system variables. Indices 128–255: EEPROM (persistent). |
| 33 | SETBYTE | 1 byte: index + 1 byte: value | — | Writes a byte to internal memory. Same division as GETBYTE. |

#### Filesystem commands

| Code | Name | Parameters sent | Response | Description |
|------|------|----------------|----------|-------------|
| 2 | PWD | — | String + EOT + status | Returns the current directory in ZX81 encoding. |
| 3 | CD | String: path | Status | Changes the current directory. Accepts absolute (/) and relative paths. |
| 4 | DEL | String: filename | Status | Deletes a file from the current directory. No wildcards. |
| 5 | MKDIR | String: name | Status | Creates a subdirectory. |
| 6 | RMDIR | String: name | Status | Removes an empty directory. |
| 7 | MOVE | String: source + String: dest | Status | Renames or moves a file. |
| 8 | COPY | String: source + String: dest | Status | Copies a file. Date/time is not preserved. |
| 9 | LOAD | String: filename | 2B length + N bytes + Status | Loads a file. .P/.81: calculates real size. .ROM: loads at address 0 and resets. .WAV: plays audio. |
| 10 | SAVE | String: name + 2B length + N bytes | Status | Saves a data block as a file on the SD. |
| 11 | TYPE | String: name | String char by char + EOT + Status | Sends the content of a text file. With * searches in /MAN/ with .TXT extension. |
| 12 | DIR | String: path/wildcard | String char by char + EOT + Status | Lists the directory, including file sizes. |
| 14 | FREE_TXT | — | String + EOT + Status | Returns SD total and free space as text. |
| 15 | FREE | — | 4B total + 4B free + Status | Space total and free in KB as 32-bit little-endian values. |
| 16 | OPENDIR | String: path/wildcard | Status | Opens a directory and builds an internal array (max. 512 entries). |
| 17 | GETROWLEN | 2B: index | 1B: length + Status | Length of the name of entry index in the array opened with OPENDIR. |
| 18 | GETROW | 2B: index | 1B: length + N bytes + Status | Name of entry index in ZX81 encoding. Index 0 = current directory. Directories between < and >. |

#### Hardware control commands

| Code | Name | Parameters sent | Response | Description |
|------|------|----------------|----------|-------------|
| 19 | ENABLE_MC45 | — | — | Activates MC45 mode (machine code in blocks 4 and 5). |
| 20 | DISABLE_MC45 | — | — | Deactivates MC45 mode. |
| 21 | JOY | String: 5 ZX81 key codes | Status | Configures joystick mapping: up, down, left, right, fire. |
| 27 | SEL_128CHARS | — | — | Activates 128-character mode. Equivalent to LOAD *128C. |
| 28 | SEL_64CHARS | — | — | Activates standard 64-character mode. Equivalent to LOAD *64C. |
| 29 | FULLPAGING | — | — | Activates full paging mode (512 KB, 64 pages). |
| 30 | HALFPAGING | — | — | Activates simple paging mode (256 KB, 32 pages). |
| 48 | ENABLE_48K | — | — | Activates 48 KB extended RAM mode. Equivalent to LOAD *RAM48. |
| 49 | DISABLE_48K | — | — | Deactivates extended RAM mode. Equivalent to LOAD *RAM48 STOP. |

#### Speech synthesis commands

| Code | Name | Parameters sent | Response | Description |
|------|------|----------------|----------|-------------|
| 22 | BINARY_SAY | String: allophone bytes | Status | Plays allophones in binary format. Synchronous (blocks until finished). |
| 23 | SAY | String: ASCII text | Status | Converts text to phonemes and plays it. With * as first character: background. Equivalent to LOAD *SAY. |

#### AY / sound commands

| Code | Name | Parameters sent | Response | Description |
|------|------|----------------|----------|-------------|
| 24 | AY_SET_REG | 1B: register (0–15) + 1B: value | — | Writes a value to an AY emulator register. |
| 25 | AY_GET_REG | 1B: register (0–15) | 1B: value | Reads the current value of an AY emulator register. |
| 26 | AY_PLAY | String: ch A + String: B + String: C | Status | Plays up to three simultaneous PLAY strings. With * in ch A: background. Equivalent to LOAD *PLAY. |

#### VGM commands

| Code | Name | Parameters sent | Response | Description |
|------|------|----------------|----------|-------------|
| 34 | PLAY_VGM | String: filename | Status | Opens and starts playing a VGM file in background. Adds .vgm if no extension. |
| 35 | STOP_VGM | — | — | Stops VGM playback and resets the AY emulator. |
| 36 | PAUSE_VGM | — | — | Pauses VGM playback. |
| 37 | CONT_VGM | — | — | Resumes paused VGM playback. |
| 38 | LOOP_VGM | 1B: mode (0=no loop, 1=loop) | — | Sets the VGM player loop mode. |

#### PEG commands

| Code | Name | Parameters sent | Response | Description |
|------|------|----------------|----------|-------------|
| 40 | LOAD_PEG | 1B: address + String: hex data | — | Loads PEG instructions into generator memory. 2 bytes per instruction in little-endian. |
| 41 | PLAY_PEG | 1B: thread (0–2) + 1B: address | — | Starts execution of a PEG program on the indicated thread. |
| 42 | STOP_PEG | 1B: thread (0–2) | — | Stops and resets the indicated PEG thread. |
| 43 | PAUSE_PEG | 1B: thread (0–2) | — | Pauses the indicated PEG thread. |
| 44 | CONT_PEG | 1B: thread (0–2) | — | Resumes the indicated PEG thread. |
| 45 | SDLOAD_PEG | String: name + 1B: address | Status | Loads a .PEB file from SD into PEG memory. Maximum size: 512 bytes. |

#### RTC and battery commands

| Code | Name | Parameters sent | Response | Description |
|------|------|----------------|----------|-------------|
| 50 | RTC | String: date/time (or empty to read) | If read: String ZX81 + Status. If write: Status | Without params: returns date/time. With params: sets the clock. Formats: YYYY-MM-DD HH:MM:SS.CC / YYYY-MM-DD HH:MM:SS / YYYY-MM-DD / HH:MM:SS.CC / HH:MM:SS / HH:MM. |
| 52 | BAT | — | 5 ASCII bytes + Status | Returns RTC battery level as a 5-character string in format V.mmm (ZX81 encoding). |

---

## 16. Troubleshooting

### 16.1 Interface Does Not Boot or ZX81 Freezes

| Symptom | Solution |
|---------|---------|
| ZX81 shows nothing on power on | Check the interface is correctly inserted in the expansion port. Disconnect and reconnect with the ZX81 powered off. |
| STAT LED does not light up | Check the SD card is inserted and contains the SYS folder with its complete contents. Without it the interface will not boot. |
| STAT LED blinks Blue/Red during boot | Error initialising the SD card. Check it is correctly inserted and formatted in FAT32. |
| STAT LED blinks Orange/Red during boot | Error writing ROM to RAM. Check the SYS folder contains the necessary ROM files. |
| STAT LED blinks Orange during boot | MCU is waiting for FPGA response. If the blink does not stop, it may indicate a hardware problem. |
| Blank screen or noise | Make sure the expansion connector pins are not bent or dirty. |
| ZX81 boots but interface commands do not work | Check the firmware version with `LOAD *VER`. To update, copy `firmware.bin` to the SD root and power on the ZX81. |

### 16.2 microSD Card Problems

| Symptom | Solution |
|---------|---------|
| Error H when trying to load | Check the SD is correctly inserted. Remove and reinsert it. If the error persists, reformat the card in FAT32. If it continues failing, the SD card may be defective. |
| SD not recognised | Check it is formatted in FAT32 (not exFAT or NTFS). |
| Error G when loading a program | The file does not exist with that name. Use `LOAD *DIR` to see exact names. |
| Error J when saving | The SD card is full. Use `LOAD *FREE` to check available space. |

### 16.3 Clock Loses Time on Power Off

The real time clock is powered by the **CR2032** button battery. If the clock systematically loses time when the ZX81 is powered off, the battery probably needs replacing.

Check the charge level with:

```
LOAD *BAT
```

If the voltage is below approximately 2.5V, replace the battery with a new CR2032. The battery is located on the interface board and can be removed with a thin flat tool.

### 16.4 Joystick Does Not Respond

| Symptom | Solution |
|---------|---------|
| Joystick does nothing | Configure the mapping with `LOAD *JOY "QAOP "` (or another mapping depending on the game) before launching the program. |
| Only some directions work | Check the configuration string has exactly 5 characters. |
| Joystick moves but does not fire | Check the fifth character of the JOY string corresponds to the game's fire key. |

### 16.5 Sound Does Not Work

| Symptom | Solution |
|---------|---------|
| No sound with `LOAD *PLAY` | Check the television or monitor is connected to the interface's SCART connector and that the SCART audio channel is not muted. |
| Speech is not intelligible | Try short phrases in English. Spell words phonetically if the result is not satisfactory. |
| VGM does not play | Check the file is a VGM with AY chip data only. VGMs with other chips are not compatible. |

### 16.6 Firmware Update Errors

| Symptom | Solution |
|---------|---------|
| STAT LED blinks Blue/Red on boot with `firmware.bin` on SD | Error initialising SD card before update. Remove the SD, check FAT32 format and try again. |
| STAT LED blinks White/Red after trying to update | Error during update. The `firmware.bin` file remains on the SD. Check the file is not corrupted and power on the ZX81 again to retry. |
| STAT LED stays solid yellow indefinitely | Update is in progress. Wait at least 2 minutes before considering there is a problem. Do not power off the ZX81. |
| After update the interface does not respond | Check with `LOAD *VER` that the version is correct. If the interface does not boot, follow the emergency USB recovery procedure described in section 17. |

### 16.7 Using the Debug Console as a Diagnostic Tool

When the STAT LED shows an error but the cause is not clear, the USB-C debug console can provide very valuable additional information.

**How to connect:**

1. Connect a USB-C cable between the interface and the computer.
2. Open a serial terminal program (PuTTY, Tera Term, minicom...) and connect to the CH340 COM/serial port with the parameters: **115200 baud, 8N1, no flow control**.
3. Power on the ZX81 with the interface connected.
4. Observe the messages that appear in the terminal during boot and normal operation.

The production firmware emits basic status messages that allow identifying which boot phase fails, whether the SD card is recognised correctly, the result of firmware updates and other relevant events.

> **Tip for developers:** Recompiling the firmware with the `DEBUG` macro active produces much more detailed output, including flash operation progress, AY register status, and the details of each command received from the Z80.

---

## 17. Firmware Update

The SD81 Booster has two independently updatable firmware components: the **microcontroller (MCU)** and the **FPGA**.

> ⚠️ **Important:** Do not interrupt the update process once started. An incomplete update may leave the interface in a non-operational state.

---

### 17.1 Microcontroller (MCU) Update

The SD81 Booster incorporates a **bootloader** that allows updating the firmware without external tools or special cables.

**Requirements:**
- Interface microSD card.
- `firmware.bin` firmware file, available in the project repository.

**Process:**

1. Download `firmware.bin` from the project repository.
2. Copy `firmware.bin` to the **root** of the microSD card (not in any subfolder).
3. Insert the card in the interface with the ZX81 **powered off**.
4. Power on the ZX81. The bootloader will automatically detect the file, perform the update and delete it from the SD when finished.

> ⚠️ **Do not power off the ZX81 or remove the SD card during the update.**

Verify the installed version with:

```
LOAD *VER
```

**Emergency USB recovery:**

If the interface becomes inoperative, there is a USB-C recovery procedure for advanced users that requires opening the enclosure and manipulating jumper **JP7**. Detailed instructions are available in the project repository:

[https://codeberg.org/Retrostuff/SD81-Booster](https://codeberg.org/Retrostuff/SD81-Booster)

---

### 17.2 FPGA Update

The FPGA (Xilinx Spartan-6 XC6SLX9) loads its configuration on each boot from an auxiliary SPI flash memory (25Q128). The update consists of writing an MCS file to that flash via JTAG, using the **Xilinx ISE iMPACT** tool and a **Xilinx Platform Cable USB**. This process is aimed exclusively at **technically specialised personnel**. Complete instructions and necessary files are available in the project repository.

> ⚠️ **Warning:** Incorrect programming of the SPI flash may permanently render the interface inoperative.

---

## 18. Glossary

| Term | Definition |
|------|-----------|
| **Allophone** | Minimal speech sound unit used by the speech synthesiser. The SD81 Booster uses the SP0256 chip allophones. |
| **Block** | 8 KB division of the Z80 address space. The SD81 Booster divides the Z80's 64 KB into 8 blocks (0–7). |
| **FPGA** | Programmable logic circuit (Xilinx Spartan-6 XC6SLX9) that implements in hardware the video logic, memory mapper and other interface functions. |
| **FAT32** | Filesystem required by the interface's microSD card. Incompatible with exFAT and NTFS. |
| **FAST** | ZX81 BASIC token (SHIFT+F). On the SD81 Booster, activates SD loading/saving mode. |
| **Screen file (HFILE)** | Memory block containing the screen data in Superfast modes. |
| **HRG** | High Resolution Graphics. ZX81 high resolution mode. |
| **MCU** | Microcontroller. The chip that manages the SD, sound, RTC and communication with the Z80. |
| **Page** | 8 KB division of the interface RAM. The 512 KB are divided into 64 pages (0–63) that can be mapped to any block. |
| **PEG** | Programmable Effects Generator. Virtual machine for playing sound effects in the background without using the ZX81 CPU. |
| **RTC** | Real Time Clock. Real time clock incorporated in the SD81 Booster, powered by a CR2032 battery. |
| **SLOW** | ZX81 BASIC token (SHIFT+D). On the SD81 Booster, activates tape (audio) loading/saving mode. |
| **SP0256** | General Instrument speech synthesiser chip, base of the SD81 Booster synthesiser. Also used in the Currah MicroSpeech and The Voice. |
| **Superfast** | Mode where the SD81 Booster hardware manages screen refresh, freeing the ZX81 CPU for other tasks. |
| **T81** | Container file format that groups multiple ZX81 programs. The interface can navigate its content as if it were a directory. *(alpha stage)* |
| **Token** | In ZX81 BASIC, each reserved word is stored as a single byte. Entered with SHIFT key combinations. |
| **VGM** | Video Game Music. File format for music that the SD81 Booster can play in the background using the AY emulator. |
| **Inverse video** | ZX81 display mode where background and character swap colours. Activated with SHIFT+9 before the character. |

---

## 19. Firmware Version History

| Version | Date | Main changes |
|---------|------|-------------|
| 1.0 | 2025 | First public release. |

> **Note:** This history will be updated with each new firmware version. Check the project repository for the complete changelog.

---

## 20. References

### The SD81 Booster Project

- **Official repository** (source code, firmware, schematics, technical documentation):
  [https://codeberg.org/Retrostuff/SD81-Booster](https://codeberg.org/Retrostuff/SD81-Booster)

- **Va de Retro** — Spanish retrocomputing forum where a previous version of the interface was announced:
  [https://www.va-de-retro.com/foros/portal](https://www.va-de-retro.com/foros/portal)

---

### Tools

- **STM32CubeProgrammer** — STM32 MCU programming tool, needed for USB recovery in emergencies:
  [https://www.st.com/en/development-tools/stm32cubeprog.html](https://www.st.com/en/development-tools/stm32cubeprog.html)

---

### Technical Reference Documentation

- **SP0256-AL2 speech synthesiser chip** (General Instrument) — datasheet for the chip on which the SD81 Booster speech synthesiser is based:
  [https://rarewaves.net/wp-content/uploads/2018/09/SP0256-AL2.pdf](https://rarewaves.net/wp-content/uploads/2018/09/SP0256-AL2.pdf)

- **Chroma81 interface** — documentation for the ZX81 colour interface whose functionality the SD81 Booster implements. The original link is no longer available; it can be found in web archives:
  `http://www.fruitcake.plus.com/Sinclair/ZX81/Chroma/ChromaInterface_Documentation.htm`

- **\.P and .P81 file format** — technical specification of the ZX81 program formats:
  [https://k1.spdns.de/Develop/Projects/zasm/Info/O80%20and%20P81%20Format.txt](https://k1.spdns.de/Develop/Projects/zasm/Info/O80%20and%20P81%20Format.txt)

- **VGM format specification** (*Video Game Music*) — file format for music used by the interface VGM player:
  [https://vgmrips.net/wiki/VGM_Specification](https://vgmrips.net/wiki/VGM_Specification)

---

### ZX81 ROM

The SD81 Booster includes a modified ROM based on the original ZX81 disassembly. Credits:

- **Geoff Wearmouth** — commented ZX81 ROM disassembly (preserved at archive.org):
  [https://web.archive.org/web/20150815035607/http://www.wearmouth.demon.co.uk/zx81.htm](https://web.archive.org/web/20150815035607/http://www.wearmouth.demon.co.uk/zx81.htm)

- **Tomaž Šolc** — preservation of the disassembly:
  [https://www.tablix.org/~avian/spectrum/rom/](https://www.tablix.org/~avian/spectrum/rom/)

---

### Project Credits

- **Hardware design and MCU firmware:** Alejandro Valero (wilco2009)
- **Z80 code / Modified ROM:** Pedro Gimeno (pgimeno)

---

## Appendix A — Complete PLAY Command Reference

### Duration Table

| Value | Name | Duration at 60 bpm |
|-------|------|-------------------|
| 1 | Semiquaver (1/4 crotchet) | 0.25 s |
| 2 | Dotted semiquaver | 0.375 s |
| 3 | Quaver (1/2 crotchet) | 0.5 s |
| 4 | Dotted quaver | 0.75 s |
| 5 | Crotchet | 1 s |
| 6 | Dotted crotchet | 1.5 s |
| 7 | Minim (2 crotchets) | 2 s |
| 8 | Dotted minim | 3 s |
| 9 | Semibreve (4 crotchets) | 4 s |
| 10 | Semiquaver triplet | 0.1667 s |
| 11 | Quaver triplet | 0.3333 s |
| 12 | Crotchet triplet | 0.6667 s |

### Complete Command Table

| Command | Function |
|---------|---------|
| `T<n>` | Sets tempo in bpm (60–240). Only effective in voice 1. Default: 120. |
| `O<n>` | Sets octave number (0–8). Default: 4. |
| `<n>` | Sets note/rest duration from that point (see duration table). |
| `-` | Ligature: ties two durations together (e.g. `4-3A` = 7/8 of a crotchet). |
| `C D E F G A B` | Plays the note in the current octave. |
| Inverse `C`..`B` | Plays the note in the next octave. |
| `$` | Flattens the next note. |
| `=` | Sharpens the next note. |
| `£` | Plays a rest. |
| `N` or space | Separator between numbers (e.g. `T60N3` or `T60 3`). |
| `V<n>` | Sets voice volume (0–15). |
| `W<n>` | Selects volume envelope effect (0–7). |
| `X<n>` | Sets envelope ramp time (0–65535; 6927 ≈ 1 second). |
| `U` | Enables envelope for the channel. |
| `M<n>` | Selects active channels and mode (1=A tone, 2=B tone, 4=C tone, 8=A noise, 16=B noise, 32=C noise). |
| `(`...`)` | Repeats an enclosed section once. |
| `)` without `(` | Repeats the whole string indefinitely. |
| `H` | Forces termination of the entire PLAY command. |

### Envelope Table

| W | Shape | Pattern |
|---|-------|---------|
| W0 | Decay then stay off | `\______` |
| W1 | Rise then stay off | `/\|_____` |
| W2 | Decay then stay on | `\|_____` |
| W3 | Rise then stay on | `/______` |
| W4 | Repeated decay | `\|\|\|\|` |
| W5 | Repeated rise | `/|/|/|/|` |
| W6 | Rise then decay, repeat | `/\/\/\/\` |
| W7 | Decay then rise, repeat | `\/\/\/\/` |

---

## Appendix B — PEG Effects Generator Reference

The PEG (Programmable Effects Generator) is a virtual machine integrated in the interface MCU. It executes programs asynchronously, accessing the AY registers directly to produce sound effects without consuming ZX81 CPU time.

### PEG Memory

- Memory space: 256 words (16-bit each).
- Maximum 3 simultaneous threads (0, 1, 2).
- Instructions are encoded as 16-bit words in big-endian order.

### Instruction Set

| Instruction | Encoding | Description |
|-------------|----------|-------------|
| `LD R,XX` | `0R XX` | Load register with 8-bit value |
| `ADD R,XX` | `1R XX` | Add 8-bit value to register |
| `LD V,XX` | `2R XX` | Load variable with 8-bit value (rest zeros) |
| `ADD V,XX` | `3R XX` | Add 8-bit value to variable |
| `LD R,R` | `40 RR` | Load register from another register |
| `LD R,V` | `41 RV` | Load register from variable |
| `LD V,R` | `42 VR` | Load variable from register |
| `LD V,V` | `43 VV` | Load variable from another variable |
| `ADD V,V` | `44 VV` | Add second variable to first |
| `SUB V,V` | `45 VV` | Subtract second variable from first |
| `ADC V,V` | `46 VV` | Add with carry |
| `SBC V,V` | `47 VV` | Subtract with carry |
| `NOT V,V` | `48 VV` | First var = bitwise NOT of second |
| `AND V,V` | `49 VV` | Bitwise AND |
| `OR V,V` | `4A VV` | Bitwise OR |
| `XOR V,V` | `4B VV` | Bitwise XOR |
| `MUL V,V` | `4C VV` | Multiply (32-bit result split across two vars) |
| `DIV V,V` | `4D VV` | Divide (quotient + remainder in next var) |
| `SHR V,X` | `4E VX` | Shift right |
| `SHL V,X` | `4F VX` | Shift left |
| `MUL V,XX` | `5V XX` | Multiply variable by constant |
| `DIV V,XX` | `6V XX` | Divide variable by constant |
| `SUB V,XX` | `7V XX` | Subtract constant from variable |
| `DJNZ V,XX` | `8V XX` | Decrement and jump by offset if not zero |
| `WAIT XXX` | `9X XX` | Wait given milliseconds |
| `WAIT V` | `A0 0V` | Wait time specified in variable |
| `HALT` | `A0 10` | Stop effect |
| `JR XX` | `A1 XX` | Jump by offset |

> **Note:** Offsets are relative to the address of the instruction following the one that uses them. The assembler `peg.py` makes this transparent and accepts absolute positions.

---

## Appendix C — Speech Synthesiser Dictionary

The SD81 Booster speech synthesiser accepts text in English and converts it automatically to phonemes. The following words are recognised directly from the dictionary:

> **Note:** This is a representative selection. The synthesiser also processes unknown words by applying English phonetic rules. For best results, write words in uppercase and phonetically if the automatic result is not clear.

### Direct word dictionary (selection)

| Word | | Word | | Word | |
|------|--|------|--|------|--|
| ABOUT | | EACH | | NEVER | |
| AFTER | | EVERY | | NEXT | |
| AGAIN | | FATHER | | NOW | |
| ALONG | | FIGHT | | ONCE | |
| ALSO | | FINE | | ONLY | |
| ANOTHER | | FIRST | | OTHER | |
| ANY | | FOUND | | PEOPLE | |
| AROUND | | FRIEND | | PLACE | |
| AS | | GETTING | | PLEASE | |
| ASKED | | GIRL | | PRETTY | |
| AWAY | | GIVE | | SAID | |
| BACK | | GLAD | | SHOULD | |
| BECAUSE | | GO | | SISTER | |
| BEFORE | | GOOD | | SNOW | |
| BEST | | GRADE | | SOMETHING | |
| BETTER | | HAPPY | | STARTED | |
| BLACK | | HARD | | SUMMER | |
| BOOK | | HELP | | SURE | |
| BOYS | | HOPE | | TEACHER | |
| BRING | | INTO | | THAN | |
| BROTHER | | JUST | | THESE | |
| BED | | LAST | | THOUGHT | |
| CAME | | LETTER | | THING | |
| CHILDREN | | LIVE | | THROUGH | |
| CLOSE | | LONG | | TODAY | |
| COLD | | LOOKED | | TOOK | |
| COMING | | MANY | | TOWN | |
| COULD | | LARGE | | TREE | |
| COUNTRY | | MEN | | UNTIL | |
| DADDY | | MILK | | VERY | |
| DAYS | | MORNING | | WANTED | |
| DOOR | | MOST | | WATER | |
| DOWN | | MUCH | | WHILE | |
| UP | | MUST | | WHITE | |
| ALAS | | NEVER | | WISH | |
| WORK | | YEAR | | SOMETHING | |

### Pre-recorded phrases and sound effects (selection)

| Code | | Code | |
|------|--|------|--|
| ENEMY | | AMAZING | |
| ALL CLEAR | | THANK YOU | |
| PLEASE | | YUCK | |
| GET OFF | | ARG | |
| OPEN FIRE | | DANGER | |
| WATCH OUT | | ACTION | |
| MERCY | | GOOD | |
| HIT IT | | HI | |
| YOU BLEW IT | | RIGHT | |
| DO IT AGAIN | | WRONG | |
| INCREDIBLE | | ATTACK | |
| U.F.O. | | FIRE | |
| MONSTER! | | HELP | |
| JUMP | | RUN | |
| NO | | YES | |
| SORRY | | GO FOR IT | |
| OH DEAR | | COME ON! | |
| GOT'CHA | | LOOK OUT | |
| OUTCH | | OH NO | |
| OK | | SPELL | |

### Individual letters

When no major match is found, each letter is pronounced by its English name (A="EY", B="BEE", C="SEE", etc.).

### Punctuation and breaks

| Character | Effect |
|----------|--------|
| Space | Short break |
| `,` | Pausa media |
| `;` `:` | Pausa larga |

### Numbers

The numbers are automatically read in English from 0 to billion.

## Appendix D — Memory Paging System

### Z80 Address Space Organisation

| Block | Address range | Default page | Notes |
|-------|--------------|--------------|-------|
| 0 | 0000–1FFF | 0 | ZX81 ROM (read only) |
| 1 | 2000–3FFF | 1 | SD81 Booster extension ROM |
| 2 | 4000–5FFF | 2 | ZX81 RAM (display file + BASIC) |
| 3 | 6000–7FFF | 3 | ZX81 RAM (continuation) |
| 4 | 8000–9FFF | 4 | Extended RAM |
| 5 | A000–BFFF | 5 | Extended RAM |
| 6 | C000–DFFF | 2 | Mirror of block 2 (required for video) |
| 7 | E000–FFFF | 3 | Mirror of block 3 (required for video) |

### Use Rules

- Block 0 is always read only. Blocks 1–7 are read/write.
- The same page can be mapped to more than one block simultaneously.
- Blocks 6 and 7 must mirror what blocks 2 and 3 contain for the ZX81 video generation to work correctly.
- If the display file is entirely in block 2, block 6 must be mapped to the same page as block 2, but block 7 can be mapped freely.
- Similarly, if the display file is entirely in block 3, block 7 must mirror block 3 but block 6 is free.
- Blocks 4 and 5 can always be mapped to any page.
- Due to ZX81 hardware quirks, blocks 4–7 can only be used for data, not to execute code (except with MC45 mode active for blocks 4 and 5).

### Machine Code Execution Restriction

By default, any instruction in blocks 4–7 whose opcode has bit 6 equal to 0 (opcodes 0–63 and 128–191) is replaced by a NOP by the ZX81 hardware. MC45 mode (section 11.3) removes this restriction for blocks 4 and 5.

### Simple vs. Full Paging Mode

**Simple mode (up to 256 KB):** uses bits D2–D0 of port E7h for the block and bits D7–D3 for the page (0–31).

**Full mode (up to 512 KB):** uses the instruction `OUT (C),r` with the page in B (0–63). Changed via the FULLPAGING/HALFPAGING MCU commands.

---

## Appendix E — Chroma81 Interface Port (7FEFh)

The SD81 Booster implements the **Chroma81** colour interface through port **7FEFh** (01111111 11101111 in binary). This port can be read and written.

### Writing (OUT 7FEFh)

| Bit | Function |
|-----|---------|
| 7 | Enable colour mode. `1` = enabled, `0` = disabled. When disabled, the ZX81 shows its normal black and white image. |
| 6 | Attribute mode: `0` = character attributes, `1` = cell attributes. |
| 5–0 | Border colour in GRB format: bits 5–4 = green, bits 3–2 = red, bits 1–0 = blue. |

**Colour attribute format** (1 byte per character in attribute memory):

```
Bit 7: blink
Bits 6-4: ink colour (GRB: bit 6=G, bit 5=R, bit 4=B)
Bits 3-0: paper colour (GRB: bit 3=G, bit 2=R, bit 1=B, bit 0=intensity)
```

### Reading (IN 7FEFh)

Allows detecting whether colour mode is available and reading VSync status:

| Bit | Function |
|-----|---------|
| 7–6 | Not used (reserved). |
| 5 | `0` = colour modes available. Always 0, indicating colour mode is always active. |
| 4–1 | Not used (reserved). |
| 0 | **VSync interrupt status.** `1` = the electron beam is in the vertical blanking period (screen painted). |

> **Note:** Reading bit 5 as 0 allows programs to automatically detect the presence of the Chroma81 interface and activate colour modes if available.

> **VSync synchronisation:** Bit 0 allows the CPU to wait until the screen has finished painting before updating its content, avoiding flicker and visual artefacts. Many ZX Spectrum games used the `HALT` instruction or an interrupt routine to synchronise with VSync; on the SD81 Booster this mechanism is the direct equivalent for that functionality:
> ```asm
>         ; Wait for start of VSync
> WAIT:   in   a,($A7)
>         rrca              ; bit 0 to carry
>         jr   nc,WAIT      ; if carry=0, screen still painting
>         ; screen refresh complete, safe to update video
> ```

---

## Appendix F — Superfast and Spectrum Modes

The SD81 Booster incorporates several high-speed video modes that free the Z80 CPU from the video refresh task, allowing programs to run much faster.

### Control Registers

Video mode is controlled by two memory addresses:

| Address | Name | Function |
|---------|------|---------|
| 2044 (7FCh) | HFILE high byte | High byte of the screen file address in extended RAM |
| 2045 (7FDh) | Mode register | Active video mode |

### Mode Register Values (POKE 2045,n)

| Value | Mode | Description |
|-------|------|-------------|
| 85 (55h) | Normal ZX81 | Standard ZX81 mode. CPU manages video. |
| 170 (AAh) | Superfast text | FPGA manages video. Screen is a character map in extended RAM. CPU completely free. |
| 172 (ACh) | Superfast HiRes Spectrum | FPGA manages video. Screen is a 256×192 pixel bitmap in Spectrum format. |
| 174 (AEh) | Superfast HiRes native | FPGA manages video. Screen is a 256×192 pixel bitmap in ZX81 native format. |

### Border control (POKE 2046..2055)
```
POKE 2046,<attr>        : To change border attributes
POKE 2047,170           : Activate border pattern
POKE 2047,85            : Deactivate border pattern
2048–2055,<datos>       : Define border pattern (8 bytes)
``` 


### VSync Synchronisation

To synchronise updates with the screen vertical blanking period:

```asm
WAIT:   in   a,($A7)
        rrca
        jr   nc,WAIT      ; wait until bit 0 = 1 (blanking)
        ; safe to update video memory
```

### Screen File Address (HFILE)

In Superfast modes, the screen data is in extended RAM. The address must be configured before activating the mode:

```basic
LET HFILE=32768
POKE 2044,HFILE/256
POKE 2045,170
```

### Port FBh in Spectrum Mode

In HiRes Spectrum mode, port FBh is used to set the border colour:

```
LOAD *OUT 251,<colour>
```

Where `<colour>` is a value 0–7 (standard Spectrum colour). The ZX Printer uses the same port and is incompatible with this mode when active.

---

## Appendix G — Audio Technical Reference: AY chip, VGM and allophones

### AY-3-8910/12 Chip Registers

The SD81 Booster AY emulator is register-level compatible with the original chip. It supports three independent voices, envelope and noise.

| Reg | Description | B7 | B6 | B5 | B4 | B3 | B2 | B1 | B0 |
|-----|-------------|----|----|----|----|----|----|----|----|
| R0 | Channel A tone period (low) | B7 | B6 | B5 | B4 | B3 | B2 | B1 | B0 |
| R1 | Channel A tone period (high) | — | — | — | — | B3 | B2 | B1 | B0 |
| R2 | Channel B tone period (low) | B7 | B6 | B5 | B4 | B3 | B2 | B1 | B0 |
| R3 | Channel B tone period (high) | — | — | — | — | B3 | B2 | B1 | B0 |
| R4 | Channel C tone period (low) | B7 | B6 | B5 | B4 | B3 | B2 | B1 | B0 |
| R5 | Channel C tone period (high) | — | — | — | — | B3 | B2 | B1 | B0 |
| R6 | Noise period | — | — | — | B4 | B3 | B2 | B1 | B0 |
| R7 | Enable | — | — | Noise C | Noise B | Noise A | Tone C | Tone B | Tone A |
| R8 | Channel A amplitude | — | — | — | Env. | L3 | L2 | L1 | L0 |
| R9 | Channel B amplitude | — | — | — | Env. | L3 | L2 | L1 | L0 |
| R10 | Channel C amplitude | — | — | — | Env. | L3 | L2 | L1 | L0 |
| R11 | Envelope period (low) | B7 | B6 | B5 | B4 | B3 | B2 | B1 | B0 |
| R12 | Envelope period (high) | B7 | B6 | B5 | B4 | B3 | B2 | B1 | B0 |
| R13 | Envelope shape/cycle | — | — | — | — | — | B2 | B1 | B0 |

> **Note:** In R7, a bit at 0 enables the channel; at 1 it disables it. In R8–R10, if the Env. bit is active, amplitude is controlled by the envelope (R11–R13) instead of L3–L0.

### VGM Player Opcodes

The interface VGM player only interprets opcodes referring to the AY chip. The rest are ignored without producing an error.

| Opcode | Parameters | Description |
|--------|-----------|-------------|
| 61h | nn nn | Wait n samples (little-endian, 0–65535; ≈ 1.49 s maximum). Long pauses are represented with several consecutive commands. |
| 62h | — | Wait 735 samples (1/60 of a second). Equivalent to 61h DFh 02h. |
| 63h | — | Wait 882 samples (1/50 of a second). Equivalent to 61h 72h 03h. |
| A0h | aa dd | Write value dd to AY register number aa. |

### SP0256-AL2 Allophone Table

Allophones are used with the MCU BINARY SAY command (16h) for precise phonetic synthesis. High-level text access (`LOAD *SAY "text"`) does not require knowing these codes.

| Code | Allophone | Example | Code | Allophone | Example |
|------|-----------|---------|------|-----------|---------|
| $00 | PA1 | pause 10 ms | $20 | AW | out |
| $01 | PA2 | pause 30 ms | $21 | DD2 | do |
| $02 | PA3 | pause 50 ms | $22 | GG3 | wig |
| $03 | PA4 | pause 100 ms | $23 | VV | vest |
| $04 | PA5 | pause 200 ms | $24 | GG1 | got |
| $05 | OY | boy | $25 | SH | ship |
| $06 | AY | sky | $26 | ZH | azure |
| $07 | EH | end | $27 | RR2 | brain |
| $08 | KK3 | comb | $28 | FF | food |
| $09 | PP | pow | $29 | KK2 | sky |
| $0A | JH | dodge | $2A | KK1 | can't |
| $0B | NN1 | thin | $2B | ZZ | zoo |
| $0C | IH | sit | $2C | NG | anchor |
| $0D | TT2 | to | $2D | LL | lake |
| $0E | RR1 | rural | $2E | WW | wool |
| $0F | AX | succeed | $2F | XR | repair |
| $10 | MM | milk | $30 | WH | whig |
| $11 | TT1 | part | $31 | YY1 | yes (short) |
| $12 | DH1 | they | $32 | CH | church |
| $13 | IY | see | $33 | ER1 | fir (short) |
| $14 | EY | beige | $34 | ER2 | fir (long) |
| $15 | DD1 | could | $35 | OW | beau |
| $16 | UW1 | too | $36 | DH2 | they |
| $17 | AO | aught | $37 | SS | vest |
| $18 | AA | hot | $38 | NN2 | no |
| $19 | YY2 | yes (long) | $39 | HH2 | hoe |
| $1A | AE | hat | $3A | OR | store |
| $1B | HH1 | he | $3B | AR | alarm |
| $1C | BB1 | business (short) | $3C | YR | clear |
| $1D | TH | thin | $3D | GG2 | guest |
| $1E | UH | book | $3E | EL | saddle |
| $1F | UW2 | food | $3F | BB2 | business (long) |
