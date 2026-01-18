/*
KNOWN BUGS:
- Beep can't sound until player has either clicked or pressed a key. It's a limitation of javascript
  so it can't be solved.
*/

// Constants

const versionDate = '24/06/2025';

// Settings
const NESTED_DOALL_ENABLED = false;
const DEBUG_ENABLED = true;
const MALUVA_DISABLED = false;

// Screen
const RESOLUTION_X = 320;
const RESOLUTION_Y= 200;
const COLUMN_WIDTH = 6;
const LINE_HEIGHT= 8;
const NUM_WINDOWS = 8;
const NUM_COLUMNS = 53; //53 colums of 8x6
const NUM_LINES=25;


// General
const NO_WORD = 0xFF;
const END_OF_PROCESS_MARK = 0x00;
const END_OF_CONDACTS_MARK = 0xFF;
const END_OF_CONNECTIONS_MARK = 0xFF;
const NUM_LOCATIONS = 256;
const MAX_LOCATION = NUM_LOCATIONS -1;
const LAST_CONVERTIBLE_NOUN=39; //Nouns convertible to verb in absence of verb. i.e "NORTH"
const LAST_PROPER_NOUN=50;
const MAX_CONDACTS = 128;

// Messages
const ESCAPE_OBJNAME = '_';
const ESCAPE_OBJNAME_CAPS = '@';
const OFUSCATE_VALUE = 0xFF;

// Parser
const WORD_LENGHT = 5;
const COMPLETE_WORD_LENGHT = 15;
const STANDARD_SEPARATORS =  ['.',',',';',':'];
const SPANISH_TERMINATIONS =  ['LO','LA','LOS','LAS'];
const MAX_CONJUNCTIONS = 256;
const NUM_HISTORY_ORDERS = 10;

const VOC_VERB=0;
const VOC_ADVERB=1;
const VOC_NOUN = 2;
const VOC_ADJECT =3
const VOC_PREPOSITION=4;
const VOC_CONJUGATION=5
const VOC_PRONOUN=6
const VOC_ANY = 7;

const VOC_TYPE=[VOC_VERB,VOC_ADVERB,VOC_NOUN, VOC_ADJECT, VOC_PREPOSITION, VOC_CONJUGATION,  VOC_PRONOUN, VOC_ANY];

// The AudioContext Frequencies

var FREQ_TABLE = 
[
    16.35,    17.32,    18.35,    19.45,    20.60,    21.83,    23.12,    24.50,    25.96,    27.50,    29.14,    30.87,
    32.70,    34.65,    36.71,    38.89,    41.20,    43.65,    46.25,    49.00,    51.91,    55.00,    58.27,    61.74,
    65.41,    69.30,    73.42,    77.78,    82.41,    87.31,    92.50,    98.00,   103.83,   110.00,   116.54,   123.47,
   130.81,   138.59,   146.83,   155.56,   164.81,   174.61,   185.00,   196.00,   207.65,   220.00,   233.08,   246.94,
   261.63,   277.18,   293.66,   311.13,   329.63,   349.23,   369.99,   392.00,   415.30,   440.00,   466.16,   493.88,
   523.25,   554.37,   587.33,   622.25,   659.26,   698.46,   739.99,   783.99,   830.61,   880.00,   932.33,   987.77,
  1046.50,  1108.73,  1174.66,  1244.51,  1318.51,  1396.91,  1479.98,  1567.98,  1661.22,  1760.00,  1864.66,  1975.53,
  2093.00,  2217.46,  2349.32,  2489.02,  2637.02,  2793.83,  2959.96,  3135.96,  3322.44,  3520.00,  3729.31,  3951.07,
  4186.01,  4434.92,  4698.64,  4978.03  
];



// The following constants are to be used so in case in the future some 
// system message has to be changed, it's easier to replace everywhere.

const SM0 = 0;
const SM1 = 1;
const SM2 = 2;
const SM3 = 3;
const SM4 = 4;
const SM5 = 5;
const SM6 = 6;
const SM7 = 7;
const SM8 = 8;
const SM9 = 9;
const SM10 = 10;
const SM11 = 11;
const SM12 = 12;
const SM13 = 13;
const SM14 = 14;
const SM15 = 15;
const SM16 = 16;
const SM17 = 17;
const SM18 = 18;
const SM19 = 19;
const SM20 = 20;
const SM21 = 21;
const SM22 = 22;
const SM23 = 23;
const SM24 = 24;
const SM25 = 25;
const SM26 = 26;
const SM27 = 27;
const SM28 = 28;
const SM29 = 29;
const SM30 = 30;
const SM31 = 31;
const SM32 = 32;
const SM33 = 33;
const SM34 = 34;
const SM35 = 35;
const SM36 = 36;
const SM37 = 37;
const SM38 = 38;
const SM39 = 39;
const SM40 = 40;
const SM41 = 41;
const SM42 = 42;
const SM43 = 43;
const SM44 = 44;
const SM45 = 45;
const SM46 = 46;
const SM47 = 47;
const SM48 = 48;
const SM49 = 49;
const SM50 = 50;
const SM51 = 51;
const SM52 = 52;
const SM53 = 53;
const SM54 = 54;
const SM55 = 55;
const SM56 = 56;
const SM57 = 57;
const SM58 = 58;
const SM59 = 59;
const SM60 = 60;
const SM61 = 61;
const SM62 = 62;
const SM63 = 63;
const SM64 = 64;
const SM65 = 65;
const SM66 = 66;
const SM67 = 67;
const SM68 = 68;
const SM69 = 69;
const SM70 = 70;


// Flag names
const FDARK=0;
const FCARRIED= 1;
const FMOUSE=29;
const FSCORE=30;
const FTURNS_LO=31;
const FTURNS_HI=32;
const FVERB = 33;
const FNOUN = 34;
const FADJECT=35;
const FADVERB=36;
const FOBJECTS_CONVEYABLE =37;
const FPLAYER = 38;
const FINPUT=41;
const FPROMPT=42;
const FPREP=43;
const FNOUN2=44;
const FADJECT2=45;
const FPRONOUN=46;
const FPRONOUN_ADJECT=47;
const FTIMEOUT=48;
const FTIMEOUT_CONTROL=49;
const FDOALL=50;
const FREFOBJ = 51;
const FPLAYER_STRENGTH=52;
const FOBJECT_PRINT_FLAGS=53;
const FREFOBJLOC = 54;
const FREFOBJWEIGHT = 55;
const FREFOBJCONTAINER = 56;
const FREFOBJWEARABLE = 57;
const FREFOBJATTR1 = 58;
const FREFOBJATTR2 = 59;
const FKEY1 =60;
const FKEY2 = 61;
const FSCREENMODE=62;
const FactiveWindow=63;

const NUM_FLAGS = 256;
const MAX_FLAG_VALUE = 0xFF;

// Object constants

const   NUM_OBJECTS = 256;
const   MAX_OBJECT  = NUM_OBJECTS -1;
const   NO_OBJECT = MAX_OBJECT;
const   LOC_NOT_CREATED = 252;
const   LOC_CARRIED = 254;
const   LOC_WORN = 253;
const   LOC_HERE = 255;


// The palette

const colours = [ [0x00,0x00,0x00],[0x00,0x00,0xAA], [0x00,0xAA,0x00],[0x00,0xAA,0xAA],[0xAA,0x00,0x00],[0xAA, 0x00, 0xAA], [0xAA, 0x55, 0x00],[0xAA, 0xAA, 0xAA]
                 ,[0x55,0x55,0x55],[0x55,0x55,0xFF], [0x55,0xFF,0x55],[0x55,0xFF,0xFF],[0xFF, 0x55, 0x55],[0xFF,0x55,0xFF], [0xFF, 0xFF, 0x55],[0xFF, 0xFF, 0xFF]];

// Carriage return

const CR = String.fromCharCode(13);

// The condacts

const condactTable  = [
    {condactName: 'AT     ', condactRoutine: _AT     , numParams: 1}, /*   0 0x00*/
    {condactName: 'NOTAT  ', condactRoutine: _NOTAT  , numParams: 1}, /*   1 0x01*/
    {condactName: 'ATGT   ', condactRoutine: _ATGT   , numParams: 1}, /*   2 0x02*/
    {condactName: 'ATLT   ', condactRoutine: _ATLT   , numParams: 1}, /*   3 0x03*/
    {condactName: 'PRESENT', condactRoutine: _PRESENT, numParams: 1}, /*   4 0x04*/
    {condactName: 'ABSENT ', condactRoutine: _ABSENT , numParams: 1}, /*   5 0x05*/
    {condactName: 'WORN   ', condactRoutine: _WORN   , numParams: 1}, /*   6 0x06*/
    {condactName: 'NOTWORN', condactRoutine: _NOTWORN, numParams: 1}, /*   7 0x07*/
    {condactName: 'CARRIED', condactRoutine: _CARRIED, numParams: 1}, /*   8 0x08*/
    {condactName: 'NOTCARR', condactRoutine: _NOTCARR, numParams: 1}, /*   9 0x09*/
    {condactName: 'CHANCE ', condactRoutine: _CHANCE , numParams: 1}, /*  10 0x0A*/
    {condactName: 'ZERO   ', condactRoutine: _ZERO   , numParams: 1}, /*  11 0x0B*/
    {condactName: 'NOTZERO', condactRoutine: _NOTZERO, numParams: 1}, /*  12 0x0C*/
    {condactName: 'EQ     ', condactRoutine: _EQ     , numParams: 2}, /*  13 0x0D*/
    {condactName: 'GT     ', condactRoutine: _GT     , numParams: 2}, /*  14 0x0E*/
    {condactName: 'LT     ', condactRoutine: _LT     , numParams: 2}, /*  15 0x0F*/
    {condactName: 'ADJECT1', condactRoutine: _ADJECT1, numParams: 1}, /*  16 0x10*/
    {condactName: 'ADVERB ', condactRoutine: _ADVERB , numParams: 1}, /*  17 0x11*/
    {condactName: 'SFX    ', condactRoutine: _SFX    , numParams: 2}, /*  18 0x12*/
    {condactName: 'DESC   ', condactRoutine: _DESC   , numParams: 1}, /*  19 0x13*/
    {condactName: 'QUIT   ', condactRoutine: _QUIT   , numParams: 0}, /*  20 0x14*/
    {condactName: 'END    ', condactRoutine: _END    , numParams: 0}, /*  21 0x15*/
    {condactName: 'DONE   ', condactRoutine: _DONE   , numParams: 0}, /*  22 0x16*/
    {condactName: 'OK     ', condactRoutine: _OK     , numParams: 0}, /*  23 0x17*/
    {condactName: 'ANYKEY ', condactRoutine: _ANYKEY , numParams: 0}, /*  24 0x18*/
    {condactName: 'SAVE   ', condactRoutine: _SAVE   , numParams: 1}, /*  25 0x19*/
    {condactName: 'LOAD   ', condactRoutine: _LOAD   , numParams: 1}, /*  26 0x1A*/
    {condactName: 'DPRINT ', condactRoutine: _DPRINT , numParams: 1}, /*  27 0x1B*/
    {condactName: 'DISPLAY', condactRoutine: _DISPLAY, numParams: 1}, /*  28 0x1C*/
    {condactName: 'CLS    ', condactRoutine: _CLS    , numParams: 0}, /*  29 0x1D*/
    {condactName: 'DROPALL', condactRoutine: _DROPALL, numParams: 0}, /*  30 0x1E*/
    {condactName: 'AUTOG  ', condactRoutine: _AUTOG  , numParams: 0}, /*  31 0x1F*/
    {condactName: 'AUTOD  ', condactRoutine: _AUTOD  , numParams: 0}, /*  32 0x20*/
    {condactName: 'AUTOW  ', condactRoutine: _AUTOW  , numParams: 0}, /*  33 0x21*/
    {condactName: 'AUTOR  ', condactRoutine: _AUTOR  , numParams: 0}, /*  34 0x22*/
    {condactName: 'PAUSE  ', condactRoutine: _PAUSE  , numParams: 1}, /*  35 0x23*/
    {condactName: 'SYNONYM', condactRoutine: _SYNONYM, numParams: 2}, /*  36 0x24*/
    {condactName: 'GOTO   ', condactRoutine: _GOTO   , numParams: 1}, /*  37 0x25*/
    {condactName: 'MESSAGE', condactRoutine: _MESSAGE, numParams: 1}, /*  38 0x26*/
    {condactName: 'REMOVE ', condactRoutine: _REMOVE , numParams: 1}, /*  39 0x27*/
    {condactName: 'GET    ', condactRoutine: _GET    , numParams: 1}, /*  40 0x28*/
    {condactName: 'DROP   ', condactRoutine: _DROP   , numParams: 1}, /*  41 0x29*/
    {condactName: 'WEAR   ', condactRoutine: _WEAR   , numParams: 1}, /*  42 0x2A*/
    {condactName: 'DESTROY', condactRoutine: _DESTROY, numParams: 1}, /*  43 0x2B*/
    {condactName: 'CREATE ', condactRoutine: _CREATE , numParams: 1}, /*  44 0x2C*/
    {condactName: 'SWAP   ', condactRoutine: _SWAP   , numParams: 2}, /*  45 0x2D*/
    {condactName: 'PLACE  ', condactRoutine: _PLACE  , numParams: 2}, /*  46 0x2E*/
    {condactName: 'SET    ', condactRoutine: _SET    , numParams: 1}, /*  47 0x2F*/
    {condactName: 'CLEAR  ', condactRoutine: _CLEAR  , numParams: 1}, /*  48 0x30*/
    {condactName: 'PLUS   ', condactRoutine: _PLUS   , numParams: 2}, /*  49 0x31*/
    {condactName: 'MINUS  ', condactRoutine: _MINUS  , numParams: 2}, /*  50 0x32*/
    {condactName: 'LET    ', condactRoutine: _LET    , numParams: 2}, /*  51 0x33*/
    {condactName: 'NEWLINE', condactRoutine: _NEWLINE, numParams: 0}, /*  52 0x34*/
    {condactName: 'PRINT  ', condactRoutine: _PRINT  , numParams: 1}, /*  53 0x35*/
    {condactName: 'SYSMESS', condactRoutine: _SYSMESS, numParams: 1}, /*  54 0x36*/
    {condactName: 'ISAT   ', condactRoutine: _ISAT   , numParams: 2}, /*  55 0x37*/
    {condactName: 'SETCO  ', condactRoutine: _SETCO  , numParams: 1}, /*  56 0x38*/
    {condactName: 'SPACE  ', condactRoutine: _SPACE  , numParams: 0}, /*  57 0x39*/
    {condactName: 'HASAT  ', condactRoutine: _HASAT  , numParams: 1}, /*  58 0x3A*/
    {condactName: 'HASNAT ', condactRoutine: _HASNAT , numParams: 1}, /*  59 0x3B*/
    {condactName: 'LISTOBJ', condactRoutine: _LISTOBJ, numParams: 0}, /*  60 0x3C*/
    {condactName: 'EXTERN ', condactRoutine: _EXTERN , numParams: 2}, /*  61 0x3D*/
    {condactName: 'RAMSAVE', condactRoutine: _RAMSAVE, numParams: 0}, /*  62 0x3E*/
    {condactName: 'RAMLOAD', condactRoutine: _RAMLOAD, numParams: 1}, /*  63 0x3F*/
    {condactName: 'BEEP   ', condactRoutine: _BEEP   , numParams: 2}, /*  64 0x40*/
    {condactName: 'PAPER  ', condactRoutine: _PAPER  , numParams: 1}, /*  65 0x41*/
    {condactName: 'INK    ', condactRoutine: _INK    , numParams: 1}, /*  66 0x42*/
    {condactName: 'BORDER ', condactRoutine: _BORDER , numParams: 1}, /*  67 0x43*/
    {condactName: 'PREP   ', condactRoutine: _PREP   , numParams: 1}, /*  68 0x44*/
    {condactName: 'NOUN2  ', condactRoutine: _NOUN2  , numParams: 1}, /*  69 0x45*/
    {condactName: 'ADJECT2', condactRoutine: _ADJECT2, numParams: 1}, /*  70 0x46*/
    {condactName: 'ADD    ', condactRoutine: _ADD    , numParams: 2}, /*  71 0x47*/
    {condactName: 'SUB    ', condactRoutine: _SUB    , numParams: 2}, /*  72 0x48*/
    {condactName: 'PARSE  ', condactRoutine: _PARSE  , numParams: 1}, /*  73 0x49*/
    {condactName: 'LISTAT ', condactRoutine: _LISTAT , numParams: 1}, /*  74 0x4A*/
    {condactName: 'PROCESS', condactRoutine: _PROCESS, numParams: 1}, /*  75 0x4B*/
    {condactName: 'SAME   ', condactRoutine: _SAME   , numParams: 2}, /*  76 0x4C*/
    {condactName: 'MES    ', condactRoutine: _MES    , numParams: 1}, /*  77 0x4D*/
    {condactName: 'WINDOW ', condactRoutine: _WINDOW , numParams: 1}, /*  78 0x4E*/
    {condactName: 'NOTEQ  ', condactRoutine: _NOTEQ  , numParams: 2}, /*  79 0x4F*/
    {condactName: 'NOTSAME', condactRoutine: _NOTSAME, numParams: 2}, /*  80 0x50*/
    {condactName: 'MODE   ', condactRoutine: _MODE   , numParams: 1}, /*  81 0x51*/
    {condactName: 'WINAT  ', condactRoutine: _WINAT  , numParams: 2}, /*  82 0x52*/
    {condactName: 'TIME   ', condactRoutine: _TIME   , numParams: 2}, /*  83 0x53*/
    {condactName: 'PICTURE', condactRoutine: _PICTURE, numParams: 1}, /*  84 0x54*/
    {condactName: 'DOALL  ', condactRoutine: _DOALL  , numParams: 1}, /*  85 0x55*/
    {condactName: 'MOUSE  ', condactRoutine: _MOUSE  , numParams: 2}, /*  86 0x56*/
    {condactName: 'GFX    ', condactRoutine: _GFX    , numParams: 2}, /*  87 0x57*/
    {condactName: 'ISNOTAT', condactRoutine: _ISNOTAT, numParams: 2}, /*  88 0x58*/
    {condactName: 'WEIGH  ', condactRoutine: _WEIGH  , numParams: 2}, /*  89 0x59*/
    {condactName: 'PUTIN  ', condactRoutine: _PUTIN  , numParams: 2}, /*  90 0x5A*/
    {condactName: 'TAKEOUT', condactRoutine: _TAKEOUT, numParams: 2}, /*  91 0x5B*/
    {condactName: 'NEWTEXT', condactRoutine: _NEWTEXT, numParams: 0}, /*  92 0x5C*/
    {condactName: 'ABILITY', condactRoutine: _ABILITY, numParams: 2}, /*  93 0x5D*/
    {condactName: 'WEIGHT ', condactRoutine: _WEIGHT , numParams: 1}, /*  94 0x5E*/
    {condactName: 'RANDOM ', condactRoutine: _RANDOM , numParams: 1}, /*  95 0x5F*/
    {condactName: 'INPUT  ', condactRoutine: _INPUT  , numParams:21}, /*  96 0x60*/
    {condactName: 'SAVEAT ', condactRoutine: _SAVEAT , numParams: 0}, /*  97 0x61*/
    {condactName: 'BACKAT ', condactRoutine: _BACKAT , numParams: 0}, /*  98 0x62*/
    {condactName: 'PRINTAT', condactRoutine: _PRINTAT, numParams: 2}, /*  99 0x63*/
    {condactName: 'WHATO  ', condactRoutine: _WHATO  , numParams: 0}, /* 100 0x64*/
    {condactName: 'CALL   ', condactRoutine: _CALL   , numParams: 1}, /* 101 0x65*/
    {condactName: 'PUTO   ', condactRoutine: _PUTO   , numParams: 1}, /* 102 0x66*/
    {condactName: 'NOTDONE', condactRoutine: _NOTDONE, numParams: 0}, /* 103 0x67*/
    {condactName: 'AUTOP  ', condactRoutine: _AUTOP  , numParams: 1}, /* 104 0x68*/
    {condactName: 'AUTOT  ', condactRoutine: _AUTOT  , numParams: 1}, /* 105 0x69*/
    {condactName: 'MOVE   ', condactRoutine: _MOVE   , numParams: 1}, /* 106 0x6A*/
    {condactName: 'WINSIZE', condactRoutine: _WINSIZE, numParams: 2}, /* 107 0x6B*/
    {condactName: 'REDO   ', condactRoutine: _REDO   , numParams: 0}, /* 108 0x6C*/
    {condactName: 'CENTRE ', condactRoutine: _CENTRE , numParams: 0}, /* 109 0x6D*/
    {condactName: 'EXIT   ', condactRoutine: _EXIT   , numParams: 1}, /* 110 0x6E*/
    {condactName: 'INKEY  ', condactRoutine: _INKEY  , numParams: 0}, /* 111 0x6F*/
    {condactName: 'BIGGER ', condactRoutine: _BIGGER , numParams: 2}, /* 112 0x70*/
    {condactName: 'SMALLER', condactRoutine: _SMALLER, numParams: 2}, /* 113 0x71*/
    {condactName: 'ISDONE ', condactRoutine: _ISDONE , numParams: 0}, /* 114 0x72*/
    {condactName: 'ISNDONE', condactRoutine: _ISNDONE, numParams: 0}, /* 115 0x73*/
    {condactName: 'SKIP   ', condactRoutine: _SKIP   , numParams: 1}, /* 116 0x74*/
    {condactName: 'RESTART', condactRoutine: _RESTART, numParams: 0}, /* 117 0x75*/
    {condactName: 'TAB    ', condactRoutine: _TAB    , numParams: 1}, /* 118 0x76*/
    {condactName: 'COPYOF ', condactRoutine: _COPYOF , numParams: 2}, /* 119 0x77*/
    {condactName: 'dumb   ', condactRoutine: _dumb   , numParams: 0}, /* 120 0x78*/
    {condactName: 'COPYOO ', condactRoutine: _COPYOO , numParams: 2}, /* 121 0x79*/
    {condactName: 'dumb   ', condactRoutine: _dumb   , numParams: 0}, /* 122 0x7A*/
    {condactName: 'COPYFO ', condactRoutine: _COPYFO , numParams: 2}, /* 123 0x7B*/
    {condactName: 'dumb   ', condactRoutine: _dumb   , numParams: 0}, /* 124 0x7C*/
    {condactName: 'COPYFF ', condactRoutine: _COPYFF , numParams: 2}, /* 125 0x7D*/
    {condactName: 'COPYBF ', condactRoutine: _COPYBF , numParams: 2}, /* 126 0x7E*/
    {condactName: 'RESET  ', condactRoutine: _RESET  , numParams: 0}  /* 127 0x7F*/
    ];

