There are some Arduino libraries in this folder. These 
have been used in at least two sketches in the book and so, 
to avoid constant repetition and copying files from sketch to 
sketch, I have created the libraries you see here.

***************************************************************

=========
ASM_Usart
=========

ASM_Usart is a small library which initialises the USART to 
transmit at 9600 baud; and to transmit the contents of the 
buffer that the X register is pointing to.

This library is not usable from C++ sketches. It is able to be
installed in the Arduino IDE and as such, can them be used by 
Assembly code developed in the IDE.

Interrupts are not used, this is a "busy wait" library.

Functions:

UsartTX9600 - initializes the USART for TX only at 9600 baud.

transmit_x - prints out the contents of the buffer which the 
             X register is pointing at. The last byte in the 
             buffer must be a zero byte, in the usual C/C++ 
             manner, so that the code can stop transmitting.

transmit_z - prints out the contents of the buffer which the 
             Z register is pointing at. The last byte in the 
             buffer must be a zero byte, in the usual C/C++ 
             manner, so that the code can stop transmitting.

transmitByte - Transmits the byte in R19 to the USART. This
               blocks until the flag is set to indicate that
               a new byte can be loaded into the USART 's 
               data register for transmission. 
               
---------------------------------------------------------------
NOTE:
---------------------------------------------------------------
This library is pretty basic! It is intended as a quick demo
on how to create one for use with Assembly Language code.
---------------------------------------------------------------
             
***************************************************************


===
WDT
===

The WDT library is able to be called from Assembly and C++ to
initialise the Watchdog Timer in one of four modes: 

wdtMode_Off				- Disabled.
wdtMode_Reset			- Will cause a reset if timeout expires.
wdtMode_Interrupt		- Interrupts every time the timeout 
						  expires. Will not reset the board.
wdtMode_ResetInterrupt	- Executes the interrupt handler on the 
						  first timeout, then resets the board 
						  on the following timeout.

The Watchdog can be configured with 10 different timeout values.

wdtTO_16MS	- 16 milliseconds. This is also the configuration 
			  after a reset caused by the watchdog timer 
			  expiring.
wdtTO_32MS	- 32 milliseconds.
wdtTO_64MS	- 64 milliseconds.
wdtTO_125MS	- 125 millseconds.
wdtTO_250MS	- 250 millseconds.
wdtTO_500MS	- 500 millseconds.
wdtTO_1S	- 1 second.
wdtTO_2S	- 2 seconds.
wdtTO_4S	- 4 seconds.
wdtTO_8S	- 8 seconds.

The library provides three functions:

wdtEnable	- Enables the watchdog. Requires a parameter of 
			  (Timeout << 8)|(mode) to set both the timeout 
			  and the mode.
wdtDisable	- Disables the watchdog. Resets the timeout to the 
			  default, 16 milliseconds.
wdtReset	- Resets the watchdog timeout. Must be called 
			  before each current timeout period expires. Not
			  required in wdtMode_Interrupt mode. If the timer
			  expires before wdtReset is called, the board will 
			  reset if configured to do so.

***************************************************************

==========
LCDLibrary
==========

This library is fully described in the "Liquid Crystal Library"
chapter in the book. 

It is a fully fledged library for accessing LCD displays from
Assembly code. It has restrictions though as it is hard coded
to run in 4 bit mode (to save output pins) and the R/W (Read/
write) in is tied to ground so the LCD status etc cannot be 
read back from the display.

***************************************************************

=======
I2C_ASM
=======

This library is fully described in the "I2C" chapter in the book. 

It is a library to make accessing I2C sensors easy. It is also 
used as the base for the LM75A_LIB library developed in the 
"LM75A" chapter.

***************************************************************

=========
LM75A_LIB
=========

This library is fully described in the "LM75A" chapter in the 
book. 

It is a library to make accessing LM75 sensors easy. It does 
require the I2C_ASM library developed in the "I2C" chapter.

***************************************************************


