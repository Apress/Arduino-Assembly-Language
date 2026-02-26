The standard Blink sketch converted to pure Assembly code
and utilising the "ASM Timer Functions" to replace the
millis(). micros() and delay() Arduino functions.

The timer functions make use of Timer 2 as the Arduino 
uses Timer 0, however, as we are not using the Arduino 
language here, it makes no actual difference and we could
use Timer 0 ourselves.

Norman Dunbar.
13 August 2024.