// Global classes

class wordClass
{
    aCode = NO_WORD;
    aType = VOC_ANY;
}


class windowClass
{
     // In characters as DAAD understands it
    line=0;
    col=0;
    height=NUM_LINES;
    width=NUM_COLUMNS;
    
    operationMode= 0;

    // In pixels for internal use
    currentY = 0;
    currentX = 0; 
    backupCurrentY=0;
    backupCurrentX = 0;  

    INK = 15;
    PAPER = 0;
    BORDER = 0;

    lastPauseLine = 0; // Line where the text stopped for the user to read last 

}

class WindowArrayClass
{
    windows = [];
    activeWindow = 0;
    lastPrintedIsCR = 0;
    charsetShift = 0;
    backupStream = 0;

    constructor()
    {
        windows = [];
        for(var i = 0; i< NUM_WINDOWS; i++) 
        {
            var aWindow = new windowClass();
            this.windows.push(aWindow);
        }
        this.resetWindows();
    }

    resetWindows()
    {
        for(var i = 0; i< NUM_WINDOWS; i++) 
        {
            this.windows[i].line = 0;
            this.windows[i].col = 0;
            this.windows[i].height = NUM_LINES;
            this.windows[i].width = NUM_COLUMNS;
            this.windows[i].operationMode = 0;
            this.windows[i].currentX = 0;
            this.windows[i].currentY = 0;
            this.windows[i].backupCurrentX = 0;
            this.windows[i].backupCurrentY = 0;
            this.windows[i].PAPER = 0;
            this.windows[i].BORDER = 0;
            this.windows[i].INK = 15; 
        
        }
        this.lastPrintedIsCR = 0;
        this.charsetShift = 0;
        this.backupStream = 0;
        this.activeWindow = 0;
    }
}

class DDBHeader
{
    version = 0;
	targetMachineLanguage=0;
	the95=0;
	numObj=0;
	numLoc=0;
	numMsg=0;
	numSys=0;
	numPro=0;
	tokenPos=0;
	processPos=0;
	objectPos=0;
	locationPos=0;
	messagePos=0;
	sysmessPos=0;
	connectionPos=0;
	vocabularyPos=0;
	objInitiallyAtPos=0;
	objNamePos=0;
	objWeightContWearPos=0;
	objAttributesPos=0;
	fileLength=0;
}

// This clases intenally uses the DDBDATA array, generated by the compiler. While is some kind of violation
// of OOP, it was prefered like that as otherwise the compiler would have to merge this file and the 
// generated DDB data, making it all more complicated in the compiler side, and different from other targets
class DDBClass {
    header = 0;

    processPTR =0;
    entryPTR = 0;
    condactPTR = 0;
    doallPTR = 0; //0 if DOALL not active, points to condact after DOALL otherwise
    doallentryPTR = 0;
    doallLocation =0;

    constructor ()
    {
        this.header = new DDBHeader();

        // Initialize the DDB header
        this.header.version = this.getByte(0);
        this.header.targetMachineLanguage=this.getByte(1);
        this.header.the95=this.getByte(2);
        this.header.numObj=this.getByte(3);
        this.header.numLoc=this.getByte(4);
        this.header.numMsg=this.getByte(5);
        this.header.numSys=this.getByte(6);
        this.header.numPro=this.getByte(7);
        this.header.tokenPos=this.getWord(8);
        this.header.processPos=this.getWord(10);
        this.header.objectPos=this.getWord(12);
        this.header.locationPos=this.getWord(14);
        this.header.messagePos=this.getWord(16);
        this.header.sysmessPos=this.getWord(18);
        this.header.connectionPos=this.getWord(20);
        this.header.vocabularyPos=this.getWord(22);
        this.header.objInitiallyAtPos=this.getWord(24);
        this.header.objNamePos=this.getWord(26);
        this.header.objWeightContWearPos=this.getWord(28);
        this.header.objAttributesPos=this.getWord(30);
        this.header.fileLength=this.getWord(32);

        // clean (probably not necessary)
        this.processPTR =0;
        this.entryPTR = 0;
        this.condactPTR = 0;
        this.doallPTR = 0; //0 if DOALL not active, points to condact after DOALL otherwise
        this.doallentryPTR = 0;
        this.doallLocation =0;
    
    }


    getByte(address)
    {
        if (address > 0xFFFE) return 0
        return DDBDATA[address];
    }

    setByte(address, value)
    {
        if (address > 0xFFFE) return 0
        DDBDATA[address] = value;
    }


    getWord(address)
    {
        return this.getByte(address) + 256 * this.getByte(address + 1);
    }

    getBlock(address, length)
    {
        var result = [];
        for (var i=0;i<length;i++) result.push(this.getByte(address+i));
        return result;
    }


    setBlock(address, data)
    {
        for (var i=0;i<data.length;i++) this.setByte(address + i, data[i]);
    }


    resetProcesses()
    {
        this.doallPTR = 0;
        this.doallentryPTR = 0; //Not really necessery
        this.condactPTR = 0;
        this.processPTR =  this.header.processPos;
        this.entryPTR =  this.getWord(this.processPTR);
    }

    consumeProcess()
    {
        while (this.getByte(this.entryPTR) != END_OF_PROCESS_MARK)  this.entryPTR +=4;
        this.entryPTR-= 4;
    }

    isSpanish()
    {
        return (this.header.targetMachineLanguage & 1) != 0;
    }


}

class flagClass {

    #theflags = [];
    #theflagsRAMSAVE = [];

    constructor () 
    {
        for(var i=0;i<NUM_FLAGS;i++) 
        {
            this.#theflags.push(0);
            this.#theflagsRAMSAVE.push(0);
        }
    }

    resetFlags()
    {
        for (var i=0;i<NUM_FLAGS;i++) 
        {
            this.#theflags[i] = 0;
            this.#theflagsRAMSAVE[i] = 0;
        }
    }

    getFlag(flagno)
    {
        return this.#theflags[flagno];
    }

    setFlag(flagno, value)
    {
        this.#theflags[flagno] = value;

    }

    getFlagBit(flagno,bitno)
    {
        return (this.getFlag(flagno) & (1 << bitno)) != 0;    
    }



    RAMSAVEFlags()
    {
        for(var i=0;i<NUM_FLAGS;i++) 
        this.#theflagsRAMSAVE[i] = this.#theflags[i];        
    }

    RAMLOADFlags(flagno)
    {
        for(var i=0;i<flagno;i++) 
         this.#theflags[i] = this.#theflagsRAMSAVE[i]
    }
}

class objectClass {

    #objectLocations = [];
    #objectLocationsRAMSAVE = [];

    constructor ()
    {
        for(var i=0;i<NUM_OBJECTS;i++) 
        {
            this.#objectLocations.push(0);
            this.#objectLocationsRAMSAVE.push(0);
        }
    }

    getObjectLocation(objno)
    {
        return this.#objectLocations[objno];
    }

    setObjectLocation(objno, value)
    {
        this.#objectLocations[objno] = value;
    }

    getObjectCountAt(locno)
    {
        var count = 0;
        for (var i=0 ; i<DDB.header.numObj ; i++)
           if (this.getObjectLocation(i)==locno) count++;
        return count;
    }

    RAMSAVEObjects()
    {
        for(var i=0;i<NUM_OBJECTS;i++) 
            this.#objectLocationsRAMSAVE[i] = this.#objectLocations[i];
    }

    RAMLOADObjects()
    {
        for(var i=0;i<NUM_OBJECTS;i++) 
         this.#objectLocations[i] =  this.#objectLocationsRAMSAVE[i];
    }

    getObjectWeight(objno)
    {
        return DDB.getByte(DDB.header.objWeightContWearPos + objno) & 0x3F;
    }

    getObjectFullWeight(objno)
    {
        if (objno >= DDB.header.numObj) w = 0
        else 
        {
            var w = this.getObjectWeight(objno);
            if ( (this.isObjectContainer(objno)) && (w!=0))
            {
                for (var i=0;i<DDB.header.numObj;i++)
                    if (this.getObjectLocation(i) == objno) 
                    {
                        var w2 = this.getObjectFullWeight(i);
                        if (w + w2 <= MAX_FLAG_VALUE) w += w2 ; else return MAX_FLAG_VALUE;
                    }
            }
        }; /* if valid object*/
       
        return w;
    }

    getWeightOfObjectsAt(locno)
    {
        var totalWeight = 0;
        for(var i=0;i<DDB.header.numObj;i++)
        {
            if (this.getObjectLocation(i)==locno) 
            {
                var currentObjWeight = this.getObjectFullWeight(i);
                if (totalWeight + currentObjWeight > MAX_FLAG_VALUE) return MAX_FLAG_VALUE; else totalWeight += currentObjWeight;
            }
        }
        return totalWeight;
    }

    resetObjects()
    {
        for(var i=0;i<NUM_OBJECTS;i++) this.setObjectLocation(i,LOC_NOT_CREATED);
        flags.setFlag(FCARRIED,0);
        for (var i=0;i< DDB.header.numObj;i++)
        {
            this.setObjectLocation(i,DDB.getByte(DDB.header.objInitiallyAtPos + i));
            if (this.getObjectLocation(i)==LOC_CARRIED) flags.setFlag(FCARRIED, flags.getFlag(FCARRIED)+1);
        }
    }

    setReferencedObject(objno)
    {
        flags.setFlag(FREFOBJ, objno);
        if (objno != NO_OBJECT)
        {
            flags.setFlag(FREFOBJLOC, this.getObjectLocation(objno));
            flags.setFlag(FREFOBJWEIGHT, DDB.getByte(DDB.header.objWeightContWearPos + objno) & 0x3F);
            if (this.isObjectContainer(objno)) flags.setFlag(FREFOBJCONTAINER, 128); else flags.setFlag(FREFOBJCONTAINER, 0);
            if (this.isObjectWearable(objno)) flags.setFlag(FREFOBJWEARABLE, 128); else flags.setFlag(FREFOBJWEARABLE, 0);
            flags.setFlag(FREFOBJATTR2, DDB.getByte(DDB.header.objAttributesPos + objno * 2));
            flags.setFlag(FREFOBJATTR1, DDB.getByte(DDB.header.objAttributesPos + objno * 2 + 1));
            flags.setFlag(FNOUN, DDB.getByte(DDB.header.objNamePos + 2 * objno));
            flags.setFlag(FADJECT, DDB.getByte(DDB.header.objNamePos + 2 * objno + 1));
        }
    }

    isObjectWearable(objno)
    {
        return (DDB.getByte(DDB.header.objWeightContWearPos + objno) & 0x80);
    }

    isObjectContainer(objno)
    {
        return (DDB.getByte(DDB.header.objWeightContWearPos + objno) & 0x40);
    }

    getObjectByVocabularyAtLocation(aNoun, anAdjective, locno)
    {
        var partialMatch = false;
        var result = MAX_OBJECT;
        for(var i=0;i<DDB.header.numObj;i++)
        // if location = MAX_LOCATION, any location is valid
        if ((locno==MAX_LOCATION) || (this.getObjectLocation(i)==locno) )
        {
         var objectNoun = DDB.getByte(DDB.header.objNamePos + i * 2);
         var objectAdject = DDB.getByte(DDB.header.objNamePos + i * 2 + 1);
         // Full match
         if (( (objectNoun != NO_WORD) && (objectNoun == aNoun)) && ((objectAdject == NO_WORD) || (objectAdject == anAdjective))) return i;
        // Partial match. Happens when the player just types the noun and there is not a full match, that's why when there is 
        // a partial match there is no immediate return, as there may be a full match to be found. Otherwise, match is accepted
        // with thet first partial matcha that happens, and that's why wer don't accept a second partial match once one partial
        // match is found.
         if (!partialMatch)
         if ((objectNoun == aNoun) && (anAdjective == NO_WORD))
         {
            partialMatch = true;
            result = i;
         }

        }
        return result;
    }

    getNextObjectAt(objno, locno)
    {
        if (objno == MAX_OBJECT) return MAX_OBJECT;
        else
        {
            if (locno == MAX_LOCATION) locno = flags.getFlag(FPLAYER);
            do
            {
                objno++;
            } while (!((objno == MAX_OBJECT) ||  (this.getObjectLocation(objno) == locno)))
        }
        return objno;
    }

}

class stackElementClass {
    currentProcess = 0;
    processPTR = 0;
    entryPTR = 0;
    condactPTR = 0;
    doallPTR = 0;
    doallentryPTR = 0;
    DoallFlag = 0;
    doallLocation = 0;
}

class stackClass {

    processStack = []; 
    stackPTR = 0;

    constructor()
    {
        this.resetStack();
    }

    resetStack()
    {
        this.processStack = [];
        this.stackPTR = 0;
    }

    stackPop()
    {
        if (!this.stackPTR)
        {
            isTerminated = true;
            return;
        }
        this.stackPTR--;
        var stackElement = this.processStack[this.stackPTR];
        DDB.processPTR = stackElement.processPTR;
        DDB.entryPTR = stackElement.entryPTR;
        DDB.condactPTR = stackElement.condactPTR;
        DDB.doallPTR = stackElement.doallPTR;
        DDB.doallentryPTR = stackElement.doallentryPTR;
        DDB.doallLocation = stackElement.doallLocation;
        flags.setFlag(FDOALL, stackElement.DoallFlag);
        currentProcess = stackElement.currentProcess;
    }

    stackPush()
    {
        var stackElement =  new stackElementClass();
        stackElement.processPTR = DDB.processPTR;
        stackElement.entryPTR = DDB.entryPTR;
        stackElement.condactPTR = DDB.condactPTR;
        stackElement.doallPTR = DDB.doallPTR;
        stackElement.doallentryPTR = DDB.doallentryPTR;
        stackElement.DoallFlag = flags.getFlag(FDOALL);
        stackElement.doallLocation = DDB.doallLocation;
        stackElement.currentProcess = currentProcess;
        this.processStack[this.stackPTR] = stackElement;
        this.stackPTR++;
    }
}

// global vars


var currentProcess = 0;
var inputBuffer = '';
var imageBufferID = false;
var sampleBufferID = false;
var flags = new flagClass();
var objects = new objectClass();
var DDB  = new DDBClass();
var stack  = new stackClass();
var windows = new WindowArrayClass();
var paper; // This will be the 2D context for the canvas
var doublebuffer; // This will be the 2D context for the double buffer canvas
var swapbuffer; // This will be the 2D context for the swap buffer canvas
var graphicsWriteToScreeen = true; // Default graphics writing to screen, not double buffer
var textWriteToScreeen = true; // Default text writing to screen, not double buffer
var audioContext; // This will be default "soundcard"
var previousVerb = NO_WORD;
var playerOrderQuoted = '';
var playerOrder = '';
var conjunctions = [] ;
var globalParseOption = 0; // preseves the option given to PARSE calls (PARSE 0 or PARSE 1), so when the run() loops is broken and handler takes control, it can call back with the proper option
var XmessagePart = 0;
var isMobileDevice = false;
var virtualKeys;
var activeMouse = true;
var mouseX = 0;
var mouseY = 0;
var mouseButtons = 0; 
var audioSFX;
var audioMusic;
var videoPlayer;
var inVideo = false; // If true, the game is in a video, so no input is allowed

var keyBoardStatus = [];

// Global var for the ReadText functions
var ticks = 0;
var timeoutHappened = false;
var timeoutID = null;
var timeoutPreservedOrder = '';
var playerPressedKey = false;
var readTextStr = '';
var inputTakenFromPlayer = false;

// Global Vars for QUIT/END
var YesResponse = '';
var PreserveTimeout = 0;



var condactResult = false;
var done = false;
var Parameter1 = 0;
var Parameter2 = 0;
var inPARSE = false;
var inANYKEY = false;
var inEND = false;
var inQUIT = false;
var inINKEY = false;
var inSAVE = false;
var inLOAD = false;
var inMORE =false; // Unlike the others, it's not a first level status variable, it's a type of inANYKEY. So there could be inANYKEY=true, inMORE=true (when on More..) and inAnykey=true, inMORE=false (when on ANYKEY)
var isTerminated = false;

var patchedStr = '';
var writeTextBuffer = ''; //Keeps the text that should be printed after a "More..." prompt
var writeTextDone = false; // Keeps the "done" status when a text is split for "More..."

