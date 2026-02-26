Sleep Mode Idle No Timer

This sketch puts the Arduino to sleep in Idle mode. On 
wakeup, the LED on pin D13/PB5 will be toggled. However,
IT NEVER WAKES UP!

The Idle sleep mode is never woken as we disable the 
Oveflow Interrupt on Timer 0. That no longer generates an
interrupt, so as there are none of the other stimuli 
available to wake the baord, it stays asleep.

The LED never illuminates.


Norman Dunbar.
15 September 2024.
