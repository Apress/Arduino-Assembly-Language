ASMTimerFunctions Sketch

A useful set of assembly routines to replace the Arduino
micros(), millis(), delay() functions with similar ones 
that can be called from Assembly code, without needing to
call out to C++.

Shows the use of Timer 2's overflow Interrupt.

ASMmillis() = same as millis().
ASMmicros() = same as micros().
ASMdelay(x) = same as delay(x).
ASMdelayMicros(x) = same as delayMicroseconds(x).
ASMinitTimer2 = initialises the system to allow the above
                functions to work. Must be called as part
                of the sketch initialisation.

Obviously, if these are required to be called from C++
a cppInterface will be required, in the usual manner. 
However, the routines are expected to be used in Assembly
code, not C++, as C++ already has them.

WARNING ---------------------------------------------------
It is not possible to use Timer 0 here, as the Arduino
already uses it, and we would get duplicate errors for
the ISR as the Arduino software defines it.
-----------------------------------------------------------

Norman Dunbar.
13 August 2024.