// DAAD Main loop. Please notice this funcion differs from the original function with the same name in PCDAAD. The main issue
// I faced is Javascript is a monothreaded execution language, whose only way to get keystrokes is via events that only happen
// when there is no job working. That is a problem for condActs like INKEY, ANYKEY and PARSE (if the player input is required).
// In PCDAAD, you never leave run() procedure, in jDAAD, you need to leave, and in fact stop javascript execution, when you
// have to wait or check for a key. When that happens, run() is terminated but the onkeydown handler is active,  so keystrokes
// are received. When received, the onKeyDown handlers knows if DAAD is inside INKEY, ANYKEY or PARSE execution and reacts
// accordingly. When the handler considers the condact is over, he will call run() again, but with the proper parameters, so 
// the execution is returned where it was before existing run(), just like naturally happens in the Pascal version. 

// Aside of that, Javascript does not support GOTO, and although labeled continues can do something similar with backward jumps,
// there is not a good way of doing forward jumps, so the code has become more complicated to read. As I stated before,  in
// the Pascal version, it can be done with GOTOs, and it's much more readable. Here you have the worse readable version.

function run(skipToRunCondact)
{
 done = false;

 //Where a new entry is considered and evaluated}
 RunEntry: while (true)
 {
    //Check if current process has finished}
    if (!skipToRunCondact)
    {
        if (DDB.getByte(DDB.entryPTR) == END_OF_PROCESS_MARK) 
        {
            debug('    EOP', 'terminator');
            var moreDOALL = false;
            //If DOALL loop in execution}
            if (DDB.doallPTR != 0)
            {
                debug('In Doall');

                do
                {
                    // Try to get next object at the doall location
                    var nextDoallObjno = objects.getNextObjectAt(flags.getFlag(FDOALL), DDB.doallLocation);
                    //If a valid object found jump back to DOALL entry/condact}
                    if (nextDoallObjno != MAX_OBJECT) 
                    {
                        objects.setReferencedObject(nextDoallObjno);
                        flags.setFlag(FDOALL, nextDoallObjno);
                        if ((flags.getFlag(FNOUN) == flags.getFlag(FNOUN2)) && ((flags.getFlag(FADJECT) == flags.getFlag(FADJECT2)) || (flags.getFlag(FADJECT) == NO_WORD) || (flags.getFlag(FADJECT2) == NO_WORD))) 
                        {
                            debug('"Except" applied to Doall, skipping object');
                            continue;
                        }


                        DDB.entryPTR = DDB.doallEntryPTR;
                        DDB.condactPTR =  DDB.doallPTR;
                        debug('Next DOALL Object:' + nextDoallObjno);
                        skipToRunCondact = true;
                        moreDOALL = true;
                        break;
                    }
                    else  
                    {
                        //If in DOALL but no more objects mark doall inactive and just let 
                        //the process continue and finish normally}
                        debug('No more DOALL Objets');
                        DDB.doallPTR = 0; 
                        break;
                    }

                } while (true);


            }
            
            if (!moreDOALL)
            {
                debug ('Process '+currentProcess+' finished.')
            //process finishes normally
                stack.stackPop();
                debug ('Process ' + currentProcess + ' continues...')
                if (isTerminated) 
                {
                    $('.goodbye').show();
                    return; // Exits from run(), forever.
                }
                DDB.condactPTR++;
                skipToRunCondact = true; // Goes to runCondact because when a process finishes, and after POP, you just have to run next condact after the PROCESS call
            }
        }
    }

    if (!skipToRunCondact)
    {
        var ValidEntry = ((DDB.getByte(DDB.entryPTR) == flags.getFlag(FVERB)) || (DDB.getByte(DDB.entryPTR) == NO_WORD))
             && ((DDB.getByte(DDB.entryPTR+1) == flags.getFlag(FNOUN)) || (DDB.getByte(DDB.entryPTR+1) == NO_WORD));

        DDB.condactPTR = DDB.getWord(DDB.entryPTR + 2);

        if (!ValidEntry)
        {
            DDB.entryPTR += 4;
            continue RunEntry;
        }
        debug('> ' + getWordByCodeType(DDB.getByte(DDB.entryPTR),VOC_VERB) + ' ' + getWordByCodeType(DDB.getByte(DDB.entryPTR+1), VOC_NOUN) + ''.padEnd(50,' ') , 'entry');

    }   

    RunCondact: while (true)
    {
        skipToRunCondact = false;

        if (!inINKEY)
        {
            // First check if there's pending text to write
            if (writeTextBuffer!='')
            {
                while(writeTextBuffer!='')
                {
                    done =writeTextDone;
                    writeText('');
                    if (inMORE) return; // If still more text to write, get out from run() as we are in More...
                }
                DDB.condactPTR++;
                // If the text pending to write was part of the PARSE, SAVE, LOAD etc. text output, get out of run() as we are still waiting for player orders
                if (inQUIT || inEND || inSAVE || inLOAD || inPARSE) return;
                done =false;
            }
            

            //Then check if no more condacts in the entry, if so, move to next entry
            
            condactResult = true;
            var opcode = DDB.getByte(DDB.condactPTR);
            if (opcode == END_OF_CONDACTS_MARK)
            {
                debug('    EOC', 'terminator');
                DDB.entryPTR += 4;
                continue RunEntry;
            }

            //These flags should have specific values that code can use to determine the machine running the DDB
            // so they are being set after every condact to make sure even when modified, their value is restored
            flags.setFlag(FSCREENMODE, 14 + 128); //Makes sure flag 62 has proper value: mode 14 (JDAAD Screen) and bit 7 set
            flags.setFlag(FMOUSE, 128 + 1); //Makes sure flag 29 has "graphics" available set, and mouse available set,  and the rest is empty}

            //Let's run the condact
            var indirection =  ((opcode & 0x80) != 0) 
            if (indirection) opcode &= 0x7F;
            var debugStr = condactTable[opcode].condactName + ' ';
            var  condactStyle = 'condact';
            if ((debugStr == 'DONE    ') || (debugStr == 'NOTDONE ') || (debugStr == 'RESTART ') || (debugStr == 'REDO    ') || (debugStr == 'END     ') || (debugStr == 'OK      ')) condactStyle = 'terminator'; 
            
            //get parameters
            if (condactTable[opcode].numParams > 0) 
            {
                DDB.condactPTR++;
                Parameter1 = DDB.getByte(DDB.condactPTR);
                debugStr = debugStr + (indirection?'@':'') + Parameter1;
                if (indirection)
                {
                    var PrevParameter1 = Parameter1;
                    Parameter1 = flags.getFlag(Parameter1);  
                    debugStr += '                 ( @' + PrevParameter1 + ' = ' + Parameter1 + ' )';
                }
                
                if (condactTable[opcode].numParams>1) 
                {
                    DDB.condactPTR++;
                    Parameter2 = DDB.getByte(DDB.condactPTR);
                    debugStr = debugStr + ' ' + Parameter2;
                }
            }
            
            debug('    ' + debugStr, condactStyle);
            //run condact
            condactResult = true;
            playerPressedKey = false;
            condactTable[opcode].condactRoutine(); //Execute the condact
            if (inPARSE || inANYKEY || inQUIT ||inEND || inSAVE || inLOAD || inINKEY)  return; // get out of main loop as we are now just waiting for keypress (or waiting for a key event in the case of inINKEY)
        } else inINKEY=false;
        //If condact execution failed, go to next entry
        if (!condactResult) 
        {
            DDB.entryPTR +=4;
            continue RunEntry;
        }
        //otherwise go to next condact}
        DDB.condactPTR++;
        continue RunCondact; 
    } // while(true) de RunCondact
 } // while(true) de RunEntry
}


// Aux functions


String.prototype.hexEncode = function(){
    var hex, i;

    var result = "";
    for (i=0; i<this.length; i++) {
        hex = this.charCodeAt(i).toString(16);
        result += ("000"+hex).slice(-4);
    }

    return result
}


function initializeParser()
{
    //Clears the input buffer}
    inputBuffer = '';
    // Creates the Conjunctions array}
    var ptr = DDB.header.vocabularyPos;
    while (DDB.getByte(ptr)!= 0) 
    {
        if (VOC_TYPE.indexOf(DDB.getByte(ptr+6)) == VOC_CONJUGATION)
        {
        var aVocWord = '';
        for (var i=0;i<WORD_LENGHT;i++)
                if ((DDB.getByte(ptr+i) ^ OFUSCATE_VALUE)!=32) 
                    aVocWord+= String.fromCharCode(DDB.getByte(ptr+i) ^ OFUSCATE_VALUE); 

                //Conjunctions are saved with leading and trailing spaces because that
                //way is how it should be found in player orders.
                if (conjunctions.length ==  MAX_CONJUNCTIONS) Error(5,'Too many conjunctions. Maximum accepted is ' + MAX_CONJUNCTIONS);
                conjunctions.push(' ' + aVocWord.toUpperCase() + ' ');
        };
        ptr+=7; //point to next word
    } //while
};


function getKeyCodeFromKey(key)
{
    if (key.length == 1) return key.charCodeAt(0);
    switch(key.toUpperCase())
    {
        case 'BACKSPACE': return 8; break;
        case 'ENTER': return 13; break;
    }
    return 0;
}

function fixSpanishCharacters(str)
{
  var encodeStr = 'º¡¿«»áéíóúñÑçÇüÜ';
  var output = '';
  for (var i=0;i<str.length;i++) 
  {
        var c = str.charAt(i);
        switch(c)
        {
        case 'ñ': c = 'Ñ';break;
        case 'ç': c = 'Ç';break;
        case 'á':
        case 'Á': c ='A';break;
        case 'é':
        case 'É': c ='E';break;
        case 'í':
        case 'Í': c ='I';break;
        case 'ó':
        case 'Ó': c ='O';break;
        case 'ú':
        case 'Ú':
        case 'Ü': 
        case 'ü': c ='U';break;
        }
        if (encodeStr.indexOf(c)!=-1) output += String.fromCharCode(16 + encodeStr.indexOf(c));
        else output += c
    }
    return output; 
}


function getCommand()
{
        inputBuffer = '';
        var thePrompt = getMessage(DDB.header.sysmessPos, SM33);
        //When the prompt appears the last pause line of all windows is resetted
        inputBuffer = readText(thePrompt); //fromEvent = false
}

function getCommandB()
{
        //The inputBuffer may come with Spanish characters that we need to convert to where DAAD stores them in the ASCII Table
        if (DDB.isSpanish()) inputBuffer = fixSpanishCharacters(inputBuffer);
        getPlayerOrdersB();
}


function findWord(aWord, aVocType)
{
    var Result = {};
    var ptr = DDB.header.vocabularyPos;
    Result.aCode = -1;
    aWord = aWord.toUpperCase();
    while (DDB.getByte(ptr)!= 0) 
    {
        //Get a word from Vocabulary
        var aVocWord = '';
        for(var i=0; i < WORD_LENGHT;i++)
            if ((DDB.getByte(ptr+i) ^ OFUSCATE_VALUE)!=32) 
            aVocWord  += String.fromCharCode(DDB.getByte(ptr+i) ^ OFUSCATE_VALUE); 
        

        //If matches text and type, or type is VOC_ANY
        if (aWord == aVocWord)  
            if ((aVocType == VOC_ANY) || (aVocType == VOC_TYPE.indexOf(DDB.getByte(ptr+6)))) 
            {
                Result.aCode = DDB.getByte(ptr+5);
                Result.aType = VOC_TYPE.indexOf(DDB.getByte(ptr+6));
                return Result;
            }	
        ptr+=7;
    } //While
    return Result;
}

function getWordByCodeType(aCode, aVocType)
{
    if (aCode == NO_WORD) return '_';
    
    var ptr = DDB.header.vocabularyPos;   
    while (DDB.getByte(ptr)!= 0) 
    {
        //Get a word from Vocabulary
        var aVocWord = '';
        for(var i=0; i < WORD_LENGHT;i++)
            if ((DDB.getByte(ptr+i) ^ OFUSCATE_VALUE)!=32) 
            aVocWord  += String.fromCharCode(DDB.getByte(ptr+i) ^ OFUSCATE_VALUE); 
        

        //If matches text and type, or type is VOC_ANY
        if ( (aVocType == VOC_TYPE.indexOf(DDB.getByte(ptr+6))) && (aCode == DDB.getByte(ptr+5)))
                return aVocWord;
        ptr+=7;
    } //While   
    return '[' + aCode + ']'; // If not found return the code
}


function getPlayerOrders()
{
    getCommand(); 
}

function getPlayerOrdersB()
{
    inputBuffer= inputBuffer.toUpperCase();
    for (var i=0; i< conjunctions.length;i++)
         inputBuffer = inputBuffer.replace(conjunctions[i],'.');

    if (inPARSE)
    {      
        RestoreStream();
        inputTakenFromPlayer = true;
        parseB();
        var result = parseEnd();
        condactResult = ! result;
        done = false;
        inPARSE = false; // Mark we are finishing the interactive part
        for(var i=0;i<NUM_WINDOWS;i++) windows.windows[i].lastPauseLine = 0;
        if (!condactResult) 
        {
            DDB.entryPTR +=4;
            run(false); // false -- go to RunEntry
        }
        else
        {
        //otherwise go to next condact
        DDB.condactPTR++;
        run(true); // true --  go to  RunCondact      
        }

    }
    else
    if (inQUIT)
    {
        inQUIT = false;
        _QUITB();
    }
    else 
    if (inEND)
    {
        inEND=false;
        _ENDB();
    }
    else
    if (inSAVE)
    {
        inSAVE=false;
        _SAVEB();
    }
    else
    if (inLOAD)
    {
        inLOAD=false;
        _LOADB();
    }
}

/* function parse(option) of PCDAAD is split in three parts:

parse(Option) --> Takes care of ensuring we have a order (each of the sentences between separators or conjunction in the player input). To do so, if 
                  it's PARSE 0, and we have still something in the inputBuffer, it calls parseB to extact an order from the buffer, then parseEND()
                  that does the proper parsing. If we don't have anything in the buffer, getPlayerOrders() is called, what means we get out of the
                  run() loop and go to wait for keypresses. The event handler will eventually call parseB(), then parseEnd().
                  In case it was a PARSE 1 or above, we just copy the playerOrderQuoted to playerOrder and call parseEND(); This procedure only 
                  exits the run() loop in case we have to ask for an order to the user.
parseB() ---> Extract a sentence from inputbuffer                  
parseEnd() ---> Properly parses the sentence */

function parse(Option)
{
    globalParseOption = Option; 
    if (globalParseOption == 0) /* parse 0, get order from the player or from orders buffer */
    {
        inputTakenFromPlayer = false;
        if (inputBuffer=='')
        {
            
            inPARSE=true; // Make the keyboardHanlder active as we will ask for an order
            PreserveStream();
            // Print prompt
            if (flags.getFlag(FPROMPT) == 0)
            {
                var i = Math.floor(Math.random(4)*4);
                Sysmess(SM2 + i);
            }
            else if (flags.getFlag(FPROMPT) < DDB.header.numSys) Sysmess(flags.getFlag(FPROMPT));
            
            getPlayerOrders();
            return;
        } 

        parseB();
    }
    else  
    {
        playerOrder = playerOrderQuoted; /* PARSE 1, get order from a quoted sentence in the current LS */
    }
    return parseEnd(playerOrder);
}


function parseB()
{
      //Extract an order
      playerOrder = '';
      var i = 0;
      while ( (!STANDARD_SEPARATORS.includes(inputBuffer.charAt(i))) && (i < inputBuffer.length)) 
      {
          playerOrder +=  inputBuffer.charAt(i);
          i++;
      }

      if (i > inputBuffer.length) inputBuffer = ''; //If finished, we empty the inputBuffer
                              else inputBuffer =  inputBuffer.substring(i+1); //If not , we set it to the remaining after the separator

  
      //Try to find a quoted sentence in the order. If found, text before the quoted setence goes to playerOrder,
      // and text after the quotes is stored in global variable playerOrderQuoted, in case it is later required by PARSE 1
  
      if (playerOrder.indexOf('"') != -1)
      {
          playerOrderQuoted = playerOrder.substring(playerOrder.indexOf('"') + 1);
          if (playerOrderQuoted.indexOf('"') != -1)  playerOrderQuoted = playerOrderQuoted.substring(0, playerOrderQuoted.indexOf('"'));
          playerOrder =  playerOrder.substring(0, playerOrder.indexOf('"'));
      
          //Because orginal interpreters make a difference betwee 'SAY JOHN'  and 'SAY JOHN ""'}
          playerOrderQuoted = playerOrderQuoted.trim();
          if (playerOrderQuoted=='') playerOrderQuoted = ' '; 
      }
      else playerOrderQuoted = '';     
}

