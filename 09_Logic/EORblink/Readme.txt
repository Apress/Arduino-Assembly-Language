The EORblink.ino sketch demonstrates the use of the EOR 
instruction to invert a bit in a register and thus, toggle an 
LED. 

In this sketch, we have a LED on pin D13/PB5. We toggle the LED 
on and off using the EOR instruction to flip the PORTB5 bit 
each time through the loop(). There is no need for the code to 
remember the current LED state. 


Norman Dunbar.
10 August 2024.
