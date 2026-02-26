Watchdog Reset Interrupt

A sketch to blink an LED a few times, then configure the
watchdog to trigger the interrupt after a couple of seconds
then, after another couple, to reset the board.

===========================================================
WARNING WARNING WARNING WARNING WARNING WARNING WARNING !!
===========================================================

This sketch may cause boot loops if the bootloader on your
Arduino board is too slow to disable the WDT on a restart.
The Uno, running Optiboot - the default bootloader - does
not have a problem. The Duemilanove does!

===========================================================
WARNING WARNING WARNING WARNING WARNING WARNING WARNING !!
===========================================================

Norman Dunbar.
27 September 2024.