function parseEnd()
{
    var result = false;
    if (playerOrder == '') // This can only happen if we get here from a PARSE 1 or above
        return  false; // To force next condact execution 


    playerOrder = playerOrder.trim();
    debug(playerOrder.padEnd(50,' ') , 'parse')
    //remove double spaces
    while (playerOrder.indexOf('  ') != -1) playerOrder.replace('  ',' ');
    //split order into words}
    var orderWords = playerOrder.split(' ');

    //parse the order}
    flags.setFlag(FVERB, NO_WORD);
    flags.setFlag(FNOUN, NO_WORD);
    flags.setFlag(FADJECT, NO_WORD);
    flags.setFlag(FNOUN2, NO_WORD);
    flags.setFlag(FADJECT2, NO_WORD);
    flags.setFlag(FADVERB, NO_WORD);
    flags.setFlag(FPREP, NO_WORD);
    var  pronounInSentence = false;

    var i= 0;
    var orderWordCount = orderWords.length;
    while ((i < orderWordCount) && (orderWords[i]!='') )
    {
        var aSearchWord = orderWords[i]; 
        if (aSearchWord.length>WORD_LENGHT) aSearchWord = aSearchWord.substring(0, WORD_LENGHT);
        var aWordRecord = findWord(aSearchWord, VOC_ANY);
        if (aWordRecord.aCode!= - 1)
        {
            if ((aWordRecord.aType == VOC_VERB) && (flags.getFlag(FVERB) == NO_WORD)) flags.setFlag(FVERB,aWordRecord.aCode); else
            if ((aWordRecord.aType == VOC_NOUN) && (flags.getFlag(FNOUN) == NO_WORD)) flags.setFlag(FNOUN,aWordRecord.aCode); else
            if ((aWordRecord.aType == VOC_NOUN) && (flags.getFlag(FNOUN2) == NO_WORD)) flags.setFlag(FNOUN2,aWordRecord.aCode); else
            if ((aWordRecord.aType == VOC_ADJECT) && (flags.getFlag(FADJECT) == NO_WORD)) flags.setFlag(FADJECT,aWordRecord.aCode); else
            if ((aWordRecord.aType == VOC_ADJECT) && (flags.getFlag(FADJECT2) == NO_WORD)) flags.setFlag(FADJECT2,aWordRecord.aCode); else
            if ((aWordRecord.aType == VOC_PREPOSITION) && (flags.getFlag(FPREP) == NO_WORD)) flags.setFlag(FPREP,aWordRecord.aCode); else
            if ((aWordRecord.aType == VOC_ADVERB) && (flags.getFlag(FADVERB) == NO_WORD)) flags.setFlag(FADVERB,aWordRecord.aCode)
            //If English, pronouns work independently, if Spanish, pronouns are applied a pronominal suffixes}
            else if ((! DDB.isSpanish()) && (aWordRecord.aType == VOC_PRONOUN) && (! pronounInSentence))
            {
                pronounInSentence = true;
                if (flags.getFlag(FNOUN)==NO_WORD)
                {
                    flags.setFlag(FNOUN, flags.getFlag(FPRONOUN));
                    flags.setFlag(FADJECT, flags.getFlag(FPRONOUN_ADJECT));
                }
            }

            //If Spanish, check pronominal terminations
            if (DDB.isSpanish()) 
            {
                if ((aWordRecord.aType == VOC_VERB) && (!pronounInSentence))
                {
                    var j = 0;
                    while ((j<4) && (!pronounInSentence)) 
                    {
                    //check if the verb ends with one of the pronominal suffixes
                        if (orderWords[i].toUpperCase().indexOf(SPANISH_TERMINATIONS[j]) == orderWords[i].length - SPANISH_TERMINATIONS[j].length)
                        {
                            //If we have a word ending with pronominal suffixes, we need to check whether the word is a verb 
                            //also without the termination, to avoid the HABLA bug where "LA" is part of the verb habLAr and
                            //not a suffix. So first we remove the termination:}
                            aSearchWord =  orderWords[i].substring(0, orderWords[i].length - SPANISH_TERMINATIONS[j].length);
                            if (aSearchWord.length>WORD_LENGHT) aSearchWord = aSearchWord.substring(0, WORD_LENGHT);

                            //Then check if still can be recognized as a verb}
                            aWordRecord = findWord(aSearchWord, VOC_VERB);
                            if (aWordRecord.aCode!=-1)
                            {
                                pronounInSentence = true;
                                if (flags.getFlag(FNOUN)==NO_WORD)
                                {
                                    flags.setFlag(FNOUN, flags.getFlag(FPRONOUN));
                                    flags.setFlag(FADJECT, flags.getFlag(FPRONOUN_ADJECT));
                                }
                            }  
                            //Please notice the word has to be first recognized as verb, so all Spanish verbs which are not
                            //5 characters long should have synonyms including the suffix or part of it: DAR->DARLO, COGE->COGEL}
                        }
                    j++;
                    };  /* loop over the terminations */
                }; /* if a Verb and no pronoun */
            }; //If IsSpanish
        }; //if aWordRecord.aCode != -1
        i++;
    }; //while

    
    //Convertible nouns
    if (globalParseOption == 0) // Nouns are not converted if PARSE 1 is called in original interpreters
    if ((flags.getFlag(FVERB)==NO_WORD) && (flags.getFlag(FNOUN)<=LAST_CONVERTIBLE_NOUN) )
        flags.setFlag(FVERB, flags.getFlag(FNOUN));
        //Note: flag fNoun is not altered, when converting noun to verb original DAAD just copies noun to verb,
        //    so both verb and noun has same code
         
    //Missing verb but present noun, replace with previous verb}
    if (!inputTakenFromPlayer)  //If the current sentece came from buffer
    if ((flags.getFlag(FVERB)==NO_WORD) && (flags.getFlag(FNOUN)!=NO_WORD) && (previousVerb!=NO_WORD))  flags.setFlag(FVERB, previousVerb);

    //Apply pronouns or terminations if needed
    if ((flags.getFlag(FNOUN)==NO_WORD) && (pronounInSentence) &&  (flags.getFlag(FPRONOUN)!=NO_WORD) )
    {
        flags.setFlag(FNOUN, flags.getFlag(FPRONOUN));
        flags.setFlag(FADJECT, flags.getFlag(FPRONOUN_ADJECT));
    }

    //Save noun and adject from LS to maybe be used in future orders, unless they are proper names ( < 50 )}
    if ((flags.getFlag(FNOUN)>=LAST_PROPER_NOUN) && (flags.getFlag(FNOUN)!=NO_WORD))
    {
        flags.setFlag(FPRONOUN, flags.getFlag(FNOUN));
        flags.setFlag(FPRONOUN_ADJECT, flags.getFlag(FADJECT));
    }

    //Preserve verb to be used by next sentence}
    if (flags.getFlag(FVERB)!=NO_WORD) previousVerb = flags.getFlag(FVERB);

    if ((flags.getFlag(FVERB)!=NO_WORD) || (flags.getFlag(FNOUN)!=NO_WORD)) result = true;
    
    return result || (globalParseOption>0);
}

function setCharAt(str,index,chr) {
    if(index > str.length-1) return str;
    return str.substring(0,index) + chr + str.substring(index+1);
}

function replaceArticles(str, replace, caps, stopAtDot)
{

    if (replace || stopAtDot) //when any of these options is ON, we also have to remove leading spaces
        while (str.charAt(0) == ' ') str = str.substring(1);

    if (stopAtDot) 
        if (str.indexOf('.') != -1) str = str.substring(0,str.indexOf('.'));

    if (replace)
    {
       

        if (DDB.isSpanish())
        {
            //un -> el
            if ((str.charAt(0).toUpperCase() == 'U') && (str.charAt(1).toUpperCase() == 'N') && (str.charAt(2)==' ')) 
            {
                var newArticle = 'el';
                if (caps) newArticle = 'El';
                return newArticle + str.substring(2);
            }
        
            //una, unos, unas --> la, los, las}
            if ((str.charAt(0).toUpperCase() == 'U') && (str.charAt(1).toUpperCase() == 'N')) 
            {
                if (caps) newArticle = 'L'; else newArticle = 'l';
                return newArticle + str.substring(2);
            }
        }
        else //In English, we have to remove the first word, whatever it is (if there)
        {
            
           if (str.indexOf(' ') != -1) str = str.substring(str.indexOf(' ')+1);
        }
    }//if replace
    return str;  
}


function getToken(id)
{
    var index = 0;
    var ptr = DDB.header.tokenPos + 1; //Apparently, token table starts one byte after the token pointer
    while (index < id) 
    {
     if (DDB.getByte(ptr) > 127) index++;
     ptr++;
    }
   
    var auxStr = '';
    while (DDB.getByte(ptr) <= 127) 
    {
        auxStr += String.fromCharCode(DDB.getByte(ptr));
        ptr++;
    }
    auxStr += String.fromCharCode(DDB.getByte(ptr) & 127);
    return auxStr.replace('_',' ');
}


function getMessageInternal(tableOffset, messageNumber)
{
    var workStr = '';
    var ptr = DDB.getWord(tableOffset + 2 * messageNumber);
    DDB.previousWasCR = false;
    var aByte = DDB.getByte(ptr);
    while ( (aByte != (0x0a ^ OFUSCATE_VALUE))  ) 
    {       
        if (aByte < 128) 
        {
            var tokenID = (aByte ^ OFUSCATE_VALUE) - 128;
            var token = getToken(tokenID);
            workStr += token
        }
        else 
        {
            var mychar = String.fromCharCode(aByte ^ OFUSCATE_VALUE);
            if ((mychar == ESCAPE_OBJNAME) || ((mychar == ESCAPE_OBJNAME_CAPS) && DDB.isSpanish()) )
            {
                var escapeText = getMessageInternal(DDB.header.objectPos, flags.getFlag(FREFOBJ));
                escapeText = replaceArticles(escapeText, true, aByte == ESCAPE_OBJNAME_CAPS, true);
                workStr += escapeText;
            } 
            else workStr += mychar;
        }  
        ptr++;
        aByte = DDB.getByte(ptr);
    }   
    debug(workStr, 'text');
    return workStr;
}

function getMessage(tableOffset, mesno)
{
    return getMessageInternal(tableOffset, mesno);
}

function getMessageOTX(objno, replace,  caps, stopAtDot)
{
    var escapeText = getMessageInternal(DDB.header.objectPos, objno);
    return escapeText = replaceArticles(escapeText, replace,  caps, stopAtDot);
}

function debug(string, style='normal')
{
    var css = 'background: #fff; color: #000';
    switch (style)
    {
        case 'normal': css = 'background: #fff; color: #000'; break;
        case 'condact': css = 'background: #fff; color: blue; '; break;
        case 'terminator' : css = 'background: #fff; color: #000099; font-weight: bold '; break;
        case 'text': css = 'background: #ffd; color: #000;'; break;
        case 'parse': css = 'background: #dfd; color: #000; border:  1px dotted black; padding: 4px; border-radius: 5px'; break;
        case 'entry': css = 'background: #eff; color: #000;  border: 1px dotted black; padding: 4px; border-radius: 5px'; break;
        case 'development': css = 'background: #f00; color: #ffff;  border: 2px fixed black; padding: 10px; border-radius: 10px'; break;
    }

    if (string.substr(string.length - 1) == CR) string +='[CR]';

    if (DEBUG_ENABLED) console.log('%c ' + string, css);
}

function clickHandler(e)
{
    if (inANYKEY)
    {
        e.preventDefault();
        e.stopPropagation();
        if (!inMORE) DDB.condactPTR++; // Point to next condact
        inANYKEY = inMORE = false;
        for(var i=0;i<NUM_WINDOWS;i++) windows.windows[i].lastPauseLine = 0;
        run(true); // skipToRunCondact = true
    }
}

function keyupHandler(e)
{
    //Save keyup status for each key to be used with INKEY
    var keyCode = getKeyCodeFromKey(e.key);
    if (keyBoardStatus.includes(keyCode)) keyBoardStatus.splice(keyBoardStatus.indexOf(keyCode));
}


function isSpecialKey(key)
{
    if (key == 'F5') return true; 
    if (key == 'F12') return true; 
}

function keydownHandler(e)
{
    if (inVideo)
    {
      if (e.key.toUpperCase()=='ESCAPE')
      {
        $('#paper').show();
        videoPlayer.pause();
        inVideo = false;
      }
    }
    else
    {

    
        if (!isSpecialKey(e.key)) 
        {

            playerPressedKey = true;

            //Save keydown status for each key to be used with INKEY    
            var keyCode = getKeyCodeFromKey(e.key);
            if ((keyBoardStatus) && (!keyBoardStatus.includes(keyCode))) keyBoardStatus.push(getKeyCodeFromKey(e.key)); 

            if (inANYKEY)
            {
                e.preventDefault();
                e.stopPropagation();   
                if (!inMORE) DDB.condactPTR++; // Point to next condact
                inANYKEY = inMORE = false;
                for(var i=0;i<NUM_WINDOWS;i++) windows.windows[i].lastPauseLine = 0;
                run(true); // skipToRunCondact = true
                return;
            }


            if (inQUIT || inEND || inSAVE || inLOAD || inPARSE)
            {
                    readTextB(e.key);
                    return;
            } 
        }
    }
}

function inputTimeoutHandler()
{

    var control = flags.getFlag(FTIMEOUT_CONTROL);
    if (inPARSE)
    {
        if (timeoutID!= null) clearTimeout(timeoutID);
        // If timeout active in any case (bit 0 cleared), or timeout active only when player hasn't pressed a key (bit 0 set), and player hasn't pressed a key       
        if (((control & 1) == 0) || (((control & 1) == 1) && (!playerPressedKey))) 
        {
            flags.setFlag(FTIMEOUT_CONTROL, flags.getFlag(FTIMEOUT_CONTROL) | 0x80); // Set the timeout happened flag
            timeoutPreservedOrder = readTextStr;
            if (timeoutPreservedOrder!='') flags.setFlag(FTIMEOUT_CONTROL, flags.getFlag(FTIMEOUT_CONTROL) | 0x40);
                                    else flags.setFlag(FTIMEOUT_CONTROL, flags.getFlag(FTIMEOUT_CONTROL) & 0xBF); 
            inputBuffer = readTextStr = '';
            carriageReturn(); 
            inPARSE = false; // Mark we are finishing the interactive part
            for(var i=0;i<NUM_WINDOWS;i++) windows.windows[i].lastPauseLine = 0;
            DDB.condactPTR++;
            run(true);       
        }
    }
    if (inANYKEY)
    {
        if (timeoutID!= null) clearTimeout(timeoutID);
        // we don't check the flag to know if timeout can happen in ANYKEY because the timeout handler is only started in ANYKEY if the bit flag is set
        if (!inMORE) DDB.condactPTR++; // Point to next condact
        inANYKEY = inMORE = false;
        for(var i=0;i<NUM_WINDOWS;i++) windows.windows[i].lastPauseLine = 0;
        run(true); // skipToRunCondact = true
    }
}

function Extern(a, b)
{
    if (typeof externHandlers === "undefined") // Extern hasn't been loaded
    {
        var script = document.createElement("script");
        script.setAttribute("type", "text/javascript");
        script.setAttribute("src", 'extern' + '.js');
        document.getElementsByTagName("head")[0].appendChild(script);

        return new Promise(() => {
            script.onload = function() {
                var callFunction = externHandlers[b];
                callFunction(a);
            }
        })
    }

    if (typeof externHandlers !== "undefined") {
        var callFunction = externHandlers[b];
        callFunction(a);
    }
}


function delay(seconds)
{
    var milliseconds = seconds * 1000;
    var start = Date.now();
    var now = start;
    while (now - start < milliseconds) now = Date.now();    
}


function clearWindow(X, Y, width, height, paperColor, isText)
{
    if (width>=318) width = 320; 
    var currentContext = paper;
    // We assume most of time we are clearing we do it on text areas (i.e. prompt, text scroll, etc.
    // There is CLS though, whichc clears partof the screen, and you never know what is there
    // Anyway, design decision is to use the double buffer for clearing only if textWriteToScreeen is true, not when graphicsWriteToScreeen is true
    if (isText && !textWriteToScreeen) currentContext = doublebuffer
    paper.fillStyle = getFillStyle(paperColor);
    paper.fillRect(X, Y, width, height)

}

function Printat(line, col)
{
    if ((line < windows.windows[windows.activeWindow].height) && (col < windows.windows[windows.activeWindow].width))
    {
        windows.windows[windows.activeWindow].CurrentY = line * LINE_HEIGHT;
        windows.windows[windows.activeWindow].CurrentX = col * COLUMN_WIDTH;
    }
   
}

function Tab(col)
{
   if (col < windows.windows[windows.activeWindow].width)  windows.windows[windows.activeWindow].CurrentX = (windows.windows[windows.activeWindow].col + col) * COLUMN_WIDTH;
        else Tab(0);   //Tested in ZX Spectrum interpreter: when the column provided exceeds the window,  then it's like TAB 0,  beginning of line
   }

function SaveAt()
{
    windows.windows[windows.activeWindow].BackupCurrentY = windows.windows[windows.activeWindow].currentY;
    windows.windows[windows.activeWindow].BackupCurrentX = windows.windows[windows.activeWindow].CurrentX;
}

function BackAt()
{
    windows.windows[windows.activeWindow].currentY = windows.windows[windows.activeWindow].backupCurrentY;
    windows.windows[windows.activeWindow].currentX = windows.windows[windows.activeWindow].backupCurrentX;
}

function doSave(filename)
{
    var savegameData = [];
    for (var i=0;i<NUM_FLAGS;i++) savegameData.push(flags.getFlag(i));
    for (var i=0;i<NUM_OBJECTS;i++) savegameData.push(objects.getObjectLocation(i));
    filename = filename.hexEncode();
    localStorage.removeItem(filename);
    localStorage.setItem(filename, JSON.stringify(savegameData));
}

function doLoad(filename) 
{
    filename = filename.hexEncode();
    var data = localStorage.getItem(filename);
    if (data == null)
    {
        Sysmess(SM57); // I/O error
        return false;
    } 
    else
    {
        data = JSON.parse(data);
        for (var i=0;i<NUM_FLAGS;i++) flags.setFlag(i, data[i]);
        for (var i=0;i<NUM_OBJECTS;i++) objects.setObjectLocation(i, data[i+NUM_FLAGS]);
        return true;
    }
}

function getVideoAddr(X, Y)
{
 return  X + Y * RESOLUTION_X;
}

function getFillStyle(colour)
{

    var r = colours[colour][0];
    var g = colours[colour][1];
    var b = colours[colour][2];
    var rhex = r.toString(16); if (rhex.length < 2) rhex = '0' + rhex;
    var ghex = g.toString(16); if (ghex.length < 2) ghex = '0' + ghex;
    var bhex = b.toString(16); if (bhex.length < 2) bhex = '0' + bhex;
    
    return ('#' + rhex + ghex + bhex).toUpperCase() ;

}


function pixelRGB(x, y, r, g, b, isText)
{
    var rhex = r.toString(16); if (rhex.length < 2) rhex = '0' + rhex;
    var ghex = g.toString(16); if (ghex.length < 2) ghex = '0' + ghex;
    var bhex = b.toString(16); if (bhex.length < 2) bhex = '0' + bhex;
    var colorCode = ('#' + rhex + ghex + bhex).toUpperCase() ;
    var currentContext = paper;
    if (isText && !textWriteToScreeen) currentContext = doublebuffer; // If text and text is not to be written to screen, use doublebuffer
    if (!isText && !graphicsWriteToScreeen) currentContext = doublebuffer; // If graphics and graphics are not to be written to screen, use doublebuffer
    currentContext.fillStyle = colorCode;
    currentContext.fillRect(x,y,1,1);
}


function pixel(x,y, colour)
{
    pixelRGB(x, y, colours[colour][0],colours[colour][1], colours[colour][2], true);
}


function writeChar(c)
{
    windows.lastPrintedIsCR = false;
    switch(c)
    {
        case 0x0E : windows.charsetShift  =128; break; //#g
        case 0x0F : windows.charsetShift  =0; break; // #t
        case 0x0B : clearCurrentWindow();break; //#b
        default:
        {
            if (windows.windows[windows.activeWindow].currentX + COLUMN_WIDTH > (windows.windows[windows.activeWindow].col + windows.windows[windows.activeWindow].width) * COLUMN_WIDTH ) 
            {
                carriageReturn();
                writeChar(c);
            }
            else
            {
                for (var i=0;i<8;i++)
                {
                    var scan = font[(c + windows.charsetShift) % 256 * 8 + i];  //Get definition for this scanline
                    scan = scan >> (8-COLUMN_WIDTH);
                    for (var j=0;j<COLUMN_WIDTH;j++)
                    {
                        if ((scan & (1 << (COLUMN_WIDTH - j))) != 0) pixel(windows.windows[windows.activeWindow].currentX + j, windows.windows[windows.activeWindow].currentY + i, windows.windows[windows.activeWindow].INK);
                                                                else pixel(windows.windows[windows.activeWindow].currentX + j, windows.windows[windows.activeWindow].currentY + i, windows.windows[windows.activeWindow].PAPER);
                    }
                }
            }
            windows.windows[windows.activeWindow].currentX = windows.windows[windows.activeWindow].currentX + COLUMN_WIDTH; 
        }
    } // switch(c)
}

function StrLenInPixels(Str)
{
    return Str.length * 6;
}

function writeWord(aWord)
{
    var Xlimit = (windows.windows[windows.activeWindow].col +  windows.windows[windows.activeWindow].width) * COLUMN_WIDTH; //First pixel out of the window}
    
    if (StrLenInPixels(aWord) + windows.windows[windows.activeWindow].currentX > Xlimit) carriageReturn();
    if  (!windows.lastPrintedIsCR  || (aWord!=' '))
        for (var i = 0; i<aWord.length;i++) writeChar(aWord.charCodeAt(i));
}

