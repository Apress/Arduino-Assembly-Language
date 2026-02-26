The file in this directory is one that is able to be used as, or
added to an existing "platform.local.txt" file. Adding the 
contents will allow the Arduino IDE (version 2.x) option

	Sketch->Optimize for debugging
	
to be used with an Arduino Uno and the like. It turns off the
IDE's default optimization (for size) and adds debugging 
information to the sketch. This of course makes the file very
much larger than normal, but it means that code can be debugged
with SimulAVR and the avr-gdb debugger without the developer 
(and this author!) being confused as to why the program counter
is all over the place, and, where have my functions gone. 

These effects make debugging difficult and are a result of the 
intelligence of the optimizer.7

Norman Dunbar.
