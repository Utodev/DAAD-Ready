/*FALTA:

TO-DO:

- Timeouts in player input
- More when too much text printed
- Escape sequence '#k'. Note: if no doable, make the compiler stop with an error when target is html
- Make HTML.BAT build script get 6x8.CHR font and convert to font.js, so it's editable like the others

PENDING CHECKS:
 
 - Check if PARSE 1 works
 - Check containers and wearables
 - Check AUTOP/AUTOT with DOALL
 - Chequea getObjectFullWeight because in unclear circumstances it produced a stack overflow due to 
   endless loop

KNOW BUGS (or features):

- Beep can't sound until player has either clicked or pressed a key. It's a limitation of javascript
  so it can't be solved.

*/


// Constants

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
const LAST_CONVERTIBLE_NOUN=19; //Nouns convertible to verb in absence of verb. i.e "NORTH"
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


// The palette

const colours = [ [0x00,0x00,0x00],[0x00,0x00,0xAA], [0x00,0xAA,0x00],[0x00,0xAA,0xAA],[0xAA,0x00,0x00],[0xAA, 0x00, 0xAA], [0xAA, 0x55, 0x00],[0xAA, 0xAA, 0xAA]
                 ,[0x55,0x55,0x55],[0x55,0x55,0xFF], [0x55,0xFF,0x55],[0x55,0xFF,0xFF],[0xFF, 0x55, 0x55],[0xFF,0x55,0xFF], [0xFF, 0xFF, 0x55],[0xFF, 0xFF, 0xFF]];

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
    {condactName: 'MOUSE  ', condactRoutine: _MOUSE  , numParams: 1}, /*  86 0x56*/
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


class parserClass
{
    constructor()
    {

    }
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
        for (i=0;i<length;i++) result.push(this.getByte(address+i));
        return result;
    }


    setBlock(address, data)
    {
        for (i=0;i<data.length;i++) this.setByte(address + i, data[i]);
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
        this.processStack[this.stackPTR] = stackElement;
        this.stackPTR++;
    }
}

// global vars


var inputBuffer = '';
var imageBufferID = false;
var flags = new flagClass();
var objects = new objectClass();
var DDB  = new DDBClass();
var stack  = new stackClass();
var windows = new WindowArrayClass();
var paper; // This will be the 2D context for the canvas
var audioContext; // This will be default "soundcard"
var previousVerb = NO_WORD;
var playerOrderQuoted = '';
var playerOrder = '';
var conjunctions = [] ;
var globalParseOption = 0; // preseves the option given to PARSE calls (PARSE 1 or PARSE 2), so when the run() loops is broken and handler takes control, it can call back with the proper option
var XmessagePart = 0;

var keyBoardStatus = [];
var keyBoardStatusShiftKeys = 0;
var keyPressTreated = 0;

// Global var for the ReadText functions
var ticks = 0;
var TimeoutHappened = false;
var TimeoutSeconds = 0;
var TimeoutPreservedOrder = '';
var SaveX = 0;
var SaveY = 0;
var readTextStr = '';
var inputTakenFromPlayer = false;

// GLobal Vars por QUIT/END
var YesResponse = '';
var PreserveTimeout = 0;