function getLastFittingChar(aText) // Given a text, calculates until which character will fit on screen without having to scroll
{
    var originalAtext = aText;


    var remainingLines  = windows.windows[windows.activeWindow].height - windows.windows[windows.activeWindow].lastPauseLine ;
    if (!remainingLines) return 0; // Not a single character will fit

    

    //Now let's calculate how much text will fit in the remaining space. To do that we will have an array of pixel width per remaining line
    var remainingPixelsperLine = [];
    var windowWidth = windows.windows[windows.activeWindow].width * COLUMN_WIDTH;
    remainingPixelsperLine.push(windows.windows[windows.activeWindow].col * COLUMN_WIDTH + windowWidth - windows.windows[windows.activeWindow].currentX); // push remaining pixels for current line
    for (var j=0;j<remainingLines-1;j++) remainingPixelsperLine.push(windows.windows[windows.activeWindow].width * COLUMN_WIDTH); // Push full width lines for the rest of lines

    var fittingStr = ''; // The string that will eventually fit
    
    for (var currentRemainingline=0; currentRemainingline < remainingPixelsperLine.length ; currentRemainingline++)
    {
        var trailingSpaceRemoved = false;
        if ((currentRemainingline!=0) && (aText.substring(0,1)==' ')) 
        {
            aText = aText.substring(1); // If we are in a new line, and the first character is a space, we remove it
            trailingSpaceRemoved = true;
        }

        var tempStr = aText.substring(0,remainingPixelsperLine[currentRemainingline] / COLUMN_WIDTH + 1); // Get the text that will fit in the current line plus one character      
        var CRpos = tempStr.indexOf(CR);   // If a CR is in the string we shorten the string to the CR
        if (CRpos != -1) 
        {
            // Si es la última línea, ese CR provocaría un scroll que no deseamos, así que cortamos la cadena justo 
            // antes del CR, y dejamos este para la parte
            if (currentRemainingline==remainingPixelsperLine.length-1) 
            {
                aText = aText.substring(CRpos);
                tempStr = tempStr.substring(0,CRpos);
                fittingStr = fittingStr + (trailingSpaceRemoved?' ':'') + tempStr;
            }
            else
            {
                aText = aText.substring(CRpos + 1);
                tempStr = tempStr.substring(0,CRpos);
                fittingStr = fittingStr + (trailingSpaceRemoved?' ':'') + tempStr + CR;
            }
            if (aText.length==0) break; // If we have no more text to process, we are done
        }
        else    //Otherwise, we shorten it to the last space
        {
            if (tempStr !=  aText) // otherwise, the whole text fits in the current line so our text to be taken is the whole remaining text
            {
                if (tempStr.slice(-1) == ' ')  //if the extra character happens to be a space
                {
                    tempStr = tempStr.substring(0,tempStr.length - 1);
                }
                else    // Otherwise, we look back for the last space, after removing that extra one.
                {
                    tempStr = tempStr.substring(0,tempStr.length - 1); // remove extra character
                    while ((tempStr!='') && (tempStr.slice(-1)!=' ')) tempStr = tempStr.substring(0,tempStr.length - 1); // Look back for the space
                }   
            }
            // Once we have the text that would actually fit, we add it to the fitting string, and remove it from the original string
            aText = aText.substring(tempStr.length);
            fittingStr = fittingStr + (trailingSpaceRemoved?' ':'') + tempStr;      
            if (aText.length==0) break; // If we have no more text to process, we are done
        }
    }
    // return last valid character from aText
    if (originalAtext == fittingStr) return -1; else return fittingStr.length;
 }




   

//Writes any text to output
function writeText(aText)
{   
    // 1.- Recover the buffer
    aText = writeTextBuffer + aText;
    writeTextBuffer = '';
    // 2.- Check for #k forced pause
    var sharpKpos = aText.indexOf(String.fromCharCode(0x0C));
    if (sharpKpos!=-1)
    {
        writeTextBuffer = aText.substring(sharpKpos + 1);
        aText = aText.substring(0, sharpKpos);
        inANYKEY = inMORE = true;  // this will make execution stop after whatever condact has called this writeText
        writeTextDone = done;
        if (flags.getFlag(FTIMEOUT)) // Start timeout
        if (flags.getFlag(FTIMEOUT_CONTROL) & 0x02) // If timeout is active in More.. (bit 1 set)
            timeoutID = setTimeout(function() { 
                inputTimeoutHandler();        
            }, flags.getFlag(FTIMEOUT)*1000);
    } 

    // 3.- check if text will fit in remaining non-scroll window

    var lastFittingChar = getLastFittingChar(aText);
    if (lastFittingChar!=-1)
    {
        writeTextBuffer = aText.substring(lastFittingChar);
        aText = aText.substring(0, lastFittingChar );
        inANYKEY = inMORE = true;  // this will make execution stop after whatever condact has called this writeText
        writeTextDone = done;
        if (flags.getFlag(FTIMEOUT)) // Start timeout
        if (flags.getFlag(FTIMEOUT_CONTROL) & 0x02) // If timeout is active in More.. (bit 1 set)
            timeoutID = setTimeout(function() { 
                inputTimeoutHandler();        
            }, flags.getFlag(FTIMEOUT)*1000);
    }

    
    
    
    // 4.- Print what it should be printed now
    var aWord = '';
    for (var i=0; i < aText.length ; i++)
    {
        switch(aText.charCodeAt(i))
        {
            case 13: writeWord(aWord);
                     aWord='';
                     carriageReturn();
                     break
            case 32: writeWord(aWord);
                     aWord='';
                     if (!windows.lastPrintedIsCR) writeWord(' '); // if we are not at the end of the line, write the seporator space
                     break;
            default: aWord  = aWord + aText.charAt(i); 
                     break;
        }
    }
    writeWord(aWord);
}

function PatchStr(Str)
{
 var finalStr ='';
 for (var i=0;i<Str.length;i++)
 switch(Str.charAt(i))
 {
   // Original DAAD characters 
   case 'ª': finalStr = finalStr + String.fromCharCode(16); break;
   case '¡': finalStr = finalStr + String.fromCharCode(17); break;
   case '¿': finalStr = finalStr + String.fromCharCode(18); break;
   case '«': finalStr = finalStr + String.fromCharCode(19); break;
   case '»': finalStr = finalStr + String.fromCharCode(20); break;
   case 'á': finalStr = finalStr + String.fromCharCode(21); break;
   case 'é': finalStr = finalStr + String.fromCharCode(22); break;
   case 'í': finalStr = finalStr + String.fromCharCode(23); break;
   case 'ó': finalStr = finalStr + String.fromCharCode(24); break;
   case 'ú': finalStr = finalStr + String.fromCharCode(25); break;
   case 'ñ': finalStr = finalStr + String.fromCharCode(26); break;
   case 'Ñ': finalStr = finalStr + String.fromCharCode(27); break;
   case 'ç': finalStr = finalStr + String.fromCharCode(28); break;
   case 'Ç': finalStr = finalStr + String.fromCharCode(29); break;
   case 'ü': finalStr = finalStr + String.fromCharCode(30); break;
   case 'Ü': finalStr = finalStr + String.fromCharCode(31); break;
   default: finalStr = finalStr + Str.charAt(i);
 }
 return finalStr;
};

       

// The original PCDAAD readText is split in parts as the key pressing part shoud be somwhere in an eveny handler
function readText(thePrompt)
{
    
    readTextStr = thePrompt;
    

    /*if timeout last frame, and there is text to recover, and we should recover*/
    /*bits 7, 6 and 5 for FTIMEOUT_CONTROL set*/
    if ((flags.getFlag(FTIMEOUT_CONTROL) & 0xE0) == 0xE0) 
    {
        readTextStr = timeoutPreservedOrder;
        timeoutPreservedOrder = '';
    }
    flags.setFlag(FTIMEOUT_CONTROL, flags.getFlag(FTIMEOUT_CONTROL)& 0x3F); //Clear bits 7 and 6
    writeText(readTextStr + '_');
    timeoutHappened = false;
    if (flags.getFlag(FTIMEOUT)) // Start timeout
        timeoutID = setTimeout(function() { 
            inputTimeoutHandler();        
        }, flags.getFlag(FTIMEOUT)*1000);
    // The main "wait for a key" loop would start here, but we exit to leave things in hands of the keydown handler
}



function readTextB(key)
{
    var keyCode = getKeyCodeFromKey(key);
    var thePrompt = getMessage(DDB.header.sysmessPos, SM33) //The prompt

    var Xlimit = (windows.windows[windows.activeWindow].col +  windows.windows[windows.activeWindow].width) * COLUMN_WIDTH; //First pixel out of the window
    if ((keyCode>=32) && (keyCode<=255))
    {
        if ((readTextStr.length + 2) * COLUMN_WIDTH  < Xlimit) // +2 because is one more for the new char being added and another one cause the cursor '_'
        readTextStr += String.fromCharCode(keyCode); //printable characters
        patchedStr = PatchStr(readTextStr);
        windows.windows[windows.activeWindow].currentX = windows.windows[windows.activeWindow].currentX - COLUMN_WIDTH; // Move the cursor back
        writeWord(String.fromCharCode(keyCode) + '_');
        
    }
    else
    if ((keyCode==8) && (readTextStr!=thePrompt))
    {
        clearWindow(windows.windows[windows.activeWindow].currentX - COLUMN_WIDTH, windows.windows[windows.activeWindow].currentY,  COLUMN_WIDTH, LINE_HEIGHT, windows.windows[windows.activeWindow].PAPER);
        readTextStr = readTextStr.slice(0, -1);
        patchedStr = PatchStr(readTextStr);
        windows.windows[windows.activeWindow].currentX = windows.windows[windows.activeWindow].currentX - COLUMN_WIDTH * 2; // Move the cursor back 
        writeWord('_');
    }

    

    if (keyCode==13)
    {
        inputBuffer = readTextStr.substring(thePrompt.length);
        if (inputBuffer.length)
        {
            // Remove the cursor
            clearWindow(windows.windows[windows.activeWindow].currentX - COLUMN_WIDTH, windows.windows[windows.activeWindow].currentY,  COLUMN_WIDTH, LINE_HEIGHT, windows.windows[windows.activeWindow].PAPER);
            carriageReturn();
            // Ok, now we have the content of the text readed. Now, depending on the condact that asked for a text to be read (PARSE, QUIT or END), we 
            // need to return to the main loop in a different way
            inputBuffer = readTextStr.substring(thePrompt.length);
            getCommandB();
        }
    }
}


function carriageReturn()
{
    windows.windows[windows.activeWindow].currentX = windows.windows[windows.activeWindow].col * COLUMN_WIDTH;
    windows.windows[windows.activeWindow].currentY = windows.windows[windows.activeWindow].currentY + LINE_HEIGHT;
    windows.windows[windows.activeWindow].lastPauseLine ++;
    
    //if out of boundary scroll window
    if (windows.windows[windows.activeWindow].currentY >= (windows.windows[windows.activeWindow].line + windows.windows[windows.activeWindow].height) *  LINE_HEIGHT) 
     ScrollCurrentWindow();
    windows.lastPrintedIsCR = true;
}

function clearCurrentWindow()
{
    clearWindow(windows.windows[windows.activeWindow].col * COLUMN_WIDTH, windows.windows[windows.activeWindow].line * LINE_HEIGHT, windows.windows[windows.activeWindow].width * COLUMN_WIDTH, windows.windows[windows.activeWindow].height * LINE_HEIGHT, windows.windows[windows.activeWindow].PAPER);
   
    windows.windows[windows.activeWindow].currentY = windows.windows[windows.activeWindow].line * LINE_HEIGHT;
    windows.windows[windows.activeWindow].currentX = windows.windows[windows.activeWindow].col * COLUMN_WIDTH;
    windows.windows[windows.activeWindow].lastPauseLine = 0;
}

//When pos or size of window is set, this function is called to make sure it doesn't exceed the size
function reconfigureWindow()
{
    if (windows.windows[windows.activeWindow].col + windows.windows[windows.activeWindow].width > NUM_COLUMNS)
    windows.windows[windows.activeWindow].width = NUM_COLUMNS - windows.windows[windows.activeWindow].col;
    
    if (windows.windows[windows.activeWindow].line + windows.windows[windows.activeWindow].height > NUM_LINES)
    windows.windows[windows.activeWindow].height = NUM_LINES - windows.windows[windows.activeWindow].line;
}

//Scrolls currently selected window 1 line up}
function ScrollCurrentWindow()
{
    var win = windows.windows[windows.activeWindow];
    var currentContext = paper;
    if (!textWriteToScreeen) currentContext = doublebuffer; // If text
    var img = currentContext.getImageData(win.col * COLUMN_WIDTH, (win.line+1) * LINE_HEIGHT, win.width * COLUMN_WIDTH, (win.height-1) * LINE_HEIGHT);
    clearWindow(win.col * COLUMN_WIDTH, (win.line+win.height-1) * LINE_HEIGHT, win.width * COLUMN_WIDTH, LINE_HEIGHT, win.PAPER);
    currentContext.putImageData(img, win.col * COLUMN_WIDTH, win.line*LINE_HEIGHT);

    win.currentY -= LINE_HEIGHT;
    win.currentX = win.col * COLUMN_WIDTH;
}


function newtext()
{
    inputBuffer = '';
}

function Sound(frequency, duration) 
{
   if (audioContext === undefined)
      audioContext = new(window.AudioContext || window.webkitAudioContext)();

  // create Oscillator node
  var oscillator = audioContext.createOscillator();

  oscillator.type = 'square';
  oscillator.frequency.value = frequency; // value in hertz
  oscillator.connect(audioContext.destination);
  oscillator.start();
  
  delay(duration);
  oscillator.stop();
}




//Get timer ticks
function getTicks() 
{
    return Date.now();
}


function PreserveStream() 
{
    windows.backupStream = windows.activeWindow;
    if ((flags.getFlag(FINPUT)!=0) &&  (flags.getFlag(FINPUT)<NUM_WINDOWS))  windows.activeWindow = flags.getFlag(FINPUT);
}

function RestoreStream() 
{
    //Check  if the bit to delete the input stream after input is active 
    // Despite this bit is in the tiemout flags flag, it's applied whether 
    // there has been a timeout or not, hence it's here
    if ((flags.getFlag(FTIMEOUT_CONTROL) & 0x08) == 0x08) clearCurrentWindow();
    windows.activeWindow = windows.backupStream;
    //Check  if the bit to print the input in the active stream
    //This one also happens, no matter if timeout happened, despite being in the timeout flag 
    if ((flags.getFlag(FTIMEOUT_CONTROL) & 0x10) == 0x10) 
    {
     Sysmess(SM33); //The prompt
     writeText( patchedStr + CR);
    }
}



function Sysmess(sysno)
{
    var saveParameter = Parameter1;
    Parameter1 = sysno;
    _SYSMESS();
    Parameter1  =saveParameter;
}


function preloadImages()
{
    for (var i=0;i<images.length;i++)
    {
          var img=new Image();
          img.src=images[i] + '.png';
    }
}


function calculateAspectRatioFit(maxWidth, maxHeight) 
{
    var ratio = Math.min(maxWidth / 320, maxHeight / 200);

    return {
      width: 320 * ratio,
      height: 200 * ratio
    };
  };


function resizeScreen()
{
    var container = document.getElementsByClassName('screenClass')[0];

    if (!isMobileDevice) var size = calculateAspectRatioFit((window.innerWidth * 8 / 10), (window.innerHeight * 8 / 10));
    else var size = calculateAspectRatioFit((window.innerWidth), (window.innerHeight));
              
    container.style.height = size.height + 'px';
    container.style.width = size.width + 'px';
}

function listObjects(locno, isLISTAT)
{
    var result = '';
    var count =objects.getObjectCountAt(locno);
    var continuousListing = (flags.getFlag(FOBJECT_PRINT_FLAGS) & 64) != 0;
    var listed = 0;
    
    if (count> 0) 
    {
       flags.setFlag(FOBJECT_PRINT_FLAGS, flags.getFlag(FOBJECT_PRINT_FLAGS) | 0x80); //Set bit 7
       
       if (!isLISTAT) 
       {
        result = getMessage(DDB.header.sysmessPos, SM1);  //I can also see: (Only for LISTOBJ)
        if (!continuousListing) result += CR;
       }
   
       for(var i=0; i < DDB.header.numObj; i++)
       {
           if (objects.getObjectLocation(i) == locno) 
           {
               result += getMessageOTX(i, false, false, continuousListing);
               listed++;
               if (continuousListing)
               { 
                   if (listed ==  count) result += getMessage(DDB.header.sysmessPos, SM48);  // .
                   else if (listed == count - 1)   result += getMessage(DDB.header.sysmessPos, SM47); // "and"
                   else  result += getMessage(DDB.header.sysmessPos, SM46); // , 
               }
               else result += CR;
           } 
        }  
    }
    else
    { //if no objects at the location
        flags.setFlag(FOBJECT_PRINT_FLAGS, flags.getFlag(FOBJECT_PRINT_FLAGS) & 0x7F); //Clear bit 7

        if  (isLISTAT) result += getMessage(DDB.header.sysmessPos, SM53); //"Nothing"
    }
   return result;
}




// MALUVA condacts

function XPart(part)
{
    XmessagePart = part;
}

function Xmes(offset)
{
    var backup = DDB.getBlock(DDB.getWord(DDB.header.sysmessPos), 512);
    for (var i=0;i<512;i++) DDB.setByte(DDB.getWord(DDB.header.sysmessPos) + i, XMBDATA[offset + i]);
    writeText(getMessage(DDB.header.sysmessPos, 0));
    DDB.setBlock(DDB.getWord(DDB.header.sysmessPos), backup);
}


function _XMES()
{
    var XMessageOffset = Parameter1;
    DDB.condactPTR++;
    XMessageOffset = XMessageOffset + DDB.getByte(DDB.condactPTR) * 256;
    Xmes(XMessageOffset); 
    done = true;
}

function _XPART()
{
    XPart(Parameter1); 
}

// Normal condacts

function _AT()
{
    condactResult = flags.getFlag(FPLAYER) == Parameter1;
}

/*--------------------------------------------------------------------------------------*/
function _NOTAT()
{
    condactResult = flags.getFlag(FPLAYER) != Parameter1;
}

/*--------------------------------------------------------------------------------------*/
function _ATGT()
{
    condactResult = flags.getFlag(FPLAYER) > Parameter1;
}

/*--------------------------------------------------------------------------------------*/
function _ATLT()
{
    condactResult = flags.getFlag(FPLAYER) < Parameter1;
}

/*--------------------------------------------------------------------------------------*/
function _PRESENT()
{
    var objectLocation = objects.getObjectLocation(Parameter1);
    condactResult = (objectLocation == LOC_CARRIED) || (objectLocation == LOC_WORN) || (objectLocation == flags.getFlag(FPLAYER)) ;
}

/*--------------------------------------------------------------------------------------*/
function _ABSENT()
{
    var objectLocation =objects.getObjectLocation(Parameter1);
    condactResult = (objectLocation != LOC_CARRIED) && (objectLocation != LOC_WORN) && (objectLocation != flags.getFlag(FPLAYER)) ;
}

/*--------------------------------------------------------------------------------------*/
function _WORN()
{
    condactResult = objects.getObjectLocation(Parameter1) == LOC_WORN;
}

/*--------------------------------------------------------------------------------------*/
function _NOTWORN()
{
    condactResult = objects.getObjectLocation(Parameter1) != LOC_WORN;
}

/*--------------------------------------------------------------------------------------*/
function _CARRIED()
{
    condactResult = objects.getObjectLocation(Parameter1) == LOC_CARRIED;
}

/*--------------------------------------------------------------------------------------*/
function _NOTCARR()
{
    condactResult = objects.getObjectLocation(Parameter1) != LOC_CARRIED;
}

/*--------------------------------------------------------------------------------------*/
function _CHANCE()
{

 if (Parameter1 > 100) condactResult = false;  else condactResult = Math.floor(Math.random() * 101) <= Parameter1;
  
}

/*--------------------------------------------------------------------------------------*/
function _ZERO()
{
    condactResult = flags.getFlag(Parameter1) == 0;
}

/*--------------------------------------------------------------------------------------*/
function _NOTZERO()
{
    condactResult = flags.getFlag(Parameter1) != 0;
}

/*--------------------------------------------------------------------------------------*/
function _EQ()
{
    condactResult = flags.getFlag(Parameter1) == Parameter2;
}

