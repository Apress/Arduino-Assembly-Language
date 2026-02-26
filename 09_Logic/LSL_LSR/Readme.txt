LSL_LSR.ino

This sketch demonstrates what happens when a 1 bit, in a 
register is shifted left, first of all, then right again. 
Eight LEDs are used to show the progress of the single 1 bit 
across the eight bits of the register.

As the bit starts in bit 0 of the register, the LEDs are
never all off. As the bit shifts, each LED is lit in 
turn until the bit shifts out of the register and into 
the Carry flag. The LEDs are never all off.

Norman Dunbar.
5 August 2024.