var condactResult = false;
var done = false;
var Parameter1 =  0;
var Parameter2 = 0;
var inPARSE = false;
var inANYKEY = false;
var inEND = false;
var inQUIT = false;
var inSAVE = false;
var inLOAD = false;
var isTerminated = false;

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
            var moreDOALL = false;
            //If DOALL loop in execution}
            if (DDB.doallPTR != 0)
            {
                debug('In Doall');
                // Try to get next object at the doall location
                var nextDoallObjno = objects.getNextObjectAt(flags.getFlag(FDOALL), DDB.doallLocation);
                //If a valid object found jump back to DOALL entry/condact}
                if (nextDoallObjno != MAX_OBJECT) 
                {
                    DDB.entryPTR = DDB.doallEntryPTR;
                    DDB.condactPTR =  DDB.doallPTR;
                    objects.setReferencedObject(nextDoallObjno);
                    debug('Next DOALL Object:' + nextDoallObjno);
                    flags.setFlag(FDOALL, nextDoallObjno);
                    skipToRunCondact = true;
                    moreDOALL = true;
                }
                else  
                {
                //If in DOALL but no more objects mark doall inactive and just let 
                //the process continue and finish normally}
                debug('No more DOALL Objets');
                DDB.doallPTR = 0; 
                }
            }
            
            if (!moreDOALL)
            {
                debug ('Process finishes normally')
            //process finishes normally
                stack.stackPop();
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
        //debug('Check Valid Entry');
        ValidEntry = ((DDB.getByte(DDB.entryPTR) == flags.getFlag(FVERB)) || (DDB.getByte(DDB.entryPTR) == NO_WORD))
             && ((DDB.getByte(DDB.entryPTR+1) == flags.getFlag(FNOUN)) || (DDB.getByte(DDB.entryPTR+1) == NO_WORD));

        DDB.condactPTR = DDB.getWord(DDB.entryPTR + 2);

        if (!ValidEntry)
        {
            //debug('Entry Not Valid');
            DDB.entryPTR += 4;
            continue RunEntry;
        }
        debug('> ' + getWordByCodeType(DDB.getByte(DDB.entryPTR),VOC_VERB) + ' ' + getWordByCodeType(DDB.getByte(DDB.entryPTR+1), VOC_NOUN) );

    }   


    RunCondact: while (true)
    {
        skipToRunCondact = false;
        
        //First check if no more condacts in the entry, if so, move to next entry
        condactResult = true;
        var opcode = DDB.getByte(DDB.condactPTR);
        if (opcode == END_OF_CONDACTS_MARK)
        {
            debug('    EOC');
            DDB.entryPTR += 4;
            continue RunEntry;
        }

        //These flags should have specific values that code can use to determine the machine running the DDB
        // so they are being set after every condact to make sure even when modified, their value is restored
        flags.setFlag(FSCREENMODE, 14 + 128); //Makes sure flag 62 has proper value: mode 14 (JDAAD SCeen) and bit 7 set
        flags.setFlag(FMOUSE, 128); //Makes sure flag 29 has "graphics" available set, and the rest is empty}

        //Let's run the condact
        var indirection =  ((opcode & 0x80) != 0) 
        if (indirection) opcode &= 0x7F;
        var debugStr = condactTable[opcode].condactName + ' ';
        
        //get parameters
        if (condactTable[opcode].numParams > 0) 
        {
            DDB.condactPTR++;
            Parameter1 = DDB.getByte(DDB.condactPTR);
            if (indirection)
            {
                if (indirection) debugStr = debugStr + '@';
                Parameter1 = flags.getFlag(Parameter1);
                
            }
            debugStr = debugStr + Parameter1;
            if (condactTable[opcode].numParams>1) 
            {
                DDB.condactPTR++;
                Parameter2 = DDB.getByte(DDB.condactPTR);
                debugStr = debugStr + ' ' + Parameter2;
            }
        }
        
        debug('    ' + debugStr);
        //run condact
        condactResult = true;
        condactTable[opcode].condactRoutine(); //Execute the condact
        if (inPARSE || inANYKEY || inQUIT ||inEND || inSAVE || inLOAD)  return; // get out of main loop as we are now just waiting for keypress 
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
    ptr = DDB.header.vocabularyPos;
    while (DDB.getByte(ptr)!= 0) 
    {
        if (VOC_TYPE.indexOf(DDB.getByte(ptr+6)) == VOC_CONJUGATION)
        {
        aVocWord = '';
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


function fixSpanishCharacters(str)
{
  var encodeStr = 'º¡¿«»áéíóúñÑçÇüÜ';
  var output = '';
  for (var i=0;i<str.length;i++) 
  {
        switch(str.charAt(i))
        {
        case 'ñ': output += 'Ñ';break;
        case 'ç': output += 'Ç';break;
        case 'á':
        case 'Á': output +='A';break;
        case 'é':
        case 'É': output +='E';break;
        case 'í':
        case 'Í': output +='I';break;
        case 'ó':
        case 'Ó': output +='O';break;
        case 'ú':
        case 'Ú':
        case 'Ü': 
        case 'ü': output +='U';break;
        }
        if (encodeStr.indexOf(str.charAt(i))!=-1) output += String.fromCharCode(16 + encodeStr.indexOf(str.charAt(i)));
        else output += str.charAt(i)
    }
    return output; 
}


function getCommand(usePrompt)
{
        inputBuffer = '';
        if (usePrompt) Sysmess(SM33); //the prompt
        //When the prompt appears the last pause line of all windows is resetted
        for(var i=0;i<NUM_WINDOWS;i++) windows.windows[i].lastPauseLine = 0;
        inputBuffer = readText(); //fromEvent = false
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
    ptr = DDB.header.vocabularyPos;
    Result.aCode = -1;
    aWord = aWord.toUpperCase();
    while (DDB.getByte(ptr)!= 0) 
    {
        //Get a word from Vocabulary
        aVocWord = '';
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
    
    ptr = DDB.header.vocabularyPos;   
    while (DDB.getByte(ptr)!= 0) 
    {
        //Get a word from Vocabulary
        aVocWord = '';
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
    getCommand(true, false); // usePrompt =true, fromCallBack = false
}

function getPlayerOrdersB()
{
    inputBuffer= inputBuffer.toUpperCase();
    for (i=0; i< conjunctions.length;i++)
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
            PreserveStream();
            // Print prompt
            if (flags.getFlag(FPROMPT) == 0)
            {
                var i = Math.floor(Math.random(4)*4);
                Sysmess(SM2 + i);
            }
            else if (flags.getFlag(FPROMPT) < DDB.header.numSys) Sysmess(flags.getFlag(FPROMPT));

            inPARSE=true; // Make the keyboardHanlder active as we will ask for an order
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
      i = 0;
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
          playerOrderQuoted = playerOrder.substring(playerOrder.indexOf('"')+1);
          if (playerOrderQuoted.indexOf('"') != -1)  playerOrderQuoted = playerOrderQuoted.substring(0,playerOrderQuoted.indexOf('"')-1);
          playerOrder =  playerOrder.substring(playerOrder.indexOf('"')-1);
      
          //Because orginal interpreters make a difference betwee 'SAY JOHN'  and 'SAY JOHN ""'}
          playerOrderQuoted = playerOrderQuoted.trim();
          if (playerOrderQuoted=='') playerOrderQuoted = ' '; 
      }
      else playerOrderQuoted = '';     
}

function parseEnd()
{
    result = false;
    if (playerOrder == '') // This can only happen if we get here from a PARSE 1 or above
        return  false; // To force next condact execution 


    playerOrder = playerOrder.trim();

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
        aSearchWord = orderWords[i]; 
        aWordRecord = findWord(aSearchWord, VOC_ANY);
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
                    j = 0;
                    while ((j<4) && (!pronounInSentence)) 
                    {
                    //check if the verb ends with one of the pronominal suffixes
                        if (otherWords[i].toUpperCase().indexOf(SPANISH_TERMINATIONS[j]) ==  1 + orderWords[i].length - SPANISH_TERMINATIONS[j].length)
                        {
                            //If we have a word ending with pronominal suffixes, we need to check whether the word is a verb 
                            //also without the termination, to avoid the HABLA bug where "LA" is part of the verb habLAr and
                            //not a suffix. So first we remove the termination:}

                            aSearchWord =  orderWords[i].substring(0, orderWords[i].length - SPANISH_TERMINATIONS[j].length -1);
                            //Then check if still can be recognized as a verb}
                            aWordRecord = FindWord(aSearchWord, VOC_VERB);
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
    {
        flags.setFlag(FVERB, flags.getFlag(FNOUN));
        flags.setFlag(FNOUN, NO_WORD);
    }

    //Missing verb but present noun, replace with previous verb}
    if (!inputTakenFromPlayer)  //If the current sentece came from buffer
    if ((flags.getFlag(FVERB)==NO_WORD) && (flags.getFlag(FNOUN)!=NO_WORD) && (previousVerb!=NO_WORD))  flags.setFlag(FVERB, PreviousVerb);

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
    if (flags.getFlag(FVERB)!=NO_WORD) pPreviousVerb = flags.getFlag(FVERB);

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
                if (caps) newArticle = 'El'; else newArticle = 'el';
                return newArticle + str.substring(2);
            }
        
            //una, unos, unas --> la, los, las}
            if ((str.charAt(0).toUpperCase() == 'U') && (str.charAt(1).toUpperCase() == 'N')) 
            {
                if (caps) newArticle = 'L'; else newArticle = 'L';
                return newArticle + str.substring(2);
            }
        }
        else // English
        {
            
            //a -> empty string}
            if ((str.charAt(0).toUpperCase() == 'A') && (str.charAt(1) == ' ')) 
            {
                return str.substring(2);
            }
        
            //some -> empty string}
            if ((str.charAt(0).toUpperCase() == 'S') && (str.charAt(1).toUpperCase() == 'O') && (str.charAt(2).toUpperCase() == 'M') && (str.charAt(3).toUpperCase() == 'E') && (str.charAt(4)==' ')) 
            {        
            return str.substring(5);
            }
        }
    }//if replace
    return str;  
}


function getToken(id)
{
    index = 0;
    ptr = DDB.header.tokenPos + 1; //Apparently, token table starts one byte after the token pointer
    while (index < id) 
    {
     if (DDB.getByte(ptr) > 127) index++;
     ptr++;
    }
   
    auxStr = '';
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
            tokenID = (aByte ^ OFUSCATE_VALUE) - 128;
            token = getToken(tokenID);
            workStr += token
        }
        else 
        {
            mychar = String.fromCharCode(aByte ^ OFUSCATE_VALUE);
            if ((mychar == ESCAPE_OBJNAME) || (mychar == ESCAPE_OBJNAME_CAPS))
            {
                escapeText = getMessageInternal(DDB.header.objectPos, flags.getFlag(FREFOBJ));
                escapeText = replaceArticles(escapeText, true, aByte == ESCAPE_OBJNAME_CAPS, true);
                workStr += escapeText;
            } 
            else workStr += mychar;
        }  
        ptr++;
        aByte = DDB.getByte(ptr);
    }   
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

function debug(string)
{
    if (DEBUG_ENABLED) console.log(string);
}

function setShiftKeys(e)
{
    keyBoardStatusShiftKeys = 0;
    if (e.shiftKey) keyBoardStatusShiftKeys+=1;
    if (e.altKey) keyBoardStatusShiftKeys+=2;
    if (e.ctrlKey) keyBoardStatusShiftKeys+=4;
    if (e.metaKey) keyBoardStatusShiftKeys+=8;
}

function keyupHandler(e)
{
    console.log('D:' + String.fromCharCode(e.keyCode) +'(' + e.keyCode +')');
    //Save keyup status for each key to be used with INKEY
    if (keyBoardStatus.includes(e.keyCode)) 
        keyBoardStatus.splice(keyBoardStatus.indexOf(e.keyCode))
    setShiftKeys(e);

}

function checkSpecialKeyCodes(keyCode, ctrlKey)
{
    if (keyCode == 116) return true; //F5
    if (keyCode == 123) return true; //F12
    if ((ctrlKey) && (keyCode==82)) return true; // Ctrl+R

}
    

function clickHandler(e)
{
    if (inANYKEY)
    {
        inANYKEY = false;
        e.preventDefault();
        DDB.condactPTR++; // Point to next condact
        run(true); // skipToRunCondact = true
    }
}


function keypressHandler(e)
{
    console.log('K:' + String.fromCharCode(e.charCode) +'(' + e.charCode +')');
    if (inQUIT || inEND || inSAVE || inLOAD || inPARSE)
    {
        // If keyDown didn't handle it
        if (!keyPressTreated) readTextB(e.charCode);
    }
}

function keydownHandler(e)
{
    console.log('D:' + String.fromCharCode(e.keyCode) +'(' + e.keyCode +')');

    keyPressTreated = false;

    //Save keydown status for each key to be used with INKEY    
    if (!keyBoardStatus.includes(e.keyCode)) 
        keyBoardStatus.push(e.keyCode); 
    setShiftKeys(e)

    if (inQUIT || inEND || inSAVE || inLOAD || inPARSE)
    {
        if (checkSpecialKeyCodes(e.keyCode, e.ctrlKey)) return true; 
        
        //if it's not standard ascii letter try to process the code
        if (e.keyCode < 32)
        {
            keyPressTreated = true;
            readTextB(e.keyCode);
        } 
            
    }

    if (inANYKEY)
    {
        inANYKEY = false;
        if (checkSpecialKeyCodes(e.keyCode, e.ctrlKey)) return true; 
        e.preventDefault();
        DDB.condactPTR++; // Point to next condact
        run(true); // skipToRunCondact = true
    }
}

function Extern(a, b)
{
    if (externHandlers[b] === null) // Extern hasn't been loaded
    {
        var script = document.createElement("script");
        script.setAttribute("type", "text/javascript");
        script.setAttribute("src", 'extern' + b + '.js');
        document.getElementsByTagName("head")[0].appendChild(script);
    }
    var callFunction = externHandlers[b];
    callFunction(a);
}


function delay(seconds)
{
    var milliseconds = seconds * 1000;
    var start = Date.now();
    var now = start;
    while (now - start < milliseconds) now = Date.now();    
}


function clearWindow(X, Y, width, height, paperColor)
{
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


function pixelRGB(x, y, r, g, b)
{
    var rhex = r.toString(16); if (rhex.length < 2) rhex = '0' + rhex;
    var ghex = g.toString(16); if (ghex.length < 2) ghex = '0' + ghex;
    var bhex = b.toString(16); if (bhex.length < 2) bhex = '0' + bhex;
    var colorCode = ('#' + rhex + ghex + bhex).toUpperCase() ;
    paper.fillStyle = colorCode;
    paper.fillRect(x,y,1,1);
}


function pixel(x,y, colour)
{
    pixelRGB(x, y, colours[colour][0],colours[colour][1], colours[colour][2]);
}



function nextChar()
{
 //Increase X
 windows.windows[windows.activeWindow].currentX = windows.windows[windows.activeWindow].currentX + COLUMN_WIDTH; 
 //If out of boundary increase Y
 if (windows.windows[windows.activeWindow].currentX >= (windows.windows[windows.activeWindow].col + windows.windows[windows.activeWindow].width) * COLUMN_WIDTH )
 {
    windows.windows[windows.activeWindow].currentX = windows.windows[windows.activeWindow].col * COLUMN_WIDTH;
    windows.windows[windows.activeWindow].currentY = windows.windows[windows.activeWindow].currentY + LINE_HEIGHT;
    //if out of boundary scroll window}
    if (windows.windows[windows.activeWindow].currentY >= (windows.windows[windows.activeWindow].line + windows.windows[windows.activeWindow].height) * LINE_HEIGHT )  ScrollCurrentWindow();
 }
}

function writeChar(c)
{
    switch(c)
    {
        case 0x0E: charsetShift  =128; break; //#g
        case 0x0F: charsetShift  =0; break; // #t
        case 0x0B : clearCurrentWindow();break; //#b
        // case 0x0C : { while (!keyPressed()) {}; i = readKey(); };break; //#k //This #k is very hard to support in javascript, so it's not supported
        default:
        {
            
            if (windows.windows[windows.activeWindow].currentX + COLUMN_WIDTH >= (windows.windows[windows.activeWindow].col + windows.windows[windows.activeWindow].width) * COLUMN_WIDTH ) 
            {
                nextChar();
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
            nextChar();
            
        }
    } // switch(c)
}

function StrLenInPixels(Str)
{
    return Str.length * 6;
}

function writeWord(aWord)
{
    var Xlimit = (windows.windows[windows.activeWindow].col +  windows.windows[windows.activeWindow].width) * 6; //First pixel out of the window}
    
    if (StrLenInPixels(aWord) + windows.windows[windows.activeWindow].currentX >= Xlimit) carriageReturn();
    if  (! (windows.lastPrintedIsCR  && (aWord==' ')) )
        for (var i = 0; i<aWord.length;i++) writeChar(aWord.charCodeAt(i));
    windows.lastPrintedIsCR = false;
     
}

//Writes any text to output
function writeText(aText, doDebug=true)
{
    if (doDebug) debug('Output:' + aText);
    var aWord = '';
    for (var i=0; i < aText.length ; i++)
    {
        switch(aText.charCodeAt(i))
        {
            case 13: writeWord(aWord);aWord='';carriageReturn();break
            case 32: writeWord(aWord);aWord='';writeWord(' ');break;
            default: aWord  = aWord + aText.charAt(i); break;
        }
    }
    writeWord(aWord);
}

function PatchStr(Str)
{
 var finalStr ='';
 for (i=0;i<Str.length;i++)
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
   case 'ü': finalStr = finalStr + String.fromCharCode(31); break;
   default: finalStr = finalStr + Str.charAt(i);
 }
 return finalStr;
};

       

// The original PCDAAD readText is split in parts as the key pressing part shoud be somwhere in an eveny handler
function readText()
{
    readTextStr = '';
    saveX  =windows.windows[windows.activeWindow].currentX;
    saveY  =windows.windows[windows.activeWindow].currentY;
    /*if timeout last frame, and there is text to recover, and we should recover*/
    /*bits 7, 6 and 5 for FTIMEOUT_CONTROL set*/
    if ((flags.getFlag(FTIMEOUT_CONTROL) & 0xE0) == 0xE0) 
    {
        readTextStr = TimeoutPreservedOrder;
        TimeoutPreservedOrder = '';
    }
    flags.setFlag(FTIMEOUT_CONTROL, flags.getFlag(FTIMEOUT_CONTROL)& 0x3F); //Clear bits 7 and 6
    writeText(readTextStr+'_', false);
    timeoutHappened = false;
    timeoutSeconds = flags.getFlag(FTIMEOUT);
    ticks  = getTicks(); //FALTA: implementar Timeout
    playerPressedKey  = false;
    // The main "wait for a key" loop would start here, but we exit to leave things in hands of the keydown handler
}

function readTextB(keyCode)
{
    var Xlimit = (windows.windows[windows.activeWindow].col +  windows.windows[windows.activeWindow].width) * COLUMN_WIDTH; //First pixel out of the window
    if ((keyCode>=32) && (keyCode<=255))
    {
        if ((readTextStr.length + 2) * COLUMN_WIDTH   + saveX  < Xlimit) // +2 because is one more for the new char being added and another one cause the cursor '_'
        readTextStr += String.fromCharCode(keyCode).toUpperCase() //printable characters
    }
    else
    if ((keyCode==8) && (readTextStr!=''))
    {
        clearWindow(saveX + (readTextStr.length)* COLUMN_WIDTH, saveY, COLUMN_WIDTH, LINE_HEIGHT , windows.windows[windows.activeWindow].PAPER);
        readTextStr = readTextStr.slice(0, -1);
    }
    windows.windows[windows.activeWindow].currentX = saveX;
    windows.windows[windows.activeWindow].currentY = saveY;
    var PatchedStr = PatchStr(readTextStr);
    writeText(PatchedStr + '_', false);
    if ((keyCode==13) && (readTextStr!=''))
    {
        // Remove the cursor
        clearWindow(saveX + readTextStr.length * COLUMN_WIDTH ,  saveY, COLUMN_WIDTH, LINE_HEIGHT , windows.windows[windows.activeWindow].PAPER); 
        carriageReturn();
        // Ok, now we have the content of the text readed. Now, depending on the condact that asked for a text to be read (PARSE, QUIT or END), we 
        // need to return to the main loop in a different way
        inputBuffer = readTextStr;
        getCommandB();
    }
}

function carriageReturn()
{
    windows.windows[windows.activeWindow].currentX = windows.windows[windows.activeWindow].col * COLUMN_WIDTH;
    windows.windows[windows.activeWindow].currentY = windows.windows[windows.activeWindow].currentY + LINE_HEIGHT;
    windows.windows[windows.activeWindow].lastPauseLine = windows.windows[windows.activeWindow].lastPauseLine + 1;
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
    var img = paper.getImageData(win.col * COLUMN_WIDTH, (win.line+1) * LINE_HEIGHT, win.width * COLUMN_WIDTH, (win.height-1) * LINE_HEIGHT);
    clearWindow(win.col * COLUMN_WIDTH, (win.line+win.height-1) * LINE_HEIGHT, win.width * COLUMN_WIDTH, LINE_HEIGHT, win.PAPER);
    paper.putImageData(img, win.col * COLUMN_WIDTH, win.line*LINE_HEIGHT);

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
     writeText( PatchedStr + chr(13));
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
    for (i=0;i<images.length;i++)
    {
          var img=new Image();
          img.src=images[i] + '.png';
    }
}

function resizeScreen()
{
    var height = window.innerHeight;
    var width = window.innerWidth;
    
    var chosenHeight = height - 200;
    var chosenWidth = Math.round(chosenHeight * 4 /3);
    if (chosenWidth > width)
    {
      chosenWidth = width - 100;
      chosenHeight = Math.round(width * 3 / 4);
    }
    $('.wrapper').css('width',chosenWidth + 'px');
    $('.wrapper').css('height',chosenHeight + 'px');
    
    var fontSize = 4.5  * chosenWidth / width;
    $('body').css('font-size', fontSize + 'vw');

}

function listObjects(locno, isLISTAT)
{
    var count =objects.getObjectCountAt(locno);
    var continuousListing = (flags.getFlag(FOBJECT_PRINT_FLAGS) & 64) != 0;
    var listed = 0;
    
    if (count> 0) 
    {
       flags.setFlag(FOBJECT_PRINT_FLAGS, flags.getFlag(FOBJECT_PRINT_FLAGS) | 0x80); //Set bit 7
       
       if (!isLISTAT) 
       {
        Sysmess(SM1); //I can also see: (Only for LISTOBJ)
        if (!continuousListing)  _NEWLINE();
       }
   
       for(var i=0; i < DDB.header.numObj; i++)
       {
           if (objects.getObjectLocation(i) == locno) 
           {
               writeText(getMessageOTX(i, false, false, continuousListing));
               listed++;
               if (continuousListing)
               { 
                   if (listed == count) Sysmess(SM48);  // .
                   else if (listed == count - 1)  Sysmess(SM47); // "and"
                   else Sysmess(SM46); // , 
               }
               else _NEWLINE();
           } 
        }  
    }
    else
    { //if no objects at the location
        flags.setFlag(FOBJECT_PRINT_FLAGS, flags.getFlag(FOBJECT_PRINT_FLAGS) & 0x7F); //Clear bit 7
        if  (isLISTAT) Sysmess(SM53); //"Nothing"
    }
    
   
}




// MALUVA condacts

function XPart(part)
{
    XmessagePart = part;
}

function Xmes(offset)
{
    var backup = DDB.getBlock(DDB.getWord(DDB.header.sysmessPos), 512);
    for (i=0;i<512;i++) DDB.setByte(DDB.getWord(DDB.header.sysmessPos) + i, XMBDATA[offset + i]);
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
    objectLocation = objects.getObjectLocation(Parameter1);
    condactResult = (objectLocation == LOC_CARRIED) || (objectLocation == LOC_WORN) || (objectLocation == flags.getFlag(FPLAYER)) ;
}

/*--------------------------------------------------------------------------------------*/
function _ABSENT()
{
    objectLocation =objects.getObjectLocation(Parameter1);
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
 // PENDING, SFX condact
 done = true;
}

/*--------------------------------------------------------------------------------------*/
function _DESC()
{
  writeText(getMessage(DDB.header.locationPos, Parameter1)); 
  done = true;
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
   windows.windows[windows.activeWindow].lastPauseLine = 0;
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
    windows.windows[windows.activeWindow].lastPauseLine = 0;
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
 DDB.ConsumeProcess; //Go to last entry
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
    inANYKEY = true;
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
    var imageWidth = image[image.length - 2];
    var imageHeight = image[image.length - 1];


    var windowX = windows.windows[windows.activeWindow].col * COLUMN_WIDTH;
    var windowY = windows.windows[windows.activeWindow].line * LINE_HEIGHT;
    var windowWidth = windows.windows[windows.activeWindow].width * COLUMN_WIDTH;
    if ((windowWidth==318) || (windowWidth==319)) windowWidth=320;
    var windowHeight = windows.windows[windows.activeWindow].height* LINE_HEIGHT;

    
    
    for (y=0;y<imageHeight;y++)
        for(x=0;x<imageWidth;x++)
         {          
            if ((x<windowWidth) && (y<windowHeight)) // clip image
            {
                var data = image[imageWidth*y + x];
                var r = (data >> 16) & 0xFF;
                var g = (data >> 8) & 0xFF;
                var b = data & 0xFF;

                pixelRGB(windowX+ x, windowY + y, r, g, b);
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
   for(var locno = LOC_CARRIED; locno<=LOC_WORN; locno++)
   {
        nextObject = - 1;
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
 debug('AUTOD: ' + Parameter1);
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
 if (Parameter1 = 0) delay(5.12); else delay(Parameter1/50); 
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
 _MES();
 _NEWLINE();
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
 ObjectLocation = objects.getObjectLocation(Parameter1);
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
  doallPTR = 0;
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
  exit;
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
 objects.setObjectLocation(Parameter2, aux);
 objects.setReferencedObject(Parameter2);
 done = true;
}

/*--------------------------------------------------------------------------------------*/
function _PLACE()
{
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
 value = flags.getFlag(Parameter1);
 valstr = value + '';
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
    condactResult = flags.getFlagBit(59 - Math.floor(Parameter1,8), Parameter1 % 8);
}

/*--------------------------------------------------------------------------------------*/
function _HASNAT()
{
    condactResult = ! flags.getFlagBit(59 - Math.floor(Parameter1,8), Parameter1 % 8);
}

/*--------------------------------------------------------------------------------------*/
function _LISTOBJ()
{
    listObjects(flags.getFlag(FPLAYER), false);
    done = true;
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
    listObjects(Parameter1, true); 
    done = true;
}

/*--------------------------------------------------------------------------------------*/
function _PROCESS()
{
    if (Parameter1 >= DDB.header.numPro) Error(3, 'Process ' + Parameter1 + 'does not exist'); 
    stack.stackPush();
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
function _MES()
{
  writeText(getMessage(DDB.header.messagePos, Parameter1));
  done = true;
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
        imageBufferID = false;
        condactResult = false;
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
 objno = objects.getNextObjectAt(-1, Parameter1);
 if (objno!=MAX_OBJECT)
 {
    DDB.doallPTR = DDB.condactPTR + 1; //Point to next Condact after DOALL
    DDB.doallEntryPTR = DDB.entryPTR;
    DDB.doallLocation = Parameter1;
    flags.setFlag(FDOALL,objno);
    objects.setReferencedObject(objno);
    done = true;
 }
 else 
 {
    debug('Mal doall');
    Sysmess(SM8);
    newtext();
    _DONE();
 } 
}

/*--------------------------------------------------------------------------------------*/
function _MOUSE()
{
// PENDING: MOUSE condact implementation
done = true;
}

/*--------------------------------------------------------------------------------------*/
function _GFX() 
{
// PENDING: GFX condact implementation 
done = true;
}

/*--------------------------------------------------------------------------------------*/
function _ISNOTAT()
{
    condactResult = objects.getObjectLocation(Parameter1) != Parameter2;
}

/*--------------------------------------------------------------------------------------*/
function _WEIGH()
{
 flags.setFlag(Parameter2, getObjectFullWeight(Parameter1));
 done = true;
}

/*--------------------------------------------------------------------------------------*/
function _PUTIN() 
{
    objects.setReferencedObject(Parameter1);
    ObjectLocation =objects.getObjectLocation(Parameter1);
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
    objects.setReferencedObject(Parameter1);
    ObjectLocation =objects.getObjectLocation(Parameter1);
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
        writeText(getMessageOTX( Parameter2, true, false, true), false);
        Sysmess(SM51);//.
        newtext();
        _DONE();
        return;
    }

    if ((ObjectLocation != flags.getFlag(FPLAYER)) && (ObjectLocation != Parameter2))
    {
        Sysmess(SM52); //There isn't one of those in the
        _SPACE();
        writeText(getMessageOTX( Parameter2, true, false, true), false);
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
        doallPTR = 0;
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
   l = objects.getObjectLocation(i);
   if ((l==LOC_CARRIED) || (l==LOC_WORN))
   {
    w2 = objects.getObjectFullWeight(i);
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
    
    flag49 = flags.getFlag(FTIMEOUT_CONTROL) & 0xC7; //Get flag 49 and clear the three bits affected by INPUT
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
    DDB.ConsumeProcess(); //Go to last entry
    //force failure so we jump to next entry, which happens to be the mark of end of process
    condactResult = false; 
}

/*--------------------------------------------------------------------------------------*/
function _AUTOP() 
{
    Parameter2 = Parameter1; //To use it with PUTIN
    Noun = flags.getFlag(FNOUN);
    Adject = flags.getFlag(FADJECT);
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
}

/*--------------------------------------------------------------------------------------*/
function _EXIT() 
{
 resetWindows();
 if (Parameter1 = 0) 
 {
    _CLS;
    $('.goodbye').show();
 } 
 resetWindows();
 flags.resetFlags();
 resetObjects();
 _RESTART();
}

/*--------------------------------------------------------------------------------------*/
function _INKEY() 
{
    if (keyBoardStatus.length)
    {
        flags.setFlag(FKEY1, keyBoardStatus[keyBoardStatus.length-1]);
        flags.setFlag(FKEY2, keyBoardStatusShiftKeys);
        condactResult = true;
    }
    else
    {
        flags.setFlag(FKEY1,0);
        flags.setFlag(FKEY2,0);
        condactResult = false;
    } 
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
 aux = Parameter2;
 Parameter2 = objects.getObjectLocation(Parameter1);
 Parameter1 = aux;
 _PLACE();
}

/*--------------------------------------------------------------------------------------*/
function _COPYFO()
{
 //Its like placing objno2 at flagno1
 aux = Parameter2;
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


// Main

$(document).ready(function()
{
    console.log('jDAAD 1.0 (C) Uto');

    // Handlers
    $(window).resize(function()
    {
        resizeScreen();
    });

    
    $(document).keydown(function(e) {
        keydownHandler(e);        
    });

    $(document).keyup(function(e) {
        keyupHandler(e);        
    });


    $(document).keypress(function(e) {
        keypressHandler(e);        
    });


    $(document).click(function(e)
    {
        clickHandler(e);
    });


    paper = document.getElementById('paper').getContext('2d', { willReadFrequently: true });

    // Init game  
    resizeScreen();  
    flags.resetFlags();         //Restores flags initial value
    objects.resetObjects();     //Restore objects to "initially at" locations
    windows.resetWindows();     //Clears all windows setup

    
    initializeParser(); 
    stack.resetStack();
    DDB.resetProcesses();
    document.getElementById('paper').focus();
    run(false); 
});

