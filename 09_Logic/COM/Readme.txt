The COM.ino sketch demonstrates the use of the COM instruction
to invert all the bits in a register. It sets an initial bitmask
to light up the LEDs attached to D0/D2/D4/D6 and on pressing a
switch, inverts those to light up D1/D3/D5/D7 instead.

LEDs are attached to D0-D7 while a switch is on D11. The switch
should be INPUT_PULLUP or INPUT with an external pullup resistor
of 10 K. The switch, attached to D11, should (must!) be debounced
as per the Fritzing project COM.fzz or the COM.png image.

Norman Dunbar.
10 August 2024.
