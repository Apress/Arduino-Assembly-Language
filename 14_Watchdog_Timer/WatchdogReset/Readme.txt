Watchdog Reset

A sketch to blink an LED a few times, then configure the
watchdog to reset the board after a couple of seconds.

==========================================================
WARNING WARNING WARNING WARNING WARNING WARNING WARNING !!
==========================================================

This sketch may cause boot loops if the bootloader on your
Arduino board is too slow to disable the WDT on a restart.
The Uno, running Optiboot - the default bootloader - does
not have a problem. The Duemilanove does!

==========================================================
WARNING WARNING WARNING WARNING WARNING WARNING WARNING !!
==========================================================

Norman Dunbar
27 September 2024
