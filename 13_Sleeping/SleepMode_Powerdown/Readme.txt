Sleep Mode POWERDOWN

This sketch puts the Arduino to sleep. On wakeup, the LED
on pin D13/PB5 will be toggled.

This mode is usable on an Arduino as we don't need to
disable Timer 0's overflow interrupt as it has no effect
in this mode.

Norman Dunbar.
15 September 2024.
