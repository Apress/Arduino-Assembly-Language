============================================================
 SPI_Peripheral.ino

 This example shows how to use SPI in peripheral mode. This
 board will receive data values over SPI and write them to 
 PORTD where a set of 8 LEDs will light up according to the
 value received.

 Norman Dunbar.
 22 July 2025.
============================================================

============================================================
 CONNECTIONS

------------------------------------------------------------
 Peripheral       Controller      Arduino Pin 
------------------------------------------------------------
 SS               SS              D10/PB2
 COPI/MOSI        COPI/MOSI       D11/PB3
 CIP)/MISO        CIPO/MISO       D12.PB4
 SCK              SCK             D13/PB5

 5V               5V
 GND              GND

 Also:

 D0/PD0 to 560R to LED+ to GND.
 D1/PD1 to 560R to LED+ to GND.
 D2/PD2 to 560R to LED+ to GND.
 D3/PD3 to 560R to LED+ to GND.
 D4/PD4 to 560R to LED+ to GND.
 D5/PD5 to 560R to LED+ to GND.
 D6/PD6 to 560R to LED+ to GND.
 D7/PD7 to 560R to LED+ to GND.
============================================================

-------------------------------------------------------------
 As for the 8 LEDs on the same port, there's a pin limit of 
 20 mA but a port limit of 100 mA maximum. I've got red, amber
 and green LEDs. The reds have a forward voltage of 1.86V, 
 amber is 2.08V and green is 2.93V. For 8 LEDs with 560R
 resistors, we have:

 RED:   5V - 1.86 V = 3.14 V / 560 R = 5.6 mA * 8 = 44.8 mA total.
 AMBER: 5V - 2.08 V = 2.92 V / 560 R = 5.2 mA * 8 = 41.6 mA total.
 GREEN: 5V - 2.93 V = 2.07 V / 560 R = 3.7 mA * 8 = 29.6 mA total.
-------------------------------------------------------------

