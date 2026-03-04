PWM Test

Configure Timer 1 in phase correct PWM mode with TOP = 1023. 
The prescalar will be 64. Pin D9/PB1 will toggle on match with 
OCR1A.

Also configures D9/PB1/OC1A as output.

Timer 1's overflow interrupt is used to brighten and dim the 
LED attached to pin D9/PB1/OC1A.

Norman Dunbar.
11 October 2024. 