/*--------------------------------------------------------------------------------------*/
function _GT()
{
    condactResult = flags.getFlag(Parameter1) > Parameter2;
}

/*--------------------------------------------------------------------------------------*/
function _LT()
{
    condactResult = flags.getFlag(Parameter1) < Parameter2;
}

/*--------------------------------------------------------------------------------------*/
function _ADJECT1()
{
 condactResult = flags.getFlag(FADJECT) == Parameter1;
}

/*--------------------------------------------------------------------------------------*/
function _ADVERB()
{
    condactResult = flags.getFlag(FADVERB) == Parameter1;
}

/*--------------------------------------------------------------------------------------*/



function _SFX()
{
 switch (Parameter2) 
 {
    /*Note: we skip should avoid using 255 and 2554 as they are used by original
    SFX implementation in AtariST. SFX x 255 plays sample loaded by PICTURE, while
    SFX 2 254 disables keyboard click sound*/

    // Plays sample and no repeat
    case 1: PlaySound(true, Parameter1, false); break;

    // Plays sample  and loop
    case 2: PlaySound(true, Parameter1, true); break;

    // Stops loop if enabled, parameter2 is irrelevant
    case 5: StopSound(true);break;

    // Plays music with no repeat
    case 6: PlaySound(false, Parameter1, false); break;

    // Plays music loop
    case 7: PlaySound(false, Parameter1, true); break;

    // Stops loop if enabled, parameter2 is irrelevant
    case 8: StopSound(false);break;

    // PlaysFLI file, no repeat
    case 9: {
        var SaveMouse = activeMouse;
        if (SaveMouse) hideMouse();
        PlayVideo(Parameter1,false);
        if (SaveMouse) showMouse();
        break;
       }; 

    // PlaysFLI file, loop
   case 10: {
        var SaveMouse = activeMouse;
        if (SaveMouse) hideMouse();
        PlayVideo(Parameter1,true);
        if (SaveMouse) showMouse();
        break;
       }
    // Plays SFX the old style
    case 255: PlaySound(true, sampleBufferID, false); break;

 } 
    
  
 done = true;
}

/*--------------------------------------------------------------------------------------*/
function _DESC()
{
  if (Parameter1 == LOC_HERE) Parameter1 = flags.getFlag(FPLAYER);
  done = true;
  writeText(getMessage(DDB.header.locationPos, Parameter1)); 
}

/*--------------------------------------------------------------------------------------*/
function _QUIT() 
{

   PreserveTimeout = flags.getFlag(FTIMEOUT);
   flags.setFlag(FTIMEOUT, 0);
   PreserveStream();  
   Sysmess(SM12); // Are you sure? 
   inputBuffer = '';
   inQUIT = true;
   getPlayerOrders();
   
}

function _QUITB()
{
   //Get first char of SM30, uppercased
   var yesNoMessage= getMessage(DDB.header.sysmessPos, SM30);
    var YesResponse = yesNoMessage.charAt(0).toUpperCase();

   condactResult = false;
   if (inputBuffer != '')
    if (inputBuffer.substring(0,1).toUpperCase() == YesResponse)
     condactResult = true;

   flags.setFlag(FTIMEOUT, PreserveTimeout);
   for(var i=0;i<NUM_WINDOWS;i++) windows.windows[i].lastPauseLine = 0;
   inputBuffer = '';
   done = true;
   RestoreStream();

   if (!condactResult) 
   {
       DDB.entryPTR +=4;
       run(false); // false -- go to RunEntry
   }
   else
   {
   //otherwise go to next condact
   DDB.condactPTR++;
   run(true); // true --  go to  RunCondact
   }

}
/*--------------------------------------------------------------------------------------*/
function _SAVE() 
{
    PreserveTimeout = flags.getFlag(FTIMEOUT);
    flags.setFlag(FTIMEOUT, 0);
    PreserveStream();
    Sysmess(SM60); // Type in name of file
    inputBuffer = '';
    inSAVE = true;
    getPlayerOrders();
}

function _SAVEB() 
{
    doSave(inputBuffer);
   
    flags.setFlag(FTIMEOUT, PreserveTimeout);
    for(var i=0;i<NUM_WINDOWS;i++) windows.windows[i].lastPauseLine = 0;
    inputBuffer = '';
    done = true;
    RestoreStream();
  
    DDB.condactPTR++;
    run(true); // true --  go to  RunCondact

}

/*--------------------------------------------------------------------------------------*/
function _LOAD() 
{
    _SAVE();
    inSAVE = false;
    inLOAD = true;
}


function _LOADB() 
{
    condactResult = true;
    if (!doLoad(inputBuffer))
    {
        flags.setFlag(FTIMEOUT, PreserveTimeout);
        windows.windows[windows.activeWindow].lastPauseLine = 0;   
        condactResult = false;
    }  
    inputBuffer = '';
    done = true;
    RestoreStream();
    for(var i=0;i<NUM_WINDOWS;i++) windows.windows[i].lastPauseLine = 0;
    if (!condactResult) 
    {
        DDB.entryPTR +=4;
        run(false); // false -- go to RunEntry
    }
    else     //otherwise go to next condact
    {
        DDB.condactPTR++;
        run(true); // true --  go to  RunCondact
    }
 
    

}


/*--------------------------------------------------------------------------------------*/

function _END() 
{
   PreserveTimeout = flags.getFlag(FTIMEOUT);
   flags.setFlag(FTIMEOUT, 0);
   Sysmess(SM13); // Play again? 
   //Get first char of SM30, uppercased
   inputBuffer = '';
   inEND = true;
   getPlayerOrders();
   
}

function _ENDB()
{
    var yesNoMessage= getMessage(DDB.header.sysmessPos, SM30);
    var YesResponse = yesNoMessage.charAt(0).toUpperCase();
    condactResult = false;
    if (inputBuffer != '')
      if (inputBuffer.substring(0,1).toUpperCase() == YesResponse)
         condactResult = true;

   if (condactResult) window.location.reload(); // reload to force Restart Game
    else  $('.goodbye').show(); // Show goodbye layer
}

/*--------------------------------------------------------------------------------------*/
function _DONE()
{
 done = true;
 DDB.consumeProcess(); //Go to last entry
 //force failure so we jump to next entry, which happens to be the mark of end of process
 condactResult = false; 
}

/*--------------------------------------------------------------------------------------*/
function _OK()
{
  Sysmess(SM15); //OK
 _DONE();
}

/*--------------------------------------------------------------------------------------*/
function _ANYKEY() 
{
    if ((keyBoardStatus.length == 1) && (keyBoardStatus[0] == 13)) keyBoardStatus = []; // Remove pending CR
    inANYKEY = true;
    if (flags.getFlag(FTIMEOUT)) // Timeout duration != 0
    if ((flags.getFlag(FTIMEOUT_CONTROL) & 4) == 4) // Timeout can happen in ANYKEY
    timeoutID = setTimeout(function() { 
        inputTimeoutHandler();        
    }, flags.getFlag(FTIMEOUT)*1000);
}


/*--------------------------------------------------------------------------------------*/
function _DPRINT()
{
    var Value = flags.getFlag(Parameter1) + 256 * flags.getFlag(Parameter1 + 1);
    var valstr = Value + '';
    writeText(valstr);
    done = true;
}

/*--------------------------------------------------------------------------------------*/
function _DISPLAY() 
{
    done = true;
    condactResult = true;
    if (imageBufferID === false) return;


    var image = images[imageBufferID];
    var fixedX = image[image.length - 4];
    var fixedY = image[image.length - 3];
    var imageWidth = image[image.length - 2];
    var imageHeight = image[image.length - 1];

    if (fixedX == -1)  // Float image
    {
        var windowX = windows.windows[windows.activeWindow].col * COLUMN_WIDTH;
        var windowY = windows.windows[windows.activeWindow].line * LINE_HEIGHT;
        var windowWidth = windows.windows[windows.activeWindow].width * COLUMN_WIDTH;
        if ((windowWidth==318) || (windowWidth==319)) windowWidth=320;
        var windowHeight = windows.windows[windows.activeWindow].height* LINE_HEIGHT;
    }
    else
    {
        var windowX =  fixedX;
        var windowY = fixedY;
        var windowWidth = imageWidth;
        var windowHeight = imageHeight;
        if (windowX + imageWidth > 320) windowWidth = 320 - windowX; // Clip image to screen
        if (windowY + imageHeight > 200) windowHeight = 200 - windowY; // Clip image to screen
    }
    
    for (var y=0;y<imageHeight;y++)
        for(var x=0;x<imageWidth;x++)
         {          
            if ((x<windowWidth) && (y<windowHeight)) // clip image
            {
                var data = image[imageWidth * y + x];
                var r = (data >> 16) & 0xFF;
                var g = (data >> 8) & 0xFF;
                var b = data & 0xFF;

                pixelRGB(windowX + x, windowY + y, r, g, b, false);
            }
         }
    
}

function _CLS() 
{
 clearCurrentWindow(); 
 done = true;
}

/*--------------------------------------------------------------------------------------*/
function _DROPALL() 
{
   var here = flags.getFlag(FPLAYER);
   for(var locno = LOC_WORN; locno<=LOC_CARRIED; locno++)
   {
    var nextObject = - 1;
        do
        {
            nextObject = objects.getNextObjectAt(nextObject, locno);
            if (nextObject!=MAX_OBJECT)  
            { 
                Parameter1 = nextObject;
                Parameter2 = here;
                _PLACE();
            }
        }
        while (nextObject!=MAX_OBJECT);
   }
   done = true;
}

/*--------------------------------------------------------------------------------------*/
function _AUTOG()
{
 var Noun = flags.getFlag(FNOUN);
 var Adject = flags.getFlag(FADJECT);
 Parameter1 = objects.getObjectByVocabularyAtLocation(Noun, Adject, flags.getFlag(FPLAYER));
 if (Parameter1 != MAX_OBJECT) 
 {
    _GET();
    return;
 }
 Parameter1 = objects.getObjectByVocabularyAtLocation(Noun, Adject, LOC_WORN);
 if (Parameter1 != MAX_OBJECT) 
 {
    _GET();
    return;
 }
 Parameter1 = objects.getObjectByVocabularyAtLocation(Noun, Adject, LOC_CARRIED);
 if (Parameter1 != MAX_OBJECT) 
 {
    _GET();
    return;
 }
 Parameter1 = objects.getObjectByVocabularyAtLocation(Noun, Adject, MAX_LOCATION); //Any Location
 if (Parameter1 != MAX_OBJECT)  Sysmess(SM26); //There isn't one of those here.
                               else Sysmess(SM8); //I can't do that.
 newtext();
 _DONE();
 }

/*--------------------------------------------------------------------------------------*/
function _AUTOD() 
{
 var Noun = flags.getFlag(FNOUN);
 var Adject = flags.getFlag(FADJECT);
 Parameter1 = objects.getObjectByVocabularyAtLocation(Noun, Adject, LOC_CARRIED);
 if (Parameter1 != MAX_OBJECT) 
 {
    _DROP();
    return;
 }

 Parameter1 = objects.getObjectByVocabularyAtLocation(Noun, Adject, LOC_WORN);
 if (Parameter1 != MAX_OBJECT)
 {
    _DROP();
    return;
 }

 Parameter1 = objects.getObjectByVocabularyAtLocation(Noun, Adject, flags.getFlag(FPLAYER));
 if (Parameter1 != MAX_OBJECT) 
 {
    _DROP();
    return;
 }

 Parameter1 = objects.getObjectByVocabularyAtLocation(Noun, Adject, MAX_LOCATION); //Any Location
 if (Parameter1 != MAX_OBJECT) Sysmess(SM28); //I don't have one of those.
                               else Sysmess(SM8); //I can't do that.
 newtext();
 _DONE();
}

/*--------------------------------------------------------------------------------------*/
function _AUTOW() 

{
 var Noun = flags.getFlag(FNOUN);
 var Adject = flags.getFlag(FADJECT);
 Parameter1 = objects.getObjectByVocabularyAtLocation(Noun, Adject, LOC_CARRIED);
 if (Parameter1 != MAX_OBJECT) 
 {
    _WEAR();
    return;
 }

 Parameter1 = objects.getObjectByVocabularyAtLocation(Noun, Adject, LOC_WORN);
 if (Parameter1 != MAX_OBJECT)
 {
    _WEAR();
    return;
 }

 Parameter1 = objects.getObjectByVocabularyAtLocation(Noun, Adject, flags.getFlag(FPLAYER));
 if (Parameter1 != MAX_OBJECT)
 {
    _WEAR();
    return;
 }

 Parameter1 = objects.getObjectByVocabularyAtLocation(Noun, Adject, MAX_LOCATION); //Any Location
 if (Parameter1 != MAX_OBJECT)  Sysmess(SM28); //I don't have one of those.
                               else Sysmess(SM8); //I can't do that.
 newtext();
 _DONE();
}

/*--------------------------------------------------------------------------------------*/
function _AUTOR() 
{
    var Noun = flags.getFlag(FNOUN);
    var Adject = flags.getFlag(FADJECT);
    Parameter1 = objects.getObjectByVocabularyAtLocation(Noun, Adject, LOC_WORN);
    if (Parameter1 != MAX_OBJECT) 
    {
    _REMOVE();
    return;
    }

    Parameter1 = objects.getObjectByVocabularyAtLocation(Noun, Adject, LOC_CARRIED);
    if (Parameter1 != MAX_OBJECT) 
    {
    _REMOVE();
    return;
    }

    Parameter1 = objects.getObjectByVocabularyAtLocation(Noun, Adject, flags.getFlag(FPLAYER));
    if (Parameter1 != MAX_OBJECT) 
    {
        _REMOVE();
        return;
    }

    Parameter1 = objects.getObjectByVocabularyAtLocation(Noun, Adject, MAX_LOCATION); //Any Location
    if (Parameter1 != MAX_OBJECT) Sysmess(SM23); //"I'm not wearing one of those.
                               else Sysmess(SM8); //I can't do that.
    newtext();
    _DONE();
 }

/*--------------------------------------------------------------------------------------*/
function _PAUSE() 
{
 if (Parameter1 == 0) delay(5.12); else delay(Parameter1/50); 
 done = true; 
}

/*--------------------------------------------------------------------------------------*/
function _SYNONYM()
{
 if (Parameter1!=NO_WORD) flags.setFlag(FVERB, Parameter1);
 if (Parameter2!=NO_WORD) flags.setFlag(FNOUN, Parameter2);
 done = true;
}

/*--------------------------------------------------------------------------------------*/
function _GOTO()
{
 flags.setFlag(FPLAYER, Parameter1);
 done = true;
}

/*--------------------------------------------------------------------------------------*/
function _MESSAGE()
{
 _MES(true);
}

/*--------------------------------------------------------------------------------------*/
function _REMOVE()
{
 objects.setReferencedObject(Parameter1);
 var ObjectLocation = objects.getObjectLocation(Parameter1);
 if ((ObjectLocation == LOC_CARRIED) || (ObjectLocation == flags.getFlag(FPLAYER)))
 {
  Sysmess(SM50); //I'm not wearing the _.
  newtext();
  _DONE();
  return;
 }

 if ((ObjectLocation != LOC_WORN) && (ObjectLocation != flags.getFlag(FPLAYER)))
 {
  Sysmess(SM23);  //"I'm not wearing one of those.
  newtext();
  _DONE();
  return;
 }

 if (! objects.isObjectWearable(Parameter1)) 
 {
  Sysmess(SM41); //I can't remove the _.
  newtext();
  _DONE();
  return;
 }

 if (flags.getFlag(FPLAYER) >= flags.getFlag(FOBJECTS_CONVEYABLE)) 
 {
  Sysmess(SM42); //I can't remove the _. My hands are full.
  newtext();
  _DONE();
  return;

 }

 objects. setObjectLocation(Parameter1, LOC_CARRIED);
 flags.setFlag(FCARRIED, flags.getFlag(FCARRIED) + 1);
 Sysmess(SM38); //I've removed the _.
 done = true;
}

/*--------------------------------------------------------------------------------------*/
function _GET() 
{
 objects.setReferencedObject(Parameter1);
 var ObjectLocation = objects.getObjectLocation(Parameter1);
 if ((ObjectLocation == LOC_WORN) || (ObjectLocation==LOC_CARRIED)) 
 {
  Sysmess(SM25); //I already have the_.
  newtext();
  _DONE();
  return;
 }

 if (ObjectLocation != flags.getFlag(FPLAYER)) 
 {
  Sysmess(SM26); //There isn't one of those here.
  newtext();
  _DONE();
  return;
 }

 var WeightCarried = objects.getWeightOfObjectsAt(LOC_CARRIED);
 var WeightWorn = objects.getWeightOfObjectsAt(LOC_WORN);
 if (WeightWorn + WeightCarried + objects.getObjectFullWeight(Parameter1) > flags.getFlag(FPLAYER_STRENGTH)) 
 {
  Sysmess(SM43); //The _ weighs too much for me.
  newtext();
  _DONE();
  return;
 }

 if (flags.getFlag(FCARRIED) >= flags.getFlag(FOBJECTS_CONVEYABLE)) 
 {
  Sysmess(SM27); //I can't carry any more things.
  DDB.doallPTR = 0;
  newtext();
  _DONE();
  return;
 }

 objects.setObjectLocation(Parameter1, LOC_CARRIED);
 flags.setFlag(FCARRIED, flags.getFlag(FCARRIED) + 1);
 Sysmess(SM36); //I now have the _.
 done = true;
}

/*--------------------------------------------------------------------------------------*/
function _DROP() 
{
 
 objects.setReferencedObject(Parameter1);
 var ObjectLocation = objects.getObjectLocation(Parameter1);
 
 if (ObjectLocation == LOC_WORN)  
 {
  Sysmess(SM24); //I can't. I'm wearing the_.
  newtext();
  _DONE();
  return;
 }

 if (ObjectLocation == flags.getFlag(FPLAYER))  
 {
  Sysmess(SM49); //I don't have the _.
  newtext();
  _DONE();
  return;
 }

 if ((ObjectLocation != flags.getFlag(FPLAYER)) &&  (ObjectLocation != LOC_CARRIED)) 
 {
  Sysmess(SM28); //I don't have one of those.
  newtext();
  _DONE();
  return;
 }

 objects.setObjectLocation(Parameter1, flags.getFlag(FPLAYER));
 flags.setFlag(FCARRIED, flags.getFlag(FCARRIED) - 1);
 Sysmess(SM39); //I've dropped the _.
 done = true;
}

/*--------------------------------------------------------------------------------------*/
function _WEAR() 
{
 objects.setReferencedObject(Parameter1);
 var ObjectLocation = objects.getObjectLocation(Parameter1);
 if (ObjectLocation == flags.getFlag(FPLAYER)) 
 {
  Sysmess(SM49); //I don't have the _.
  newtext();
  _DONE();
  return;
 }

 if (ObjectLocation == LOC_WORN)  
 {
  Sysmess(SM29); //I'm already wearing the _.
  newtext();
  _DONE();
  return;
 }

 if (ObjectLocation != LOC_CARRIED)  
 {
  Sysmess(SM28); //I don't have one of those.
  newtext();
  _DONE();
  return;
 }

 if (! objects.isObjectWearable(Parameter1))
{
  Sysmess(SM40); //I can't wear the _.
  newtext();
  _DONE();
  return;
 }

 objects.setObjectLocation(Parameter1, LOC_WORN);
 flags.setFlag(FCARRIED, flags.getFlag(FCARRIED) - 1);
 Sysmess(SM37); //I'm now wearing the _.
 done = true;
}

