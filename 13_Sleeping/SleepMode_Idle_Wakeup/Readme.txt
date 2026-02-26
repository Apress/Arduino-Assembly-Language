Sleep Mode Idle No Timer Wakeup

This sketch puts the Arduino to sleep in Idle mode. Timer
0's Overflow Interrupt is disabled while the board is 
asleep so micros() and millis() do not increment. The
watchdog timer is configured to wake the board every two
seconds and this lets the LED blink.

Norman Dunbar.
15 September 2024.
