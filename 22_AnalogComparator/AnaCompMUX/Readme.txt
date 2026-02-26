AnaCompMUX.ino

This sketch uses the Analog Comparator in multiplexer mode where pin D6/AIN0 is the positive
input pin and A0/ADC0 is the negative input. Whenever the voltage measured on the positive 
pin is higher than the positive pin's voltage, the analog comparator's output bit goes high.

This bit going high has been configured to trigger an interrupt which will set the LED 
attached to D13/PB5 to follow the state of the analog comparator's output.


Norman Dunbar.
30 May 2025.
