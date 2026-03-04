LedSwitchPullup.ino

This sketch shows illuminate an LED when a switch, attached to 
D8/PB0 is pressed. The switch is conigured as INPUT_PULLUP and
because of this, any time we write to the switch port, we must
keep the switch's bit in the port, set. If not, the switch will 
revert to INPUT without a PULLUP.

The switch is debounced with a software 
delay. Uses the LED on D13/PB5 for the demo.

