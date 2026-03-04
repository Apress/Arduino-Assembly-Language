LM75A Examples.

There are a number of example sketches using the LM75A_LIB library. 
These are:

LM75A_Comparator - uses the LM75A in comparator mode to monitor 
the temperature and light an LED when it's too hot; and 
extinguish it when it cools down again.

LM75A_Interrupt - uses the LM75A in interrupt mode to monitor 
the temperature and light an LED when it's too hot; and 
extinguish it when it cools down again. However, by commenting 
out one line, the sketch changes and lights the LED on an over 
temperature situation, and leaves it lit even though the current 
temperature may have dropped below the minimum setting. Like an 
alarm to show it happened, even if nobody was there to see it.

LM75A_Read - reads the current temperature and displays it on 
the Serial Monitor every 5 seconds. The LM75A is in full power 
mode.

LM75A_Read_Write - configures the current temperature register 
as the default "read" register, then reads and display its 
value every 5 seconds.

LM75A_Shutdown - reads the current temperature and displays it on 
the Serial Monitor every 5 seconds. The LM75A is in low power 
or shutdown mode.


NOTE: All sketches use the breadboard layout shown in the file 
LM75A_Read.png or in the Fritzing project LM75A_Read.fzz. 
Not all sketches use the LED and/or the OS to D2/PD2 wire.



Norman Dunbar.
13 August 2025.


