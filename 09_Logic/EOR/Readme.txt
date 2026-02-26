This is a bonus sketch, not detailed in the book.

The EOR.ino sketch demonstrates the use of the EOR instruction
to invert a bit in a register and thus, toggle an LED 

In this sketch, we have a switch on pin D11 and the LED on
pin D13. We toggle the LED on and off using the switch, but
we use the EOR instruction to flip the D13 bit each time. There
is no need for the code to know the current LED state. 

The switch is debounced with a pair of 10K resistors and a 
100nF ceramic capacitor.

Norman Dunbar.
10 August 2024.