/*--------------------------------------------------------------------------------------*/
function _DESTROY()
{
  Parameter2 = LOC_NOT_CREATED;
  _PLACE();
}

/*--------------------------------------------------------------------------------------*/
function _CREATE()
{
 Parameter2 = flags.getFlag(FPLAYER);
 _PLACE();
}

/*--------------------------------------------------------------------------------------*/
function _SWAP()
{
 var Aux = objects.getObjectLocation(Parameter1);
 objects.setObjectLocation(Parameter1, objects.getObjectLocation(Parameter2));
 objects.setObjectLocation(Parameter2, Aux);
 objects.setReferencedObject(Parameter2);
 done = true;
}

/*--------------------------------------------------------------------------------------*/
function _PLACE()
{
 if (Parameter2 == LOC_HERE) Parameter2 = flags.getFlag(FPLAYER);
 if (objects.getObjectLocation(Parameter1) == LOC_CARRIED) flags.setFlag(FCARRIED, flags.getFlag(FCARRIED) - 1);
 objects.setObjectLocation(Parameter1, Parameter2);
 if (objects.getObjectLocation(Parameter1) == LOC_CARRIED) flags.setFlag(FCARRIED, flags.getFlag(FCARRIED) +1);
 done = true;
}

/*--------------------------------------------------------------------------------------*/
function _SET()
{
    flags.setFlag(Parameter1, MAX_FLAG_VALUE);
    done = true;
}

/*--------------------------------------------------------------------------------------*/
function _CLEAR()
{
    flags.setFlag(Parameter1, 0);
    done = true;
}

/*--------------------------------------------------------------------------------------*/
function _PLUS()
{
 if (flags.getFlag(Parameter1) + Parameter2 > MAX_FLAG_VALUE) _SET();
        else flags.setFlag(Parameter1, flags.getFlag(Parameter1) + Parameter2);
 done = true;                                                      
}

/*--------------------------------------------------------------------------------------*/
function _MINUS()
{
 if (flags.getFlag(Parameter1) - Parameter2 < 0) _CLEAR();
        else flags.setFlag(Parameter1, flags.getFlag(Parameter1) - Parameter2);
 done = true;                                                        
}

/*--------------------------------------------------------------------------------------*/
function _LET()
{
    flags.setFlag(Parameter1, Parameter2);
    done = true;
}

/*--------------------------------------------------------------------------------------*/
function _NEWLINE()
{
 carriageReturn(); 
 done = true;
}

/*--------------------------------------------------------------------------------------*/
function _PRINT()
{
 var value = flags.getFlag(Parameter1);
 var valstr = value + '';
 writeText(valstr);
 done = true;
}

/*--------------------------------------------------------------------------------------*/
function _SYSMESS()
{
 writeText(getMessage(DDB.header.sysmessPos, Parameter1));   
 done = true;
}

/*--------------------------------------------------------------------------------------*/
function _ISAT()
{
    if (Parameter2 == LOC_HERE) Parameter2 = flags.getFlag(FPLAYER);
    condactResult = objects.getObjectLocation(Parameter1) == Parameter2;
}

/*--------------------------------------------------------------------------------------*/
function _SETCO()
{
  objects.setReferencedObject(Parameter1);
  done = true;
}

/*--------------------------------------------------------------------------------------*/
function _SPACE()
{
    writeText(' ');
    done = true;
}

/*--------------------------------------------------------------------------------------*/
function _HASAT()
{
    condactResult = flags.getFlagBit(59 - Math.floor(Parameter1/8), Parameter1 % 8);
}

/*--------------------------------------------------------------------------------------*/
function _HASNAT()
{
    _HASAT();
    condactResult = ! condactResult;
}

/*--------------------------------------------------------------------------------------*/
function _LISTOBJ()
{
    done = true;
    writeText(listObjects(flags.getFlag(FPLAYER), false));  // false = not LISTAT
}

/*--------------------------------------------------------------------------------------*/
function _EXTERN() 
{
    if (!MALUVA_DISABLED)   /* Maluva Emulation */
    {
        switch(Parameter2)
        {
            case 3: _XMES(); return;
            case 4: _XPART(); return;
        }
    }
    /*Please notice even with Maluva Enabled additional EXTERN code can be run, it just happens Maluva functions 
    can intervene and don't let execution come to this point, but if not, then standard EXTERN code may run */
    Extern(Parameter1, Parameter2); 
    done = true;
}

/*--------------------------------------------------------------------------------------*/
function _RAMSAVE()
{
    objects.RAMSAVEObjects();
    flags.RAMSAVEFlags();
     done = true;
}

/*--------------------------------------------------------------------------------------*/
function _RAMLOAD()
{
    objects.RAMLOADObjects();
    flags.RAMLOADFlags(Parameter1);
    done = true;
}

/*--------------------------------------------------------------------------------------*/
function _BEEP() 
{
    if ((Parameter2 >= 24) && (Parameter2 <= 238) && (Parameter2 % 2 == 0))
    {
        Sound(FREQ_TABLE[(Parameter2 - 24) >> 1], Parameter1/100);
    }
    done = true;
}

/*--------------------------------------------------------------------------------------*/
function _PAPER()
{
    windows.windows[windows.activeWindow].PAPER = Parameter1  % 16;
    done = true;
}

/*--------------------------------------------------------------------------------------*/
function _INK()
{
    windows.windows[windows.activeWindow].INK = Parameter1 % 16;
    done = true;
}

/*--------------------------------------------------------------------------------------*/
function _BORDER()
{
    windows.windows[windows.activeWindow].BORDER = Parameter1  % 16;
    document.getElementById('screen').style.backgroundColor = getFillStyle(Parameter1  % 16);
    done = true;
}

/*--------------------------------------------------------------------------------------*/
function _PREP()
{
    condactResult = flags.getFlag(FPREP) == Parameter1;
}

/*--------------------------------------------------------------------------------------*/
function _NOUN2()
{
 condactResult = flags.getFlag(FNOUN2) == Parameter1;
}

/*--------------------------------------------------------------------------------------*/
function _ADJECT2()
{
 condactResult = flags.getFlag(FADJECT2) == Parameter1;
}

/*--------------------------------------------------------------------------------------*/
function _ADD()
{
 if (flags.getFlag(Parameter1) -  flags.getFlag(Parameter2) > MAX_FLAG_VALUE) flags.setFlag(Parameter2, MAX_FLAG_VALUE);
                else flags.setFlag(Parameter2, flags.getFlag(Parameter1) + flags.getFlag(Parameter2));
 done = true;
}

/*--------------------------------------------------------------------------------------*/
function _SUB()
{
 if (flags.getFlag(Parameter2) -  flags.getFlag(Parameter1) < 0) flags.setFlag(Parameter2, 0);
                else flags.setFlag(Parameter2, flags.getFlag(Parameter2) - flags.getFlag(Parameter1));
done = true;
}

/*--------------------------------------------------------------------------------------*/
function _PARSE()
{
 // The call to parse() can have two differente consequences:
 // a) there was input buffer left and the parser processes a new sentence in a sequential way (just as PCDAAD)   
 // b= there was no input buffer, and parse() returns with inPARSE = true, which on return will make run() exit
 // and the keydown event handler start listening keystrokes (for the player input)
 var result = parse(Parameter1);

 // If sequential execution we do the same as always
 if (!inPARSE)
 {
    condactResult = ! result;
    done = false;
 }
}

/*--------------------------------------------------------------------------------------*/
function _LISTAT()
{
    if (Parameter1 == LOC_HERE) Parameter1 = flags.getFlag(FPLAYER);
    done = true;
    writeText(listObjects(Parameter1, true));  // true = LISTAT
}

/*--------------------------------------------------------------------------------------*/
function _PROCESS()
{
    if (Parameter1 >= DDB.header.numPro) Error(3, 'Process ' + Parameter1 + 'does not exist'); 
    stack.stackPush();
    currentProcess = Parameter1;
    if (NESTED_DOALL_ENABLED) 
    {
        DDB.doallPTR = 0;
        DDB.doallentryPTR = 0; //Not really necessary
    }
    DDB.condactPTR = 0;
    DDB.processPTR =  DDB.header.processPos + 2 * Parameter1;
    /*As I really want to force a jump to first entry of this new    */
    /* process I set the EntryPRT to 2 below the first entry and     */
    /* make the condition fail, so actually we wil habe the entryPTR */
    /* increased by 2 on return and jump to entry validation         */
    DDB.entryPTR =  DDB.getWord(DDB.processPTR) - 4;
    condactResult = false;
    // done is cleared on exit, so ISdone after a PROCESS call refers to the process and not to any previous execucition
    done = false;
}

/*--------------------------------------------------------------------------------------*/
function _SAME()
{
    condactResult = flags.getFlag(Parameter1) == flags.getFlag(Parameter2);
}

/*--------------------------------------------------------------------------------------*/
function _MES(withCR = false)
{
    var message = getMessage(DDB.header.messagePos, Parameter1);
    if (withCR) message += CR;
    done = true;
    writeText(message);
}

/*--------------------------------------------------------------------------------------*/
function _WINDOW()
{
 if (Parameter1<NUM_WINDOWS) 
 {
    windows.activeWindow = Parameter1;
    flags.setFlag(FactiveWindow, Parameter1);
 }
 done = true;
}

/*--------------------------------------------------------------------------------------*/
function _NOTEQ()
{
    condactResult = flags.getFlag(Parameter1) != Parameter2;
}

/*--------------------------------------------------------------------------------------*/
function _NOTSAME()
{
    condactResult = flags.getFlag(Parameter1) != flags.getFlag(Parameter2);
}

/*--------------------------------------------------------------------------------------*/
function _MODE()
{
 windows.windows[windows.activeWindow].OperationMode = Parameter1;
 windows.charsetShift = (Parameter1 == 1) ? 128 : 0;
 done = true;
}

/*--------------------------------------------------------------------------------------*/
function _WINAT()
{
 windows.windows[windows.activeWindow].line = Parameter1;
 windows.windows[windows.activeWindow].currentY = Parameter1 * LINE_HEIGHT;
 windows.windows[windows.activeWindow].col = Parameter2;
 windows.windows[windows.activeWindow].currentX = Parameter2 * COLUMN_WIDTH;
 reconfigureWindow();
 done = true;
}

/*--------------------------------------------------------------------------------------*/
function _TIME()
{
 flags.setFlag(FTIMEOUT, Parameter1);
 flags.setFlag(FTIMEOUT_CONTROL, Parameter2);
 done = true;
}

/*--------------------------------------------------------------------------------------*/
function _PICTURE() 
{
    
    var image = images[Parameter1];
    if (  image !== null )
    {
        imageBufferID = Parameter1;
        condactResult = true;
    }
    else
    {
        var image = jDAADSounds[Parameter1];
        if (image !== null)
        {
            sampleBufferID = Parameter1;
            condactResult = true;
        }
        else
        {
            imageBufferID = false;
            condactResult = false;
        }
    }
    done = true;
}


/*--------------------------------------------------------------------------------------*/
function _DOALL() 
{
    if  (DDB.doallPTR!=0)
    {
    writeText('Runtime error 4 - Invalid nested DOALL');
    _ANYKEY;
    Parameter1 = 0;
    _EXIT;
    }
 
    if (Parameter1 == LOC_HERE) Parameter1 = flags.getFlag(FPLAYER);
    var i = -1;
    do 
    {
        var objno = objects.getNextObjectAt(i, Parameter1);

    
        if (objno!=MAX_OBJECT)
        {
            objects.setReferencedObject(objno);
            flags.setFlag(FDOALL,objno);
            if ((flags.getFlag(FNOUN) == flags.getFlag(FNOUN2)) && ((flags.getFlag(FADJECT) == flags.getFlag(FADJECT2)) || (flags.getFlag(FADJECT) == NO_WORD) || (flags.getFlag(FADJECT2) == NO_WORD))) 
                            {
                                debug('"Except" applied to Doall, skipping object');
                                i++;
                                continue;
                            }


            DDB.doallPTR = DDB.condactPTR + 1; //Point to next Condact after DOALL
            DDB.doallEntryPTR = DDB.entryPTR;
            DDB.doallLocation = Parameter1;
            done = true;
            break;
        }
        else 
        {
            debug('Bad doall', 'error');
            Sysmess(SM8);
            newtext();
            _DONE();
            break;
        } 
    } while (true);
}

/*--------------------------------------------------------------------------------------*/
function _MOUSE()
{
    switch(Parameter2)
    {
    case 0 : break; // was ResetMouse() but it makes no sense in JS
    case 1 : showMouse(); break; // Show mouse pointer
    case 2 : hideMouse() ; break; // Hide mouse pointer
    case 3 : {
                var mouseData = GetMouse();
                var columnX = Math.floor(mouseData.x/8) ;
                if (columnX <0) columnX = 0;
                if (columnX > 39) columnX = 39;
                var columnY = Math.floor(mouseData.y/8);
                if (columnY <0) columnY = 0;
                if (columnY > 24) columnY = 24;
                var columnX6 = Math.floor(mouseData.x/6) ;
                if (columnX6 <0) columnX6 = 0;
                if (columnX6 > 53) columnX6 = 53;
                

                flags.setFlag(Parameter1, mouseData.buttons);
                flags.setFlag(Parameter1 + 1, columnX);
                flags.setFlag(Parameter1 + 2, columnY);
                flags.setFlag(Parameter1 + 3, columnX6);
                break;
            }
    };
    done = true;
}

/*--------------------------------------------------------------------------------------*/
function _GFX() 
{
 switch (Parameter2) 
 {
  case 0: DBBuffertoScreen(); break;//Copy the buffer to the screen
  case 1: DBScreentoBuffer(); break; //Copy the screen to the buffer}
  case 2: DBSwapBuffers(); break; //Swap the buffers
  case 3: DBGraphicsWriteToScreen(); break; //Write the graphics buffer to the screen
  case 4: DBGraphicsWriteToBuffer(); break; //Write the graphics buffer to the buffer
  case 5: DBClearScreen; break; //Clear the screen
  case 6: DBClearBuffer; break; //Clear the buffer
  case 7: DBTextWriteToScreen(); break; //Write the text buffer to the screen
  case 8: DBTextWriteToBuffer(); break; //Write the text buffer to the buffer
  case 9: DBSetPalette(Parameter1); //Set the palette
  case 10:DBgetPalette(Parameter1); //Gets the palette
 }
done = true;
}

/*--------------------------------------------------------------------------------------*/
function _ISNOTAT()
{
    if (Parameter2 == LOC_HERE) Parameter2 = flags.getFlag(FPLAYER);
    condactResult = objects.getObjectLocation(Parameter1) != Parameter2;
}

/*--------------------------------------------------------------------------------------*/
function _WEIGH()
{
 flags.setFlag(Parameter2, objects.getObjectFullWeight(Parameter1));
 done = true;
}

/*--------------------------------------------------------------------------------------*/
function _PUTIN() 
{
    if (Parameter1 == LOC_HERE) Parameter1 = flags.getFlag(FPLAYER);
    objects.setReferencedObject(Parameter1);
    var ObjectLocation =objects.getObjectLocation(Parameter1);
    if (ObjectLocation == LOC_WORN) 
    {
        Sysmess(SM24); //I can't. I'm wearing the_.
        newtext();
        _DONE();
        return;
    }

    if (ObjectLocation == flags.getFlag(FPLAYER))
    {
        Sysmess(SM49); //I don't have the _.
        newtext();
        _DONE();
        return;
    }

    if ((ObjectLocation != flags.getFlag(FPLAYER)) && (ObjectLocation != LOC_CARRIED)) 
    {
        Sysmess(SM28); //I don't have one of those.
        newtext();
        _DONE();
        return;
    }

     objects.setObjectLocation(Parameter1, Parameter2);
    flags.setFlag(FCARRIED, flags.getFlag(FCARRIED) - 1);
    Sysmess(SM44); //The _ is in the }
    _SPACE();
    writeText(getMessageOTX(Parameter2, true, false, true));
    Sysmess(SM51); //.
    done = true;
}

/*--------------------------------------------------------------------------------------*/
function _NEWTEXT()
{
    newtext(); 
    done = true;
}


/*--------------------------------------------------------------------------------------*/
function _TAKEOUT() 
{
    if (Parameter1 == LOC_HERE) Parameter1 = flags.getFlag(FPLAYER);
    objects.setReferencedObject(Parameter1);
    var ObjectLocation =objects.getObjectLocation(Parameter1);
    if ((ObjectLocation == LOC_WORN) || (ObjectLocation==LOC_CARRIED)) 
    {
        Sysmess(SM45); //I already have the _.
        newtext();
        _DONE();
        return;
    }

    if (ObjectLocation == flags.getFlag(FPLAYER)) 
    {
        Sysmess(SM49); //The _ isn't in the
        writeText(getMessageOTX( Parameter2, true, false, true));
        Sysmess(SM51);//.
        newtext();
        _DONE();
        return;
    }

    if ((ObjectLocation != flags.getFlag(FPLAYER)) && (ObjectLocation != Parameter2))
    {
        Sysmess(SM52); //There isn't one of those in the
        _SPACE();
        writeText(getMessageOTX( Parameter2, true, false, true));
        Sysmess(SM51);//.
        newtext();
        _DONE();
        return;
    }

    if ((ObjectLocation != LOC_CARRIED) && (ObjectLocation != LOC_WORN))
    {
        var WeightCarried = objects.getObjectFullWeight(LOC_CARRIED);
        var WeightWorn = objects.getObjectFullWeight(LOC_WORN);
        if (WeightCarried + WeightWorn + objects.getObjectFullWeight(Parameter1) > flags.getFlag(FPLAYER_STRENGTH)) 
        {
            Sysmess(SM43); //The _ weighs too much for me.
            newtext();
            _DONE();
            return;
        }
    } 

    if (flags.getFlag(FCARRIED) >=  flags.getFlag(FOBJECTS_CONVEYABLE)) 
    {
        Sysmess(SM27); //"I can't carry any more things.
        newtext();
        DDB.doallPTR = 0;
        _DONE();
        return;
    }

    objects.setObjectLocation(Parameter1, LOC_CARRIED);
    flags.setFlag(FCARRIED, flags.getFlag(FCARRIED) + 1);
    Sysmess(SM36); //I now have the _.
    done = true;
}


/*--------------------------------------------------------------------------------------*/
function _ABILITY()
{
 flags.setFlag(FOBJECTS_CONVEYABLE, Parameter1);
 flags.setFlag(FPLAYER_STRENGTH, Parameter2);
 done = true;
}

/*--------------------------------------------------------------------------------------*/
function _WEIGHT()
{
  var w = 0;
  for (var i=0;i<DDB.header.numObj;i++)
  {
    var l = objects.getObjectLocation(i);
   if ((l==LOC_CARRIED) || (l==LOC_WORN))
   {
    var w2 = objects.getObjectFullWeight(i);
    if (w + w2 > MAX_FLAG_VALUE)  w =MAX_FLAG_VALUE;  else w +=w2;
   }
  } 
  flags.setFlag(Parameter1, w);
  done = true;
}

/*--------------------------------------------------------------------------------------*/
function _RANDOM()
{
 flags.setFlag(Parameter1, Math.floor(Math.random()*101));
 done = true;
}

/*--------------------------------------------------------------------------------------*/
function _INPUT() 
{
  if (Parameter1<NUM_WINDOWS)
  {
    flags.setFlag(FINPUT, Parameter1);
    
    Parameter2 = Parameter2 << 3; //Move the three bits to their position in flag 49
    Parameter2 = Parameter2 & 0x38; //Isolate them: 00111000
    
    var flag49 = flags.getFlag(FTIMEOUT_CONTROL) & 0xC7; //Get flag 49 and clear the three bits affected by INPUT
    flags.setFlag(FTIMEOUT_CONTROL, flag49 | Parameter2);  //Combine bits
   } 

   done = true;
}

