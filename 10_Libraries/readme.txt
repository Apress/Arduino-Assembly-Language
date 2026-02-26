The ASM_Usart directory is the full sources, as discussed in the
library chapter in the book, for the ASM_Usart library for the 
Arduino IDE. 

This library is also contained in the "Arduino Libraries Used" 
directory in the code repository.


BrokenBlink is a sketch to demonstrate why, when writing libraries,
we must use the various macros to wrap the SFRs to avoid breaking
sketches in C/C++ which use direct access to those SFRs.

Uncommenting the "#define __SFR_OFFSET 0" line will break the
sketch.

Norman Dunbar.
29 July 2025.
