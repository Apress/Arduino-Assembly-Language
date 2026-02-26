ROL_ROR.ino

This sketch demonstrates what happens when a 1 bit, in the 
carry flag is rotated left, first of all, then right again. 
Eight LEDs are used to show the progress of the single 1 bit 
across the entire register.

As the bit rotates into the register, from carry, the LEDs 
start with all off. As the bit rotates, each LED is lit in 
turn until the bit rotates out of the register and back into 
the Carry flag, thus extinguishing all the LEDs.

Norman Dunbar.
5 August 2024.
