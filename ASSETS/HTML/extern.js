/*
IMPORTANT: If you are using DAAD-Ready, modify this file in the ASSETS/HTML folder, 
not in RELEASE/HTML folder, or your changes will be overwritten


HOW EXTERN WORKS IN jDAAD:

1) EXTERN condact has two parameters, let´s call them Parameter1 and Parameter2
2) You can create a different function per each value of Parameter2. Parameter1 
   will be sent to that function. So Parameter2 is like function name, and 
   Parameter 1 is the real parameter.
3) To add a new function, for instance for Parameter2 = 100, you first add a new
   function to this file, under the  "// Functions to handle each extern" comment, 
   for instance you can add:

    function whateverthename(parameter1)
    {
        // do whatever
    }

3) Then you add a new line at the end of the file like this:

    externHandlers[100] = whateverthename;

4) After doing that, when "EXTERN x 100" is called in DAAD code, whaterverthename(x) 
   will be called called in javascript

Accesing game data
------------------
You can access flags and object locations like this:

flags.setFlag(flagno, value);
var val = flags.getFlag(flagno);

objects.setObjectLocation(objno, locno);
var objectLocation = objects.getObjectLocation(objno);

You can also access any javascript data in the game, so you can access Window position
current cursor, pictures data, etc. Check jdaad.js source code to find what you need.

Maluva
------
By default jDAAD supports Maluva extension emulator for XMESSAGE and XPART, which
means functions 3 and 4 are already taken and you won't get a call for your extern
handler functions if Parameter2 is 3 or 4. Just use some others or, in case 
you really need to use those and you are not going to use XMESSAGES, just modify 
the value of MALUVA_DISABLED constant in jdaad.js (in the ASSETS/HTML folder) to 
be true instead of false.

*/


// Gobal vars for externs
var externHandlers = [];

// Initialize Externs
for (i=0;i<256;i++) externHandlers.push(null);

// Functions to handle each extern
function dumbExtern(parameter1) // Example
{
    console.log('Dumb extern function 0 called with value ' + parameter1);
}

// Initialize handlers per each parameter2
externHandlers[0] = dumbExtern; // Example