/*--------------------------------------------------------------------------------------*/
function _SAVEAT()
{
    SaveAt(); 
    done = true;
}

/*--------------------------------------------------------------------------------------*/
function _BACKAT()
{
    BackAt(); 
    done = true;
}

/*--------------------------------------------------------------------------------------*/
function _PRINTAT() 
{
    Printat(Parameter1, Parameter2); 
    done = true;
}

/*--------------------------------------------------------------------------------------*/
function _WHATO() 
{
    var currentNoun = flags.getFlag(FNOUN);
    var currentAdjective = flags.getFlag(FVERB);

    var objno = objects.getObjectByVocabularyAtLocation(currentNoun, currentAdjective, LOC_CARRIED);
    if (objno != NO_OBJECT) objects.setReferencedObject(objno);
    else 
    {
        objno = objects.getObjectByVocabularyAtLocation(currentNoun, currentAdjective, LOC_WORN);
        if (objno != NO_OBJECT) objects.setReferencedObject(objno);
        else
        {
            objno = objects.getObjectByVocabularyAtLocation(currentNoun, currentAdjective, flags.getFlag(FPLAYER));
            if (objno != NO_OBJECT) objects.setReferencedObject(objno);
            else
            {
                //Despite what documentation says, DAAD performs a search at ANY location if object not present 
                // getObjectByVocabularyAtLocation searchs at any location if location = MAX_LOCATION}
                objno = objects.getObjectByVocabularyAtLocation(currentNoun, currentAdjective, MAX_LOCATION);
                if (objno != NO_OBJECT) objects.setReferencedObject(objno);
                else objects.setReferencedObject(NO_OBJECT);
            }
        }
    }
    done = true;
 } 

/*--------------------------------------------------------------------------------------*/
function _CALL()
{
    // CALL not supported by jDAAD
    done = true;
}

/*--------------------------------------------------------------------------------------*/
function _PUTO() 
{
    Parameter2 = Parameter1;
    Parameter1 = flags.getFlag(FREFOBJ);
    _PLACE();
    done = true;
}

/*--------------------------------------------------------------------------------------*/
function _NOTDONE()
{
    done = false;
    DDB.consumeProcess(); //Go to last entry
    //force failure so we jump to next entry, which happens to be the mark of end of process
    condactResult = false; 
}

/*--------------------------------------------------------------------------------------*/
function _AUTOP() 
{
    if (Parameter1 == LOC_HERE) Parameter1 = flags.getFlag(FPLAYER);
    Parameter2 = Parameter1; //To use it with PUTIN
    var Noun = flags.getFlag(FNOUN);
    var Adject = flags.getFlag(FADJECT);
    Parameter1 = objects.getObjectByVocabularyAtLocation(Noun, Adject, LOC_CARRIED);
    if (Parameter1 != MAX_OBJECT) 
    {
        _PUTIN();
        return;
    }

    Parameter1 = objects.getObjectByVocabularyAtLocation(Noun, Adject, LOC_WORN);
    if (Parameter1 != MAX_OBJECT) 
    {
        _PUTIN();
        return;
    }

    Parameter1 = objects.getObjectByVocabularyAtLocation(Noun, Adject, flags.getFlag(FPLAYER));
    if (Parameter1 != MAX_OBJECT) 
    {
        _PUTIN();
        return;
    }

    Parameter1 = objects.getObjectByVocabularyAtLocation(Noun, Adject, MAX_LOCATION); //Any Location
    if (Parameter1 != MAX_OBJECT) Sysmess(SM28); //I don't have one of those.
                                else Sysmess(SM8); //I can't do that.
    newtext();
    _DONE();

}

/*--------------------------------------------------------------------------------------*/
function _AUTOT() 
{
    if (Parameter1 == LOC_HERE) Parameter1 = flags.getFlag(FPLAYER);
    Parameter2 = Parameter1; //To use it with TAKEOUT
    var Noun = flags.getFlag(FNOUN);
    var Adject = flags.getFlag(FADJECT);

    Parameter1 = objects.getObjectByVocabularyAtLocation(Noun, Adject, Parameter2); //In container
    if (Parameter1 != MAX_OBJECT) 
    {
        _TAKEOUT();
        return;
    }

    Parameter1 = objects.getObjectByVocabularyAtLocation(Noun, Adject, LOC_CARRIED);
    if (Parameter1 != MAX_OBJECT)
    {
        _TAKEOUT();
        return;
    }

    Parameter1 = objects.getObjectByVocabularyAtLocation(Noun, Adject, LOC_WORN);
    if (Parameter1 != MAX_OBJECT)
    {
    _TAKEOUT();
    return;
    }

    Parameter1 = objects.getObjectByVocabularyAtLocation(Noun, Adject, flags.getFlag(FPLAYER));
    if (Parameter1 != MAX_OBJECT) 
    {
        _TAKEOUT();
        return;
    }

    Parameter1 = objects.getObjectByVocabularyAtLocation(Noun, Adject, MAX_LOCATION); //Any Location
    if (Parameter1 != MAX_OBJECT) 
    {
        Sysmess(SM52); //There isn't one of those in the
        writeText(getMessageOTX( Parameter2, true, false, true));
        Sysmess(SM51); // . 
    }
    else Sysmess(SM8); //I can't do that.
    newtext();
    _DONE();
}

/*--------------------------------------------------------------------------------------*/
function _MOVE() 
{
    var ptr = DDB.getWord(DDB.header.connectionPos + 2 * flags.getFlag(Parameter1));
    do
    {
        var direction = DDB.getByte(ptr);
        if ((direction != END_OF_CONNECTIONS_MARK) &&  (direction == flags.getFlag(FVERB)))
        {
            flags.setFlag(Parameter1, DDB.getByte(ptr+1));
            return;
        } 
        ptr+=2;
    } while (direction != END_OF_CONNECTIONS_MARK);
    condactResult = false; //If no movement, condition fails
    done = true;
 }

/*--------------------------------------------------------------------------------------*/
function _WINSIZE()
{
    windows.windows[windows.activeWindow].height = Parameter1;
    windows.windows[windows.activeWindow].width = Parameter2;
    reconfigureWindow();
    done = true;
}

/*--------------------------------------------------------------------------------------*/
function _REDO()
{
    //Point 4 bytes below first entry because on return the engine will add 4
    DDB.entryPTR = DDB.getWord(DDB.processPTR) - 4; 
    condactResult = false;  //force so we get out of current entry and the jump to first entry
}

/*--------------------------------------------------------------------------------------*/
function _CENTRE()
{
    windows.windows[windows.activeWindow].col = (NUM_COLUMNS - windows.windows[windows.activeWindow].width) >> 1;
    done = true;
}

/*--------------------------------------------------------------------------------------*/
function _EXIT() 
{
 windows.resetWindows();
 if (Parameter1 == 0) 
 {
    _CLS;
    $('.goodbye').show();
 } 
 windows.resetWindows();
 flags.resetFlags();
 objects.resetObjects();
 _RESTART();
}

/*--------------------------------------------------------------------------------------*/
/* INKEY requires active keyboard reading, but we can't do it while there main thread
is running, so what we do is setting inINKEY to true and start a timeout of 50ms. That
allows keyboard events to happen, which will, in other part of the code, fill up the
keyboardStatus array. When the timeout expires, _INKEY2 checks if there is a key pressed
and updates data accordingly. 50 milliseconds is a good value, because it allows the
engine to receive events, but doesn't hold the game too long. */
function _INKEY() 
{
    if ((keyBoardStatus.length == 1) && (keyBoardStatus[0] == 13)) keyBoardStatus = []; // Remove pending CR
    inINKEY = true;
    setTimeout(() => {
        _INKEY2();
    }, 50);
}

function _INKEY2()
{
    if (keyBoardStatus.length)
    {
        flags.setFlag(FKEY1, keyBoardStatus[keyBoardStatus.length-1]);
        flags.setFlag(FKEY2,0);
        condactResult = true;
    }
    else
    {
        flags.setFlag(FKEY1,0);
        flags.setFlag(FKEY2,0);
        condactResult = false;
    } 
    run(true);

}

/*--------------------------------------------------------------------------------------*/
function _BIGGER()
{
    condactResult = flags.getFlag(Parameter1) > flags.getFlag(Parameter2);
}

/*--------------------------------------------------------------------------------------*/
function _SMALLER()
{
    condactResult = flags.getFlag(Parameter1) < flags.getFlag(Parameter2);
}

/*--------------------------------------------------------------------------------------*/
function _ISDONE()
{
    condactResult = done;
}

/*--------------------------------------------------------------------------------------*/
function _ISNDONE()
{
    condactResult = ! done;
}

/*--------------------------------------------------------------------------------------*/
function _SKIP()
{
    var OriginalSkip;
    if (Parameter1 >= 128) OriginalSkip = Parameter1 - 256; else OriginalSkip = Parameter1; //Bring back the -128 to 127 value
    DDB.entryPTR = DDB.entryPTR + 4 * OriginalSkip; 
    condactResult = false;
}

/*--------------------------------------------------------------------------------------*/
function _RESTART()
{
    //Reset the stack and the processes to go back to process 0
    DDB.resetProcesses();
    stack.resetStack();
    //When we force condact to fail, it will inrease entryPTR by 4 and continue execution
    //So we first make entryPTR point two point below
    DDB.entryPTR = DDB.getWord(DDB.processPTR) - 4;
    condactResult = false;
}

/*--------------------------------------------------------------------------------------*/
function _TAB()
{
    Tab(Parameter1); 
    done = true;
}

/*--------------------------------------------------------------------------------------*/
function _COPYOF()
{
    flags.setFlag(Parameter2, objects.getObjectLocation(Parameter1));
    done = true;
}

/*--------------------------------------------------------------------------------------*/
function _COPYOO()
{
 // Its like placing objno2 at objno1 location}
 var aux = Parameter2;
 Parameter2 = objects.getObjectLocation(Parameter1);
 Parameter1 = aux;
 _PLACE();
}

/*--------------------------------------------------------------------------------------*/
function _COPYFO()
{
 //Its like placing objno2 at flagno1
 var aux = Parameter2;
 Parameter2 = flags.getFlag(Parameter1);
 Parameter1 = aux;
 _PLACE();
}

/*--------------------------------------------------------------------------------------*/
function _dumb()
{
}

/*--------------------------------------------------------------------------------------*/
function _COPYFF()
{
 flags.setFlag(Parameter2, flags.getFlag(Parameter1));
 done = true;
}

/*--------------------------------------------------------------------------------------*/
function _COPYBF()
{
 flags.setFlag(Parameter1, flags.getFlag(Parameter2));
 done = true;
}

/*--------------------------------------------------------------------------------------*/
function _RESET()
{
 objects.resetObjects();
 done = true;
}


/*--------------------------------------------------------------------------------------*/


/* Mouse functions */

function showMouse() //Show the mouse pointer
{
    document.body.style.cursor = 'default';
    activeMouse = true;
}

function hideMouse() //Hide the mouse pointer
{
    document.body.style.cursor = 'none';
    activeMouse = false;
}

function GetMouse() //Get the mouse status
{
    var response = {};
    response.x = mouseX;
    response.y = mouseY;
    response.buttons = mouseButtons;
    return response;
}

/* SFX functions */


function PlayVideo(sfxno, loop)
{
    if (jDAADVideos.indexOf(sfxno) >= 0)
    {
        var filename = sfxno + '';
        while (filename.length < 3) filename = '0' + filename; // Make sure we have 3 digits
        filename += '.mp4';
        
        videoPlayer = document.createElement('video');
        videoPlayer.style.width = '100%';
        videoPlayer.style.height = '100%';
        videoPlayer.loop = loop;
        videoPlayer.src = filename;
        videoPlayer.addEventListener('ended', () => {
            $('#paper').css('display','block');
            inVideo = false;
        });
        document.getElementById('videolayer').innerHTML = '';
        document.getElementById('videolayer').appendChild(videoPlayer);
        $('#paper').css('display','none');
        videoPlayer.play();
        inVideo = true;
        //return video;
    }
}


function StopSound(isSFX)
{
    if (isSFX) audioSFX.pause();
    else audioMusic.pause();
}

function PlaySound(isSFX, sfxno, loop)
{
    if (jDAADSounds.indexOf(sfxno) >= 0)
    {
        var filename = sfxno + '';
        while (filename.length < 3) filename = '0' + filename; // Make sure we have 3 digits
        filename += '.mp3';
        if (isSFX)
        {
            audioSFX = new Audio(filename);
            audioSFX.loop = loop;
            audioSFX.play();
        }
        else
        {
            audioMusic = new Audio(filename);
            audioMusic.loop = loop;
            audioMusic.play();
        }
    }
}

/* GFX functions */
function DBBuffertoScreen() //Copy the buffer to the screen
{
    paper.drawImage(doublebuffer.canvas, 0, 0);
} 

function DBScreentoBuffer() //Copy the screen to the buffer
{
    doublebuffer.drawImage(paper.canvas, 0, 0);
}

function DBSwapBuffers() //Swap the buffers
{
    swapbuffer.drawImage(doublebuffer.canvas, 0, 0);
    doublebuffer.drawImage(paper.canvas, 0, 0);
    paper.drawImage(swapbuffer.canvas, 0, 0);
}

function DBGraphicsWriteToScreen() //Write the graphics buffer to the screen
{
    graphicsWriteToScreeen = true;
}

function DBGraphicsWriteToBuffer() //Write the graphics buffer to the buffer
{
    graphicsWriteToScreeen = false;
}

function DBClearBuffer()
{    
    doublebuffer.fillStyle = getFillStyle(windows.windows[windows.activeWindow].PAPER);
    doublebuffer.fillRect(0, 0, 320, 200)
}

function DBClearScreen()
{
    paper.fillStyle = getFillStyle(windows.windows[windows.activeWindow].PAPER);
    paper.fillRect(0, 0, 320, 200)
}

function DBTextWriteToScreen() //Write the text buffer to the screen
{
    textWriteToScreeen = true;
}

function DBTextWriteToBuffer() //Write the text buffer to the buffer
{
    textWriteToScreeen = false;
}

function DBSetPalette(Parameter1) //Set the palette
{
    colours[flags.getFlag(Parameter1)*3] = flags.getFlag(Parameter1 + 1);
    colours[flags.getFlag(Parameter1)*3 + 1] = flags.getFlag(Parameter1 + 2);
    colours[flags.getFlag(Parameter1)*3 + 2] = flags.getFlag(Parameter1 + 3);
}

function DBgetPalette(Parameter1)
{
    flags.setFlag(Parameter1 + 1, colours[flags.getFlag(Parameter1)*3]);
    flags.setFlag(Parameter1 + 2, colours[flags.getFlag(Parameter1)*3 + 1]);
    flags.setFlag(Parameter1 + 3, colours[flags.getFlag(Parameter1)*3 + 2]);
}

function getVirtualKeyboardKey(key)
{
    if (key=='COMMA') return ",";
    if (key=='DOT') return ".";
    if (key=='QUOTE') return "\"";
    if (key=='SPACE') return " ";
    if (key.length==1 && key>='A' && key<='Z') return String.fromCharCode(key.charCodeAt(0) + 32);
    if (key=='Ñ') return "ñ";
    return key;
}


function initVirtualKeyboard()
{
    debug('Mobile device detected', 'info');
    
    document.getElementById('screen').classList.remove("screenClass");
    document.getElementById('screen').classList.add("mobileScreenClass");

    // rearrange          
    var ratio = window.innerWidth / window.innerHeight;

    if (ratio>0.70) var scale = 80; else var scale = 100;

    $('#screen').css('width', Math.round(window.innerWidth*scale/100) + 'px');
    $('#screen').css('height', Math.round(window.innerWidth * scale/100 * 3 / 4) + 'px');
    
    var screenHeight = document.getElementById('screen').style.height;
    screenHeight = screenHeight.substring(0, screenHeight.length - 2); 
    screenHeight = parseInt(screenHeight) + 30;
    screenHeight += 'px';

    $('#virtualKeyboardDAAD').css('position', 'relative');
    $('#virtualKeyboardDAAD').css('top', screenHeight); 
    $('#virtualKeyboardDAAD').show();
    $('#scanlines').hide();

    // Set handlers

    virtualKeys = Array.from(window.document.querySelectorAll('.key'));

    virtualKeys.forEach(function(key) 
    {
        key.addEventListener('touchstart', function(e) {
            e.stopImmediatePropagation();
            var myevent = new KeyboardEvent('keydown', {"key": getVirtualKeyboardKey(e.target.id)});
            keydownHandler(myevent);
        });
        key.addEventListener('touchend', function(e) {
            e.stopImmediatePropagation();
            var myevent = new KeyboardEvent('keyup', {"key": getVirtualKeyboardKey(e.target.id)});
            keyupHandler(myevent);
        });      


    });
}

// Main

$(document).ready(function()
{
    console.log('jDAAD 1.2 (C) Uto ' + versionDate);


    
    // Handlers


    $(document).mousemove(function(e) 
    {
        if (activeMouse) 
        {
            var rect = paper.canvas.getBoundingClientRect();

            mouseX = e.clientX- rect.left;
            mouseY = e.clientY- rect.top;
            var scaleX = paper.canvas.width / rect.width;
            var scaleY = paper.canvas.height / rect.height;

            mouseX = Math.round(mouseX * scaleX);
            mouseY = Math.round(mouseY * scaleY);

        }
    });

    $(document).mousedown(function(e) 
    {
        //  Javascript: 0 for left, 1 for middle, 2 for right
        // DAAD:  1 LeftButton ,2 Right, 4 Middle
        if (activeMouse) 
        {
            if (e.button == 0) mouseButtons |= 1; // Left button
            if (e.button == 1) mouseButtons |= 4; // Middle button
            if (e.button == 2) mouseButtons |= 2; // Right button
            
        }
    });

    $(document).mouseup(function(e) 
    {
        //  Javascript: 0 for left, 1 for middle, 2 for right
        // DAAD:  1 LeftButton ,2 Right, 4 Middle
        if (activeMouse) 
        {
            if (e.button == 0) mouseButtons &= (255 - 1); // Left button
            if (e.button == 1) mouseButtons &= (255 - 4); // Middle button
            if (e.button == 2) mouseButtons &= (255 - 2); // Right button
            
        }
    });

    
    $(document).keydown(function(e) {
        keydownHandler(e);        
    });

    $(document).keyup(function(e) {
        keyupHandler(e);        
    });



    $(window).resize(function()
    {
        resizeScreen();
    });
    
	  
    // Virtual keyboard initialization    
    paper = document.getElementById('paper').getContext('2d', { willReadFrequently: true });
    doublebuffer = document.getElementById('doublebuffer').getContext('2d', { willReadFrequently: true });
    swapbuffer = document.getElementById('swapbuffer').getContext('2d', { willReadFrequently: true });
    
    resizeScreen();  
    // Init game  
    isMobileDevice = ('ontouchstart' in document.documentElement);
    if (isMobileDevice) initVirtualKeyboard();
    else 
    {
        $(document).click(function(e)
        {
            clickHandler(e);
        });
    
    }
    

    
    flags.resetFlags();         //Restores flags initial value
    objects.resetObjects();     //Restore objects to "initially at" locations
    windows.resetWindows();     //Clears all windows setup

    
    initializeParser(); 
    stack.resetStack();
    DDB.resetProcesses();
    document.getElementById('paper').focus();
    run(false); 
});

