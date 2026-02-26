LEDSwitchDebounceHistory.ino

This Assembly sketch shows how to use the method of "switch 
history" to debounce a switch.

The file debouncePINB.S can be added to an Assembly Language 
sketch to debounce a switch attached to any pin on PORTB as an 
input. See the file header for full instructions.

Files LEDSwitchDebounceHistory.ino/LEDSwitchDebounceHistory.S 
are a simple test sketch to demonstrate the use of the debounce 
subroutine. An LED on pin PB5/D13 will be lit or extinguished 
by a switch on pin PB0/D8.

