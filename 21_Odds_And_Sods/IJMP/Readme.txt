The IJMP sketch demonstrates the use of the IJMP instruction to 
make an indirect jump to the piece of code whose address is in 
the Z register, R31:R30. Beware that this sort of instruction 
can lead to spaghetti code as a further jump back into the loop 
will be required, unlike ICALL.

It should be noted that this address must be a WORD address and 
not a BYTE address as the avr-as assembler creates by default. 
In order to facilitate this requirement, the high and low bytes 
of the address are extracted using the pm_hi8 and pm_lo8 
assembler functions rather than the usual hi8 and lo8.


Norman Dunbar
25 May 2025.
