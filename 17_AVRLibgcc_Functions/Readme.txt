The sketches in this folder are all demonstrations of the various arithmetic routines in the Libgcc library supplied with the Arduino IDE, but not documented.

The file, libgcc_alias.h, is a header file which could, with a little work, be installed as a library and then used in your own Assembly Language sketches to alias the "interesting" names given to the functions in the Libgcc library, with more meaningful ones. The example sketches don't use this header --- it appears that it cannot be #included from a relative path --- simply I'm using a #define instead. I could have put a copy of the header in *every* example, but that would have been a nightmare if I need to make an amendment!

The example sketches are Assembly Language only, so there's no C++ to display results and such like. The code is provided as an example of how to call the various functions from Assembly. What you do with the results is obviously up to you, but I tested mine in the simulator.


EXAMPLE SKETCHES
================

Clz_16, Clz_32: Count the number of leading zeros in a 16 or 32 bit value. Leading in this context means counting from the most significant bit.

Ctz_16, Ctz_32: Count the number of trailing zeros in a 16 or 32 bit value. Leading in this context means counting from the least significant bit.

Div_s8_s8, Div_S16_S16, Div_s32_s32: These are signed 8, 16 and 32 bit division functions.

Div_u8_u8,Div_u16_u16, Div_u32_u32: These are unsigned 8, 16 and 32 bit division functions.

Ffs_16, Ffs_32: Find first set bit in 16 and 32 bit values. First, in this context, means from the least significant bit and not the most significant bit as would normally be expected by "first"!

Mult_s16_s16, Mult_s32_s32: 16 and 32 bit, signed multiplication functions. There are no equivalent unsigned functions in the Libgcc library.

Mult_s16_u16: This function multiplies a signed 16 bit value by an unsigned 16 bit value.


Libgcc_alias.h: This is a header file to #include in your Assembly sketches to save you having to remember the cryptic names of the various Libgcc functions. You can either add it to your sketches by copying it into the sketch's source directory; or, create a library containing only this file and install it into the Arduino IDE.


TESTING THE EXAMPLES
====================

The following applies only to Linux as that is my Operating System of choice. I no longer have access to Windows.

1. You will need to open the IDE and click File->Preferences and enable verbose compilation as you need to see the location that the compiled sketch is written to. From IDE version 2.3.4 onwards, the compilations (on Linux anyway) are written to ${HOME}/.cache/arduino/sketches/BIG_HEX_NUMBER, whereas in previous versions, they went into the temporary filesystem.

2. Open and compile the sketch. 

3. Open a terminal session at the location where the compiled sketch was written to.

4. Start a simulator session:

	simulavr --gdbserver --device atmega328 --cpufrequency 16000000


5. Open a second terminal session, and change to the same location.

6. Start a debug session:

	ddd --debugger avr-gdb
	
	Al following instructions take place in the debugger.

7. Click File->Open Program. Select the *.elf file that is listed. Click OK.

8. Type:

	target remote localhost:1212
	load
	
9. Set a breakpoint at the "main" and "loop" labels:

	br main
	br loop
	cont
	
	The sketch will run and stop at the beginning of the main code.
	
10. Click "step" repeatedly to step through the code assigning variables and preserving corrupted registers until you get to the "call xxxxx" instruction. At this point, click "next" to call the Libgcc function, and return.

11. Observe the values in the Libgcc functions's return registers. Are they as expected?

Why not try amending the unsigned functions to put negative values where negative values are not supposed to be! What happens? Can you explain why you get the results you get?

Have fun!


Norman Dunbar
26 January 2025.


